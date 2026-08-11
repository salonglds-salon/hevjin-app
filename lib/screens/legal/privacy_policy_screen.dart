import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import 'legal_layout.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HevjinTheme.background,
      appBar: AppBar(title: const Text('Datenschutzerkl\u00e4rung')),
      body: const LegalBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Datenschutzerkl\u00e4rung', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Stand: 11. August 2026', style: TextStyle(color: HevjinTheme.textSecondary, fontSize: 12)),
            SizedBox(height: 20),

            _Section(title: '1. Verantwortlicher', content:
              'Verantwortlich f\u00fcr die Datenverarbeitung ist:\n\n'
              'Dalshad Kasim\n'
              'Bahnhofstr. 30, 49413 Dinklage, Deutschland\n'
              'E-Mail: hevjinsupport@gmail.com\n'),

            _Section(title: '2. Welche Daten wir erheben', content:
              'Bei der Nutzung von Hevj\u00een erheben wir folgende Daten:\n\n'
              '- Registrierungsdaten: E-Mail-Adresse, Passwort (verschl\u00fcsselt gespeichert)\n'
              '- Profildaten: Name, Geburtsdatum, Geschlecht, gesuchtes Geschlecht, Kaste, Stamm, '
              'Wohnort, K\u00f6rpergr\u00f6\u00dfe, Beruf, Bildung, Familienstand, Kinderwunsch, '
              'Bio, Profilfragen, Interessen, Sport, Reisen, Fotos\n'
              '- Nutzungsdaten: Likes, Matches, Chat-Nachrichten, Chat-Bilder, Blockierungen, '
              'Meldungen, Zeitstempel der letzten Aktivit\u00e4t\n'
              '- Technische Daten: Ger\u00e4tetyp, Browser, IP-Adresse\n\n'
              'Eine Telefonnummer wird nicht erhoben.\n'),

            _Section(title: '3. Besondere Kategorien personenbezogener Daten', content:
              'Angaben zu Ihrer Kaste (Mirid, P\u00eer, \u015e\u00eax), zu Ihrem Stamm sowie zu Ihrem '
              'Geschlecht und dem von Ihnen gesuchten Geschlecht lassen R\u00fcckschl\u00fcsse auf Ihre '
              'religi\u00f6se Zugeh\u00f6rigkeit und Ihre sexuelle Orientierung zu. Es handelt sich damit '
              'um besondere Kategorien personenbezogener Daten im Sinne von Art. 9 Abs. 1 DSGVO.\n\n'
              'Ihre Verarbeitung erfolgt ausschlie\u00dflich auf Grundlage Ihrer ausdr\u00fccklichen '
              'Einwilligung nach Art. 6 Abs. 1 lit. a, Art. 7 und Art. 9 Abs. 2 lit. a DSGVO. '
              'Sie erteilen diese Einwilligung, indem Sie die entsprechenden Angaben im '
              'Registrierungsprozess freiwillig machen.\n\n'
              'Sie k\u00f6nnen Ihre Einwilligung jederzeit ohne Angabe von Gr\u00fcnden widerrufen, '
              'indem Sie die betreffenden Angaben l\u00f6schen oder Ihr Konto l\u00f6schen. Der Widerruf '
              'ber\u00fchrt nicht die Rechtm\u00e4\u00dfigkeit der bis dahin erfolgten Verarbeitung. '
              'Ohne diese Angaben ist die Vermittlungsfunktion von Hevj\u00een nicht nutzbar.\n'),

            _Section(title: '4. Zweck der Datenverarbeitung', content:
              'Wir verarbeiten Ihre Daten zu folgenden Zwecken:\n\n'
              '- Bereitstellung des Dienstes (Profil, Entdecken, Matching, Chat)\n'
              '- Best\u00e4tigung Ihrer E-Mail-Adresse und Zur\u00fccksetzen des Passworts\n'
              '- Kontoverwaltung einschlie\u00dflich Deaktivierung und L\u00f6schung\n'
              '- Sicherheit und Missbrauchspr\u00e4vention (Blockieren, Melden)\n'
              '- Verbesserung unseres Dienstes\n'),

            _Section(title: '5. Rechtsgrundlage', content:
              'Die Verarbeitung erfolgt auf Grundlage von:\n\n'
              '- Art. 6 Abs. 1 lit. b DSGVO (Vertragserf\u00fcllung) f\u00fcr Konto, Profil, '
              'Matching und Chat\n'
              '- Art. 6 Abs. 1 lit. a DSGVO (Einwilligung) f\u00fcr freiwillige Profilangaben '
              'und Fotos\n'
              '- Art. 9 Abs. 2 lit. a DSGVO (ausdr\u00fcckliche Einwilligung) f\u00fcr die in '
              'Abschnitt 3 genannten besonderen Kategorien\n'
              '- Art. 6 Abs. 1 lit. f DSGVO (berechtigtes Interesse) f\u00fcr Sicherheit, '
              'Missbrauchspr\u00e4vention und technischen Betrieb\n'
              '- Art. 6 Abs. 1 lit. c DSGVO (rechtliche Verpflichtung), soweit gesetzliche '
              'Aufbewahrungspflichten bestehen\n'),

            _Section(title: '6. Empf\u00e4nger und Auftragsverarbeiter', content:
              'Wir verkaufen Ihre Daten nicht und geben sie nicht zu Werbezwecken weiter. '
              'Zur Bereitstellung des Dienstes setzen wir folgende Dienstleister als '
              'Auftragsverarbeiter nach Art. 28 DSGVO ein:\n\n'
              '- Supabase Inc., USA: Authentifizierung, Datenbank und Speicherung der Fotos. '
              'Die Datenverarbeitung findet auf Servern in der Europ\u00e4ischen Union statt; '
              'eine \u00dcbermittlung in die USA kann im Rahmen von Support und Betrieb nicht '
              'ausgeschlossen werden. Grundlage sind die EU-Standardvertragsklauseln.\n'
              '- Resend (Plus Five Five, Inc.), USA: Versand der System-E-Mails '
              '(Best\u00e4tigung der Registrierung, Passwort-Zur\u00fccksetzung). '
              'Grundlage sind die EU-Standardvertragsklauseln.\n'
              '- GitHub, Inc., USA: Hosting der Web-Version unter hevjin.app \u00fcber GitHub Pages. '
              'Grundlage sind die EU-Standardvertragsklauseln.\n\n'
              'Dar\u00fcber hinaus geben wir Daten nur weiter, wenn Sie ausdr\u00fccklich '
              'einwilligen oder wir gesetzlich dazu verpflichtet sind.\n\n'
              'Ihr Profil ist innerhalb der App f\u00fcr andere angemeldete Nutzerinnen und Nutzer '
              'sichtbar, soweit Sie es nicht auf privat gestellt oder die betreffende Person '
              'blockiert haben.\n'),

            _Section(title: '7. Speicherdauer', content:
              'Ihre Daten werden gespeichert, solange Ihr Konto besteht.\n\n'
              'Wenn Sie Ihr Konto l\u00f6schen, wird es zun\u00e4chst deaktiviert und f\u00fcr '
              '14 Tage aufbewahrt. In diesem Zeitraum ist Ihr Profil f\u00fcr andere Nutzerinnen '
              'und Nutzer nicht mehr sichtbar und Sie k\u00f6nnen das Konto durch erneute '
              'Anmeldung reaktivieren. Nach Ablauf der 14 Tage werden Ihr Konto und alle '
              'zugeh\u00f6rigen personenbezogenen Daten endg\u00fcltig gel\u00f6scht, sofern keine '
              'gesetzlichen Aufbewahrungspflichten bestehen.\n\n'
              'Chat-Nachrichten werden gel\u00f6scht, wenn Sie sie l\u00f6schen oder wenn eines der '
              'beteiligten Konten endg\u00fcltig gel\u00f6scht wird.\n'),

            _Section(title: '8. Konto und Daten l\u00f6schen', content:
              'Sie k\u00f6nnen Ihr Konto und alle zugeh\u00f6rigen Daten jederzeit selbst '
              'l\u00f6schen:\n\n'
              'Profil \u2192 Einstellungen \u2192 Konto l\u00f6schen\n\n'
              'Alternativ k\u00f6nnen Sie die L\u00f6schung per E-Mail an hevjinsupport@gmail.com '
              'beantragen. Wir bearbeiten Ihren Antrag unverz\u00fcglich, sp\u00e4testens '
              'innerhalb von 30 Tagen. Zum Ablauf der L\u00f6schung siehe Abschnitt 7.\n\n'
              'Einzelne Angaben und Fotos k\u00f6nnen Sie unabh\u00e4ngig davon jederzeit in '
              'Ihrem Profil bearbeiten oder entfernen.\n'),

            _Section(title: '9. Ihre Rechte', content:
              'Sie haben folgende Rechte:\n\n'
              '- Auskunft \u00fcber Ihre gespeicherten Daten (Art. 15 DSGVO)\n'
              '- Berichtigung unrichtiger Daten (Art. 16 DSGVO)\n'
              '- L\u00f6schung Ihrer Daten (Art. 17 DSGVO)\n'
              '- Einschr\u00e4nkung der Verarbeitung (Art. 18 DSGVO)\n'
              '- Daten\u00fcbertragbarkeit (Art. 20 DSGVO)\n'
              '- Widerspruch gegen die Verarbeitung (Art. 21 DSGVO)\n'
              '- Widerruf Ihrer Einwilligung (Art. 7 Abs. 3 DSGVO)\n\n'
              'Zur Aus\u00fcbung Ihrer Rechte kontaktieren Sie uns unter: '
              'hevjinsupport@gmail.com\n'),

            _Section(title: '10. Datensicherheit', content:
              'Wir setzen technische und organisatorische Ma\u00dfnahmen ein, um Ihre Daten zu '
              'sch\u00fctzen:\n\n'
              '- Verschl\u00fcsselte \u00dcbertragung (HTTPS/TLS)\n'
              '- Verschl\u00fcsselte Speicherung von Passw\u00f6rtern\n'
              '- Zugriffsbeschr\u00e4nkungen auf Datenbankebene (Row Level Security)\n'
              '- Regelm\u00e4\u00dfige Sicherheitspr\u00fcfungen\n'),

            _Section(title: '11. Fotos und Medien', content:
              'Hochgeladene Fotos werden bei unserem Auftragsverarbeiter Supabase gespeichert. '
              'Sie k\u00f6nnen Fotos jederzeit l\u00f6schen oder als privat markieren. '
              'Profilfotos sind f\u00fcr andere angemeldete Nutzerinnen und Nutzer sichtbar, '
              'sofern Sie die Privatsph\u00e4re-Einstellung nicht aktivieren.\n\n'
              'Bilder, die Sie in einem Chat versenden, sind f\u00fcr die jeweilige '
              'Chat-Partnerin oder den Chat-Partner sichtbar.\n'),

            _Section(title: '12. Cookies und Tracking', content:
              'Die App verwendet keine Cookies und keine Tracking- oder Analyse-Tools von '
              'Drittanbietern. Es findet keine Werbung und kein Profiling zu Werbezwecken '
              'statt. In der Web-Version speichern wir ausschlie\u00dflich technisch notwendige '
              'Sitzungsdaten lokal in Ihrem Browser, um Sie angemeldet zu halten.\n'),

            _Section(title: '13. Mindestalter', content:
              'Die Nutzung von Hevj\u00een ist erst ab 18 Jahren gestattet. '
              'Mit der Registrierung best\u00e4tigen Sie, dass Sie mindestens 18 Jahre alt sind.\n'),

            _Section(title: '14. \u00c4nderungen', content:
              'Wir behalten uns vor, diese Datenschutzerkl\u00e4rung zu aktualisieren. '
              '\u00dcber wesentliche \u00c4nderungen informieren wir Sie per E-Mail oder '
              'In-App-Benachrichtigung.\n'),

            _Section(title: '15. Beschwerderecht', content:
              'Sie haben das Recht, sich bei einer Datenschutz-Aufsichtsbeh\u00f6rde zu '
              'beschweren:\n\n'
              'Die Landesbeauftragte f\u00fcr den Datenschutz Niedersachsen\n'
              'Prinzenstra\u00dfe 5, 30159 Hannover\n'
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
