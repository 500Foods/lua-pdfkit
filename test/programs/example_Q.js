// Held-out example Q. Forms, different tree and options from test_17.
const fs = require('fs');
const path = require('path');
const PDFDocument = require('pdfkit');
const ROOT = path.resolve(__dirname, '..', '..');

function GeneratePDF() {
  const doc = new PDFDocument({
    size: 'A4',
    layout: 'portrait',
    margin: 40,
  });

  doc.info.Title = 'Held-out form';
  doc.font('Times-Bold');
  doc.initForm();

  const shipping = doc.formField('shipping', { readOnly: false });
  const address = doc.formField('address', { parent: shipping, required: true });

  doc.font('Times-Roman');
  doc.fontSize(12);
  doc.text('Ship to', 40, 40);

  doc.formText('street', 40, 70, 280, 22, {
    parent: address,
    value: '1 Harbour Road',
    align: 'left',
    borderColor: '#224466',
    backgroundColor: '#f4f1ea',
  });
  doc.formText('city', 40, 100, 160, 22, {
    parent: address,
    value: 'Halifax',
  });
  doc.formText('region', 210, 100, 110, 22, {
    parent: address,
    value: 'NS',
    align: 'center',
    noSpell: true,
  });

  doc.formText('posted', 40, 140, 160, 22, {
    format: { type: 'date', param: 'd mmmm yyyy' },
    value: '5 November 2026',
    fontSize: 9,
  });

  doc.formText('share', 210, 140, 80, 22, {
    format: { type: 'percent', nDec: 0, sepComma: false },
    value: '15',
    align: 'right',
  });

  doc.formCombo('carrier', 40, 180, 160, 20, {
    select: ['postal', 'courier', 'pickup'],
    value: 'courier',
    defaultValue: 'postal',
    edit: false,
    sort: true,
    borderColor: [20, 40, 80],
  });

  doc.formList('notes', 210, 180, 140, 60, {
    select: ['fragile', 'signature', 'leave at door'],
    multiSelect: true,
  });

  doc.formPushButton('send', 40, 260, 90, 26, {
    label: 'Send',
    backgroundColor: 'teal',
    borderColor: 'black',
  });

  doc.formCheckbox('gift', 150, 266, 16, 16, {
    readOnly: true,
    defaultValue: 'Off',
  });

  doc.formText('ssn', 40, 310, 140, 20, {
    format: { type: 'ssn' },
    password: true,
    value: '123456789',
  });

  doc.formText('plus4', 190, 310, 100, 20, {
    format: { type: 'zipPlus4' },
    value: '021391234',
  });

  doc.addNamedJavaScript('validate', 'if (this.getField("street")) { /* held-out */ }');

  doc.addPage({ size: 'A4', margin: 40 });
  doc.font('Courier');
  doc.formText('memo', 40, 40, 300, 80, {
    multiline: true,
    noExport: true,
    value: 'second page, courier, not exported',
    align: 'left',
  });

  return doc;
}

const outPath = process.argv[2];
if (!outPath) { console.error('usage: node example.js <out.pdf>'); process.exit(2); }

const doc = GeneratePDF();
const stream = fs.createWriteStream(outPath);
doc.pipe(stream);
doc.end();
stream.on('finish', () => process.exit(0));
