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
  String get changeLanguage => 'تغيير اللغة';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get settings => 'الإعدادات';

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

  @override
  String get clinicGalleryExperienceEyebrow => 'التجربة';

  @override
  String get clinicGalleryInteriorTitle => 'داخل العيادة';

  @override
  String get clinicGalleryNoInteriorPhotos => 'لا توجد صور داخلية';

  @override
  String get clinicGalleryResultsEyebrow => 'نتائج حقيقية';

  @override
  String get clinicGalleryTransformationsTitle => 'التحولات';

  @override
  String get clinicGalleryDefaultTransformationCaption => 'نتيجة تحول سريري';

  @override
  String get clinicGalleryResultBadge => 'النتيجة';

  @override
  String get clinicGalleryBeforeLabel => 'قبل';

  @override
  String get clinicGalleryAfterLabel => 'بعد';

  @override
  String get clinicGalleryNoTransformations => 'لا توجد تحولات مسجلة بعد';

  @override
  String get clinicGalleryPrecisionEyebrow => 'دقة سريرية';

  @override
  String get clinicGalleryProceduresTitle => 'إجراءات البشرة';

  @override
  String get clinicGalleryNoProcedures => 'لا توجد إجراءات متاحة';

  @override
  String get clinicDetailsTitle => 'تفاصيل العيادة';

  @override
  String get clinicDetailsLoadFailed => 'تعذر تحميل تفاصيل العيادة.';

  @override
  String get clinicTabOverview => 'نظرة عامة';

  @override
  String get clinicTabServices => 'الخدمات';

  @override
  String get clinicTabGallery => 'المعرض';

  @override
  String get clinicTabInfo => 'معلومات';

  @override
  String get clinicTopRated => 'الأعلى تقييماً';

  @override
  String clinicHeroRatingReviews(String rating, String reviews) {
    return '$rating ($reviews)';
  }

  @override
  String get clinicAbout => 'عن العيادة';

  @override
  String get clinicLocation => 'الموقع';

  @override
  String get clinicSpecialOffers => 'عروض خاصة';

  @override
  String get clinicOurSpecialists => 'أخصائيونا';

  @override
  String get clinicNoOffersTitle => 'لا توجد عروض حالياً';

  @override
  String get clinicNoOffersSubtitle =>
      'ترقّب! ستظهر خصومات حصرية من العيادة هنا.';

  @override
  String get clinicNoSpecialists => 'لا يوجد أخصائيون متاحون حالياً.';

  @override
  String get clinicNoServices => 'لا توجد خدمات متاحة لهذا المركز.';

  @override
  String clinicServicesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count خدمات',
      one: 'خدمة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get clinicServiceBadgeOffer => 'عرض';

  @override
  String get clinicServiceBadgeBestSeller => 'الأكثر مبيعاً';

  @override
  String get clinicServiceBadgeFeatured => 'مميز';

  @override
  String get clinicBookAppointment => 'احجز موعداً';

  @override
  String get clinicInstantConfirmation => 'تأكيد فوري';

  @override
  String get clinicRequiresApproval => 'يتطلب موافقة';

  @override
  String get clinicNoDepositRequired => 'لا يُطلب عربون';

  @override
  String clinicDepositPercentage(int value) {
    return 'عربون مطلوب: $value%';
  }

  @override
  String clinicDepositAmount(int value) {
    return 'عربون: $value ل.س';
  }

  @override
  String get clinicHours => 'ساعات العمل';

  @override
  String get clinicClosedToday => 'مغلق اليوم';

  @override
  String clinicOpenTodayUntil(String time) {
    return 'مفتوح اليوم | حتى $time';
  }

  @override
  String get clinicClosed => 'مغلق';

  @override
  String get clinicNoWorkingHours => 'لم يتم توفير ساعات العمل.';

  @override
  String get dayMonday => 'الاثنين';

  @override
  String get dayTuesday => 'الثلاثاء';

  @override
  String get dayWednesday => 'الأربعاء';

  @override
  String get dayThursday => 'الخميس';

  @override
  String get dayFriday => 'الجمعة';

  @override
  String get daySaturday => 'السبت';

  @override
  String get daySunday => 'الأحد';

  @override
  String get dayUnknown => 'غير معروف';

  @override
  String get dayTodayMarker => '(اليوم)';

  @override
  String get clinicContact => 'تواصل';

  @override
  String get clinicPhone => 'الهاتف';

  @override
  String get clinicEmail => 'البريد الإلكتروني';

  @override
  String get clinicWebsite => 'الموقع الإلكتروني';

  @override
  String get clinicCallNow => 'اتصل الآن';

  @override
  String get clinicCancellationPolicy => 'سياسة الإلغاء';

  @override
  String clinicCancellationIntro(String policyType) {
    return 'نقدّر وقتك وخبرة ممارسينا. يطبّق هذا المركز سياسة إلغاء من نوع $policyType.';
  }

  @override
  String clinicCancellationFree(int hours) {
    return 'الإلغاء مجاني بالكامل إذا تم قبل $hours ساعة على الأقل من موعدك.';
  }

  @override
  String clinicCancellationFee(int hours, int percentage) {
    return 'الإلغاء المتأخر خلال $hours ساعة يخضع لرسوم بنسبة $percentage% من سعر الخدمة. عدم الحضور يُحاسب بنسبة 100%.';
  }

  @override
  String get clinicPolicyStandard => 'قياسي';

  @override
  String get limitedTime => 'لفترة محدودة';

  @override
  String get limitedTimeLower => 'لفترة محدودة';

  @override
  String offerUntilDate(String date) {
    return 'حتى $date';
  }

  @override
  String offerDiscountPercent(int value) {
    return 'خصم $value%';
  }

  @override
  String offerDiscountAmount(int value) {
    return 'خصم $value ل.س';
  }

  @override
  String get clinicOfferClaim => 'احصل عليه';

  @override
  String clinicDurationMinutes(int minutes) {
    return '$minutes د';
  }

  @override
  String clinicPrepMinutes(int minutes) {
    return '+ $minutes د تحضير';
  }

  @override
  String priceSp(String price) {
    return '$price ل.س';
  }

  @override
  String get clearAll => 'مسح الكل';

  @override
  String get filterServiceType => 'نوع الخدمة';

  @override
  String get filterPriceRange => 'نطاق السعر';

  @override
  String get filterFacialTreatment => 'علاج الوجه';

  @override
  String get filterBotoxFillers => 'بوتوكس وفيلر';

  @override
  String get filterLaserHairRemoval => 'إزالة الشعر بالليزر';

  @override
  String get filterBodyContouring => 'نحت الجسم';

  @override
  String get filterChemicalPeel => 'تقشير كيميائي';

  @override
  String get filterLocationBeverlyHills => 'Beverly Hills, CA';

  @override
  String get filterLocationSantaMonica => 'Santa Monica';

  @override
  String get filterLocationWestHollywood => 'West Hollywood';

  @override
  String get filterLocationDowntownLa => 'Downtown LA';

  @override
  String get filterLocationMalibu => 'Malibu';

  @override
  String priceUsd(int value) {
    return '\$$value';
  }

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get phone => 'الهاتف';

  @override
  String get yourLocation => 'موقعك';

  @override
  String get verified => 'موثّق';

  @override
  String get unverified => 'غير موثّق';

  @override
  String get active => 'نشط';

  @override
  String get inactive => 'غير نشط';

  @override
  String get unableToLoadProfile => 'تعذر تحميل الملف الشخصي.';

  @override
  String get noSpecialPromotionsTitle => 'لا توجد عروض خاصة حالياً';

  @override
  String get noSpecialPromotionsSubtitle =>
      'عد لاحقاً للاطلاع على عروض حصرية من العيادات القريبة منك.';

  @override
  String get findingYourLocation => 'جارٍ تحديد موقعك...';

  @override
  String get locationServicesOff => 'خدمات الموقع متوقفة';

  @override
  String get enableLocation => 'تفعيل الموقع';

  @override
  String get locationUnavailable => 'الموقع غير متاح';

  @override
  String get myAppointments => 'مواعيدي';

  @override
  String get upcoming => 'القادمة';

  @override
  String get past => 'السابقة';

  @override
  String get next30Days => 'الـ 30 يوماً القادمة';

  @override
  String get history => 'السجل';

  @override
  String get noUpcomingAppointments => 'لا توجد مواعيد قادمة.';

  @override
  String get noPastAppointments => 'لا توجد مواعيد سابقة.';

  @override
  String get cancelAppointment => 'إلغاء الموعد؟';

  @override
  String get cancelAppointmentConfirm => 'هل أنت متأكد من إلغاء هذا الموعد؟';

  @override
  String get cancelAppointmentAction => 'إلغاء الموعد';

  @override
  String get keep => 'إبقاء';

  @override
  String get clinicMissingForAppointment => 'العيادة غير موجودة لهذا الموعد.';

  @override
  String get reschedule => 'إعادة الجدولة';

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String get rebook => 'إعادة الحجز';

  @override
  String get appointmentCancelled => 'تم إلغاء الموعد بنجاح.';

  @override
  String get emailOrPhone => 'البريد أو الهاتف';

  @override
  String get emailOrPhoneHint => 'البريد الإلكتروني أو رقم الهاتف';

  @override
  String get bookTreatment => 'حجز علاج';

  @override
  String get selectService => 'اختر الخدمة';

  @override
  String get selectServiceSubtitle => 'اختر العلاج الذي تريد حجزه';

  @override
  String get chooseSpecialist => 'اختر الأخصائي';

  @override
  String get chooseSpecialistSubtitle =>
      'اختياري — اترك \"أي\" لأقرب موعد متاح';

  @override
  String get anySpecialist => 'أي';

  @override
  String get anySpecialistName => 'أي أخصائي';

  @override
  String get otherCategory => 'أخرى';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get selectDateSubtitle => 'اختر يوماً لموعدك';

  @override
  String get calendarMonth => 'شهر';

  @override
  String get selectTime => 'اختر الوقت';

  @override
  String get changeDate => 'تغيير التاريخ';

  @override
  String get couldNotLoadAvailableTimes => 'تعذر تحميل الأوقات المتاحة.';

  @override
  String get noAvailableTimesOnDate => 'لا توجد أوقات متاحة في هذا التاريخ.';

  @override
  String specialistNoAvailability(String name) {
    return '$name غير متاح في هذا التاريخ.';
  }

  @override
  String get tryAnySpecialist => 'جرّب أي أخصائي';

  @override
  String get pickAnotherDate => 'اختر تاريخاً آخر';

  @override
  String get morningPeriod => 'صباحاً';

  @override
  String get afternoonPeriod => 'مساءً';

  @override
  String get bookingSummary => 'الملخص';

  @override
  String get serviceLabel => 'الخدمة';

  @override
  String get specialistLabel => 'الأخصائي';

  @override
  String get dateLabel => 'التاريخ';

  @override
  String get timeLabel => 'الوقت';

  @override
  String get estimatedTotal => 'الإجمالي التقديري';

  @override
  String bookingTotal(String total) {
    return 'الإجمالي  $total';
  }

  @override
  String get chooseATime => 'اختر وقتاً';

  @override
  String get continueLabel => 'متابعة';

  @override
  String get confirmBooking => 'تأكيد الحجز';

  @override
  String get confirmReschedule => 'تأكيد إعادة الجدولة';

  @override
  String get noServicesAvailable => 'لا توجد خدمات متاحة لهذه العيادة.';

  @override
  String get pleaseChooseServiceDateTime => 'يرجى اختيار خدمة وتاريخ ووقت.';

  @override
  String get appointmentBookedSuccessfully => 'تم حجز الموعد بنجاح.';

  @override
  String get appointmentDetails => 'تفاصيل الموعد';

  @override
  String get clinicLabel => 'العيادة';

  @override
  String get depositLabel => 'العربون';

  @override
  String get notesLabel => 'ملاحظات';

  @override
  String get cancellationReasonLabel => 'سبب الإلغاء';

  @override
  String get statusPending => 'قيد الانتظار';

  @override
  String get statusConfirmed => 'مؤكد';

  @override
  String get statusCompleted => 'مكتمل';

  @override
  String get statusCancelled => 'ملغى';

  @override
  String get statusRejected => 'مرفوض';

  @override
  String get errorNoInternet =>
      'لا يوجد اتصال بالإنترنت. تحقق من الشبكة وحاول مرة أخرى.';

  @override
  String get errorServerUnavailable =>
      'تعذر الوصول إلى الخادم. يرجى المحاولة لاحقاً.';

  @override
  String get errorUnexpected => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';
}
