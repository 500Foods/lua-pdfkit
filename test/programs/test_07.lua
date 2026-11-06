-- test_07 -- one document whose pages differ in size and orientation, with content on each
--
-- The Lua mirror of pdfkit/test_07.js. Everything inside GeneratePDF() is
-- lua-pdfkit API surface, and each call corresponds one-to-one with a PDFKit
-- call in the JS original. Everything outside it is plumbing -- module
-- resolution, file handling, output naming -- and is expected to differ
-- between the two implementations.

-- Resolve lua-pdfkit no matter which directory the script is run from.
local ROOT do
    local src = debug.getinfo(1, "S").source
    if src:sub(1, 1) == "@" then src = src:sub(2) end
    local dir = src:match("^(.*)/") or "."
    ROOT = dir .. "/../.."
end
package.path = ROOT .. "/src/?.lua;" .. ROOT .. "/src/?/init.lua;" .. package.path

local PDFDocument = require("lua-pdfkit")

-- --- lua-pdfkit API surface -------------------------------------------------

local function GeneratePDF()
    local doc = PDFDocument.new({
        size = "LETTER",
        layout = "portrait",
    })

    -- Pages of different sizes and orientations in one document, with real content
    -- on each, so the page box and the content stream have to agree page by page.

    -- 1. US Letter, portrait -- whatever the document was opened with.
    doc:font("Helvetica-Bold", 20):text("1. Letter portrait", 72, 72)
    doc:font("Helvetica", 11)
       :text("612 x 792 points, the size this document was opened with.", 72, 100)
    doc:rect(72, 128, 200, 56):fill("#4477aa")
    doc:fillColor("black"):text("a filled rectangle", 72, 196)

    -- 2. The same sheet turned on its side, so width and height swap.
    doc:addPage({ size = "LETTER", layout = "landscape" })
    doc:font("Helvetica-Bold", 20):text("2. Letter landscape", 72, 72)
    doc:font("Helvetica", 11)
       :text("792 x 612 -- the same paper, rotated.", 72, 100)
    doc:save():lineWidth(3):strokeColor("#aa4444")
    doc:moveTo(72, 136):lineTo(600, 136):stroke()
    doc:restore()
    doc:circle(180, 220, 48):fill("#44aa77")

    -- 3. US Legal: 216 points taller than Letter, exactly as wide. The paragraph
    -- wraps in a measured column, so the breaker has to be working off this page.
    doc:addPage({ size = "LEGAL", layout = "portrait" })
    doc:font("Times-Bold", 20):text("3. Legal portrait", 72, 72)
    doc:font("Times-Roman", 11):text(
        "Legal is 612 by 1008 points, which makes this page taller than the first " ..
        "one while staying exactly as wide. This paragraph is justified inside a " ..
        "three hundred point column to give the line breaker something to do.",
        72, 100, { width = 300, align = "justify" })

    -- 4. A 4x6 card at 72dpi, with margins of its own rather than the default 72.
    doc:addPage({
        size = { 288, 432 },
        layout = "portrait",
        margins = { top = 18, bottom = 18, left = 18, right = 18 },
    })
    doc:font("Helvetica-Bold", 14):text("4. A 4x6 card", 18, 18)
    doc:font("Helvetica", 9):text("288 x 432 points, 18pt margins.", 18, 40)
    doc:path("M 20 70 L 130 70 L 75 150 Z"):fill("#ddaa33")
    doc:fillColor("black"):font("Courier", 8)
       :text("custom size, custom margins", 18, 168)

    -- 5. A4 landscape, back on the default margins.
    doc:addPage({ size = "A4", layout = "landscape" })
    doc:font("Helvetica-Bold", 20):text("5. A4 landscape", 72, 72)
    doc:font("Helvetica", 11):text("The metric sheet, on its side.", 72, 100)
    doc:roundedRect(72, 128, 240, 68, 12):lineWidth(2):strokeColor("#333366"):stroke()
    doc:fillColor("#333366"):text("rounded, stroked, not filled", 84, 154)

    -- 6. Back to portrait Letter to close, and a look at the page count.
    doc:addPage({ size = "LETTER", layout = "portrait" })
    doc:font("Helvetica-Bold", 20):fillColor("black"):text("6. Letter again", 72, 72)
    doc:font("Helvetica", 11)
       :text("Six pages, five distinct page boxes.", 72, 100)

    -- Ranged right against the far edge of the margin box. Every line has to be
    -- pushed out by its own measured width, so the offsets differ line by line.
    local box = doc.page.width - doc.page.margins.left - doc.page.margins.right
    doc:text("This block is set ranged right, hard against the right margin, " ..
        "with enough words in it that the wrapper has to measure and offset " ..
        "several lines rather than only one.", 72, 130, { width = box, align = "right" })

    return doc
end

-- --- plumbing ---------------------------------------------------------------

-- test_07.lua -> test_07_lua.pdf; the JS side writes test_07_js.pdf, so the two
-- never collide if they end up in the same folder.
local outPath = assert(arg[1], "usage: lua " .. (arg[0] or "program.lua") .. " <out.pdf>")

local doc = GeneratePDF()
local out = assert(io.open(outPath, "wb"))

doc:pipe(out)
doc:finish() -- PDFKit's doc.end(); `end` is a reserved word in Lua
out:close()

print(outPath)
