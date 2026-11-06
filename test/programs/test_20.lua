-- test_20 -- embedded TrueType, Arabic joining forms
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
        layout = "portrait",
    })

    local font = ROOT .. "/test/assets/fonts/DejaVuSans.ttf"
    doc:font(font, 24)
    doc:text("السلام", 72, 72)
    doc:fontSize(18)
    doc:text("مرحبا بالعالم", 72, 120)
    doc:fontSize(14)
    doc:text("كتاب 2026", 72, 160)
    doc:text("بسم الله الرحمن الرحيم", 72, 200, { width = 280 })

    local line = "اللغة العربية"
    local w = doc:widthOfString(line)
    doc:text(line, 420 - w, 260)

    doc:addPage()
    doc:font(font, 12)
    doc:text("سطر طويل بما يكفي ليلتف مرتين على عرض العمود، مع أرقام ١٢٣ وحروف لاتينية PDF.", 72, 72, {
        width = 340,
        align = "right",
        lineGap = 3,
    })

    return doc
end

local outPath = assert(arg[1], "usage: lua program.lua <out.pdf>")
local doc = GeneratePDF()
local out = assert(io.open(outPath, "wb"))
doc:pipe(out)
doc:finish()
out:close()
