# lua-pdfkit

Pure Lua PDF writer. No Node, no C module, and no network at runtime. `require "lua-pdfkit"` returns the document constructor.

```lua
local PDFDocument = require "lua-pdfkit"

local doc = PDFDocument.new({ size = "LETTER" })
doc:fontSize(16)
doc:text("hello", 72, 72)

local out = assert(io.open("out.pdf", "wb"))
doc:pipe(out)
doc:finish()
out:close()
```

`pipe` takes an open Lua file handle. Two names differ from PDFKit, because Lua reserves the word: `doc.end()` is `doc:finish()`, and `ref.end()` is `ref:finish()`. Everything else keeps PDFKit's spelling.

## Credit

This is an independent Lua port of [PDFKit](https://pdfkit.org/) by [Devon Govett](https://github.com/foliojs/pdfkit). The pin for this release is PDFKit 0.20.2. This project is not affiliated with foliojs or Devon Govett.

## What matches 0.20.2

A match is byte-identical PDF output after three length-preserving blankings: PDF dates shaped like `(D:YYYYMMDDHHMMSSZ)`, the trailer `/ID` array, and `<xmp:CreateDate>` in the XMP packet.

| family | what it covers | claim |
|---|---|---|
| A | Measured text placement | matches 0.20.2 |
| B | Page geometry, revisiting pages, info dictionary | matches 0.20.2 |
| C | Vector graphics | matches 0.20.2 |
| D | Colour, opacity, spot colour | matches 0.20.2 |
| E | SVG path data | matches 0.20.2 |
| F | The fourteen standard fonts | matches 0.20.2 |
| G | Mixed page sizes and orientation | matches 0.20.2 |
| H | Text layout: alignment, columns, lists, decorations, links | matches 0.20.2 |
| I | Gradients and tiling patterns | matches 0.20.2 |
| J | JPEG and PNG | matches 0.20.2 |
| K | Embedded-font pipeline | matches 0.20.2 |
| L | Embedded TrueType, subset widths, ToUnicode | matches 0.20.2 |
| M | Annotations | matches 0.20.2 |
| N | Structure tree and marked content | matches 0.20.2 |
| O | Table layout | matches 0.20.2 |
| P | Tagged tables | matches 0.20.2 |

Present in the tree, and not part of that claim: interactive forms, PDF encryption, outlines, and the JavaScript entry points `registerFile`, `toBytes`, and `toBlob`. Callers pass a filesystem path or a byte string, and read the PDF from `pipe` / `finish`.

## Notices

Standard-font metrics are generated from Adobe AFM data. The deflate path is a transcription of zlib 1.3.1. PDF/A documents embed the sRGB IEC61966-2.1 profile. The notices are in [NOTICE](NOTICE).

## Tests

```bash
lua test/smoke.lua
```

`test/compare.sh` is the byte-identical claim. It needs Node, npm, and `qpdf`. `test/smoke.lua` does not.

## Install

```bash
luarocks --lua-version=5.5 install lua-pdfkit
```

From a clone of this repository:

```bash
luarocks --lua-version=5.5 make
```

The rockspec depends on `lua >= 5.5`. The default `luarocks` on some machines is bound to Lua 5.4, which cannot satisfy that. Lua 5.5.1 is what the suite runs on.

LuaRocks 3.9.2 reads `LUA_VERSION_NUM` as a literal in `lua.h`. Lua 5.5 writes that macro as an expression, so `luarocks make` reports that the header does not match. Point `LUA_INCDIR` at a header that contains `#define LUA_VERSION_NUM 505`. This rock builds no C.

## Repository Information
[![Count Lines of Code](https://github.com/500Foods/lua-pdfkit/actions/workflows/main.yml/badge.svg)](https://github.com/500Foods/lua-pdfkit/actions/workflows/main.yml)
<!--CLOC-START -->
```cloc
Last updated at 2026-11-06 02:32:26 UTC
-------------------------------------------------------------------------------
Language                     files          blank        comment           code
-------------------------------------------------------------------------------
Markdown                         2              9              2             39
YAML                             2              8             13             37
-------------------------------------------------------------------------------
SUM:                             4             17             15             76
-------------------------------------------------------------------------------
2 Files were skipped (duplicate, binary, or without source code):
  gitattributes: 1
  gitignore: 1
```
<!--CLOC-END-->

## Sponsor / Donate / Support
If you find this work interesting, helpful, or valuable, or that it has saved you time, money, or both, please consider directly supporting these efforts financially via [GitHub Sponsors](https://github.com/sponsors/500Foods) or donating via [Buy Me a Pizza](https://www.buymeacoffee.com/andrewsimard500). Also, check out these other [GitHub Repositories](https://github.com/500Foods?tab=repositories&q=&sort=stargazers) that may interest you.
