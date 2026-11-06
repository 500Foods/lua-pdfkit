-- test_19 -- embedded TrueType, Hebrew: RTL glyph order and mark positioning
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

    local font = ROOT .. "/test/assets/fonts/DejaVuSans.ttf"
    doc:font(font, 24)
    doc:text("שלום", 72, 72)
    doc:fontSize(18)
    doc:text("שָׁלוֹם", 72, 110)
    doc:fontSize(14)
    doc:text("עברית 123", 72, 150)
    doc:text("אבגדהוזחטיכלמנסעפצקרשת", 72, 180, { width = 240 })

    local line = "שלום עולם"
    local w = doc:widthOfString(line)
    doc:text(line, 400 - w, 230)

    doc:addPage()
    doc:font(font, 12)
    doc:text("עברית על העמוד השני, עם מספרים 2026 ומילה ארוכה יותר.", 72, 72, {
        width = 360,
        align = "right",
    })

    return doc
end

local outPath = assert(arg[1], "usage: lua program.lua <out.pdf>")
local doc = GeneratePDF()
local out = assert(io.open(outPath, "wb"))
doc:pipe(out)
doc:finish()
out:close()
