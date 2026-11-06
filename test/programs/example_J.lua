-- Held-out example J. Not shipped with the task.
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

    -- Held-out counterpart to sample test_10: JPEG and PNG images with fit,
    -- cover, scale, alignment, links and opacity.
    --
    -- Every colour type PDFKit treats differently is here, because it takes a
    -- different route through the embedder for each. Types 4 and 6 carry a real
    -- alpha channel, so the colour plane is decoded and re-deflated and the alpha
    -- plane is deflated separately -- two fresh compressed streams that have to
    -- come out byte-identical. Types 0, 2 and 3 with a tRNS chunk keep their
    -- original IDAT untouched and only deflate a small alpha lookup. Opaque PNGs
    -- are copied through whole, and JPEGs are never deflated at all. A port that
    -- only agrees with PDFKit on one of those routes fails here.
    --
    -- The options are permuted against the sample so no placement is reused.
    local IMG = ROOT .. "/test/assets/images"

    -- Colour type 6, RGB with alpha: fit inside a box, aligned to a corner.
    doc:image(IMG .. "/bee.png", 50, 50, {fit = {110, 110}, align = "right", valign = "bottom"})
    -- Colour type 4, gray with alpha: plain width.
    doc:image(IMG .. "/fish.png", 180, 50, {width = 90})
    -- Colour type 6 again, sixteen bits per sample: cover a box it does not fit.
    doc:image(IMG .. "/straight.png", 300, 50, {cover = {120, 90}, align = "center", valign = "center"})

    -- Colour type 0 with tRNS: an alpha lookup table rather than a plane.
    doc:image(IMG .. "/pngsuite-gray-transparent-black.png", 50, 190, {width = 70, opacity = 0.65})
    -- Colour type 2 with tRNS, sixteen bits.
    doc:image(IMG .. "/pngsuite-rgb-transparent-white.png", 150, 190, {scale = 0.75})
    -- Colour type 3 with tRNS, one bit per pixel.
    doc:image(IMG .. "/pallete-transparent-white-1bit.png", 250, 190, {fit = {80, 80}})
    -- Colour type 3 with tRNS, eight bits.
    doc:image(IMG .. "/pngsuite-palette-transparent-white.png", 360, 190, {height = 70})

    -- Opaque grayscale: the IDAT is copied through with no deflate anywhere.
    doc:image(IMG .. "/glassware-noisy.png", 50, 300, {width = 120, link = "https://pdfkit.org/"})

    -- The JPEG paths, which never compress anything.
    doc:image(IMG .. "/bee.jpg", 200, 300, {fit = {100, 100}, align = "left", valign = "top"})
    doc:image(IMG .. "/sampleImage.jpg", 320, 300, {height = 90})
    doc:image(IMG .. "/orientation-6.jpeg", 430, 300, {scale = 0.35, opacity = 0.4})

    -- The same file twice more: once at a different size, once at the same size,
    -- so the image cache is asked for a hit both ways on one page.
    doc:image(IMG .. "/bee.png", 50, 430, {width = 60})
    doc:image(IMG .. "/bee.png", 130, 430, {width = 60})

    -- A second page, where every XObject has to be recorded against a fresh
    -- resource dictionary even though the images themselves are already embedded.
    doc:addPage()
    doc:image(IMG .. "/fish.png", 60, 60, {fit = {140, 140}, align = "center", valign = "center"})
    doc:image(IMG .. "/bee.jpg", 230, 60, {width = 120, opacity = 0.8})
    -- And one file that appears only after the break.
    doc:image(IMG .. "/straight.png", 380, 60, {width = 100})

    return doc
end

local outPath = assert(arg[1], "usage: lua example.lua <out.pdf>")

local doc = GeneratePDF()
local out = assert(io.open(outPath, "wb"))

doc:pipe(out)
doc:finish()
out:close()
