-- Copyright (C) 2026 mengxianbo
-- SPDX-License-Identifier: GPL-3.0-only
-- This file is part of WARP-MASQUE for OpenWrt.

module("luci.controller.warp-masque", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/warp-masque") then
		return
	end

	entry({"admin", "services", "warp-masque"}, cbi("warp-masque"), _("WARP MASQUE"), 90).dependent = false
end
