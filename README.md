# WARP-MASQUE for OpenWrt

OpenWrt LuCI package for Cloudflare WARP over MASQUE. This project uses the upstream
[usque](https://github.com/Diniboy1123/usque) client in proxy-only mode.

## Defaults

- SOCKS5: `127.0.0.1:32500`
- HTTP CONNECT: `127.0.0.1:32511`
- Transport: MASQUE / HTTP/3 (upstream-supported fallback options are exposed by usque)
- No TUN device, no default-route takeover, and no automatic PassWall configuration.

## Important

This repository is being bootstrapped. The first GitHub Actions run will validate and
build the OpenWrt package. Do not expose the unauthenticated local proxy listeners to
untrusted LAN/WAN networks. Keep them bound to loopback unless you deliberately change
the bind address and configure firewall/authentication.

## Upstream

The MASQUE protocol implementation and proxy modes are provided by
[Diniboy1123/usque](https://github.com/Diniboy1123/usque), licensed under MIT.
