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

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get changeLanguage;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

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
  /// **'SP {min} - SP {max}'**
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

  /// No description provided for @clinicGalleryExperienceEyebrow.
  ///
  /// In en, this message translates to:
  /// **'THE EXPERIENCE'**
  String get clinicGalleryExperienceEyebrow;

  /// No description provided for @clinicGalleryInteriorTitle.
  ///
  /// In en, this message translates to:
  /// **'Clinic Interior'**
  String get clinicGalleryInteriorTitle;

  /// No description provided for @clinicGalleryNoInteriorPhotos.
  ///
  /// In en, this message translates to:
  /// **'No interior photos available'**
  String get clinicGalleryNoInteriorPhotos;

  /// No description provided for @clinicGalleryResultsEyebrow.
  ///
  /// In en, this message translates to:
  /// **'REAL RESULTS'**
  String get clinicGalleryResultsEyebrow;

  /// No description provided for @clinicGalleryTransformationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Transformations'**
  String get clinicGalleryTransformationsTitle;

  /// No description provided for @clinicGalleryDefaultTransformationCaption.
  ///
  /// In en, this message translates to:
  /// **'Clinical Transformation Result'**
  String get clinicGalleryDefaultTransformationCaption;

  /// No description provided for @clinicGalleryResultBadge.
  ///
  /// In en, this message translates to:
  /// **'RESULT'**
  String get clinicGalleryResultBadge;

  /// No description provided for @clinicGalleryBeforeLabel.
  ///
  /// In en, this message translates to:
  /// **'BEFORE'**
  String get clinicGalleryBeforeLabel;

  /// No description provided for @clinicGalleryAfterLabel.
  ///
  /// In en, this message translates to:
  /// **'AFTER'**
  String get clinicGalleryAfterLabel;

  /// No description provided for @clinicGalleryNoTransformations.
  ///
  /// In en, this message translates to:
  /// **'No Transformations Logged Yet'**
  String get clinicGalleryNoTransformations;

  /// No description provided for @clinicGalleryPrecisionEyebrow.
  ///
  /// In en, this message translates to:
  /// **'CLINICAL PRECISION'**
  String get clinicGalleryPrecisionEyebrow;

  /// No description provided for @clinicGalleryProceduresTitle.
  ///
  /// In en, this message translates to:
  /// **'Skin Procedures'**
  String get clinicGalleryProceduresTitle;

  /// No description provided for @clinicGalleryNoProcedures.
  ///
  /// In en, this message translates to:
  /// **'No Procedures Available'**
  String get clinicGalleryNoProcedures;

  /// No description provided for @clinicDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Clinic Details'**
  String get clinicDetailsTitle;

  /// No description provided for @clinicDetailsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load clinic details.'**
  String get clinicDetailsLoadFailed;

  /// No description provided for @clinicTabOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get clinicTabOverview;

  /// No description provided for @clinicTabServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get clinicTabServices;

  /// No description provided for @clinicTabGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get clinicTabGallery;

  /// No description provided for @clinicTabInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get clinicTabInfo;

  /// No description provided for @clinicTopRated.
  ///
  /// In en, this message translates to:
  /// **'TOP RATED'**
  String get clinicTopRated;

  /// No description provided for @clinicHeroRatingReviews.
  ///
  /// In en, this message translates to:
  /// **'{rating} ({reviews})'**
  String clinicHeroRatingReviews(String rating, String reviews);

  /// No description provided for @clinicAbout.
  ///
  /// In en, this message translates to:
  /// **'About Clinic'**
  String get clinicAbout;

  /// No description provided for @clinicLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get clinicLocation;

  /// No description provided for @clinicSpecialOffers.
  ///
  /// In en, this message translates to:
  /// **'Special Offers'**
  String get clinicSpecialOffers;

  /// No description provided for @clinicOurSpecialists.
  ///
  /// In en, this message translates to:
  /// **'Our Specialists'**
  String get clinicOurSpecialists;

  /// No description provided for @clinicNoOffersTitle.
  ///
  /// In en, this message translates to:
  /// **'No Offers Available Right Now'**
  String get clinicNoOffersTitle;

  /// No description provided for @clinicNoOffersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stay tuned! Exclusive clinic discounts will appear here.'**
  String get clinicNoOffersSubtitle;

  /// No description provided for @clinicNoSpecialists.
  ///
  /// In en, this message translates to:
  /// **'No specialists available right now.'**
  String get clinicNoSpecialists;

  /// No description provided for @clinicNoServices.
  ///
  /// In en, this message translates to:
  /// **'No services available for this center.'**
  String get clinicNoServices;

  /// No description provided for @clinicServicesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 SERVICE} other{{count} SERVICES}}'**
  String clinicServicesCount(int count);

  /// No description provided for @clinicServiceBadgeOffer.
  ///
  /// In en, this message translates to:
  /// **'OFFER'**
  String get clinicServiceBadgeOffer;

  /// No description provided for @clinicServiceBadgeBestSeller.
  ///
  /// In en, this message translates to:
  /// **'BEST SELLER'**
  String get clinicServiceBadgeBestSeller;

  /// No description provided for @clinicServiceBadgeFeatured.
  ///
  /// In en, this message translates to:
  /// **'FEATURED'**
  String get clinicServiceBadgeFeatured;

  /// No description provided for @clinicBookAppointment.
  ///
  /// In en, this message translates to:
  /// **'BOOK APPOINTMENT'**
  String get clinicBookAppointment;

  /// No description provided for @clinicInstantConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Instant Confirmation'**
  String get clinicInstantConfirmation;

  /// No description provided for @clinicRequiresApproval.
  ///
  /// In en, this message translates to:
  /// **'Requires Approval'**
  String get clinicRequiresApproval;

  /// No description provided for @clinicNoDepositRequired.
  ///
  /// In en, this message translates to:
  /// **'No Deposit Required'**
  String get clinicNoDepositRequired;

  /// No description provided for @clinicDepositPercentage.
  ///
  /// In en, this message translates to:
  /// **'Required Deposit: {value}%'**
  String clinicDepositPercentage(int value);

  /// No description provided for @clinicDepositAmount.
  ///
  /// In en, this message translates to:
  /// **'Deposit: SP {value}'**
  String clinicDepositAmount(int value);

  /// No description provided for @clinicHours.
  ///
  /// In en, this message translates to:
  /// **'Clinic Hours'**
  String get clinicHours;

  /// No description provided for @clinicClosedToday.
  ///
  /// In en, this message translates to:
  /// **'Closed Today'**
  String get clinicClosedToday;

  /// No description provided for @clinicOpenTodayUntil.
  ///
  /// In en, this message translates to:
  /// **'Open Today | Until {time}'**
  String clinicOpenTodayUntil(String time);

  /// No description provided for @clinicClosed.
  ///
  /// In en, this message translates to:
  /// **'CLOSED'**
  String get clinicClosed;

  /// No description provided for @clinicNoWorkingHours.
  ///
  /// In en, this message translates to:
  /// **'No working hours provided.'**
  String get clinicNoWorkingHours;

  /// No description provided for @dayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get dayMonday;

  /// No description provided for @dayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get dayTuesday;

  /// No description provided for @dayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get dayWednesday;

  /// No description provided for @dayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get dayThursday;

  /// No description provided for @dayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get dayFriday;

  /// No description provided for @daySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get daySaturday;

  /// No description provided for @daySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get daySunday;

  /// No description provided for @dayUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get dayUnknown;

  /// No description provided for @dayTodayMarker.
  ///
  /// In en, this message translates to:
  /// **'(Today)'**
  String get dayTodayMarker;

  /// No description provided for @clinicContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get clinicContact;

  /// No description provided for @clinicPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get clinicPhone;

  /// No description provided for @clinicEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get clinicEmail;

  /// No description provided for @clinicWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get clinicWebsite;

  /// No description provided for @clinicCallNow.
  ///
  /// In en, this message translates to:
  /// **'CALL NOW'**
  String get clinicCallNow;

  /// No description provided for @clinicCancellationPolicy.
  ///
  /// In en, this message translates to:
  /// **'Cancellation Policy'**
  String get clinicCancellationPolicy;

  /// No description provided for @clinicCancellationIntro.
  ///
  /// In en, this message translates to:
  /// **'We value your time and our practitioners\' expertise. This center applies a {policyType} cancellation policy.'**
  String clinicCancellationIntro(String policyType);

  /// No description provided for @clinicCancellationFree.
  ///
  /// In en, this message translates to:
  /// **'Cancellations are completely free of charge if made at least {hours} hours prior to your appointment window.'**
  String clinicCancellationFree(int hours);

  /// No description provided for @clinicCancellationFee.
  ///
  /// In en, this message translates to:
  /// **'Late cancellations within {hours} hours are subject to a fee equal to {percentage}% of the scheduled service price. No-shows will be charged at 100%.'**
  String clinicCancellationFee(int hours, int percentage);

  /// No description provided for @clinicPolicyStandard.
  ///
  /// In en, this message translates to:
  /// **'STANDARD'**
  String get clinicPolicyStandard;

  /// No description provided for @limitedTime.
  ///
  /// In en, this message translates to:
  /// **'Limited Time'**
  String get limitedTime;

  /// No description provided for @limitedTimeLower.
  ///
  /// In en, this message translates to:
  /// **'Limited time'**
  String get limitedTimeLower;

  /// No description provided for @offerUntilDate.
  ///
  /// In en, this message translates to:
  /// **'Until {date}'**
  String offerUntilDate(String date);

  /// No description provided for @offerDiscountPercent.
  ///
  /// In en, this message translates to:
  /// **'{value}% OFF'**
  String offerDiscountPercent(int value);

  /// No description provided for @offerDiscountAmount.
  ///
  /// In en, this message translates to:
  /// **'SP{value} OFF'**
  String offerDiscountAmount(int value);

  /// No description provided for @clinicOfferClaim.
  ///
  /// In en, this message translates to:
  /// **'Claim'**
  String get clinicOfferClaim;

  /// No description provided for @clinicDurationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String clinicDurationMinutes(int minutes);

  /// No description provided for @clinicPrepMinutes.
  ///
  /// In en, this message translates to:
  /// **'+ {minutes} min prep'**
  String clinicPrepMinutes(int minutes);

  /// No description provided for @priceSp.
  ///
  /// In en, this message translates to:
  /// **'{price} SP'**
  String priceSp(String price);

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'CLEAR ALL'**
  String get clearAll;

  /// No description provided for @filterServiceType.
  ///
  /// In en, this message translates to:
  /// **'Service Type'**
  String get filterServiceType;

  /// No description provided for @filterPriceRange.
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get filterPriceRange;

  /// No description provided for @filterFacialTreatment.
  ///
  /// In en, this message translates to:
  /// **'Facial Treatment'**
  String get filterFacialTreatment;

  /// No description provided for @filterBotoxFillers.
  ///
  /// In en, this message translates to:
  /// **'Botox & Fillers'**
  String get filterBotoxFillers;

  /// No description provided for @filterLaserHairRemoval.
  ///
  /// In en, this message translates to:
  /// **'Laser Hair Removal'**
  String get filterLaserHairRemoval;

  /// No description provided for @filterBodyContouring.
  ///
  /// In en, this message translates to:
  /// **'Body Contouring'**
  String get filterBodyContouring;

  /// No description provided for @filterChemicalPeel.
  ///
  /// In en, this message translates to:
  /// **'Chemical Peel'**
  String get filterChemicalPeel;

  /// No description provided for @filterLocationBeverlyHills.
  ///
  /// In en, this message translates to:
  /// **'Beverly Hills, CA'**
  String get filterLocationBeverlyHills;

  /// No description provided for @filterLocationSantaMonica.
  ///
  /// In en, this message translates to:
  /// **'Santa Monica'**
  String get filterLocationSantaMonica;

  /// No description provided for @filterLocationWestHollywood.
  ///
  /// In en, this message translates to:
  /// **'West Hollywood'**
  String get filterLocationWestHollywood;

  /// No description provided for @filterLocationDowntownLa.
  ///
  /// In en, this message translates to:
  /// **'Downtown LA'**
  String get filterLocationDowntownLa;

  /// No description provided for @filterLocationMalibu.
  ///
  /// In en, this message translates to:
  /// **'Malibu'**
  String get filterLocationMalibu;

  /// No description provided for @priceUsd.
  ///
  /// In en, this message translates to:
  /// **'\${value}'**
  String priceUsd(int value);

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @yourLocation.
  ///
  /// In en, this message translates to:
  /// **'YOUR LOCATION'**
  String get yourLocation;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @unverified.
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get unverified;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @unableToLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Unable to load profile.'**
  String get unableToLoadProfile;

  /// No description provided for @noSpecialPromotionsTitle.
  ///
  /// In en, this message translates to:
  /// **'No special promotions right now'**
  String get noSpecialPromotionsTitle;

  /// No description provided for @noSpecialPromotionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check back soon for exclusive offers from clinics near you.'**
  String get noSpecialPromotionsSubtitle;

  /// No description provided for @findingYourLocation.
  ///
  /// In en, this message translates to:
  /// **'Finding your location...'**
  String get findingYourLocation;

  /// No description provided for @locationServicesOff.
  ///
  /// In en, this message translates to:
  /// **'Location services off'**
  String get locationServicesOff;

  /// No description provided for @enableLocation.
  ///
  /// In en, this message translates to:
  /// **'Enable location'**
  String get enableLocation;

  /// No description provided for @locationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable'**
  String get locationUnavailable;

  /// No description provided for @myAppointments.
  ///
  /// In en, this message translates to:
  /// **'My Appointments'**
  String get myAppointments;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @past.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get past;

  /// No description provided for @next30Days.
  ///
  /// In en, this message translates to:
  /// **'NEXT 30 DAYS'**
  String get next30Days;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'HISTORY'**
  String get history;

  /// No description provided for @noUpcomingAppointments.
  ///
  /// In en, this message translates to:
  /// **'No upcoming appointments.'**
  String get noUpcomingAppointments;

  /// No description provided for @noPastAppointments.
  ///
  /// In en, this message translates to:
  /// **'No past appointments.'**
  String get noPastAppointments;

  /// No description provided for @cancelAppointment.
  ///
  /// In en, this message translates to:
  /// **'Cancel appointment?'**
  String get cancelAppointment;

  /// No description provided for @cancelAppointmentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this appointment?'**
  String get cancelAppointmentConfirm;

  /// No description provided for @cancelAppointmentAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel Appointment'**
  String get cancelAppointmentAction;

  /// No description provided for @keep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get keep;

  /// No description provided for @clinicMissingForAppointment.
  ///
  /// In en, this message translates to:
  /// **'Clinic is missing for this appointment.'**
  String get clinicMissingForAppointment;

  /// No description provided for @reschedule.
  ///
  /// In en, this message translates to:
  /// **'Reschedule'**
  String get reschedule;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// No description provided for @rebook.
  ///
  /// In en, this message translates to:
  /// **'Rebook'**
  String get rebook;

  /// No description provided for @appointmentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Appointment cancelled successfully.'**
  String get appointmentCancelled;

  /// No description provided for @emailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Email or Phone'**
  String get emailOrPhone;

  /// No description provided for @emailOrPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Email or phone number'**
  String get emailOrPhoneHint;

  /// No description provided for @bookTreatment.
  ///
  /// In en, this message translates to:
  /// **'Book Treatment'**
  String get bookTreatment;

  /// No description provided for @selectService.
  ///
  /// In en, this message translates to:
  /// **'Select Service'**
  String get selectService;

  /// No description provided for @selectServiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick the treatment you want to book'**
  String get selectServiceSubtitle;

  /// No description provided for @chooseSpecialist.
  ///
  /// In en, this message translates to:
  /// **'Choose Specialist'**
  String get chooseSpecialist;

  /// No description provided for @chooseSpecialistSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional — leave \"Any\" for the earliest availability'**
  String get chooseSpecialistSubtitle;

  /// No description provided for @anySpecialist.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get anySpecialist;

  /// No description provided for @anySpecialistName.
  ///
  /// In en, this message translates to:
  /// **'Any specialist'**
  String get anySpecialistName;

  /// No description provided for @otherCategory.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherCategory;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @selectDateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a day for your appointment'**
  String get selectDateSubtitle;

  /// No description provided for @calendarMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get calendarMonth;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// No description provided for @changeDate.
  ///
  /// In en, this message translates to:
  /// **'Change date'**
  String get changeDate;

  /// No description provided for @couldNotLoadAvailableTimes.
  ///
  /// In en, this message translates to:
  /// **'Could not load available times.'**
  String get couldNotLoadAvailableTimes;

  /// No description provided for @noAvailableTimesOnDate.
  ///
  /// In en, this message translates to:
  /// **'No available times on this date.'**
  String get noAvailableTimesOnDate;

  /// No description provided for @specialistNoAvailability.
  ///
  /// In en, this message translates to:
  /// **'{name} has no availability on this date.'**
  String specialistNoAvailability(String name);

  /// No description provided for @tryAnySpecialist.
  ///
  /// In en, this message translates to:
  /// **'Try any specialist'**
  String get tryAnySpecialist;

  /// No description provided for @pickAnotherDate.
  ///
  /// In en, this message translates to:
  /// **'Pick another date'**
  String get pickAnotherDate;

  /// No description provided for @morningPeriod.
  ///
  /// In en, this message translates to:
  /// **'MORNING'**
  String get morningPeriod;

  /// No description provided for @afternoonPeriod.
  ///
  /// In en, this message translates to:
  /// **'AFTERNOON'**
  String get afternoonPeriod;

  /// No description provided for @bookingSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get bookingSummary;

  /// No description provided for @serviceLabel.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get serviceLabel;

  /// No description provided for @specialistLabel.
  ///
  /// In en, this message translates to:
  /// **'Specialist'**
  String get specialistLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @estimatedTotal.
  ///
  /// In en, this message translates to:
  /// **'Estimated Total'**
  String get estimatedTotal;

  /// No description provided for @bookingTotal.
  ///
  /// In en, this message translates to:
  /// **'Total  {total}'**
  String bookingTotal(String total);

  /// No description provided for @chooseATime.
  ///
  /// In en, this message translates to:
  /// **'Choose a time'**
  String get chooseATime;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @confirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get confirmBooking;

  /// No description provided for @confirmReschedule.
  ///
  /// In en, this message translates to:
  /// **'Confirm Reschedule'**
  String get confirmReschedule;

  /// No description provided for @noServicesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No services available for this clinic.'**
  String get noServicesAvailable;

  /// No description provided for @pleaseChooseServiceDateTime.
  ///
  /// In en, this message translates to:
  /// **'Please choose a service, date, and time.'**
  String get pleaseChooseServiceDateTime;

  /// No description provided for @appointmentBookedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Appointment booked successfully.'**
  String get appointmentBookedSuccessfully;

  /// No description provided for @appointmentDetails.
  ///
  /// In en, this message translates to:
  /// **'Appointment details'**
  String get appointmentDetails;

  /// No description provided for @clinicLabel.
  ///
  /// In en, this message translates to:
  /// **'Clinic'**
  String get clinicLabel;

  /// No description provided for @depositLabel.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get depositLabel;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @cancellationReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancellation reason'**
  String get cancellationReasonLabel;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmed;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @errorNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network and try again.'**
  String get errorNoInternet;

  /// No description provided for @errorServerUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server. Please try again later.'**
  String get errorServerUnavailable;

  /// No description provided for @errorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorUnexpected;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDate;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @notificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications Enabled'**
  String get notificationsEnabled;

  /// No description provided for @myStats.
  ///
  /// In en, this message translates to:
  /// **'My Stats'**
  String get myStats;

  /// No description provided for @appointmentsTotal.
  ///
  /// In en, this message translates to:
  /// **'Total Appointments'**
  String get appointmentsTotal;

  /// No description provided for @appointmentsUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Appointments'**
  String get appointmentsUpcoming;

  /// No description provided for @appointmentsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed Appointments'**
  String get appointmentsCompleted;

  /// No description provided for @favoriteCenters.
  ///
  /// In en, this message translates to:
  /// **'Favorite Centers'**
  String get favoriteCenters;

  /// No description provided for @favoriteServices.
  ///
  /// In en, this message translates to:
  /// **'Favorite Services'**
  String get favoriteServices;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @unreadNotifications.
  ///
  /// In en, this message translates to:
  /// **'Unread Notifications'**
  String get unreadNotifications;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully.'**
  String get profileUpdatedSuccessfully;

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

  /// No description provided for @changeAvatar.
  ///
  /// In en, this message translates to:
  /// **'Change Avatar'**
  String get changeAvatar;

  /// No description provided for @uploadAvatar.
  ///
  /// In en, this message translates to:
  /// **'Upload Avatar'**
  String get uploadAvatar;

  /// No description provided for @avatarUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Avatar updated successfully.'**
  String get avatarUpdatedSuccessfully;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get deleteAccountConfirm;

  /// No description provided for @accountDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully.'**
  String get accountDeletedSuccessfully;

  /// No description provided for @selectImage.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get selectImage;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully.'**
  String get passwordChangedSuccessfully;

  /// No description provided for @passwordChangedReLogin.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully. Please log in again.'**
  String get passwordChangedReLogin;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @currentPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Current password is required.'**
  String get currentPasswordRequired;

  /// No description provided for @newPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'New password is required.'**
  String get newPasswordRequired;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password.'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get passwordTooShort;

  /// No description provided for @lastLogin.
  ///
  /// In en, this message translates to:
  /// **'Last Login'**
  String get lastLogin;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @centers.
  ///
  /// In en, this message translates to:
  /// **'Centers'**
  String get centers;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @offers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get offers;

  /// No description provided for @noFavoriteCenters.
  ///
  /// In en, this message translates to:
  /// **'No favorite centers'**
  String get noFavoriteCenters;

  /// No description provided for @noFavoriteCentersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start adding centers to your favorites to see them here.'**
  String get noFavoriteCentersSubtitle;

  /// No description provided for @noFavoriteServices.
  ///
  /// In en, this message translates to:
  /// **'No favorite services'**
  String get noFavoriteServices;

  /// No description provided for @noFavoriteServicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start adding services to your favorites to see them here.'**
  String get noFavoriteServicesSubtitle;

  /// No description provided for @exploreAndAddFavorites.
  ///
  /// In en, this message translates to:
  /// **'Explore and add to favorites'**
  String get exploreAndAddFavorites;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @noResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results for'**
  String get noResultsFor;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'SYP'**
  String get currency;

  /// No description provided for @pressBackAgainToExit.
  ///
  /// In en, this message translates to:
  /// **'Press back again to exit the app'**
  String get pressBackAgainToExit;
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
