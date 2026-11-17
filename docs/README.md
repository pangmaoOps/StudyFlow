# StudyFlow

StudyFlow 是使用 ArkTS 与 ArkUI 独立实现的校园学习任务管理应用，面向 DevEco Studio 26.0.0 Previewer。

## 当前功能

- 五个主页面：学习首页、任务管理、学习日历、数据分析、个人中心。
- 任务创建、编辑、删除、完成状态切换、状态筛选和 Navigation 详情页。
- Preferences 持久化任务、学习时长记录和个人设置。
- 月历跨月浏览、按日期标记计划任务。
- 手动学习分钟记录，统计最近七天的时长。
- 通过 Network Kit 请求 JSONPlaceholder 帖子接口，呈现加载、空数据、失败重试与远端资源标题长度图表。
- TaskCard、EmptyState、ProgressCard 三个复用组件。

## 构建

本机 DevEco SDK 26.0.0 和 HarmonyOS SDK 6.1.1：

```powershell
$env:DEVECO_SDK_HOME='<DevEco Studio SDK directory>'
$env:JAVA_HOME='<DevEco Studio bundled JBR directory>'
$env:Path="$env:JAVA_HOME\bin;$env:Path"
.\hvigorw.bat assembleHap --no-daemon
```

网络访问需要在应用中授予 `ohos.permission.INTERNET`。生成的 HAP 位于 `entry/build/default/outputs/default/`。当前构建为未签名调试包。

## 参考资料和许可证

参考仅用于学习 ArkUI API、工程结构及架构，不复用学习管理业务实现或整页 UI。

| 来源 | 用途 | 许可核验 |
|---|---|---|
| [OpenHarmony applications_app_samples](https://github.com/openharmony/applications_app_samples) | 官方样例用于核对基础 ArkTS 与 API 开发方式 | OpenHarmony 项目通常采用 Apache-2.0；仓库/具体样例文件应以对应 LICENSE 和文件头为准。本工程没有拷贝其样例代码 |
| [HMApp_ArkTS](https://github.com/wuyukobe24/HMApp_ArkTS) | 阅读目录组织、网络封装和页面路由章节 | 本次未确认仓库根目录存在明确 LICENSE；仅作技术阅读来源，不复制代码 |
| [Navigation 页面跳转官方指南](https://developer.huawei.com/consumer/en/doc/harmonyos-guides/arkts-navigation-jump/) | NavPathStack、pushPath 参数、路由栈管理 | 华为官方文档，按文档使用，不复制示例页面 |
| [Preferences ArkTS 指南](https://developer.huawei.com/consumer/en/doc/harmonyos-guides/data-persistence-by-preferences/) | 核对 Preferences 适合轻量 KV 设置及持久化 | 官方文档/API |
| [HTTP 网络请求指南](https://developer.huawei.com/consumer/en/doc/harmonyos-guides/http-request/) | 核对 Network Kit、超时、响应码与异步请求 | 官方文档/API |
| [Canvas 绘图指南](https://developer.huawei.com/consumer/en/doc/harmonyos-guides/arkts-drawing-customization-on-canvas/) | 评估原生动态图表能力 | 官方文档/API；本项目优先用原生 Progress 组件保证 Previewer 兼容 |

兼容性依据：本地 SDK 路径 `DevEco Studio/sdk/default/openharmony`，工程 target SDK 26.0.0、compatible SDK 6.1.1。ArkTS 编译、PreviewBuild 编译与 HAP 打包已通过；本机 IDE 的 Previewer 面板仍显示加载失败，因此页面可视运行、交互与网络策略仍待复核。

## Previewer 复核步骤

1. 用 DevEco Studio 打开本目录。
2. 在 `entry/src/main/ets/pages/Index.ets` 打开 Previewer。
3. 依次操作五个底部页签；新增任务，打开详情后编辑、完成和删除；检查重启后数据是否保留。
4. 在日历切换月份、选择日期；在我的页面记录学习分钟数并改每日目标。
5. 进入分析页验证真实时长条形统计；检查远程资料 Loading、成功/失败和刷新。
6. 保存实际 Previewer 页面截图和 Git 图形提交记录截图，再加入课程报告附件。

尚未由本执行环境实际操作 Previewer 图形界面，因此报告不伪称该项已验证，也不放入伪造截图。
