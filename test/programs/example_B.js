// Held-out example B. Not shipped with the task.
const fs = require('fs');
const path = require('path');
const PDFDocument = require('pdfkit');
const ROOT = path.resolve(__dirname, '..', '..');

function GeneratePDF() {
  const doc = new PDFDocument({
    size: 'LETTER',
    layout: 'portrait',
    bufferPages: true,
    pdfVersion: '1.7ext3',
  });

  // Held-out counterpart to sample test_02: page geometry, revisiting, info dict.
  doc.info.Title = 'Held out';
  doc.info.Author = 'verifier';
  doc.info.Subject = 'geometry';
  doc.info.Keywords = 'x,y,z';
  doc.text('first', 40, 40);
  doc.addPage({size: 'LEGAL', layout: 'portrait', margin: 36});
  doc.text('second', 40, 40);
  doc.addPage({size: [400, 250], margins: {top: 15, bottom: 25, left: 35, right: 45}});
  doc.text('third', 40, 40);
  doc.addPage({size: 'A4', layout: 'landscape'});
  doc.text('fourth', 40, 40);
  doc.switchToPage(1);
  doc.text('back on 2', 40, 90);
  doc.switchToPage(0);
  doc.text('back on 1', 40, 90);
  const r = doc.bufferedPageRange();
  doc.text('range ' + r.start + ' ' + r.count, 40, 140);

  return doc;
}

const outPath = process.argv[2];
if (!outPath) { console.error('usage: node example.js <out.pdf>'); process.exit(2); }

const doc = GeneratePDF();
const stream = fs.createWriteStream(outPath);

doc.pipe(stream);
doc.end();

stream.on('finish', () => process.exit(0));
