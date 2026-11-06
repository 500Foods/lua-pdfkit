// test_06 — the fourteen standard fonts, their AFM metrics and their kerning
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

  // The standard 14 fonts: every one of them, by name, plus the AFM metrics and
  // kerning that come with them. Nothing here is embedded — these fonts live in
  // the viewer, so the PDF carries only widths and a name.
  const NAMES = [
    'Courier', 'Courier-Bold', 'Courier-Oblique', 'Courier-BoldOblique',
    'Helvetica', 'Helvetica-Bold', 'Helvetica-Oblique', 'Helvetica-BoldOblique',
    'Times-Roman', 'Times-Bold', 'Times-Italic', 'Times-BoldItalic',
    'Symbol', 'ZapfDingbats',
  ];

  let y = 40;
  for (const name of NAMES) {
    doc.font(name, 13);
    doc.text(name + '  Hamburgefonstiv 0123456789', 40, y);
    y = y + 22;
  }

  // The PostScript aliases PDFKit accepts alongside the canonical names.
  doc.font('Times-Roman', 12);
  doc.text('aliases', 40, 360);
  doc.font('Courier-BoldOblique', 12);
  doc.text('Courier-BoldOblique', 120, 360);

  // Kerning. Times has a large kern table and these pairs are all in it, so the
  // emitted show-text array has to be split at every one of them.
  doc.font('Times-Roman', 20);
  doc.text('AWAY Yo To Wa P, V. LT', 40, 390);
  doc.font('Helvetica', 20);
  doc.text('AWAY Yo To Wa P, V. LT', 40, 420);

  // The same string measured, then underscored to the measured width, so a wrong
  // width shows up as a visible mismatch rather than only in the metrics.
  doc.font('Times-Bold', 16);
  const s = 'measured against its own metrics';
  const w = doc.widthOfString(s);
  doc.text(s, 40, 460);
  doc.rect(40, 480, w, 2).fill('black');

  // WinAnsi high characters, which is where the standard fonts' encoding table
  // stops being ASCII.
  doc.font('Helvetica', 12);
  doc.text('ÀÇÉÑÖÜ ' +
    'àáçéíñöü ' +
    '‘’“”–—†‡…',
    40, 500);

  // Symbol and ZapfDingbats have encodings of their own rather than WinAnsi.
  doc.font('Symbol', 16);
  doc.text('abgdez QWFY ∑√∫', 40, 530);
  doc.font('ZapfDingbats', 16);
  doc.text('abcdefgh 34567', 40, 560);

  // Registered under a name of the caller's choosing.
  doc.registerFont('Body', 'Times-Italic');
  doc.font('Body', 14);
  doc.text('registered alias for a standard font', 40, 590);

  // Switching back and forth inside one wrapped paragraph, so the line breaker
  // has to ask two different fonts for widths.
  doc.font('Helvetica', 11);
  doc.text('A paragraph long enough to wrap several times, laid out in ' +
    'Helvetica at eleven points across a measured column so that the line ' +
    'breaker has real work to do here.', 40, 620, { width: 240 });
  doc.font('Times-Roman', 11);
  doc.text('The same words again in Times, which has different widths for ' +
    'every glyph, so the breaks land in different places.', 300, 620,
    { width: 240 });

  // fontSize independent of font, and the size sticking across a font switch.
  doc.fontSize(9);
  doc.font('Courier');
  doc.text('nine point courier, size set separately', 40, 720);

  return doc;
}

// --- Node plumbing ----------------------------------------------------------

// test_06.js -> test_06_js.pdf; the Lua side writes test_06_lua.pdf, so the two
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
