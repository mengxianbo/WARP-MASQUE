local m = Map("warp-masque", translate("WARP MASQUE"),
	translate("Cloudflare WARP MASQUE 本机代理管理。不会创建 TUN，也不会接管 LAN 默认路由。"))
local s = m:section(NamedSection, "main", "warp-masque", translate("设备与服务管理"))
s.addremove = false
local state = s:option(DummyValue, "_state", translate("当前状态"))
state.rawhtml = true
function state.cfgvalue()
	return luci.sys.exec("/usr/libexec/warp-masque status 2>/dev/null")
end
local reg = s:option(Button, "_register", translate("设备注册"))
reg.inputtitle = translate("同意条款并注册")
reg.inputstyle = "apply"
reg.description = translate("点击即表示你同意注册时适用的 Cloudflare 服务条款。程序调用 usque v1.5.0 的 --accept-tos 参数自动确认，无需在终端输入 Y。已有设备配置时拒绝覆盖。")
function reg.write(self, section)
	luci.sys.call("/usr/libexec/warp-masque register >/dev/null 2>&1")
end
local start = s:option(Button, "_start", translate("启动代理"))
start.inputtitle = translate("启动 SOCKS5 / HTTP 代理")
start.inputstyle = "apply"
function start.write(self, section)
	luci.sys.call("/usr/libexec/warp-masque start >/tmp/warp-masque-start.log 2>&1")
end
local stop = s:option(Button, "_stop", translate("停止代理"))
stop.inputtitle = translate("停止服务")
stop.inputstyle = "reset"
function stop.write(self, section)
	luci.sys.call("/usr/libexec/warp-masque stop >/tmp/warp-masque-stop.log 2>&1")
end
local enabled = s:option(Flag, "enabled", translate("开机启用代理"))
enabled.rmempty = false
enabled.default = "0"
enabled.description = translate("首次使用请先完成设备注册。")
local mode = s:option(ListValue, "network_mode", translate("网络出口模式"))
mode:value("wan", translate("有 WAN 口：指定 WAN 接口"))
mode:value("default", translate("没有 WAN 口：使用系统默认出口"))
mode.default = "default"; mode.rmempty = false
mode.description = translate("当前仅保存模式选择；指定 WAN 出口绑定与 PassWall 外层连接防回环尚未实现并通过实测。")
local wan = s:option(Value, "wan_interface", translate("WAN 逻辑接口名称"))
wan:depends("network_mode", "wan")
wan.placeholder = "wan"; wan.default = "wan"
wan.description = translate("例如 wan 或 pppoe-wan。当前仅保存该值，不代表已强制绑定出口。")
local bind = s:option(Value, "bind", translate("代理监听地址"))
bind.default = "127.0.0.1"; bind.rmempty = false
bind.description = translate("建议保持 127.0.0.1，仅允许路由器本机访问。")
local socks = s:option(Value, "socks_port", translate("SOCKS5 端口"))
socks.datatype = "port"; socks.default = "32500"; socks.rmempty = false
local http = s:option(Value, "http_port", translate("HTTP CONNECT 端口"))
http.datatype = "port"; http.default = "32511"; http.rmempty = false
local log = s:option(ListValue, "log_level", translate("日志等级"))
log:value("debug", "debug"); log:value("info", "info"); log:value("warn", "warn"); log:value("error", "error")
log.default = "info"
return m
