-- test_15 -- the table layout engine: column widths, spans, padding, borders, breaks
--
-- The Lua mirror of pdfkit/test_15.js. Everything inside GeneratePDF() is
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
    })

    -- 1. Simplest possible: data only, everything defaulted.
    doc:fontSize(11):text("Plain", 72, 60)
    doc:table({
      position = {x = 72, y = 78},
      data = {
        {"Region", "Q1", "Q2"},
        {"North", "1200", "980"},
        {"South", "640", "1710"},
      },
    })

    -- 2. Column widths: one fixed, two stars, one clamped by maxWidth.
    doc:fontSize(11):text("Columns", 72, 180)
    doc:table({
      position = {x = 72, y = 198},
      maxWidth = 400,
      columnStyles = {
        {width = 80},
        {width = "*"},
        {width = "*", maxWidth = 60},
        {width = "*"},
      },
      data = {
        {"fixed 80", "star", "star max 60", "star"},
        {"a", "b", "c", "d"},
      },
    })

    -- 3. Row heights, minHeight, percentage width, and a rowStyles callback.
    doc:fontSize(11):text("Rows", 72, 280)
    doc:table({
      position = {x = 72, y = 298},
      maxWidth = "60%",
      rowStyles = function(i)
        if i % 2 == 0 then return {height = 30} else return {minHeight = 18} end
      end,
      data = {
        {"tall row", "height 30"},
        {"short row", "min 18"},
        {"tall row", "height 30"},
      },
    })

    -- 4. Spans: a cell two columns wide over a cell two rows tall.
    doc:fontSize(11):text("Spans", 72, 400)
    doc:table({
      position = {x = 72, y = 418},
      maxWidth = 360,
      data = {
        {{text = "spans two columns", colSpan = 2}, "c"},
        {{text = "spans two rows", rowSpan = 2}, "b", "c"},
        {"b", "c"},
      },
    })

    -- 5. Padding, borders per side, border colours, background.
    doc:addPage()
    doc:fontSize(11):text("Borders", 72, 60)
    doc:table({
      position = {x = 72, y = 78},
      maxWidth = 400,
      defaultStyle = {padding = 6, border = {top = 2, bottom = 2, left = 0, right = 0}},
      data = {
        {
          {text = "thick top/bottom", borderColor = "red"},
          {text = "all four", border = 1, borderColor = {top = "blue", right = "green", bottom = "blue", left = "green"}},
        },
        {
          {text = "no border at all", border = 0},
          {text = "filled", backgroundColor = "#eeddcc", padding = {top = 2, bottom = 10, left = 14, right = 2}},
        },
      },
    })

    -- 6. Alignment, both axes, in a row tall enough for the vertical one to show.
    doc:fontSize(11):text("Alignment", 72, 200)
    doc:table({
      position = {x = 72, y = 218},
      maxWidth = 450,
      rowStyles = {height = 46},
      data = {
        {
          {text = "TL", align = {x = "left", y = "top"}},
          {text = "CC", align = {x = "center", y = "center"}},
          {text = "BR", align = {x = "right", y = "bottom"}},
          {text = "just this text wraps and is justified across the cell", align = "justify"},
        },
      },
    })

    -- 7. Text options and colours, including a stroked string.
    doc:fontSize(11):text("Text", 72, 300)
    doc:table({
      position = {x = 72, y = 318},
      maxWidth = 400,
      data = {
        {
          {text = "red", textColor = "red"},
          {text = "stroked", textStroke = 0.6, textStrokeColor = "blue", textColor = "white"},
          {text = "this string is long enough that it has to be cut short", textOptions = {ellipsis = true}},
        },
        {
          {text = "oblique", textOptions = {oblique = 10}},
          {text = "underline", textOptions = {underline = true}},
          {text = "char spaced", textOptions = {characterSpacing = 2}},
        },
      },
    })

    -- 8. Fonts: per-column, per-row and per-cell, with em-relative sizing.
    doc:fontSize(11):text("Fonts", 72, 420)
    doc:table({
      position = {x = 72, y = 438},
      maxWidth = 400,
      columnStyles = {{font = {src = "Helvetica-Bold"}}, {}, {}},
      rowStyles = {{}, {font = {size = 16}}},
      data = {
        {"col font", "plain", {text = "cell font", font = {src = "Courier", size = 9}}},
        {"col font", "row size 16", {text = "both", font = {src = "Times-Italic"}}},
      },
    })

    -- 9. Row-at-a-time, with the table object driven by hand.
    doc:addPage()
    doc:fontSize(11):text("Streamed", 72, 60)
    local t = doc:table({position = {x = 72, y = 78}, maxWidth = 300, columnStyles = {width = 150}})
    t:row({"streamed", "one"})
    t:row({"streamed", "two"})
    t:row({"streamed", "three"}, true)

    -- 10. A table long enough to break across a page, from the middle of a page.
    doc:fontSize(11):text("Overflow", 72, 200)
    local rows = {}
    for i = 1, 40 do rows[i] = {"row " .. i, "value " .. i * 7} end
    doc:table({position = {x = 72, y = 218}, maxWidth = 300, data = rows})

    return doc
end

-- --- plumbing ---------------------------------------------------------------

-- test_15.lua -> test_15_lua.pdf; the JS side writes test_15_js.pdf, so the two
-- never collide if they end up in the same folder.
local outPath = assert(arg[1], "usage: lua " .. (arg[0] or "program.lua") .. " <out.pdf>")

local doc = GeneratePDF()
local out = assert(io.open(outPath, "wb"))

doc:pipe(out)
doc:finish() -- PDFKit's doc.end(); `end` is a reserved word in Lua
out:close()

print(outPath)
