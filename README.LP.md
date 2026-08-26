# flutter_gen (fork)

本目录为 [iStarEternal/flutter_gen](https://github.com/iStarEternal/flutter_gen) 的完整源码检出，供 monorepo path 依赖。

- 基线 tag：`v5.15.0`
- 工作分支：`feat/svg-ext-template`（相对 tag 的本地改动）
- 消费方：`lp_modules/lp_assets`（`svg_extension_template`）

## 双仓同步

- **fork remote**：在本目录内 `git push`（保留本目录 `.git`）。
- **monorepo**：父仓跟踪本目录**文件内容**（提交时勿把嵌套 `.git` 收成 gitlink；见变更 tasks）。

## 升级

1. 在 fork 上 merge / cherry-pick upstream tag。
2. 父仓更新 `lp_githubs/flutter_gen` 文件树并回归 `lp_assets` codegen。
