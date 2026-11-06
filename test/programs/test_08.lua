-- test_08 -- text layout: alignment, columns, lists, decorations, links and continued runs
--
-- The Lua mirror of pdfkit/test_08.js. Everything inside GeneratePDF() is
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

    local L = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'
    doc:fontSize(10)
    doc:text(L, 50, 50, {width=200, align='left'})
    doc:text(L, 50, 120, {width=200, align='right'})
    doc:text(L, 50, 190, {width=200, align='center'})
    doc:text(L, 50, 260, {width=200, align='justify'})
    doc:text(L, 300, 50, {width=200, indent=20, paragraphGap=8, lineGap=3})
    doc:text(L, 300, 150, {width=200, columns=2, columnGap=10, height=100})
    doc:text('under', 50, 340, {underline=true})
    doc:text('strike', 50, 360, {strike=true})
    doc:text('both', 50, 380, {underline=true, strike=true})
    doc:text('oblique', 50, 400, {oblique=true})
    doc:text('oblique15', 50, 420, {oblique=15})
    doc:text('link', 50, 440, {link='https://example.com', underline=true})
    doc:text('goto', 50, 460, {goTo='anchor'})
    doc:text('dest', 50, 480, {destination='anchor'})
    doc:list({'one','two',{'nested a','nested b'},'three'}, 50, 500, {width=200})
    doc:list({'a','b'}, 300, 500, {width=200, listType='numbered'})
    doc:list({'a','b'}, 300, 560, {width=200, listType='lettered'})
    doc:text('spacing', 50, 620, {characterSpacing=2, wordSpacing=5})
    doc:text('nowrap', 50, 650, {lineBreak=false})
    doc:text('ellipsis test that is long', 50, 670, {width=60, height=12, ellipsis=true})
    doc:text('cont1 ', 50, 690, {continued=true}):text('cont2')
    doc:text('baseline', 50, 710, {baseline='top'})
    doc:text('fill+stroke', 50, 730, {fill=true, stroke=true})

    return doc
end

-- --- plumbing ---------------------------------------------------------------

-- test_08.lua -> test_08_lua.pdf; the JS side writes test_08_js.pdf, so the two
-- never collide if they end up in the same folder.
local outPath = assert(arg[1], "usage: lua " .. (arg[0] or "program.lua") .. " <out.pdf>")

local doc = GeneratePDF()
local out = assert(io.open(outPath, "wb"))

doc:pipe(out)
doc:finish() -- PDFKit's doc.end(); `end` is a reserved word in Lua
out:close()

print(outPath)
