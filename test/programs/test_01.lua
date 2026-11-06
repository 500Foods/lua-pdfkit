-- test_01 -- "hello, world" centered horizontally and vertically on a portrait
-- US Letter page, in the default font (Helvetica) at 16pt.
--
-- The Lua mirror of pdfkit/test_01.js. Everything inside GeneratePDF() is
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

    doc:fontSize(16)

    local text = "hello, world"

    -- Horizontal: align within the full margin box, which is symmetric, so
    -- centering in the box is centering on the page.
    local width =
        doc.page.width - doc.page.margins.left - doc.page.margins.right

    -- Vertical: measure the laid-out height and split the remaining space.
    local height = doc:heightOfString(text, { width = width, align = "center" })
    local y = (doc.page.height - height) / 2

    doc:text(text, doc.page.margins.left, y, { width = width, align = "center" })

    return doc
end

-- --- plumbing ---------------------------------------------------------------

-- test_01.lua -> test_01_lua.pdf; the JS side writes test_01_js.pdf, so the two
-- never collide if they end up in the same folder.
local outPath = assert(arg[1], "usage: lua " .. (arg[0] or "program.lua") .. " <out.pdf>")

local doc = GeneratePDF()
local out = assert(io.open(outPath, "wb"))

doc:pipe(out)
doc:finish() -- PDFKit's doc.end(); `end` is a reserved word in Lua
out:close()

print(outPath)
