// Held-out example F. Not shipped with the task.
const fs = require('fs');
const path = require('path');
const PDFDocument = require('pdfkit');
const ROOT = path.resolve(__dirname, '..', '..');

function GeneratePDF() {
  const doc = new PDFDocument({
    size: 'LETTER',
    layout: 'portrait',
  });

  // Held-out counterpart to sample test_06: the fourteen standard fonts.
  // Same alphabet as the sample, walked in a different order and set at a
  // different size, so the AFM widths feed different arithmetic.
  const NAMES = [
    'ZapfDingbats', 'Symbol',
    'Times-BoldItalic', 'Times-Italic', 'Times-Bold', 'Times-Roman',
    'Helvetica-BoldOblique', 'Helvetica-Oblique', 'Helvetica-Bold', 'Helvetica',
    'Courier-BoldOblique', 'Courier-Oblique', 'Courier-Bold', 'Courier',
  ];

  let y = 30;
  for (const name of NAMES) {
    doc.font(name, 11);
    doc.text(name + '  Wavefront quiz 9876543210', 30, y);
    y = y + 19;
  }

  // A canonical name used twice in a row, and one interleaved switch.
  doc.font('Helvetica-Oblique', 10);
  doc.text('oblique', 30, 320);
  doc.font('Helvetica-Oblique', 10);
  doc.text('oblique again', 110, 320);
  doc.font('Courier-Bold', 10);
  doc.text('courier bold', 220, 320);

  // Kerning pairs. These are all in the Times and Helvetica kern tables, so the
  // show-text array has to break at each of them.
  doc.font('Times-Roman', 18);
  doc.text('Tr Vo We Ya P. F, LY AV', 30, 350);
  doc.font('Helvetica', 18);
  doc.text('Tr Vo We Ya P. F, LY AV', 30, 378);

  // Measured, then boxed to the measured width, so a wrong advance shows up
  // geometrically rather than only in the numbers.
  doc.font('Times-Italic', 15);
  const s = 'an italic line measured against its own metrics';
  const w = doc.widthOfString(s);
  doc.text(s, 30, 410);
  doc.rect(30, 428, w, 3).fill('black');

  // WinAnsi above 0x7F, which is where the standard encoding stops being ASCII.
  doc.font('Times-Roman', 11);
  doc.text('ÄÅÈÏØß ' +
    'âäèîòøúÿ ' +
    '‚„‰‹›•«»',
    30, 450);

  // Symbol and ZapfDingbats carry encodings of their own.
  doc.font('Symbol', 15);
  doc.text('hjklm ABGDE ≠≤∞', 30, 478);
  doc.font('ZapfDingbats', 15);
  doc.text('nopqrst 89:;<', 30, 506);

  // Registered under a caller-chosen name.
  doc.registerFont('Caption', 'Helvetica-Oblique');
  doc.font('Caption', 12);
  doc.text('a registered alias resolving to a standard font', 30, 534);

  // Two columns of the same words in two faces, so the line breaker has to ask
  // two different metric tables where the breaks fall.
  doc.font('Times-Roman', 10);
  doc.text('A column of prose long enough that the line breaker has to make ' +
    'several decisions about where each line ends, set in Times at ten ' +
    'points across a narrow measure.', 30, 564, { width: 220 });
  doc.font('Helvetica', 10);
  doc.text('The identical words again in Helvetica, whose advances differ ' +
    'glyph by glyph, so the breaks land somewhere else entirely.', 280,
    564, { width: 220 });

  // Size set on its own, then a font switch that has to inherit it.
  doc.fontSize(8);
  doc.font('Courier-Oblique');
  doc.text('eight point courier oblique, size set separately', 30, 700);

  return doc;
}

const outPath = process.argv[2];
if (!outPath) { console.error('usage: node example.js <out.pdf>'); process.exit(2); }

const doc = GeneratePDF();
const stream = fs.createWriteStream(outPath);

doc.pipe(stream);
doc.end();

stream.on('finish', () => process.exit(0));
