-- Held-out example E. Not shipped with the task.
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

    -- Held-out counterpart to sample test_05: SVG path data, absolute and relative.
    doc:path('M 20 20 L 120 20 L 120 90 Z'):stroke();
    doc:path('m 20 110 l 100 0 l 0 70 z'):stroke();
    doc:path('M 20 220 C 50 190 90 250 120 220 S 190 190 220 220'):stroke();
    doc:path('M 20 290 Q 70 250 120 290 T 220 290'):stroke();
    doc:path('M 20 340 H 220 V 390 h -120 v 30'):stroke();
    doc:path('M 120 440 A 60 35 0 0 1 220 440 a 60 35 0 1 0 -100 0'):stroke();
    doc:path('M 270 440 A 45 25 30 1 1 370 470'):stroke();
    doc:path('M15,540L65,540 65,590 15,590Z'):fill();
    doc:path('M 420 90 A 0 25 0 0 1 470 90'):stroke();
    doc:path('M 420 190 A 35 35 0 0 1 420 190'):stroke();
    doc:path('M 20 640 c 12 -12 24 -12 36 0 s 24 12 36 0 t 12 12'):stroke();
    doc:path('M 120 640 A 25 25 0 0125 120 640'):stroke();
    doc:path('M6 6l2e1 3E1 .25.25 -.25-.25'):stroke();

    return doc
end

local outPath = assert(arg[1], "usage: lua example.lua <out.pdf>")

local doc = GeneratePDF()
local out = assert(io.open(outPath, "wb"))

doc:pipe(out)
doc:finish()
out:close()
