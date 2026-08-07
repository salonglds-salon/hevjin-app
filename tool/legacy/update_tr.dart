import 'dart:io';
import 'dart:convert';
void main() {
  final f = File('lib/l10n/app_tr.arb');
  final d = json.decode(f.readAsStringSync()) as Map<String,dynamic>;
  d['step']='Adim'; d['skip']='Atla'; d['back']='Geri'; d['next']='Ileri';
  d['createProfile']='Profil Olustur'; d['basicInfo']='Temel Bilgiler';
  d['firstName']='Ad'; d['yourFirstName']='Adiniz';
  d['birthDate']='Dogum tarihi'; d['years']='yas';
  d['male']='Erkek'; d['female']='Kadin';
  d['ezidiIdentity']='Ezidi Kimligi';
  d['tribe']='Asir / Asiret'; d['iAmLookingFor']='Ariyorum';
  d['marriage']='Evlilik'; d['dating']='Tanisma'; d['friendship']='Arkadaslik';
  d['aboutYou']='Hakkinda'; d['location']='Sehir';
  d['jobTitle']='Meslek'; d['educationLevel']='Egitim';
  d['single']='Bekar'; d['divorced']='Bosanmis'; d['widowed']='Dul';
  d['noChildren']='Cocuk yok'; d['hasChildren']='Cocugu var';
  d['wantsChildren']='Cocuk istiyor'; d['maybeChildren']='Belki';
  d['interestsHobbies']='Ilgi Alanlari ve Hobiler';
  d['characterTraits']='Karakter ve Ozellikler';
  d['aboutMe']='Hakkimda'; d['threeThings']='Benim icin onemli uc sey';
  d['profileCreated']='Profil olusturuldu!';
  f.writeAsStringSync(JsonEncoder.withIndent('  ').convert(d));
  print('TR done');
}