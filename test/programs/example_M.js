// Held-out example M. Not shipped with the task.
const fs = require('fs');
const path = require('path');
const PDFDocument = require('pdfkit');
const ROOT = path.resolve(__dirname, '..', '..');

function GeneratePDF() {
  const doc = new PDFDocument({
    size: 'LETTER',
    layout: 'portrait',
  });

  // Held-out counterpart to sample test_13: every annotation kind PDFKit can
  // emit, plus named destinations and a hand-built annotation dictionary. The
  // geometry, the colours and the contents all differ from the sample, and a
  // second page is added so the per-page annotation arrays have to be kept
  // apart rather than accumulated into one.

  doc.fontSize(14);
  doc.text('a link on the first page', 45, 45);
  doc.link(45, 45, 150, 22, 'https://github.com/foliojs/pdfkit');

  // Colours given three different ways: by name, as an RGB triple, and omitted.
  doc.note(45, 90, 24, 24, 'a longer note, with punctuation.', {color:'#33aaff', open:false});
  doc.highlight(45, 140, 120, 16, {color:[0, 255, 128]});
  doc.underline(45, 185, 120, 16, {color:'blue'});
  doc.strike(45, 230, 120, 16, {color:[128, 0, 0]});

  // The shape annotations, drawn at sizes the sample does not use.
  doc.lineAnnotation(45, 280, 220, 262, {color:'#ff6600'});
  doc.rectAnnotation(45, 320, 110, 55, {color:'purple'});
  doc.ellipseAnnotation(240, 320, 55, 28, {color:'teal'});

  // Free text, and a file with contents of its own.
  doc.textAnnotation(45, 400, 160, 40, 'free text, second sample', {color:'#404040'});
  doc.fileAnnotation(45, 460, 24, 24, {
    name: 'notes.md',
    src: Buffer.from('# heading\n\nattached bytes, not the sample\'s.\n'),
    description: 'an attached markdown file',
  });

  // Two named destinations and a jump to the one defined later, so the name
  // tree has more than a single entry to sort.
  doc.goTo(45, 510, 80, 24, 'second');
  doc.addNamedDestination('first');

  // A dictionary built by hand, with keys the helpers never emit.
  doc.annotate(45, 560, 60, 60, {Subtype:'Square', Border:[0, 0, 4], IC:[0.9, 0.9, 0.2]});

  // Page two: the destination jumped to above, and annotations that must land
  // in this page's array rather than the first page's.
  doc.addPage();
  doc.fontSize(14);
  doc.text('the landing page', 45, 45);
  doc.addNamedDestination('second');
  doc.link(45, 45, 130, 22, 'https://pdfkit.org/docs/annotations.html');
  doc.goTo(45, 90, 80, 24, 'first');
  doc.highlight(45, 140, 90, 16, {color:'yellow'});
  doc.annotate(45, 190, 50, 50, {Subtype:'Circle', Border:[0, 0, 1], C:[0, 0.4, 1]});

  return doc;
}

const outPath = process.argv[2];
if (!outPath) { console.error('usage: node example.js <out.pdf>'); process.exit(2); }

const doc = GeneratePDF();
const stream = fs.createWriteStream(outPath);

doc.pipe(stream);
doc.end();

stream.on('finish', () => process.exit(0));
