// test_11 — an embedded TrueType font with no shaping tables: subsetting, widths, ToUnicode
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

  // The embedded-font pipeline on its own: Droid Sans Mono is the one font in the corpus
  // with no GSUB, GPOS, kern or morx, so nothing here depends on shaping.
  const F = ROOT + "/test/assets/fonts/";

  doc.font(F + 'DroidSansMono.ttf', 24);
  doc.text('Hamburgefonstiv 0123456789', 50, 50);

  doc.font(F + 'DroidSansMono.ttf', 18);
  doc.text('ÀÇÉÑÖÜ àáçéíñöü', 50, 100);

  doc.font(F + 'DroidSansMono.ttf', 14);
  doc.text('the quick brown fox jumps over the lazy dog', 50, 140, {
    wordSpacing: 6,
    characterSpacing: 0.5,
  });

  doc.font(F + 'DroidSansMono.ttf', 11);
  doc.text(
    'reused, and wrapped across a measured width so the line breaker has to ' +
      'ask this font how wide each word is many times over',
    50, 180, { width: 300 },
  );

  doc.text(
    'Justification asks for the width of the stripped line and of a single ' +
      'space, so both paths through widthOfString run here.',
    50, 240, { width: 300, align: 'justify' },
  );

  const bytes = fs.readFileSync(F + 'DroidSansMono.ttf');
  doc.font(bytes, 12);
  doc.text('bytes not a path', 50, 320);

  doc.registerFont('Body', F + 'DroidSansMono.ttf');
  doc.font('Body', 13);
  doc.text('registered under a name of its own', 50, 350);

  doc.font('Helvetica', 12);
  doc.text('and a standard font alongside', 50, 380);

  doc.font(F + 'DroidSansMono.ttf', 9);
  let s = '';
  for (let cp = 0x21; cp < 0x180; cp++) { s += String.fromCharCode(cp); }
  doc.text(s, 50, 450, { width: 500 });

  doc.font(F + 'DroidSansMono.ttf', 20);
  const w = doc.widthOfString('sample text, measured');
  doc.rect(50, 600, w, 4).fill('black');
  doc.text('sample text, measured', 50, 610);

  doc.addPage();
  doc.font(F + 'DroidSansMono.ttf', 20);
  doc.text('second page, same font', 50, 50);

  return doc;
}

// --- Node plumbing ----------------------------------------------------------

// test_11.js -> test_11_js.pdf; the Lua side writes test_11_lua.pdf, so the two
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
