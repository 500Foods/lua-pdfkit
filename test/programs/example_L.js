// Held-out example L. Not shipped with the task.
const fs = require('fs');
const path = require('path');
const PDFDocument = require('pdfkit');
const ROOT = path.resolve(__dirname, '..', '..');

function GeneratePDF() {
  const doc = new PDFDocument({
    size: 'LETTER',
    layout: 'portrait',
  });

  // Held-out counterpart to sample test_12: embedded TrueType fonts that do
  // carry shaping tables. All nine fonts in the corpus appear, but each plays a
  // different part than it does in the sample -- the font that was measured
  // there is set here, the one supplied as bytes there is registered here -- so
  // the subsets, the width arrays and the ToUnicode maps all come out different.
  const F = ROOT + "/test/assets/fonts/";

  // A plain run in a serif face with a full GPOS table.
  doc.font(F + 'Merriweather-Regular.ttf', 21);
  doc.text('Waltz job vexed 1490', 40, 40);

  // Accents, which is where the composite glyphs live.
  doc.font(F + 'AlegreyaSans-Light.ttf', 19);
  doc.text('ÃÕÑ ãõñ ÏÜŸ ïüÿ ß', 40, 92);

  // Word and character spacing together.
  doc.font(F + 'Alegreya-Bold.ttf', 13);
  doc.text('sphinx of black quartz judge my vow', 40, 132, {
    wordSpacing: 4.5,
    characterSpacing: 0.75,
  });

  // The first font again by the same path -- one embedded object, not two --
  // wrapped so the breaker has to measure repeatedly.
  doc.font(F + 'Merriweather-Regular.ttf', 10);
  doc.text(
    'set again in the face used at the top, across a column narrow enough ' +
      'that almost every word is a candidate break point',
    40, 172, { width: 250 },
  );

  // Justified, which measures with and without the trailing space.
  doc.text(
    'Both paths through the measuring code run when a line is justified ' +
      'rather than merely wrapped.',
    40, 230, { width: 250, align: 'justify' },
  );

  // Supplied as bytes rather than a path.
  const bytes = fs.readFileSync(F + 'Roboto-Medium.ttf');
  doc.font(bytes, 14);
  doc.text('this one arrived as a buffer', 40, 300);

  // Registered under a name of its own.
  doc.registerFont('Slanted', F + 'Roboto-Italic.ttf');
  doc.font('Slanted', 15);
  doc.text('and this one under a name', 40, 332);

  // A standard font, so both kinds coexist in the resource dictionary.
  doc.font('Courier-Bold', 12);
  doc.text('a standard font, monospaced', 40, 366);

  // Well outside Latin-1, which is what stretches the ToUnicode ranges.
  doc.font(F + 'DejaVuSans.ttf', 15);
  doc.text('Ωω Дд «guillemets» — £250 ‰', 40, 398);

  // A sweep wide enough that the width array is long and the bfrange chunking
  // has real work to do. Different span from the sample.
  doc.font(F + 'DejaVuSans.ttf', 8);
  let s = '';
  for (let cp = 0x30; cp < 0x1a0; cp++) { s += String.fromCharCode(cp); }
  doc.text(s, 40, 430, { width: 490 });

  // Measured but drawn at the measured width, so a disagreement about metrics
  // shows up as a rule of the wrong length rather than as nothing at all.
  doc.font(F + 'SourceCodePro-Regular.ttf', 18);
  const w = doc.widthOfString('fixed pitch, still measured');
  doc.rect(40, 560, w, 3).fill('black');
  doc.text('fixed pitch, still measured', 40, 568);

  // Punctuation the breaker splits at but the font never sees as word edges.
  doc.font(F + 'Roboto-Regular.ttf', 11);
  doc.text(
    'hard-wearing, well-thumbed: see also example.org/a/b?x=1&y=2 and ' +
      'half-a-dozen other break points.',
    40, 610, { width: 380 },
  );

  // A second page, so font resources are recorded per page, with one face that
  // appears nowhere before the break.
  doc.addPage();
  doc.font(F + 'Merriweather-Regular.ttf', 18);
  doc.text('carried across the page break', 40, 40);
  doc.font(F + 'DroidSansMono.ttf', 24);
  doc.text('and one that starts here', 40, 80);

  return doc;
}

const outPath = process.argv[2];
if (!outPath) { console.error('usage: node example.js <out.pdf>'); process.exit(2); }

const doc = GeneratePDF();
const stream = fs.createWriteStream(outPath);

doc.pipe(stream);
doc.end();

stream.on('finish', () => process.exit(0));
