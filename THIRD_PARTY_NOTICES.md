# 第三方组件与许可证声明

本仓库包含或在构建产物中分发以下第三方组件。各组件保留其原始版权和许可证；本文件不将第三方组件的许可证改写为本项目许可证。

## usque

- 项目：<https://github.com/Diniboy1123/usque>
- 构建版本：v1.5.0
- 构建方式：GitHub Actions 从上游仓库检出 v1.5.0 标签并编译 Linux amd64 二进制。
- 许可证：MIT
- 版权声明：Copyright © 2025, github.com/Diniboy1123
- 上游许可证文件：<https://github.com/Diniboy1123/usque/blob/v1.5.0/LICENSE.md>

上游 MIT 许可证全文：

```text
The MIT License (MIT)
=====================

Copyright © 2025, github.com/Diniboy1123

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the “Software”), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.


```

## OpenWrt / LuCI 运行环境

本项目面向 OpenWrt，运行时依赖由目标固件及其软件源提供（例如 luci-base、ca-bundle）。这些系统组件并未复制进本仓库；其许可证由各自上游项目决定。

## 许可证边界

- 本仓库原创的 LuCI 页面、OpenWrt 服务脚本、打包与构建脚本、项目文档，按仓库根目录 `LICENSE` 中的 GNU GPL v3.0-only 发布。
- 单独分发的 usque 上游程序仍按其 MIT 许可证发布，MIT 版权与许可声明必须保留。
- 本项目是软件集合/集成项目；本声明不声称拥有 Cloudflare 商标，也不代表 Cloudflare 官方支持。
