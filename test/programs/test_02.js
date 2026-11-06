// test_02 — page sizes, layouts and margins, added and revisited, the document
// info dictionary, and the XMP metadata packet that comes with it above PDF 1.3
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
    bufferPages: true,
    pdfVersion: '1.4',
  });

  doc.info.Title = 'Cross check';
  doc.info.Author = 'harness';
  doc.info.Subject = 'pages';
  doc.info.Keywords = 'a,b';
  doc.text('page 1', 50, 50);
  doc.addPage({size:'A4', layout:'landscape', margin:20});
  doc.text('page 2', 50, 50);
  doc.addPage({size:[300,400], margins:{top:10,bottom:20,left:30,right:40}});
  doc.text('page 3', 50, 50);
  doc.addPage({size:'LEGAL'});
  doc.text('page 4', 50, 50);
  doc.switchToPage(0);
  doc.text('back on 1', 50, 100);
  doc.switchToPage(3);
  doc.text('back on 4', 50, 100);
  const r = doc.bufferedPageRange();
  doc.text(`range ${r.start} ${r.count}`, 50, 150);

  return doc;
}

// --- Node plumbing ----------------------------------------------------------

// test_02.js -> test_02_js.pdf; the Lua side writes test_02_lua.pdf, so the two
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
