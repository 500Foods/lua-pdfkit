// test_21 -- embedded CFF (.otf): subset, widths, wrapping
const fs = require('fs');
const path = require('path');
const PDFDocument = require('pdfkit');
const ROOT = path.resolve(__dirname, '..', '..');

function GeneratePDF() {
  const doc = new PDFDocument({
    size: 'LETTER',
    layout: 'portrait',
  });

  const font = path.join(ROOT, 'test/assets/fonts/SourceCodePro-Regular.otf');
  doc.font(font, 20);
  doc.text('Source Code Pro', 72, 64);

  doc.fontSize(11);
  doc.text('The quick brown fox jumps over the lazy dog. 0123456789.', 72, 100, {
    width: 360,
    align: 'justify',
    lineGap: 3,
  });

  doc.fontSize(9);
  const sample = 'if (n < 1240) return 107; else return 1131;';
  doc.text(sample, 72, 160, { characterSpacing: 0.4 });
  const w = doc.widthOfString(sample);
  doc.text('width ' + w.toFixed(2), 72, 180);

  doc.fontSize(13);
  doc.text('Punctuation: ([{}]) <> "quotes" \'apostrophe\' -- em-dash? No.', 72, 210, {
    width: 400,
  });

  doc.addPage();
  doc.font(font, 16);
  doc.text('Page two', 72, 72, { align: 'center', width: 468 });
  doc.fontSize(10);
  doc.text('ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz', 72, 120, {
    width: 300,
    align: 'left',
    wordSpacing: 1.5,
  });
  doc.text('Symbols: @#$%^&*_+-=/~`|\\', 72, 180);

  return doc;
}

const outPath = process.argv[2];
if (!outPath) { console.error('usage: node program.js <out.pdf>'); process.exit(2); }

const doc = GeneratePDF();
const stream = fs.createWriteStream(outPath);
doc.pipe(stream);
doc.end();
stream.on('finish', () => process.exit(0));
