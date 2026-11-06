// Held-out example C. Not shipped with the task.
const fs = require('fs');
const path = require('path');
const PDFDocument = require('pdfkit');
const ROOT = path.resolve(__dirname, '..', '..');

function GeneratePDF() {
  const doc = new PDFDocument({
    size: 'LETTER',
    layout: 'portrait',
  });

  // Held-out counterpart to sample test_03: the vector graphics API.
  doc.moveTo(60, 80).lineTo(180, 120).lineTo(120, 210).lineTo(60, 80).stroke();
  doc.lineWidth(2.5).lineCap('square').lineJoin('round');
  doc.moveTo(240, 80).bezierCurveTo(270, 40, 320, 130, 360, 90).stroke();
  doc.moveTo(240, 200).quadraticCurveTo(300, 150, 360, 200).stroke();
  doc.rect(60, 260, 90, 55).fill('#336699');
  doc.roundedRect(180, 260, 90, 55, 12).fillAndStroke('#cc9933', '#222222');
  doc.circle(330, 288, 34).stroke();
  doc.ellipse(450, 288, 52, 26).fill('#772255');
  doc.polygon([60, 380], [130, 355], [170, 420], [95, 440]).stroke();
  doc.dash(6, {space: 3, phase: 2});
  doc.moveTo(60, 470).lineTo(520, 470).stroke();
  doc.undash();
  doc.save().translate(300, 500).rotate(-25, {origin: [20, 20]}).scale(1.4).rect(0, 0, 40, 40).stroke().restore();
  doc.transform(1, 0.15, 0, 1, 25, 5);
  doc.rect(120, 520, 60, 60).stroke();
  doc.lineWidth(0.75).miterLimit(8);
  doc.moveTo(420, 520).lineTo(470, 620).lineTo(520, 520).stroke();
  doc.rect(60, 620, 140, 80).clip();
  doc.rect(0, 0, 800, 800).fill('#99ccaa');

  return doc;
}

const outPath = process.argv[2];
if (!outPath) { console.error('usage: node example.js <out.pdf>'); process.exit(2); }

const doc = GeneratePDF();
const stream = fs.createWriteStream(outPath);

doc.pipe(stream);
doc.end();

stream.on('finish', () => process.exit(0));
