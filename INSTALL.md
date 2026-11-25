# WARP-MASQUE OpenWrt 安装命令

本文档对应仓库：<https://github.com/mengxianbo/WARP-MASQUE>

软件包版本：**1.2.0-1**

本次仅新增 OpenWrt APK 格式安装包，不改变原有 WARP MASQUE 功能、服务逻辑、端口、LuCI 页面、注册流程或 PassWall 行为。原 IPK 包继续保留。

## 1. 先确认系统版本、架构和包管理器

SSH 登录路由器执行：

```sh
ubus call system board
cat /etc/openwrt_release
opkg print-architecture 2>/dev/null || true
command -v apk || true
command -v opkg || true
uname -m
```

按包管理器选择安装包，**不要只看文件后缀或强行跨版本安装**：

| 固件 | 包管理器 | 应下载 |
|---|---|---|
| OpenWrt 24.10 及更早的 opkg 固件 | `opkg` | `warp-masque_1.2.0-1_x86_64.ipk` |
| OpenWrt 25.12.x（apk-tools 3.x） | `apk` | `warp-masque_1.2.0-1_x86_64.apk` |

当前这两份独立包均为 **x86_64** 构建。ARM、ARM64、MIPS 等其他架构不能安装这两个包。

> OpenWrt 25.12 使用 apk 包管理器和新版 APK v3 包格式。这里的 APK 是 OpenWrt 系统软件包，不是 Android 应用 APK。不要把 IPK 改名为 APK，也不要把旧版 APK v2 当作 25.12 的 APK v3 使用。

## 2. 下载地址

最新 Release 页面：

<https://github.com/mengxianbo/WARP-MASQUE/releases/latest>

Actions 构建记录：

<https://github.com/mengxianbo/WARP-MASQUE/actions>

Release 直链（构建成功并发布对应资产后可用）：

- IPK：<https://github.com/mengxianbo/WARP-MASQUE/releases/latest/download/warp-masque_1.2.0-1_x86_64.ipk>
- APK：<https://github.com/mengxianbo/WARP-MASQUE/releases/latest/download/warp-masque_1.2.0-1_x86_64.apk>

## 3. OpenWrt 25.12.x：安装 APK

先检查系统：

```sh
command -v apk
apk --version
```

### 方法 A：路由器 SSH 直接下载并安装

```sh
cd /tmp
wget -O warp-masque_1.2.0-1_x86_64.apk \
  https://github.com/mengxianbo/WARP-MASQUE/releases/latest/download/warp-masque_1.2.0-1_x86_64.apk

# 更新系统软件源索引
apk update

# 安装本地 APK；该包由项目 Actions 构建，未使用你的路由器本机信任密钥签名
apk add --allow-untrusted ./warp-masque_1.2.0-1_x86_64.apk
```

如果固件已配置的软件源无法提供依赖，请先确认固件版本和软件源完全匹配，再按提示补齐依赖。不要混用其他 OpenWrt 版本的软件源。

### 方法 B：电脑下载后上传

1. 打开 <https://github.com/mengxianbo/WARP-MASQUE/releases/latest>。
2. 下载 `warp-masque_1.2.0-1_x86_64.apk`。
3. 用 SCP 或 WinSCP 上传到路由器 `/tmp/`。
4. SSH 执行：

```sh
apk update
apk add --allow-untrusted /tmp/warp-masque_1.2.0-1_x86_64.apk
```

如果 apk 对本地路径解析有要求，使用带 `./` 的相对路径：

```sh
cd /tmp
apk add --allow-untrusted ./warp-masque_1.2.0-1_x86_64.apk
```

## 4. OpenWrt 24.10 及更早版本：安装 IPK

仅在系统确实使用 `opkg` 时执行：

```sh
cd /tmp
wget -O warp-masque_1.2.0-1_x86_64.ipk \
  https://github.com/mengxianbo/WARP-MASQUE/releases/latest/download/warp-masque_1.2.0-1_x86_64.ipk

opkg update
opkg install ca-bundle
opkg install luci-base
opkg install ./warp-masque_1.2.0-1_x86_64.ipk
```

电脑下载上传方式：

```sh
opkg update
opkg install ca-bundle
opkg install luci-base
opkg install /tmp/warp-masque_1.2.0-1_x86_64.ipk
```

