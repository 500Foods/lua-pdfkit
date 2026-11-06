// test_12 — embedded TrueType fonts that do carry shaping tables (GSUB, GPOS, kern)
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

  // Embedded TrueType fonts: subsetting, layout, widths and the ToUnicode map.
  const F = ROOT + "/test/assets/fonts/";

  // A plain run, in the font's own metrics. Every glyph here is simple.
  doc.font(F + 'Roboto-Regular.ttf', 24);
  doc.text('Hamburgefonstiv 0123456789', 50, 50);

  // Accented text, which is where the composite glyphs live -- these are the
  // glyphs the subset has to renumber.
  doc.font(F + 'Roboto-Italic.ttf', 18);
  doc.text('ÀÇÉÑÖÜ àáçéíñöü', 50, 100);

  // Word spacing, which encodes each word separately and folds the extra space
  // into the last glyph's advance.
  doc.font(F + 'Roboto-Medium.ttf', 14);
  doc.text('the quick brown fox jumps over the lazy dog', 50, 140, {
    wordSpacing: 6,
    characterSpacing: 0.5,
  });

  // A second run in a font already loaded: the cache is keyed by path, so this
  // must reuse the object rather than embedding twice.
  doc.font(F + 'Roboto-Regular.ttf', 11);
  doc.text(
    'reused, and wrapped across a measured width so the line breaker has to ' +
      'ask this font how wide each word is many times over',
    50,
    180,
    { width: 300 },
  );

  // Justified, which measures with and without the trailing space.
  doc.text(
    'Justification asks for the width of the stripped line and of a single ' +
      'space, so both paths through widthOfString run here.',
    50,
    240,
    { width: 300, align: 'justify' },
  );

  // A font supplied as bytes rather than a path.
  const bytes = fs.readFileSync(F + 'SourceCodePro-Regular.ttf');
  doc.font(bytes, 12);
  doc.text('bytes not a path -- monospaced', 50, 320);

  // Explicit registration, then use by the registered name.
  doc.registerFont('Body', F + 'Merriweather-Regular.ttf');
  doc.font('Body', 13);
  doc.text('registered under a name of its own', 50, 350);

  // Back to a standard font, so both kinds coexist in one resource dictionary.
  doc.font('Helvetica', 12);
  doc.text('and a standard font alongside', 50, 380);

  // Characters outside Latin-1, exercising the ToUnicode ranges.
  doc.font(F + 'DejaVuSans.ttf', 16);
  doc.text('Αα Аа ‘quoted’ – €100', 50, 410);

  // A wide sweep of code points, to make the subset large and the width array
  // long. Not quite 256 glyphs, but the bfrange chunking arithmetic runs either
  // way and the loca offsets get big enough to matter.
  doc.font(F + 'DejaVuSans.ttf', 9);
  let s = '';
  for (let cp = 0x21; cp < 0x180; cp++) {
    s += String.fromCharCode(cp);
  }
  doc.text(s, 50, 450, { width: 500 });

  // Measurement without drawing. widthOfString still pulls glyphs into the
  // subset, so what it measures ends up embedded whether or not it is painted --
  // the rule below is drawn at the measured width to prove both sides agree.
  doc.font(F + 'Alegreya-Bold.ttf', 20);
  const w = doc.widthOfString('sample text, measured');
  doc.rect(50, 600, w, 4).fill('black');
  doc.text('sample text, measured', 50, 610);

  // A hyphenated / punctuated run, which the line breaker splits at points the
  // font never sees as words.
  doc.font(F + 'DroidSansMono.ttf', 15);
  doc.text(
    'well-known break-points: co-operate, e-mail, and a URL like ' +
      'example.com/path?q=1&r=2 all split differently.',
    50,
    650,
    { width: 400 },
  );

  // A second page, so the font resources have to be recorded per page.
  doc.addPage();
  doc.font(F + 'Roboto-Regular.ttf', 20);
  doc.text('second page, same fonts', 50, 50);
  doc.font(F + 'AlegreyaSans-Light.ttf', 20);
  doc.text('and one that appears only here', 50, 90);

  return doc;
}

// --- Node plumbing ----------------------------------------------------------

// test_12.js -> test_12_js.pdf; the Lua side writes test_12_lua.pdf, so the two
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
