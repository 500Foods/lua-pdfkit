// test_19 — embedded TrueType, Hebrew: RTL glyph order and mark positioning
const fs = require('fs');
const path = require('path');
const PDFDocument = require('pdfkit');
const ROOT = path.resolve(__dirname, '..', '..');

function GeneratePDF() {
  const doc = new PDFDocument({
    size: 'LETTER',
    layout: 'portrait',
  });

  const font = path.join(ROOT, 'test/assets/fonts/DejaVuSans.ttf');
  doc.font(font, 24);
  doc.text('שלום', 72, 72);
  doc.fontSize(18);
  doc.text('שָׁלוֹם', 72, 110);
  doc.fontSize(14);
  doc.text('עברית 123', 72, 150);
  doc.text('אבגדהוזחטיכלמנסעפצקרשת', 72, 180, { width: 240 });

  const line = 'שלום עולם';
  const w = doc.widthOfString(line);
  doc.text(line, 400 - w, 230);

  doc.addPage();
  doc.font(font, 12);
  doc.text('עברית על העמוד השני, עם מספרים 2026 ומילה ארוכה יותר.', 72, 72, {
    width: 360,
    align: 'right',
  });

  return doc;
}

const outPath = process.argv[2];
if (!outPath) { console.error('usage: node program.js <out.pdf>'); process.exit(2); }

const doc = GeneratePDF();
const stream = fs.createWriteStream(outPath);
doc.pipe(stream);
doc.end();
stream.on('finish', () => process.exit(0));
