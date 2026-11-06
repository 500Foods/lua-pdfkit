-- test_05 -- every SVG path command, in both its absolute and its relative form
--
-- The Lua mirror of pdfkit/test_05.js. Everything inside GeneratePDF() is
-- lua-pdfkit API surface, and each call corresponds one-to-one with a PDFKit
-- call in the JS original. Everything outside it is plumbing -- module
-- resolution, file handling, output naming -- and is expected to differ
-- between the two implementations.

-- Resolve lua-pdfkit no matter which directory the script is run from.
local ROOT do
    local src = debug.getinfo(1, "S").source
    if src:sub(1, 1) == "@" then src = src:sub(2) end
    local dir = src:match("^(.*)/") or "."
    ROOT = dir .. "/../.."
end
package.path = ROOT .. "/src/?.lua;" .. ROOT .. "/src/?/init.lua;" .. package.path

local PDFDocument = require("lua-pdfkit")

-- --- lua-pdfkit API surface -------------------------------------------------

local function GeneratePDF()
    local doc = PDFDocument.new({
        size = "LETTER",
        layout = "portrait",
    })

    doc:path('M 10 10 L 100 10 L 100 100 Z'):stroke();
    doc:path('m 10 120 l 90 0 l 0 90 z'):stroke();
    doc:path('M 10 230 C 40 200 80 260 110 230 S 180 200 210 230'):stroke();
    doc:path('M 10 300 Q 60 260 110 300 T 210 300'):stroke();
    doc:path('M 10 350 H 200 V 400 h -100 v 40'):stroke();
    doc:path('M 100 450 A 50 30 0 0 1 200 450 a 50 30 0 1 0 -100 0'):stroke();
    doc:path('M 250 450 A 50 30 45 1 1 350 480'):stroke();
    doc:path('M10,550L60,550 60,600 10,600Z'):fill();
    doc:path('M 400 100 A 0 30 0 0 1 450 100'):stroke();
    doc:path('M 400 200 A 40 40 0 0 1 400 200'):stroke();
    doc:path('M 10 650 c 10 -10 20 -10 30 0 s 20 10 30 0 t 10 10'):stroke();
    doc:path('M 100 650 A 20 20 0 0110 100 650'):stroke();
    doc:path('M5 5l1e1 2E1 .5.5 -.5-.5'):stroke();

    return doc
end

-- --- plumbing ---------------------------------------------------------------

-- test_05.lua -> test_05_lua.pdf; the JS side writes test_05_js.pdf, so the two
-- never collide if they end up in the same folder.
local outPath = assert(arg[1], "usage: lua " .. (arg[0] or "program.lua") .. " <out.pdf>")

local doc = GeneratePDF()
local out = assert(io.open(outPath, "wb"))

doc:pipe(out)
doc:finish() -- PDFKit's doc.end(); `end` is a reserved word in Lua
out:close()

print(outPath)
