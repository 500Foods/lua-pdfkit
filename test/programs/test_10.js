// test_10 — JPEG and PNG images, with fit, cover, scale, alignment and opacity
//
// Everything inside GeneratePDF() is PDFKit API surface and needs a one-to-one
// Lua equivalent. Everything outside it is Node plumbing — stream handling and
// file naming — and is expected to differ between the two implementations.

const fs = require('fs');
const path = require('path');
const PDFDocument = require('pdfkit');
const ROOT = path.resolve(__dirname, '..', '..');

// --- PDFKit API surface -----------------------------------------------------

function GeneratePDF() {
  const doc = new PDFDocument({
    size: 'LETTER',
    layout: 'portrait',
  });

  const IMG = ROOT + "/test/assets/images";
  doc.image(IMG + '/bee.png', 50, 50, {width:100});
  doc.image(IMG + '/bee.jpg', 200, 50, {height:80});
  doc.image(IMG + '/fish.png', 50, 200, {fit:[120,120], align:'center', valign:'center'});
  doc.image(IMG + '/glassware-noisy.png', 200, 200, {cover:[100,100]});
  doc.image(IMG + '/pngsuite-gray-transparent-black.png', 350, 200, {scale:0.5});
  doc.image(IMG + '/pallete-transparent-white-1bit.png', 350, 300);
  doc.image(IMG + '/straight.png', 50, 350, {width:60, link:'https://example.com'});
  doc.image(IMG + '/orientation-6.jpeg', 150, 350, {width:60});
  doc.image(IMG + '/sampleImage.jpg', 250, 350, {width:60, opacity:0.5});
  doc.image(IMG + '/pngsuite-rgb-transparent-white.png', 350, 450, {width:60});
  doc.image(IMG + '/pngsuite-palette-transparent-white.png', 430, 450, {width:60});

  return doc;
}

// --- Node plumbing ----------------------------------------------------------

// test_10.js -> test_10_js.pdf; the Lua side writes test_10_lua.pdf, so the two
// never collide if they end up in the same folder.
const outPath = process.argv[2];
if (!outPath) { console.error('usage: node program.js <out.pdf>'); process.exit(2); }

const doc = GeneratePDF();
const stream = fs.createWriteStream(outPath);

doc.pipe(stream);
doc.end();

stream.on('finish', () => {
  console.log(outPath);
});
