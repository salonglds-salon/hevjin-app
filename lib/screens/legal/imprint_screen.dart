import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class ImprintScreen extends StatelessWidget {
  const ImprintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HevjinTheme.background,
      appBar: AppBar(title: const Text('Impressum')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Impressum', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Angaben gem\u00e4\u00df \u00a7 5 DDG', style: TextStyle(color: HevjinTheme.textSecondary, fontSize: 12)),
            SizedBox(height: 20),

            _Section(title: 'Anbieter', content:
              'Dalshad Kasim\n'
              'Bahnhofstr. 30\n'
              '49413 Dinklage\n'
              'Deutschland'),

            _Section(title: 'Kontakt', content:
              'Telefon: +49 1516 4013969\n'
              'E-Mail: hevjinsupport@gmail.com\n'
              'Website: https://hevjin.app'),

            _Section(title: 'Verantwortlich f\u00fcr den Inhalt', content:
              'Dalshad Kasim\n'
              'Bahnhofstr. 30\n'
              '49413 Dinklage'),

            _Section(title: 'Umsatzsteuer', content:
              'Kleinunternehmer gem\u00e4\u00df \u00a7 19 UStG. '
              'Es wird keine Umsatzsteuer berechnet und ausgewiesen.'),

            _Section(title: 'Streitschlichtung', content:
              'Die Europ\u00e4ische Kommission stellt eine Plattform zur '
              'Online-Streitbeilegung (OS) bereit: '
              'https://ec.europa.eu/consumers/odr\n\n'
              'Wir sind nicht verpflichtet und nicht bereit, an einem '
              'Streitbeilegungsverfahren vor einer Verbraucher-'
              'schlichtungsstelle teilzunehmen.'),

            _Section(title: 'Haftung f\u00fcr Inhalte', content:
              'Als Diensteanbieter sind wir gem\u00e4\u00df \u00a7 7 Abs. 1 DDG f\u00fcr eigene '
              'Inhalte auf diesen Seiten verantwortlich. Nach \u00a7\u00a7 8 bis 10 DDG '
              'sind wir jedoch nicht verpflichtet, \u00fcbermittelte oder gespeicherte '
              'fremde Informationen zu \u00fcberwachen oder nach Umst\u00e4nden zu '
              'forschen, die auf eine rechtswidrige T\u00e4tigkeit hinweisen.\n\n'
              'Nutzerprofile, Fotos und Nachrichten werden von den Nutzern selbst '
              'erstellt. Bei Kenntnis von Rechtsverst\u00f6\u00dfen entfernen wir '
              'entsprechende Inhalte unverz\u00fcglich.'),

            _Section(title: 'Haftung f\u00fcr Links', content:
              'Unser Angebot enth\u00e4lt ggf. Links zu externen Websites Dritter, '
              'auf deren Inhalte wir keinen Einfluss haben. Deshalb k\u00f6nnen wir '
              'f\u00fcr diese fremden Inhalte auch keine Gew\u00e4hr \u00fcbernehmen.'),

            _Section(title: 'Urheberrecht', content:
              'Die durch den Anbieter erstellten Inhalte und Werke auf diesen '
              'Seiten unterliegen dem deutschen Urheberrecht. Downloads und '
              'Kopien dieser Seite sind nur f\u00fcr den privaten, nicht '
              'kommerziellen Gebrauch gestattet.'),

            _Section(title: 'Meldung von Verst\u00f6\u00dfen', content:
              'Verst\u00f6\u00dfe gegen unsere Community-Regeln, bel\u00e4stigende Nachrichten '
              'oder Fake-Profile k\u00f6nnen direkt in der App gemeldet werden.\n\n'
              'Alternativ per E-Mail an: hevjinsupport@gmail.com'),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String content;
  const _Section({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 13, height: 1.6, color: Color(0xFF444444))),
        ],
      ),
    );
  }
}
