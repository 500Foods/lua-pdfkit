-- Held-out example V. WOFF1, different copy and geometry from test_22.
local ROOT do
    local src = debug.getinfo(1, "S").source
    if src:sub(1, 1) == "@" then src = src:sub(2) end
    local dir = src:match("^(.*)/") or "."
    ROOT = dir .. "/../.."
end
package.path = ROOT .. "/src/?.lua;" .. ROOT .. "/src/?/init.lua;" .. package.path

local PDFDocument = require("lua-pdfkit")

local function GeneratePDF()
    local doc = PDFDocument.new({
        size = "A5",
        layout = "landscape",
        margin = 36,
    })

    local font = ROOT .. "/test/assets/fonts/SourceCodePro-Regular.woff"
    doc:font(font, 24)
    doc:text("A5 landscape", 36, 40)

    doc:fontSize(11)
    doc:text("Pack my box with five dozen liquor jugs. The font arrived compressed and leaves as a subset.", 36, 90, {
        width = 480,
        align = "center",
        lineGap = 4,
    })

    doc:fontSize(9)
    doc:text("()[]{}<>+-*/= 3.14159", 36, 160)

    return doc
end

local outPath = assert(arg[1], "usage: lua example.lua <out.pdf>")
local doc = GeneratePDF()
local out = assert(io.open(outPath, "wb"))
doc:pipe(out)
doc:finish()
out:close()
