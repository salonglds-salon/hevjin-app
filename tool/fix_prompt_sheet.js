const fs = require('fs');
const p = 'C:/Users/dalshkas/Desktop/hevjin-app/lib/screens/home/home_screen.dart';
let c = fs.readFileSync(p, 'utf8');
const eol = c.includes('\r\n') ? '\r\n' : '\n';
let L = c.split(/\r?\n/);
function chk(i, needle) {
  if (!L[i] || L[i].indexOf(needle) === -1) {
    console.log('ANCHOR FAIL line ' + (i + 1) + ' expected [' + needle + '] got [' + L[i] + ']');
    process.exit(1);
  }
}
chk(2068, 'showModalBottomSheet(');
chk(2075, 'String? selectedPrompt');
chk(2081, '.toList();');
chk(2082, '');
chk(2082 + 0, '');
chk(2083 - 1, '');
chk(2082 + 1 - 1, '');
chk(2083, 'return StatefulBuilder(');
const block = L.slice(2075, 2082).map(s => (s.slice(0, 4) === '    ' ? s.slice(4) : s));
L.splice(2075, 7);
L.splice(2068, 0, ...block);
fs.writeFileSync(p, L.join(eol), 'utf8');
console.log('OK patched. new line count: ' + L.length);
