// Held-out example S. Hebrew, different copy and geometry from test_19.
const fs = require('fs');
const path = require('path');
const PDFDocument = require('pdfkit');
const ROOT = path.resolve(__dirname, '..', '..');

function GeneratePDF() {
  const doc = new PDFDocument({
    size: 'A4',
    margin: 50,
  });

  const font = path.join(ROOT, 'test/assets/fonts/DejaVuSans.ttf');
  doc.font(font, 28);
  doc.text('ברוכים הבאים', 50, 60);

  doc.fontSize(16);
  doc.text('ספר בראשית, פרק א.', 50, 120, { width: 300, align: 'center' });

  doc.fontSize(11);
  doc.text('בְּרֵאשִׁית בָּרָא אֱלֹהִים אֵת הַשָּׁמַיִם וְאֵת הָאָרֶץ.', 50, 180, {
    width: 420,
    align: 'justify',
    lineGap: 4,
  });

  doc.fontSize(13);
  doc.text('שורה עם אנגלית Hello וספרות 42.', 50, 260);

  doc.addPage({ size: 'A4', margin: 50 });
  doc.font(font, 20);
  doc.text('עמוד ב׳', 50, 50);
  doc.fontSize(14);
  doc.text('תל אביב, ירושלים, חיפה', 50, 100, { characterSpacing: 1.5 });

  return doc;
}

const outPath = process.argv[2];
if (!outPath) { console.error('usage: node example.js <out.pdf>'); process.exit(2); }

const doc = GeneratePDF();
const stream = fs.createWriteStream(outPath);
doc.pipe(stream);
doc.end();
stream.on('finish', () => process.exit(0));
