-- test_02 -- page sizes, layouts and margins, added and revisited, the document
-- info dictionary, and the XMP metadata packet that comes with it above PDF 1.3
--
-- The Lua mirror of pdfkit/test_02.js. Everything inside GeneratePDF() is
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
        bufferPages = true,
        pdfVersion = "1.4",
    })

    doc.info.Title = 'Cross check'
    doc.info.Author = 'harness'
    doc.info.Subject = 'pages'
    doc.info.Keywords = 'a,b'
    doc:text('page 1', 50, 50)
    doc:addPage({size='A4', layout='landscape', margin=20})
    doc:text('page 2', 50, 50)
    doc:addPage({size={300,400}, margins={top=10,bottom=20,left=30,right=40}})
    doc:text('page 3', 50, 50)
    doc:addPage({size='LEGAL'})
    doc:text('page 4', 50, 50)
    doc:switchToPage(0)
    doc:text('back on 1', 50, 100)
    doc:switchToPage(3)
    doc:text('back on 4', 50, 100)
    local r = doc:bufferedPageRange()
    doc:text(string.format('range %d %d', r.start, r.count), 50, 150)

    return doc
end

-- --- plumbing ---------------------------------------------------------------

-- test_02.lua -> test_02_lua.pdf; the JS side writes test_02_js.pdf, so the two
-- never collide if they end up in the same folder.
local outPath = assert(arg[1], "usage: lua " .. (arg[0] or "program.lua") .. " <out.pdf>")

local doc = GeneratePDF()
local out = assert(io.open(outPath, "wb"))

doc:pipe(out)
doc:finish() -- PDFKit's doc.end(); `end` is a reserved word in Lua
out:close()

print(outPath)
