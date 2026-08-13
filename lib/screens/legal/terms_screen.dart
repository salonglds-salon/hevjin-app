import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import 'legal_layout.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HevjinTheme.background,
      appBar: AppBar(title: const Text('Nutzungsbedingungen')),
      body: const LegalBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Allgemeine Nutzungsbedingungen', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Stand: August 2026', style: TextStyle(color: HevjinTheme.textSecondary, fontSize: 12)),
            SizedBox(height: 20),

            _Section(title: '1. Geltungsbereich', content:
              'Diese Nutzungsbedingungen gelten f\u00fcr die Nutzung der Dating-App "Hevjin", '
              'betrieben von Dalshad Kasim, Bahnhofstr. 30, 49413 Dinklage, Deutschland.\n'),

            _Section(title: '2. Zielgruppe', content:
              'Hevjin ist eine Dating-Plattform exklusiv f\u00fcr Mitglieder der ezidischen (yazidischen) Gemeinschaft. '
              'Die Nutzung ist ab 18 Jahren gestattet.\n'),

            _Section(title: '3. Registrierung', content:
              'f\u00fcr die Nutzung ist eine Registrierung per E-Mail oder Telefonnummer erforderlich. '
              'Sie sind verpflichtet, wahrheitsgemasse Angaben zu machen. '
              'Jede Person darf nur ein Konto besitzen.\n'),

            _Section(title: '4. Pflichten der Nutzer', content:
              'Sie verpflichten sich:\n\n'
              '- Keine falschen Identitaeten vorzutaeuschen\n'
              '- Keine belaestigenden, bedrohenden oder rechtswidrigen Inhalte zu veroeffentlichen\n'
              '- Keine kommerziellen Inhalte oder Spam zu versenden\n'
              '- Die Privatsphaere anderer Nutzer zu respektieren\n'
              '- Keine Fotos oder Informationen anderer Nutzer ohne deren Zustimmung weiterzugeben\n'
              '- Keine Minderjahrigen zu kontaktieren oder sich als solche auszugeben\n'),

            _Section(title: '5. Inhalte und Fotos', content:
              'Sie sind f\u00fcr alle Inhalte verantwortlich, die Sie hochladen. Verboten sind:\n\n'
              '- Nacktbilder oder pornografische Inhalte\n'
              '- Gewaltverherrlichende Inhalte\n'
              '- Urheberrechtlich geschuetztes Material Dritter\n'
              '- Bilder von Minderjahrigen\n\n'
              'Wir behalten uns vor, Inhalte ohne Vorankuendigung zu entfernen.\n'),

            _Section(title: '6. Kosten', content:
              'Die Grundnutzung von Hevjin ist kostenlos. '
              'Zukuenftige Premium-Funktionen koennen kostenpflichtig angeboten werden. '
              'Ueber Kosten werden Sie vor dem Kauf informiert.\n'),

            _Section(title: '7. Sperrung und Kuendigung', content:
              'Wir behalten uns vor, Konten zu sperren oder zu loeschen bei:\n\n'
              '- Verstoss gegen diese Nutzungsbedingungen\n'
              '- Fake-Profile oder Betrug\n'
              '- Belaestigung anderer Nutzer\n'
              '- Inaktivitaet ueber 12 Monate\n\n'
              'Sie koennen Ihr Konto jederzeit in den Einstellungen loeschen.\n'),

            _Section(title: '8. Haftungsausschluss', content:
              'Hevjin uebernimmt keine Haftung f\u00fcr:\n\n'
              '- Die Richtigkeit der Angaben anderer Nutzer\n'
              '- Schaeden aus Kontakten zwischen Nutzern\n'
              '- Voruebergehende Nichtverfuegbarkeit des Dienstes\n'
              '- Datenverlust bei technischen Stoerungen\n\n'
              'Die Nutzung erfolgt auf eigene Verantwortung.\n'),

            _Section(title: '9. Geistiges Eigentum', content:
              'Alle Rechte an der App (Design, Code, Marke "Hevjin") liegen beim Betreiber. '
              'Eine Vervielfaeltigung oder kommerzielle Nutzung ist ohne Genehmigung untersagt.\n'),

            _Section(title: '10. Aenderungen', content:
              'Wir behalten uns vor, diese Bedingungen zu aendern. '
              'Ueber wesentliche Aenderungen informieren wir per E-Mail oder In-App.\n'),

            _Section(title: '11. Anwendbares Recht', content:
              'Es gilt deutsches Recht. Gerichtsstand ist Cloppenburg, sofern gesetzlich zul\u00e4ssig.\n'),

            _Section(title: '12. Kontakt', content:
              'Bei Fragen zu diesen Nutzungsbedingungen:\n\n'
              'Dalshad Hajaj Kasim\n'
              'Telefon: +49 1525 1322992\n'
              'E-Mail: hevjinsupport@gmail.com\n'),

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
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 14, height: 1.6, color: HevjinTheme.textSecondary)),
        ],
      ),
    );
  }
}

