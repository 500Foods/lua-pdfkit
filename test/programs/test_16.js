// test_16 — tagged tables: header scopes, the table structure tree and cell attributes
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

  // 1. Tagged directly under the document, with a column-scoped header row.
  doc.fontSize(11).text('Column headers', 72, 60);
  doc.table({
    position: {x: 72, y: 78},
    maxWidth: 400,
    structParent: doc,
    data: [
      [
        {text: 'Region', type: 'TH', scope: 'column'},
        {text: 'Q1', type: 'th', scope: 'Column'},
        {text: 'Q2', type: 'TH', scope: 'COLUMN'},
      ],
      ['North', '1200', '980'],
      ['South', '640', '1710'],
    ],
  });

  // 2. Nested under a structure element, row-scoped headers down the left.
  const sect = doc.struct('Sect');
  docStruct.add(sect);
  doc.fontSize(11).text('Row headers', 72, 200);
  doc.table({
    position: {x: 72, y: 218},
    maxWidth: 400,
    structParent: sect,
    data: [
      [{text: 'North', type: 'TH', scope: 'row'}, '1200', '980'],
      [{text: 'South', type: 'TH', scope: 'row'}, '640', '1710'],
    ],
  });

  // 3. Both scopes at once, plus spans, so a data cell names two headers and the
  //    corner cell is registered once but reachable from either lookup.
  doc.fontSize(11).text('Both scopes', 72, 320);
  doc.table({
    position: {x: 72, y: 338},
    maxWidth: 450,
    structParent: sect,
    data: [
      [
        {text: 'corner', type: 'TH', scope: 'both'},
        {text: 'spans two', type: 'TH', scope: 'column', colSpan: 2},
        {text: 'last', type: 'TH', scope: 'Column'},
      ],
      [{text: 'tall', type: 'TH', scope: 'row', rowSpan: 2}, 'a', 'b', 'c'],
      ['d', 'e', 'f'],
    ],
  });

  // 4. Attributes that only appear when set: background, per-side border colours,
  //    a cell with no border at all, and an explicit id and title.
  doc.addPage();
  doc.fontSize(11).text('Attributes', 72, 60);
  doc.table({
    id: 'attrs',
    position: {x: 72, y: 78},
    maxWidth: 400,
    structParent: doc,
    data: [
      [
        {text: 'filled', backgroundColor: '#ccddee', title: 'a filled cell'},
        {text: 'sides', border: {top: 3, right: 0, bottom: 1, left: 2},
         borderColor: {top: 'red', right: 'green', bottom: 'blue', left: '#123456'}},
      ],
      [
        {text: 'bare', border: 0, id: 'the-bare-one'},
        {text: 'padded', padding: {top: 1, right: 2, bottom: 3, left: 4}},
      ],
    ],
  });

  docStruct.end();

  return doc;
}

// --- Node plumbing ----------------------------------------------------------

// test_16.js -> test_16_js.pdf; the Lua side writes test_16_lua.pdf, so the two
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