## 5. 安装后检查

APK 固件：

```sh
apk info | grep -i warp-masque
```

IPK 固件：

```sh
opkg list-installed | grep -i warp-masque
```

两种系统均可检查项目文件：

```sh
ls -l /usr/bin/usque
ls -l /usr/libexec/warp-masque
ls -l /etc/init.d/warp-masque
ls -l /etc/config/warp-masque
```

如果 LuCI 菜单没有显示，重新登录 LuCI 并检查：

```sh
/etc/init.d/rpcd restart
logread | grep -i luci
```

LuCI 页面入口：**服务 → WARP MASQUE**。

## 6. 首次注册 WARP 设备

1. 打开 LuCI：**服务 → WARP MASQUE**。
2. 阅读条款说明。
3. 由用户主动点击 **「同意条款并注册」**。
4. 等待注册任务完成，刷新页面查看状态。
5. 注册配置保存在 `/etc/warp-masque/config.json`。

注册命令由插件在用户授权后调用：

```sh
/usr/bin/usque -c /etc/warp-masque/config.json register --accept-tos --name "OpenWrt-WARP-MASQUE"
```

如果已经存在注册配置，不要为了重复注册而直接删除。配置包含私钥和访问令牌，请勿公开：

```sh
chmod 700 /etc/warp-masque
chmod 600 /etc/warp-masque/config.json
```

查看注册日志：

```sh
tail -n 60 /var/run/warp-masque/register.log
logread -e warp-masque
```

## 7. 启动、停止与开机启动

注册成功后，可在 LuCI 页面启动代理。也可以 SSH 执行：

```sh
/etc/init.d/warp-masque enable
uci set warp-masque.main.enabled='1'
uci commit warp-masque
/etc/init.d/warp-masque start
```

停止：

```sh
/etc/init.d/warp-masque stop
```

取消开机启动：

```sh
/etc/init.d/warp-masque disable
uci set warp-masque.main.enabled='0'
uci commit warp-masque
```

查看进程、端口和日志：

```sh
ps | grep '[u]sque'
netstat -lntp 2>/dev/null | grep -E '32500|32511'
logread -e warp-masque
```

默认本机监听地址和端口保持原样：

| 代理 | 地址 | 端口 |
|---|---|---:|
| SOCKS5 | 127.0.0.1 | 32500 |
| HTTP CONNECT | 127.0.0.1 | 32511 |

## 8. 代理测试

SOCKS5：

```sh
curl -v -x socks5h://127.0.0.1:32500 https://www.cloudflare.com/cdn-cgi/trace
```

HTTP CONNECT：

```sh
curl -v -x http://127.0.0.1:32511 https://www.cloudflare.com/cdn-cgi/trace
```

如未安装 curl，按系统包管理器安装匹配版本的 curl。

## 9. PassWall 注意事项

本项目仍然不会自动添加、删除或修改 PassWall 节点，也不会自动暂停 PassWall。用户可按原方式手动添加本地代理：

- SOCKS5：`127.0.0.1:32500`
- HTTP：`127.0.0.1:32511`

**防回环限制保持不变：** PassWall 可能捕获 usque 的 MASQUE 外层连接。当前项目尚未完成并验证专用绕行策略，因此不要把该节点作为全网正式出口，直到项目另行发布防回环验证完成的版本。

## 10. 卸载

先停止服务：

```sh
/etc/init.d/warp-masque stop
/etc/init.d/warp-masque disable
```

OpenWrt 25.12 APK：

```sh
apk del warp-masque
```

OpenWrt 24.10 及更早 IPK：

```sh
opkg remove warp-masque
```

如确定不再需要注册密钥，再手动删除配置（不可恢复）：

```sh
rm -rf /etc/warp-masque
rm -rf /var/run/warp-masque
```

## 11. 重要提醒

- IPK 和 APK 是不同包格式，按系统包管理器选择。
- 本次新增 APK 不改变原插件运行逻辑。
- 当前包仅适用于 x86_64。
- 不要混用不同 OpenWrt 版本的软件源。
- 默认仅监听 127.0.0.1，不建议随意改为 0.0.0.0。
- 安装成功不代表 PassWall 外层连接防回环已经验证。
- WARP 配置文件属于敏感凭据，不要上传到公开仓库。
