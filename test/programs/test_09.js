// test_09 — linear and radial gradients, including opacity stops and gradient transforms
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


  // two-stop linear
  const g1 = doc.linearGradient(50, 0, 150, 0);
  g1.stop(0, 'red').stop(1, 'blue');
  doc.rect(50, 50, 100, 100).fill(g1);

  // three stops, last before 100% -> closing copy + stitching function
  const g2 = doc.linearGradient(200, 0, 300, 0);
  g2.stop(0, '#00ff00').stop(0.4, '#ffff00').stop(0.8, '#ff00ff');
  doc.rect(200, 50, 100, 100).fill(g2);

  // radial, CMYK
  const g3 = doc.radialGradient(400, 100, 0, 400, 100, 50);
  g3.stop(0, [0,0,0,0]).stop(1, [0,100,100,0]);
  doc.circle(400, 100, 50).fill(g3);

  // opacity stops -> luminosity SMask tower
  const g4 = doc.linearGradient(50, 0, 250, 0);
  g4.stop(0, 'red', 1).stop(0.5, 'yellow', 0.5).stop(1, 'blue', 0);
  doc.rect(50, 200, 200, 100).fill(g4);

  // setTransform
  const g5 = doc.linearGradient(0, 0, 100, 0);
  g5.stop(0, 'black').stop(1, 'white');
  g5.setTransform(2, 0, 0, 2, 300, 200);
  doc.rect(300, 200, 200, 100).fill(g5);

  // same gradient, same ctm -> no re-embed
  doc.rect(50, 320, 100, 40).fill(g1);
  // same gradient, different ctm -> re-embed
  doc.save();
  doc.translate(20, 20);
  doc.rect(50, 380, 100, 40).fill(g1);
  doc.restore();

  // gradient as a stroke colour
  const g6 = doc.linearGradient(50, 0, 250, 0);
  g6.stop(0, 'cyan').stop(1, 'magenta');
  doc.lineWidth(6).rect(300, 320, 150, 60).stroke(g6);

  // gray gradient
  const g7 = doc.linearGradient(50, 0, 150, 0);
  g7.stop(0, [0]).stop(1, [1]);
  doc.rect(50, 440, 100, 40).fill(g7);

  // opacity on a radial, plus a stop out of order
  const g8 = doc.radialGradient(200, 470, 5, 200, 470, 40);
  g8.stop(0, 'white', 0.9).stop(1, 'black', 0.1);
  doc.circle(200, 470, 40).fill(g8);

  // tiling patterns
  const p1 = doc.pattern([1,1,4,4], 3, 3, '1 w 0 1 m 4 5 l s 2 0 m 5 3 l s');
  doc.rect(50, 520, 100, 60).fill([p1, 'blue']);
  doc.rect(200, 520, 100, 60).fill([p1, [0,100,100,0]]);
  const p2 = doc.pattern([1,1,7,7], 6, 6, '1 w 0 1 m 7 8 l s 5 0 m 8 3 l s');
  doc.lineWidth(4).rect(350, 520, 100, 60).stroke([p2, 'green']);

  // second page: same gradient and pattern again
  doc.addPage();
  doc.rect(50, 50, 100, 100).fill(g1);
  doc.rect(200, 50, 100, 60).fill([p1, 'red']);

  // a gradient created after the page break
  const g9 = doc.linearGradient(50, 0, 250, 0);
  g9.stop(0, 'orange').stop(0.5, 'navy', 0.25).stop(1, 'orange');
  doc.rect(50, 200, 200, 80).fill(g9);


  return doc;
}

// --- Node plumbing ----------------------------------------------------------

// test_09.js -> test_09_js.pdf; the Lua side writes test_09_lua.pdf, so the two
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
