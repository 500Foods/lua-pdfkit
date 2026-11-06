// Held-out example E. Not shipped with the task.
const fs = require('fs');
const path = require('path');
const PDFDocument = require('pdfkit');
const ROOT = path.resolve(__dirname, '..', '..');

function GeneratePDF() {
  const doc = new PDFDocument({
    size: 'LETTER',
    layout: 'portrait',
  });

  // Held-out counterpart to sample test_05: SVG path data, absolute and relative.
  doc.path('M 20 20 L 120 20 L 120 90 Z').stroke();
  doc.path('m 20 110 l 100 0 l 0 70 z').stroke();
  doc.path('M 20 220 C 50 190 90 250 120 220 S 190 190 220 220').stroke();
  doc.path('M 20 290 Q 70 250 120 290 T 220 290').stroke();
  doc.path('M 20 340 H 220 V 390 h -120 v 30').stroke();
  doc.path('M 120 440 A 60 35 0 0 1 220 440 a 60 35 0 1 0 -100 0').stroke();
  doc.path('M 270 440 A 45 25 30 1 1 370 470').stroke();
  doc.path('M15,540L65,540 65,590 15,590Z').fill();
  doc.path('M 420 90 A 0 25 0 0 1 470 90').stroke();
  doc.path('M 420 190 A 35 35 0 0 1 420 190').stroke();
  doc.path('M 20 640 c 12 -12 24 -12 36 0 s 24 12 36 0 t 12 12').stroke();
  doc.path('M 120 640 A 25 25 0 0125 120 640').stroke();
  doc.path('M6 6l2e1 3E1 .25.25 -.25-.25').stroke();

  return doc;
}

const outPath = process.argv[2];
if (!outPath) { console.error('usage: node example.js <out.pdf>'); process.exit(2); }

const doc = GeneratePDF();
const stream = fs.createWriteStream(outPath);

doc.pipe(stream);
doc.end();

stream.on('finish', () => process.exit(0));
