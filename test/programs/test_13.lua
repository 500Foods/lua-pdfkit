-- test_13 -- annotations: links, notes, markup, shapes, attachments and named destinations
--
-- The Lua mirror of pdfkit/test_13.js. Everything inside GeneratePDF() is
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

    doc:fontSize(12)
    doc:text('link here', 50, 50)
    doc:link(50, 50, 100, 20, 'https://example.com')
    doc:note(50, 100, 20, 20, 'a note', {color='yellow', open=true})
    doc:highlight(50, 150, 80, 14, {color={255,255,0}})
    doc:underline(50, 200, 80, 14, {color='red'})
    doc:strike(50, 250, 80, 14)
    doc:lineAnnotation(50, 300, 150, 320, {color='blue'})
    doc:rectAnnotation(50, 350, 80, 40, {color='green'})
    doc:ellipseAnnotation(200, 350, 40, 20)
    doc:textAnnotation(50, 420, 100, 30, 'free text', {color='black'})
    doc:fileAnnotation(50, 470, 20, 20, {name='x.txt', src='hello file', description='a file'})
    doc:goTo(50, 520, 60, 20, 'dest1')
    doc:addNamedDestination('dest1')
    doc:annotate(50, 560, 40, 40, PDFDocument.object.dict{{'Subtype','Square'},{'Border',PDFDocument.object.array{0,0,2}}})

    return doc
end

-- --- plumbing ---------------------------------------------------------------

-- test_13.lua -> test_13_lua.pdf; the JS side writes test_13_js.pdf, so the two
-- never collide if they end up in the same folder.
local outPath = assert(arg[1], "usage: lua " .. (arg[0] or "program.lua") .. " <out.pdf>")

local doc = GeneratePDF()
local out = assert(io.open(outPath, "wb"))

doc:pipe(out)
doc:finish() -- PDFKit's doc.end(); `end` is a reserved word in Lua
out:close()

print(outPath)
