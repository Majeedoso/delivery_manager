// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'LihLih Manager';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get name => 'الاسم';

  @override
  String get phone => 'الهاتف';

  @override
  String get rememberMe => 'تذكرني';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get signInWithGoogle => 'تسجيل الدخول بحساب جوجل';

  @override
  String get signInWithEmail => 'تسجيل الدخول بالبريد الإلكتروني';

  @override
  String get checkingAuthentication => 'جارٍ التحقق من تسجيل الدخول...';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get language => 'اللغة';

  @override
  String get or => 'أو';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get userType => 'نوع الحساب';

  @override
  String get settings => 'الإعدادات';

  @override
  String get appSettings => 'إعدادات التطبيق';

  @override
  String get privacy => 'الخصوصية';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get appInformation => 'معلومات عن التطبيق';

  @override
  String get version => 'الإصدار';

  @override
  String get checkForUpdates => 'التحقق من التحديثات';

  @override
  String get aboutApp => 'عن التطبيق';

  @override
  String get aboutDescription => 'يمنحك تطبيق المدير إشرافًا كاملًا على منصة التوصيل كلها: وافق على المستخدمين، وراقب الأداء، واضبط الإعدادات، وأدِر القسائم، وكل ذلك من لوحة تحكم واحدة.';

  @override
  String get features => 'الميزات';

  @override
  String get userAuthentication => 'إدارة المستخدمين';

  @override
  String get userAuthenticationDescription => 'وافق على السائقين والمطاعم وموظفي التحقق، وأدِر إيقاف الحسابات';

  @override
  String get multiLanguageSupport => 'التحليلات والتقارير';

  @override
  String get multiLanguageSupportDescription => 'تابع الإيرادات واتجاهات الطلبات وأداء المنصة عبر لوحات معلومات مفصلة';

  @override
  String get secureStorage => 'إعدادات المنصة';

  @override
  String get secureStorageDescription => 'اضبط رسوم التوصيل ونسب العمولة وقواعد تشغيل المنصة';

  @override
  String get googleSignIn => 'القسائم';

  @override
  String get googleSignInDescription => 'أنشئ القسائم وحدّد شروطها والمناطق التي تسري فيها';

  @override
  String get contactUs => 'اتصل بنا';

  @override
  String copyright(String year) {
    return '© $year LihLih Manager. جميع الحقوق محفوظة.';
  }

  @override
  String get website => 'الموقع الإلكتروني';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get changeEmail => 'تغيير البريد الإلكتروني';

  @override
  String get updateProfile => 'تحديث الملف الشخصي';

  @override
  String get main => 'الرئيسية';

  @override
  String get refresh => 'تحديث';

  @override
  String get total => 'الإجمالي';

  @override
  String get deliveryFee => 'رسوم التوصيل';

  @override
  String get confirmed => 'مؤكد';

  @override
  String get statistics => 'الإحصائيات';

  @override
  String get statisticsMoney => 'المالية';

  @override
  String get statisticsOrders => 'الطلبات';

  @override
  String get ordersPlaced => 'طلبات';

  @override
  String get ordersPendingVerification => 'قيد التحقق';

  @override
  String get ordersAcceptedByOperator => 'قبلها موظف التحقق';

  @override
  String get ordersAcceptedByRestaurant => 'قبلها المطعم';

  @override
  String get ordersRejectedByOperator => 'رفضها موظف التحقق';

  @override
  String get ordersRejectedByRestaurant => 'رفضها المطعم';

  @override
  String get ordersAcceptedByDriver => 'قبلها السائق';

  @override
  String get ordersCancelled => 'ملغاة';

  @override
  String get noUserDataAvailable => 'لا تتوفر بيانات المستخدم';

  @override
  String get user => 'مستخدم';

  @override
  String get delivered => 'تم التوصيل';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get resetYourPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get enterEmailDescription => 'أدخل بريدك الإلكتروني وسنرسل إليك رمز تحقق لإعادة تعيين كلمة المرور.';

  @override
  String get emailAddress => 'عنوان البريد الإلكتروني';

  @override
  String get sendOtp => 'إرسال الرمز';

  @override
  String get enterOtpCode => 'أدخل رمز التحقق';

  @override
  String get enterOtpDescription => 'أدخل رمز التحقق المكوّن من 6 أرقام الذي أرسلناه إلى بريدك الإلكتروني\nسيجري التحقق منه تلقائيًا فور اكتمال إدخاله';

  @override
  String get setNewPassword => 'تعيين كلمة مرور جديدة';

  @override
  String get enterNewPasswordDescription => 'أدخل كلمة المرور الجديدة أدناه';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get confirmNewPassword => 'تأكيد كلمة المرور';

  @override
  String get resendOtp => 'إعادة إرسال الرمز';

  @override
  String get verifyEmail => 'التحقق من البريد الإلكتروني';

  @override
  String get enterOtp => 'أدخل رمز التحقق';

  @override
  String get otpSentTo => 'أرسلنا رمز التحقق إلى';

  @override
  String get verifyOtp => 'تأكيد الرمز';

  @override
  String get confirmEmailChange => 'تأكيد تغيير البريد الإلكتروني';

  @override
  String resendIn(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds ثانية',
      few: '$seconds ثوانٍ',
      two: 'ثانيتين',
      one: 'ثانية واحدة',
    );
    return 'يمكنك إعادة إرسال الرمز بعد $_temp0';
  }

  @override
  String get emailNotVerified => 'البريد الإلكتروني غير مؤكد';

  @override
  String get emailVerificationRequired => 'يرجى تأكيد بريدك الإلكتروني للمتابعة. أرسلنا رمز تحقق إلى بريدك، فافتح صندوق الوارد وأدخل الرمز المكوّن من 6 أرقام.';

  @override
  String get resendVerificationEmail => 'إعادة إرسال الرمز';

  @override
  String get checkStatus => 'التحقق من الحالة';

  @override
  String get checkStatusDescription => 'اضغط على «التحقق من الحالة» لمعرفة ما إذا تمت الموافقة على حسابك';

  @override
  String get initializing => 'جارٍ التهيئة...';

  @override
  String get initializationFailed => 'تعذّر تشغيل التطبيق';

  @override
  String get checkingInternet => 'جارٍ التحقق من الاتصال بالإنترنت...';

  @override
  String get noInternetConnection => 'لا يوجد اتصال بالإنترنت';

  @override
  String get noInternetDescription => 'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get updateRequired => 'يلزم تحديث التطبيق';

  @override
  String get updateRequiredDescription => 'يتوفر إصدار جديد من التطبيق. يرجى تحديثه لمواصلة استخدامه.';

  @override
  String get minimumRequiredVersion => 'أدنى إصدار مطلوب';

  @override
  String get latestAvailableVersion => 'أحدث إصدار متاح';

  @override
  String get updateNow => 'تحديث الآن';

  @override
  String get updateIsRequired => 'يلزم التحديث للمتابعة';

  @override
  String get yourCurrentVersion => 'إصدارك الحالي';

  @override
  String get updateAvailable => 'يتوفر تحديث جديد. يرجى تحديث التطبيق لمواصلة استخدامه.';

  @override
  String get updateAvailableOptional => 'يتوفر إصدار جديد. حدّث التطبيق للحصول على أحدث الميزات.';

  @override
  String get appUpToDate => 'لديك أحدث إصدار من التطبيق!';

  @override
  String get accountStatus => 'حالة الحساب';

  @override
  String get areYouSureLogout => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get theme => 'المظهر';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get system => 'حسب الجهاز';

  @override
  String get pleaseEnterEmail => 'يرجى إدخال بريدك الإلكتروني';

  @override
  String get pleaseEnterValidEmail => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get pleaseEnterPassword => 'يرجى إدخال كلمة المرور';

  @override
  String get passwordMinLength => 'يجب ألا تقل كلمة المرور عن 6 أحرف';

  @override
  String get newEmailAddress => 'البريد الإلكتروني الجديد';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get newEmailMustBeDifferent => 'يجب أن يختلف البريد الإلكتروني الجديد عن الحالي';

  @override
  String get day => 'يوم';

  @override
  String get month => 'شهر';

  @override
  String get year => 'سنة';

  @override
  String get dateRange => 'فترة محددة';

  @override
  String get from => 'من';

  @override
  String get to => 'إلى';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get errorLoadingStatistics => 'تعذّر تحميل الإحصائيات';

  @override
  String get noStatisticsAvailable => 'لا تتوفر إحصائيات';

  @override
  String get overview => 'نظرة عامة';

  @override
  String get totalOrders => 'إجمالي الطلبات';

  @override
  String get accepted => 'مقبول';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get rejected => 'مرفوض';

  @override
  String get performanceMetrics => 'مقاييس الأداء';

  @override
  String get acceptedOrdersSuccessRateGood => 'ارتفاع نسبة النجاح يعني أنك تقبل طلبات تستطيع تنفيذها بثبات.';

  @override
  String get acceptedOrdersSuccessRateBad => 'انخفاض نسبة النجاح يدل على مشكلات في تنفيذ الطلبات، فراجع طاقتك الاستيعابية.';

  @override
  String get acceptedOrdersFailureRateGood => 'انخفاض نسبة الفشل يدل على حسن التعامل مع الطلبات.';

  @override
  String get acceptedOrdersFailureRateBad => 'ارتفاع نسبة الفشل يضر بالسمعة، فابحث عن أسباب تعثّر الطلبات.';

  @override
  String get averageRespondingTimeGood => 'سرعة الاستجابة تزيد رضا العملاء وترفع نسبة قبول الطلبات.';

  @override
  String get averageRespondingTimeBad => 'بطء الاستجابة قد يؤدي إلى إلغاء الطلبات وعدم رضا العملاء.';

  @override
  String get whenGood => 'عندما يكون جيدًا';

  @override
  String get whenBad => 'عندما يكون سيئًا';

  @override
  String get close => 'إغلاق';

  @override
  String get all => 'الكل';

  @override
  String get second => 'ثانية';

  @override
  String get seconds => 'ثوانٍ';

  @override
  String get minute => 'دقيقة';

  @override
  String get hour => 'ساعة';

  @override
  String get errorGeneric => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get errorNetworkTimeout => 'انتهت مهلة الاتصال. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';

  @override
  String get errorConnectionError => 'تعذّر الاتصال بالخادم. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';

  @override
  String get errorRequestCancelled => 'أُلغيت العملية. يرجى المحاولة مرة أخرى.';

  @override
  String get errorNetworkGeneric => 'حدث خطأ في الشبكة. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';

  @override
  String get errorInvalidRequest => 'تعذّر تنفيذ العملية. يرجى مراجعة البيانات المدخلة والمحاولة مرة أخرى.';

  @override
  String get errorSessionExpired => 'انتهت جلستك. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get errorNoPermission => 'لا تملك صلاحية تنفيذ هذا الإجراء.';

  @override
  String get errorNotFound => 'المحتوى المطلوب غير موجود.';

  @override
  String get errorConflict => 'لا يمكن تنفيذ هذا الإجراء في الوضع الحالي. يرجى تحديث الصفحة والمحاولة مرة أخرى.';

  @override
  String get errorValidation => 'البيانات المدخلة غير صحيحة. يرجى مراجعتها.';

  @override
  String get errorTooManyRequests => 'محاولات كثيرة جدًا. يرجى الانتظار قليلًا ثم المحاولة مرة أخرى.';

  @override
  String get errorServerUnavailable => 'الخدمة غير متاحة مؤقتًا. يرجى المحاولة مرة أخرى لاحقًا.';

  @override
  String get errorServerGeneric => 'حدث خطأ في الخادم. يرجى المحاولة مرة أخرى لاحقًا.';

  @override
  String get errorDatabaseLocal => 'تعذّر حفظ البيانات على الجهاز. يرجى المحاولة مرة أخرى.';

  @override
  String get errorCacheLoad => 'تعذّر تحميل البيانات المحفوظة. يرجى تحديث الصفحة.';

  @override
  String get errorAuthFailed => 'تعذّر تسجيل الدخول. يرجى التحقق من بيانات الدخول والمحاولة مرة أخرى.';

  @override
  String get errorInvalidCredentials => 'البريد الإلكتروني أو كلمة المرور غير صحيحة. يرجى التحقق منهما والمحاولة مرة أخرى.';

  @override
  String get errorAuthRequired => 'يرجى تسجيل الدخول مرة أخرى للمتابعة.';

  @override
  String get errorSignInCancelled => 'تم إلغاء تسجيل الدخول.';

  @override
  String get errorServerMaintenance => 'الخدمة متوقفة مؤقتًا للصيانة. يرجى المحاولة مرة أخرى لاحقًا.';

  @override
  String get errorDatabaseServer => 'حدث خطأ في قاعدة البيانات. يرجى المحاولة مرة أخرى لاحقًا.';

  @override
  String get customer => 'عميل';

  @override
  String get restaurant => 'مطعم';

  @override
  String get description => 'الوصف';

  @override
  String get isOpen => 'مفتوح';

  @override
  String get notes => 'ملاحظات';

  @override
  String get rejectionReason => 'السبب';

  @override
  String get confirm => 'تأكيد';

  @override
  String get loadMore => 'تحميل المزيد';

  @override
  String get drivers => 'السائقون';

  @override
  String get call => 'اتصال';

  @override
  String get currentPasswordRequired => 'كلمة المرور الحالية مطلوبة';

  @override
  String get newPasswordRequired => 'كلمة المرور الجديدة مطلوبة';

  @override
  String get passwordMinLength8 => 'يجب ألا تقل كلمة المرور عن 8 أحرف';

  @override
  String get passwordComplexity => 'يجب أن تحتوي كلمة المرور على حرف كبير وحرف صغير ورقم ورمز';

  @override
  String get pleaseConfirmNewPassword => 'يرجى تأكيد كلمة المرور الجديدة';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountConfirmation => 'هل أنت متأكد من حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء، وستُحذف جميع بياناتك نهائيًا.\n\nستحتاج إلى تأكيد هويتك برمز تحقق نرسله إلى بريدك الإلكتروني.';

  @override
  String get continueButton => 'متابعة';

  @override
  String errorOpeningUrl(String error) {
    return 'تعذّر فتح الرابط: $error';
  }

  @override
  String get emailVerifiedSuccessfully => 'تم التحقق من البريد الإلكتروني بنجاح';

  @override
  String get failedToVerifyEmailOtp => 'تعذّر التحقق من رمز البريد الإلكتروني';

  @override
  String get requestTimeoutCheckConnection => 'انتهت مهلة الاتصال. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';

  @override
  String get cannotConnectToServer => 'تعذّر الاتصال بالخادم. يرجى التحقق من اتصالك بالإنترنت.';

  @override
  String get verificationOtpSentSuccessfully => 'أرسلنا رمز التحقق بنجاح. يرجى مراجعة بريدك الإلكتروني.';

  @override
  String get failedToResendVerificationOtp => 'تعذّرت إعادة إرسال رمز التحقق';

  @override
  String get emailChangeOtpSentSuccessfully => 'أرسلنا رمز تغيير البريد الإلكتروني بنجاح. يرجى مراجعة بريدك الإلكتروني الجديد.';

  @override
  String get pleaseEnterValid6DigitOtp => 'يرجى إدخال رمز تحقق صحيح مكوّن من 6 أرقام';

  @override
  String get urlNotAvailable => 'الرابط غير متاح. يرجى المحاولة مرة أخرى لاحقًا.';

  @override
  String get closed => 'مغلق';

  @override
  String get sunday => 'الأحد';

  @override
  String get open => 'فتح';

  @override
  String get unsavedChanges => 'تغييرات غير محفوظة';

  @override
  String get unsavedChangesMessage => 'لديك تغييرات غير محفوظة. هل تريد حفظها أم تجاهلها؟';

  @override
  String get save => 'حفظ';

  @override
  String get discard => 'تجاهل';

  @override
  String get latitude => 'دوائر العرض';

  @override
  String get longitude => 'خطوط الطول';

  @override
  String get search => 'بحث';

  @override
  String get active => 'نشط';

  @override
  String get edit => 'تعديل';

  @override
  String get delete => 'حذف';

  @override
  String get selected => 'محدد';

  @override
  String get remove => 'إزالة';

  @override
  String get isActive => 'نشط';

  @override
  String get clearFilters => 'مسح عوامل التصفية';

  @override
  String get bank => 'الحسابات';

  @override
  String get errorLoadingData => 'تعذّر تحميل البيانات';

  @override
  String get noDataAvailable => 'لا تتوفر بيانات';

  @override
  String get amount => 'المبلغ';

  @override
  String get driver => 'سائق';

  @override
  String get transactions => 'المعاملات';

  @override
  String get bankArchive => 'أرشيف الحسابات';

  @override
  String get approvedBy => 'وافق عليها';

  @override
  String get transactionType => 'النوع';

  @override
  String get selectDriver => 'اختر السائق';

  @override
  String get date => 'التاريخ';

  @override
  String get status => 'الحالة';

  @override
  String get receivables => 'المستحقات';

  @override
  String get payables => 'الديون';

  @override
  String get receivablesAndPayables => 'المستحقات والديون';

  @override
  String get newTransaction => 'معاملة جديدة';

  @override
  String get transactionsHistory => 'سجل المعاملات';

  @override
  String get performance => 'الأداء';

  @override
  String get allTime => 'منذ البداية';

  @override
  String get today => 'اليوم';

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get thisYear => 'هذه السنة';

  @override
  String get responseSpeed => 'سرعة الاستجابة';

  @override
  String get responseSpeedDescription => 'الوقت المستغرق لقبول الطلبات أو رفضها';

  @override
  String get preparationSpeed => 'سرعة التحضير';

  @override
  String get preparationSpeedDescription => 'الوقت المستغرق لتحضير الطلبات المقبولة';

  @override
  String get decisionQuality => 'جودة القرارات';

  @override
  String get decisionQualityDescription => 'نسبة الطلبات المكتملة من الطلبات المقبولة';

  @override
  String get poorDecisions => 'قرارات خاطئة';

  @override
  String get poorDecisionsDescription => 'نسبة الطلبات الملغاة بعد القبول';

  @override
  String get totalDebt => 'إجمالي الدين';

  @override
  String get systemDebt => 'دين المنصة';

  @override
  String get systemDebtDescription => 'المبلغ المستحق للمنصة من رسوم التوصيل';

  @override
  String get restaurantDebts => 'ديون المطاعم';

  @override
  String get restaurantCredits => 'المطاعم';

  @override
  String get recordPayment => 'تسجيل دفعة';

  @override
  String get recordSystemPayment => 'تسجيل دفعة للمنصة';

  @override
  String get noDebts => 'لا توجد ديون مستحقة';

  @override
  String get confirmedAt => 'وقت التأكيد';

  @override
  String get invalidAmount => 'المبلغ غير صحيح';

  @override
  String get noTransactionsFound => 'لا توجد معاملات';

  @override
  String get paymentType => 'نوع الدفع';

  @override
  String get selectRestaurant => 'اختر مطعمًا';

  @override
  String get paymentDate => 'تاريخ الدفع';

  @override
  String get totalCredits => 'إجمالي المستحقات';

  @override
  String get overpay => 'دفع مبلغ زائد';

  @override
  String get pickupSpeed => 'سرعة الاستلام';

  @override
  String get pickupSpeedDescription => 'الوقت من جاهزية الطعام إلى الاستلام';

  @override
  String get completionRate => 'نسبة الإكمال';

  @override
  String get cancellationRate => 'نسبة الإلغاء';

  @override
  String get cancellationRateDescription => 'نسبة الطلبات المقبولة التي تم إلغاؤها';

  @override
  String get ok => 'حسنًا';

  @override
  String get understood => 'فهمت';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get wrongApp => 'التطبيق غير مناسب';

  @override
  String get accountNotFound => 'الحساب غير موجود';

  @override
  String get accountNotFoundMessage => 'لا يوجد حساب مدير بهذا البريد الإلكتروني. فريق المنصة هو من يُنشئ حسابات المديرين، وليس التطبيق.';

  @override
  String get loginFailed => 'تعذّر تسجيل الدخول';

  @override
  String get invalidCredentialsMessage => 'البريد الإلكتروني أو كلمة المرور غير صحيحة. يرجى التحقق منهما والمحاولة مرة أخرى.';

  @override
  String get userManagement => 'إدارة المستخدمين';

  @override
  String get errorLoadingUsers => 'تعذّر تحميل المستخدمين';

  @override
  String get noUsersFound => 'لم نعثر على مستخدمين';

  @override
  String get noUsersMatchFilters => 'لا يوجد مستخدمون يطابقون عوامل التصفية';

  @override
  String get noUsersInSystem => 'لا يوجد مستخدمون على المنصة';

  @override
  String get userApprovedSuccessfully => 'تمت الموافقة على المستخدم بنجاح';

  @override
  String get userRejectedSuccessfully => 'تم رفض المستخدم بنجاح';

  @override
  String get userSuspendedSuccessfully => 'تم إيقاف المستخدم بنجاح';

  @override
  String get userActivatedSuccessfully => 'تم تفعيل المستخدم بنجاح';

  @override
  String get changeStatus => 'تغيير الحالة';

  @override
  String get pendingApproval => 'في انتظار الموافقة';

  @override
  String get suspended => 'موقوف';

  @override
  String get operator => 'موظف التحقق';

  @override
  String get manager => 'مدير';

  @override
  String get filters => 'عوامل التصفية';

  @override
  String get clear => 'مسح';

  @override
  String get allRoles => 'جميع الأدوار';

  @override
  String get allStatuses => 'جميع الحالات';

  @override
  String get rejectUser => 'رفض المستخدم';

  @override
  String rejectingUser(String userName) {
    return 'رفض حساب: $userName';
  }

  @override
  String get rejectionReasonLabel => 'سبب الرفض *';

  @override
  String get enterRejectionReason => 'اكتب سبب الرفض...';

  @override
  String get minimumCharacters => '10 أحرف على الأقل';

  @override
  String get rejectionReasonRequired => 'سبب الرفض مطلوب';

  @override
  String get reasonMinimum10Characters => 'يجب ألا يقل السبب عن 10 أحرف';

  @override
  String get suspendUser => 'إيقاف المستخدم';

  @override
  String suspendingUser(String userName) {
    return 'إيقاف حساب: $userName';
  }

  @override
  String get suspensionReasonLabel => 'سبب الإيقاف *';

  @override
  String get enterSuspensionReason => 'اكتب سبب الإيقاف...';

  @override
  String get suspensionReasonRequired => 'سبب الإيقاف مطلوب';

  @override
  String get searchUsers => 'البحث بالاسم أو البريد الإلكتروني أو الهاتف';

  @override
  String get coupons => 'القسائم';

  @override
  String get restaurantCoupons => 'قسائم المطاعم';

  @override
  String get deliveryCoupons => 'قسائم التوصيل';

  @override
  String get draft => 'مسودة';

  @override
  String get disabled => 'معطلة';

  @override
  String get newDeliveryCoupon => 'قسيمة توصيل جديدة';

  @override
  String get newCoupon => 'قسيمة جديدة';

  @override
  String get noDeliveryCouponsYet => 'لا توجد قسائم توصيل بعد';

  @override
  String get noCouponsYet => 'لا توجد قسائم بعد';

  @override
  String get createFirstDeliveryCoupon => 'أنشئ أول قسيمة توصيل!';

  @override
  String get createFirstCoupon => 'أنشئ أول قسيمة لجذب المزيد من العملاء!';

  @override
  String get off => 'خصم';

  @override
  String get discount => 'خصم';

  @override
  String get valid => 'صالحة';

  @override
  String get uses => 'مرات الاستخدام';

  @override
  String get minOrder => 'الحد الأدنى للطلب';

  @override
  String get dzd => 'دج';

  @override
  String get expired => 'منتهية الصلاحية';

  @override
  String get globalAllRestaurants => 'عامة (جميع المطاعم)';

  @override
  String get issuer => 'الجهة المصدرة: ';

  @override
  String get discardChanges => 'تجاهل التغييرات؟';

  @override
  String get editCoupon => 'تعديل القسيمة';

  @override
  String get update => 'تحديث';

  @override
  String get create => 'إنشاء';

  @override
  String get couponCode => 'رمز القسيمة';

  @override
  String get couponCodeHint => 'مثال: SUMMER20';

  @override
  String get pleaseEnterCouponCode => 'يرجى إدخال رمز القسيمة';

  @override
  String get codeMinLength => 'يجب ألا يقل الرمز عن 3 أحرف';

  @override
  String get type => 'النوع';

  @override
  String get percentage => 'نسبة مئوية';

  @override
  String get fixedAmount => 'مبلغ ثابت';

  @override
  String get value => 'القيمة';

  @override
  String get required => 'مطلوب';

  @override
  String get min1 => 'الحد الأدنى 1';

  @override
  String get max100Percent => 'الحد الأقصى 100%';

  @override
  String get discountAppliesTo => 'يسري الخصم على';

  @override
  String get orderSubtotal => 'المجموع الفرعي للطلب';

  @override
  String get validityPeriod => 'فترة الصلاحية';

  @override
  String get startDate => 'تاريخ البدء';

  @override
  String get endDate => 'تاريخ الانتهاء';

  @override
  String get restaurantOptional => 'المطعم (اختياري)';

  @override
  String get couponZonesOptional => 'مناطق القسيمة (اختياري)';

  @override
  String get manageZones => 'إدارة المناطق';

  @override
  String get usageLimitsOptional => 'حدود الاستخدام (اختياري)';

  @override
  String get totalUses => 'إجمالي مرات الاستخدام';

  @override
  String get perCustomer => 'لكل عميل';

  @override
  String get orderConstraintsOptional => 'قيود الطلب (اختياري)';

  @override
  String get minOrderDzd => 'الحد الأدنى للطلب (دج)';

  @override
  String get maxDiscountDzd => 'الحد الأقصى للخصم (دج)';

  @override
  String get descriptionOptional => 'الوصف (اختياري)';

  @override
  String get internalNoteHint => 'ملاحظة داخلية عن هذه القسيمة...';

  @override
  String get noCouponZonesAvailable => 'لا توجد مناطق متاحة للقسيمة. أنشئ مناطق لقصر القسيمة عليها.';

  @override
  String get selectZonesInfo => 'اختر المناطق (تسري القسيمة في كل مكان إذا لم تحدد منطقة)';

  @override
  String get noRestaurantsAvailable => 'لا توجد مطاعم متاحة. ستكون هذه القسيمة عامة.';

  @override
  String get selectedRestaurant => 'المطعم المحدد';

  @override
  String get allRestaurantsGlobal => 'جميع المطاعم (عامة)';

  @override
  String get kmRadius => 'كم (نصف القطر)';

  @override
  String get couponZones => 'مناطق القسائم';

  @override
  String get addZone => 'إضافة منطقة';

  @override
  String get success => 'تم بنجاح!';

  @override
  String get errorOccurred => 'حدث خطأ';

  @override
  String get noCouponZonesYet => 'لا توجد مناطق قسائم بعد';

  @override
  String get createZonesToRestrict => 'أنشئ مناطق لقصر القسائم\\nعلى أماكن محددة';

  @override
  String get createZone => 'إنشاء منطقة';

  @override
  String get editZone => 'تعديل المنطقة';

  @override
  String get zoneNameRequired => 'اسم المنطقة *';

  @override
  String get zoneNameHint => 'مثال: منطقة وسط المدينة';

  @override
  String get optionalDescription => 'وصف اختياري';

  @override
  String get latitudeHint => 'مثال: 36.7538';

  @override
  String get longitudeHint => 'مثال: 3.0588';

  @override
  String get radiusKm => 'نصف القطر (كم)';

  @override
  String get radiusHint => 'مثال: 5.0';

  @override
  String get km => 'كم';

  @override
  String get zoneNameIsRequired => 'اسم المنطقة مطلوب';

  @override
  String get deleteZone => 'حذف المنطقة';

  @override
  String deleteZoneConfirmation(Object zoneName) {
    return 'هل أنت متأكد من حذف «$zoneName»؟';
  }

  @override
  String get currency => 'دج';

  @override
  String get revenueOverview => 'نظرة عامة';

  @override
  String get totalRevenue => 'إجمالي الإيرادات';

  @override
  String get subtotalRevenue => 'قيمة الطعام';

  @override
  String get deliveryFeesCollected => 'رسوم التوصيل';

  @override
  String get platformEarnings => 'الإيرادات';

  @override
  String get platformRevenue => 'إيرادات المنصة';

  @override
  String get platformShort => 'المنصة';

  @override
  String get driverEarnings => 'أرباح السائق';

  @override
  String get driversShort => 'السائقون';

  @override
  String get restaurantEarnings => 'أرباح المطعم';

  @override
  String get restaurantsShort => 'المطاعم';

  @override
  String get totalRevenueDesc => 'إجمالي المبالغ التي دفعها العملاء لجميع الطلبات المُسلَّمة، شاملةً تكلفة الطعام ورسوم التوصيل.';

  @override
  String get subtotalRevenueDesc => 'إجمالي قيمة الطعام في جميع الطلبات المُسلَّمة، من دون رسوم التوصيل.';

  @override
  String get deliveryFeesDesc => 'إجمالي رسوم التوصيل المحصَّلة من العملاء في جميع الطلبات المُسلَّمة.';

  @override
  String get platformRevenueDesc => 'عمولة المنصة: نسبة تقتطعها من قيمة طلبات الطعام لدى المطاعم ومن رسوم التوصيل لدى السائقين.';

  @override
  String get driversRevenueDesc => 'ما يبقى للسائقين فعليًا: رسوم التوصيل المحصَّلة مخصومًا منها عمولة المنصة.';

  @override
  String get restaurantsRevenueDesc => 'ما يبقى للمطاعم فعليًا: إيرادات طلبات الطعام مخصومًا منها عمولة المنصة.';

  @override
  String get restaurantEarningsSection => 'الأرباح';

  @override
  String get restaurantNetEarnings => 'صافي الأرباح';

  @override
  String get driverEarningsSection => 'الأرباح';

  @override
  String get driverNetEarnings => 'صافي الأرباح';

  @override
  String get averageOrderValueDesc => 'متوسط المبلغ الإجمالي (طعام + توصيل) لكل طلب مُسلَّم في الفترة المحددة.';

  @override
  String get orderMetrics => 'مقاييس الطلبات';

  @override
  String get averageOrderValue => 'متوسط قيمة الطلب';

  @override
  String get statisticsRatings => 'التقييمات';

  @override
  String get statisticsPerformance => 'الأداء';

  @override
  String get deliveryPerformance => 'أداء التوصيل';

  @override
  String get totalDeliveries => 'إجمالي عمليات التوصيل';

  @override
  String get completedDeliveries => 'عمليات التوصيل المكتملة';

  @override
  String get cancelledDeliveries => 'عمليات التوصيل الملغاة';

  @override
  String get onTimeRate => 'نسبة الالتزام بالوقت';

  @override
  String get avgDeliveryTime => 'متوسط وقت التوصيل';

  @override
  String get fastestDelivery => 'أسرع توصيل';

  @override
  String get slowestDelivery => 'أبطأ توصيل';

  @override
  String get totalDeliveriesDesc => 'إجمالي عدد طلبات التوصيل في الفترة المحددة.';

  @override
  String get completedDeliveriesDesc => 'الطلبات التي تم توصيلها بنجاح إلى العميل.';

  @override
  String get cancelledDeliveriesDesc => 'الطلبات التي تم إلغاؤها بعد قبولها.';

  @override
  String get completionRateDesc => 'نسبة الطلبات المقبولة التي تم توصيلها بنجاح.';

  @override
  String get avgDeliveryTimeDesc => 'متوسط الوقت بالدقائق من استلام الطلب حتى التسليم.';

  @override
  String get onTimeRateDesc => 'نسبة عمليات التوصيل المنجزة ضمن الوقت المستهدف.';

  @override
  String get fastestDeliveryDesc => 'أقصر وقت توصيل مسجل في الفترة المحددة.';

  @override
  String get slowestDeliveryDesc => 'أطول وقت توصيل مسجل في الفترة المحددة.';

  @override
  String get minutesAbbr => 'د';

  @override
  String get averageRating => 'متوسط التقييم';

  @override
  String get totalRatings => 'إجمالي التقييمات';

  @override
  String get ratingDistribution => 'توزيع التقييمات';

  @override
  String get foodQualityRating => 'جودة الطعام';

  @override
  String get restaurantServiceRating => 'خدمة المطعم';

  @override
  String get deliverySpeedRating => 'سرعة التوصيل';

  @override
  String get reorderRate => 'نسبة إعادة الطلب';

  @override
  String get recommendRate => 'نسبة التوصية';

  @override
  String get outOf5 => 'من 5';

  @override
  String get restaurantsTab => 'المطاعم';

  @override
  String get reviews => 'تقييمات';

  @override
  String get noRatingsYet => 'لا توجد تقييمات بعد';

  @override
  String get driversTab => 'السائقون';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get failedToLoadSettings => 'تعذّر تحميل الإعدادات';

  @override
  String get noSettingsFound => 'لا توجد إعدادات';

  @override
  String get noSettingsInThisCategory => 'لا توجد إعدادات في هذه الفئة';

  @override
  String get settingUpdatedSuccessfully => 'تم تحديث الإعداد';

  @override
  String get emptyInParentheses => '(فارغ)';

  @override
  String get currentValue => 'القيمة الحالية';

  @override
  String get keyLabel => 'المفتاح';

  @override
  String get editValue => 'تعديل القيمة';

  @override
  String get newValue => 'القيمة الجديدة';

  @override
  String get invalidRouteArguments => 'بيانات التنقل غير صالحة';

  @override
  String get invalidAppVersionArgument => 'بيانات الإصدار غير صالحة';

  @override
  String get globalCoupons => 'قسائم عامة';

  @override
  String get enterVerificationCode => 'أدخل رمز التحقق';

  @override
  String weSentVerificationCodeTo(Object email) {
    return 'أرسلنا رمز التحقق إلى $email';
  }

  @override
  String get confirmAccountDeletionCodeMessage => 'يرجى إدخال الرمز لتأكيد حذف الحساب. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get unableToCheckForUpdates => 'تعذّر التحقق من التحديثات. يرجى المحاولة مرة أخرى لاحقًا.';

  @override
  String get accountPendingApprovalMessage => 'حسابك في انتظار موافقة المدير. يرجى الانتظار حتى يراجعه ويوافق عليه لتتمكن من الدخول. سيصلك إشعار عند الموافقة عليه.';

  @override
  String get accountSuspendedMessage => 'تم إيقاف حسابك. يرجى التواصل مع الدعم للحصول على المساعدة.';

  @override
  String get accountRejectedMessage => 'تم رفض حسابك. يرجى التواصل مع الدعم لمزيد من المعلومات.';

  @override
  String balanceForPeriod(String period) {
    return '(الرصيد: $period)';
  }

  @override
  String get updateLinkUnavailable => 'تعذّر فتح التحديث على هذا الجهاز. تواصل معنا للحصول على الإصدار الجديد.';

  @override
  String get pageNotFound => 'الصفحة غير موجودة';

  @override
  String get accountApprovedRedirectingMessage => 'تمت الموافقة على حسابك! جارٍ نقلك...';

  @override
  String get accountPendingApproval => 'الحساب في انتظار الموافقة';

  @override
  String get accountPendingApprovalFallbackMessage => 'حسابك في انتظار موافقة المدير. يرجى الانتظار حتى يراجعه ويوافق عليه لتتمكن من الدخول.';

  @override
  String get accountRejected => 'تم رفض الحساب';

  @override
  String get accountSuspended => 'الحساب موقوف';

  @override
  String get appFailedToInitializeProperly => 'تعذّر تشغيل التطبيق كما ينبغي.';

  @override
  String get pleaseConfirmYourPassword => 'يرجى تأكيد كلمة المرور';

  @override
  String get nameIsRequired => 'الاسم مطلوب';

  @override
  String get nameTooShort => 'يجب ألا يقل الاسم عن حرفين';

  @override
  String get phoneTooShort => 'يجب ألا يقل رقم الهاتف عن 10 أرقام';

  @override
  String usesUnlimited(int count) {
    return '$count (غير محدود)';
  }

  @override
  String get finalTotalGlobal => 'المجموع النهائي (عام)';

  @override
  String zonesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count منطقة محددة',
      few: '$count مناطق محددة',
      two: 'منطقتان محددتان',
      one: 'منطقة واحدة محددة',
    );
    return '$_temp0';
  }

  @override
  String get settingsCategoryDelivery => 'التوصيل';

  @override
  String get settingsCategoryFinancials => 'المالية';

  @override
  String get settingsCategoryCustomersOrders => 'العملاء والطلبات';

  @override
  String get settingsCategoryLoyaltyPromotions => 'الولاء والعروض';

  @override
  String get settingsCategoryAccountsSecurity => 'الحسابات والأمان';

  @override
  String get settingsCategoryApiIntegrations => 'الواجهات البرمجية والتكامل';

  @override
  String get settingsCategoryLegalContact => 'الشؤون القانونية والاتصال';

  @override
  String get settingTypeText => 'نص';

  @override
  String get settingTypeWhole => 'عدد صحيح';

  @override
  String get settingTypeNumber => 'عدد';

  @override
  String get settingTypeYesNo => 'نعم أو لا';

  @override
  String get settingTypeList => 'قائمة (JSON)';

  @override
  String get settingSystemManagerOrderPercentageName => 'العمولة على الطلبات (%)';

  @override
  String get settingSystemManagerOrderPercentageRole => 'حصة المنصة من المجموع الفرعي للأطباق';

  @override
  String get settingSystemManagerOrderPercentageHelp => 'النسبة المئوية التي تقتطعها المنصة عمولةً من قيمة أطباق كل طلب. فالقيمة 10 مثلًا تعني أن المنصة تكسب 10 دج عن كل 100 دج من الأطباق المطلوبة. وعند توصيل الطلب تسجّل صفحة الحسابات هذا المبلغ دينًا على المطعم للمنصة (أما السائق فيدين للمطعم بقيمة الأطباق كاملة).';

  @override
  String get settingSystemManagerDeliveryFeePercentageName => 'الحصة من رسوم التوصيل (%)';

  @override
  String get settingSystemManagerDeliveryFeePercentageRole => 'حصة المنصة من رسوم كل توصيلة';

  @override
  String get settingSystemManagerDeliveryFeePercentageHelp => 'النسبة المئوية التي تذهب إلى المنصة من رسوم التوصيل، ويحتفظ السائق بالباقي. فمع القيمة 30 مثلًا تأخذ المنصة 30% من رسوم كل توصيلة ويأخذ السائق 70%. وتُطبَّق هذه النسبة في الحسابات كلما سُلِّم طلب.';

  @override
  String get settingContactEmailName => 'بريد الدعم الإلكتروني';

  @override
  String get settingContactEmailRole => 'يظهر في كل التطبيقات';

  @override
  String get settingContactEmailHelp => 'يظهر مع بقية بيانات الاتصال في صفحتي «اتصل بنا» و«عن التطبيق» في كل التطبيقات (العميل والسائق والمطعم وموظف التحقق). غيّره كلما تغيّر بريد الدعم، ليصل المستخدمون دائمًا إلى العنوان الصحيح.';

  @override
  String get settingContactPhoneName => 'هاتف الدعم';

  @override
  String get settingContactPhoneRole => 'يظهر في كل التطبيقات';

  @override
  String get settingContactPhoneHelp => 'يظهر في صفحة «اتصل بنا» في كل التطبيقات. تقرؤه التطبيقات من الخادم، فيصل أي تغيير هنا إليها جميعًا فورًا من دون إصدار جديد.';

  @override
  String get settingContactWebsiteName => 'الموقع الإلكتروني';

  @override
  String get settingContactWebsiteRole => 'يظهر في كل التطبيقات';

  @override
  String get settingContactWebsiteHelp => 'عنوان الموقع الإلكتروني لمنصتك، يظهر في صفحتي «عن التطبيق» و«اتصل بنا» في كل التطبيقات، ويُفتح في متصفح الهاتف عند الضغط عليه.';

  @override
  String get settingContactAddressName => 'العنوان البريدي';

  @override
  String get settingContactAddressRole => 'عنوان الشركة';

  @override
  String get settingContactAddressHelp => 'العنوان الرسمي لشركتك. يظهر في قسم الاتصال من صفحتي سياسة الخصوصية وشروط الخدمة (بكل اللغات)، ويُرسَل إلى التطبيقات مع بقية بيانات الاتصال. اتركه فارغًا لإخفاء سطر العنوان.';

  @override
  String get settingMinimumDeliveryFeeName => 'الحد الأدنى لرسوم التوصيل';

  @override
  String get settingMinimumDeliveryFeeRole => 'أقل ما يكلّفه التوصيل';

  @override
  String get settingMinimumDeliveryFeeHelp => 'أقل مبلغ يدفعه العميل للتوصيل مهما كان المطعم قريبًا. فالقيمة 50 مثلًا تعني أن طلبًا على بعد 300 متر يكلّف مع ذلك 50 دج للتوصيل. ضع 0 لإلغاء الحد الأدنى، فتُعتمد نتيجة الحساب كما هي.';

  @override
  String get settingMaximumDeliveryFeeName => 'الحد الأقصى لرسوم التوصيل';

  @override
  String get settingMaximumDeliveryFeeRole => 'أقصى ما يكلّفه التوصيل';

  @override
  String get settingMaximumDeliveryFeeHelp => 'أقصى مبلغ يمكن أن يدفعه العميل للتوصيل مهما كان المطعم بعيدًا. فالقيمة 500 مثلًا تعني أن طلبًا على بعد 20 كم لن يكلّف أكثر من 500 دج للتوصيل. ضع 0 لإلغاء الحد الأقصى، فتُعتمد نتيجة الحساب كما هي.';

  @override
  String get settingMaxDriverConcurrentOrdersName => 'عدد الطلبات المتزامنة للسائق';

  @override
  String get settingMaxDriverConcurrentOrdersRole => 'أقصى عدد من الطلبات الجارية لكل سائق';

  @override
  String get settingMaxDriverConcurrentOrdersHelp => 'أكبر عدد من الطلبات الجارية يمكن أن يتولاه سائق واحد في الوقت نفسه. وحين يبلغ هذا العدد لا يُعرض عليه أي طلب جديد حتى يوصل طلبًا أو يعيده. ارفعه في أوقات الذروة، واخفضه لتبقى مدة التوصيل قصيرة.';

  @override
  String get settingFixedDeliveryFeeName => 'رسوم التوصيل الثابتة';

  @override
  String get settingFixedDeliveryFeeRole => 'الجزء الثابت من رسوم كل توصيلة';

  @override
  String get settingFixedDeliveryFeeHelp => 'مبلغ ثابت يدخل في رسوم كل توصيلة مهما كانت المسافة: الرسوم = الرسوم الثابتة + (السعر لكل متر × المسافة بالأمتار)، ثم تُقرَّب وتبقى بين الحد الأدنى والحد الأقصى. رفعه يزيد ما يدفعه كل عميل للتوصيل.';

  @override
  String get settingPricePerMeterName => 'السعر لكل متر';

  @override
  String get settingPricePerMeterRole => 'الجزء المرتبط بالمسافة من رسوم التوصيل';

  @override
  String get settingPricePerMeterHelp => 'ما يضيفه كل متر من الطريق بين المطعم وعنوان التوصيل إلى الرسوم. فقيمة 0.02 دج لكل متر مثلًا تعني أن طريقًا طوله 5 كم يضيف 100 دج إلى الرسوم الثابتة. تُستمد مسافة الطريق من Mapbox أو OpenRouteService.';

  @override
  String get settingMaxDeliveryDistanceKmName => 'أقصى مسافة للتوصيل (كم)';

  @override
  String get settingMaxDeliveryDistanceKmRole => 'أبعد مسافة يبلغها التوصيل';

  @override
  String get settingMaxDeliveryDistanceKmHelp => 'يُرفض عند تقديمه الطلبُ الذي يبعد عنوان توصيله عن المطعم أكثر من هذا العدد من الكيلومترات. يجنّب ذلك السائقين الرحلات الطويلة جدًا ويبقي مدة التوصيل متوقعة. ارفعه أو اخفضه لتوسيع منطقة خدمتك أو تضييقها.';

  @override
  String get settingAverageCitySpeedKmhName => 'السرعة داخل المدينة (كم/س)';

  @override
  String get settingAverageCitySpeedKmhRole => 'لمدة التوصيل حين لا يُعرف المسار';

  @override
  String get settingAverageCitySpeedKmhHelp => 'حين لا يجيب Mapbox ولا OpenRouteService، تُقاس المسافة في خط مستقيم وتحدد هذه السرعة الوقت الذي يستغرقه التوصيل في شوارع المدينة. القيمة المعتادة من 25 إلى 40 كم/س، مراعاةً لحركة المرور والتوقفات.';

  @override
  String get settingAverageHighwaySpeedKmhName => 'السرعة على الطريق السريع (كم/س)';

  @override
  String get settingAverageHighwaySpeedKmhRole => 'للجزء الطويل من مثل هذه الرحلة';

  @override
  String get settingAverageHighwaySpeedKmhHelp => 'تُستعمل مع السرعة داخل المدينة في هذا التقدير بالخط المستقيم: بعد مسافة الانتقال من المدينة إلى الطريق السريع، يُحسب باقي الرحلة بهذه السرعة الأعلى. القيمة المعتادة من 80 إلى 120 كم/س.';

  @override
  String get settingCityHighwayTransitionKmName => 'مسافة الانتقال من المدينة إلى الطريق السريع (كم)';

  @override
  String get settingCityHighwayTransitionKmRole => 'حدّ احتساب سرعة المدينة';

  @override
  String get settingCityHighwayTransitionKmHelp => 'في هذا التقدير بالخط المستقيم، تُحسب الرحلة الأقصر من هذه المسافة كلها بسرعة المدينة، وتُحسب الكيلومترات التي تتجاوزها بسرعة الطريق السريع. فالقيمة 5 مثلًا تعني أول 5 كم بسرعة المدينة والباقي بسرعة الطريق السريع.';

  @override
  String get settingCurrencyName => 'العملة';

  @override
  String get settingCurrencyRole => 'رمز عملة المنصة';

  @override
  String get settingCurrencyHelp => 'رمز ISO 4217 لعملة جميع المبالغ في المنصة: مجاميع الطلبات ورسوم التوصيل والأرباح والإشعارات، مثل «DZD» للدينار الجزائري. يكتبه الخادم بعد المبالغ ويرسله إلى كل التطبيقات.';

  @override
  String get settingBirthdayGiftEnabledName => 'هدية عيد الميلاد';

  @override
  String get settingBirthdayGiftEnabledRole => 'مفعّلة أو معطّلة';

  @override
  String get settingBirthdayGiftEnabledHelp => 'إذا كانت القيمة true (أو 1)، فإن العميل الذي يطلب يوم عيد ميلاده يحصل على طلبه مدفوعًا في حدود سقف الهدية، مرة واحدة في السنة. وإذا كانت false (أو 0)، فلا هدية. يشغّل ذلك العرض أو يوقفه من دون المساس بالشيفرة.';

  @override
  String get settingBirthdayGiftCapName => 'سقف هدية عيد الميلاد (دج)';

  @override
  String get settingBirthdayGiftCapRole => 'أقصى ما تغطيه هدية عيد الميلاد';

  @override
  String get settingBirthdayGiftCapHelp => 'أقصى ما تغطيه هدية عيد الميلاد بعملة المنصة. فمع سقف 500 مثلًا، يُخفَّض طلب عيد ميلاد قيمته 700 دج بمقدار 500 دج. وبذلك تبقى الهدية معقولة في الطلبات الكبيرة.';

  @override
  String get settingCustomerRestaurantRadiusKmName => 'نصف قطر البحث عن المطاعم (كم)';

  @override
  String get settingCustomerRestaurantRadiusKmRole => 'المطاعم التي يراها العميل';

  @override
  String get settingCustomerRestaurantRadiusKmHelp => 'يرى العميل المطاعم الواقعة ضمن هذا العدد من الكيلومترات من مكانه. وكلما زاد نصف القطر زادت الخيارات، لكنه قد يُظهر مطاعم أبعد من أن تصل طلباتها في وقت مناسب.';

  @override
  String get settingCustomerRestaurantPrefilterRadiusKmName => 'نصف قطر التصفية الأولية للبحث (كم)';

  @override
  String get settingCustomerRestaurantPrefilterRadiusKmRole => 'فرز أولي أسرع للمطاعم';

  @override
  String get settingCustomerRestaurantPrefilterRadiusKmHelp => 'قبل الحساب الدقيق للمسافة، تحتفظ قاعدة البيانات بالمطاعم الواقعة ضمن هذا النطاق الأوسع فقط، وهو أسرع. يجب ألا يقل عن نصف قطر البحث عن المطاعم: إن كان أصغر استُبعدت مطاعم قريبة، وإن كان أكبر منه بكثير لم يفعل سوى إبطاء البحث.';

  @override
  String get settingPrivacyPolicyUrlName => 'رابط سياسة الخصوصية';

  @override
  String get settingPrivacyPolicyUrlRole => 'يظهر في كل التطبيقات';

  @override
  String get settingPrivacyPolicyUrlHelp => 'يُفتح في متصفح الهاتف حين يضغط أحدهم على «سياسة الخصوصية» في أي تطبيق. غيّره هنا كلما نشرت نسخة جديدة من سياستك، ولا حاجة إلى تحديث التطبيقات.';

  @override
  String get settingTermsOfServiceUrlName => 'رابط شروط الخدمة';

  @override
  String get settingTermsOfServiceUrlRole => 'يظهر في كل التطبيقات';

  @override
  String get settingTermsOfServiceUrlHelp => 'يُفتح في متصفح الهاتف حين يضغط أحدهم على «شروط الخدمة» في أي تطبيق. غيّره هنا كلما عدّلت شروطك، ولا حاجة إلى تحديث التطبيقات.';

  @override
  String get settingMinOrderSchedulingMinutesName => 'مهلة جدولة الطلب (بالدقائق)';

  @override
  String get settingMinOrderSchedulingMinutesRole => 'المدة المسبقة لجدولة الطلب';

  @override
  String get settingMinOrderSchedulingMinutesHelp => 'على العميل الذي يجدول طلبًا أن يختار وقتًا يأتي بعد هذا العدد من الدقائق على الأقل. فالقيمة 30 مثلًا تعني أنه لا يمكن جدولة طلب خلال الدقائق الثلاثين القادمة. يمنح ذلك المطاعم والسائقين وقتًا كافيًا للاستعداد.';

  @override
  String get settingNumberOfOrdersToBeTrustedName => 'الطلبات اللازمة ليصبح العميل موثوقًا';

  @override
  String get settingNumberOfOrdersToBeTrustedRole => 'متى يتوقف التحقق من طلبات العميل';

  @override
  String get settingNumberOfOrdersToBeTrustedHelp => 'يراجع موظف التحقق طلبات العميل الجديد قبل أن تصل إلى المطعم. وحين يبلغ العميل هذا العدد من الطلبات المُسلَّمة يصبح «موثوقًا»، وتذهب طلباته التالية مباشرة إلى المطعم. اخفضه لتمنح الثقة أسرع، وارفعه لمزيد من التحقق.';

  @override
  String get settingOtpValidityMinutesName => 'مدة صلاحية الرمز (بالدقائق)';

  @override
  String get settingOtpValidityMinutesRole => 'مدة صلاحية الرموز المرسلة بالبريد';

  @override
  String get settingOtpValidityMinutesHelp => 'تُرسل الرموز بالبريد الإلكتروني لإعادة تعيين كلمة المرور، والتحقق من البريد أو تغييره، وتأكيد حذف الحساب. يبقى الرمز صالحًا هذا العدد من الدقائق بعد إرساله، وتذكر الرسالة ذلك. المدة الأقصر أكثر أمانًا، والأطول أرفق بصناديق البريد البطيئة.';

  @override
  String get settingOtpResendWaitSecondsName => 'الانتظار قبل طلب رمز جديد (بالثواني)';

  @override
  String get settingOtpResendWaitSecondsRole => 'بين رمزين مرسلين بالبريد';

  @override
  String get settingOtpResendWaitSecondsHelp => 'بعد إرسال رمز، لا يمكن طلب رمز جديد إلا بعد هذا العدد من الثواني، وتعرض التطبيقات العدّ التنازلي. يحدّ ذلك من الرسائل المرسلة إلى عنوان واحد.';

  @override
  String get settingMaxSavedAddressesName => 'العناوين المحفوظة لكل عميل';

  @override
  String get settingMaxSavedAddressesRole => 'عدد العناوين التي يحتفظ بها العميل';

  @override
  String get settingMaxSavedAddressesHelp => 'أكبر عدد من عناوين التوصيل يمكن للعميل الواحد الاحتفاظ به في التطبيق. ويُرفض أي عنوان إضافي مع رسالة توضيحية.';

  @override
  String get settingMaxItemsPerOrderName => 'الأطباق في الطلب الواحد';

  @override
  String get settingMaxItemsPerOrderRole => 'أطباق مختلفة في طلب واحد';

  @override
  String get settingMaxItemsPerOrderHelp => 'يُرفض الطلب الذي يضم أطباقًا مختلفة تتجاوز هذا العدد. وبذلك يبقى الطلب الواحد في حدود ما يستطيع المطبخ والسائق التعامل معه دفعة واحدة.';

  @override
  String get settingMaxQuantityPerItemName => 'الحصص من الطبق الواحد';

  @override
  String get settingMaxQuantityPerItemRole => 'حصص الطبق الواحد في طلب واحد';

  @override
  String get settingMaxQuantityPerItemHelp => 'أكبر كمية من طبق واحد يمكن للعميل طلبها، وتُرفض الكمية الأكبر مع رسالة توضيحية.';

  @override
  String get settingAmountRoundingStepName => 'وحدة التقريب (دج)';

  @override
  String get settingAmountRoundingStepRole => 'تقريب رسوم التوصيل وخصومات القسائم';

  @override
  String get settingAmountRoundingStepHelp => 'تُقرَّب رسوم التوصيل إلى الأعلى، وخصومات القسائم إلى الأسفل، إلى أحد مضاعفات هذا المبلغ. فمع القيمة 5، تصبح رسوم 162 دج 165 دج، ويصبح خصم 312 دج 310 دج. ضع 1 لإيقاف التقريب.';

  @override
  String get settingLoyaltyCouponValidityDaysName => 'مدة صلاحية قسيمة الولاء (بالأيام)';

  @override
  String get settingLoyaltyCouponValidityDaysRole => 'المدة التي تبقى فيها قسيمة الولاء صالحة';

  @override
  String get settingLoyaltyCouponValidityDaysHelp => 'يمكن استعمال القسيمة المستبدلة بنقاط الولاء طوال هذا العدد من الأيام، ويعرض تطبيق العميل هذا العدد قبل صرف النقاط.';

  @override
  String get settingDefaultDeliveryTimeMinutesName => 'مدة التوصيل الافتراضية (بالدقائق)';

  @override
  String get settingDefaultDeliveryTimeMinutesRole => 'حين يكون المسار غير معروف';

  @override
  String get settingDefaultDeliveryTimeMinutesHelp => 'حين يتعذّر حساب الطريق إلى العميل (لعدم توفر موقعه بعد أو لغياب خدمة حساب المسارات)، يُعرض هذا العدد من الدقائق ويُعتمد مدةً للتوصيل.';

  @override
  String get settingRouteCacheMinutesName => 'مدة الاحتفاظ بمسافة الطريق (بالدقائق)';

  @override
  String get settingRouteCacheMinutesRole => 'مدة إعادة استعمال المسافة المحسوبة';

  @override
  String get settingRouteCacheMinutesHelp => 'تُحفظ مسافة الطريق بين المطعم ومكان التوصيل هذا العدد من الدقائق بدل حسابها من جديد، فتكون الرسوم المدفوعة هي الرسوم المعروضة وتقل طلبات حساب المسارات. لا تخفضه إلا إذا كانت الطرق تتغير كثيرًا.';

  @override
  String get settingMaxRouteLookupsPerDayName => 'مسافات الطريق في اليوم (Mapbox)';

  @override
  String get settingMaxRouteLookupsPerDayRole => 'أقصى عدد من مسافات الطريق يُطلب حسابها من Mapbox في اليوم';

  @override
  String get settingMaxRouteLookupsPerDayHelp => 'كل مطعم يُعرض في مكان جديد يُطلب من Mapbox حساب مسافة الطريق إليه، ويحتسب Mapbox ثمنها بعد تجاوز حصته المجانية الشهرية. فإذا بلغ العدد هذا الحد في يوم، تُحسب المسافة بـ OpenRouteService (مجاني) أو بخط مستقيم حتى منتصف الليل، كما لو كان Mapbox معطلًا، وتبقى الرسوم المدفوعة هي الرسوم المعروضة. القيمة 0 لا تطلب من Mapbox شيئًا.';

  @override
  String get settingMaxRouteLookupsPerCustomerPerDayName => 'مسافات الطريق لكل عميل في اليوم (Mapbox)';

  @override
  String get settingMaxRouteLookupsPerCustomerPerDayRole => 'أقصى عدد من مسافات الطريق يمكن لعميل واحد أن يُطلب حسابها من Mapbox في اليوم';

  @override
  String get settingMaxRouteLookupsPerCustomerPerDayHelp => 'يُحسب لكل حساب، ولكل عنوان شبكة للزوار بلا حساب (فالزوار الذين يتشاركون عنوانًا واحدًا يتشاركون هذا الحد). فإذا تجاوزه عميل، رأى هو وحده مسافات تقريبية حتى منتصف الليل، ولا يتأثر غيره. القيمة 0 لا تطلب من Mapbox شيئًا.';

  @override
  String get settingMapDefaultLatitudeName => 'مركز الخريطة: دوائر العرض';

  @override
  String get settingMapDefaultLatitudeRole => 'موضع فتح الخريطة في التطبيقات';

  @override
  String get settingMapDefaultLatitudeHelp => 'حين يفتح أحدهم الخريطة لاختيار مكان ولا يُعرف أي موقع بعد، تُفتح الخريطة هنا. اضبطه مع خطوط الطول على مركز منطقة خدمتك. القيمة بين -90 و90.';

  @override
  String get settingMapDefaultLongitudeName => 'مركز الخريطة: خطوط الطول';

  @override
  String get settingMapDefaultLongitudeRole => 'موضع فتح الخريطة في التطبيقات';

  @override
  String get settingMapDefaultLongitudeHelp => 'خطوط الطول المرافقة لدوائر عرض مركز الخريطة: مركز منطقة خدمتك. القيمة بين -180 و180.';

  @override
  String get settingAppMapboxAccessTokenName => 'رمز الخرائط (Mapbox)';

  @override
  String get settingAppMapboxAccessTokenRole => 'يرسم الخرائط في التطبيقات';

  @override
  String get settingAppMapboxAccessTokenHelp => 'رمز Mapbox العام (يبدأ بـ «pk.») الذي ترسم به تطبيقات العميل والسائق والمطعم والمدير خرائطها. تقرؤه التطبيقات من الخادم، فاستبداله هنا لا يتطلب إصدارًا جديدًا. يُرفض الرمز السري («sk.»)، لأن هذا الرمز يُسلَّم إلى كل التطبيقات. أما المفاتيح التي يقيس بها الخادم مسافات الطرق فليست هنا، فهي أسرار محفوظة في ملف .env على الخادم.';

  @override
  String get settingLocalTimezoneName => 'المنطقة الزمنية';

  @override
  String get settingLocalTimezoneRole => 'لساعات عمل المطاعم';

  @override
  String get settingLocalTimezoneHelp => 'تُدخل المطاعم ساعات عملها بالتوقيت المحلي، من 11:00 إلى 23:00 مثلًا. وهذه هي المنطقة الزمنية التي تُقرأ بها تلك الساعات حين تقرر المنصة إن كان المطعم مفتوحًا. استعمل اسمًا معياريًا مثل «Africa/Algiers»، وما عداه يُرفض.';

  @override
  String get settingBestSellerCountName => 'عدد الأطباق الأكثر مبيعًا لكل مطعم';

  @override
  String get settingBestSellerCountRole => 'عدد الأطباق التي تحصل على الشارة';

  @override
  String get settingBestSellerCountHelp => 'في تطبيق العميل، تحمل أكثر أطباق المطعم طلبًا شارة «الأكثر مبيعًا». وهذا هو عدد أطباقه التي تحصل عليها، وهي الأكثر ورودًا في الطلبات المُسلَّمة. ضع 0 لعدم عرض أي شارة.';

  @override
  String get settingBestSellerDaysName => 'فترة الأكثر مبيعًا (بالأيام)';

  @override
  String get settingBestSellerDaysRole => 'الأيام التي تُحتسب للشارة';

  @override
  String get settingBestSellerDaysHelp => 'لا تُحتسب للشارة إلا الطلبات المُسلَّمة خلال هذا العدد من الأيام الماضية، لتواكب ما يطلبه العملاء الآن. فالقيمة 30 مثلًا تعني طلبات الشهر الأخير.';

  @override
  String get settingBestSellerMinOrdersName => 'الطلبات اللازمة لشارة الأكثر مبيعًا';

  @override
  String get settingBestSellerMinOrdersRole => 'أقل ما يحتاجه الطبق للشارة';

  @override
  String get settingBestSellerMinOrdersHelp => 'لا يحصل الطبق على الشارة إلا إذا ورد في هذا العدد على الأقل من الطلبات المُسلَّمة خلال تلك الفترة. فالمطعم الجديد قليل الطلبات لا تظهر له شارة حتى تبلغ أطباقه هذا العدد.';

  @override
  String get settingLoyaltyEnabledName => 'نقاط الولاء';

  @override
  String get settingLoyaltyEnabledRole => 'مفعّلة أو معطّلة';

  @override
  String get settingLoyaltyEnabledHelp => 'إذا كانت القيمة true، يكسب العملاء نقاطًا على كل طلب مُسلَّم ويمكنهم استبدالها بقسائم خصم. وإذا كانت false، فلا تُكسب نقاط ولا تُستبدل، وتبقى الأرصدة المكتسبة محفوظة. وبذلك يتوقف برنامج الولاء مؤقتًا من دون فقدان شيء.';

  @override
  String get settingLoyaltyEarnRateName => 'النقاط المكتسبة لكل دينار';

  @override
  String get settingLoyaltyEarnRateRole => 'ما يكسبه العميل من الطلب';

  @override
  String get settingLoyaltyEarnRateHelp => 'نقاط الولاء التي يحصل عليها العميل عن كل دينار يدفعه في طلب مُسلَّم (المجموع مع التوصيل بعد الخصومات). فالقيمة 0.1 مثلًا تعني أن طلبًا بقيمة 1000 دج يكسب 100 نقطة. المعدل الأعلى يجعل البرنامج أسخى، والأقل يكلّف المنصة أقل.';

  @override
  String get settingLoyaltyRedeemRateName => 'قيمة النقطة عند الاستبدال (دج)';

  @override
  String get settingLoyaltyRedeemRateRole => 'قيمة النقطة';

  @override
  String get settingLoyaltyRedeemRateHelp => 'قيمة نقطة الولاء حين يستبدلها العميل بقسيمة. فالقيمة 0.5 مثلًا تعني أن 200 نقطة تساوي قسيمة بقيمة 100 دج. وهي تحدد التكلفة الحقيقية للبرنامج: القيمة الأقل تحمي هوامش الربح، والأعلى تشجع العملاء أكثر على استبدال نقاطهم.';

  @override
  String get settingLoyaltyMinRedeemPointsName => 'أقل عدد من النقاط للاستبدال';

  @override
  String get settingLoyaltyMinRedeemPointsRole => 'أقل ما يستبدله العميل دفعة واحدة';

  @override
  String get settingLoyaltyMinRedeemPointsHelp => 'لا يمكن للعميل استبدال نقاط أقل من هذا العدد دفعة واحدة. يمنع هذا الحد الأدنى (100 نقطة مثلًا) القسائم الصغيرة جدًا، ويتيح للعملاء جمع رصيد حقيقي أولًا.';

  @override
  String get settingLoyaltyTiersName => 'شرائح الاستبدال';

  @override
  String get settingLoyaltyTiersRole => 'مقادير النقاط التي يمكن للعميل استبدالها';

  @override
  String get settingLoyaltyTiersHelp => 'مقادير النقاط الدقيقة التي يمكن للعميل استبدالها دفعة واحدة، في قائمة JSON من أعداد صحيحة، مثل [100, 500, 1000, 2000]. ولا يعرض تطبيق العميل إلا هذه المقادير. ويجب ألا يقل كل منها عن الحد الأدنى للاستبدال.';

  @override
  String get settingMaxCouponsPerCategoryName => 'القسائم من النوع نفسه في الطلب';

  @override
  String get settingMaxCouponsPerCategoryRole => 'جمع قسائم من النوع نفسه';

  @override
  String get settingMaxCouponsPerCategoryHelp => 'أكبر عدد من القسائم من النوع نفسه (مطعم أو توصيل أو عامة) يمكن استعماله في طلب واحد. فمع القيمة 1 لا يمكن للعميل وضع قسيمتي مطعم على طلب واحد. وتُحتسب قسائم الولاء قسائمَ مطعم. ارفعه للسماح بجمع قسائم من النوع نفسه.';

  @override
  String get settingMaxCouponCategoriesName => 'أنواع القسائم في الطلب';

  @override
  String get settingMaxCouponCategoriesRole => 'الجمع بين أنواع مختلفة من القسائم';

  @override
  String get settingMaxCouponCategoriesHelp => 'أكبر عدد من أنواع القسائم المختلفة (مطعم وتوصيل وعامة) يمكن استعمالها معًا في طلب واحد. فالقيمة 2 مثلًا تعني أن الطلب يجمع نوعين على الأكثر، كقسيمة مطعم وقسيمة توصيل. ومع القيمة 3 يمكن استعمال الأنواع الثلاثة معًا.';

  @override
  String confirmPaymentReceived(String amount, String payer) {
    return 'هل استلمت $amount من $payer؟';
  }

  @override
  String get paymentRecordedNotice => 'تم تسجيل الدفعة';

  @override
  String get refusedAt => 'وقت الرفض';

  @override
  String get paymentWaitingForAnswer => 'دفعة أُرسلت من التطبيق تنتظر ردك في سجل المعاملات، ولم تُحتسب بعد.';

  @override
  String get reasonLoyaltyCouponCredit => 'رصيد قسيمة الولاء';

  @override
  String get reject => 'رفض';

  @override
  String paymentNote(String note) {
    return 'ملاحظة: $note';
  }

  @override
  String paymentAnswer(String note) {
    return 'الرد: $note';
  }

  @override
  String get paymentConfirmedNotice => 'تم تأكيد الدفعة';

  @override
  String get paymentRefusedNotice => 'تم رفض الدفعة';

  @override
  String get refusePaymentTitle => 'هل تريد رفض هذه الدفعة؟';

  @override
  String get refusePaymentReasonHint => 'ما السبب؟ (مثلًا: لم أستلمها)';

  @override
  String get confirmPaymentReceivedTitle => 'هل استلمت الدفعة؟';

  @override
  String get creditDetails => 'تفاصيل المستحقات';

  @override
  String get debtDetails => 'تفاصيل الدين';

  @override
  String get orderSettlements => 'تسويات الطلبات';

  @override
  String get cashTransactions => 'المعاملات النقدية';

  @override
  String get noTransactionsInPeriod => 'لا توجد معاملات في هذه الفترة';

  @override
  String get receivedPayment => 'دفعة مستلمة';

  @override
  String get sentPayment => 'دفعة مرسلة';

  @override
  String get totalOrderSettlements => 'مجموع التسويات';

  @override
  String get totalCashOutgoing => 'مجموع المدفوعات المرسلة';

  @override
  String get totalCashIncoming => 'مجموع المدفوعات المستلمة';

  @override
  String get netBalance => 'صافي الرصيد';

  @override
  String get paidTowardsOrders => 'المدفوع عن هذه الطلبات';

  @override
  String get cashPaidInTheseDays => 'المبالغ النقدية المدفوعة في هذه الأيام';

  @override
  String get cashReceivedInTheseDays => 'المبالغ النقدية المستلمة في هذه الأيام';

  @override
  String get reasonOvercharge => 'مبلغ زائد';

  @override
  String get reasonOrderSettlement => 'تسوية طلب';

  @override
  String get reasonCouponCredit => 'رصيد قسيمة';

  @override
  String get reasonGlobalCouponCredit => 'رصيد قسيمة عامة';

  @override
  String get reasonBirthdayCredit => 'رصيد هدية عيد الميلاد';

  @override
  String get deliveryAreas => 'مناطق التوصيل';

  @override
  String get deliveryAreasHelp => 'لا يمكن للعملاء الطلب إلا إلى عنوان يقع داخل منطقة مفعّلة.';

  @override
  String get noDeliveryAreasYet => 'لا توجد منطقة توصيل بعد، لذا لا يمكن لأي عميل الطلب.';

  @override
  String get addDeliveryArea => 'إضافة منطقة توصيل';

  @override
  String get editDeliveryArea => 'تعديل منطقة التوصيل';

  @override
  String get deliveryAreaOn => 'مفعّلة: يمكن للعملاء الطلب فيها';

  @override
  String get deliveryAreaOff => 'معطّلة: لا يمكن لأي عميل الطلب فيها';

  @override
  String get deleteDeliveryArea => 'حذف منطقة التوصيل';

  @override
  String deleteDeliveryAreaConfirmation(String name) {
    return 'هل تريد حذف $name؟ لن يتمكن العملاء في هذه المنطقة من الطلب بعد الآن.';
  }

  @override
  String get coordinatesInvalid => 'دوائر العرض من -90 إلى 90، وخطوط الطول من -180 إلى 180';

  @override
  String get radiusOutOfRange => 'نصف القطر من 0.1 إلى 100 كم';

  @override
  String get payFromPlatform => 'الدفع من المنصة';

  @override
  String platformPaymentTitle(String name) {
    return 'دفعة من المنصة إلى $name';
  }

  @override
  String get platformPaymentHelp => 'تُحتسب فورًا ويُبلَّغ المستفيد بها. ما يُدفع زيادة على المستحق يصبح دينًا عليه للمنصة.';

  @override
  String get platformPaymentRecorded => 'تم تسجيل دفعة المنصة';

  @override
  String get paidByThePlatform => 'دفعته المنصة';

  @override
  String get paidBeyondWhatWasOwed => 'مدفوع زيادة على المستحق';

  @override
  String get systemAccount => 'المنصة';

  @override
  String ratingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تقييم',
      many: '$count تقييمًا',
      few: '$count تقييمات',
      two: 'تقييمان',
      one: 'تقييم واحد',
    );
    return '$_temp0';
  }
}
