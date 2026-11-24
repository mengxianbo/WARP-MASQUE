# WARP-MASQUE for OpenWrt

**Cloudflare WARP MASQUE 本机代理插件｜中文版**

本项目基于上游 [Diniboy1123/usque](https://github.com/Diniboy1123/usque) v1.5.0，为 OpenWrt 提供 Cloudflare WARP MASQUE SOCKS5 和 HTTP CONNECT 代理，并提供中文 LuCI 管理页面。

> 本项目是第三方开源集成，不是 Cloudflare 官方软件，也不代表 Cloudflare 对本项目提供支持。

## 一、设计原则

- 仅使用 WARP MASQUE，不使用 TUN 模式，不创建 TUN 网卡。
- 不接管 LAN 默认路由，不修改系统默认路由。
- 默认仅监听路由器本机：SOCKS5 地址 127.0.0.1:32500，HTTP CONNECT 地址 127.0.0.1:32511。
- 不自动添加、删除或修改 PassWall 节点，不自动暂停 PassWall。
- PassWall 节点由用户手动添加。
- 注册必须由用户在 LuCI 页面主动点击「同意条款并注册」触发；开机启动服务不会擅自注册新设备。
- 当前 WAN 出口绑定和 PassWall 外层连接防回环仍未完成实机验证，不能把本版本当作已解决回环的正式网关方案。

## 二、当前版本和支持范围

| 项目 | 当前构建目标/状态 |
|---|---|
| 软件包版本 | 1.2.0-1 |
| OpenWrt 架构 | x86_64 |
| 软件包格式 | IPK（opkg 系统） |
| WARP 客户端 | usque v1.5.0 |
| LuCI | 中文管理页，含注册、启动、停止操作 |
| 注册条款确认 | 用户点击授权后调用上游 register --accept-tos |
| SOCKS5 / HTTP CONNECT | 启动命令已集成，需在目标固件实测 |
| WAN / 默认出口选择 | 当前保存设置，尚未强制绑定出口 |
| PassWall 自动联动 | 不做，不修改 PassWall 配置 |
| PassWall 外层连接绕行 | 尚未完成验证 |
| TUN / 默认路由接管 | 不使用 |

**兼容性提示：** 当前 Actions 产物面向 x86_64、使用 opkg 的 OpenWrt。若系统为 apk 包管理器、ARM/ARM64、MIPS 或其他架构，不要安装此 IPK。先确认固件版本、架构和包管理器。

## 三、下载

- GitHub Releases：<https://github.com/mengxianbo/WARP-MASQUE/releases>
- 最新 Release 资产：<https://github.com/mengxianbo/WARP-MASQUE/releases/latest/download/warp-masque_1.2.0-1_x86_64.ipk>

如果最新构建尚未发布，请进入 Releases 页面选择最新成功构建；也可以在 Actions 页面下载构建产物：<https://github.com/mengxianbo/WARP-MASQUE/actions>。

## 四、安装前检查

通过 SSH 登录 OpenWrt，执行：

    ubus call system board
    cat /etc/openwrt_release
    opkg print-architecture
    command -v opkg

确认设备是 x86_64、系统使用 opkg 而不是 apk，并且路由器可以访问 GitHub 和 Cloudflare 注册服务。建议先备份配置：

    sysupgrade -b /tmp/openwrt-backup.tar.gz

同时确保有 Proxmox/VNC/串口等本地救援入口。

## 五、完整安装命令

### 方法 A：SSH 下载并安装

    cd /tmp
    wget -O warp-masque_1.2.0-1_x86_64.ipk https://github.com/mengxianbo/WARP-MASQUE/releases/latest/download/warp-masque_1.2.0-1_x86_64.ipk
    opkg update
    opkg install ca-bundle
    opkg install luci-base
    opkg install ./warp-masque_1.2.0-1_x86_64.ipk

如果固件软件源没有 luci-base，请先确认固件本身是否安装 LuCI；不要从不匹配的固件源强行安装依赖。

### 方法 B：电脑下载后上传

1. 在电脑打开 <https://github.com/mengxianbo/WARP-MASQUE/releases>。
2. 下载 warp-masque_1.2.0-1_x86_64.ipk。
3. 使用 SCP、WinSCP 或路由器文件管理功能上传到路由器 /tmp/。
4. SSH 执行：

    opkg update
    opkg install ca-bundle
    opkg install luci-base
    opkg install /tmp/warp-masque_1.2.0-1_x86_64.ipk

### 检查安装结果

    opkg list-installed | grep -i warp-masque
    ls -l /usr/bin/usque
    ls -l /usr/libexec/warp-masque
    ls -l /etc/init.d/warp-masque
    ls -l /etc/config/warp-masque

安装后进入 LuCI：**服务 → WARP MASQUE**。若菜单未显示，重新登录 LuCI，再检查：

    /etc/init.d/rpcd restart
    logread | grep -i luci

## 六、首次注册设备（重要）

1. 打开 LuCI：**服务 → WARP MASQUE**。
2. 阅读页面上的条款说明。
3. 点击 **「同意条款并注册」**。
4. 后台启动注册任务；稍等片刻后刷新页面查看状态和注册日志。
5. 注册成功后，设备配置保存在 /etc/warp-masque/config.json。

### 自动确认机制

本插件固定使用上游 usque v1.5.0。该版本 register 命令提供 --accept-tos 参数，专门用于非交互式接受 Cloudflare 服务条款。因此实现不是把一个不区分上下文的 Y 随意写入标准输入，而是在用户主动点击授权按钮后执行：

    /usr/bin/usque -c /etc/warp-masque/config.json register --accept-tos --name "OpenWrt-WARP-MASQUE"

这比模拟键盘输入更可靠。按钮点击代表你同意注册当时适用的条款；不会在没有用户操作时静默注册，也不会自动接受未来版本变化的新条款。

为避免覆盖账户和设备密钥，如果配置文件已经存在，注册动作会拒绝重复注册。不要为了重新注册直接删除配置文件，除非确认旧设备配置不再需要。

### 注册状态和日志

    ls -l /etc/warp-masque/config.json
    tail -n 60 /var/run/warp-masque/register.log
    logread -e warp-masque

配置文件含私钥、访问令牌等敏感信息，请勿上传 GitHub 或发送给他人。权限应保持：

    chmod 700 /etc/warp-masque
    chmod 600 /etc/warp-masque/config.json

## 七、启动、停止和开机启动

完成设备注册后，在 LuCI 点击「启动 SOCKS5 / HTTP 代理」。

SSH 命令：

    /etc/init.d/warp-masque enable
    uci set warp-masque.main.enabled='1'
    uci commit warp-masque
    /etc/init.d/warp-masque start

停止：

    /etc/init.d/warp-masque stop

禁止开机启动：

    /etc/init.d/warp-masque disable
    uci set warp-masque.main.enabled='0'
    uci commit warp-masque

查看进程、端口和日志：

    ubus call service list '{"name":"warp-masque"}'
    ps | grep '[u]sque'
    netstat -lntp 2>/dev/null | grep -E '32500|32511'
    logread -e warp-masque

若系统没有 netstat，可尝试 ss -lntp。

## 八、代理测试

在路由器本机执行 SOCKS5 测试：

    curl -v -x socks5h://127.0.0.1:32500 https://www.cloudflare.com/cdn-cgi/trace

HTTP CONNECT 测试：

    curl -v -x http://127.0.0.1:32511 https://www.cloudflare.com/cdn-cgi/trace

如提示没有 curl：

    opkg update
    opkg install curl

检查输出中的 warp=、ip=、colo= 等字段。测试成功只能说明本机代理可用，不能证明 PassWall 外层连接已经绕过，也不能证明防回环已完成。

## 九、PassWall 手动添加方式

本项目不写入 PassWall UCI，不调用 PassWall API，也不会自动切换节点。

代理服务运行后，可由你自行在 PassWall 添加：

| 类型 | 地址 | 端口 |
|---|---|---:|
| SOCKS5 | 127.0.0.1 | 32500 |
| HTTP | 127.0.0.1 | 32511 |

**防回环警告：** PassWall 可能通过路由器本机 OUTPUT 规则捕获 usque 发出的 MASQUE 外层连接。如果外层连接又被送入本机 WARP 代理，就可能形成代理回环。当前构建尚未实现并验证针对 usque 进程的专用绕行策略。请勿把该节点设置为承担全网流量的正式出口，直到项目明确发布防回环验证完成的版本。

本项目不会通过暂停 PassWall、删除节点、全局排除 root 流量、修改默认路由或创建 TUN 来掩盖问题。

## 十、网络出口选项说明

LuCI 当前有两种设置项：

- **有 WAN 口：指定 WAN 接口**，例如 wan、pppoe-wan。
- **没有 WAN 口：使用系统默认出口**，适合单网口、旁路由和虚拟机。

目前这些设置只保存 UCI 值，尚未实现真正的外层连接绑定。选择某个接口不代表内核路由已经按该接口执行。后续必须结合 PassWall 实际规则，完成专用进程身份/策略路由隔离，并进行断线、重连、DNS、IPv4/IPv6 和回环测试。

## 十一、卸载

先停止并禁用：

    /etc/init.d/warp-masque stop
    /etc/init.d/warp-masque disable

卸载软件包：

    opkg remove warp-masque

如确定不再需要已注册的 WARP 设备配置，再手动删除（不可恢复）：

    rm -rf /etc/warp-masque
    rm -rf /var/run/warp-masque

本插件不会自动清理或修改 PassWall 节点；如曾手动添加，请自行到 PassWall 页面删除。

## 十二、常见问题

**1. LuCI 没有显示 WARP MASQUE 菜单？**

确认已安装 luci-base，然后执行：

    /etc/init.d/rpcd restart

退出并重新登录 LuCI。

**2. 点击注册后一直显示注册中？**

检查：

    ps | grep '[u]sque'
    tail -n 100 /var/run/warp-masque/register.log

确认路由器能访问 Cloudflare 注册服务。不要公开配置文件内容。

**3. 提示设备已注册？**

为防止覆盖原有密钥，插件拒绝重复注册。保留原配置即可使用；确需重新注册时，应先明确处理旧设备和旧配置。

**4. 代理端口没有监听？**

先确认设备注册成功，再执行启动命令并查看：

    logread -e warp-masque
    ps | grep '[u]sque'
    netstat -lntp 2>/dev/null | grep -E '32500|32511'

**5. 能代理上网是否表示没有回环？**

不是。代理可用和 PassWall 外层连接绕行是两件事。防回环尚未通过实测前，不要将其投入全网代理。

## 十三、源码与构建

仓库：<https://github.com/mengxianbo/WARP-MASQUE>

GitHub Actions：<https://github.com/mengxianbo/WARP-MASQUE/actions>

上游 usque：<https://github.com/Diniboy1123/usque>

当前构建流程使用 Go 1.26.3，拉取 usque v1.5.0，构建 Linux x86_64 客户端并组装 IPK。手动构建上游客户端示例：

    git clone --depth 1 --branch v1.5.0 https://github.com/Diniboy1123/usque.git
    cd usque
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -ldflags="-s -w" -o usque .

上游许可证以对应版本仓库中的 LICENSE 文件为准。

## 十四、安全提醒

1. 默认代理只监听 127.0.0.1，不要随意改为 0.0.0.0。
2. 妥善保护 /etc/warp-masque/config.json。
3. 不要把尚未完成防回环验证的构建作为生产主路由的全局代理出口。
4. 修改防火墙或策略路由前先备份配置，确保有本地控制台救援方式。
5. Cloudflare 条款由用户通过 LuCI 按钮主动确认；插件不会在无用户操作时擅自注册或重新接受条款。


## 十五、开源许可证与第三方组件

本仓库原创的 LuCI 页面、OpenWrt 服务脚本、打包脚本、GitHub Actions 工作流及项目文档，采用 **GNU GPL-3.0-only（GPL 第 3 版，仅此版本）** 发布。完整条款见仓库根目录 [LICENSE](LICENSE)。

构建产物中的 `usque` 是独立的上游组件，来自 [Diniboy1123/usque v1.5.0](https://github.com/Diniboy1123/usque/tree/v1.5.0)，其许可证为 MIT；上游版权与许可声明见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。本项目不会把上游 MIT 组件的原始许可证声明替换为 GPL。

**修改与再分发：** 修改本项目 GPL 覆盖的部分或再分发相应二进制时，请遵守 GPL-3.0-only，包括保留版权/许可证声明，并按 GPL 要求提供对应源代码和必要的构建、安装脚本。GitHub 仓库及其 Actions 构建流程用于提供本项目对应源码与构建方式。

**无担保：** 本项目按“现状”提供，不提供任何明示或默示担保。使用者需自行评估网络环境、Cloudflare 服务条款和 OpenWrt 固件兼容性。
