// test_01 — "hello, world" centered horizontally and vertically on a portrait
// US Letter page, in the default font (Helvetica) at 16pt.
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

  doc.fontSize(16);

  const text = 'hello, world';

  // Horizontal: align within the full margin box, which is symmetric, so
  // centering in the box is centering on the page.
  const width =
    doc.page.width - doc.page.margins.left - doc.page.margins.right;

  // Vertical: measure the laid-out height and split the remaining space.
  const height = doc.heightOfString(text, { width: width, align: 'center' });
  const y = (doc.page.height - height) / 2;

  doc.text(text, doc.page.margins.left, y, { width: width, align: 'center' });

  return doc;
}

// --- Node plumbing ----------------------------------------------------------

// test_01.js -> test_01_js.pdf; the Lua side writes test_01_lua.pdf, so the two
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
