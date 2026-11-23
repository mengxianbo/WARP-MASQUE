include $(TOPDIR)/rules.mk

PKG_NAME:=warp-masque
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/Diniboy1123/usque.git
PKG_SOURCE_VERSION:=v1.5.0
PKG_MIRROR_HASH:=skip
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_BUILD_DEPENDS:=golang/host

GO_PKG:=github.com/Diniboy1123/usque
GO_PKG_LDFLAGS_X:=main.version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/warp-masque
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=Cloudflare WARP MASQUE proxy client
  URL:=https://github.com/mengxianbo/WARP-MASQUE
  DEPENDS:=$(GO_ARCH依赖)
endef

define Package/warp-masque/description
 Cloudflare WARP MASQUE client exposing local SOCKS5 and HTTP CONNECT proxies.
 No TUN interface and no system default-route modification.
endef

define Build/Compile
	$(call GoPackage/Build/Compile)
endef

define Package/warp-masque/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/etc/config $(1)/etc/init.d
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/usque $(1)/usr/bin/usque
	$(INSTALL_CONF) ./files/warp-masque.config $(1)/etc/config/warp-masque
	$(INSTALL_BIN) ./files/warp-masque.init $(1)/etc/init.d/warp-masque
endef

$(eval $(call GoBinPackage,warp-masque))
$(eval $(call BuildPackage,warp-masque))
