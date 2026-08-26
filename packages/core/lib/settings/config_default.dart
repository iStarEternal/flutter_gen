const configDefaultYamlContent = '''
name: UNKNOWN

flutter_gen:
  output: lib/gen/ # Optional
#  line_length: 80 # Optional
  parse_metadata: false # Optional

  # Optional
  integrations:
    image: true
    flutter_svg: false
    rive: false
    lottie: false
  
  images:
    # Optional
    parse_animation: false

  assets:
    enabled: true # Optional
    outputs: # Optional
      # Set to true if you want this package to be a package dependency
      # See: https://flutter.dev/docs/development/ui/assets-and-images#from-packages
      package_parameter_enabled: false # Optional
      # Available values:
      # - camel-case
      # - snake-case
      # - dot-delimiter
      style: dot-delimiter # Optional
      class_name: Assets
      # Optional. Relative to the package root. When set with integrations.flutter_svg,
      # SvgGenImage omits inline svg(); FlutterGen emits assets.svg_ext.gen.dart from this template.
      # svg_extension_template: tool/flutter_gen_templates/svg_gen_image_ext.dart.template
      # Optional. Per-folder SvgGenImage subclasses (longest path prefix wins):
      # svg_path_classes:
      #   - path: assets/v3_svg/
      #     class_name: V3SvgGenImage
      #     template: tool/flutter_gen_templates/v3_svg_gen_image.dart.template
    exclude: []

  fonts:
    enabled: true # Optional
    outputs: # Optional
      class_name: FontFamily

  colors:
    enabled: true # Optional
    inputs: [] # Optional
    outputs: # Optional
      class_name: ColorName

flutter:
  # See: https://flutter.dev/docs/development/ui/assets-and-images#specifying-assets
  assets: []
  # See: https://flutter.dev/docs/cookbook/design/fonts#2-declare-the-font-in-the-pubspec
  fonts: []
''';
