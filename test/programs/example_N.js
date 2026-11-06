// Held-out example N. Not shipped with the task.
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

  // Held-out counterpart to sample test_14: the structure tree, marked content,
  // artifacts and the parent tree. The tree here is deeper than the sample's --
  // a Sect wrapping its own heading and body, a list nested inside that, and a
  // figure whose image takes the alpha-channel route rather than the sample's --
  // and it spans two pages, so the parent tree has entries under more than one
  // page key.

  doc.info.Title = 'Held-out structure';
  doc.info.Lang = 'en-GB';

  const docStruct = doc.struct('Document');
  doc.addStructure(docStruct);

  // A titled heading directly under the document.
  const h1 = doc.struct('H1', {title:'Top level', lang:'en-GB'}, () => {
    doc.fontSize(22).text('Held-out Document', 60, 60);
  });
  docStruct.add(h1);

  // A section, with everything below it hanging off the section rather than off
  // the document -- one level deeper than the sample builds.
  const sect = doc.struct('Sect', {title:'The only section'});
  docStruct.add(sect);

  const h2 = doc.struct('H2', {title:'Subheading', lang:'en-GB'}, () => {
    doc.fontSize(15).text('A subheading inside it', 60, 100);
  });
  sect.add(h2);

  const body = doc.struct('P', () => {
    doc.fontSize(11).text('Body copy set wide enough to wrap over several lines, so the marked-content range covers more than one show-text operator and the range has to be closed on the right one.', 60, 130, {width:420});
  });
  sect.add(body);

  // A quotation, which is a different structure type with an alt string.
  const quote = doc.struct('BlockQuote', {alt:'a quotation'}, () => {
    doc.fontSize(11).text('Set in from the left margin, as a quotation would be.', 90, 190, {width:360});
  });
  sect.add(quote);

  // A four-item list, labels and bodies built separately, nested in the section.
  const list = doc.struct('L');
  for (let i = 1; i <= 4; i++) {
    const li = doc.struct('LI');
    li.add(doc.struct('Lbl', () => { doc.text('(' + i + ')', 60, 216 + i * 15); }));
    li.add(doc.struct('LBody', {alt:'entry ' + i, lang:'en-GB'}, () => {
      doc.text('Entry ' + i + ' of four', 88, 216 + i * 15);
    }));
    list.add(li);
  }
  sect.add(list);

  // An artifact: a rule that carries no semantics and must be excluded from the
  // structure tree entirely.
  doc.markContent('Artifact');
  doc.rect(60, 292, 420, 1).fill('black');
  doc.endMarkedContent();

  // A figure whose image has a real alpha channel, so the tagged path and the
  // re-deflating image path run in the same document.
  const fig = doc.struct('Figure', {alt:'A fish', bbox:[60, 310, 180, 400], placement:'Block'}, () => {
    doc.image(ROOT + "/test/assets/images/fish.png", 60, 310, {width:120});
  });
  sect.add(fig);

  const caption = doc.struct('Caption', () => {
    doc.fontSize(9).text('Figure 1. Not a bee.', 60, 410);
  });
  sect.add(caption);

  // A second page, so the parent tree has to key entries by page.
  doc.addPage();

  const h2b = doc.struct('H2', {title:'Over the break'}, () => {
    doc.fontSize(15).text('Continued overleaf', 60, 60);
  });
  sect.add(h2b);

  // Another artifact, this time on the second page.
  doc.markContent('Artifact');
  doc.rect(60, 88, 420, 1).fill('black');
  doc.endMarkedContent();

  // Two header cells with the two scopes, added to the document rather than to
  // the section, so the tree branches at the top again after the break.
  const th1 = doc.struct('TH', {scope:'Row', title:'a row header'}, () => {
    doc.fontSize(11).text('row header', 60, 110);
  });
  docStruct.add(th1);

  const th2 = doc.struct('TH', {scope:'Column', title:'a column header'}, () => {
    doc.text('column header', 160, 110);
  });
  docStruct.add(th2);

  const cell = doc.struct('TD', () => { doc.text('a plain cell', 60, 140); });
  docStruct.add(cell);

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
