-- test_14 -- a tagged PDF: the structure tree, marked content, artifacts and the parent tree
--
-- The Lua mirror of pdfkit/test_14.js. Everything inside GeneratePDF() is
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
        pdfVersion = "1.7",
        tagged = true,
        displayTitle = true,
    })

    doc.info.Title = "Tagged sample"
    doc.info.Lang = "en-US"

    local docStruct = doc:struct("Document")
    doc:addStructure(docStruct)

    local h1 = doc:struct("H1", {title="Heading one", lang="en-US"}, function()
      doc:fontSize(20):text("The Heading", 72, 72)
    end)
    docStruct:add(h1)

    local p1 = doc:struct("P", function()
      doc:fontSize(12):text("First paragraph of body copy, long enough to wrap onto a second line so the marked content spans more than one show-text operator.", 72, 110, {width=400})
    end)
    docStruct:add(p1)

    local list = doc:struct("L")
    for i = 1, 3 do
      local li = doc:struct("LI")
      li:add(doc:struct("Lbl", function() doc:text(i .. ".", 72, 170 + i*16) end))
      li:add(doc:struct("LBody", {alt="item " .. i}, function() doc:text("Item number " .. i, 92, 170 + i*16) end))
      list:add(li)
    end
    docStruct:add(list)

    local fig = doc:struct("Figure", {alt="A bee", bbox={72, 240, 172, 340}, placement="Block"}, function()
      doc:image(ROOT .. "/test/assets/images/bee.png", 72, 240, {width=100})
    end)
    docStruct:add(fig)

    doc:markContent("Artifact")
    doc:rect(72, 360, 200, 2):fill("black")
    doc:endMarkedContent()

    local cell = doc:struct("TD", {scope="Column"}, function() doc:text("cell", 72, 380) end)
    docStruct:add(cell)

    docStruct:finish()

    return doc
end

-- --- plumbing ---------------------------------------------------------------

-- test_14.lua -> test_14_lua.pdf; the JS side writes test_14_js.pdf, so the two
-- never collide if they end up in the same folder.
local outPath = assert(arg[1], "usage: lua " .. (arg[0] or "program.lua") .. " <out.pdf>")

local doc = GeneratePDF()
local out = assert(io.open(outPath, "wb"))

doc:pipe(out)
doc:finish() -- PDFKit's doc.end(); `end` is a reserved word in Lua
out:close()

print(outPath)
