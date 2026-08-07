import 'dart:io';
import 'dart:convert';
void main() {
  // RU
  var f = File('lib/l10n/app_ru.arb'); var d = json.decode(f.readAsStringSync()) as Map<String,dynamic>;
  d['step']='Shag'; d['skip']='Propustit'; d['back']='Nazad'; d['next']='Dalee';
  d['createProfile']='Sozdat profil'; d['basicInfo']='Osnovnye dannye';
  d['firstName']='Imya'; d['yourFirstName']='Vashe imya'; d['birthDate']='Data rozhdeniya'; d['years']='let';
  d['male']='Muzhchina'; d['female']='Zhenshchina';
  d['ezidiIdentity']='Ezidskaya identichnost'; d['tribe']='Plemya / Ashiret'; d['iAmLookingFor']='Ya ishchu';
  d['marriage']='Brak'; d['dating']='Znakomstva'; d['friendship']='Druzhba';
  d['aboutYou']='O vas'; d['location']='Gorod'; d['jobTitle']='Professiya'; d['educationLevel']='Obrazovanie';
  d['single']='Holost'; d['divorced']='Razvedyon'; d['widowed']='Vdovets';
  d['noChildren']='Net detej'; d['hasChildren']='Est deti'; d['wantsChildren']='Hochet detej'; d['maybeChildren']='Mozhet byt';
  d['interestsHobbies']='Interesy i hobbi'; d['characterTraits']='Harakter i kachestva';
  d['aboutMe']='O sebe'; d['threeThings']='Tri vazhnyh veshchi dlya menya'; d['profileCreated']='Profil sozdan!';
  f.writeAsStringSync(JsonEncoder.withIndent('  ').convert(d)); print('RU done');
  // FR
  f = File('lib/l10n/app_fr.arb'); d = json.decode(f.readAsStringSync()) as Map<String,dynamic>;
  d['step']='Etape'; d['skip']='Passer'; d['back']='Retour'; d['next']='Suivant';
  d['createProfile']='Creer profil'; d['basicInfo']='Infos de base';
  d['firstName']='Prenom'; d['yourFirstName']='Votre prenom'; d['birthDate']='Date de naissance'; d['years']='ans';
  d['male']='Homme'; d['female']='Femme';
  d['ezidiIdentity']='Identite Ezidie'; d['tribe']='Tribu / Ashiret'; d['iAmLookingFor']='Je cherche';
  d['marriage']='Mariage'; d['dating']='Rencontres'; d['friendship']='Amitie';
  d['aboutYou']='A propos de vous'; d['location']='Ville'; d['jobTitle']='Profession'; d['educationLevel']='Education';
  d['single']='Celibataire'; d['divorced']='Divorce'; d['widowed']='Veuf';
  d['noChildren']='Pas d enfants'; d['hasChildren']='A des enfants'; d['wantsChildren']='Veut des enfants'; d['maybeChildren']='Peut-etre';
  d['interestsHobbies']='Interets et loisirs'; d['characterTraits']='Caractere et qualites';
  d['aboutMe']='A propos de moi'; d['threeThings']='Trois choses importantes pour moi'; d['profileCreated']='Profil cree!';
  f.writeAsStringSync(JsonEncoder.withIndent('  ').convert(d)); print('FR done');
  // NL
  f = File('lib/l10n/app_nl.arb'); d = json.decode(f.readAsStringSync()) as Map<String,dynamic>;
  d['step']='Stap'; d['skip']='Overslaan'; d['back']='Terug'; d['next']='Volgende';
  d['createProfile']='Profiel aanmaken'; d['basicInfo']='Basisgegevens';
  d['firstName']='Voornaam'; d['yourFirstName']='Je voornaam'; d['birthDate']='Geboortedatum'; d['years']='jaar';
  d['male']='Man'; d['female']='Vrouw';
  d['ezidiIdentity']='Ezidische identiteit'; d['tribe']='Stam / Ashiret'; d['iAmLookingFor']='Ik zoek';
  d['marriage']='Huwelijk'; d['dating']='Daten'; d['friendship']='Vriendschap';
  d['aboutYou']='Over jou'; d['location']='Stad'; d['jobTitle']='Beroep'; d['educationLevel']='Opleiding';
  d['single']='Ongehuwd'; d['divorced']='Gescheiden'; d['widowed']='Weduwe';
  d['noChildren']='Geen kinderen'; d['hasChildren']='Heeft kinderen'; d['wantsChildren']='Wil kinderen'; d['maybeChildren']='Misschien';
  d['interestsHobbies']='Interesses en hobbys'; d['characterTraits']='Karakter en eigenschappen';
  d['aboutMe']='Over mij'; d['threeThings']='Drie belangrijke dingen voor mij'; d['profileCreated']='Profiel aangemaakt!';
  f.writeAsStringSync(JsonEncoder.withIndent('  ').convert(d)); print('NL done');
}