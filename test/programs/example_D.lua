-- Held-out example D. Not shipped with the task.
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

    -- Held-out counterpart to sample test_04: colour notation, opacity, spot colour.
    doc:fillColor("teal"):rect(20, 20, 60, 40):fill()
    doc:fillColor("#1188cc"):rect(100, 20, 60, 40):fill()
    doc:fillColor("#3c9"):rect(180, 20, 60, 40):fill()
    doc:fillColor({12, 200, 90}):rect(260, 20, 60, 40):fill()
    doc:fillColor({40, 0, 60, 20}):rect(340, 20, 60, 40):fill()
    doc:strokeColor("crimson"):lineWidth(3):rect(20, 90, 60, 40):stroke()
    doc:fillOpacity(0.35):rect(100, 90, 60, 40):fill("orange")
    doc:strokeOpacity(0.6):rect(180, 90, 60, 40):stroke()
    doc:opacity(0.45):rect(260, 90, 60, 40):fill("#204080")
    doc:fillColor("darkslategray", 0.8):rect(340, 90, 60, 40):fill()
    doc:fillOpacity(1):strokeOpacity(1)
    doc:fillColor("gold"):rect(20, 160, 60, 40):fill()
    doc:fillColor("rebeccapurple"):rect(100, 160, 60, 40):fill()
    doc:fillAndStroke("aquamarine", "maroon")
    doc:addSpotColor("PANTONE-032", 0, 90, 86, 0)
    doc:fillColor("PANTONE-032"):rect(20, 230, 70, 70):fill()
    doc:strokeColor("PANTONE-032", 0.4):rect(110, 230, 70, 70):stroke()
    doc:fillOpacity(0.35):rect(220, 230, 70, 70):fill("teal")
    doc:fillOpacity(0.35):rect(310, 230, 70, 70):fill("teal")

    return doc
end

local outPath = assert(arg[1], "usage: lua example.lua <out.pdf>")

local doc = GeneratePDF()
local out = assert(io.open(outPath, "wb"))

doc:pipe(out)
doc:finish()
out:close()
