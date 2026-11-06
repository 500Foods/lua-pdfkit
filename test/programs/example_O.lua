-- Held-out example O. Not shipped with the task.
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

    -- Held-out counterpart to sample test_15: the table layout engine. Same set
    -- of knobs -- column sizing, row sizing, spans, padding, borders, alignment,
    -- text options and fonts -- with different values everywhere, a wider grid,
    -- and one cell set in an embedded TrueType face so the table engine and the
    -- font embedder have to agree about widths.

    -- 1. Data only. Four columns rather than three, so the default sizing has a
    --    different amount of room to divide.
    doc:fontSize(10):text("Bare", 60, 50)
    doc:table({
      position = {x = 60, y = 66},
      data = {
        {"Site", "Mon", "Tue", "Wed"},
        {"Depot", "18", "24", "7"},
        {"Yard", "31", "3", "29"},
      },
    })

    -- 2. Column sizing: two fixed, one star, one star clamped smaller than its
    --    share, under an explicit maximum.
    doc:fontSize(10):text("Widths", 60, 160)
    doc:table({
      position = {x = 60, y = 176},
      maxWidth = 440,
      columnStyles = {
        {width = 60},
        {width = 110},
        {width = "*"},
        {width = "*", maxWidth = 45},
      },
      data = {
        {"sixty", "one ten", "star", "star capped"},
        {"w", "x", "y", "z"},
      },
    })

    -- 3. Row sizing by callback, and a maximum given as a percentage.
    doc:fontSize(10):text("Heights", 60, 262)
    doc:table({
      position = {x = 60, y = 278},
      maxWidth = "75%",
      rowStyles = function(i)
        if i == 1 then return {height = 42} else return {minHeight = 15} end
      end,
      data = {
        {"min fifteen", "first"},
        {"fixed forty-two", "second"},
        {"min fifteen", "third"},
        {"min fifteen", "fourth"},
      },
    })

    -- 4. Spans in both directions, including one that starts partway along a row.
    doc:fontSize(10):text("Spans", 60, 400)
    doc:table({
      position = {x = 60, y = 416},
      maxWidth = 420,
      data = {
        {"a", {text = "three wide", colSpan = 3}},
        {{text = "three tall", rowSpan = 3}, "b", "c", "d"},
        {"b", {text = "two wide", colSpan = 2}},
        {"b", "c", "d"},
      },
    })

    -- 5. Padding and borders: a default style for the table, then cells that
    --    override it one side at a time.
    doc:addPage()
    doc:fontSize(10):text("Edges", 60, 50)
    doc:table({
      position = {x = 60, y = 66},
      maxWidth = 430,
      defaultStyle = {padding = {top = 3, right = 8, bottom = 3, left = 8}, border = {top = 0, right = 1, bottom = 0, left = 1}},
      data = {
        {
          {text = "sides only", borderColor = "#aa0044"},
          {text = "all four, four colours", border = 2,
           borderColor = {top = "#111111", right = "#ff0000", bottom = "#00aa00", left = "#0000ff"}},
          {text = "none", border = 0},
        },
        {
          {text = "tinted", backgroundColor = "#f0e6ff"},
          {text = "lopsided padding", padding = {top = 12, right = 1, bottom = 1, left = 20}},
          {text = "thick bottom", border = {top = 0, right = 0, bottom = 4, left = 0}, borderColor = "black"},
        },
      },
    })

    -- 6. Alignment on both axes, in rows tall enough for the vertical part to be
    --    visible, plus a justified cell.
    doc:fontSize(10):text("Placement", 60, 190)
    doc:table({
      position = {x = 60, y = 206},
      maxWidth = 460,
      rowStyles = {height = 54},
      data = {
        {
          {text = "TR", align = {x = "right", y = "top"}},
          {text = "CB", align = {x = "center", y = "bottom"}},
          {text = "LC", align = {x = "left", y = "center"}},
          {text = "a run long enough to need several lines and be spread out to the full measure", align = "justify"},
        },
      },
    })

    -- 7. Text colour, stroking and the pass-through text options.
    doc:fontSize(10):text("Ink", 60, 290)
    doc:table({
      position = {x = 60, y = 306},
      maxWidth = 430,
      data = {
        {
          {text = "green", textColor = "#008844"},
          {text = "outlined", textStroke = 1.1, textStrokeColor = "#aa0000", textColor = "#ffeeee"},
          {text = "far too long to fit inside the width this column has been given", textOptions = {ellipsis = true}},
        },
        {
          {text = "leaning", textOptions = {oblique = -12}},
          {text = "ruled", textOptions = {underline = true, strike = true}},
          {text = "spread", textOptions = {characterSpacing = 1.5, wordSpacing = 4}},
        },
      },
    })

    -- 8. Fonts by column, by row and by cell, including one embedded face.
    doc:fontSize(10):text("Faces", 60, 400)
    doc:table({
      position = {x = 60, y = 416},
      maxWidth = 430,
      columnStyles = {{font = {src = "Times-Bold"}}, {}, {font = {size = 8}}},
      rowStyles = {{}, {font = {size = 14}}},
      data = {
        {"column face", "inherited", {text = "cell face", font = {src = "Courier-Oblique", size = 10}}},
        {"column face", "row size", {text = "embedded", font = {src = ROOT .. "/test/assets/fonts/Roboto-Regular.ttf", size = 11}}},
      },
    })

    -- 9. Driven a row at a time, with a single style applied to every column.
    doc:addPage()
    doc:fontSize(10):text("By hand", 60, 50)
    local t = doc:table({position = {x = 60, y = 66}, maxWidth = 360, columnStyles = {width = 120}})
    t:row({"first", "of", "four"})
    t:row({"second", "of", "four"})
    t:row({"third", "of", "four"})
    t:row({"fourth", "of", "four"}, true)

    -- 10. Long enough to break across two page boundaries, not just one.
    doc:fontSize(10):text("Spilling over", 60, 190)
    local rows = {}
    for i = 1, 70 do
        rows[i] = {"line " .. i, "x" .. (i * 3), (i % 5 == 0) and "mark" or ""}
    end
    doc:table({position = {x = 60, y = 206}, maxWidth = 330, data = rows})

    return doc
end

local outPath = assert(arg[1], "usage: lua example.lua <out.pdf>")

local doc = GeneratePDF()
local out = assert(io.open(outPath, "wb"))

doc:pipe(out)
doc:finish()
out:close()
