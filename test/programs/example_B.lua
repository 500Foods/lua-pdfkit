-- Held-out example B. Not shipped with the task.
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
        bufferPages = true,
        pdfVersion = "1.7ext3",
    })

    -- Held-out counterpart to sample test_02: page geometry, revisiting, info dict.
    doc.info.Title = "Held out"
    doc.info.Author = "verifier"
    doc.info.Subject = "geometry"
    doc.info.Keywords = "x,y,z"
    doc:text("first", 40, 40)
    doc:addPage({size="LEGAL", layout="portrait", margin=36})
    doc:text("second", 40, 40)
    doc:addPage({size={400,250}, margins={top=15,bottom=25,left=35,right=45}})
    doc:text("third", 40, 40)
    doc:addPage({size="A4", layout="landscape"})
    doc:text("fourth", 40, 40)
    doc:switchToPage(1)
    doc:text("back on 2", 40, 90)
    doc:switchToPage(0)
    doc:text("back on 1", 40, 90)
    local r = doc:bufferedPageRange()
    doc:text(("range %d %d"):format(r.start, r.count), 40, 140)

    return doc
end

local outPath = assert(arg[1], "usage: lua example.lua <out.pdf>")

local doc = GeneratePDF()
local out = assert(io.open(outPath, "wb"))

doc:pipe(out)
doc:finish()
out:close()
