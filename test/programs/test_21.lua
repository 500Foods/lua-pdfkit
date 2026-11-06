-- test_21 -- embedded CFF (.otf): subset, widths, wrapping
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
        size = "LETTER",
        layout = "portrait",
    })

    local font = ROOT .. "/test/assets/fonts/SourceCodePro-Regular.otf"
    doc:font(font, 20)
    doc:text("Source Code Pro", 72, 64)

    doc:fontSize(11)
    doc:text("The quick brown fox jumps over the lazy dog. 0123456789.", 72, 100, {
        width = 360,
        align = "justify",
        lineGap = 3,
    })

    doc:fontSize(9)
    local sample = "if (n < 1240) return 107; else return 1131;"
    doc:text(sample, 72, 160, { characterSpacing = 0.4 })
    local w = doc:widthOfString(sample)
    doc:text("width " .. string.format("%.2f", w), 72, 180)

    doc:fontSize(13)
    doc:text("Punctuation: ([{}]) <> \"quotes\" 'apostrophe' -- em-dash? No.", 72, 210, {
        width = 400,
    })

    doc:addPage()
    doc:font(font, 16)
    doc:text("Page two", 72, 72, { align = "center", width = 468 })
    doc:fontSize(10)
    doc:text("ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz", 72, 120, {
        width = 300,
        align = "left",
        wordSpacing = 1.5,
    })
    doc:text("Symbols: @#$%^&*_+-=/~`|\\", 72, 180)

    return doc
end

local outPath = assert(arg[1], "usage: lua program.lua <out.pdf>")
local doc = GeneratePDF()
local out = assert(io.open(outPath, "wb"))
doc:pipe(out)
doc:finish()
out:close()
