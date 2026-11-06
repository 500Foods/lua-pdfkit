-- Held-out example I. Not shipped with the task.
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

    -- Held-out counterpart to sample test_09: linear and radial gradients,
    -- opacity stops, gradient transforms and tiling patterns. Every construct the
    -- sample uses appears here with different geometry and different colours.

    -- A two-stop linear, running vertically rather than horizontally.
    local a = doc:linearGradient(0, 60, 0, 170)
    a:stop(0, "#ff8800"):stop(1, "#004488")
    doc:rect(60, 60, 110, 110):fill(a)

    -- Four stops, the last short of 100%, which forces the closing copy and the
    -- stitching function underneath it.
    local b = doc:linearGradient(210, 0, 330, 0)
    b:stop(0, "cyan"):stop(0.25, "white"):stop(0.6, "magenta"):stop(0.85, "black")
    doc:rect(210, 60, 120, 110):fill(b)

    -- Radial in RGB, offset centres so the inner circle is not concentric.
    local c = doc:radialGradient(400, 90, 8, 420, 115, 60)
    c:stop(0, {255, 255, 220}):stop(1, {40, 20, 80})
    doc:circle(420, 115, 60):fill(c)

    -- Opacity stops, which build the luminosity soft-mask tower.
    local d = doc:linearGradient(60, 0, 300, 0)
    d:stop(0, "green", 0):stop(0.35, "green", 1):stop(1, "purple", 0.2)
    doc:rect(60, 210, 240, 90):fill(d)

    -- A gradient placed by its own transform rather than by its coordinates.
    local e = doc:linearGradient(0, 0, 60, 0)
    e:stop(0, "#ffffff"):stop(1, "#222222")
    e:setTransform(3, 0, 0, 1.5, 330, 210)
    doc:rect(330, 210, 180, 90):fill(e)

    -- The first gradient again under the current transform: no re-embed.
    doc:rect(60, 320, 110, 36):fill(a)
    -- And again under a scaled one, which has to be embedded a second time.
    doc:save()
    doc:scale(1.25, 1.25)
    doc:rect(48, 300, 88, 30):fill(a)
    doc:restore()

    -- A gradient used as the stroke colour on a shape, not the fill.
    local f = doc:linearGradient(330, 0, 500, 0)
    f:stop(0, "yellow"):stop(1, "red")
    doc:lineWidth(9):rect(330, 320, 170, 50):stroke(f)

    -- Gray, given as one-element arrays.
    local g = doc:linearGradient(60, 0, 200, 0)
    g:stop(0, {0.15}):stop(0.5, {0.85}):stop(1, {0.35})
    doc:rect(60, 400, 140, 44):fill(g)

    -- Radial with opacity at both ends, the transparent end innermost.
    local h = doc:radialGradient(280, 424, 3, 280, 424, 44)
    h:stop(0, "black", 0.15):stop(1, "white", 0.95)
    doc:circle(280, 424, 44):fill(h)

    -- Tiling patterns: a hatch, filled twice against different colours, and a
    -- coarser one used as a stroke.
    local p = doc:pattern({0, 0, 6, 6}, 5, 5, "0.8 w 0 0 m 6 6 l s 0 6 m 6 0 l s")
    doc:rect(60, 480, 120, 70):fill({p, "#993300"})
    doc:rect(210, 480, 120, 70):fill({p, {100, 0, 60, 10}})
    local q = doc:pattern({0, 0, 10, 10}, 9, 9, "2 w 5 0 m 5 10 l s")
    doc:lineWidth(6):rect(360, 480, 140, 70):stroke({q, "navy"})

    -- Second page: the same gradient and the same pattern, which have to be
    -- re-registered against the new page's resource dictionary.
    doc:addPage()
    doc:rect(60, 60, 140, 90):fill(a)
    doc:rect(230, 60, 140, 90):fill({q, "black"})

    -- And one gradient that does not exist until after the break.
    local r = doc:linearGradient(60, 0, 320, 0)
    r:stop(0, "teal"):stop(0.5, "#ffcc00", 0.4):stop(1, "teal")
    doc:rect(60, 190, 260, 70):fill(r)

    return doc
end

local outPath = assert(arg[1], "usage: lua example.lua <out.pdf>")

local doc = GeneratePDF()
local out = assert(io.open(outPath, "wb"))

doc:pipe(out)
doc:finish()
out:close()
