// test_05 — every SVG path command, in both its absolute and its relative form
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

  doc.path('M 10 10 L 100 10 L 100 100 Z').stroke();
  doc.path('m 10 120 l 90 0 l 0 90 z').stroke();
  doc.path('M 10 230 C 40 200 80 260 110 230 S 180 200 210 230').stroke();
  doc.path('M 10 300 Q 60 260 110 300 T 210 300').stroke();
  doc.path('M 10 350 H 200 V 400 h -100 v 40').stroke();
  doc.path('M 100 450 A 50 30 0 0 1 200 450 a 50 30 0 1 0 -100 0').stroke();
  doc.path('M 250 450 A 50 30 45 1 1 350 480').stroke();
  doc.path('M10,550L60,550 60,600 10,600Z').fill();
  doc.path('M 400 100 A 0 30 0 0 1 450 100').stroke();
  doc.path('M 400 200 A 40 40 0 0 1 400 200').stroke();
  doc.path('M 10 650 c 10 -10 20 -10 30 0 s 20 10 30 0 t 10 10').stroke();
  doc.path('M 100 650 A 20 20 0 0110 100 650').stroke();
  doc.path('M5 5l1e1 2E1 .5.5 -.5-.5').stroke();

  return doc;
}

// --- Node plumbing ----------------------------------------------------------

// test_05.js -> test_05_js.pdf; the Lua side writes test_05_lua.pdf, so the two
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
