# OpenWrt package

This directory contains the OpenWrt service integration and package-related
files used by the GitHub Actions build.

- The build workflow fetches and compiles the upstream `usque` v1.5.0 Go client.
- SOCKS5 defaults to `127.0.0.1:32500`.
- HTTP CONNECT defaults to `127.0.0.1:32511`.
- No TUN device is created and no default route is changed.
- PassWall configuration is never read or modified.
- The init service does **not** register a WARP device. Registration must first
  be explicitly initiated by the user from LuCI using the consent button.
- Device credentials are stored in `/etc/warp-masque/config.json`; protect
  this file and never commit it.

After registration, enable the service:

```sh
uci set warp-masque.main.enabled='1'
uci commit warp-masque
/etc/init.d/warp-masque enable
/etc/init.d/warp-masque start
```

The repository's own integration code and scripts are licensed under
GNU GPL-3.0-only; see the root `LICENSE`. The separately built upstream
`usque` executable remains under its MIT license; see
`THIRD_PARTY_NOTICES.md`.
