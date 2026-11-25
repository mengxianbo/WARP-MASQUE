include $(TOPDIR)/rules.mk

PKG_NAME:=warp-masque
PKG_VERSION:=1.2.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/warp-masque
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Cloudflare WARP MASQUE proxy for OpenWrt
  DEPENDS:=+ca-bundle +luci-base
endef

define Package/warp-masque/description
 Cloudflare WARP MASQUE SOCKS5 and HTTP CONNECT proxy with the existing
 Chinese LuCI management interface. This package only repackages the
 existing project files; it does not change runtime behavior.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files/. $(PKG_BUILD_DIR)/
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/warp-masque/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/usr/bin/usque $(1)/usr/bin/usque

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/etc/config/warp-masque $(1)/etc/config/warp-masque

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/etc/init.d/warp-masque $(1)/etc/init.d/warp-masque

	$(INSTALL_DIR) $(1)/usr/libexec
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/usr/libexec/warp-masque $(1)/usr/libexec/warp-masque

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/usr/lib/lua/luci/controller/warp-masque.lua $(1)/usr/lib/lua/luci/controller/warp-masque.lua

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/usr/lib/lua/luci/model/cbi/warp-masque.lua $(1)/usr/lib/lua/luci/model/cbi/warp-masque.lua

	$(INSTALL_DIR) $(1)/usr/share/licenses/warp-masque
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/usr/share/licenses/warp-masque/LICENSE $(1)/usr/share/licenses/warp-masque/LICENSE
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/usr/share/licenses/warp-masque/THIRD_PARTY_NOTICES.md $(1)/usr/share/licenses/warp-masque/THIRD_PARTY_NOTICES.md
endef

$(eval $(call BuildPackage,warp-masque))
