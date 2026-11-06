// test_08 — text layout: alignment, columns, lists, decorations, links and continued runs
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

  const L = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.';
  doc.fontSize(10);
  doc.text(L, 50, 50, {width:200, align:'left'});
  doc.text(L, 50, 120, {width:200, align:'right'});
  doc.text(L, 50, 190, {width:200, align:'center'});
  doc.text(L, 50, 260, {width:200, align:'justify'});
  doc.text(L, 300, 50, {width:200, indent:20, paragraphGap:8, lineGap:3});
  doc.text(L, 300, 150, {width:200, columns:2, columnGap:10, height:100});
  doc.text('under', 50, 340, {underline:true});
  doc.text('strike', 50, 360, {strike:true});
  doc.text('both', 50, 380, {underline:true, strike:true});
  doc.text('oblique', 50, 400, {oblique:true});
  doc.text('oblique15', 50, 420, {oblique:15});
  doc.text('link', 50, 440, {link:'https://example.com', underline:true});
  doc.text('goto', 50, 460, {goTo:'anchor'});
  doc.text('dest', 50, 480, {destination:'anchor'});
  doc.list(['one','two',['nested a','nested b'],'three'], 50, 500, {width:200});
  doc.list(['a','b'], 300, 500, {width:200, listType:'numbered'});
  doc.list(['a','b'], 300, 560, {width:200, listType:'lettered'});
  doc.text('spacing', 50, 620, {characterSpacing:2, wordSpacing:5});
  doc.text('nowrap', 50, 650, {lineBreak:false});
  doc.text('ellipsis test that is long', 50, 670, {width:60, height:12, ellipsis:true});
  doc.text('cont1 ', 50, 690, {continued:true}).text('cont2');
  doc.text('baseline', 50, 710, {baseline:'top'});
  doc.text('fill+stroke', 50, 730, {fill:true, stroke:true});

  return doc;
}

// --- Node plumbing ----------------------------------------------------------

// test_08.js -> test_08_js.pdf; the Lua side writes test_08_lua.pdf, so the two
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
