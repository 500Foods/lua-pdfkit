# lua-pdfkit

Pure Lua PDF writer. No Node, no C module, and no network at runtime. `require "pdfkit"` returns the document constructor.

```lua
local PDFDocument = require "pdfkit"

local doc = PDFDocument.new({ size = "LETTER" })
doc:fontSize(16)
doc:text("hello", 72, 72)

local out = assert(io.open("out.pdf", "wb"))
doc:pipe(out)
doc:finish()
out:close()
```

`pipe` takes an open Lua file handle. It is optional: `doc:output()` returns the finished PDF as a string after `finish()`. Two names differ from PDFKit, because Lua reserves the word: `doc.end()` is `doc:finish()`, and `ref.end()` is `ref:finish()`. Everything else keeps PDFKit's spelling. PDFKit's own guide is <https://pdfkit.org/docs/getting_started.html>.

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
| Q | AcroForm fields | matches 0.20.2 |
| R | Outlines | matches 0.20.2 |
| S | Hebrew, right to left | matches 0.20.2 |
| T | Arabic joining | matches 0.20.2 |
| U | Embedded CFF (`.otf`) | matches 0.20.2 |
| V | WOFF1, unwrapped and then subset | matches 0.20.2 |

## Limits

The fourteen standard fonts are WinAnsi. Text outside that encoding needs an embedded font: `.ttf`, `.otf`, or WOFF1.

`userPassword` and `ownerPassword` are refused. Encrypted PDFs are not supported.

WOFF is a web wrapper. PDF does not store it. WOFF1 is inflated and embedded as a normal TrueType or CFF subset. WOFF2 is not supported.

This is a writer. It does not read, merge, or stamp an existing PDF.

Hebrew is laid out right to left. Arabic joining is shaped. Indic, Hangul, and the Universal shaper are not. Variable fonts are not.

Not in this release: PDF encryption, reading or merging existing PDFs, WOFF2, and variable fonts. The JavaScript entry points `registerFile`, `toBytes`, and `toBlob` are not part of the Lua API. Callers pass a filesystem path or a byte string, and read the PDF from `pipe` / `finish` or from `doc:output()`.

## Missing a PDFKit feature?

1.0.0 is the part of PDFKit 0.20.2 that is compared above. If you need a PDFKit feature that did not make this release, please ask for it: <https://github.com/500Foods/lua-pdfkit/issues>.

## Notices

Standard-font metrics are generated from Adobe AFM data. The deflate path is a transcription of zlib 1.3.1. PDF/A documents embed the sRGB IEC61966-2.1 profile. The notices are in [NOTICE](NOTICE).

## Tests

```bash
lua test/smoke.lua
```

`test/compare.sh` is the byte-identical claim. It needs Node, the vendored Yarn, and `qpdf`. `test/smoke.lua` checks the stored digests with no Node and no `qpdf`. It needs `sha256sum`.

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
Last updated at 2026-11-06 05:53:04 UTC
-------------------------------------------------------------------------------
Language                     files          blank        comment           code
-------------------------------------------------------------------------------
Lua                            184           4192           7343          22129
JavaScript                      44            589            464           2446
Text                             4             64              0            304
Markdown                         3            101              2            286
Bourne Shell                     2             29            109            123
YAML                             2              8             13             37
-------------------------------------------------------------------------------
SUM:                           239           4983           7931          25325
-------------------------------------------------------------------------------
28 Files were skipped (duplicate, binary, or without source code):
  ttf: 9
  png: 8
  jpg: 2
  notice: 2
  gitattributes: 1
  gitignore: 1
  jpeg: 1
  otf: 1
  rhkn9ofa9q: 1
  rockspec: 1
  woff: 1
```
<!--CLOC-END-->

## Sponsor / Donate / Support
If you find this work interesting, helpful, or valuable, or that it has saved you time, money, or both, please consider directly supporting these efforts financially via [GitHub Sponsors](https://github.com/sponsors/500Foods) or donating via [Buy Me a Pizza](https://www.buymeacoffee.com/andrewsimard500). Also, check out these other [GitHub Repositories](https://github.com/500Foods?tab=repositories&q=&sort=stargazers) that may interest you.
