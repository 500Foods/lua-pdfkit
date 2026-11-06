-- test_22 -- WOFF1 unwrap: the file is zlib-wrapped TrueType, the PDF embeds a subset
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
        size = "LETTER",
        margin = 72,
    })

    local font = ROOT .. "/test/assets/fonts/SourceCodePro-Regular.woff"
    doc:font(font, 18)
    doc:text("Wrapped for the web", 72, 72)

    doc:fontSize(12)
    doc:text("WOFF is a transport. This page is a normal TrueType subset: tables inflated, then glyf copied for the glyphs below.", 72, 110, {
        width = 420,
        align = "justify",
        lineGap = 2,
    })

    doc:fontSize(10)
    doc:text("0123456789 abcdefghijklmnopqrstuvwxyz", 72, 180, {
        characterSpacing = 0.6,
    })
    doc:text("ABCDEFGHIJKLMNOPQRSTUVWXYZ", 72, 200)

    doc:addPage()
    doc:font(font, 14)
    doc:text("Still the same face", 72, 80, { align = "right", width = 400 })

    return doc
end

local outPath = assert(arg[1], "usage: lua program.lua <out.pdf>")
local doc = GeneratePDF()
local out = assert(io.open(outPath, "wb"))
doc:pipe(out)
doc:finish()
out:close()
