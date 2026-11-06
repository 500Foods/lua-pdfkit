// test_04 — colour in every notation PDFKit accepts, plus fill rules, opacity and spot colours
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

  doc.fillColor('red').rect(10,10,50,50).fill();
  doc.fillColor('#ff8800').rect(70,10,50,50).fill();
  doc.fillColor('#f80').rect(130,10,50,50).fill();
  doc.fillColor([255,128,0]).rect(190,10,50,50).fill();
  doc.fillColor([0,100,50,10]).rect(250,10,50,50).fill();
  doc.strokeColor('blue').lineWidth(4).rect(10,80,50,50).stroke();
  doc.fillOpacity(0.5).rect(70,80,50,50).fill('green');
  doc.strokeOpacity(0.25).rect(130,80,50,50).stroke();
  doc.opacity(0.75).rect(190,80,50,50).fill('purple');
  doc.fillColor('black', 0.3).rect(250,80,50,50).fill();
  doc.fillOpacity(1).strokeOpacity(1);
  doc.fillColor('yellow').rect(10,200,50,50).fill();
  doc.fillColor('rebeccapurple').rect(70,200,50,50).fill();
  doc.fillAndStroke('lime','navy');
  doc.addSpotColor('PANTONE-185', 0, 100, 79, 0);
  doc.fillColor('PANTONE-185').rect(10,300,60,60).fill();
  doc.strokeColor('PANTONE-185', 0.6).rect(90,300,60,60).stroke();
  doc.fillOpacity(0.5).rect(200,300,60,60).fill('red');
  doc.fillOpacity(0.5).rect(280,300,60,60).fill('red');

  return doc;
}

// --- Node plumbing ----------------------------------------------------------

// test_04.js -> test_04_js.pdf; the Lua side writes test_04_lua.pdf, so the two
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
