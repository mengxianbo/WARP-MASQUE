# WARP-MASQUE for OpenWrt

**Cloudflare WARP MASQUE 代理插件（OpenWrt）**

本项目基于上游开源项目 [Diniboy1123/usque](https://github.com/Diniboy1123/usque)，在 OpenWrt 上提供 WARP MASQUE 代理服务。它不是 WireGuard 版 WARP，也不是 TUN 接管方案。

## 1. 功能与设计目标

- 使用 Cloudflare WARP **MASQUE** 协议。
- 提供本机 SOCKS5 代理：`127.0.0.1:32500`。
- 提供本机 HTTP CONNECT 代理：`127.0.0.1:32511`。
- 不创建 TUN 网卡。
- 不接管 OpenWrt 的 LAN 默认路由。
- 不自动添加、删除或修改 PassWall 节点。
- 不自动暂停或重启 PassWall。
- 代理地址由用户手动添加到 PassWall。
- 计划提供「有 WAN 口」和「无 WAN 口」两种网络出口配置模式。

> **重要状态说明（请先阅读）**：当前已验证成功的是 x86_64 基础 IPK 打包流程。当前 Release 尚不能视为已经完成 LuCI 双模式界面、MASQUE 外层连接绕过 PassWall、WAN 出口绑定和回环防护的正式版本。上述网络隔离功能完成并通过实机测试前，不建议在承担主网络出口的生产路由器上启用。README 中的规划功能不代表当前二进制已经实现。

## 2. 当前构建支持范围

| 项目 | 当前状态 |
|---|---|
| OpenWrt 架构 | x86_64 |
| 软件包 | IPK |
| MASQUE 客户端 | usque v1.5.0 |
| SOCKS5 / HTTP CONNECT | 上游客户端支持；当前服务脚本已配置启动命令，仍需完成路由器实测 |
| LuCI 中文界面 | 正在完善 |
| 有 WAN / 无 WAN 模式 | 设计已确定，正在实现 |
| PassWall 自动联动 | 不会自动修改 PassWall |
| PassWall 外层连接绕行 | 尚未完成验证，不得宣称已解决回环 |
| TUN / 默认路由接管 | 不使用 |

## 3. 下载 IPK

打开本项目的 Releases 页面：

https://github.com/mengxianbo/WARP-MASQUE/releases

当前基础构建资产（仅 x86_64）：

- [warp-masque_1.0.0-1_x86_64.ipk（build-3）](https://github.com/mengxianbo/WARP-MASQUE/releases/download/build-3/warp-masque_1.0.0-1_x86_64.ipk)

也可以在 OpenWrt SSH 中下载：

```sh
cd /tmp
wget -O warp-masque.ipk https://github.com/mengxianbo/WARP-MASQUE/releases/download/build-3/warp-masque_1.0.0-1_x86_64.ipk
```

> build-3 是基础打包验证版本，不包含已完成的 LuCI 双模式出口控制和防回环实现。后续功能版本会发布新的 Release，请以 Releases 页面最新版本说明为准。

## 4. 安装命令

先确认设备架构：

```sh
ubus call system board
opkg print-architecture
```

只有 x86_64 设备可以安装当前 x86_64 IPK。确认系统使用 opkg 后执行：

```sh
opkg update
opkg install /tmp/warp-masque.ipk
```

如果提示缺少依赖，可先安装 CA 根证书：

```sh
opkg update
opkg install ca-bundle
opkg install /tmp/warp-masque.ipk
```

检查安装文件：

```sh
ls -l /usr/bin/usque
ls -l /etc/init.d/warp-masque
ls -l /etc/config/warp-masque
```

## 5. 配置与启动

查看 UCI 默认配置：

```sh
uci show warp-masque
```

默认监听地址和端口：

- SOCKS5：`127.0.0.1:32500`
- HTTP CONNECT：`127.0.0.1:32511`

默认关闭服务。基础服务配置完成后，可通过以下命令启用开机启动并启动服务：

```sh
uci set warp-masque.main.enabled='1'
uci commit warp-masque
/etc/init.d/warp-masque enable
/etc/init.d/warp-masque start
```

首次启动时，服务脚本会在尚无设备配置文件时调用 usque 注册流程。注册成功后，配置保存在：

```
/etc/warp-masque/config.json
```

该文件包含设备密钥和访问凭据，请勿公开、上传到 GitHub 或发送给他人。检查文件权限：

```sh
chmod 700 /etc/warp-masque
chmod 600 /etc/warp-masque/config.json
```

查看服务状态和日志：

```sh
/etc/init.d/warp-masque status
logread -e warp-masque
logread | grep -i usque
```

停止服务：

```sh
/etc/init.d/warp-masque stop
```

## 6. 代理测试

在路由器本机执行 SOCKS5 测试：

```sh
curl -x socks5h://127.0.0.1:32500 https://www.cloudflare.com/cdn-cgi/trace
```

HTTP CONNECT 测试：

```sh
curl -x http://127.0.0.1:32511 https://www.cloudflare.com/cdn-cgi/trace
```

查看监听端口：

```sh
netstat -lntp 2>/dev/null | grep -E '32500|32511'
```

如果系统没有 netstat，可使用：

```sh
ss -lntp 2>/dev/null | grep -E '32500|32511'
```

测试结果中可查看 `warp=` 字段。代理连接成功不等于已经完成 PassWall 回环隔离验证。

## 7. PassWall 手动配置原则

本项目不会自动写入 PassWall 配置。待代理服务运行并完成外层连接绕行验证后，用户可以在 PassWall 中手动添加：

| 类型 | 地址 | 端口 |
|---|---|---:|
| SOCKS5 | 127.0.0.1 | 32500 |
| HTTP | 127.0.0.1 | 32511 |

**不要把 WARP MASQUE 外层连接再次交给这个 WARP 代理本身。** 如果 PassWall 的路由器本机 OUTPUT 规则捕获 usque 的外层连接，就可能形成代理回环。当前版本尚未证明能够在不同 PassWall 版本和防火墙后端下可靠绕过该捕获，因此在完成专用进程身份/策略路由或等效隔离并验证之前，不应将其作为正式出口使用。

本项目不会通过暂停 PassWall、删除节点、修改默认路由或创建 TUN 来规避此问题。

## 8. 两种网络出口模式（开发目标）

后续 LuCI 界面提供以下选择：

### 模式 A：有 WAN 口

- 自动枚举网络接口，并允许选择 WAN 逻辑接口（例如 `wan` 或 `pppoe-wan`）。
- 显示检测到的出口、网关和状态。
- 目标是让 usque 的 MASQUE 外层连接走指定 WAN，而不是被 PassWall 再次代理。

### 模式 B：没有 WAN 口

- 面向单网口软路由、旁路由和虚拟机等场景。
- 自动读取系统当前有效的默认出口及网关。
- 不要求设备必须存在名为 `wan` 的逻辑接口。

两种模式都必须满足：不创建 TUN、不接管 LAN 默认路由、不自动修改 PassWall，并对 MASQUE 外层连接实施可验证的防回环隔离。**在后端隔离逻辑和实机测试完成前，模式选择界面不能被当作已经生效的流量绑定功能。**

## 9. 卸载

先停止并禁用服务：

```sh
/etc/init.d/warp-masque stop
/etc/init.d/warp-masque disable
```

再卸载软件包：

```sh
opkg remove warp-masque
```

如需同时删除 WARP 设备注册信息（此操作不可恢复，请先确认不再需要该设备配置）：

```sh
rm -rf /etc/warp-masque
```

卸载插件不会自动修改或清理 PassWall 节点，因为本项目不会管理 PassWall 配置。

## 10. 从源码构建

GitHub Actions 会自动构建 x86_64 IPK。也可以手动构建上游 usque：

```sh
git clone --depth 1 --branch v1.5.0 https://github.com/Diniboy1123/usque.git
cd usque
CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o usque .
```

上游要求 Go 1.26.3 或更新版本。OpenWrt 插件的打包流程见本仓库 `.github/workflows/build.yml`。

## 11. 安全提示

1. 默认只监听 `127.0.0.1`，不要随意改成 `0.0.0.0`。
2. 不要公开 `/etc/warp-masque/config.json`。
3. 不要把当前基础构建当作已完成防回环的正式版本。
4. 不要在远程管理且没有本地控制台/救援方式的主路由上测试未验证的策略路由或防火墙规则。
5. 修改网络出口前，先备份 OpenWrt 配置，并确保可以通过控制台恢复。

## 12. 上游项目与许可

- 上游项目：[Diniboy1123/usque](https://github.com/Diniboy1123/usque)
- 上游协议实现：Cloudflare WARP MASQUE / Connect-IP
- 上游许可证：MIT（请以对应上游版本中的 LICENSE 文件为准）

本项目是第三方开源集成项目，与 Cloudflare 官方没有隶属关系。
