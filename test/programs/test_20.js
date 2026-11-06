// test_20 — embedded TrueType, Arabic joining forms
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
  doc.text('السلام', 72, 72);
  doc.fontSize(18);
  doc.text('مرحبا بالعالم', 72, 120);
  doc.fontSize(14);
  doc.text('كتاب 2026', 72, 160);
  doc.text('بسم الله الرحمن الرحيم', 72, 200, { width: 280 });

  const line = 'اللغة العربية';
  const w = doc.widthOfString(line);
  doc.text(line, 420 - w, 260);

  doc.addPage();
  doc.font(font, 12);
  doc.text('سطر طويل بما يكفي ليلتف مرتين على عرض العمود، مع أرقام ١٢٣ وحروف لاتينية PDF.', 72, 72, {
    width: 340,
    align: 'right',
    lineGap: 3,
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
