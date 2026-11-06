// Held-out example R. Outlines, different pages and destinations from test_18.
const fs = require('fs');
const path = require('path');
const PDFDocument = require('pdfkit');
const ROOT = path.resolve(__dirname, '..', '..');

function GeneratePDF() {
  const doc = new PDFDocument({
    size: [400, 600],
    margin: 30,
  });

  doc.fontSize(14);
  doc.text('alpha', 30, 40);
  doc.addPage({ size: [500, 700], margin: 20 });
  doc.text('beta', 20, 30);
  doc.addPage();
  doc.text('gamma', 20, 30);

  const outline = doc.outline;
  const book = outline.addItem('Book', { expanded: true });
  const part = book.addItem('Part I', { expanded: true, pageNumber: 0 });
  part.addItem('Opening', { fit: false, top: 40, left: 10, zoom: 2 });
  part.addItem('Middle', { pageNumber: 1, fit: false, top: 80, left: 0, zoom: 1 });
  book.addItem('Part II', { pageNumber: 2 });

  outline.addItem('Wide page', {
    pageNumber: 1,
    fit: true,
    expanded: false,
  });

  const marks = outline.addItem('Marks: é — #1');
  marks.addItem('Back to alpha', { pageNumber: 0 });
  const deep = marks.addItem('Deep', { expanded: true });
  deep.addItem('Deeper', { pageNumber: 2, fit: false, top: 12, left: 8, zoom: 0.5 });

  return doc;
}

const outPath = process.argv[2];
if (!outPath) { console.error('usage: node example.js <out.pdf>'); process.exit(2); }

const doc = GeneratePDF();
const stream = fs.createWriteStream(outPath);
doc.pipe(stream);
doc.end();
stream.on('finish', () => process.exit(0));
