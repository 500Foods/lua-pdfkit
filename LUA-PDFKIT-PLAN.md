# lua-pdfkit

Public MIT Lua port of [PDFKit](https://github.com/foliojs/pdfkit). Pure Lua. No Node, no C module, and no network at runtime.

This file is the plan of record. It follows the checklist at the bottom of `lua-zint-svg/LUA-ZINT-SVG-PLAN.md`. The August 2026 port this plan starts from lives at `~/DA/triton4/triton-toolkit-5b12870/tasks/lua-pdfkit/`. This repository is the 500Foods template with the MIT license already in place. The Lua source is not in it yet.

The first rock claims PDFKit **0.20.2**. The August tree matches 0.19.1. Publishing that pin is not the goal.

The consumer, later, is an all-Lua report writer: a JSON report descriptor and JSON data files in, an HTML file and a PDF file out. This repository is the PDF writer that application will call. The HTML path is a different piece of work. This session does not start that application.

## Session

Follow the order of work below. The August port already matches 0.19.1, so this round is the 0.20.2 delta, the repo cleanup, and the rock. Budget a few hours, the same shape of session as lua-zint-svg.

- Do not build the report writer here.
- Do not bring forms, encryption, or outlines under the comparator.
- Do not restyle the Lua. Keep the PDFKit names.
- Copy the tree and vendor 0.20.2, then run one family. Fix the first diff before reading the rest of the tree.
- Run the copied AFM-based tree against 0.20.2 before replacing the font loader. A kern-decoder bug and a 0.20 behavior change have to stay separate. Switch to the generated metrics after that first compare, then re-run family F.
- `lua` on this machine is 5.5.1 at `/usr/local/bin/lua`. Plain `luarocks` targets Lua 5.4. Every LuaRocks command is `luarocks --lua-version 5.5`.
- `qpdf` 12.3.2 is on `PATH`. Node is v24, which is new enough for PDFKit 0.20.
- The LuaRocks API key is `LUAROCKS_API_KEY` in `~/.festival.env`. Source that file at upload time. Do not write the key into the repo, the rockspec, a commit, or the README. Upload is the last step, after the sixteen families match.

## What this library is

A PDF writer. `require "lua-pdfkit"` returns the document constructor. Callers build a document with the PDFKit method names, then write the bytes.

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

Two names differ from the JavaScript, because Lua reserves the word:

- `doc.end()` is `doc:finish()`
- `ref.end()` is `ref:finish()`

Everything else keeps PDFKit's spelling, camelCase included, so a JavaScript example transliterates line for line. `pipe` takes an open Lua file handle. The writer may hold the bytes and write them at `finish()`. The bytes on disk are the contract.

Compression, font subsetting, PNG decode, and the standard-font metrics are inside this tree. A report that embeds a barcode from `lua-zint-svg` takes that library's form-XObject content stream and wraps it here. This repo does not depend on that rock. The files are plain Lua another project can copy.

## Decisions

- The published Lua is MIT. `NOTICE` carries the notices that have to travel with the code.
- The pin for this round is PDFKit **0.20.2** (release of 2026-08-30, commit `8d72a71`). Git master is past that tag and is not the pin. A globally installed `pdfkit` is not the oracle. The comparator loads the vendored tree.
- Tests run on Lua **5.5.1**. The rockspec depends on `lua >= 5.5`.
- The whole August tree is copied. The byte-compare claim is the sixteen example families below, re-run against 0.20.2. Forms, encryption, and outlines ship in the tree and stay off that claim until a test covers them.
- The module name stays `lua-pdfkit`. Internal `require("lua-pdfkit....")` paths stay. The rock name is `lua-pdfkit`.
- There is no user-facing CLI. PDFKit is a library. `test/compare.sh` is the shell entry the differential harness uses.
- Standard-font metrics follow 0.20.2: generated tables, loaded as Lua modules. The runtime stops parsing AFM files. Widths have to match the generated numbers Node loads.
- Runtime data the rock must install (metric tables, the sRGB ICC profile) lives in Lua modules. A path next to a `.lua` file works in a checkout and disappears under `luarocks make`, because the builtin build installs listed modules.
- The rock and a later copy in another project are the same plain Lua files. Nothing is downloaded at runtime.
- LuaRocks upload is the last step, after the sixteen families match 0.20.2. The key is `LUAROCKS_API_KEY` in `~/.festival.env`.

We do not imply affiliation with foliojs or Devon Govett. The README credits them and says this is an independent Lua port.

## Where the code is today

`github.com/500Foods/lua-pdfkit` on `main` is the template. `LICENSE.md` is already MIT, copyright Andrew Simard, 2026. `.gitignore` is a Delphi template and will be replaced. The CLOC workflow still forces Pascal on `*.inc`. The badge URL already points at this repository.

The port is `solution/lua-pdfkit/` in the Harbor task above. About 115 Lua files, on the order of a megabyte, most of it tables: fontkit, linebreak data, the zlib 1.3.1 compressor (`zlib/deflate.lua`, `zlib/trees.lua`), and `flate.lua` (inflate, Adler-32, the zlib wrapper). `require("lua-pdfkit")` returns the module. `PDFDocument.new` is `Document.new`.

Every Lua file in that tree starts with the Harbor benchmark banner and a canary id. Those lines are stripped before the first commit of the source. They do not appear in this repo.

The August comparator blanks three fields, length-preservingly, then compares the rest byte for byte:

1. PDF dates shaped like `(D:YYYYMMDDHHMMSSZ)`. The fourteen digits become zeros.
2. The trailer `/ID` array. Both 32-character hex strings become zeros.
3. `<xmp:CreateDate>` in the XMP packet, ISO 8601 with a trailing `Z`.

`qpdf --check` runs first. A Lua traceback or a truncated file fails there, with a diagnostic, instead of as a hash mismatch. Those three blankings are the public definition of a match. The stored digests in `tests/digests.txt` are for PDFKit 0.19.1. They are evidence the August port worked. They are not the 0.20.2 claim, and they are regenerated.

The sixteen families, from the held-out programs `example_A` through `example_P` and the matching development programs `test_01` through `test_16`:

| | family |
|---|---|
| A / 01 | Measured text placement |
| B / 02 | Page geometry, revisiting pages, info dictionary |
| C / 03 | Vector graphics |
| D / 04 | Colour, opacity, spot colour |
| E / 05 | SVG path data |
| F / 06 | The fourteen standard fonts |
| G / 07 | Mixed page sizes and orientation |
| H / 08 | Text layout: alignment, columns, lists, decorations, links |
| I / 09 | Gradients and tiling patterns |
| J / 10 | JPEG and PNG |
| K / 11 | Embedded-font pipeline |
| L / 12 | Embedded TrueType, subset widths, ToUnicode |
| M / 13 | Annotations |
| N / 14 | Structure tree and marked content |
| O / 15 | Table layout |
| P / 16 | Tagged tables |

The development programs and the held-out programs cover the same families with different values. Both sets run. The README lists one row per family.

Present in the tree, and not in that claim until a program is added and matched:

- Interactive forms (`mixins/acroform.lua` and the form methods on the document).
- PDF encryption and security. `object.lua` has an encrypt hook. No example turns it on.
- Outlines (`outline.lua`, `mixins/outline.lua`).
- `registerFile`, `toBytes`, and `toBlob`. Those are 0.20 JavaScript entry points. Lua callers pass filesystem paths, or the byte strings the August port already accepts, and read the result from `pipe` / `finish`.

PDF/A and PDF/UA helpers stay in the tree. They are claimed only where family N or P already emits that output and the bytes match.

## The 0.20.2 rebase

0.20.0 is the break. 0.20.1 adds a Node ESM build. 0.20.2 fixes three bugs on top of 0.20.0. The Lua port is rebased onto the behavior of 0.20.2, which includes the 0.20.0 changes.

Changes that can move PDF bytes, and so have to be re-diffed:

- Standard fonts. Node no longer parses AFM at runtime. It loads generated metric modules. The browser build imports them from `pdfkit/standard-fonts/*` and registers them with `registerStdFonts()`. Our `font/standard.lua` still reads `font/data/*.afm` through an AFM parser. That path is replaced with Lua modules transcribed from the generated 0.20.2 metrics. Example F is the direct check. Any example that sets text in a standard font feels a width change.
- Annotation option keys are no longer uppercased automatically. `annotate` and its helpers no longer mutate the options table the caller passed. Example M.
- Font options persist when a page is added. Examples that cross a page boundary (B, G, and others).
- `indentAllLines` no longer reapplies the indent on every paragraph and every page break, and it stays applied across continued text. Example H.
- A hole in a sparse array is no longer skipped in a way that shifts later entries. Tables, examples O and P.
- `doc.text()` with `lineBreak: false` combined with underline, strike, link, or goTo no longer throws on a NaN width. Example H, if a case hits that combination.
- `doc.file()` can embed the same in-memory attachment twice under one name. Only matters if a copied program does that.
- Strings inside name trees are encrypted when encryption is on. Encryption is outside the claim. The code is updated so a later test is not starting from the 0.19.1 behavior.
- The PDF/A ICC profile is loaded when a PDF/A document needs it. The profile bytes stay in the tree.

These are also in 0.20.0, and they do not change the sixteen families unless a program already called them: AcroForm options restricted to the documented mappings, `addNamedEmbeddedFile` throwing when no ref is given, the date-field formatting fix, `Uint8Array` in place of Node `Buffer`, removal of `pdfkit/virtual-fs`.

The comparator is the judge. A family whose bytes already match 0.20.2 is left alone. A family that moved is fixed until it matches.

## License

Audit before the source commit, against the 0.20.2 tree and the resolved npm versions recorded in `vendor/PIN`. Known items:

| Path | License |
|---|---|
| PDFKit 0.20.2, and the Lua transcribed from it | MIT, Devon Govett, 2014. Our `LICENSE.md` stays MIT, Andrew Simard, 2026. `NOTICE` quotes Govett's notice |
| `fontkit`, `linebreak`, `png-js`, `js-md5`, `restructure`, and the other MIT libraries the August tree transcribes | MIT. `NOTICE` names each one we actually copied |
| `zlib/deflate.lua`, `zlib/trees.lua`, `flate.lua` | Transcription of zlib 1.3.1. The zlib license notice goes in `NOTICE` |
| Standard-font metric modules | Numbers derived from the Adobe AFM files PDFKit generates from. Adobe's copyright notice travels in `NOTICE`. The raw `.afm` files are not installed by the rock |
| `sRGB_IEC61966_2_1.icc` | The HP/Microsoft sRGB notice, quoted in `NOTICE`, if 0.20.2 still ships that profile |
| `vendor/pdfkit/` | Upstream licenses, unchanged. Excluded from the rock and from CLOC |
| Test fonts and images | Copied only when the license allows redistribution. Each one is named in `NOTICE` or in `test/assets/NOTICE` |

`GoodDog.ttf` is the one to check first. Several of the other test faces are OFL or Apache-2.0 (Roboto, Merriweather, Alegreya, Source Code Pro, DejaVu). A font we cannot redistribute is swapped for one we can, and that example's digest is whatever 0.20.2 produces with the replacement. The images get the same pass. Images that originate in the PDFKit repo can stay with PDFKit's MIT grant if that is how upstream ships them.

`vendor/pdfkit/` is the reading copy and the Node oracle. It is not in the rock.

## Repository layout

```
LICENSE.md
NOTICE
LUA-PDFKIT-PLAN.md
README.md
lua-pdfkit-1.0.0-1.rockspec
src/lua-pdfkit/                 the August tree, banner stripped
src/lua-pdfkit/init.lua         require "lua-pdfkit"
src/lua-pdfkit/font/            generated standard-font metrics as Lua modules
src/lua-pdfkit/zlib/            deflate, matching Node's zlib on the bytes
src/lua-pdfkit/fontkit/         subsetter and OpenType tables
src/lua-pdfkit/mixins/          vector, text, images, color, annotations, forms, outlines
vendor/pdfkit/                  PDFKit 0.20.2 source, not in the rock
vendor/PIN                      tag, commit, url, resolved dependency versions
test/compare.sh                 installs vendor deps if needed, diffs the sixteen families
test/comparepdf.sh              qpdf --check, then the three blankings, then cmp or digest
test/smoke.lua                  the Lua programs against stored digests, no Node
test/digests.txt                normalised SHA-256 against PDFKit 0.20.2
test/programs/                  Lua and Node pairs, both sets
test/assets/                    fonts and images the programs open
.gitignore
.github/workflows/main.yml
```

Vendor the 0.20.2 tag. Keep `lib/`, the generated standard-font modules, `package.json`, the lockfile, `LICENSE`, `CHANGELOG.md`, and the AFM-to-metrics tool if it is small and explains the numbers. Drop `node_modules/`, the website build, and browser bundles. `npm install` or `yarn` output under `vendor/pdfkit/node_modules/` is gitignored. The comparator requires that local tree, never a global install.

Record in `vendor/PIN`: tag `v0.20.2`, commit `8d72a71`, the GitHub URL, and the installed versions of `fontkit`, `linebreak`, `png-js`, `js-md5`, `@noble/hashes`, and `@noble/ciphers`. If one of those moved relative to the August tree, the matching Lua is re-read before the family that uses it is declared green.

## Rock

`lua-pdfkit-1.0.0-1.rockspec`, format 3.0, same shape as the lua-zint-svg rockspec. Package name `lua-pdfkit`, version `1.0.0-1`, source tag `v1.0.0`. The PDFKit pin is stated in the description. The rock version does not track PDFKit's version, because this rock does not claim the whole PDFKit API.

Module name `lua-pdfkit`. Homepage this GitHub repo. License `MIT`. Maintainer Andrew Simard. Dependency `lua >= 5.5`. `build.modules` lists every `src/lua-pdfkit/**/*.lua`, including metric modules and the ICC module. No native dependency, no other rock dependency, no installed script.

`luarocks make` in this repo is how we check the rock. `luarocks upload` is how other people install it.

## README, tests, and the public claim

The README states, in this order:

- Pure Lua, no Node at runtime. `require "lua-pdfkit"`, the `finish` rename, and one short example.
- Credit and links: Devon Govett, https://github.com/foliojs/pdfkit, https://pdfkit.org/, the 0.20.2 pin. Independent port.
- A table: the sixteen families, each marked `matches 0.20.2`. The match is defined in one sentence: byte-identical after the three blankings above.
- A short list of what is in the tree and not in that claim: forms, encryption, outlines, `registerFile` / `toBytes` / `toBlob`.
- Font, zlib, and ICC notices, one line each, pointing at `NOTICE`.
- The CLOC badge: `https://github.com/500Foods/lua-pdfkit/actions/workflows/main.yml/badge.svg`.

The workflow drops `--force-lang=Pascal,inc` and excludes `vendor`, so the count is this port.

Tests come in two layers.

- `test/smoke.lua` runs the Lua programs and checks `test/digests.txt`. Lua alone. The blanking used for those digests is the same three substitutions `comparepdf.sh` performs, so a digest from either path agrees. This is what a LuaRocks user can execute.
- `test/compare.sh` installs the vendored 0.20.2 dependencies if `node_modules` is absent, runs the Node programs and the Lua programs, and diffs them with `comparepdf.sh`. This is the byte-identical claim. It is allowed to need Node, npm or yarn, and `qpdf`.

`.gitignore` replaces the Delphi template. Ignore `node_modules/`, `vendor/pdfkit/node_modules/`, LuaRocks output (`*.rock`, `lua_modules/`, `.luarocks/`), generated PDFs under `test/out/`, and editor or OS noise. Track `vendor/pdfkit` source, `src/`, and `test/`. The Delphi rules go away, including `*.dcu`, `*.bpl`, `__history/`, `TMSWeb/`, `*.identcache`, `Win32/`, `modules/`, `*.cfg`, and `*.map`.

## Order of work

1. This file. Then `NOTICE` (filled in as the audit finishes), `.gitignore`, the README, and the CLOC workflow change. `LICENSE.md` is already MIT.
2. Vendor PDFKit 0.20.2, write `vendor/PIN`, install its runtime dependencies into the gitignored `node_modules`, confirm the package version is 0.20.2.
3. License audit of the generated font metrics, the ICC profile, the transcribed libraries, and the test fonts and images. Swap anything we cannot ship. Record the notices.
4. Copy the Lua tree into `src/lua-pdfkit/`. Strip the Harbor banner from every file. Do not copy `tests/digests.txt` as the claim. Adapt `comparepdf.sh` without the banner.
5. Replace runtime AFM parsing with Lua modules of the 0.20.2 generated metrics. Point the ICC load at a Lua module.
6. Adapt the thirty-two programs (sixteen families, two sets) onto this repo's paths. Re-run Node 0.20.2 against Lua. Fix diffs until every family matches. Write `test/digests.txt` from that run. `test/smoke.lua` reads it.
7. `luarocks make`, then `lua -e 'local P=require"lua-pdfkit"; print(type(P.new))'` on Lua 5.5.1. That prints `function`.
8. Upload if a LuaRocks API key is present. Otherwise stop with the rockspec ready.

## Done

- Vendored PDFKit reports version 0.20.2, and `vendor/pdfkit/node_modules/` is untracked.
- All sixteen families match that build after the three blankings, both the development programs and the held-out programs.
- `test/smoke.lua` passes without Node.
- `luarocks make` succeeds. `require "lua-pdfkit"` returns a table whose `new` is a function.
- `LICENSE.md` is MIT. `NOTICE` names PDFKit, the transcribed libraries, zlib, the Adobe font metrics, and the ICC profile.
- No Harbor banner remains in the committed source.
- The README's claim is the sixteen families, and it names forms, encryption, and outlines as present and not yet compared.

## Backlog

Waiting, and not part of the first rock:

- Forms, encryption, and outlines brought under `comparepdf.sh` with programs of their own. The code is already in the tree. The claim grows when the bytes match, one family at a time.
- A Lua equivalent of `registerFile` if a caller needs a path that is not on disk. Until then, pass a path or the bytes.
- The next PDFKit pin, when that round starts. Same rule: pin the latest release, rerun the comparator, fix what moved.
