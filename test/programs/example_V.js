// Held-out example V. WOFF1, different copy and geometry from test_22.
const fs = require('fs');
const path = require('path');
const PDFDocument = require('pdfkit');
const ROOT = path.resolve(__dirname, '..', '..');

function GeneratePDF() {
  const doc = new PDFDocument({
    size: 'A5',
    layout: 'landscape',
    margin: 36,
  });

  const font = path.join(ROOT, 'test/assets/fonts/SourceCodePro-Regular.woff');
  doc.font(font, 24);
  doc.text('A5 landscape', 36, 40);

  doc.fontSize(11);
  doc.text('Pack my box with five dozen liquor jugs. The font arrived compressed and leaves as a subset.', 36, 90, {
    width: 480,
    align: 'center',
    lineGap: 4,
  });

  doc.fontSize(9);
  doc.text('()[]{}<>+-*/= 3.14159', 36, 160);

  return doc;
}

const outPath = process.argv[2];
if (!outPath) { console.error('usage: node example.js <out.pdf>'); process.exit(2); }

const doc = GeneratePDF();
const stream = fs.createWriteStream(outPath);
doc.pipe(stream);
doc.end();
stream.on('finish', () => process.exit(0));
