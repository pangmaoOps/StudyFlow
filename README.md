# StudyFlow

StudyFlow 是面向 HarmonyOS 的个人学习任务与学习记录应用，使用 ArkTS 和 ArkUI 实现，支持在 DevEco Studio Previewer 中预览。

## 功能

- 首页展示今日任务、完成进度和学习时长快捷记录。
- 任务管理支持创建、编辑、删除、完成状态切换和状态筛选。
- 使用 Navigation 与 NavPathStack 在任务列表、详情和编辑页间跳转。
- 学习日历支持月份切换和按日期查看计划。
- 分析页汇总任务、近七天学习时长，并展示远程测试资源。
- 个人中心编辑昵称和每日目标。
- Preferences 持久化本地数据；Network Kit 请求 JSONPlaceholder，并处理加载、失败和空结果。
- 复用 TaskCard、EmptyState、ProgressCard 等自定义组件。

## 环境与运行

1. 安装 DevEco Studio，并配置 HarmonyOS SDK（工程配置目标 SDK 26.0.0，兼容 SDK 6.1.1）。
2. 在 DevEco Studio 中打开仓库根目录。
3. 等待依赖同步完成后，从 `entry/src/main/ets/pages/Index.ets` 打开页面，在 Previewer 中运行和检查交互。
4. 网络资源使用公开 JSONPlaceholder 测试接口，内容是演示数据，不代表校内资源。

命令行构建示例（按本机安装位置设置环境变量）：

```powershell
$env:DEVECO_SDK_HOME='<DevEco Studio SDK directory>'
$env:JAVA_HOME='<DevEco Studio bundled JBR directory>'
.\hvigorw.bat assembleHap --no-daemon
```

## 目录

- `entry/src/main/ets/pages`：主界面与页面路由。
- `entry/src/main/ets/components`：复用 ArkUI 组件。
- `entry/src/main/ets/services`：Preferences 数据存储与 HTTP 服务。
- `docs`：课程报告、实际 Previewer 截图、验证记录和报告生成脚本。

## 参考资料与许可

本项目独立实现业务、页面和视觉设计。参考资料仅用于核对 ArkTS/ArkUI API 与工程架构，没有复制完整开源应用或学习管理业务代码。请查看 [`docs/README.md`](docs/README.md) 中的参考链接与许可说明。
