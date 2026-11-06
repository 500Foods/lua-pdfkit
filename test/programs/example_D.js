// Held-out example D. Not shipped with the task.
const fs = require('fs');
const path = require('path');
const PDFDocument = require('pdfkit');
const ROOT = path.resolve(__dirname, '..', '..');

function GeneratePDF() {
  const doc = new PDFDocument({
    size: 'LETTER',
    layout: 'portrait',
  });

  // Held-out counterpart to sample test_04: colour notation, opacity, spot colour.
  doc.fillColor('teal').rect(20, 20, 60, 40).fill();
  doc.fillColor('#1188cc').rect(100, 20, 60, 40).fill();
  doc.fillColor('#3c9').rect(180, 20, 60, 40).fill();
  doc.fillColor([12, 200, 90]).rect(260, 20, 60, 40).fill();
  doc.fillColor([40, 0, 60, 20]).rect(340, 20, 60, 40).fill();
  doc.strokeColor('crimson').lineWidth(3).rect(20, 90, 60, 40).stroke();
  doc.fillOpacity(0.35).rect(100, 90, 60, 40).fill('orange');
  doc.strokeOpacity(0.6).rect(180, 90, 60, 40).stroke();
  doc.opacity(0.45).rect(260, 90, 60, 40).fill('#204080');
  doc.fillColor('darkslategray', 0.8).rect(340, 90, 60, 40).fill();
  doc.fillOpacity(1).strokeOpacity(1);
  doc.fillColor('gold').rect(20, 160, 60, 40).fill();
  doc.fillColor('rebeccapurple').rect(100, 160, 60, 40).fill();
  doc.fillAndStroke('aquamarine', 'maroon');
  doc.addSpotColor('PANTONE-032', 0, 90, 86, 0);
  doc.fillColor('PANTONE-032').rect(20, 230, 70, 70).fill();
  doc.strokeColor('PANTONE-032', 0.4).rect(110, 230, 70, 70).stroke();
  doc.fillOpacity(0.35).rect(220, 230, 70, 70).fill('teal');
  doc.fillOpacity(0.35).rect(310, 230, 70, 70).fill('teal');

  return doc;
}

const outPath = process.argv[2];
if (!outPath) { console.error('usage: node example.js <out.pdf>'); process.exit(2); }

const doc = GeneratePDF();
const stream = fs.createWriteStream(outPath);

doc.pipe(stream);
doc.end();

stream.on('finish', () => process.exit(0));
