-- init.lua -- the front door of lua-pdfkit
--
-- PDFKit's entry point is the PDFDocument class and nothing else, and that is
-- the shape this keeps:
--
--     local PDFDocument = require("lua-pdfkit")
--
--     local doc = PDFDocument.new({ size = "LETTER", compress = false })
--     doc:fontSize(16)
--     doc:text("hello, world", 72, 72)
--
--     local out = assert(io.open("out.pdf", "wb"))
--     doc:pipe(out)
--     doc:finish()
--     out:close()
--
-- TWO NAMES DIFFER FROM THE ORIGINAL, both because Lua reserves the word:
--
--     doc.end()   ->  doc:finish()
--     ref.end()   ->  ref:finish()
--
-- Everything else keeps PDFKit's own spelling, camelCase included, so that a
-- JavaScript example transliterates line for line.
--
-- The submodules below are exported for callers who want a piece of the machine
-- rather than the whole document -- reading a PNG's dimensions without embedding
-- it, say, or formatting a number the way the PDF writer does. They are not
-- needed for ordinary use, and PDFKit does not expose equivalents.

local Document = require("lua-pdfkit.document")

local M = {}

--- Create a document. See document.lua for the option list.
M.new = Document.new

-- The class itself, for anyone wanting to add a method of their own -- the same
-- thing the mixins do.
M.Document = Document

-- Building blocks.
M.object = require("lua-pdfkit.object")
M.utils = require("lua-pdfkit.utils")
M.Reference = require("lua-pdfkit.reference")
M.Page = require("lua-pdfkit.page")

-- Fonts, images and compression, usable on their own.
M.Font = require("lua-pdfkit.font")
M.Image = require("lua-pdfkit.image")
M.PNGReader = require("lua-pdfkit.png_reader")
M.flate = require("lua-pdfkit.flate")

-- Text layout.
M.LineBreaker = require("lua-pdfkit.line_breaker")
M.LineWrapper = require("lua-pdfkit.line_wrapper")

-- SVG path parsing and playback.
M.SVGPath = require("lua-pdfkit.path")

return M
