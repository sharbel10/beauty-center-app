import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Lumina App'**
  String get appTitle;

  /// No description provided for @lumina.
  ///
  /// In en, this message translates to:
  /// **'Lumina'**
  String get lumina;

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

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get min;

  /// No description provided for @max.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get max;

  /// No description provided for @book.
  ///
  /// In en, this message translates to:
  /// **'BOOK'**
  String get book;

  /// No description provided for @top.
  ///
  /// In en, this message translates to:
  /// **'TOP'**
  String get top;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'HOME'**
  String get home;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'EXPLORE'**
  String get explore;

  /// No description provided for @bookings.
  ///
  /// In en, this message translates to:
  /// **'BOOKINGS'**
  String get bookings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'PROFILE'**
  String get profile;

  /// No description provided for @aiScan.
  ///
  /// In en, this message translates to:
  /// **'AI SCAN'**
  String get aiScan;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get emailHint;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verificationCode;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @checkEnteredData.
  ///
  /// In en, this message translates to:
  /// **'Check the entered data.'**
  String get checkEnteredData;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registrationFailed;

  /// No description provided for @requestFailed.
  ///
  /// In en, this message translates to:
  /// **'Request failed'**
  String get requestFailed;

  /// No description provided for @verificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Verification failed'**
  String get verificationFailed;

  /// No description provided for @resetFailed.
  ///
  /// In en, this message translates to:
  /// **'Reset failed'**
  String get resetFailed;

  /// No description provided for @emailRequiredToProceed.
  ///
  /// In en, this message translates to:
  /// **'Email is required to proceed.'**
  String get emailRequiredToProceed;

  /// No description provided for @emailNotFound.
  ///
  /// In en, this message translates to:
  /// **'Email not found'**
  String get emailNotFound;

  /// No description provided for @otpSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'OTP sent successfully.'**
  String get otpSentSuccessfully;

  /// No description provided for @failedToResendOtp.
  ///
  /// In en, this message translates to:
  /// **'Failed to resend OTP.'**
  String get failedToResendOtp;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @accessYourLuminaAccount.
  ///
  /// In en, this message translates to:
  /// **'Access your Lumina account.'**
  String get accessYourLuminaAccount;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @forgotPasswordQuestion.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordQuestion;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @joinLumina.
  ///
  /// In en, this message translates to:
  /// **'Join Lumina'**
  String get joinLumina;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Jane Doe'**
  String get fullNameHint;

  /// No description provided for @registerEmailHint.
  ///
  /// In en, this message translates to:
  /// **'jane@example.com'**
  String get registerEmailHint;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'+1 (555) 000-0000'**
  String get phoneHint;

  /// No description provided for @createPassword.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get createPassword;

  /// No description provided for @confirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmYourPassword;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @recoverYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Recover your account'**
  String get recoverYourAccount;

  /// No description provided for @sendVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Send Verification Code'**
  String get sendVerificationCode;

  /// No description provided for @enterYourEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address.'**
  String get enterYourEmailAddress;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendCode;

  /// No description provided for @otpVerification.
  ///
  /// In en, this message translates to:
  /// **'OTP Verification'**
  String get otpVerification;

  /// No description provided for @secureAccountRecovery.
  ///
  /// In en, this message translates to:
  /// **'Secure account recovery'**
  String get secureAccountRecovery;

  /// No description provided for @enterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Code'**
  String get enterCode;

  /// No description provided for @yourEmail.
  ///
  /// In en, this message translates to:
  /// **'your email'**
  String get yourEmail;

  /// No description provided for @otpEmailMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to {email}.'**
  String otpEmailMessage(String email);

  /// No description provided for @verifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify Code'**
  String get verifyCode;

  /// No description provided for @verifyAccount.
  ///
  /// In en, this message translates to:
  /// **'Verify Account'**
  String get verifyAccount;

  /// No description provided for @completeRegistration.
  ///
  /// In en, this message translates to:
  /// **'Complete your registration'**
  String get completeRegistration;

  /// No description provided for @registrationCode.
  ///
  /// In en, this message translates to:
  /// **'Registration Code'**
  String get registrationCode;

  /// No description provided for @registrationCodeHelp.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent after creating your account.'**
  String get registrationCodeHelp;

  /// No description provided for @codeValidTenMinutes.
  ///
  /// In en, this message translates to:
  /// **'The code is valid for 10 minutes'**
  String get codeValidTenMinutes;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @createNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Create a new password'**
  String get createNewPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @choosePasswordForAccount.
  ///
  /// In en, this message translates to:
  /// **'Choose a password for your account.'**
  String get choosePasswordForAccount;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get enterNewPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// No description provided for @validationFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name.'**
  String get validationFullName;

  /// No description provided for @validationEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email address is required.'**
  String get validationEmailRequired;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get validationEmailInvalid;

  /// No description provided for @validationPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required.'**
  String get validationPhoneRequired;

  /// No description provided for @validationPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number.'**
  String get validationPhoneInvalid;

  /// No description provided for @validationEmailOrPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Email or phone is required.'**
  String get validationEmailOrPhoneRequired;

  /// No description provided for @validationEmailOrPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email or phone number.'**
  String get validationEmailOrPhoneInvalid;

  /// No description provided for @validationPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required.'**
  String get validationPasswordRequired;

  /// No description provided for @validationPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get validationPasswordLength;

  /// No description provided for @validationOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit verification code.'**
  String get validationOtp;

  /// No description provided for @validationConfirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password.'**
  String get validationConfirmPasswordRequired;

  /// No description provided for @validationPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get validationPasswordsDoNotMatch;

  /// No description provided for @onboardingDiscoverClinics.
  ///
  /// In en, this message translates to:
  /// **'Discover Clinics'**
  String get onboardingDiscoverClinics;

  /// No description provided for @onboardingDiscoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Find trusted beauty centers near you.'**
  String get onboardingDiscoverTitle;

  /// No description provided for @onboardingDiscoverSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore services, specialists, and available appointments from one place.'**
  String get onboardingDiscoverSubtitle;

  /// No description provided for @onboardingBookVisits.
  ///
  /// In en, this message translates to:
  /// **'Book Visits'**
  String get onboardingBookVisits;

  /// No description provided for @onboardingBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule your care without extra calls.'**
  String get onboardingBookTitle;

  /// No description provided for @onboardingBookSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your treatment, pick a time, and keep your booking details organized.'**
  String get onboardingBookSubtitle;

  /// No description provided for @onboardingPersonalCare.
  ///
  /// In en, this message translates to:
  /// **'Personal Care'**
  String get onboardingPersonalCare;

  /// No description provided for @onboardingPersonalTitle.
  ///
  /// In en, this message translates to:
  /// **'Track your beauty journey clearly.'**
  String get onboardingPersonalTitle;

  /// No description provided for @onboardingPersonalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review appointments and follow-up notes in a simple patient experience.'**
  String get onboardingPersonalSubtitle;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'WELCOME BACK'**
  String get welcomeBack;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @searchClinicsOrTreatments.
  ///
  /// In en, this message translates to:
  /// **'Search clinics or treatments...'**
  String get searchClinicsOrTreatments;

  /// No description provided for @nearbyClinics.
  ///
  /// In en, this message translates to:
  /// **'Nearby Clinics'**
  String get nearbyClinics;

  /// No description provided for @specialPromotions.
  ///
  /// In en, this message translates to:
  /// **'Special Promotions'**
  String get specialPromotions;

  /// No description provided for @discoverMoreClinics.
  ///
  /// In en, this message translates to:
  /// **'DISCOVER MORE CLINICS'**
  String get discoverMoreClinics;

  /// No description provided for @unableToLoadHomeData.
  ///
  /// In en, this message translates to:
  /// **'Unable to load home data.'**
  String get unableToLoadHomeData;

  /// No description provided for @exclusive.
  ///
  /// In en, this message translates to:
  /// **'EXCLUSIVE'**
  String get exclusive;

  /// No description provided for @hotDeal.
  ///
  /// In en, this message translates to:
  /// **'HOT DEAL'**
  String get hotDeal;

  /// No description provided for @claimOffer.
  ///
  /// In en, this message translates to:
  /// **'CLAIM OFFER'**
  String get claimOffer;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get off;

  /// No description provided for @reviewsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No reviews yet} one{1 review} other{{count} reviews}}'**
  String reviewsCount(int count);

  /// No description provided for @couldNotOpenMapsForLocation.
  ///
  /// In en, this message translates to:
  /// **'Could not open maps for this location.'**
  String get couldNotOpenMapsForLocation;

  /// No description provided for @locationUnavailableForClinic.
  ///
  /// In en, this message translates to:
  /// **'Location is not available for this clinic.'**
  String get locationUnavailableForClinic;

  /// No description provided for @allClinics.
  ///
  /// In en, this message translates to:
  /// **'All Clinics'**
  String get allClinics;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get loadMore;

  /// No description provided for @searchClinics.
  ///
  /// In en, this message translates to:
  /// **'Search clinics...'**
  String get searchClinics;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @priceRangeFilter.
  ///
  /// In en, this message translates to:
  /// **'\${min} - \${max}'**
  String priceRangeFilter(int min, int max);

  /// No description provided for @couldNotOpenMaps.
  ///
  /// In en, this message translates to:
  /// **'Could not open maps.'**
  String get couldNotOpenMaps;

  /// No description provided for @clinicCenter.
  ///
  /// In en, this message translates to:
  /// **'Clinic center'**
  String get clinicCenter;

  /// No description provided for @viewAndBook.
  ///
  /// In en, this message translates to:
  /// **'View & Book'**
  String get viewAndBook;

  /// No description provided for @clinicDetailsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Clinic details will be connected next.'**
  String get clinicDetailsComingSoon;

  /// No description provided for @topPick.
  ///
  /// In en, this message translates to:
  /// **'Top Pick'**
  String get topPick;

  /// No description provided for @clinic.
  ///
  /// In en, this message translates to:
  /// **'Clinic'**
  String get clinic;

  /// No description provided for @area.
  ///
  /// In en, this message translates to:
  /// **'AREA'**
  String get area;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'DISTANCE'**
  String get distance;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// No description provided for @noClinicsFound.
  ///
  /// In en, this message translates to:
  /// **'No clinics found.'**
  String get noClinicsFound;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @pricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get pricing;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
