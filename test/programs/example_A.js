// Held-out example A. Not shipped with the task.
const fs = require('fs');
const path = require('path');
const PDFDocument = require('pdfkit');
const ROOT = path.resolve(__dirname, '..', '..');

function GeneratePDF() {
  const doc = new PDFDocument({
    size: 'LETTER',
    layout: 'portrait',
  });

  // Held-out counterpart to sample test_01: measured text placement.
  doc.fontSize(24);

  const title = 'the quick brown fox';
  const width = doc.page.width - doc.page.margins.left - doc.page.margins.right;

  // Right-aligned in the margin box, placed a third of the way down rather than
  // centred, so the measured height feeds a different arithmetic than the sample.
  const height = doc.heightOfString(title, { width: width, align: 'right' });
  const y = (doc.page.height - height) / 3;
  doc.text(title, doc.page.margins.left, y, { width: width, align: 'right' });

  // A wrapped block centred in a narrower column, measured the same way.
  doc.fontSize(11);
  const para = 'A paragraph set in a column narrower than the margin box, so the ' +
    'line breaker has to wrap it several times before the measured height ' +
    'means anything.';
  const ph = doc.heightOfString(para, { width: 240, align: 'center' });
  doc.text(para, doc.page.margins.left, y + height + 36, { width: 240, align: 'center' });

  // And the same string again, left-aligned, directly below the measured block.
  doc.text(para, doc.page.margins.left, y + height + 36 + ph + 18, { width: 240 });

  // A block long enough to run off the bottom of the page, so the wrapper has to
  // open the second page by itself rather than being told to.
  // Set off the page's black so the break has a fill colour to carry over: the
  // colour lives in the content stream, so page two has to restate it.
  doc.fillColor('#334455').fontSize(10);
  const long = (
    'This sentence repeats until the block is taller than the page it starts ' +
    'on, which forces the line wrapper to break to a new page on its own. '
  ).repeat(12);
  doc.text(long, doc.page.margins.left, 560, { width: 400, align: 'justify' });

  // And one line asked for below the bottom margin, which has to move to a fresh
  // page before it emits anything at all.
  doc.fillColor('black').fontSize(12);
  doc.text('asked for past the bottom margin', doc.page.margins.left, 750);

  return doc;
}

const outPath = process.argv[2];
if (!outPath) { console.error('usage: node example.js <out.pdf>'); process.exit(2); }

const doc = GeneratePDF();
const stream = fs.createWriteStream(outPath);

doc.pipe(stream);
doc.end();

stream.on('finish', () => process.exit(0));
