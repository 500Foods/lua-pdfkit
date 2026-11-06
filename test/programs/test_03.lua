-- test_03 -- the vector graphics API: paths, curves, shapes, dashes, transforms and clipping
--
-- The Lua mirror of pdfkit/test_03.js. Everything inside GeneratePDF() is
-- pdfkit API surface, and each call corresponds one-to-one with a PDFKit
-- call in the JS original. Everything outside it is plumbing -- module
-- resolution, file handling, output naming -- and is expected to differ
-- between the two implementations.

-- Resolve pdfkit no matter which directory the script is run from.
local ROOT do
    local src = debug.getinfo(1, "S").source
    if src:sub(1, 1) == "@" then src = src:sub(2) end
    local dir = src:match("^(.*)/") or "."
    ROOT = dir .. "/../.."
end
package.path = ROOT .. "/src/?.lua;" .. ROOT .. "/src/?/init.lua;" .. package.path

local PDFDocument = require("pdfkit")

-- --- pdfkit API surface -------------------------------------------------

local function GeneratePDF()
    local doc = PDFDocument.new({
        size = "LETTER",
        layout = "portrait",
    })

    doc:moveTo(100,100):lineTo(200,150):lineTo(150,250):stroke()
    doc:lineWidth(3):lineCap('round'):lineJoin('bevel')
    doc:moveTo(50,50):bezierCurveTo(80,20,120,80,150,50):stroke()
    doc:moveTo(50,300):quadraticCurveTo(100,250,150,300):stroke()
    doc:rect(200,300,80,40):fill('red')
    doc:roundedRect(300,300,80,40,8):fillAndStroke('blue','black')
    doc:circle(120,400,30):stroke()
    doc:ellipse(220,400,40,20):fill()
    doc:polygon({50,500},{100,480},{140,530}):stroke()
    doc:dash(4, {space=2, phase=1})
    doc:moveTo(50,560):lineTo(400,560):stroke()
    doc:undash()
    doc:save():translate(100,100):rotate(30, {origin={0,0}}):scale(0.5):rect(0,0,50,50):stroke():restore()
    doc:transform(1,0,0.2,1,10,20)
    doc:rect(300,500,40,40):stroke()
    doc:lineWidth(1):miterLimit(4)
    doc:moveTo(400,100):lineTo(450,200):lineTo(500,100):stroke()
    doc:rect(50,600,100,50):clip()
    doc:rect(0,0,700,700):fill('green')

    return doc
end

-- --- plumbing ---------------------------------------------------------------

-- test_03.lua -> test_03_lua.pdf; the JS side writes test_03_js.pdf, so the two
-- never collide if they end up in the same folder.
local outPath = assert(arg[1], "usage: lua " .. (arg[0] or "program.lua") .. " <out.pdf>")

local doc = GeneratePDF()
local out = assert(io.open(outPath, "wb"))

doc:pipe(out)
doc:finish() -- PDFKit's doc.end(); `end` is a reserved word in Lua
out:close()

print(outPath)
