import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hy.dart';
import 'app_localizations_ka.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('fa'),
    Locale('fr'),
    Locale('hy'),
    Locale('ka'),
    Locale('nl'),
    Locale('ru'),
    Locale('sv'),
    Locale('tr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Hevjîn'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Matchmaking for Ezidis'**
  String get welcome;

  /// No description provided for @loginWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Login with Email'**
  String get loginWithEmail;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @loginProblems.
  ///
  /// In en, this message translates to:
  /// **'Login problems?'**
  String get loginProblems;

  /// No description provided for @anonymous.
  ///
  /// In en, this message translates to:
  /// **'100% data encrypted'**
  String get anonymous;

  /// No description provided for @emailVerified.
  ///
  /// In en, this message translates to:
  /// **'Email verified'**
  String get emailVerified;

  /// No description provided for @onlyEzidi.
  ///
  /// In en, this message translates to:
  /// **'Ezidis Only'**
  String get onlyEzidi;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get terms;

  /// No description provided for @imprint.
  ///
  /// In en, this message translates to:
  /// **'Imprint'**
  String get imprint;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @loginRegister.
  ///
  /// In en, this message translates to:
  /// **'Login / Register'**
  String get loginRegister;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// No description provided for @likes.
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get likes;

  /// No description provided for @chats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chats;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// No description provided for @unblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get unblock;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @caste.
  ///
  /// In en, this message translates to:
  /// **'Caste'**
  String get caste;

  /// No description provided for @lookingFor.
  ///
  /// In en, this message translates to:
  /// **'Looking for'**
  String get lookingFor;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @job.
  ///
  /// In en, this message translates to:
  /// **'Occupation'**
  String get job;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @interests.
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get interests;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phone;

  /// No description provided for @privacySettings.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacySettings;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @verification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verification;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @yourConversations.
  ///
  /// In en, this message translates to:
  /// **'Your conversations'**
  String get yourConversations;

  /// No description provided for @noChatsYet.
  ///
  /// In en, this message translates to:
  /// **'No chats yet'**
  String get noChatsYet;

  /// No description provided for @noNewProfiles.
  ///
  /// In en, this message translates to:
  /// **'No new profiles'**
  String get noNewProfiles;

  /// No description provided for @blocked.
  ///
  /// In en, this message translates to:
  /// **'You blocked this user'**
  String get blocked;

  /// No description provided for @blockedByOther.
  ///
  /// In en, this message translates to:
  /// **'You have been blocked'**
  String get blockedByOther;

  /// No description provided for @unblockAction.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get unblockAction;

  /// No description provided for @sendLink.
  ///
  /// In en, this message translates to:
  /// **'Send link'**
  String get sendLink;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @resetPasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we will send a link.'**
  String get resetPasswordDesc;

  /// No description provided for @familyStatus.
  ///
  /// In en, this message translates to:
  /// **'Marital status'**
  String get familyStatus;

  /// No description provided for @children.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get children;

  /// No description provided for @childWish.
  ///
  /// In en, this message translates to:
  /// **'Wish for children'**
  String get childWish;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @match.
  ///
  /// In en, this message translates to:
  /// **'Match'**
  String get match;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'About me'**
  String get bio;

  /// No description provided for @addPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add photos'**
  String get addPhotos;

  /// No description provided for @noPhotos.
  ///
  /// In en, this message translates to:
  /// **'No photos yet'**
  String get noPhotos;

  /// No description provided for @character.
  ///
  /// In en, this message translates to:
  /// **'Character & Traits'**
  String get character;

  /// No description provided for @step.
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get step;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @createProfile.
  ///
  /// In en, this message translates to:
  /// **'Create Profile'**
  String get createProfile;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get basicInfo;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @yourFirstName.
  ///
  /// In en, this message translates to:
  /// **'Your first name'**
  String get yourFirstName;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get birthDate;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @ezidiIdentity.
  ///
  /// In en, this message translates to:
  /// **'Ezidi Identity'**
  String get ezidiIdentity;

  /// No description provided for @tribe.
  ///
  /// In en, this message translates to:
  /// **'Tribe / Ashiret'**
  String get tribe;

  /// No description provided for @iAmLookingFor.
  ///
  /// In en, this message translates to:
  /// **'I am looking for'**
  String get iAmLookingFor;

  /// No description provided for @marriage.
  ///
  /// In en, this message translates to:
  /// **'Marriage'**
  String get marriage;

  /// No description provided for @dating.
  ///
  /// In en, this message translates to:
  /// **'Dating'**
  String get dating;

  /// No description provided for @friendship.
  ///
  /// In en, this message translates to:
  /// **'Friendship'**
  String get friendship;

  /// No description provided for @aboutYou.
  ///
  /// In en, this message translates to:
  /// **'About You'**
  String get aboutYou;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @jobTitle.
  ///
  /// In en, this message translates to:
  /// **'Occupation'**
  String get jobTitle;

  /// No description provided for @educationLevel.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get educationLevel;

  /// No description provided for @single.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get single;

  /// No description provided for @divorced.
  ///
  /// In en, this message translates to:
  /// **'Divorced'**
  String get divorced;

  /// No description provided for @widowed.
  ///
  /// In en, this message translates to:
  /// **'Widowed'**
  String get widowed;

  /// No description provided for @noChildren.
  ///
  /// In en, this message translates to:
  /// **'No children'**
  String get noChildren;

  /// No description provided for @hasChildren.
  ///
  /// In en, this message translates to:
  /// **'Has children'**
  String get hasChildren;

  /// No description provided for @wantsChildren.
  ///
  /// In en, this message translates to:
  /// **'Wants children'**
  String get wantsChildren;

  /// No description provided for @maybeChildren.
  ///
  /// In en, this message translates to:
  /// **'Maybe'**
  String get maybeChildren;

  /// No description provided for @interestsHobbies.
  ///
  /// In en, this message translates to:
  /// **'Interests and Hobbies'**
  String get interestsHobbies;

  /// No description provided for @characterTraits.
  ///
  /// In en, this message translates to:
  /// **'Character and Traits'**
  String get characterTraits;

  /// No description provided for @aboutMe.
  ///
  /// In en, this message translates to:
  /// **'About Me'**
  String get aboutMe;

  /// No description provided for @threeThings.
  ///
  /// In en, this message translates to:
  /// **'Three things important to me'**
  String get threeThings;

  /// No description provided for @profileCreated.
  ///
  /// In en, this message translates to:
  /// **'Profile created!'**
  String get profileCreated;

  /// No description provided for @onbPhotoMaxPhotos.
  ///
  /// In en, this message translates to:
  /// **'Maximum of 6 photos allowed'**
  String get onbPhotoMaxPhotos;

  /// No description provided for @onbPhotoUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed: {error}'**
  String onbPhotoUploadFailed(String error);

  /// No description provided for @onbPhotoStep.
  ///
  /// In en, this message translates to:
  /// **'Step 8 / 8'**
  String get onbPhotoStep;

  /// No description provided for @onbPhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Your photos'**
  String get onbPhotoTitle;

  /// No description provided for @onbPhotoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hevjîn is built on real profiles. Please upload at least two photos — so others know who they are talking to.'**
  String get onbPhotoSubtitle;

  /// No description provided for @onbPhotoSelect.
  ///
  /// In en, this message translates to:
  /// **'Choose photo'**
  String get onbPhotoSelect;

  /// No description provided for @onbPhotoCount.
  ///
  /// In en, this message translates to:
  /// **'{count} of {min} photos'**
  String onbPhotoCount(int count, int min);

  /// No description provided for @onbPhotoAddMore.
  ///
  /// In en, this message translates to:
  /// **'Add another photo'**
  String get onbPhotoAddMore;

  /// No description provided for @onbPhotoAddSecond.
  ///
  /// In en, this message translates to:
  /// **'Add a second photo'**
  String get onbPhotoAddSecond;

  /// No description provided for @onbPhotoStart.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go'**
  String get onbPhotoStart;

  /// No description provided for @onbPhotoUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload photo'**
  String get onbPhotoUpload;

  /// No description provided for @pupProfileUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Profile unlocked'**
  String get pupProfileUnlocked;

  /// No description provided for @pupAvatarUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile picture updated ✓'**
  String get pupAvatarUpdated;

  /// No description provided for @pupTitle.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get pupTitle;

  /// No description provided for @pupDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get pupDone;

  /// No description provided for @pupSort.
  ///
  /// In en, this message translates to:
  /// **'Sort photos'**
  String get pupSort;

  /// No description provided for @pupSortHint.
  ///
  /// In en, this message translates to:
  /// **'Press and hold to move — first photo = profile picture'**
  String get pupSortHint;

  /// No description provided for @pupNoPhotos.
  ///
  /// In en, this message translates to:
  /// **'No photos yet'**
  String get pupNoPhotos;

  /// No description provided for @pupAdd.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get pupAdd;

  /// No description provided for @pupAvatarBadge.
  ///
  /// In en, this message translates to:
  /// **'⭐ Profile picture'**
  String get pupAvatarBadge;

  /// No description provided for @pupPhotoN.
  ///
  /// In en, this message translates to:
  /// **'Photo {index}'**
  String pupPhotoN(int index);

  /// No description provided for @pupShownOnSwipe.
  ///
  /// In en, this message translates to:
  /// **'Shown while swiping'**
  String get pupShownOnSwipe;

  /// No description provided for @pupHoldToMove.
  ///
  /// In en, this message translates to:
  /// **'Press and hold to move'**
  String get pupHoldToMove;

  /// No description provided for @pupUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get pupUploading;

  /// No description provided for @pupAddCount.
  ///
  /// In en, this message translates to:
  /// **'Add photo ({count}/{max})'**
  String pupAddCount(int count, int max);

  /// No description provided for @snpChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get snpChanged;

  /// No description provided for @snpChangedBody.
  ///
  /// In en, this message translates to:
  /// **'Your new password is active. You can use it to sign in from now on.'**
  String get snpChangedBody;

  /// No description provided for @snpContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get snpContinue;

  /// No description provided for @snpDifferent.
  ///
  /// In en, this message translates to:
  /// **'Please choose a different password than the old one.'**
  String get snpDifferent;

  /// No description provided for @snpExpired.
  ///
  /// In en, this message translates to:
  /// **'This link has expired. Please request a new reset link.'**
  String get snpExpired;

  /// No description provided for @snpSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Saving failed. Check your connection and try again.'**
  String get snpSaveFailed;

  /// No description provided for @snpTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a new password'**
  String get snpTitle;

  /// No description provided for @snpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password for your Hevjîn account.'**
  String get snpSubtitle;

  /// No description provided for @snpNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get snpNewPassword;

  /// No description provided for @snpRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat password'**
  String get snpRepeat;

  /// No description provided for @snpMin6.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get snpMin6;

  /// No description provided for @snpMatch.
  ///
  /// In en, this message translates to:
  /// **'Both entries match'**
  String get snpMatch;

  /// No description provided for @snpSave.
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get snpSave;

  /// No description provided for @snpCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get snpCancel;

  /// No description provided for @ecTitle.
  ///
  /// In en, this message translates to:
  /// **'Registration confirmed!'**
  String get ecTitle;

  /// No description provided for @ecBody.
  ///
  /// In en, this message translates to:
  /// **'Your account was created successfully.\nYou can now sign in and set up your profile.'**
  String get ecBody;

  /// No description provided for @ecContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue to login'**
  String get ecContinue;

  /// No description provided for @matSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Message could not be sent'**
  String get matSendFailed;

  /// No description provided for @matItsAMatch.
  ///
  /// In en, this message translates to:
  /// **'It\'s a Match!'**
  String get matItsAMatch;

  /// No description provided for @matSayHint.
  ///
  /// In en, this message translates to:
  /// **'Say something nice ...'**
  String get matSayHint;

  /// No description provided for @supTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get supTitle;

  /// No description provided for @supSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Message sent!'**
  String get supSentTitle;

  /// No description provided for @supSentBody.
  ///
  /// In en, this message translates to:
  /// **'We received your message and will get back to you as soon as possible.'**
  String get supSentBody;

  /// No description provided for @supHeadline.
  ///
  /// In en, this message translates to:
  /// **'How can we help?'**
  String get supHeadline;

  /// No description provided for @supReplyTime.
  ///
  /// In en, this message translates to:
  /// **'We reply within 24 hours'**
  String get supReplyTime;

  /// No description provided for @supCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get supCategory;

  /// No description provided for @supMessage.
  ///
  /// In en, this message translates to:
  /// **'Your message'**
  String get supMessage;

  /// No description provided for @supHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your issue...'**
  String get supHint;

  /// No description provided for @supSend.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get supSend;

  /// No description provided for @supDirectContact.
  ///
  /// In en, this message translates to:
  /// **'Direct contact'**
  String get supDirectContact;

  /// No description provided for @supCatGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get supCatGeneral;

  /// No description provided for @supCatTechnical.
  ///
  /// In en, this message translates to:
  /// **'Technical problem'**
  String get supCatTechnical;

  /// No description provided for @supCatReportUser.
  ///
  /// In en, this message translates to:
  /// **'Report a user'**
  String get supCatReportUser;

  /// No description provided for @supCatProfilePhotos.
  ///
  /// In en, this message translates to:
  /// **'Profile / photos'**
  String get supCatProfilePhotos;

  /// No description provided for @supCatMatchChat.
  ///
  /// In en, this message translates to:
  /// **'Match / chat problem'**
  String get supCatMatchChat;

  /// No description provided for @supCatDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get supCatDeleteAccount;

  /// No description provided for @supCatSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Suggestion'**
  String get supCatSuggestion;

  /// No description provided for @supCatOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get supCatOther;

  /// No description provided for @errorWithMsg.
  ///
  /// In en, this message translates to:
  /// **'Error: {msg}'**
  String errorWithMsg(String msg);

  /// No description provided for @optHumorvoll.
  ///
  /// In en, this message translates to:
  /// **'Funny'**
  String get optHumorvoll;

  /// No description provided for @optRomantisch.
  ///
  /// In en, this message translates to:
  /// **'Romantic'**
  String get optRomantisch;

  /// No description provided for @optSportlich.
  ///
  /// In en, this message translates to:
  /// **'Athletic'**
  String get optSportlich;

  /// No description provided for @optFamiliaer.
  ///
  /// In en, this message translates to:
  /// **'Family-oriented'**
  String get optFamiliaer;

  /// No description provided for @optZuverlaessig.
  ///
  /// In en, this message translates to:
  /// **'Reliable'**
  String get optZuverlaessig;

  /// No description provided for @optEhrgeizig.
  ///
  /// In en, this message translates to:
  /// **'Ambitious'**
  String get optEhrgeizig;

  /// No description provided for @optHerzlich.
  ///
  /// In en, this message translates to:
  /// **'Warm-hearted'**
  String get optHerzlich;

  /// No description provided for @optWeltoffen.
  ///
  /// In en, this message translates to:
  /// **'Open-minded'**
  String get optWeltoffen;

  /// No description provided for @optTraditionell.
  ///
  /// In en, this message translates to:
  /// **'Traditional'**
  String get optTraditionell;

  /// No description provided for @optSpontan.
  ///
  /// In en, this message translates to:
  /// **'Spontaneous'**
  String get optSpontan;

  /// No description provided for @optKreativ.
  ///
  /// In en, this message translates to:
  /// **'Creative'**
  String get optKreativ;

  /// No description provided for @optSpirituell.
  ///
  /// In en, this message translates to:
  /// **'Spiritual'**
  String get optSpirituell;

  /// No description provided for @optFuersorglich.
  ///
  /// In en, this message translates to:
  /// **'Caring'**
  String get optFuersorglich;

  /// No description provided for @optLiebevoll.
  ///
  /// In en, this message translates to:
  /// **'Loving'**
  String get optLiebevoll;

  /// No description provided for @optGelassen.
  ///
  /// In en, this message translates to:
  /// **'Easy-going'**
  String get optGelassen;

  /// No description provided for @optSchuechtern.
  ///
  /// In en, this message translates to:
  /// **'Shy'**
  String get optSchuechtern;

  /// No description provided for @optZielstrebig.
  ///
  /// In en, this message translates to:
  /// **'Determined'**
  String get optZielstrebig;

  /// No description provided for @optAbenteuerlustig.
  ///
  /// In en, this message translates to:
  /// **'Adventurous'**
  String get optAbenteuerlustig;

  /// No description provided for @optEmpathisch.
  ///
  /// In en, this message translates to:
  /// **'Empathetic'**
  String get optEmpathisch;

  /// No description provided for @optLoyal.
  ///
  /// In en, this message translates to:
  /// **'Loyal'**
  String get optLoyal;

  /// No description provided for @optIntSportFitness.
  ///
  /// In en, this message translates to:
  /// **'Sports & Fitness'**
  String get optIntSportFitness;

  /// No description provided for @optIntFamilyTime.
  ///
  /// In en, this message translates to:
  /// **'Time with family'**
  String get optIntFamilyTime;

  /// No description provided for @optIntCooking.
  ///
  /// In en, this message translates to:
  /// **'Cooking & Food'**
  String get optIntCooking;

  /// No description provided for @optIntTravel.
  ///
  /// In en, this message translates to:
  /// **'Travelling'**
  String get optIntTravel;

  /// No description provided for @optIntReading.
  ///
  /// In en, this message translates to:
  /// **'Reading & Learning'**
  String get optIntReading;

  /// No description provided for @optIntGaming.
  ///
  /// In en, this message translates to:
  /// **'Gaming & Movies'**
  String get optIntGaming;

  /// No description provided for @optIntMusic.
  ///
  /// In en, this message translates to:
  /// **'Music & Dancing'**
  String get optIntMusic;

  /// No description provided for @optIntNature.
  ///
  /// In en, this message translates to:
  /// **'Nature & Walks'**
  String get optIntNature;

  /// No description provided for @optIntCafe.
  ///
  /// In en, this message translates to:
  /// **'Café & Friends'**
  String get optIntCafe;

  /// No description provided for @optIntPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photography'**
  String get optIntPhoto;

  /// No description provided for @optIntCars.
  ///
  /// In en, this message translates to:
  /// **'Cars & Tech'**
  String get optIntCars;

  /// No description provided for @optIntArt.
  ///
  /// In en, this message translates to:
  /// **'Art & Design'**
  String get optIntArt;

  /// No description provided for @optSpFitness.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get optSpFitness;

  /// No description provided for @optSpFootball.
  ///
  /// In en, this message translates to:
  /// **'Football'**
  String get optSpFootball;

  /// No description provided for @optSpSwimming.
  ///
  /// In en, this message translates to:
  /// **'Swimming'**
  String get optSpSwimming;

  /// No description provided for @optSpJogging.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get optSpJogging;

  /// No description provided for @optSpYoga.
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get optSpYoga;

  /// No description provided for @optSpBoxing.
  ///
  /// In en, this message translates to:
  /// **'Boxing'**
  String get optSpBoxing;

  /// No description provided for @optSpBasketball.
  ///
  /// In en, this message translates to:
  /// **'Basketball'**
  String get optSpBasketball;

  /// No description provided for @optSpTennis.
  ///
  /// In en, this message translates to:
  /// **'Tennis'**
  String get optSpTennis;

  /// No description provided for @optSpMartial.
  ///
  /// In en, this message translates to:
  /// **'Martial arts'**
  String get optSpMartial;

  /// No description provided for @optSpDancing.
  ///
  /// In en, this message translates to:
  /// **'Dancing'**
  String get optSpDancing;

  /// No description provided for @optSpCycling.
  ///
  /// In en, this message translates to:
  /// **'Cycling'**
  String get optSpCycling;

  /// No description provided for @optSpHiking.
  ///
  /// In en, this message translates to:
  /// **'Hiking'**
  String get optSpHiking;

  /// No description provided for @optTrBeach.
  ///
  /// In en, this message translates to:
  /// **'Beach holiday'**
  String get optTrBeach;

  /// No description provided for @optTrCity.
  ///
  /// In en, this message translates to:
  /// **'City trips'**
  String get optTrCity;

  /// No description provided for @optTrActive.
  ///
  /// In en, this message translates to:
  /// **'Active holiday'**
  String get optTrActive;

  /// No description provided for @optTrCamping.
  ///
  /// In en, this message translates to:
  /// **'Camping & Nature'**
  String get optTrCamping;

  /// No description provided for @optTrWellness.
  ///
  /// In en, this message translates to:
  /// **'Wellness'**
  String get optTrWellness;

  /// No description provided for @optTrBackpacking.
  ///
  /// In en, this message translates to:
  /// **'Backpacking'**
  String get optTrBackpacking;

  /// No description provided for @optTrFamily.
  ///
  /// In en, this message translates to:
  /// **'Family holiday'**
  String get optTrFamily;

  /// No description provided for @optTrCruise.
  ///
  /// In en, this message translates to:
  /// **'Cruise'**
  String get optTrCruise;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'de',
        'en',
        'fa',
        'fr',
        'hy',
        'ka',
        'nl',
        'ru',
        'sv',
        'tr'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
    case 'fr':
      return AppLocalizationsFr();
    case 'hy':
      return AppLocalizationsHy();
    case 'ka':
      return AppLocalizationsKa();
    case 'nl':
      return AppLocalizationsNl();
    case 'ru':
      return AppLocalizationsRu();
    case 'sv':
      return AppLocalizationsSv();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
