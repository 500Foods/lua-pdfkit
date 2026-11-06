// test_03 — the vector graphics API: paths, curves, shapes, dashes, transforms and clipping
//
// Everything inside GeneratePDF() is PDFKit API surface and needs a one-to-one
// Lua equivalent. Everything outside it is Node plumbing — stream handling and
// file naming — and is expected to differ between the two implementations.

const fs = require('fs');
const path = require('path');
const PDFDocument = require('pdfkit');
const ROOT = path.resolve(__dirname, '..', '..');

// --- PDFKit API surface -----------------------------------------------------

function GeneratePDF() {
  const doc = new PDFDocument({
    size: 'LETTER',
    layout: 'portrait',
  });

  doc.moveTo(100,100).lineTo(200,150).lineTo(150,250).stroke();
  doc.lineWidth(3).lineCap('round').lineJoin('bevel');
  doc.moveTo(50,50).bezierCurveTo(80,20,120,80,150,50).stroke();
  doc.moveTo(50,300).quadraticCurveTo(100,250,150,300).stroke();
  doc.rect(200,300,80,40).fill('red');
  doc.roundedRect(300,300,80,40,8).fillAndStroke('blue','black');
  doc.circle(120,400,30).stroke();
  doc.ellipse(220,400,40,20).fill();
  doc.polygon([50,500],[100,480],[140,530]).stroke();
  doc.dash(4, {space:2, phase:1});
  doc.moveTo(50,560).lineTo(400,560).stroke();
  doc.undash();
  doc.save().translate(100,100).rotate(30, {origin:[0,0]}).scale(0.5).rect(0,0,50,50).stroke().restore();
  doc.transform(1,0,0.2,1,10,20);
  doc.rect(300,500,40,40).stroke();
  doc.lineWidth(1).miterLimit(4);
  doc.moveTo(400,100).lineTo(450,200).lineTo(500,100).stroke();
  doc.rect(50,600,100,50).clip();
  doc.rect(0,0,700,700).fill('green');

  return doc;
}

// --- Node plumbing ----------------------------------------------------------

// test_03.js -> test_03_js.pdf; the Lua side writes test_03_lua.pdf, so the two
// never collide if they end up in the same folder.
const outPath = process.argv[2];
if (!outPath) { console.error('usage: node program.js <out.pdf>'); process.exit(2); }

const doc = GeneratePDF();
const stream = fs.createWriteStream(outPath);

doc.pipe(stream);
doc.end();

stream.on('finish', () => {
  console.log(outPath);
});
