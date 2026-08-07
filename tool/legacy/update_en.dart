import 'dart:io';
import 'dart:convert';
void main() {
  final f = File('lib/l10n/app_en.arb');
  final d = json.decode(f.readAsStringSync()) as Map<String,dynamic>;
  d['step']='Step'; d['skip']='Skip'; d['back']='Back'; d['next']='Next';
  d['createProfile']='Create Profile'; d['basicInfo']='Basic Info';
  d['firstName']='First name'; d['yourFirstName']='Your first name';
  d['birthDate']='Date of birth'; d['years']='years';
  d['male']='Male'; d['female']='Female';
  d['ezidiIdentity']='Ezidi Identity';
  d['tribe']='Tribe / Ashiret'; d['iAmLookingFor']='I am looking for';
  d['marriage']='Marriage'; d['dating']='Dating'; d['friendship']='Friendship';
  d['aboutYou']='About You'; d['location']='Location';
  d['jobTitle']='Occupation'; d['educationLevel']='Education';
  d['single']='Single'; d['divorced']='Divorced'; d['widowed']='Widowed';
  d['noChildren']='No children'; d['hasChildren']='Has children';
  d['wantsChildren']='Wants children'; d['maybeChildren']='Maybe';
  d['interestsHobbies']='Interests and Hobbies';
  d['characterTraits']='Character and Traits';
  d['aboutMe']='About Me'; d['threeThings']='Three things important to me';
  d['profileCreated']='Profile created!';
  f.writeAsStringSync(JsonEncoder.withIndent('  ').convert(d));
  print('EN done');
}