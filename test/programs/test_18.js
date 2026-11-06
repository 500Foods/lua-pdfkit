// test_18 — outlines: nested bookmarks, expanded, page index, XYZ destinations
const fs = require('fs');
const path = require('path');
const PDFDocument = require('pdfkit');
const ROOT = path.resolve(__dirname, '..', '..');

function GeneratePDF() {
  const doc = new PDFDocument({
    size: 'LETTER',
    layout: 'portrait',
  });

  doc.fontSize(16);
  doc.text('Page one', 72, 72);
  doc.addPage();
  doc.text('Page two', 72, 72);
  doc.addPage();
  doc.text('Page three', 72, 72);

  const outline = doc.outline;
  const top = outline.addItem('Top Level', { expanded: true });
  top.addItem('Sub-section');
  top.addItem('Nested closed', { expanded: false });

  outline.addItem('Chapter 1', { pageNumber: 0 });
  outline.addItem('Chapter 2', { pageNumber: 1 });
  outline.addItem('Chapter 3', { pageNumber: 2, expanded: true });

  outline.addItem('Section 1', {
    fit: false,
    top: 0,
    left: 0,
    zoom: 1.5,
  });
  outline.addItem('Section 2', {
    pageNumber: 1,
    fit: false,
    top: 100,
    left: 36,
    zoom: 0,
  });

  const quoted = outline.addItem('Quotes "and" parens (here)');
  quoted.addItem('Child of quoted', { pageNumber: 2, fit: true });

  return doc;
}

const outPath = process.argv[2];
if (!outPath) { console.error('usage: node program.js <out.pdf>'); process.exit(2); }

const doc = GeneratePDF();
const stream = fs.createWriteStream(outPath);
doc.pipe(stream);
doc.end();
stream.on('finish', () => process.exit(0));
