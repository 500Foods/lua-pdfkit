-- Held-out example A. Not shipped with the task.
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

    -- Held-out counterpart to sample test_01: measured text placement.
    doc:fontSize(24)

    local title = "the quick brown fox"
    local width = doc.page.width - doc.page.margins.left - doc.page.margins.right

    -- Right-aligned in the margin box, placed a third of the way down rather than
    -- centred, so the measured height feeds a different arithmetic than the sample.
    local height = doc:heightOfString(title, { width = width, align = "right" })
    local y = (doc.page.height - height) / 3
    doc:text(title, doc.page.margins.left, y, { width = width, align = "right" })

    -- A wrapped block centred in a narrower column, measured the same way.
    doc:fontSize(11)
    local para = "A paragraph set in a column narrower than the margin box, so the " ..
        "line breaker has to wrap it several times before the measured height " ..
        "means anything."
    local ph = doc:heightOfString(para, { width = 240, align = "center" })
    doc:text(para, doc.page.margins.left, y + height + 36, { width = 240, align = "center" })

    -- And the same string again, left-aligned, directly below the measured block.
    doc:text(para, doc.page.margins.left, y + height + 36 + ph + 18, { width = 240 })

    -- A block long enough to run off the bottom of the page, so the wrapper has to
    -- open the second page by itself rather than being told to.
    -- Set off the page's black so the break has a fill colour to carry over: the
    -- colour lives in the content stream, so page two has to restate it.
    doc:fillColor("#334455"):fontSize(10)
    local long = string.rep(
        "This sentence repeats until the block is taller than the page it starts " ..
        "on, which forces the line wrapper to break to a new page on its own. ", 12)
    doc:text(long, doc.page.margins.left, 560, { width = 400, align = "justify" })

    -- And one line asked for below the bottom margin, which has to move to a fresh
    -- page before it emits anything at all.
    doc:fillColor("black"):fontSize(12)
    doc:text("asked for past the bottom margin", doc.page.margins.left, 750)

    return doc
end

local outPath = assert(arg[1], "usage: lua example.lua <out.pdf>")

local doc = GeneratePDF()
local out = assert(io.open(outPath, "wb"))

doc:pipe(out)
doc:finish()
out:close()
