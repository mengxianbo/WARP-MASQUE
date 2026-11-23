local m = Map("warp-masque", translate("WARP MASQUE"),
	translate("Cloudflare WARP MASQUE 代理设置。此页面提供出口模式与本地代理监听配置。"))

local s = m:section(NamedSection, "main", "warp-masque", translate("基本设置"))
s.addremove = false

local enabled = s:option(Flag, "enabled", translate("启用服务"))
enabled.rmempty = false
enabled.default = "0"

local mode = s:option(ListValue, "network_mode", translate("网络出口模式"))
mode:value("wan", translate("有 WAN 口：指定 WAN 接口"))
mode:value("default", translate("没有 WAN 口：使用系统默认出口"))
mode.default = "default"
mode.rmempty = false
mode.description = translate("选择设备网络结构。请注意：当前版本仅保存此项配置，实际出口绑定与 PassWall 外层连接绕行仍在开发和验证中，不能据此认为已实现防回环。")

local wan = s:option(Value, "wan_interface", translate("WAN 逻辑接口名称"))
wan:depends("network_mode", "wan")
wan.placeholder = "wan"
wan.default = "wan"
wan.description = translate("填写 OpenWrt 网络配置中的逻辑接口名称，例如 wan 或 pppoe-wan。")

local bind = s:option(Value, "bind", translate("代理监听地址"))
bind.default = "127.0.0.1"
bind.rmempty = false
bind.description = translate("建议保持 127.0.0.1，仅允许路由器本机访问。")

local socks = s:option(Value, "socks_port", translate("SOCKS5 端口"))
socks.datatype = "port"
socks.default = "32500"
socks.rmempty = false

local http = s:option(Value, "http_port", translate("HTTP CONNECT 端口"))
http.datatype = "port"
http.default = "32511"
http.rmempty = false

local log = s:option(ListValue, "log_level", translate("日志等级"))
log:value("debug", "debug")
log:value("info", "info")
log:value("warn", "warn")
log:value("error", "error")
log.default = "info"

return m
