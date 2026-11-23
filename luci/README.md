# LuCI 页面

此目录提供 WARP MASQUE 的中文 LuCI 配置页面。

当前页面可配置：
- 启用/停用服务
- 网络出口模式：有 WAN 口 / 无 WAN 口
- WAN 逻辑接口名称
- SOCKS5 与 HTTP CONNECT 监听地址、端口
- 日志等级

**注意：** 页面中的出口模式目前用于保存用户选择；实际按接口绑定外层 MASQUE 流量，以及可靠绕过 PassWall OUTPUT 捕获的后端逻辑尚未完成验证。不要把 UI 选项误认为已经具备防回环能力。
