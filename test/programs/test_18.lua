-- test_18 -- outlines: nested bookmarks, expanded, page index, XYZ destinations
local ROOT do
    local src = debug.getinfo(1, "S").source
    if src:sub(1, 1) == "@" then src = src:sub(2) end
    local dir = src:match("^(.*)/") or "."
    ROOT = dir .. "/../.."
end
package.path = ROOT .. "/src/?.lua;" .. ROOT .. "/src/?/init.lua;" .. package.path

local PDFDocument = require("lua-pdfkit")

local function GeneratePDF()
    local doc = PDFDocument.new({
        size = "LETTER",
        layout = "portrait",
    })

    doc:fontSize(16)
    doc:text("Page one", 72, 72)
    doc:addPage()
    doc:text("Page two", 72, 72)
    doc:addPage()
    doc:text("Page three", 72, 72)

    local outline = doc.outline
    local top = outline:addItem("Top Level", { expanded = true })
    top:addItem("Sub-section")
    top:addItem("Nested closed", { expanded = false })

    outline:addItem("Chapter 1", { pageNumber = 0 })
    outline:addItem("Chapter 2", { pageNumber = 1 })
    outline:addItem("Chapter 3", { pageNumber = 2, expanded = true })

    outline:addItem("Section 1", {
        fit = false,
        top = 0,
        left = 0,
        zoom = 1.5,
    })
    outline:addItem("Section 2", {
        pageNumber = 1,
        fit = false,
        top = 100,
        left = 36,
        zoom = 0,
    })

    local quoted = outline:addItem('Quotes "and" parens (here)')
    quoted:addItem("Child of quoted", { pageNumber = 2, fit = true })

    return doc
end

local outPath = assert(arg[1], "usage: lua program.lua <out.pdf>")
local doc = GeneratePDF()
local out = assert(io.open(outPath, "wb"))
doc:pipe(out)
doc:finish()
out:close()
