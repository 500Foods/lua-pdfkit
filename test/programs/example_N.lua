-- Held-out example N. Not shipped with the task.
local ROOT do
    local src = debug.getinfo(1, "S").source
    if src:sub(1, 1) == "@" then src = src:sub(2) end
    local dir = src:match("^(.*)/") or "."
    ROOT = dir .. "/../.."
end
package.path = ROOT .. "/src/?.lua;" .. ROOT .. "/src/?/init.lua;" .. package.path

local PDFDocument = require("pdfkit")

local function GeneratePDF()
    local doc = PDFDocument.new({
        size = "LETTER",
        layout = "portrait",
        pdfVersion = "1.7",
        tagged = true,
        displayTitle = true,
    })

    -- Held-out counterpart to sample test_14: the structure tree, marked content,
    -- artifacts and the parent tree. The tree here is deeper than the sample's --
    -- a Sect wrapping its own heading and body, a list nested inside that, and a
    -- figure whose image takes the alpha-channel route rather than the sample's --
    -- and it spans two pages, so the parent tree has entries under more than one
    -- page key.

    doc.info.Title = "Held-out structure"
    doc.info.Lang = "en-GB"

    local docStruct = doc:struct("Document")
    doc:addStructure(docStruct)

    -- A titled heading directly under the document.
    local h1 = doc:struct("H1", {title = "Top level", lang = "en-GB"}, function()
        doc:fontSize(22):text("Held-out Document", 60, 60)
    end)
    docStruct:add(h1)

    -- A section, with everything below it hanging off the section rather than off
    -- the document -- one level deeper than the sample builds.
    local sect = doc:struct("Sect", {title = "The only section"})
    docStruct:add(sect)

    local h2 = doc:struct("H2", {title = "Subheading", lang = "en-GB"}, function()
        doc:fontSize(15):text("A subheading inside it", 60, 100)
    end)
    sect:add(h2)

    local body = doc:struct("P", function()
        doc:fontSize(11):text("Body copy set wide enough to wrap over several lines, so the marked-content range covers more than one show-text operator and the range has to be closed on the right one.", 60, 130, {width = 420})
    end)
    sect:add(body)

    -- A quotation, which is a different structure type with an alt string.
    local quote = doc:struct("BlockQuote", {alt = "a quotation"}, function()
        doc:fontSize(11):text("Set in from the left margin, as a quotation would be.", 90, 190, {width = 360})
    end)
    sect:add(quote)

    -- A four-item list, labels and bodies built separately, nested in the section.
    local list = doc:struct("L")
    for i = 1, 4 do
        local li = doc:struct("LI")
        li:add(doc:struct("Lbl", function() doc:text("(" .. i .. ")", 60, 216 + i * 15) end))
        li:add(doc:struct("LBody", {alt = "entry " .. i, lang = "en-GB"}, function()
            doc:text("Entry " .. i .. " of four", 88, 216 + i * 15)
        end))
        list:add(li)
    end
    sect:add(list)

    -- An artifact: a rule that carries no semantics and must be excluded from the
    -- structure tree entirely.
    doc:markContent("Artifact")
    doc:rect(60, 292, 420, 1):fill("black")
    doc:endMarkedContent()

    -- A figure whose image has a real alpha channel, so the tagged path and the
    -- re-deflating image path run in the same document.
    local fig = doc:struct("Figure", {alt = "A fish", bbox = {60, 310, 180, 400}, placement = "Block"}, function()
        doc:image(ROOT .. "/test/assets/images/fish.png", 60, 310, {width = 120})
    end)
    sect:add(fig)

    local caption = doc:struct("Caption", function()
        doc:fontSize(9):text("Figure 1. Not a bee.", 60, 410)
    end)
    sect:add(caption)

    -- A second page, so the parent tree has to key entries by page.
    doc:addPage()

    local h2b = doc:struct("H2", {title = "Over the break"}, function()
        doc:fontSize(15):text("Continued overleaf", 60, 60)
    end)
    sect:add(h2b)

    -- Another artifact, this time on the second page.
    doc:markContent("Artifact")
    doc:rect(60, 88, 420, 1):fill("black")
    doc:endMarkedContent()

    -- Two header cells with the two scopes, added to the document rather than to
    -- the section, so the tree branches at the top again after the break.
    local th1 = doc:struct("TH", {scope = "Row", title = "a row header"}, function()
        doc:fontSize(11):text("row header", 60, 110)
    end)
    docStruct:add(th1)

    local th2 = doc:struct("TH", {scope = "Column", title = "a column header"}, function()
        doc:text("column header", 160, 110)
    end)
    docStruct:add(th2)

    local cell = doc:struct("TD", function() doc:text("a plain cell", 60, 140) end)
    docStruct:add(cell)

    docStruct:finish()

    return doc
end

local outPath = assert(arg[1], "usage: lua example.lua <out.pdf>")

local doc = GeneratePDF()
local out = assert(io.open(outPath, "wb"))

doc:pipe(out)
doc:finish()
out:close()
