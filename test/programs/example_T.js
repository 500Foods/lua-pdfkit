// Held-out example T. Arabic, different copy and geometry from test_20.
const fs = require('fs');
const path = require('path');
const PDFDocument = require('pdfkit');
const ROOT = path.resolve(__dirname, '..', '..');

function GeneratePDF() {
  const doc = new PDFDocument({
    size: 'A4',
    margin: 48,
  });

  const font = path.join(ROOT, 'test/assets/fonts/DejaVuSans.ttf');
  doc.font(font, 26);
  doc.text('عنوان الصفحة', 48, 56);

  doc.fontSize(15);
  doc.text('هذا نص تجريبي لاختبار الوصل بين الحروف.', 48, 110, {
    width: 400,
    align: 'center',
  });

  doc.fontSize(12);
  doc.text('القاهرة، دمشق، بغداد، والرباط في سطر واحد.', 48, 180, {
    width: 460,
    align: 'justify',
  });

  doc.fontSize(13);
  doc.text('كلمة مع English في الوسط ثم ٤٢.', 48, 250);

  doc.addPage({ size: 'A4', margin: 48 });
  doc.font(font, 18);
  doc.text('الصفحة الثانية', 48, 48);
  doc.fontSize(11);
  doc.text('لا تنسَ التشكيل: كَتَبَ الكَاتِبُ كِتاباً.', 48, 100, {
    characterSpacing: 0.4,
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
