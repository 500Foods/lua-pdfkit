// Held-out example K. Not shipped with the task.
const fs = require('fs');
const path = require('path');
const PDFDocument = require('pdfkit');
const ROOT = path.resolve(__dirname, '..', '..');

function GeneratePDF() {
  const doc = new PDFDocument({
    size: 'LETTER',
    layout: 'portrait',
  });

  // Held-out counterpart to sample test_11: the embedded-font pipeline with no
  // shaping to hide behind. Droid Sans Mono is the one font in the corpus carrying no
  // GSUB, GPOS, kern or morx table, so every advance here comes straight from
  // hmtx and every glyph id straight from cmap. Subsetting, the width array and
  // the ToUnicode map are what is actually under test.
  const F = ROOT + "/test/assets/fonts/";

  // A plain run at a size the sample does not use.
  doc.font(F + 'DroidSansMono.ttf', 30);
  doc.text('Quartz glyph vext 5678', 40, 40);

  // Accented characters, which is where the composite glyphs are -- the ones
  // whose component glyph ids have to be renumbered by the subsetter.
  doc.font(F + 'DroidSansMono.ttf', 21);
  doc.text('ÂÊÎÔÛ âêîôû ÆØÅ æøå', 40, 96);

  // Both spacing knobs at once, which splits the run into separately positioned
  // pieces and folds the slack into each advance.
  doc.font(F + 'DroidSansMono.ttf', 13);
  doc.text('pack my box with five dozen liquor jugs', 40, 136, {
    wordSpacing: 3.5,
    characterSpacing: 1.25,
  });

  // The same font again by the same path: this must reuse the embedded object
  // rather than subset it twice. Wrapped, so the line breaker measures often.
  doc.font(F + 'DroidSansMono.ttf', 10);
  doc.text(
    'measured across a narrow column, which makes the breaker ask this font ' +
      'for the width of every candidate word more than once',
    40, 178, { width: 240 },
  );

  // Justified, which measures the stripped line and a lone space separately.
  doc.text(
    'Justifying needs the width of the line without its trailing space and ' +
      'the width of that space on its own.',
    40, 236, { width: 240, align: 'justify' },
  );

  // The font handed over as bytes rather than as a path.
  const bytes = fs.readFileSync(F + 'DroidSansMono.ttf');
  doc.font(bytes, 15);
  doc.text('handed over as a buffer', 40, 310);

  // Registered under a name, then used by that name.
  doc.registerFont('Display', F + 'DroidSansMono.ttf');
  doc.font('Display', 17);
  doc.text('reached through a registered name', 40, 342);

  // A standard font alongside, so both kinds share one resource dictionary.
  doc.font('Times-Roman', 13);
  doc.text('a standard font in the same document', 40, 378);

  // A sweep wide enough to make the subset large and the ToUnicode ranges
  // non-trivial. Different span from the sample, so the subset differs too.
  doc.font(F + 'DroidSansMono.ttf', 8);
  let s = '';
  for (let cp = 0x2a; cp < 0x150; cp++) { s += String.fromCharCode(cp); }
  doc.text(s, 40, 420, { width: 480 });

  // Measuring without drawing still pulls glyphs into the subset, so the rule
  // below has to come out the same length in both implementations.
  doc.font(F + 'DroidSansMono.ttf', 26);
  const w = doc.widthOfString('measure me twice');
  doc.rect(40, 560, w, 3).fill('black');
  doc.text('measure me twice', 40, 568);

  // Height as well as width, since the two are computed from different metrics.
  doc.font(F + 'DroidSansMono.ttf', 12);
  const h = doc.heightOfString('two lines worth of text in a narrow box here', {width: 150});
  doc.rect(40, 620, 150, h).stroke('black');

  // A second page, so the font resource is recorded against a new page too.
  doc.addPage();
  doc.font(F + 'DroidSansMono.ttf', 22);
  doc.text('carried onto the next page', 40, 40);
  doc.font('Display', 12);
  doc.text('and the registered name still resolves', 40, 80);

  return doc;
}

const outPath = process.argv[2];
if (!outPath) { console.error('usage: node example.js <out.pdf>'); process.exit(2); }

const doc = GeneratePDF();
const stream = fs.createWriteStream(outPath);

doc.pipe(stream);
doc.end();

stream.on('finish', () => process.exit(0));
