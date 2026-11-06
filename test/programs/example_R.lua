-- Held-out example R. Outlines, different pages and destinations from test_18.
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
        size = { 400, 600 },
        margin = 30,
    })

    doc:fontSize(14)
    doc:text("alpha", 30, 40)
    doc:addPage({ size = { 500, 700 }, margin = 20 })
    doc:text("beta", 20, 30)
    doc:addPage()
    doc:text("gamma", 20, 30)

    local outline = doc.outline
    local book = outline:addItem("Book", { expanded = true })
    local part = book:addItem("Part I", { expanded = true, pageNumber = 0 })
    part:addItem("Opening", { fit = false, top = 40, left = 10, zoom = 2 })
    part:addItem("Middle", { pageNumber = 1, fit = false, top = 80, left = 0, zoom = 1 })
    book:addItem("Part II", { pageNumber = 2 })

    outline:addItem("Wide page", {
        pageNumber = 1,
        fit = true,
        expanded = false,
    })

    local marks = outline:addItem("Marks: é — #1")
    marks:addItem("Back to alpha", { pageNumber = 0 })
    local deep = marks:addItem("Deep", { expanded = true })
    deep:addItem("Deeper", { pageNumber = 2, fit = false, top = 12, left = 8, zoom = 0.5 })

    return doc
end

local outPath = assert(arg[1], "usage: lua example.lua <out.pdf>")
local doc = GeneratePDF()
local out = assert(io.open(outPath, "wb"))
doc:pipe(out)
doc:finish()
out:close()
