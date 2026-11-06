-- Held-out example U. CFF font, different copy and geometry from test_21.
local ROOT do
    local src = debug.getinfo(1, "S").source
    if src:sub(1, 1) == "@" then src = src:sub(2) end
    local dir = src:match("^(.*)/") or "."
    ROOT = dir .. "/../.."
end
package.path = ROOT .. "/src/?.lua;" .. ROOT .. "/src/?/init.lua;" .. package.path

local PDFDocument = require("pdfkit")

local function GeneratePDF()
    local doc = PDFDocument.new({
        size = "A4",
        margin = 48,
    })

    local font = ROOT .. "/test/assets/fonts/SourceCodePro-Regular.otf"
    doc:font(font, 22)
    doc:text("Release notes", 48, 56)

    doc:fontSize(12)
    doc:text("Version 1.0.0 embeds this face as a CIDFontType0. The subset keeps only the glyphs this page uses.", 48, 100, {
        width = 480,
        align = "left",
        lineGap = 5,
    })

    doc:fontSize(10)
    doc:text("Item 1   build the charstring index", 48, 170)
    doc:text("Item 2   stub unused subroutines", 48, 186)
    doc:text("Item 3   write ROS Adobe-Identity-0", 48, 202)

    doc:moveDown(2)
    doc:fontSize(14)
    doc:text("Centered colophon", { align = "center", characterSpacing = 1 })

    doc:addPage({ size = "A4", margin = 48 })
    doc:font(font, 11)
    doc:text("Second page, right aligned, with digits 2026 and a long line that has to wrap inside a narrow measure so the line breaker runs.", 48, 80, {
        width = 240,
        align = "right",
    })

    return doc
end

local outPath = assert(arg[1], "usage: lua example.lua <out.pdf>")
local doc = GeneratePDF()
local out = assert(io.open(outPath, "wb"))
doc:pipe(out)
doc:finish()
out:close()
