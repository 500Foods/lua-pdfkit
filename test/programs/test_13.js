// test_13 — annotations: links, notes, markup, shapes, attachments and named destinations
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

  doc.fontSize(12);
  doc.text('link here', 50, 50);
  doc.link(50, 50, 100, 20, 'https://example.com');
  doc.note(50, 100, 20, 20, 'a note', {color:'yellow', open:true});
  doc.highlight(50, 150, 80, 14, {color:[255,255,0]});
  doc.underline(50, 200, 80, 14, {color:'red'});
  doc.strike(50, 250, 80, 14);
  doc.lineAnnotation(50, 300, 150, 320, {color:'blue'});
  doc.rectAnnotation(50, 350, 80, 40, {color:'green'});
  doc.ellipseAnnotation(200, 350, 40, 20);
  doc.textAnnotation(50, 420, 100, 30, 'free text', {color:'black'});
  doc.fileAnnotation(50, 470, 20, 20, {name:'x.txt', src:Buffer.from('hello file'), description:'a file'});
  doc.goTo(50, 520, 60, 20, 'dest1');
  doc.addNamedDestination('dest1');
  doc.annotate(50, 560, 40, 40, {Subtype:'Square', Border:[0,0,2]});

  return doc;
}

// --- Node plumbing ----------------------------------------------------------

// test_13.js -> test_13_js.pdf; the Lua side writes test_13_lua.pdf, so the two
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
