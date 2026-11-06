// Held-out example U. CFF font, different copy and geometry from test_21.
const fs = require('fs');
const path = require('path');
const PDFDocument = require('pdfkit');
const ROOT = path.resolve(__dirname, '..', '..');

function GeneratePDF() {
  const doc = new PDFDocument({
    size: 'A4',
    margin: 48,
  });

  const font = path.join(ROOT, 'test/assets/fonts/SourceCodePro-Regular.otf');
  doc.font(font, 22);
  doc.text('Release notes', 48, 56);

  doc.fontSize(12);
  doc.text('Version 1.0.0 embeds this face as a CIDFontType0. The subset keeps only the glyphs this page uses.', 48, 100, {
    width: 480,
    align: 'left',
    lineGap: 5,
  });

  doc.fontSize(10);
  doc.text('Item 1   build the charstring index', 48, 170);
  doc.text('Item 2   stub unused subroutines', 48, 186);
  doc.text('Item 3   write ROS Adobe-Identity-0', 48, 202);

  doc.moveDown(2);
  doc.fontSize(14);
  doc.text('Centered colophon', { align: 'center', characterSpacing: 1 });

  doc.addPage({ size: 'A4', margin: 48 });
  doc.font(font, 11);
  doc.text('Second page, right aligned, with digits 2026 and a long line that has to wrap inside a narrow measure so the line breaker runs.', 48, 80, {
    width: 240,
    align: 'right',
  });

  return doc;
}

const outPath = process.argv[2];
if (!outPath) { console.error('usage: node example.js <out.pdf>'); process.exit(2); }

const doc = GeneratePDF();
const stream = fs.createWriteStream(outPath);
doc.pipe(stream);
doc.end();
stream.on('finish', () => process.exit(0));
