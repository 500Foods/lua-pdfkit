// Held-out example P. Not shipped with the task.
const fs = require('fs');
const path = require('path');
const PDFDocument = require('pdfkit');
const ROOT = path.resolve(__dirname, '..', '..');

function GeneratePDF() {
  const doc = new PDFDocument({
    size: 'LETTER',
    layout: 'portrait',
    pdfVersion: '1.7',
    tagged: true,
    displayTitle: true,
  });

  // Held-out counterpart to sample test_16: tagged tables. Header scopes in
  // both directions and in mixed case, spans that make one header serve several
  // cells, tables parented at three different depths, and the cell attributes
  // that are only written when they are set.

  doc.info.Title = 'Held-out tagged tables';
  doc.info.Lang = 'en-GB';

  const docStruct = doc.struct('Document');
  doc.addStructure(docStruct);

  // 1. Parented on the document, headers down the left. Scope spelled in a
  //    different case on each row, which must normalise to the same thing.
  doc.fontSize(10).text('Row headers', 60, 50);
  doc.table({
    position: {x: 60, y: 66},
    maxWidth: 420,
    structParent: doc,
    data: [
      [{text: 'Depot', type: 'TH', scope: 'ROW'}, '18', '24', '7'],
      [{text: 'Yard', type: 'th', scope: 'row'}, '31', '3', '29'],
      [{text: 'Wharf', type: 'TH', scope: 'Row'}, '12', '40', '16'],
    ],
  });

  // 2. Parented on a section, headers along the top instead.
  const sect = doc.struct('Sect', {title:'Tables'});
  docStruct.add(sect);
  doc.fontSize(10).text('Column headers', 60, 170);
  doc.table({
    position: {x: 60, y: 186},
    maxWidth: 420,
    structParent: sect,
    data: [
      [
        {text: 'Site', type: 'TH', scope: 'column'},
        {text: 'Mon', type: 'th', scope: 'COLUMN'},
        {text: 'Tue', type: 'TH', scope: 'Column'},
      ],
      ['Depot', '18', '24'],
      ['Yard', '31', '3'],
    ],
  });

  // 3. Parented two levels down, on a subsection of that section.
  const sub = doc.struct('Sect', {title:'A nested one'});
  sect.add(sub);
  doc.fontSize(10).text('Nested deeper', 60, 290);
  doc.table({
    position: {x: 60, y: 306},
    maxWidth: 300,
    structParent: sub,
    data: [
      [{text: 'Key', type: 'TH', scope: 'Column'}, {text: 'Value', type: 'TH', scope: 'Column'}],
      ['alpha', '1'],
      ['beta', '2'],
    ],
  });

  // 4. Both scopes at once with spans, so one header covers several data cells
  //    and the corner cell is reachable from either direction.
  doc.fontSize(10).text('Corner and spans', 60, 400);
  doc.table({
    position: {x: 60, y: 416},
    maxWidth: 460,
    structParent: sect,
    data: [
      [
        {text: 'corner', type: 'TH', scope: 'Both'},
        {text: 'first half', type: 'TH', scope: 'column', colSpan: 2},
        {text: 'second half', type: 'TH', scope: 'COLUMN', colSpan: 2},
      ],
      [{text: 'spans three', type: 'TH', scope: 'row', rowSpan: 3}, 'a', 'b', 'c', 'd'],
      ['e', 'f', 'g', 'h'],
      ['i', 'j', 'k', 'l'],
      [{text: 'plain', type: 'TH', scope: 'ROW'}, 'm', 'n', 'o', 'p'],
    ],
  });

  // 5. The attributes that only appear once they are set, on a table with an id
  //    of its own, after a page break so the parent tree keys on two pages.
  doc.addPage();
  doc.fontSize(10).text('Attributes', 60, 50);
  doc.table({
    id: 'held-out-attrs',
    position: {x: 60, y: 66},
    maxWidth: 430,
    structParent: doc,
    data: [
      [
        {text: 'tinted', backgroundColor: '#ffeecc', title: 'a tinted cell'},
        {text: 'four sides, four colours', border: {top: 1, right: 4, bottom: 2, left: 3},
         borderColor: {top: '#654321', right: 'red', bottom: 'blue', left: 'green'}},
      ],
      [
        {text: 'no edges', border: 0, id: 'no-edges'},
        {text: 'inset', padding: {top: 6, right: 1, bottom: 2, left: 9}, title: 'a padded cell'},
      ],
      [
        {text: 'header with an id', type: 'TH', scope: 'Column', id: 'the-header'},
        {text: 'ordinary'},
      ],
    ],
  });

  docStruct.end();

  return doc;
}

const outPath = process.argv[2];
if (!outPath) { console.error('usage: node example.js <out.pdf>'); process.exit(2); }

const doc = GeneratePDF();
const stream = fs.createWriteStream(outPath);

doc.pipe(stream);
doc.end();

stream.on('finish', () => process.exit(0));
