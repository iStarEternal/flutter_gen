import 'dart:io' show Directory, File;

import 'package:flutter_gen_core/generators/assets_generator.dart';
import 'package:flutter_gen_core/generators/colors_generator.dart';
import 'package:flutter_gen_core/generators/fonts_generator.dart';
import 'package:flutter_gen_core/generators/generator_helper.dart';
import 'package:flutter_gen_core/generators/integrations/svg_integration.dart';
import 'package:flutter_gen_core/settings/config.dart';
import 'package:flutter_gen_core/utils/file.dart';
import 'package:flutter_gen_core/utils/formatter.dart';
import 'package:flutter_gen_core/utils/log.dart';
import 'package:path/path.dart' show join, normalize;

class FlutterGenerator {
  const FlutterGenerator(
    this.pubspecFile, {
    this.buildFile,
    this.assetsName = 'assets.gen.dart',
    this.svgExtName = 'assets.svg_ext.gen.dart',
    this.colorsName = 'colors.gen.dart',
    this.fontsName = 'fonts.gen.dart',
    this.overrideOutputPath,
  });

  final File pubspecFile;
  final File? buildFile;
  final String assetsName;
  final String svgExtName;
  final String colorsName;
  final String fontsName;
  final String? overrideOutputPath;

  Future<void> build({Config? config, FileWriter? writer}) async {
    config ??= loadPubspecConfigOrNull(pubspecFile, buildFile: buildFile);
    if (config == null) {
      return;
    }

    final formatter = buildDartFormatterFromConfig(config);
    final flutter = config.pubspec.flutter;
    final flutterGen = config.pubspec.flutterGen;
    final output = config.pubspec.flutterGen.output;

    void defaultWriter(String contents, String path) {
      final file = File(path);
      if (!file.existsSync()) {
        file.createSync(recursive: true);
      }
      file.writeAsStringSync(contents);
    }

    writer ??= defaultWriter;

    final absoluteOutput = Directory(
      normalize(overrideOutputPath ?? join(pubspecFile.parent.path, output)),
    );
    if (!absoluteOutput.existsSync()) {
      absoluteOutput.createSync(recursive: true);
    }

    if (flutterGen.assets.enabled && flutter.assets.isNotEmpty) {
      final assetsConfig = AssetsGenConfig.fromConfig(pubspecFile, config);
      final generated = await generateAssets(
        assetsConfig,
        formatter,
      );
      final assetsPath = normalize(join(absoluteOutput.path, assetsName));
      writer(generated, assetsPath);
      log.info('Generated: $assetsPath');

      if (flutterGen.integrations.flutterSvg) {
        final integration = SvgIntegration(
          assetsConfig.packageParameterLiteral,
          omitSvgMethod: true,
        );
        final assetsGenImport = "import '$assetsName';";

        // Global extension on SvgGenImage.
        final svgTemplatePath =
            flutterGen.assets.outputs.svgExtensionTemplate?.trim();
        if (svgTemplatePath != null && svgTemplatePath.isNotEmpty) {
          final templateFile = File(
            normalize(join(pubspecFile.parent.path, svgTemplatePath)),
          );
          if (!templateFile.existsSync()) {
            throw StateError(
              'flutter_gen.assets.outputs.svg_extension_template not found: '
              '${templateFile.path}',
            );
          }
          final rendered = integration.renderExtensionTemplate(
            templateFile.readAsStringSync(),
            assetsGenImport: assetsGenImport,
            extensionName:
                flutterGen.assets.outputs.svgExtensionName?.trim(),
          );
          final buffer = StringBuffer()
            ..writeln(header)
            ..writeln(ignore)
            ..writeln(rendered);
          final svgExtPath = normalize(join(absoluteOutput.path, svgExtName));
          writer(formatter.format(buffer.toString()), svgExtPath);
          log.info('Generated: $svgExtPath');
        }

        // Per-path-class extensions (coexist with the global one).
        for (final pathClass in flutterGen.assets.outputs.svgPathClasses) {
          if (!pathClass.hasSvgExtensionTemplate) {
            continue;
          }
          final pathTemplate = pathClass.svgExtensionTemplate!.trim();
          final templateFile = File(
            normalize(join(pubspecFile.parent.path, pathTemplate)),
          );
          if (!templateFile.existsSync()) {
            throw StateError(
              'flutter_gen.assets.outputs.svg_path_classes'
              '[${pathClass.className}].svg_extension_template not found: '
              '${templateFile.path}',
            );
          }
          final rendered = integration.renderExtensionTemplate(
            templateFile.readAsStringSync(),
            assetsGenImport: assetsGenImport,
            onType: pathClass.className,
            extensionName: pathClass.extensionName?.trim(),
          );
          final buffer = StringBuffer()
            ..writeln(header)
            ..writeln(ignore)
            ..writeln(rendered);
          final pathExtName =
              'assets.${_camelToSnake(pathClass.className)}_ext.gen.dart';
          final pathExtPath =
              normalize(join(absoluteOutput.path, pathExtName));
          writer(formatter.format(buffer.toString()), pathExtPath);
          log.info('Generated: $pathExtPath');
        }
      }
    }

    if (flutterGen.colors.enabled && flutterGen.colors.inputs.isNotEmpty) {
      final generated = generateColors(
        pubspecFile,
        formatter,
        flutterGen.colors,
      );
      final colorsPath = normalize(join(absoluteOutput.path, colorsName));
      writer(generated, colorsPath);
      log.info('Generated: $colorsPath');
    }

    if (flutterGen.fonts.enabled && flutter.fonts.isNotEmpty) {
      final generated = generateFonts(
        FontsGenConfig.fromConfig(config),
        formatter,
      );
      final fontsPath = normalize(join(absoluteOutput.path, fontsName));
      writer(generated, fontsPath);
      log.info('Generated: $fontsPath');
    }

    log.info('Finished generating.');
  }
}

/// `V3SvgGenImage` → `v3_svg_gen_image`.
String _camelToSnake(String name) {
  final withUnderscores = name.replaceAllMapped(
    RegExp(r'[A-Z]'),
    (match) => '_${match.group(0)!.toLowerCase()}',
  );
  return withUnderscores.startsWith('_')
      ? withUnderscores.substring(1)
      : withUnderscores;
}
