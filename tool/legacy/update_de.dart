import 'dart:io';
import 'dart:convert';
void main() {
  final f = File('lib/l10n/app_de.arb');
  final d = json.decode(f.readAsStringSync()) as Map<String,dynamic>;
  d['step']='Schritt'; d['skip']='Ueberspringen'; d['back']='Zurueck'; d['next']='Weiter';
  d['createProfile']='Profil erstellen'; d['basicInfo']='Grunddaten';
  d['firstName']='Vorname'; d['yourFirstName']='Dein Vorname';
  d['birthDate']='Geburtsdatum'; d['years']='Jahre';
  d['male']='Mann'; d['female']='Frau';
  d['ezidiIdentity']='Ezidische Identitaet';
  d['tribe']='Stamm / Ashiret'; d['iAmLookingFor']='Ich suche';
  d['marriage']='Heirat'; d['dating']='Dating'; d['friendship']='Freundschaft';
  d['aboutYou']='Ueber dich'; d['location']='Wohnort';
  d['jobTitle']='Beruf'; d['educationLevel']='Bildung';
  d['single']='Ledig'; d['divorced']='Geschieden'; d['widowed']='Verwitwet';
  d['noChildren']='Keine Kinder'; d['hasChildren']='Hat Kinder';
  d['wantsChildren']='Kinderwunsch'; d['maybeChildren']='Vielleicht';
  d['interestsHobbies']='Interessen und Hobbys';
  d['characterTraits']='Charakter und Eigenschaften';
  d['aboutMe']='Ueber mich'; d['threeThings']='Drei Dinge die mir wichtig sind';
  d['profileCreated']='Profil erstellt!';
  f.writeAsStringSync(JsonEncoder.withIndent('  ').convert(d));
  print('DE done');
}