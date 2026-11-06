-- Held-out example T. Arabic, different copy and geometry from test_20.
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

    local font = ROOT .. "/test/assets/fonts/DejaVuSans.ttf"
    doc:font(font, 26)
    doc:text("عنوان الصفحة", 48, 56)

    doc:fontSize(15)
    doc:text("هذا نص تجريبي لاختبار الوصل بين الحروف.", 48, 110, {
        width = 400,
        align = "center",
    })

    doc:fontSize(12)
    doc:text("القاهرة، دمشق، بغداد، والرباط في سطر واحد.", 48, 180, {
        width = 460,
        align = "justify",
    })

    doc:fontSize(13)
    doc:text("كلمة مع English في الوسط ثم ٤٢.", 48, 250)

    doc:addPage({ size = "A4", margin = 48 })
    doc:font(font, 18)
    doc:text("الصفحة الثانية", 48, 48)
    doc:fontSize(11)
    doc:text("لا تنسَ التشكيل: كَتَبَ الكَاتِبُ كِتاباً.", 48, 100, {
        characterSpacing = 0.4,
    })

    return doc
end

local outPath = assert(arg[1], "usage: lua example.lua <out.pdf>")
local doc = GeneratePDF()
local out = assert(io.open(outPath, "wb"))
doc:pipe(out)
doc:finish()
out:close()
