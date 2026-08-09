import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HevjinTheme.background,
      appBar: AppBar(title: const Text('Datenschutzerkl\u00e4rung')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Datenschutzerkl\u00e4rung', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Stand: August 2026', style: TextStyle(color: HevjinTheme.textSecondary, fontSize: 12)),
            SizedBox(height: 20),

            _Section(title: '1. Verantwortlicher', content:
              'Verantwortlich f\u00fcr die Datenverarbeitung ist:\n\n'
              'Dalshad Kasim\n'
              'Bahnhofstr. 30, 49413 Dinklage, Deutschland\n'
              'E-Mail: hevjinsupport@gmail.com\n'),

            _Section(title: '2. Welche Daten wir erheben', content:
              'Bei der Nutzung von Hevjin erheben wir folgende Daten:\n\n'
              '- Registrierungsdaten: E-Mail-Adresse oder Telefonnummer, Passwort\n'
              '- Profildaten: Name, Alter, Geschlecht, Kaste, Stamm, Wohnort, K\u00f6rpergr\u00f6\u00dfe, Beruf, Bildung, Familienstand, Bio, Interessen, Fotos\n'
              '- Nutzungsdaten: Likes, Matches, Nachrichten, Zeitstempel\n'
              '- Technische Daten: Ger\u00e4tetyp, Browser, IP-Adresse\n'),

            _Section(title: '3. Zweck der Datenverarbeitung', content:
              'Wir verarbeiten Ihre Daten zu folgenden Zwecken:\n\n'
              '- Bereitstellung des Dating-Dienstes (Profil, Matching, Chat)\n'
              '- Verifizierung Ihrer Identit\u00e4t (SMS/E-Mail)\n'
              '- Verbesserung unseres Dienstes\n'
              '- Sicherheit und Missbrauchspr\u00e4vention\n'),

            _Section(title: '4. Rechtsgrundlage', content:
              'Die Verarbeitung erfolgt auf Grundlage von:\n\n'
              '- Art. 6 Abs. 1 lit. b DSGVO (Vertragserf\u00fcllung)\n'
              '- Art. 6 Abs. 1 lit. a DSGVO (Einwilligung)\n'
              '- Art. 6 Abs. 1 lit. f DSGVO (Berechtigtes Interesse)\n'),

            _Section(title: '5. Speicherdauer', content:
              'Ihre Daten werden gespeichert, solange Ihr Konto aktiv ist. '
              'Nach L\u00f6schung Ihres Kontos werden alle personenbezogenen Daten '
              'innerhalb von 30 Tagen geloescht, sofern keine gesetzlichen '
              'Aufbewahrungspflichten bestehen.\n'),

            _Section(title: '6. Weitergabe an Dritte', content:
              'Wir geben Ihre Daten nicht an Dritte weiter, ausser:\n\n'
              '- An unseren Hosting-Anbieter Supabase (Sitz: USA, EU-Standardvertragsklauseln)\n'
              '- Wenn Sie ausdruecklich einwilligen\n'
              '- Wenn wir gesetzlich dazu verpflichtet sind\n'),

            _Section(title: '7. Ihre Rechte', content:
              'Sie haben folgende Rechte:\n\n'
              '- Auskunft ueber Ihre gespeicherten Daten (Art. 15 DSGVO)\n'
              '- Berichtigung unrichtiger Daten (Art. 16 DSGVO)\n'
              '- L\u00f6schung Ihrer Daten (Art. 17 DSGVO)\n'
              '- Einschraenkung der Verarbeitung (Art. 18 DSGVO)\n'
              '- Datenuebertragbarkeit (Art. 20 DSGVO)\n'
              '- Widerspruch gegen die Verarbeitung (Art. 21 DSGVO)\n'
              '- Widerruf Ihrer Einwilligung (Art. 7 Abs. 3 DSGVO)\n\n'
              'Zur Ausuebung Ihrer Rechte kontaktieren Sie uns unter: hevjinsupport@gmail.com\n'),

            _Section(title: '8. Datensicherheit', content:
              'Wir setzen technische und organisatorische Ma\u00dfnahmen ein, um Ihre Daten zu schuetzen:\n\n'
              '- Verschluesselte \u00dcbertragung (HTTPS/TLS)\n'
              '- Verschluesselte Speicherung\n'
              '- Zugriffsbeschraenkungen\n'
              '- regelm\u00e4\u00dfige Sicherheitspruefungen\n'),

            _Section(title: '9. Fotos und Medien', content:
              'Hochgeladene Fotos werden auf unseren Servern gespeichert. '
              'Sie koennen jederzeit Fotos l\u00f6schen oder die Sichtbarkeit einschraenken. '
              'Profilfotos sind f\u00fcr andere Nutzer sichtbar, sofern Sie die '
              'Privatsphaere-Einstellung nicht aktivieren.\n'),

            _Section(title: '10. Push-Benachrichtigungen', content:
              'Mit Ihrer Einwilligung senden wir Push-Benachrichtigungen bei:\n\n'
              '- Neuen Matches\n'
              '- Neuen Nachrichten\n'
              '- Profil-Likes\n\n'
              'Sie koennen diese jederzeit in den App-Einstellungen deaktivieren.\n'),

            _Section(title: '11. Cookies und Tracking', content:
              'Die App verwendet keine Cookies oder Tracking-Tools von Drittanbietern. '
              'Wir verwenden nur technisch notwendige Session-Daten f\u00fcr die Authentifizierung.\n'),

            _Section(title: '12. Mindestalter', content:
              'Die Nutzung von Hevjin ist erst ab 18 Jahren gestattet. '
              'Mit der Registrierung bestaetigen Sie, dass Sie mindestens 18 Jahre alt sind.\n'),

            _Section(title: '13. \u00c4nderungen', content:
              'Wir behalten uns vor, diese Datenschutzerkl\u00e4rung zu aktualisieren. '
              'Ueber wesentliche \u00c4nderungen informieren wir Sie per E-Mail oder In-App-Benachrichtigung.\n'),

            _Section(title: '14. Beschwerderecht', content:
              'Sie haben das Recht, sich bei einer Datenschutz-Aufsichtsbeh\u00f6rde zu beschweren:\n\n'
              'Die Landesbeauftragte f\u00fcr den Datenschutz Niedersachsen\n'
              'Prinzenstrasse 5, 30159 Hannover\n'
              'www.lfd.niedersachsen.de\n'),

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

