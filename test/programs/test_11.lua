-- test_11 -- an embedded TrueType font with no shaping tables: subsetting, widths, ToUnicode
--
-- The Lua mirror of pdfkit/test_11.js. Everything inside GeneratePDF() is
-- pdfkit API surface, and each call corresponds one-to-one with a PDFKit
-- call in the JS original. Everything outside it is plumbing -- module
-- resolution, file handling, output naming -- and is expected to differ
-- between the two implementations.

-- Resolve pdfkit no matter which directory the script is run from.
local ROOT do
    local src = debug.getinfo(1, "S").source
    if src:sub(1, 1) == "@" then src = src:sub(2) end
    local dir = src:match("^(.*)/") or "."
    ROOT = dir .. "/../.."
end
package.path = ROOT .. "/src/?.lua;" .. ROOT .. "/src/?/init.lua;" .. package.path

local PDFDocument = require("pdfkit")

-- --- pdfkit API surface -------------------------------------------------

local function GeneratePDF()
    local doc = PDFDocument.new({
        size = "LETTER",
        layout = "portrait",
    })

    -- The embedded-font pipeline on its own: Droid Sans Mono is the one font in the corpus
    -- with no GSUB, GPOS, kern or morx, so nothing here depends on shaping.
    local F = ROOT .. "/test/assets/fonts/"

    doc:font(F .. "DroidSansMono.ttf", 24)
    doc:text("Hamburgefonstiv 0123456789", 50, 50)

    doc:font(F .. "DroidSansMono.ttf", 18)
    doc:text("ÀÇÉÑÖÜ àáçéíñöü", 50, 100)

    doc:font(F .. "DroidSansMono.ttf", 14)
    doc:text("the quick brown fox jumps over the lazy dog", 50, 140, {
        wordSpacing = 6,
        characterSpacing = 0.5,
    })

    doc:font(F .. "DroidSansMono.ttf", 11)
    doc:text(
        "reused, and wrapped across a measured width so the line breaker has to "
            .. "ask this font how wide each word is many times over",
        50, 180, { width = 300 }
    )

    doc:text(
        "Justification asks for the width of the stripped line and of a single "
            .. "space, so both paths through widthOfString run here.",
        50, 240, { width = 300, align = "justify" }
    )

    local fh = assert(io.open(F .. "DroidSansMono.ttf", "rb"))
    local bytes = fh:read("a")
    fh:close()
    doc:font(bytes, 12)
    doc:text("bytes not a path", 50, 320)

    doc:registerFont("Body", F .. "DroidSansMono.ttf")
    doc:font("Body", 13)
    doc:text("registered under a name of its own", 50, 350)

    doc:font("Helvetica", 12)
    doc:text("and a standard font alongside", 50, 380)

    doc:font(F .. "DroidSansMono.ttf", 9)
    local s = {}
    for cp = 0x21, 0x17F do s[#s + 1] = utf8.char(cp) end
    doc:text(table.concat(s), 50, 450, { width = 500 })

    doc:font(F .. "DroidSansMono.ttf", 20)
    local w = doc:widthOfString("sample text, measured")
    doc:rect(50, 600, w, 4):fill("black")
    doc:text("sample text, measured", 50, 610)

    doc:addPage()
    doc:font(F .. "DroidSansMono.ttf", 20)
    doc:text("second page, same font", 50, 50)

    return doc
end

-- --- plumbing ---------------------------------------------------------------

-- test_11.lua -> test_11_lua.pdf; the JS side writes test_11_js.pdf, so the two
-- never collide if they end up in the same folder.
local outPath = assert(arg[1], "usage: lua " .. (arg[0] or "program.lua") .. " <out.pdf>")

local doc = GeneratePDF()
local out = assert(io.open(outPath, "wb"))

doc:pipe(out)
doc:finish() -- PDFKit's doc.end(); `end` is a reserved word in Lua
out:close()

print(outPath)
