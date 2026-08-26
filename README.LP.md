# flutter_gen (fork)

本目录作为 monorepo 的 **git submodule**，指向 [iStarEternal/flutter_gen](https://github.com/iStarEternal/flutter_gen)，供 `lp_assets` path 依赖。

- 基线 tag：`v5.15.0`
- 工作分支：`feat/svg-ext-template`
- 消费方：`lp_modules/lp_assets`
  - 全局 `svg_extension_template` + 可选 `svg_extension_name` → `assets.svg_ext.gen.dart`
  - `svg_path_classes[]`：`svg_extension_template` + 可选 `extension_name` → `assets.<class_snake>_ext.gen.dart`

## 父仓用法

```bash
# 克隆 monorepo 后
git submodule update --init --recursive lp_githubs/flutter_gen

# 或克隆时带上
git clone --recurse-submodules <monorepo-url>
```

## 双仓同步

- **改 generator**：在本目录（submodule）内提交并 `git push` 到 fork。
- **钉版本**：父仓提交更新的 submodule gitlink（`lp_githubs/flutter_gen` 指向的 SHA）。

## 升级

1. 在本目录 fetch / merge upstream 或前进 `feat/svg-ext-template`。
2. 父仓 `git add lp_githubs/flutter_gen` 并提交新的 SHA。
3. 回归 `lp_assets` codegen。
