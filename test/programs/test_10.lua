-- test_10 -- JPEG and PNG images, with fit, cover, scale, alignment and opacity
--
-- The Lua mirror of pdfkit/test_10.js. Everything inside GeneratePDF() is
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

    local IMG = ROOT .. "/test/assets/images"
    doc:image(IMG .. '/bee.png', 50, 50, {width=100})
    doc:image(IMG .. '/bee.jpg', 200, 50, {height=80})
    doc:image(IMG .. '/fish.png', 50, 200, {fit={120,120}, align='center', valign='center'})
    doc:image(IMG .. '/glassware-noisy.png', 200, 200, {cover={100,100}})
    doc:image(IMG .. '/pngsuite-gray-transparent-black.png', 350, 200, {scale=0.5})
    doc:image(IMG .. '/pallete-transparent-white-1bit.png', 350, 300)
    doc:image(IMG .. '/straight.png', 50, 350, {width=60, link='https://example.com'})
    doc:image(IMG .. '/orientation-6.jpeg', 150, 350, {width=60})
    doc:image(IMG .. '/sampleImage.jpg', 250, 350, {width=60, opacity=0.5})
    doc:image(IMG .. '/pngsuite-rgb-transparent-white.png', 350, 450, {width=60})
    doc:image(IMG .. '/pngsuite-palette-transparent-white.png', 430, 450, {width=60})

    return doc
end

-- --- plumbing ---------------------------------------------------------------

-- test_10.lua -> test_10_lua.pdf; the JS side writes test_10_js.pdf, so the two
-- never collide if they end up in the same folder.
local outPath = assert(arg[1], "usage: lua " .. (arg[0] or "program.lua") .. " <out.pdf>")

local doc = GeneratePDF()
local out = assert(io.open(outPath, "wb"))

doc:pipe(out)
doc:finish() -- PDFKit's doc.end(); `end` is a reserved word in Lua
out:close()

print(outPath)
