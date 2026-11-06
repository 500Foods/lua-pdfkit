-- test_06 -- the fourteen standard fonts, their AFM metrics and their kerning
--
-- The Lua mirror of pdfkit/test_06.js. Everything inside GeneratePDF() is
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

    -- The standard 14 fonts: every one of them, by name, plus the AFM metrics and
    -- kerning that come with them. Nothing here is embedded -- these fonts live in
    -- the viewer, so the PDF carries only widths and a name.
    local NAMES = {
        "Courier", "Courier-Bold", "Courier-Oblique", "Courier-BoldOblique",
        "Helvetica", "Helvetica-Bold", "Helvetica-Oblique", "Helvetica-BoldOblique",
        "Times-Roman", "Times-Bold", "Times-Italic", "Times-BoldItalic",
        "Symbol", "ZapfDingbats",
    }

    local y = 40
    for _, name in ipairs(NAMES) do
        doc:font(name, 13)
        doc:text(name .. "  Hamburgefonstiv 0123456789", 40, y)
        y = y + 22
    end

    -- The PostScript aliases PDFKit accepts alongside the canonical names.
    doc:font("Times-Roman", 12)
    doc:text("aliases", 40, 360)
    doc:font("Courier-BoldOblique", 12)
    doc:text("Courier-BoldOblique", 120, 360)

    -- Kerning. Times has a large kern table and these pairs are all in it, so the
    -- emitted show-text array has to be split at every one of them.
    doc:font("Times-Roman", 20)
    doc:text("AWAY Yo To Wa P, V. LT", 40, 390)
    doc:font("Helvetica", 20)
    doc:text("AWAY Yo To Wa P, V. LT", 40, 420)

    -- The same string measured, then underscored to the measured width, so a wrong
    -- width shows up as a visible mismatch rather than only in the metrics.
    doc:font("Times-Bold", 16)
    local s = "measured against its own metrics"
    local w = doc:widthOfString(s)
    doc:text(s, 40, 460)
    doc:rect(40, 480, w, 2):fill("black")

    -- WinAnsi high characters, which is where the standard fonts' encoding table
    -- stops being ASCII.
    doc:font("Helvetica", 12)
    doc:text("\u{00C0}\u{00C7}\u{00C9}\u{00D1}\u{00D6}\u{00DC} " ..
        "\u{00E0}\u{00E1}\u{00E7}\u{00E9}\u{00ED}\u{00F1}\u{00F6}\u{00FC} " ..
        "\u{2018}\u{2019}\u{201C}\u{201D}\u{2013}\u{2014}\u{2020}\u{2021}\u{2026}",
        40, 500)

    -- Symbol and ZapfDingbats have encodings of their own rather than WinAnsi.
    doc:font("Symbol", 16)
    doc:text("abgdez QWFY \u{2211}\u{221A}\u{222B}", 40, 530)
    doc:font("ZapfDingbats", 16)
    doc:text("abcdefgh 34567", 40, 560)

    -- Registered under a name of the caller's choosing.
    doc:registerFont("Body", "Times-Italic")
    doc:font("Body", 14)
    doc:text("registered alias for a standard font", 40, 590)

    -- Switching back and forth inside one wrapped paragraph, so the line breaker
    -- has to ask two different fonts for widths.
    doc:font("Helvetica", 11)
    doc:text("A paragraph long enough to wrap several times, laid out in " ..
        "Helvetica at eleven points across a measured column so that the line " ..
        "breaker has real work to do here.", 40, 620, { width = 240 })
    doc:font("Times-Roman", 11)
    doc:text("The same words again in Times, which has different widths for " ..
        "every glyph, so the breaks land in different places.", 300, 620,
        { width = 240 })

    -- fontSize independent of font, and the size sticking across a font switch.
    doc:fontSize(9)
    doc:font("Courier")
    doc:text("nine point courier, size set separately", 40, 720)

    return doc
end

-- --- plumbing ---------------------------------------------------------------

-- test_06.lua -> test_06_lua.pdf; the JS side writes test_06_js.pdf, so the two
-- never collide if they end up in the same folder.
local outPath = assert(arg[1], "usage: lua " .. (arg[0] or "program.lua") .. " <out.pdf>")

local doc = GeneratePDF()
local out = assert(io.open(outPath, "wb"))

doc:pipe(out)
doc:finish() -- PDFKit's doc.end(); `end` is a reserved word in Lua
out:close()

print(outPath)
