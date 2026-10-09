// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'تطبيق المدير';

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
  String get forgotPassword => 'نسيت كلمة المرور';

  @override
  String get signInWithGoogle => 'تسجيل الدخول باستخدام جوجل';

  @override
  String get checkingAuthentication => 'جاري فحص المصادقة...';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get language => 'اللغة';

  @override
  String get or => 'أو';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get userType => 'نوع المستخدم';

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
  String get appInformation => 'معلومات حول التطبيق';

  @override
  String get version => 'الإصدار';

  @override
  String get checkForUpdates => 'التحقق من التحديثات';

  @override
  String get aboutApp => 'حول التطبيق';

  @override
  String get aboutDescription => 'تطبيق المدير يمنحك إشرافاً كاملاً على منصة التوصيل بأكملها. وافق على المستخدمين، راقب الأداء، اضبط إعدادات النظام، وأدِر الكوبونات — كل ذلك من لوحة تحكم إدارية متكاملة.';

  @override
  String get features => 'الميزات';

  @override
  String get userAuthentication => 'إدارة المستخدمين';

  @override
  String get userAuthenticationDescription => 'الموافقة على السائقين والمطاعم والمشغلين وإدارة تعليق الحسابات';

  @override
  String get multiLanguageSupport => 'التحليلات والتقارير';

  @override
  String get multiLanguageSupportDescription => 'متابعة الإيرادات واتجاهات الطلبات وأداء المنصة عبر لوحات معلومات مفصلة';

  @override
  String get secureStorage => 'إعدادات النظام';

  @override
  String get secureStorageDescription => 'ضبط رسوم التوصيل ونسب العمولة والقواعد التشغيلية للمنصة';

  @override
  String get googleSignIn => 'الكوبونات';

  @override
  String get googleSignInDescription => 'إنشاء الكوبونات وتحديد حدودها والمناطق التي تُطبَّق فيها';

  @override
  String get contactUs => 'اتصل بنا';

  @override
  String copyright(String year) {
    return '© $year تطبيق المدير. جميع الحقوق محفوظة.';
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
  String get statisticsMoney => 'المال';

  @override
  String get statisticsOrders => 'الطلبات';

  @override
  String get ordersPlaced => 'طلبات';

  @override
  String get ordersPendingVerification => 'قيد التحقق';

  @override
  String get ordersAcceptedByOperator => 'تم القبول من قبل المشغل';

  @override
  String get ordersAcceptedByRestaurant => 'تم القبول من قبل المطعم';

  @override
  String get ordersRejectedByOperator => 'تم الرفض من قبل المشغل';

  @override
  String get ordersRejectedByRestaurant => 'تم الرفض من قبل المطعم';

  @override
  String get ordersAcceptedByDriver => 'تم القبول من قبل السائق';

  @override
  String get ordersCancelled => 'ملغاة';

  @override
  String get noUserDataAvailable => 'لا توجد بيانات مستخدم متاحة';

  @override
  String get user => 'مستخدم';

  @override
  String get delivered => 'تم التوصيل';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get resetYourPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get enterEmailDescription => 'أدخل عنوان بريدك الإلكتروني وسنرسل لك رمز OTP لإعادة تعيين كلمة المرور.';

  @override
  String get emailAddress => 'عنوان البريد الإلكتروني';

  @override
  String get sendOtp => 'إرسال OTP';

  @override
  String get enterOtpCode => 'أدخل رمز OTP';

  @override
  String get enterOtpDescription => 'أدخل رمز OTP المكون من 6 أرقام المرسل إلى بريدك الإلكتروني\nسيتم التحقق منه تلقائياً عند الاكتمال';

  @override
  String get setNewPassword => 'تعيين كلمة مرور جديدة';

  @override
  String get enterNewPasswordDescription => 'أدخل كلمة المرور الجديدة أدناه';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get confirmNewPassword => 'تأكيد كلمة المرور';

  @override
  String get resendOtp => 'إعادة إرسال OTP';

  @override
  String get verifyEmail => 'التحقق من البريد الإلكتروني';

  @override
  String get enterOtp => 'أدخل رمز OTP';

  @override
  String get otpSentTo => 'تم إرسال رمز OTP إلى';

  @override
  String get verifyOtp => 'التحقق من OTP';

  @override
  String get confirmEmailChange => 'تأكيد تغيير البريد الإلكتروني';

  @override
  String resendIn(int seconds) {
    return 'يمكنك إعادة إرسال OTP خلال $seconds ثانية';
  }

  @override
  String get emailNotVerified => 'البريد الإلكتروني غير موثق';

  @override
  String get emailVerificationRequired => 'يرجى التحقق من عنوان بريدك الإلكتروني قبل الوصول إلى هذا المورد. تم إرسال رمز التحقق (OTP) إلى عنوان بريدك الإلكتروني. يرجى التحقق من صندوق الوارد وإدخال الرمز المكون من 6 أرقام للتحقق من بريدك الإلكتروني.';

  @override
  String get resendVerificationEmail => 'إعادة التحقق';

  @override
  String get checkStatus => 'فحص الحالة';

  @override
  String get checkStatusDescription => 'اضغط على \"فحص الحالة\" لمعرفة ما إذا تمت الموافقة على حسابك';

  @override
  String get initializing => 'جاري التهيئة...';

  @override
  String get initializationFailed => 'فشل في التهيئة';

  @override
  String get checkingInternet => 'جاري فحص الاتصال بالإنترنت...';

  @override
  String get noInternetConnection => 'لا يوجد اتصال بالإنترنت';

  @override
  String get noInternetDescription => 'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get updateRequired => 'تحديث مطلوب';

  @override
  String get updateRequiredDescription => 'إصدار جديد من التطبيق متاح. يرجى التحديث للمتابعة في استخدام التطبيق.';

  @override
  String get minimumRequiredVersion => 'الحد الأدنى المطلوب للإصدار';

  @override
  String get latestAvailableVersion => 'أحدث إصدار متاح';

  @override
  String get updateNow => 'تحديث الآن';

  @override
  String get updateIsRequired => 'التحديث مطلوب للمتابعة';

  @override
  String get yourCurrentVersion => 'إصدارك الحالي';

  @override
  String get updateAvailable => 'تحديث متاح. يرجى التحديث للمتابعة في استخدام التطبيق.';

  @override
  String get updateAvailableOptional => 'إصدار جديد متاح. قم بالتحديث للحصول على أحدث الميزات.';

  @override
  String get appUpToDate => 'التطبيق محدث!';

  @override
  String get accountStatus => 'حالة الحساب';

  @override
  String get areYouSureLogout => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get theme => 'المظهر';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get system => 'النظام';

  @override
  String get pleaseEnterEmail => 'الرجاء إدخال بريدك الإلكتروني';

  @override
  String get pleaseEnterValidEmail => 'الرجاء إدخال بريد إلكتروني صالح';

  @override
  String get pleaseEnterPassword => 'الرجاء إدخال كلمة المرور';

  @override
  String get passwordMinLength => 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

  @override
  String get newEmailAddress => 'عنوان البريد الإلكتروني الجديد';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get newEmailMustBeDifferent => 'يجب أن يكون البريد الإلكتروني الجديد مختلفًا عن البريد الإلكتروني الحالي';

  @override
  String get day => 'يوم';

  @override
  String get month => 'شهر';

  @override
  String get year => 'سنة';

  @override
  String get dateRange => 'نطاق تاريخ';

  @override
  String get from => 'من';

  @override
  String get to => 'إلى';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get errorLoadingStatistics => 'خطأ في تحميل الإحصائيات';

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
  String get acceptedOrdersSuccessRateGood => 'معدل نجاح عالي يعني أنك تقبل طلبات يمكنك تنفيذها بشكل موثوق.';

  @override
  String get acceptedOrdersSuccessRateBad => 'معدل نجاح منخفض يشير إلى مشاكل في تنفيذ الطلبات - راجع قدرتك.';

  @override
  String get acceptedOrdersFailureRateGood => 'معدل فشل منخفض يظهر معالجة موثوقة للطلبات.';

  @override
  String get acceptedOrdersFailureRateBad => 'معدل فشل عالي يضر بالسمعة - فكر لماذا تفشل الطلبات.';

  @override
  String get averageRespondingTimeGood => 'أوقات الاستجابة السريعة تؤدي إلى رضا العملاء وقبول أعلى للطلبات.';

  @override
  String get averageRespondingTimeBad => 'أوقات الاستجابة البطيئة قد تؤدي إلى إلغاء الطلبات وعدم رضا العملاء.';

  @override
  String get whenGood => 'عندما يكون جيداً';

  @override
  String get whenBad => 'عندما يكون سيئاً';

  @override
  String get close => 'إغلاق';

  @override
  String get all => 'الكل';

  @override
  String get second => 'ثانية';

  @override
  String get seconds => 'ثواني';

  @override
  String get minute => 'دقيقة';

  @override
  String get hour => 'ساعة';

  @override
  String get errorGeneric => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get errorNetworkTimeout => 'انتهت مهلة الطلب. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';

  @override
  String get errorConnectionError => 'لا يمكن الاتصال بالخادم. يرجى التحقق من اتصالك بالإنترنت والتأكد من أن الخادم يعمل.';

  @override
  String get errorRequestCancelled => 'تم إلغاء الطلب. يرجى المحاولة مرة أخرى.';

  @override
  String get errorNetworkGeneric => 'حدث خطأ في الشبكة. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';

  @override
  String get errorInvalidRequest => 'طلب غير صالح. يرجى التحقق من المدخلات والمحاولة مرة أخرى.';

  @override
  String get errorSessionExpired => 'انتهت صلاحية جلستك. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get errorNoPermission => 'ليس لديك إذن لتنفيذ هذا الإجراء.';

  @override
  String get errorNotFound => 'لم يتم العثور على المورد المطلوب.';

  @override
  String get errorConflict => 'يتعارض هذا الإجراء مع الحالة الحالية. يرجى التحديث والمحاولة مرة أخرى.';

  @override
  String get errorValidation => 'خطأ في التحقق. يرجى التحقق من المدخلات.';

  @override
  String get errorTooManyRequests => 'طلبات كثيرة جداً. يرجى الانتظار قليلاً والمحاولة مرة أخرى.';

  @override
  String get errorServerUnavailable => 'الخدمة غير متاحة مؤقتاً. يرجى المحاولة مرة أخرى لاحقاً.';

  @override
  String get errorServerGeneric => 'حدث خطأ في الخادم. يرجى المحاولة مرة أخرى لاحقاً.';

  @override
  String get errorDatabaseLocal => 'تعذر حفظ البيانات محلياً. يرجى المحاولة مرة أخرى.';

  @override
  String get errorCacheLoad => 'تعذر تحميل البيانات المخزنة مؤقتاً. يرجى التحديث.';

  @override
  String get errorAuthFailed => 'فشل المصادقة. يرجى التحقق من بيانات الاعتماد والمحاولة مرة أخرى.';

  @override
  String get errorInvalidCredentials => 'بريد إلكتروني أو كلمة مرور غير صحيحة. يرجى التحقق من بيانات الاعتماد والمحاولة مرة أخرى.';

  @override
  String get errorAuthRequired => 'المصادقة مطلوبة. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get errorSignInCancelled => 'تم إلغاء تسجيل الدخول.';

  @override
  String get errorServerMaintenance => 'الخدمة غير متاحة مؤقتاً للصيانة. يرجى المحاولة مرة أخرى لاحقاً.';

  @override
  String get errorDatabaseServer => 'حدث خطأ في قاعدة البيانات. يرجى المحاولة مرة أخرى لاحقاً.';

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
  String get passwordMinLength8 => 'يجب أن تكون كلمة المرور 8 أحرف على الأقل';

  @override
  String get passwordComplexity => 'يجب أن تحتوي كلمة المرور على حرف كبير وصغير ورقم ورمز';

  @override
  String get pleaseConfirmNewPassword => 'يرجى تأكيد كلمة المرور الجديدة';

  @override
  String get passwordsDoNotMatch => 'كلمات المرور غير متطابقة';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountConfirmation => 'هل أنت متأكد من أنك تريد حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء وستتم إزالة جميع بياناتك بشكل دائم.\n\nستحتاج إلى التحقق من هويتك برمز OTP سيتم إرساله إلى بريدك الإلكتروني.';

  @override
  String get continueButton => 'متابعة';

  @override
  String errorOpeningUrl(String error) {
    return 'خطأ في فتح الرابط: $error';
  }

  @override
  String get emailVerifiedSuccessfully => 'تم التحقق من البريد الإلكتروني بنجاح';

  @override
  String get failedToVerifyEmailOtp => 'فشل التحقق من رمز OTP للبريد الإلكتروني';

  @override
  String get requestTimeoutCheckConnection => 'انتهت مهلة الطلب. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';

  @override
  String get cannotConnectToServer => 'تعذر الاتصال بالخادم. يرجى التحقق من اتصالك بالإنترنت.';

  @override
  String get verificationOtpSentSuccessfully => 'تم إرسال رمز التحقق OTP بنجاح. يرجى التحقق من بريدك الإلكتروني.';

  @override
  String get failedToResendVerificationOtp => 'فشل إعادة إرسال رمز التحقق OTP';

  @override
  String get emailChangeOtpSentSuccessfully => 'تم إرسال رمز OTP لتغيير البريد الإلكتروني بنجاح. يرجى التحقق من بريدك الإلكتروني الجديد.';

  @override
  String get pleaseEnterValid6DigitOtp => 'يرجى إدخال رمز OTP صحيح مكون من 6 أرقام';

  @override
  String get urlNotAvailable => 'الرابط غير متاح. يرجى المحاولة مرة أخرى لاحقاً.';

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
  String get clearFilters => 'مسح المرشحات';

  @override
  String get bank => 'البنك';

  @override
  String get errorLoadingData => 'خطأ في تحميل البيانات';

  @override
  String get noDataAvailable => 'لا توجد بيانات متاحة';

  @override
  String get amount => 'المبلغ';

  @override
  String get driver => 'سائق';

  @override
  String get transactions => 'المعاملات';

  @override
  String get bankArchive => 'أرشيف البنك';

  @override
  String get approvedBy => 'تمت الموافقة من قبل';

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
  String get payables => 'المدفوعات';

  @override
  String get receivablesAndPayables => 'المستحقات والمدفوعات';

  @override
  String get newTransaction => 'معاملة جديدة';

  @override
  String get transactionsHistory => 'سجل المعاملات';

  @override
  String get performance => 'الأداء';

  @override
  String get allTime => 'كل الوقت';

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
  String get responseSpeedDescription => 'الوقت للقبول أو الرفض';

  @override
  String get preparationSpeed => 'سرعة التحضير';

  @override
  String get preparationSpeedDescription => 'الوقت لتحضير الطلبات المقبولة';

  @override
  String get decisionQuality => 'جودة القرار';

  @override
  String get decisionQualityDescription => 'نسبة الطلبات المكتملة من المقبولة';

  @override
  String get poorDecisions => 'قرارات سيئة';

  @override
  String get poorDecisionsDescription => 'نسبة الطلبات الملغاة بعد القبول';

  @override
  String get totalDebt => 'إجمالي الدين';

  @override
  String get systemDebt => 'دين النظام';

  @override
  String get systemDebtDescription => 'المبلغ المستحق لمدير النظام لرسوم التوصيل';

  @override
  String get restaurantDebts => 'ديون المطاعم';

  @override
  String get restaurantCredits => 'المطاعم';

  @override
  String get recordPayment => 'تسجيل الدفع';

  @override
  String get recordSystemPayment => 'تسجيل دفع النظام';

  @override
  String get noDebts => 'لا توجد ديون مستحقة';

  @override
  String get confirmedAt => 'تم التأكيد في';

  @override
  String get invalidAmount => 'مبلغ غير صالح';

  @override
  String get noTransactionsFound => 'لا توجد معاملات';

  @override
  String get paymentType => 'نوع الدفع';

  @override
  String get selectRestaurant => 'اختر مطعم';

  @override
  String get paymentDate => 'تاريخ الدفع';

  @override
  String get totalCredits => 'إجمالي الأرصدة';

  @override
  String get overpay => 'دفع زائد';

  @override
  String get pickupSpeed => 'سرعة الاستلام';

  @override
  String get pickupSpeedDescription => 'الوقت من جاهزية الطعام إلى الاستلام';

  @override
  String get completionRate => 'معدل الإكمال';

  @override
  String get cancellationRate => 'معدل الإلغاء';

  @override
  String get cancellationRateDescription => 'نسبة الطلبات المقبولة التي تم إلغاؤها';

  @override
  String get ok => 'حسناً';

  @override
  String get understood => 'فهمت';

  @override
  String get tryAgain => 'حاول مجدداً';

  @override
  String get wrongApp => 'تطبيق خاطئ';

  @override
  String get accountNotFound => 'الحساب غير موجود';

  @override
  String get accountNotFoundMessage => 'لا يوجد حساب مدير بهذا البريد الإلكتروني. فريق المنصة هو من يُنشئ حسابات المديرين، وليس التطبيق.';

  @override
  String get loginFailed => 'فشل تسجيل الدخول';

  @override
  String get invalidCredentialsMessage => 'البريد الإلكتروني أو كلمة المرور التي أدخلتها غير صحيحة. يرجى التحقق من بيانات الاعتماد والمحاولة مرة أخرى.';

  @override
  String get userManagement => 'إدارة المستخدمين';

  @override
  String get errorLoadingUsers => 'خطأ في تحميل المستخدمين';

  @override
  String get noUsersFound => 'لم يتم العثور على مستخدمين';

  @override
  String get noUsersMatchFilters => 'لا يوجد مستخدمون يطابقون المرشحات';

  @override
  String get noUsersInSystem => 'لا يوجد مستخدمون في النظام';

  @override
  String get userApprovedSuccessfully => 'تمت الموافقة على المستخدم بنجاح';

  @override
  String get userRejectedSuccessfully => 'تم رفض المستخدم بنجاح';

  @override
  String get userSuspendedSuccessfully => 'تم تعليق المستخدم بنجاح';

  @override
  String get userActivatedSuccessfully => 'تم تنشيط المستخدم بنجاح';

  @override
  String get changeStatus => 'تغيير الحالة';

  @override
  String get pendingApproval => 'في انتظار الموافقة';

  @override
  String get suspended => 'معلق';

  @override
  String get operator => 'مشغل';

  @override
  String get manager => 'مدير';

  @override
  String get filters => 'المرشحات';

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
    return 'جاري رفض: $userName';
  }

  @override
  String get rejectionReasonLabel => 'سبب الرفض *';

  @override
  String get enterRejectionReason => 'أدخل سبب الرفض...';

  @override
  String get minimumCharacters => '10 أحرف كحد أدنى';

  @override
  String get rejectionReasonRequired => 'سبب الرفض مطلوب';

  @override
  String get reasonMinimum10Characters => 'يجب أن يكون السبب 10 أحرف على الأقل';

  @override
  String get suspendUser => 'تعليق المستخدم';

  @override
  String suspendingUser(String userName) {
    return 'جاري تعليق: $userName';
  }

  @override
  String get suspensionReasonLabel => 'سبب التعليق *';

  @override
  String get enterSuspensionReason => 'أدخل سبب التعليق...';

  @override
  String get suspensionReasonRequired => 'سبب التعليق مطلوب';

  @override
  String get searchUsers => 'البحث بالاسم أو البريد الإلكتروني أو الهاتف';

  @override
  String get coupons => 'قسائم الخصم';

  @override
  String get restaurantCoupons => 'قسائم المطاعم';

  @override
  String get deliveryCoupons => 'قسائم التوصيل';

  @override
  String get draft => 'مسودة';

  @override
  String get disabled => 'معطل';

  @override
  String get newDeliveryCoupon => 'قسيمة توصيل جديدة';

  @override
  String get newCoupon => 'قسيمة جديدة';

  @override
  String get noDeliveryCouponsYet => 'لا توجد قسائم توصيل بعد';

  @override
  String get noCouponsYet => 'لا توجد قسائم بعد';

  @override
  String get createFirstDeliveryCoupon => 'أنشئ قسيمة التوصيل الأولى!';

  @override
  String get createFirstCoupon => 'أنشئ قسيمتك الأولى لجذب المزيد من العملاء!';

  @override
  String get off => 'خصم';

  @override
  String get discount => 'خصم';

  @override
  String get valid => 'صالح';

  @override
  String get uses => 'الاستخدامات';

  @override
  String get minOrder => 'الحد الأدنى للطلب';

  @override
  String get dzd => 'دج';

  @override
  String get expired => 'منتهية الصلاحية';

  @override
  String get globalAllRestaurants => 'عام (جميع المطاعم)';

  @override
  String get issuer => 'المُصدر: ';

  @override
  String get discardChanges => 'تجاهل التغييرات؟';

  @override
  String get editCoupon => 'تعديل القسيمة';

  @override
  String get update => 'تحديث';

  @override
  String get create => 'إنشاء';

  @override
  String get couponCode => 'كود القسيمة';

  @override
  String get couponCodeHint => 'مثال: SUMMER20';

  @override
  String get pleaseEnterCouponCode => 'الرجاء إدخال كود القسيمة';

  @override
  String get codeMinLength => 'يجب أن يكون الكود 3 أحرف على الأقل';

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
  String get discountAppliesTo => 'الخصم ينطبق على';

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
  String get totalUses => 'إجمالي الاستخدامات';

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
  String get internalNoteHint => 'ملاحظة داخلية حول هذه القسيمة...';

  @override
  String get noCouponZonesAvailable => 'لا توجد مناطق متاحة للقسيمة. أنشئ مناطق لتقييد توفر القسيمة.';

  @override
  String get selectZonesInfo => 'اختر المناطق (ينطبق على الكل إذا لم يتم الاختيار)';

  @override
  String get noRestaurantsAvailable => 'لا توجد مطاعم متاحة. ستكون هذه القسيمة عامة.';

  @override
  String get selectedRestaurant => 'المطعم المحدد';

  @override
  String get allRestaurantsGlobal => 'جميع المطاعم (عام)';

  @override
  String get kmRadius => 'كم نصف قطر';

  @override
  String get couponZones => 'مناطق القسيمة';

  @override
  String get addZone => 'إضافة منطقة';

  @override
  String get success => 'نجح!';

  @override
  String get errorOccurred => 'حدث خطأ';

  @override
  String get noCouponZonesYet => 'لا توجد مناطق قسيمة بعد';

  @override
  String get createZonesToRestrict => 'أنشئ مناطق لتقييد القسائم\\nإلى مناطق محددة';

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
    return 'هل أنت متأكد أنك تريد حذف \"$zoneName\"؟';
  }

  @override
  String get currency => 'دج';

  @override
  String get revenueOverview => 'نظرة عامة';

  @override
  String get totalRevenue => 'إجمالي الإيرادات';

  @override
  String get subtotalRevenue => 'مجموع الطعام';

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
  String get subtotalRevenueDesc => 'إجمالي تكلفة الطعام عبر جميع الطلبات المُسلَّمة، باستثناء رسوم التوصيل.';

  @override
  String get deliveryFeesDesc => 'إجمالي رسوم التوصيل المحصَّلة من العملاء عبر جميع الطلبات المُسلَّمة.';

  @override
  String get platformRevenueDesc => 'عمولة المنصة: نسبة مئوية مأخوذة من طلبات الطعام الخاصة بالمطاعم ومن رسوم توصيل السائقين.';

  @override
  String get driversRevenueDesc => 'ما يحتفظ به السائقون فعليًا: رسوم التوصيل المحصَّلة ناقص عمولة المنصة على عمليات التوصيل.';

  @override
  String get restaurantsRevenueDesc => 'ما تحتفظ به المطاعم فعليًا: إيرادات طلبات الطعام ناقص عمولة المنصة على الطلبات الغذائية.';

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
  String get totalDeliveries => 'إجمالي التوصيلات';

  @override
  String get completedDeliveries => 'التوصيلات المكتملة';

  @override
  String get cancelledDeliveries => 'التوصيلات الملغاة';

  @override
  String get onTimeRate => 'معدل الالتزام بالوقت';

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
  String get reorderRate => 'معدل إعادة الطلب';

  @override
  String get recommendRate => 'معدل التوصية';

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
    return 'لقد أرسلنا رمز التحقق إلى $email';
  }

  @override
  String get confirmAccountDeletionCodeMessage => 'يرجى إدخال الرمز لتأكيد حذف الحساب. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get unableToCheckForUpdates => 'تعذر التحقق من التحديثات. يرجى المحاولة مرة أخرى لاحقاً.';

  @override
  String get accountPendingApprovalMessage => 'حسابك في انتظار موافقة المدير. يرجى الانتظار حتى يراجع المدير حسابك ويوافق عليه قبل أن تتمكن من الوصول إلى النظام. ستتلقى إشعاراً عند الموافقة على حسابك.';

  @override
  String get accountSuspendedMessage => 'تم تعليق حسابك. يرجى التواصل مع الدعم للحصول على المساعدة.';

  @override
  String get accountRejectedMessage => 'تم رفض حسابك. يرجى التواصل مع الدعم للحصول على مزيد من المعلومات.';

  @override
  String balanceForPeriod(String period) {
    return '(الرصيد: $period)';
  }

  @override
  String get updateLinkUnavailable => 'تعذر فتح التحديث على هذا الجهاز. تواصل معنا للحصول على الإصدار الجديد.';

  @override
  String get pageNotFound => 'الصفحة غير موجودة';

  @override
  String get accountApprovedRedirectingMessage => 'تمت الموافقة على حسابك! جارٍ التحويل...';

  @override
  String get accountPendingApproval => 'الحساب بانتظار الموافقة';

  @override
  String get accountPendingApprovalFallbackMessage => 'حسابك بانتظار موافقة المدير. يرجى الانتظار حتى يراجع المدير حسابك ويوافق عليه قبل أن تتمكن من الدخول إلى النظام.';

  @override
  String get accountRejected => 'تم رفض الحساب';

  @override
  String get accountSuspended => 'الحساب موقوف';

  @override
  String get appFailedToInitializeProperly => 'تعذر تشغيل التطبيق بشكل صحيح.';

  @override
  String get pleaseConfirmYourPassword => 'يرجى تأكيد كلمة المرور';

  @override
  String get nameIsRequired => 'الاسم مطلوب';

  @override
  String get nameTooShort => 'يجب أن يتكون الاسم من حرفين على الأقل';

  @override
  String get phoneTooShort => 'يجب أن يتكون رقم الهاتف من 10 أرقام على الأقل';

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
  String get settingSystemManagerOrderPercentageHelp => 'النسبة المئوية من المجموع الفرعي لأطباق كل طلب التي تحتفظ بها المنصة عمولةً لها. مثلاً، القيمة 10 تعني أن المنصة تكسب 10 دج عن كل 100 دج من الأطباق المطلوبة. عند توصيل الطلب، يسجّلها البنك مبلغاً مستحقاً على المطعم للمنصة (أما السائق فيدين للمطعم بكامل المجموع الفرعي للأطباق).';

  @override
  String get settingSystemManagerDeliveryFeePercentageName => 'الحصة من رسوم التوصيل (%)';

  @override
  String get settingSystemManagerDeliveryFeePercentageRole => 'حصة المنصة من كل رسوم توصيل';

  @override
  String get settingSystemManagerDeliveryFeePercentageHelp => 'النسبة المئوية من رسوم التوصيل التي تذهب إلى المنصة، ويحتفظ السائق بالباقي. مثلاً، مع القيمة 30 تحتفظ المنصة بـ 30% من كل رسوم توصيل ويأخذ السائق 70%. يطبّقها البنك في كل مرة يُسلَّم فيها طلب.';

  @override
  String get settingContactEmailName => 'البريد الإلكتروني للدعم';

  @override
  String get settingContactEmailRole => 'يظهر في كل التطبيقات';

  @override
  String get settingContactEmailHelp => 'يظهر مع بقية بيانات الاتصال في صفحتي الاتصال وحول التطبيق في كل التطبيقات (العميل، السائق، المطعم، المشغل). غيّره كلما تغيّر بريد الدعم، حتى يصل المستخدمون دائماً إلى العنوان الصحيح.';

  @override
  String get settingContactPhoneName => 'هاتف الدعم';

  @override
  String get settingContactPhoneRole => 'يظهر في كل التطبيقات';

  @override
  String get settingContactPhoneHelp => 'يظهر في صفحة الاتصال في كل التطبيقات. تقرؤه التطبيقات من الخادم، فيصل أي تغيير هنا إليها جميعاً فوراً دون إصدار جديد.';

  @override
  String get settingContactWebsiteName => 'الموقع الإلكتروني';

  @override
  String get settingContactWebsiteRole => 'يظهر في كل التطبيقات';

  @override
  String get settingContactWebsiteHelp => 'عنوان الموقع الإلكتروني لمنصتك، يظهر في صفحتي حول التطبيق والاتصال في كل التطبيقات، ويُفتح في متصفح الهاتف عند لمسه.';

  @override
  String get settingContactAddressName => 'العنوان البريدي';

  @override
  String get settingContactAddressRole => 'عنوان الشركة';

  @override
  String get settingContactAddressHelp => 'العنوان الرسمي لشركتك. يُطبع في قسم الاتصال من صفحتي سياسة الخصوصية وشروط الخدمة (بكل اللغات)، ويُرسَل إلى التطبيقات مع بقية بيانات الاتصال. اتركه فارغاً لإخفاء سطر العنوان.';

  @override
  String get settingMinimumDeliveryFeeName => 'الحد الأدنى لرسوم التوصيل';

  @override
  String get settingMinimumDeliveryFeeRole => 'أقل ما يكلّفه التوصيل';

  @override
  String get settingMinimumDeliveryFeeHelp => 'أقل مبلغ يدفعه العميل للتوصيل مهما كان المطعم قريباً. مثلاً، القيمة 50 تعني أن طلباً على بعد 300 متر يكلّف مع ذلك 50 دج للتوصيل. ضع 0 لإلغاء الحد الأدنى: تُستعمل نتيجة الحساب كما هي.';

  @override
  String get settingMaximumDeliveryFeeName => 'الحد الأقصى لرسوم التوصيل';

  @override
  String get settingMaximumDeliveryFeeRole => 'أقصى ما يكلّفه التوصيل';

  @override
  String get settingMaximumDeliveryFeeHelp => 'أقصى مبلغ يمكن أن يدفعه العميل للتوصيل مهما كان المطعم بعيداً. مثلاً، القيمة 500 تعني أن طلباً على بعد 20 كم لا يكلّف أبداً أكثر من 500 دج للتوصيل. ضع 0 لإلغاء الحد الأقصى: تُستعمل نتيجة الحساب كما هي.';

  @override
  String get settingMaxDriverConcurrentOrdersName => 'الطلبات لدى السائق في وقت واحد';

  @override
  String get settingMaxDriverConcurrentOrdersRole => 'أقصى عدد من الطلبات الجارية لكل سائق';

  @override
  String get settingMaxDriverConcurrentOrdersHelp => 'أكبر عدد من الطلبات الجارية يمكن أن يحمله سائق واحد في الوقت نفسه. حين يبلغ السائق هذا العدد لا يُعرض عليه أي طلب جديد حتى يوصل طلباً أو يعيده. ارفعه في أوقات الذروة، واخفضه لتبقى مدة التوصيل قصيرة.';

  @override
  String get settingFixedDeliveryFeeName => 'رسوم التوصيل الثابتة';

  @override
  String get settingFixedDeliveryFeeRole => 'الجزء الثابت من كل رسوم توصيل';

  @override
  String get settingFixedDeliveryFeeHelp => 'مبلغ ثابت يدخل في كل رسوم توصيل مهما كانت المسافة: الرسوم = الرسوم الثابتة + (السعر لكل متر × المسافة بالأمتار)، ثم تُقرَّب وتبقى بين الحد الأدنى والحد الأقصى. رفعه يرفع ما يدفعه كل عميل للتوصيل.';

  @override
  String get settingPricePerMeterName => 'السعر لكل متر';

  @override
  String get settingPricePerMeterRole => 'جزء المسافة من رسوم التوصيل';

  @override
  String get settingPricePerMeterHelp => 'ما يضيفه كل متر من الطريق بين المطعم وعنوان التوصيل إلى الرسوم. مثلاً، 0.02 دج لكل متر تعني أن مساراً طوله 5 كم يضيف 100 دج إلى الرسوم الثابتة. تأتي المسافة عبر الطريق من Mapbox أو OpenRouteService.';

  @override
  String get settingMaxDeliveryDistanceKmName => 'أقصى مسافة للتوصيل (كم)';

  @override
  String get settingMaxDeliveryDistanceKmRole => 'إلى أي مدى يمكن أن يصل التوصيل';

  @override
  String get settingMaxDeliveryDistanceKmHelp => 'يُرفض الطلب الذي يبعد عنوان توصيله عن المطعم أكثر من هذا العدد من الكيلومترات عند تقديمه. يجنّب ذلك السائقين رحلات طويلة جداً ويبقي مدة التوصيل متوقعة. ارفعه أو اخفضه لتوسيع منطقة خدمتك أو تضييقها.';

  @override
  String get settingAverageCitySpeedKmhName => 'السرعة داخل المدينة (كم/س)';

  @override
  String get settingAverageCitySpeedKmhRole => 'لمدة التوصيل حين لا يُعرف المسار';

  @override
  String get settingAverageCitySpeedKmhHelp => 'حين لا يجيب Mapbox ولا OpenRouteService، تُقاس المسافة في خط مستقيم وتعطي هذه السرعة الوقت الذي يستغرقه التوصيل في شوارع المدينة. القيمة المعتادة من 25 إلى 40 كم/س، مراعاةً لحركة المرور والتوقفات.';

  @override
  String get settingAverageHighwaySpeedKmhName => 'السرعة على الطريق السريع (كم/س)';

  @override
  String get settingAverageHighwaySpeedKmhRole => 'للجزء الطويل من مثل هذه الرحلة';

  @override
  String get settingAverageHighwaySpeedKmhHelp => 'تُستعمل مع السرعة داخل المدينة في هذا التقدير بخط مستقيم: بعد مسافة الانتقال من المدينة إلى الطريق السريع، يُحسب باقي الرحلة بهذه السرعة الأعلى. القيمة المعتادة من 80 إلى 120 كم/س.';

  @override
  String get settingCityHighwayTransitionKmName => 'مسافة الانتقال من المدينة إلى الطريق السريع (كم)';

  @override
  String get settingCityHighwayTransitionKmRole => 'حيث تنتهي السرعة داخل المدينة';

  @override
  String get settingCityHighwayTransitionKmHelp => 'في هذا التقدير بخط مستقيم، تُحسب الرحلة الأقصر من هذه المسافة كلها بالسرعة داخل المدينة، وتُحسب الكيلومترات التي تتجاوزها بسرعة الطريق السريع. مثلاً، 5 تعني أول 5 كم بسرعة المدينة والباقي بسرعة الطريق السريع.';

  @override
  String get settingCurrencyName => 'العملة';

  @override
  String get settingCurrencyRole => 'رمز عملة المنصة';

  @override
  String get settingCurrencyHelp => 'رمز ISO 4217 لعملة كل المبالغ في المنصة: مجاميع الطلبات، رسوم التوصيل، الأرباح، الإشعارات. مثلاً، «DZD» للدينار الجزائري. يكتبه الخادم بعد المبالغ ويرسله إلى كل التطبيقات.';

  @override
  String get settingBirthdayGiftEnabledName => 'هدية عيد الميلاد';

  @override
  String get settingBirthdayGiftEnabledRole => 'مفعّلة أو لا';

  @override
  String get settingBirthdayGiftEnabledHelp => 'إذا كانت القيمة true (أو 1)، يحصل العميل الذي يطلب يوم عيد ميلاده على طلبه مدفوعاً حتى سقف الهدية، مرة واحدة في السنة. وإذا كانت false (أو 0)، فلا هدية. يشغّل ذلك العرض أو يوقفه دون المساس بالشيفرة.';

  @override
  String get settingBirthdayGiftCapName => 'سقف هدية عيد الميلاد (دج)';

  @override
  String get settingBirthdayGiftCapRole => 'أقصى ما تغطيه هدية عيد الميلاد';

  @override
  String get settingBirthdayGiftCapHelp => 'أقصى ما تغطيه هدية عيد الميلاد، بعملة المنصة. مثلاً، مع سقف 500، يُخفَّض طلب عيد ميلاد قيمته 700 دج بمقدار 500 دج. يبقي ذلك الهدية معقولة في الطلبات الكبيرة.';

  @override
  String get settingCustomerRestaurantRadiusKmName => 'نصف قطر البحث عن المطاعم (كم)';

  @override
  String get settingCustomerRestaurantRadiusKmRole => 'المطاعم التي يراها العميل';

  @override
  String get settingCustomerRestaurantRadiusKmHelp => 'يرى العميل المطاعم الواقعة ضمن هذا العدد من الكيلومترات من مكانه. نصف قطر أكبر يعرض خيارات أكثر، لكنه قد يُظهر مطاعم بعيدة جداً عن التوصيل في وقت مناسب.';

  @override
  String get settingCustomerRestaurantPrefilterRadiusKmName => 'نصف قطر التصفية الأولية للبحث (كم)';

  @override
  String get settingCustomerRestaurantPrefilterRadiusKmRole => 'فرز أول وأسرع للمطاعم';

  @override
  String get settingCustomerRestaurantPrefilterRadiusKmHelp => 'قبل الحساب الدقيق للمسافة، تحتفظ قاعدة البيانات بالمطاعم الواقعة ضمن هذا النطاق الأوسع فقط، وهو أسرع. يجب ألا يقل عن نصف قطر البحث عن المطاعم: إن كان أصغر استُبعدت مطاعم قريبة، وإن كان أكبر بكثير أبطأ البحث فقط.';

  @override
  String get settingPrivacyPolicyUrlName => 'رابط سياسة الخصوصية';

  @override
  String get settingPrivacyPolicyUrlRole => 'يظهر في كل التطبيقات';

  @override
  String get settingPrivacyPolicyUrlHelp => 'يُفتح في متصفح الهاتف حين يلمس أحدهم «سياسة الخصوصية» في أي تطبيق. غيّره هنا كلما نشرت نسخة جديدة من سياستك: لا حاجة إلى تحديث التطبيقات.';

  @override
  String get settingTermsOfServiceUrlName => 'رابط شروط الخدمة';

  @override
  String get settingTermsOfServiceUrlRole => 'يظهر في كل التطبيقات';

  @override
  String get settingTermsOfServiceUrlHelp => 'يُفتح في متصفح الهاتف حين يلمس أحدهم «شروط الخدمة» في أي تطبيق. غيّره هنا كلما راجعت شروطك: لا حاجة إلى تحديث التطبيقات.';

  @override
  String get settingMinOrderSchedulingMinutesName => 'مهلة جدولة الطلب (دقائق)';

  @override
  String get settingMinOrderSchedulingMinutesRole => 'كم من الوقت مسبقاً تُجدول الطلبات';

  @override
  String get settingMinOrderSchedulingMinutesHelp => 'على العميل الذي يجدول طلباً أن يختار وقتاً بعد هذا العدد من الدقائق على الأقل. مثلاً، 30 تعني أنه لا يمكن جدولة طلب خلال الـ 30 دقيقة القادمة. يمنح ذلك المطاعم والسائقين وقتاً كافياً للاستعداد.';

  @override
  String get settingNumberOfOrdersToBeTrustedName => 'الطلبات اللازمة ليصبح العميل موثوقاً';

  @override
  String get settingNumberOfOrdersToBeTrustedRole => 'متى يتوقف المشغل عن التحقق من طلبات العميل';

  @override
  String get settingNumberOfOrdersToBeTrustedHelp => 'يتحقق مشغل من طلبات العميل الجديد قبل أن تصل إلى المطعم. حين يبلغ العميل هذا العدد من الطلبات المسلَّمة يصبح «موثوقاً»، وتذهب طلباته التالية مباشرة إلى المطعم. اخفضه لتثق أسرع، وارفعه لمزيد من التحقق.';

  @override
  String get settingOtpValidityMinutesName => 'مدة صلاحية الرمز (دقائق)';

  @override
  String get settingOtpValidityMinutesRole => 'كم تبقى الرموز المرسلة بالبريد صالحة';

  @override
  String get settingOtpValidityMinutesHelp => 'تُرسل رموز بالبريد الإلكتروني لإعادة تعيين كلمة المرور، والتحقق من البريد أو تغييره، وتأكيد حذف الحساب. يبقى الرمز صالحاً هذا العدد من الدقائق بعد إرساله، ويذكر البريد ذلك. المدة الأقصر أكثر أماناً، والأطول أرحم بصناديق البريد البطيئة.';

  @override
  String get settingOtpResendWaitSecondsName => 'الانتظار قبل رمز جديد (ثوانٍ)';

  @override
  String get settingOtpResendWaitSecondsRole => 'بين رمزين مرسلين بالبريد';

  @override
  String get settingOtpResendWaitSecondsHelp => 'بعد إرسال رمز، لا يمكن طلب رمز جديد إلا بعد هذا العدد من الثواني، وتعرض التطبيقات العدّ التنازلي. يحدّ ذلك من الرسائل المرسلة إلى عنوان واحد.';

  @override
  String get settingMaxSavedAddressesName => 'العناوين المحفوظة لكل عميل';

  @override
  String get settingMaxSavedAddressesRole => 'كم عنواناً يحتفظ به العميل';

  @override
  String get settingMaxSavedAddressesHelp => 'أكبر عدد من عناوين التوصيل يمكن أن يحتفظ به عميل واحد في التطبيق. يُرفض أي عنوان إضافي برسالة.';

  @override
  String get settingMaxItemsPerOrderName => 'الأطباق في الطلب الواحد';

  @override
  String get settingMaxItemsPerOrderRole => 'أطباق مختلفة في طلب واحد';

  @override
  String get settingMaxItemsPerOrderHelp => 'يُرفض الطلب الذي يحتوي على أطباق مختلفة أكثر من هذا العدد. يبقي ذلك الطلب الواحد في حدود ما يستطيع مطبخ وسائق التعامل معه دفعة واحدة.';

  @override
  String get settingMaxQuantityPerItemName => 'الحصص من الطبق الواحد';

  @override
  String get settingMaxQuantityPerItemRole => 'حصص الطبق الواحد في طلب واحد';

  @override
  String get settingMaxQuantityPerItemHelp => 'أكبر كمية من طبق واحد يمكن أن يطلبها العميل. تُرفض الكمية الأكبر برسالة.';

  @override
  String get settingAmountRoundingStepName => 'خطوة التقريب (دج)';

  @override
  String get settingAmountRoundingStepRole => 'تقريب رسوم التوصيل وخصومات القسائم';

  @override
  String get settingAmountRoundingStepHelp => 'تُقرَّب رسوم التوصيل إلى الأعلى، وخصومات القسائم إلى الأسفل، إلى مضاعف لهذا المبلغ. مع 5، تصبح رسوم 162 دج 165 ويصبح خصم 312 دج 310. ضع 1 لإيقاف التقريب.';

  @override
  String get settingLoyaltyCouponValidityDaysName => 'مدة صلاحية قسيمة الولاء (أيام)';

  @override
  String get settingLoyaltyCouponValidityDaysRole => 'كم تبقى قسيمة الولاء قابلة للاستعمال';

  @override
  String get settingLoyaltyCouponValidityDaysHelp => 'يمكن استعمال القسيمة المحصّلة بنقاط الولاء طوال هذا العدد من الأيام. يعرض تطبيق العميل هذا العدد قبل صرف النقاط.';

  @override
  String get settingDefaultDeliveryTimeMinutesName => 'مدة التوصيل الافتراضية (دقائق)';

  @override
  String get settingDefaultDeliveryTimeMinutesRole => 'حين يكون المسار غير معروف';

  @override
  String get settingDefaultDeliveryTimeMinutesHelp => 'حين يتعذر حساب المسار إلى العميل (لا موقع بعد، أو لا خدمة لحساب المسارات)، يُعرض هذا العدد من الدقائق ويُستعمل مدةً للتوصيل.';

  @override
  String get settingRouteCacheMinutesName => 'مدة الاحتفاظ بمسافة الطريق (دقائق)';

  @override
  String get settingRouteCacheMinutesRole => 'كم من الوقت يُعاد استعمال المسافة المحسوبة';

  @override
  String get settingRouteCacheMinutesHelp => 'تُحفظ المسافة عبر الطريق بين مطعم ومكان التوصيل هذا العدد من الدقائق بدل طلبها من جديد. فتكون الرسوم المدفوعة هي الرسوم المعروضة، وتقلّ طلبات حساب المسارات. لا تخفضه إلا إذا كانت الطرق تتغير كثيراً.';

  @override
  String get settingMapDefaultLatitudeName => 'مركز الخريطة: خط العرض';

  @override
  String get settingMapDefaultLatitudeRole => 'حيث تُفتح خريطة التطبيقات';

  @override
  String get settingMapDefaultLatitudeHelp => 'حين يفتح أحدهم الخريطة لاختيار مكان ولا يُعرف أي موقع بعد، تُفتح الخريطة هنا. اضبطه مع خط الطول على مركز منطقة خدمتك. قيمة بين -90 و90.';

  @override
  String get settingMapDefaultLongitudeName => 'مركز الخريطة: خط الطول';

  @override
  String get settingMapDefaultLongitudeRole => 'حيث تُفتح خريطة التطبيقات';

  @override
  String get settingMapDefaultLongitudeHelp => 'خط الطول المرافق لخط عرض مركز الخريطة: مركز منطقة خدمتك. قيمة بين -180 و180.';

  @override
  String get settingAppMapboxAccessTokenName => 'رمز الخرائط (Mapbox)';

  @override
  String get settingAppMapboxAccessTokenRole => 'يرسم الخرائط في التطبيقات';

  @override
  String get settingAppMapboxAccessTokenHelp => 'رمز Mapbox العام (يبدأ بـ «pk.») الذي ترسم به تطبيقات العميل والسائق والمطعم والمدير خرائطها. تقرؤه التطبيقات من الخادم، فاستبداله هنا لا يتطلب إصداراً جديداً. يُرفض الرمز السري («sk.»): فهذا الرمز يُسلَّم إلى كل التطبيقات. المفاتيح التي يقيس بها الخادم المسافات عبر الطرق ليست هنا: إنها أسرار محفوظة في ملف .env على الخادم.';

  @override
  String get settingLocalTimezoneName => 'المنطقة الزمنية';

  @override
  String get settingLocalTimezoneRole => 'لساعات عمل المطاعم';

  @override
  String get settingLocalTimezoneHelp => 'تُدخل المطاعم ساعات عملها بالتوقيت المحلي، مثلاً من 11:00 إلى 23:00. هذه هي المنطقة الزمنية التي تُقرأ بها تلك الساعات حين تقرر المنصة إن كان المطعم مفتوحاً. استعمل اسماً معيارياً مثل «Africa/Algiers»، وما عداه يُرفض.';

  @override
  String get settingBestSellerCountName => 'الأكثر مبيعاً لكل مطعم';

  @override
  String get settingBestSellerCountRole => 'كم طبقاً يحصل على الشارة';

  @override
  String get settingBestSellerCountHelp => 'في تطبيق العميل، تحمل أكثر أطباق المطعم طلباً شارة «الأكثر مبيعاً». هذا هو عدد أطباقه التي تحصل عليها: تلك الموجودة في أكثر الطلبات المسلَّمة. ضع 0 لعدم عرض أي شارة.';

  @override
  String get settingBestSellerDaysName => 'فترة الأكثر مبيعاً (أيام)';

  @override
  String get settingBestSellerDaysRole => 'الأيام التي تحسبها الشارة';

  @override
  String get settingBestSellerDaysHelp => 'لا تُحسب للشارة إلا الطلبات المسلَّمة خلال هذا العدد من الأيام الماضية، فتتبع ما يطلبه العملاء الآن. مثلاً، 30 تعني آخر شهر من الطلبات المسلَّمة.';

  @override
  String get settingBestSellerMinOrdersName => 'الطلبات اللازمة لشارة الأكثر مبيعاً';

  @override
  String get settingBestSellerMinOrdersRole => 'أقل ما يحتاجه الطبق للشارة';

  @override
  String get settingBestSellerMinOrdersHelp => 'لا يحصل الطبق على الشارة إلا إذا ورد في هذا العدد على الأقل من الطلبات المسلَّمة خلال تلك الفترة. فلا يُظهر مطعم جديد قليل الطلبات أي شارة حتى تبلغ أطباقه هذا العدد.';

  @override
  String get settingLoyaltyEnabledName => 'نقاط الولاء';

  @override
  String get settingLoyaltyEnabledRole => 'مفعّلة أو لا';

  @override
  String get settingLoyaltyEnabledHelp => 'إذا كانت القيمة true، يكسب العملاء نقاطاً على كل طلب مسلَّم ويمكنهم صرفها في قسائم خصم. وإذا كانت false، فلا تُكسب نقاط ولا تُصرف، وتبقى الأرصدة المكتسبة محفوظة. يوقف ذلك برنامج الولاء مؤقتاً دون فقدان شيء.';

  @override
  String get settingLoyaltyEarnRateName => 'النقاط المكتسبة لكل دينار';

  @override
  String get settingLoyaltyEarnRateRole => 'ما يكسبه الطلب';

  @override
  String get settingLoyaltyEarnRateHelp => 'نقاط الولاء التي يحصل عليها العميل عن كل دينار يدفعه في طلب مسلَّم (مجموعه، مع التوصيل، بعد الخصومات). مثلاً، 0.1 تعني أن طلباً بقيمة 1000 دج يكسب 100 نقطة. المعدل الأعلى يجعل البرنامج أسخى، والأقل يكلّف المنصة أقل.';

  @override
  String get settingLoyaltyRedeemRateName => 'الدنانير لكل نقطة مصروفة';

  @override
  String get settingLoyaltyRedeemRateRole => 'قيمة النقطة';

  @override
  String get settingLoyaltyRedeemRateHelp => 'قيمة نقطة الولاء حين يصرفها العميل في قسيمة. مثلاً، 0.5 تعني أن 200 نقطة تصنع قسيمة بقيمة 100 دج. تحدد التكلفة الحقيقية للبرنامج: القيمة الأقل تحمي الهوامش، والأعلى تشجع العملاء أكثر على صرف نقاطهم.';

  @override
  String get settingLoyaltyMinRedeemPointsName => 'أقل عدد من النقاط للصرف';

  @override
  String get settingLoyaltyMinRedeemPointsRole => 'أقل ما يصرفه العميل دفعة واحدة';

  @override
  String get settingLoyaltyMinRedeemPointsHelp => 'لا يمكن للعميل صرف نقاط أقل من هذا العدد دفعة واحدة. يمنع هذا الحد الأدنى (مثلاً 100 نقطة) القسائم الصغيرة جداً ويترك العملاء يجمعون رصيداً حقيقياً أولاً.';

  @override
  String get settingLoyaltyTiersName => 'شرائح الاستبدال';

  @override
  String get settingLoyaltyTiersRole => 'مقادير النقاط التي يمكن للعميل صرفها';

  @override
  String get settingLoyaltyTiersHelp => 'مقادير النقاط الدقيقة التي يمكن للعميل صرفها دفعة واحدة، على شكل قائمة JSON من أعداد صحيحة، مثلاً [100, 500, 1000, 2000]. لا يعرض تطبيق العميل إلا هذه المقادير. يجب ألا يقل كل منها عن أقل عدد من النقاط للصرف.';

  @override
  String get settingMaxCouponsPerCategoryName => 'القسائم من النوع نفسه في الطلب';

  @override
  String get settingMaxCouponsPerCategoryRole => 'جمع قسائم من النوع نفسه';

  @override
  String get settingMaxCouponsPerCategoryHelp => 'أكبر عدد من القسائم من النوع نفسه (مطعم، توصيل أو عامة) يمكن أن يستعمله طلب واحد. مع 1، لا يمكن للعميل وضع قسيمتي مطعم على طلب واحد. تُحسب قسائم الولاء قسائمَ مطعم. ارفعه للسماح بجمع قسائم من النوع نفسه.';

  @override
  String get settingMaxCouponCategoriesName => 'أنواع القسائم في الطلب';

  @override
  String get settingMaxCouponCategoriesRole => 'الجمع بين أنواع مختلفة من القسائم';

  @override
  String get settingMaxCouponCategoriesHelp => 'أكبر عدد من أنواع القسائم المختلفة (مطعم، توصيل، عامة) يمكن أن يستعملها طلب واحد معاً. مثلاً، 2 تعني أن الطلب يمكن أن يجمع نوعين على الأكثر، كقسيمة مطعم وقسيمة توصيل. ومع 3 يمكن استعمال الأنواع الثلاثة معاً.';

  @override
  String confirmPaymentReceived(String amount, String payer) {
    return 'هل استلمت $amount من $payer؟';
  }

  @override
  String get paymentRecordedNotice => 'تم تسجيل الدفعة';

  @override
  String get refusedAt => 'تم الرفض في';

  @override
  String get paymentWaitingForAnswer => 'دفعة أرسلوها من تطبيقهم تنتظر ردك في سجل المعاملات: لم تُحتسب بعد.';

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
  String get refusePaymentTitle => 'رفض هذه الدفعة؟';

  @override
  String get refusePaymentReasonHint => 'لماذا؟ (مثلاً: لم يتم الاستلام)';

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
  String get netBalance => 'الرصيد الصافي';

  @override
  String get paidTowardsOrders => 'المدفوع من هذه الطلبات';

  @override
  String get cashPaidInTheseDays => 'النقود المدفوعة في هذه الأيام';

  @override
  String get cashReceivedInTheseDays => 'النقود المستلمة في هذه الأيام';

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
  String get deliveryAreasHelp => 'لا يمكن للزبائن الطلب إلا من عنوان يقع داخل منطقة مفعّلة.';

  @override
  String get noDeliveryAreasYet => 'لا توجد منطقة توصيل بعد: لا يمكن لأي زبون الطلب.';

  @override
  String get addDeliveryArea => 'إضافة منطقة توصيل';

  @override
  String get editDeliveryArea => 'تعديل منطقة التوصيل';

  @override
  String get deliveryAreaOn => 'مفعّلة: يمكن للزبائن الطلب فيها';

  @override
  String get deliveryAreaOff => 'معطّلة: لا يمكن لأي زبون الطلب فيها';

  @override
  String get deleteDeliveryArea => 'حذف منطقة التوصيل';

  @override
  String deleteDeliveryAreaConfirmation(String name) {
    return 'حذف $name؟ لن يتمكن الزبائن في هذه المنطقة من الطلب بعد الآن.';
  }

  @override
  String get coordinatesInvalid => 'خط العرض من -90 إلى 90، وخط الطول من -180 إلى 180';

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
}
