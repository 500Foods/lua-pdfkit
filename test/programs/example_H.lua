-- Held-out example H. Not shipped with the task.
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
    })

    -- Held-out counterpart to sample test_08: text layout -- alignment, columns,
    -- lists, decorations, links and continued runs. Same options, different
    -- values throughout, so a port that hard-coded the sample's numbers has
    -- nothing to fall back on.

    local P = "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam eaque ipsa quae ab illo inventore veritatis."
    doc:fontSize(9)

    -- The four alignments, on a narrower measure than the sample uses so the
    -- line breaker chooses different break points.
    doc:text(P, 40, 40, {width = 170, align = "justify"})
    doc:text(P, 40, 110, {width = 170, align = "center"})
    doc:text(P, 40, 180, {width = 170, align = "right"})
    doc:text(P, 40, 250, {width = 170, align = "left"})

    -- Indent, paragraph gap and line gap together.
    doc:text(P, 250, 40, {width = 230, indent = 35, paragraphGap = 14, lineGap = 6})

    -- Three columns rather than two, and a taller box.
    doc:text(P, 250, 160, {width = 230, columns = 3, columnGap = 14, height = 120})

    -- Decorations, one per line.
    doc:text("underlined", 40, 330, {underline = true})
    doc:text("struck", 40, 348, {strike = true})
    doc:text("underlined and struck", 40, 366, {underline = true, strike = true})
    doc:text("slanted", 40, 384, {oblique = true})
    doc:text("slanted by minus eight", 40, 402, {oblique = -8})

    -- A link, a jump to a named destination, and the destination itself.
    doc:text("follow me", 40, 424, {link = "https://pdfkit.org/docs/", underline = true})
    doc:text("jump", 40, 442, {goTo = "target"})
    doc:text("landing", 40, 460, {destination = "target"})

    -- Lists: a nested one, then the two counted kinds in the other order.
    doc:list({"alpha", {"beta one", "beta two", "beta three"}, "gamma"}, 40, 482, {width = 190})
    doc:list({"first", "second", "third"}, 250, 330, {width = 190, listType = "lettered"})
    doc:list({"first", "second", "third"}, 250, 400, {width = 190, listType = "numbered"})

    -- Spacing, wrapping suppressed, and truncation.
    doc:text("spaced out wider than before", 40, 570, {characterSpacing = 3.5, wordSpacing = 9})
    doc:text("this one is not allowed to wrap at all", 40, 596, {lineBreak = false})
    doc:text("truncated because the box is far too small", 40, 618, {width = 90, height = 11, ellipsis = true})

    -- A continued run in three parts rather than two.
    doc:text("one ", 40, 640, {continued = true})
       :text("two ", {continued = true})
       :text("three")

    -- Baseline placement and a filled-and-stroked string.
    doc:text("hanging baseline", 40, 664, {baseline = "hanging"})
    doc:text("filled and stroked", 40, 690, {fill = true, stroke = true})

    return doc
end

local outPath = assert(arg[1], "usage: lua example.lua <out.pdf>")

local doc = GeneratePDF()
local out = assert(io.open(outPath, "wb"))

doc:pipe(out)
doc:finish()
out:close()
