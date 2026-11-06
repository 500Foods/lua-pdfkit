-- test_04 -- colour in every notation PDFKit accepts, plus fill rules, opacity and spot colours
--
-- The Lua mirror of pdfkit/test_04.js. Everything inside GeneratePDF() is
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

    doc:fillColor('red'):rect(10,10,50,50):fill()
    doc:fillColor('#ff8800'):rect(70,10,50,50):fill()
    doc:fillColor('#f80'):rect(130,10,50,50):fill()
    doc:fillColor({255,128,0}):rect(190,10,50,50):fill()
    doc:fillColor({0,100,50,10}):rect(250,10,50,50):fill()
    doc:strokeColor('blue'):lineWidth(4):rect(10,80,50,50):stroke()
    doc:fillOpacity(0.5):rect(70,80,50,50):fill('green')
    doc:strokeOpacity(0.25):rect(130,80,50,50):stroke()
    doc:opacity(0.75):rect(190,80,50,50):fill('purple')
    doc:fillColor('black', 0.3):rect(250,80,50,50):fill()
    doc:fillOpacity(1):strokeOpacity(1)
    doc:fillColor('yellow'):rect(10,200,50,50):fill()
    doc:fillColor('rebeccapurple'):rect(70,200,50,50):fill()
    doc:fillAndStroke('lime','navy')
    doc:addSpotColor('PANTONE-185', 0, 100, 79, 0)
    doc:fillColor('PANTONE-185'):rect(10,300,60,60):fill()
    doc:strokeColor('PANTONE-185', 0.6):rect(90,300,60,60):stroke()
    doc:fillOpacity(0.5):rect(200,300,60,60):fill('red')
    doc:fillOpacity(0.5):rect(280,300,60,60):fill('red')

    return doc
end

-- --- plumbing ---------------------------------------------------------------

-- test_04.lua -> test_04_lua.pdf; the JS side writes test_04_js.pdf, so the two
-- never collide if they end up in the same folder.
local outPath = assert(arg[1], "usage: lua " .. (arg[0] or "program.lua") .. " <out.pdf>")

local doc = GeneratePDF()
local out = assert(io.open(outPath, "wb"))

doc:pipe(out)
doc:finish() -- PDFKit's doc.end(); `end` is a reserved word in Lua
out:close()

print(outPath)
