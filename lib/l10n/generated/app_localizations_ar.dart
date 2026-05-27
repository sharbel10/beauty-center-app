// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'تطبيق لومينا';

  @override
  String get lumina => 'لومينا';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get apply => 'تطبيق';

  @override
  String get reset => 'إعادة ضبط';

  @override
  String get all => 'الكل';

  @override
  String get min => 'الحد الأدنى';

  @override
  String get max => 'الحد الأقصى';

  @override
  String get book => 'احجز';

  @override
  String get top => 'مميز';

  @override
  String get home => 'الرئيسية';

  @override
  String get explore => 'استكشف';

  @override
  String get bookings => 'الحجوزات';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get aiScan => 'فحص AI';

  @override
  String get emailAddress => 'البريد الإلكتروني';

  @override
  String get emailHint => 'name@example.com';

  @override
  String get password => 'كلمة المرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get verificationCode => 'رمز التحقق';

  @override
  String get backToLogin => 'العودة إلى تسجيل الدخول';

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String get checkEnteredData => 'تحقق من البيانات المدخلة.';

  @override
  String get loginFailed => 'فشل تسجيل الدخول';

  @override
  String get registrationFailed => 'فشل إنشاء الحساب';

  @override
  String get requestFailed => 'فشل الطلب';

  @override
  String get verificationFailed => 'فشل التحقق';

  @override
  String get resetFailed => 'فشلت إعادة التعيين';

  @override
  String get emailRequiredToProceed => 'البريد الإلكتروني مطلوب للمتابعة.';

  @override
  String get emailNotFound => 'لم يتم العثور على البريد الإلكتروني';

  @override
  String get otpSentSuccessfully => 'تم إرسال رمز التحقق بنجاح.';

  @override
  String get failedToResendOtp => 'فشل إرسال رمز التحقق مرة أخرى.';

  @override
  String get signInToContinue => 'سجل دخولك للمتابعة';

  @override
  String get accessYourLuminaAccount => 'ادخل إلى حسابك في لومينا.';

  @override
  String get enterYourPassword => 'أدخل كلمة المرور';

  @override
  String get forgotPasswordQuestion => 'نسيت كلمة المرور؟';

  @override
  String get rememberMe => 'تذكرني';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟ ';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get joinLumina => 'انضم إلى لومينا';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get fullNameHint => 'Jane Doe';

  @override
  String get registerEmailHint => 'jane@example.com';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get phoneHint => '+1 (555) 000-0000';

  @override
  String get createPassword => 'أنشئ كلمة مرور';

  @override
  String get confirmYourPassword => 'أكد كلمة المرور';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟ ';

  @override
  String get forgotPassword => 'نسيت كلمة المرور';

  @override
  String get recoverYourAccount => 'استعد حسابك';

  @override
  String get sendVerificationCode => 'إرسال رمز التحقق';

  @override
  String get enterYourEmailAddress => 'أدخل بريدك الإلكتروني.';

  @override
  String get sendCode => 'إرسال الرمز';

  @override
  String get otpVerification => 'التحقق من الرمز';

  @override
  String get secureAccountRecovery => 'استرداد آمن للحساب';

  @override
  String get enterCode => 'أدخل الرمز';

  @override
  String get yourEmail => 'بريدك الإلكتروني';

  @override
  String otpEmailMessage(String email) {
    return 'أدخل الرمز المكون من 6 أرقام الذي تم إرساله إلى $email.';
  }

  @override
  String get verifyCode => 'تحقق من الرمز';

  @override
  String get verifyAccount => 'تأكيد الحساب';

  @override
  String get completeRegistration => 'أكمل تسجيلك';

  @override
  String get registrationCode => 'رمز التسجيل';

  @override
  String get registrationCodeHelp =>
      'أدخل الرمز المكون من 6 أرقام الذي تم إرساله بعد إنشاء حسابك.';

  @override
  String get codeValidTenMinutes => 'الرمز صالح لمدة 10 دقائق';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get createNewPassword => 'أنشئ كلمة مرور جديدة';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get choosePasswordForAccount => 'اختر كلمة مرور لحسابك.';

  @override
  String get enterNewPassword => 'أدخل كلمة المرور الجديدة';

  @override
  String get confirmNewPassword => 'أكد كلمة المرور الجديدة';

  @override
  String get validationFullName => 'أدخل اسمك الكامل.';

  @override
  String get validationEmailRequired => 'البريد الإلكتروني مطلوب.';

  @override
  String get validationEmailInvalid => 'أدخل بريدًا إلكترونيًا صحيحًا.';

  @override
  String get validationPhoneRequired => 'رقم الهاتف مطلوب.';

  @override
  String get validationPhoneInvalid => 'أدخل رقم هاتف صحيحًا.';

  @override
  String get validationEmailOrPhoneRequired =>
      'البريد الإلكتروني أو الهاتف مطلوب.';

  @override
  String get validationEmailOrPhoneInvalid =>
      'أدخل بريدًا إلكترونيًا أو رقم هاتف صحيحًا.';

  @override
  String get validationPasswordRequired => 'كلمة المرور مطلوبة.';

  @override
  String get validationPasswordLength =>
      'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل.';

  @override
  String get validationOtp => 'أدخل رمز التحقق المكون من 6 أرقام.';

  @override
  String get validationConfirmPasswordRequired => 'أكد كلمة المرور.';

  @override
  String get validationPasswordsDoNotMatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get onboardingDiscoverClinics => 'اكتشف العيادات';

  @override
  String get onboardingDiscoverTitle =>
      'اعثر على مراكز تجميل موثوقة بالقرب منك.';

  @override
  String get onboardingDiscoverSubtitle =>
      'استكشف الخدمات والأخصائيين والمواعيد المتاحة من مكان واحد.';

  @override
  String get onboardingBookVisits => 'احجز الزيارات';

  @override
  String get onboardingBookTitle => 'حدد موعد رعايتك بدون مكالمات إضافية.';

  @override
  String get onboardingBookSubtitle =>
      'اختر علاجك وحدد الوقت واحتفظ بتفاصيل حجزك منظمة.';

  @override
  String get onboardingPersonalCare => 'رعاية شخصية';

  @override
  String get onboardingPersonalTitle => 'تابع رحلة جمالك بوضوح.';

  @override
  String get onboardingPersonalSubtitle =>
      'راجع المواعيد وملاحظات المتابعة بتجربة بسيطة.';

  @override
  String get skip => 'تخطي';

  @override
  String get next => 'التالي';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get welcomeBack => 'مرحبًا بعودتك';

  @override
  String get guest => 'ضيف';

  @override
  String get searchClinicsOrTreatments => 'ابحث عن عيادات أو علاجات...';

  @override
  String get nearbyClinics => 'العيادات القريبة';

  @override
  String get specialPromotions => 'العروض الخاصة';

  @override
  String get discoverMoreClinics => 'اكتشف المزيد من العيادات';

  @override
  String get unableToLoadHomeData => 'تعذر تحميل بيانات الصفحة الرئيسية.';

  @override
  String get exclusive => 'حصري';

  @override
  String get hotDeal => 'عرض مميز';

  @override
  String get claimOffer => 'احصل على العرض';

  @override
  String get off => 'خصم';

  @override
  String reviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تقييم',
      many: '$count تقييمًا',
      few: '$count تقييمات',
      two: 'تقييمان',
      one: 'تقييم واحد',
      zero: 'لا توجد تقييمات بعد',
    );
    return '$_temp0';
  }

  @override
  String get couldNotOpenMapsForLocation => 'تعذر فتح الخرائط لهذا الموقع.';

  @override
  String get locationUnavailableForClinic => 'الموقع غير متاح لهذه العيادة.';

  @override
  String get allClinics => 'كل العيادات';

  @override
  String get loadMore => 'تحميل المزيد';

  @override
  String get searchClinics => 'ابحث عن عيادات...';

  @override
  String get filters => 'الفلاتر';

  @override
  String priceRangeFilter(int min, int max) {
    return '\$$min - \$$max';
  }

  @override
  String get couldNotOpenMaps => 'تعذر فتح الخرائط.';

  @override
  String get clinicCenter => 'مركز عيادة';

  @override
  String get viewAndBook => 'عرض وحجز';

  @override
  String get clinicDetailsComingSoon => 'سيتم ربط تفاصيل العيادة لاحقًا.';

  @override
  String get topPick => 'اختيار مميز';

  @override
  String get clinic => 'عيادة';

  @override
  String get area => 'المنطقة';

  @override
  String get distance => 'المسافة';

  @override
  String get notAvailable => 'غير متاح';

  @override
  String get noClinicsFound => 'لم يتم العثور على عيادات.';

  @override
  String get categories => 'الفئات';

  @override
  String get pricing => 'الأسعار';
}
