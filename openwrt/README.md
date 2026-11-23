# OpenWrt package

This directory contains the OpenWrt package recipe and procd service.

- The package builds the upstream `usque` Go client in proxy-only mode.
- SOCKS5 defaults to `127.0.0.1:32500`.
- HTTP CONNECT defaults to `127.0.0.1:32511`.
- No TUN device is created and no default route is changed.
- PassWall configuration is never read or modified.

Enable after installation:

```sh
uci set warp-masque.main.enabled='1'
uci commit warp-masque
/etc/init.d/warp-masque enable
/etc/init.d/warp-masque start
```

The first start registers a WARP device and stores its credentials in
`/etc/warp-masque/config.json`. Back up this file securely.
