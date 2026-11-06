// test_22 -- WOFF1 unwrap: the file is zlib-wrapped TrueType, the PDF embeds a subset
const fs = require('fs');
const path = require('path');
const PDFDocument = require('pdfkit');
const ROOT = path.resolve(__dirname, '..', '..');

function GeneratePDF() {
  const doc = new PDFDocument({
    size: 'LETTER',
    margin: 72,
  });

  const font = path.join(ROOT, 'test/assets/fonts/SourceCodePro-Regular.woff');
  doc.font(font, 18);
  doc.text('Wrapped for the web', 72, 72);

  doc.fontSize(12);
  doc.text('WOFF is a transport. This page is a normal TrueType subset: tables inflated, then glyf copied for the glyphs below.', 72, 110, {
    width: 420,
    align: 'justify',
    lineGap: 2,
  });

  doc.fontSize(10);
  doc.text('0123456789 abcdefghijklmnopqrstuvwxyz', 72, 180, {
    characterSpacing: 0.6,
  });
  doc.text('ABCDEFGHIJKLMNOPQRSTUVWXYZ', 72, 200);

  doc.addPage();
  doc.font(font, 14);
  doc.text('Still the same face', 72, 80, { align: 'right', width: 400 });

  return doc;
}

const outPath = process.argv[2];
if (!outPath) { console.error('usage: node program.js <out.pdf>'); process.exit(2); }

const doc = GeneratePDF();
const stream = fs.createWriteStream(outPath);
doc.pipe(stream);
doc.end();
stream.on('finish', () => process.exit(0));
