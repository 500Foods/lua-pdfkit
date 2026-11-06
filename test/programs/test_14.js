// test_14 — a tagged PDF: the structure tree, marked content, artifacts and the parent tree
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
    pdfVersion: '1.7',
    tagged: true,
    displayTitle: true,
  });

  doc.info.Title = 'Tagged sample';
  doc.info.Lang = 'en-US';

  const docStruct = doc.struct('Document');
  doc.addStructure(docStruct);

  const h1 = doc.struct('H1', {title:'Heading one', lang:'en-US'}, () => {
    doc.fontSize(20).text('The Heading', 72, 72);
  });
  docStruct.add(h1);

  const p1 = doc.struct('P', () => {
    doc.fontSize(12).text('First paragraph of body copy, long enough to wrap onto a second line so the marked content spans more than one show-text operator.', 72, 110, {width:400});
  });
  docStruct.add(p1);

  const list = doc.struct('L');
  for (let i = 1; i <= 3; i++) {
    const li = doc.struct('LI');
    li.add(doc.struct('Lbl', () => { doc.text(String(i) + '.', 72, 170 + i*16); }));
    li.add(doc.struct('LBody', {alt:'item ' + i}, () => { doc.text('Item number ' + i, 92, 170 + i*16); }));
    list.add(li);
  }
  docStruct.add(list);

  const fig = doc.struct('Figure', {alt:'A bee', bbox:[72, 240, 172, 340], placement:'Block'}, () => {
    doc.image(ROOT + "/test/assets/images/bee.png", 72, 240, {width:100});
  });
  docStruct.add(fig);

  doc.markContent('Artifact');
  doc.rect(72, 360, 200, 2).fill('black');
  doc.endMarkedContent();

  const cell = doc.struct('TD', {scope:'Column'}, () => { doc.text('cell', 72, 380); });
  docStruct.add(cell);

  docStruct.end();

  return doc;
}

// --- Node plumbing ----------------------------------------------------------

// test_14.js -> test_14_js.pdf; the Lua side writes test_14_lua.pdf, so the two
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
