// Generiert statische HTML-Seiten aus den Legal-Screens.
// Aufruf:  dart run tool/gen_legal_html.dart
import 'dart:io';

const map = {
  'privacy_policy_screen.dart': ['datenschutz.html', 'Datenschutzerklärung'],
  'imprint_screen.dart': ['impressum.html', 'Impressum'],
  'terms_screen.dart': ['agb.html', 'Allgemeine Geschäftsbedingungen'],
};

String unesc(String s) {
  s = s.replaceAllMapped(RegExp(r'\\u([0-9a-fA-F]{4})'),
      (m) => String.fromCharCode(int.parse(m[1]!, radix: 16)));
  return s.replaceAll(r'\n', '\n').replaceAll(r"\'", "'");
}

String esc(String s) =>
    s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');

String body(String content) {
  final out = StringBuffer();
  for (final block in content.trim().split('\n\n')) {
    final lines =
        block.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) continue;
    if (lines.every((l) => l.trim().startsWith('- '))) {
      out.writeln('<ul>');
      for (final l in lines) {
        out.writeln('<li>${esc(l.trim().substring(2))}</li>');
      }
      out.writeln('</ul>');
    } else {
      out.writeln('<p>${lines.map((l) => esc(l.trim())).join('<br>')}</p>');
    }
  }
  return out.toString();
}

String page(String title, String inner) => '''<!DOCTYPE html>
<html lang="de" dir="ltr">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>$title – Hevjîn</title>
<style>
*{box-sizing:border-box}
body{margin:0;padding:0;background:linear-gradient(160deg,#2D2016 0%,#5C3A28 100%);
  background-attachment:fixed;color:#F2E8DC;
  font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;
  line-height:1.65;font-size:16px}
.wrap{max-width:800px;margin:0 auto;padding:32px 20px 64px}
header{border-bottom:1px solid rgba(212,149,43,.35);padding-bottom:20px;margin-bottom:32px}
.brand{font-size:15px;letter-spacing:.16em;text-transform:uppercase;color:#D4952B;font-weight:600}
h1{font-size:28px;margin:10px 0 0;color:#fff;font-weight:600}
h2{font-size:19px;margin:36px 0 10px;color:#D4952B;font-weight:600}
p{margin:0 0 14px}
ul{margin:0 0 16px;padding-left:22px}
li{margin-bottom:7px}
a{color:#FF8A80}
footer{margin-top:48px;padding-top:20px;border-top:1px solid rgba(212,149,43,.25);
  font-size:14px;color:#C9B8A6}
footer a{margin-right:16px}
@media(max-width:600px){h1{font-size:23px}.wrap{padding:24px 16px 48px}}
</style>
</head>
<body>
<div class="wrap">
<header><div class="brand">Hevjîn</div><h1>$title</h1></header>
$inner
<footer>
<a href="/impressum.html">Impressum</a><a href="/datenschutz.html">Datenschutz</a><a href="/agb.html">AGB</a><a href="/">Zur App</a>
<p style="margin-top:14px">Hevjîn · Dalshad Kasim · Bahnhofstr. 30, 49413 Dinklage · hevjinsupport@gmail.com</p>
</footer>
</div>
</body>
</html>
''';

void main() {
  final strRe = RegExp(r"'((?:[^'\\]|\\.)*)'");
  final targets = <Directory>[
    Directory('web'),
    if (Directory('build/web').existsSync()) Directory('build/web'),
  ];

  map.forEach((src, cfg) {
    final f = File('lib/screens/legal/$src');
    if (!f.existsSync()) {
      print('!! fehlt: ${f.path}');
      return;
    }
    final code = f.readAsStringSync();
    final chunks = code.split('_Section(')..removeAt(0);
    final out = StringBuffer();
    var n = 0;

    for (var c in chunks) {
      final end = c.indexOf("'),");
      if (end >= 0) c = c.substring(0, end + 1);
      final parts = strRe.allMatches(c).map((m) => m[1]!).toList();
      if (parts.isEmpty) continue;
      final title = unesc(parts.first);
      final content = unesc(parts.skip(1).join());
      out.writeln('<h2>${esc(title)}</h2>');
      out.write(body(content));
      n++;
    }

    if (n == 0) {
      // Fallback: alle String-Literale der Datei als Absätze
      final parts = strRe
          .allMatches(code)
          .map((m) => unesc(m[1]!))
          .where((s) => s.length > 40 && !s.contains('package:'))
          .toList();
      out.write(body(parts.join('\n\n')));
      print('   (Fallback-Modus, ${parts.length} Absätze)');
    }

    final html = page(cfg[1], out.toString());
    for (final d in targets) {
      final o = File('${d.path}/${cfg[0]}');
      o.writeAsStringSync(html);
      print('OK  ${o.path}  ($n Abschnitte, ${html.length} B)');
    }
  });
}
