-- Held-out example S. Hebrew, different copy and geometry from test_19.
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
        size = "A4",
        margin = 50,
    })

    local font = ROOT .. "/test/assets/fonts/DejaVuSans.ttf"
    doc:font(font, 28)
    doc:text("ברוכים הבאים", 50, 60)

    doc:fontSize(16)
    doc:text("ספר בראשית, פרק א.", 50, 120, { width = 300, align = "center" })

    doc:fontSize(11)
    doc:text("בְּרֵאשִׁית בָּרָא אֱלֹהִים אֵת הַשָּׁמַיִם וְאֵת הָאָרֶץ.", 50, 180, {
        width = 420,
        align = "justify",
        lineGap = 4,
    })

    doc:fontSize(13)
    doc:text("שורה עם אנגלית Hello וספרות 42.", 50, 260)

    doc:addPage({ size = "A4", margin = 50 })
    doc:font(font, 20)
    doc:text("עמוד ב׳", 50, 50)
    doc:fontSize(14)
    doc:text("תל אביב, ירושלים, חיפה", 50, 100, { characterSpacing = 1.5 })

    return doc
end

local outPath = assert(arg[1], "usage: lua example.lua <out.pdf>")
local doc = GeneratePDF()
local out = assert(io.open(outPath, "wb"))
doc:pipe(out)
doc:finish()
out:close()
