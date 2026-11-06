-- Held-out example G. Not shipped with the task.
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

    -- Held-out counterpart to sample test_07: one document whose pages differ in
    -- size and orientation, with real content on each.

    -- 1. A5 portrait, opened as Letter and switched on the first added page, so
    -- the first page here keeps the document default.
    doc:font("Helvetica-Bold", 18):text("1. Letter, the default", 60, 60)
    doc:font("Helvetica", 10)
       :text("Whatever the document was constructed with.", 60, 86)
    doc:ellipse(200, 160, 80, 40):fill("#556677")

    -- 2. A5, a good deal smaller than Letter in both directions.
    doc:addPage({ size = "A5", layout = "portrait" })
    doc:font("Times-Bold", 16):fillColor("black"):text("2. A5 portrait", 50, 50)
    doc:font("Times-Roman", 10):text(
        "A5 is roughly 420 by 595 points, so a paragraph set across a two " ..
        "hundred and fifty point column has to wrap rather more often than it " ..
        "would on Letter.", 50, 74, { width = 250, align = "left" })

    -- 3. Tabloid on its side: the widest sheet in the document by a wide margin.
    doc:addPage({ size = "TABLOID", layout = "landscape" })
    doc:font("Helvetica-Bold", 22):text("3. Tabloid landscape", 72, 72)
    doc:save():lineWidth(4):strokeColor("#227744")
    doc:moveTo(72, 120):lineTo(1100, 120):stroke()
    doc:restore()
    doc:font("Courier", 10):fillColor("#227744")
       :text("1224 x 792 points, the long way round.", 72, 136)

    -- 4. A 5x7 card at 72dpi with margins of its own.
    doc:addPage({
        size = { 360, 504 },
        layout = "portrait",
        margins = { top = 24, bottom = 24, left = 24, right = 24 },
    })
    doc:font("Helvetica-Bold", 13):fillColor("black"):text("4. A 5x7 card", 24, 24)
    doc:roundedRect(24, 48, 180, 60, 10):lineWidth(1.5):strokeColor("#884422"):stroke()
    doc:path("M 30 130 L 150 130 L 90 220 Z"):fill("#bb7744")

    -- 5. A3 portrait, the tallest sheet here, back on the default margins.
    doc:addPage({ size = "A3", layout = "portrait" })
    doc:font("Helvetica-Bold", 20):fillColor("black"):text("5. A3 portrait", 72, 72)
    doc:font("Helvetica", 11):text(
        "The metric sheet two sizes up, justified across four hundred points so " ..
        "that the line breaker has to distribute the slack itself.",
        72, 100, { width = 400, align = "justify" })
    doc:rect(72, 180, 300, 90):fill("#334455")

    -- 6. Back to Letter landscape to close.
    doc:addPage({ size = "LETTER", layout = "landscape" })
    doc:font("Helvetica-Bold", 18):fillColor("black"):text("6. Letter landscape", 72, 72)
    doc:font("Helvetica", 10)
       :text("Six pages, six distinct page boxes.", 72, 98)
    local box = doc.page.width - doc.page.margins.left - doc.page.margins.right
    doc:text("Ranged right across a landscape measure, which is wide enough " ..
        "that the words fall into different lines than they would on a portrait " ..
        "page, and each of those lines is offset by its own width.",
        72, 124, { width = box, align = "right" })
    doc:circle(400, 300, 60):lineWidth(2):strokeColor("black"):stroke()

    return doc
end

local outPath = assert(arg[1], "usage: lua example.lua <out.pdf>")

local doc = GeneratePDF()
local out = assert(io.open(outPath, "wb"))

doc:pipe(out)
doc:finish()
out:close()
