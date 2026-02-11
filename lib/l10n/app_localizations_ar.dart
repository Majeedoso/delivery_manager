// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'سائق التوصيل';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get name => 'الاسم';

  @override
  String get phone => 'الهاتف';

  @override
  String get rememberMe => 'تذكرني';

  @override
  String get forgotPassword => 'نسيت كلمة المرور';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟ ';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟ ';

  @override
  String get signInWithGoogle => 'تسجيل الدخول باستخدام جوجل';

  @override
  String get signUpWithGoogle => 'إنشاء حساب باستخدام جوجل';

  @override
  String get signUpWithEmail => 'إنشاء حساب بالبريد الإلكتروني';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get checkingAuthentication => 'جاري فحص المصادقة...';

  @override
  String get welcome => 'مرحباً';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get clearSavedCredentials => 'مسح بيانات الاعتماد المحفوظة';

  @override
  String get language => 'اللغة';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String get french => 'الفرنسية';

  @override
  String get or => 'أو';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get profileInformation => 'معلومات الملف الشخصي';

  @override
  String get userType => 'نوع المستخدم';

  @override
  String get settings => 'الإعدادات';

  @override
  String get appSettings => 'إعدادات التطبيق';

  @override
  String get deliveryPreferences => '??????? ???????';

  @override
  String get deliveryPreferencesDescription => '???? ??????? ???? ???? ??????? ???';

  @override
  String get mutualSelected => 'Mutual';

  @override
  String get pendingSelected => 'Pending';

  @override
  String get selectAllRestaurants => '????? ?? ???????';

  @override
  String get noSelectionAllRestaurantsHint => '??? ????? ??? ?????? ???? ??????? ?? ???? ???????.';

  @override
  String selectedRestaurantsCount(int count, int total) {
    return '$count ?? $total ?????';
  }

  @override
  String updatingSelections(int done, int total) {
    return '???? ????? ??????? $done/$total...';
  }

  @override
  String get linkedRestaurants => '??????? ????????';

  @override
  String get addRestaurantByCode => '????? ???? ??????';

  @override
  String get restaurantCode => '??? ??????';

  @override
  String get enterRestaurantCode => '???? ??? ??????';

  @override
  String get linkRestaurant => '???';

  @override
  String get linkRestaurantSuccess => '?? ????? ?????';

  @override
  String get unlinkRestaurant => '?? ????? ????? ?????';

  @override
  String get noLinkedRestaurants => '?? ???? ????? ?????? ???';

  @override
  String get noLinkedRestaurantsDescription => '??? ??? ???? ????? ?? ??????? ?????? ?????.';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get pushNotifications => 'الإشعارات الفورية';

  @override
  String get pushNotificationsDescription => 'تلقي الإشعارات الفورية';

  @override
  String get emailNotifications => 'إشعارات البريد الإلكتروني';

  @override
  String get emailNotificationsDescription => 'تلقي إشعارات البريد الإلكتروني';

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
  String get aboutDescription => 'هذا التطبيق مصمم لسائقي التوصيل لإدارة عمليات التوصيل بكفاءة. يمكن للسائقين عرض الطلبات المتاحة وقبول طلبات التوصيل والتنقل إلى مواقع الاستلام والتسليم وتحديث حالة التوصيل في الوقت الفعلي وتحديد جدول التوفر الخاص بهم وتتبع أرباحهم.';

  @override
  String get features => 'الميزات';

  @override
  String get userAuthentication => 'مصادقة المستخدم';

  @override
  String get userAuthenticationDescription => 'نظام تسجيل دخول وإنشاء حساب آمن';

  @override
  String get multiLanguageSupport => 'دعم متعدد اللغات';

  @override
  String get multiLanguageSupportDescription => 'دعم للغات متعددة';

  @override
  String get secureStorage => 'التخزين الآمن';

  @override
  String get secureStorageDescription => 'تخزين آمن للبيانات الحساسة';

  @override
  String get googleSignIn => 'تسجيل الدخول بجوجل';

  @override
  String get googleSignInDescription => 'تسجيل دخول سريع بحساب جوجل';

  @override
  String get contactUs => 'اتصل بنا';

  @override
  String get copyright => '© 2024 سائق التوصيل. جميع الحقوق محفوظة.';

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
  String get pendingOrders => 'الطلبات المعلقة';

  @override
  String get pendingOrdersDescription => 'إدارة الطلبات في انتظار التحقق';

  @override
  String get acceptOrder => 'قبول الطلب';

  @override
  String get orderAcceptedSuccessfully => 'تم قبول الطلب بنجاح!';

  @override
  String get noOrdersAvailable => 'لا توجد طلبات متاحة';

  @override
  String get checkBackLater => 'عد لاحقاً للطلبات الجديدة';

  @override
  String get refresh => 'تحديث';

  @override
  String get noDeliveryAddress => 'لا يوجد عنوان توصيل';

  @override
  String get items => 'عناصر';

  @override
  String get total => 'الإجمالي';

  @override
  String get deliveryFee => 'رسوم التوصيل';

  @override
  String get cash => 'نقداً';

  @override
  String get card => 'بطاقة';

  @override
  String get confirmed => 'مؤكد';

  @override
  String get readyForPickup => 'جاهز للاستلام';

  @override
  String get showMore => 'عرض المزيد';

  @override
  String get showLess => 'عرض أقل';

  @override
  String get paymentMethod => 'الدفع';

  @override
  String get deliveryNotes => 'ملاحظات';

  @override
  String get ongoingOrders => 'الطلبات الجارية';

  @override
  String get ongoingOrdersDescription => 'إدارة التوصيلات النشطة';

  @override
  String get archiveOrders => 'أرشيف الطلبات';

  @override
  String get archiveOrdersDescription => 'عرض الطلبات المقبولة والمرفوضة';

  @override
  String get statistics => 'الإحصائيات';

  @override
  String get statisticsDescription => 'عرض مقاييس الأداء الخاصة بك';

  @override
  String get statisticsMoney => 'المال';

  @override
  String get statisticsOrders => 'الطلبات';

  @override
  String get ordersPlaced => 'تم الطلب';

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
  String get orders => 'الطلبات';

  @override
  String get archive => 'الأرشيف';

  @override
  String get ordersArchive => 'أرشيف الطلبات';

  @override
  String get acceptedOrders => 'الطلبات المقبولة';

  @override
  String get rejectedOrders => 'الطلبات المرفوضة';

  @override
  String get deliveredOrders => 'الطلبات المسلمة';

  @override
  String get canceledOrders => 'الطلبات الملغاة';

  @override
  String get delivered => 'تم التوصيل';

  @override
  String get cancelled => 'ملغي';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get resetYourPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get enterEmailDescription => 'أدخل عنوان بريدك الإلكتروني وسنرسل لك رمز OTP لإعادة تعيين كلمة المرور.';

  @override
  String get emailAddress => 'عنوان البريد الإلكتروني';

  @override
  String get sendResetLink => 'إرسال رابط إعادة التعيين';

  @override
  String get sendOtp => 'إرسال OTP';

  @override
  String get backToLogin => 'العودة لتسجيل الدخول';

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
  String get verificationEmailSent => 'تم إرسال بريد التحقق بنجاح. يرجى التحقق من صندوق الوارد.';

  @override
  String get checking => 'جاري الفحص...';

  @override
  String get checkStatus => 'فحص الحالة';

  @override
  String get checkStatusDescription => 'اضغط على \"فحص الحالة\" لمعرفة ما إذا تمت الموافقة على حسابك';

  @override
  String get notificationsRequired => 'الإشعارات مطلوبة لهذا التطبيق';

  @override
  String get notificationsRequiredDescription => 'يتطلب هذا التطبيق إذن الإشعارات لتلقي تنبيهات الطلبات الجديدة.';

  @override
  String get enableNotifications => 'تفعيل الإشعارات';

  @override
  String get openSettings => '??? ?????????';

  @override
  String get exitApp => 'إغلاق التطبيق';

  @override
  String get initializing => 'جاري التهيئة...';

  @override
  String get checkingNotifications => 'جاري فحص الإشعارات...';

  @override
  String get settingUpNotifications => 'جاري إعداد الإشعارات...';

  @override
  String get initializationFailed => 'فشل في التهيئة';

  @override
  String get requestingPermission => 'جاري طلب الإذن...';

  @override
  String get permissionRequestFailed => 'فشل في طلب الإذن';

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
  String get week => 'أسبوع';

  @override
  String get month => 'شهر';

  @override
  String get year => 'سنة';

  @override
  String get dateRange => 'نطاق تاريخ';

  @override
  String get selectPeriod => 'اختر الفترة';

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
  String get averageRespondingTime => 'متوسط وقت الاستجابة';

  @override
  String get acceptedOrdersSuccessRate => 'معدل القرارات الجيدة';

  @override
  String get acceptedOrdersSuccessRateExplanation => 'يقيس عدد الطلبات المقبولة التي تم تسليمها بنجاح. هذا مقياس إيجابي يركز على النجاحات.';

  @override
  String get acceptedOrdersSuccessRateGood => 'معدل نجاح عالي يعني أنك تقبل طلبات يمكنك تنفيذها بشكل موثوق.';

  @override
  String get acceptedOrdersSuccessRateBad => 'معدل نجاح منخفض يشير إلى مشاكل في تنفيذ الطلبات - راجع قدرتك.';

  @override
  String get acceptedOrdersFailureRate => 'معدل القرارات السيئة';

  @override
  String get acceptedOrdersFailureRateExplanation => 'يقيس عدد الطلبات المقبولة التي فشلت لأي سبب (ملغاة، مسترجعة، رفضها العميل، لم يتم تسليمها). هذا مقياس سلبي يركز على الفشل.';

  @override
  String get acceptedOrdersFailureRateGood => 'معدل فشل منخفض يظهر معالجة موثوقة للطلبات.';

  @override
  String get acceptedOrdersFailureRateBad => 'معدل فشل عالي يضر بالسمعة - فكر لماذا تفشل الطلبات.';

  @override
  String get averageRespondingTimeExplanation => 'يقيس متوسط الوقت الذي يستغرقه المشغل للرد على الطلب (قبول أو رفض) بعد إنشائه.';

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
  String get orderBreakdown => 'تفصيل الطلبات';

  @override
  String get all => 'الكل';

  @override
  String get second => 'ثانية';

  @override
  String get seconds => 'ثواني';

  @override
  String get minute => 'دقيقة';

  @override
  String get minutes => 'دقائق';

  @override
  String get hour => 'ساعة';

  @override
  String get hours => 'ساعات';

  @override
  String get days => 'أيام';

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
  String get errorLoadingOrders => 'خطأ في تحميل الطلبات';

  @override
  String get order => 'طلب';

  @override
  String get customer => 'عميل';

  @override
  String get restaurant => 'مطعم';

  @override
  String get description => 'الوصف';

  @override
  String get address => 'العنوان';

  @override
  String get isOpen => 'مفتوح';

  @override
  String get restaurantAndNotes => 'المطعم والملاحظات';

  @override
  String get notes => 'ملاحظات';

  @override
  String get rejectionReason => 'السبب';

  @override
  String get deliveryInstructions => 'تعليمات التسليم';

  @override
  String get confirm => 'تأكيد';

  @override
  String get reject => 'رفض';

  @override
  String get startPreparing => 'بدء التحضير';

  @override
  String get markReady => 'تمييز جاهز';

  @override
  String get pickedUp => 'تم الاستلام';

  @override
  String get markDelivered => 'تمييز تم التسليم';

  @override
  String get loadMore => 'تحميل المزيد';

  @override
  String get noPendingOrders => 'لا توجد طلبات معلقة';

  @override
  String get noPendingOrdersDescription => 'لا توجد طلبات معلقة في هذا النطاق الزمني.';

  @override
  String get noOngoingOrders => 'لا توجد طلبات قيد التنفيذ';

  @override
  String get noOngoingOrdersDescription => 'لا توجد طلبات قيد التنفيذ في هذا النطاق الزمني.';

  @override
  String get selectDeliveryMethod => 'اختر طريقة التوصيل';

  @override
  String get selfDelivery => 'توصيل ذاتي';

  @override
  String get externalDelivery => 'توصيل خارجي';

  @override
  String get selfDeliveryDescription => 'سيقوم المطعم بتوصيل الطلب باستخدام سائقه الخاص';

  @override
  String get externalDeliveryDescription => 'سيتم استلام الطلب من قبل سائقي التوصيل الخارجيين';

  @override
  String get pleaseSelectDeliveryMethod => 'يرجى اختيار طريقة التوصيل قبل تحديد الطلب كجاهز';

  @override
  String get drivers => 'السائقون';

  @override
  String get addDriver => 'إضافة سائق';

  @override
  String get editDriver => 'تعديل سائق';

  @override
  String get deleteDriver => 'حذف سائق';

  @override
  String get driverCode => 'رمز السائق';

  @override
  String get driverCodeRequired => 'رمز السائق مطلوب';

  @override
  String get noDriversAdded => 'لم يتم إضافة سائقين بعد';

  @override
  String get pleaseAddDriverBeforeSelfDelivery => 'يرجى إضافة سائق في ملفك الشخصي قبل اختيار التوصيل الذاتي.';

  @override
  String get selectDriversForDelivery => 'اختر السائقين للتوصيل';

  @override
  String get selectAllDrivers => 'اختر جميع السائقين';

  @override
  String get selectSpecificDrivers => 'اختر سائقين محددين';

  @override
  String driverSelected(int count) {
    return '$count سائق محدد';
  }

  @override
  String get driverCodeNotFound => 'لم يتم العثور على رمز السائق. يرجى إدخال رمز سائق صالح.';

  @override
  String get driverAlreadyLinked => 'هذا السائق مرتبط بالفعل بمطعمك.';

  @override
  String get driverLinkedSuccessfully => 'تم ربط السائق بنجاح!';

  @override
  String get requestTimeout => 'انتهت مهلة الطلب';

  @override
  String get requestTimeoutDescription => 'استغرق الطلب وقتاً طويلاً للإكمال. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';

  @override
  String get call => 'اتصال';

  @override
  String get failedToOpenPhoneApp => 'فشل فتح تطبيق الهاتف';

  @override
  String get errorMakingPhoneCall => 'خطأ في إجراء المكالمة';

  @override
  String get ordersLoadedSuccessfully => 'تم تحميل الطلبات بنجاح';

  @override
  String get orderConfirmedSuccessfully => 'تم تأكيد الطلب بنجاح';

  @override
  String get orderRejectedSuccessfully => 'تم رفض الطلب بنجاح';

  @override
  String get confirmOrder => 'تأكيد';

  @override
  String get areYouSureConfirmOrder => 'هل أنت متأكد أنك تريد تأكيد هذا الطلب؟';

  @override
  String get confirmOrderDescription => 'سيؤدي هذا إلى الموافقة على الطلب وجعله مرئياً للمطعم.';

  @override
  String get pleaseSelectRejectReason => 'يرجى اختيار سبب لرفض هذا الطلب:';

  @override
  String get enterYourReason => 'أدخل سببك...';

  @override
  String get rejectReasonDidntPickUp => 'لم يرد على الهاتف';

  @override
  String get rejectReasonSuspiciousBehavior => 'سلوك العميل مشبوه';

  @override
  String get rejectReasonInvalidAddress => 'عنوان التسليم غير صحيح';

  @override
  String get rejectReasonUnrealisticAmount => 'مبلغ الطلب يبدو غير واقعي';

  @override
  String get rejectReasonInvalidContact => 'معلومات الاتصال بالعميل غير صحيحة';

  @override
  String get rejectReasonRestaurantUnavailable => 'المطعم غير متاح';

  @override
  String get other => 'أخرى';

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
  String get appStoreUrlNotConfigured => 'رابط متجر التطبيقات غير مُكوّن. يرجى تحديث التطبيق يدوياً من متجر التطبيقات.';

  @override
  String unableToDetermineAppPackage(String store) {
    return 'تعذر تحديد حزمة التطبيق. يرجى تحديث التطبيق يدوياً من $store.';
  }

  @override
  String unableToOpenStore(String store) {
    return 'تعذر فتح $store. يرجى تحديث التطبيق يدوياً.';
  }

  @override
  String errorOpeningAppStore(String error) {
    return 'خطأ في فتح متجر التطبيقات: $error. يرجى تحديث التطبيق يدوياً.';
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
  String get failedToGetLegalUrls => 'فشل الحصول على روابط المستندات القانونية';

  @override
  String get networkErrorCheckConnection => 'خطأ في الشبكة. يرجى التحقق من اتصالك بالإنترنت.';

  @override
  String get serverErrorOccurred => 'حدث خطأ في الخادم';

  @override
  String get failedToGetContactInformation => 'فشل الحصول على معلومات الاتصال';

  @override
  String unexpectedErrorOccurred(String error) {
    return 'حدث خطأ غير متوقع: $error';
  }

  @override
  String get appStore => 'متجر التطبيقات';

  @override
  String get playStore => 'متجر Google Play';

  @override
  String get urlNotAvailable => 'الرابط غير متاح. يرجى المحاولة مرة أخرى لاحقاً.';

  @override
  String get unableToOpenUrlTryAgain => 'تعذر فتح الرابط. يرجى المحاولة مرة أخرى.';

  @override
  String get unableToOpenUrlCheckConnection => 'تعذر فتح الرابط. يرجى التحقق من اتصالك بالإنترنت.';

  @override
  String get anErrorOccurred => 'حدث خطأ';

  @override
  String get openingHours => 'ساعات العمل';

  @override
  String get closed => 'مغلق';

  @override
  String get monday => 'الاثنين';

  @override
  String get tuesday => 'الثلاثاء';

  @override
  String get wednesday => 'الأربعاء';

  @override
  String get thursday => 'الخميس';

  @override
  String get friday => 'الجمعة';

  @override
  String get saturday => 'السبت';

  @override
  String get sunday => 'الأحد';

  @override
  String get open => 'فتح';

  @override
  String get schedule => 'الجدول الزمني';

  @override
  String get restaurantIsOpen => 'المطعم مفتوح حالياً';

  @override
  String get restaurantIsClosed => 'المطعم مغلق حالياً';

  @override
  String get updateSchedule => 'تحديث الجدول الزمني';

  @override
  String get driverAvailability => 'التوفر';

  @override
  String get driverIsAvailable => 'أنت متاح حاليًا للتوصيل';

  @override
  String get driverIsUnavailable => 'أنت غير متاح حاليًا للتوصيل';

  @override
  String get unsavedChanges => 'تغييرات غير محفوظة';

  @override
  String get unsavedChangesMessage => 'لديك تغييرات غير محفوظة. هل تريد حفظها أم تجاهلها؟';

  @override
  String get save => 'حفظ';

  @override
  String get discard => 'تجاهل';

  @override
  String get selectLocationMethod => 'اختر طريقة تحديد الموقع';

  @override
  String get manualEntry => 'تعديل يدوي';

  @override
  String get fromMap => 'من الخارطة';

  @override
  String get selectLocationOnMap => 'اختر الموقع على الخريطة';

  @override
  String get selectLocation => 'اختيار الموقع';

  @override
  String get locationCoordinates => 'إحداثيات الموقع';

  @override
  String get enterCoordinatesManually => 'أدخل الإحداثيات يدويًا';

  @override
  String get latitude => 'دوائر العرض';

  @override
  String get longitude => 'خطوط الطول';

  @override
  String get latitudeRequired => 'دوائر العرض مطلوبة';

  @override
  String get longitudeRequired => 'خطوط الطول مطلوبة';

  @override
  String get invalidLatitude => 'قيمة دوائر العرض غير صحيحة';

  @override
  String get invalidLongitude => 'قيمة خطوط الطول غير صحيحة';

  @override
  String get latitudeRange => 'يجب أن تكون دوائر العرض بين -90 و 90';

  @override
  String get longitudeRange => 'يجب أن تكون خطوط الطول بين -180 و 180';

  @override
  String get menu => 'القائمة';

  @override
  String get categories => 'الفئات';

  @override
  String get menuItems => 'عناصر القائمة';

  @override
  String get addCategory => 'إضافة فئة';

  @override
  String get editCategory => 'تعديل فئة';

  @override
  String get deleteCategory => 'حذف فئة';

  @override
  String get addMenuItem => 'إضافة عنصر';

  @override
  String get editMenuItem => 'تعديل عنصر';

  @override
  String get deleteMenuItem => 'حذف عنصر';

  @override
  String get categoryName => 'اسم الفئة';

  @override
  String get categoryDescription => 'وصف الفئة';

  @override
  String get itemName => 'اسم العنصر';

  @override
  String get itemDescription => 'وصف العنصر';

  @override
  String get itemPrice => 'السعر';

  @override
  String get preparationTime => 'وقت التحضير';

  @override
  String get ingredients => 'المكونات';

  @override
  String get allergens => 'مسببات الحساسية';

  @override
  String get nutritionalInfo => 'المعلومات الغذائية';

  @override
  String get image => 'الصورة';

  @override
  String get selectImage => 'اختر صورة';

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get chooseFromGallery => 'اختر من المعرض';

  @override
  String get search => 'بحث';

  @override
  String get filter => 'تصفية';

  @override
  String get bulkActions => 'إجراءات مجمعة';

  @override
  String get deleteSelected => 'حذف المحدد';

  @override
  String get toggleAvailability => 'تبديل التوفر';

  @override
  String get reorder => 'إعادة الترتيب';

  @override
  String get dragToReorder => 'اسحب لإعادة الترتيب';

  @override
  String get active => 'نشط';

  @override
  String get inactive => 'غير نشط';

  @override
  String get edit => 'تعديل';

  @override
  String get delete => 'حذف';

  @override
  String get featured => 'مميز';

  @override
  String get available => 'متاح';

  @override
  String get unavailable => 'غير متاح';

  @override
  String get selected => 'محدد';

  @override
  String get makeUnavailable => 'جعل غير متاح';

  @override
  String get makeAvailable => 'جعل متاح';

  @override
  String get remove => 'إزالة';

  @override
  String get removeImage => 'إزالة الصورة';

  @override
  String get areYouSureYouWantToRemoveThisImage => 'هل أنت متأكد أنك تريد إزالة هذه الصورة؟';

  @override
  String get noCategories => 'لا توجد فئات';

  @override
  String get noCategoriesDescription => 'لم تقم بإنشاء أي فئات بعد. اضغط على زر + لإضافة واحدة.';

  @override
  String get noMenuItems => 'لا توجد عناصر في القائمة';

  @override
  String get noMenuItemsDescription => 'لا تحتوي هذه الفئة على أي عناصر بعد. اضغط على زر + لإضافة واحدة.';

  @override
  String get areYouSureDeleteCategory => 'هل أنت متأكد أنك تريد حذف هذه الفئة؟';

  @override
  String get areYouSureDeleteMenuItem => 'هل أنت متأكد أنك تريد حذف عنصر القائمة هذا؟';

  @override
  String areYouSureDeleteSelected(int count) {
    return 'هل أنت متأكد أنك تريد حذف $count عنصر(عناصر) محدد(ة)؟';
  }

  @override
  String categoryHasItems(int count) {
    return 'تحتوي هذه الفئة على $count عنصر(عناصر). يرجى حذف العناصر أو نقلها أولاً.';
  }

  @override
  String get categoryNameRequired => 'اسم الفئة مطلوب';

  @override
  String get itemNameRequired => 'اسم العنصر مطلوب';

  @override
  String get priceRequired => 'السعر مطلوب';

  @override
  String get priceInvalid => 'يجب أن يكون السعر أكبر من 0';

  @override
  String get preparationTimeRequired => 'وقت التحضير مطلوب';

  @override
  String get preparationTimeInvalid => 'يجب أن يكون وقت التحضير دقيقة واحدة على الأقل';

  @override
  String get categoryRequired => 'الفئة مطلوبة';

  @override
  String get addIngredient => 'إضافة مكون';

  @override
  String get addAllergen => 'إضافة مسبب حساسية';

  @override
  String get sortOrder => 'ترتيب الفرز';

  @override
  String get isActive => 'نشط';

  @override
  String get isAvailable => 'متاح';

  @override
  String get isFeatured => 'مميز';

  @override
  String get clearFilters => 'مسح المرشحات';

  @override
  String get sortByName => 'الفرز حسب الاسم';

  @override
  String get sortByPrice => 'الفرز حسب السعر';

  @override
  String get sortByOrder => 'الفرز حسب الترتيب';

  @override
  String get sortAscending => 'تصاعدي';

  @override
  String get sortDescending => 'تنازلي';

  @override
  String get minPrice => 'الحد الأدنى للسعر';

  @override
  String get maxPrice => 'الحد الأقصى للسعر';

  @override
  String get selectCategory => 'اختر الفئة';

  @override
  String get categoryCreatedSuccessfully => 'تم إنشاء الفئة بنجاح';

  @override
  String get categoryUpdatedSuccessfully => 'تم تحديث الفئة بنجاح';

  @override
  String get categoryDeletedSuccessfully => 'تم حذف الفئة بنجاح';

  @override
  String get menuItemCreatedSuccessfully => 'تم إنشاء عنصر القائمة بنجاح';

  @override
  String get menuItemUpdatedSuccessfully => 'تم تحديث عنصر القائمة بنجاح';

  @override
  String get menuItemDeletedSuccessfully => 'تم حذف عنصر القائمة بنجاح';

  @override
  String get menuItemsUpdatedSuccessfully => 'تم تحديث عناصر القائمة بنجاح';

  @override
  String get menuItemsDeletedSuccessfully => 'تم حذف عناصر القائمة بنجاح';

  @override
  String get categoriesReorderedSuccessfully => 'تم إعادة ترتيب الفئات بنجاح';

  @override
  String get menuItemsReorderedSuccessfully => 'تم إعادة ترتيب عناصر القائمة بنجاح';

  @override
  String get bank => 'البنك';

  @override
  String get totalExpected => 'المبلغ المتوقع الإجمالي';

  @override
  String get driverDebts => 'ديون السائقين';

  @override
  String get pendingPayments => 'المدفوعات المعلقة';

  @override
  String get noPendingTransactions => 'لا توجد معاملات معلقة';

  @override
  String get errorLoadingData => 'خطأ في تحميل البيانات';

  @override
  String get noDataAvailable => 'لا توجد بيانات متاحة';

  @override
  String get restaurantSystemManagerDebt => 'دين المطعم لمدير النظام';

  @override
  String get restaurantDebtToSystem => 'دين المطعم للنظام';

  @override
  String get restaurantSystemManagerDebtDescription => 'المبلغ الذي يدين به المطعم لمدير النظام (10% من إجمالي الطلب)';

  @override
  String get amount => 'المبلغ';

  @override
  String get driver => 'سائق';

  @override
  String get expectedFromDrivers => 'المتوقع من السائقين';

  @override
  String get payToSystemAdministrator => 'الدفع لمدير النظام';

  @override
  String get transactions => 'المعاملات';

  @override
  String get bankArchive => 'أرشيف البنك';

  @override
  String get createTransaction => 'إنشاء معاملة';

  @override
  String get paySystem => 'دفع للنظام';

  @override
  String get calculatingAmount => 'جاري حساب المبلغ...';

  @override
  String get amountCalculated => 'تم حساب المبلغ';

  @override
  String get noAmountForRange => 'لا يوجد مبلغ مستحق للفترة المحددة';

  @override
  String get amountFieldReadOnly => 'يتم حساب المبلغ تلقائياً بناءً على الفترة المحددة';

  @override
  String get pendingApprovals => 'الموافقات المعلقة';

  @override
  String get myPendingTransactions => 'معاملاتي المعلقة';

  @override
  String get transactionHistory => 'سجل المعاملات';

  @override
  String get filterByType => 'تصفية حسب النوع';

  @override
  String get filterByDate => 'تصفية حسب التاريخ';

  @override
  String get waitingForApproval => 'في انتظار الموافقة';

  @override
  String get approvedBy => 'تمت الموافقة من قبل';

  @override
  String get rejectedBy => 'تم الرفض من قبل';

  @override
  String get breakdownByDriver => 'التفصيل حسب السائق';

  @override
  String get breakdown => 'التفاصيل';

  @override
  String get transactionType => 'النوع';

  @override
  String get paymentToDriver => 'من السائق';

  @override
  String get paymentToSystem => 'دفع للنظام';

  @override
  String get selectDriver => 'اختر السائق';

  @override
  String get enterAmount => 'أدخل المبلغ';

  @override
  String get submit => 'إرسال';

  @override
  String get approve => 'موافقة';

  @override
  String get date => 'التاريخ';

  @override
  String get status => 'الحالة';

  @override
  String get confirmCancellation => 'تأكيد الإلغاء';

  @override
  String get cancelTransactionConfirmation => 'هل أنت متأكد أنك تريد إلغاء هذه المعاملة؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get no => 'لا';

  @override
  String get yesCancel => 'نعم، إلغاء';

  @override
  String get receivables => 'المستحقات';

  @override
  String get payables => 'المدفوعات';

  @override
  String get receivablesAndPayables => 'المستحقات والمدفوعات';

  @override
  String get newTransaction => 'معاملة جديدة';

  @override
  String get pendingTransactions => 'المعاملات المعلقة';

  @override
  String get transactionsHistory => 'سجل المعاملات';

  @override
  String get ratings => 'التقييمات';

  @override
  String get ratingsTitle => 'تقييمات العملاء';

  @override
  String get ratingsDetailTitle => 'تفاصيل التقييم';

  @override
  String ratingsBasedOn(String count) {
    return 'بناءً على $count تقييم';
  }

  @override
  String get ratingsAnonymous => 'عميل مجهول';

  @override
  String get ratingsResponded => 'تم الرد';

  @override
  String get ratingsReplyNow => 'رد الآن';

  @override
  String get ratingsResponseSuccess => 'تم إرسال الرد بنجاح';

  @override
  String get ratingsOverallRating => 'التقييم العام';

  @override
  String get ratingsDate => 'التاريخ';

  @override
  String get ratingsWouldReorder => 'سيطلب مجدداً';

  @override
  String get ratingsWouldRecommend => 'سيوصي به';

  @override
  String get ratingsDetailedRatings => 'التقييمات التفصيلية';

  @override
  String get ratingsFoodQuality => 'جودة الطعام';

  @override
  String get ratingsDeliverySpeed => 'سرعة التوصيل';

  @override
  String get ratingsDriver => 'السائق';

  @override
  String get ratingsService => 'الخدمة';

  @override
  String get ratingsComments => 'التعليقات';

  @override
  String get ratingsGeneralComment => 'تعليق عام';

  @override
  String get ratingsFoodComment => 'تعليق على الطعام';

  @override
  String get ratingsDeliveryComment => 'تعليق على التوصيل';

  @override
  String get ratingsDriverComment => 'تعليق على السائق';

  @override
  String get ratingsRestaurantComment => 'تعليق على المطعم';

  @override
  String get ratingsTags => 'الوسوم';

  @override
  String get ratingsYourResponse => 'ردك';

  @override
  String get ratingsWriteResponse => 'اكتب رداً';

  @override
  String get ratingsResponseHint => 'اشكر العميل أو عالج ملاحظاته...';

  @override
  String get ratingsResponseRequired => 'الرجاء إدخال رد';

  @override
  String get ratingsResponseMinLength => 'يجب أن يكون الرد 10 أحرف على الأقل';

  @override
  String get ratingsSubmitResponse => 'إرسال الرد';

  @override
  String get ratingsEmptyTitle => 'لا توجد تقييمات بعد';

  @override
  String get ratingsEmptyMessage => 'ستظهر تقييمات العملاء هنا بمجرد استلامها.';

  @override
  String get ratingsLoadMore => 'تحميل المزيد';

  @override
  String get ratingsFilterAll => 'الكل';

  @override
  String get ratingsFilterPositive => 'إيجابية';

  @override
  String get ratingsFilterNegative => 'سلبية';

  @override
  String get orderCounts => 'عدد الطلبات';

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
  String get custom => 'مخصص';

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
  String get statisticsDataFrom => 'بيانات من';

  @override
  String get orderCapacity => 'سعة الطلبات';

  @override
  String canAcceptMoreOrders(int count) {
    return 'يمكنك قبول $count طلب(ات) أخرى';
  }

  @override
  String get maxCapacityReached => 'تم الوصول للحد الأقصى';

  @override
  String get preparing => 'قيد التحضير';

  @override
  String get onDelivery => 'قيد التوصيل';

  @override
  String get noPreparingOrders => 'لا توجد طلبات قيد التحضير';

  @override
  String get noPreparingOrdersDescription => 'ستظهر الطلبات التي تنتظر تحضير الطعام هنا';

  @override
  String get noReadyOrders => 'لا توجد طلبات جاهزة للاستلام';

  @override
  String get noReadyOrdersDescription => 'ستظهر الطلبات الجاهزة للاستلام هنا';

  @override
  String get noDeliveringOrders => 'لا توجد طلبات قيد التوصيل';

  @override
  String get noDeliveringOrdersDescription => 'ستظهر الطلبات التي تقوم بتوصيلها هنا';

  @override
  String get markPickedUp => 'تأكيد الاستلام';

  @override
  String get navigateToRestaurant => 'التوجه للمطعم';

  @override
  String get navigateToCustomer => 'التوجه للعميل';

  @override
  String get rejectOrder => 'رفض الطلب';

  @override
  String get selectRejectionReason => 'اختر سبب الرفض:';

  @override
  String get rejectionReasonTooFar => 'بعيد جداً عن موقعي';

  @override
  String get rejectionReasonLowEarnings => 'أرباح منخفضة لهذا الطلب';

  @override
  String get rejectionReasonBadArea => 'منطقة التوصيل صعبة';

  @override
  String get rejectionReasonBusy => 'مشغول حالياً بتوصيلات أخرى';

  @override
  String get rejectionReasonVehicleIssue => 'مشكلة في المركبة/النقل';

  @override
  String get rejectionReasonPersonal => 'أسباب شخصية';

  @override
  String get rejectionReasonOther => 'أخرى';

  @override
  String get additionalNotes => 'ملاحظات إضافية (اختياري)';

  @override
  String get additionalNotesHint => 'أضف تفاصيل إضافية...';

  @override
  String get confirmRejection => 'رفض';

  @override
  String get orderRejected => 'تم رفض الطلب';

  @override
  String get noRejectedOrders => 'لا توجد طلبات مرفوضة';

  @override
  String get rejectedAt => 'تم الرفض في';

  @override
  String get unassignOrder => 'إلغاء التعيين من الطلب';

  @override
  String get selectUnassignReason => 'لماذا لا يمكنك إكمال هذا الطلب؟';

  @override
  String get unassignReasonVehicleBreakdown => 'عطل في المركبة';

  @override
  String get unassignReasonPersonalEmergency => 'طارئ شخصي';

  @override
  String get unassignReasonSafetyConcern => 'مخاوف أمنية في الموقع';

  @override
  String get unassignReasonCannotReach => 'لا يمكن الوصول إلى موقع الاستلام/التسليم';

  @override
  String get unassignReasonLongWait => 'وقت انتظار طويل في المطعم';

  @override
  String get unassignReasonOrderIssue => 'مشكلة في الطلب (عناصر مفقودة، طلب خاطئ)';

  @override
  String get unassignReasonOther => 'سبب آخر';

  @override
  String get confirmUnassign => 'إلغاء التعيين';

  @override
  String get orderUnassigned => 'تم إلغاء التعيين من الطلب';

  @override
  String get unassignOnDeliveryWarning => 'حالة طارئة فقط! إلغاء التعيين أثناء التوصيل أمر خطير وسيتم مراجعته. استخدم فقط في حالات الطوارئ الحقيقية.';

  @override
  String get unassignReadyWarning => 'الطعام جاهز وفي انتظار. إلغاء التعيين الآن قد يؤثر على جودة الطعام للعميل.';

  @override
  String get unassignEmergencyNotesHint => 'يرجى وصف حالة الطوارئ...';

  @override
  String get unassignConsequenceNotice => 'إلغاء التعيين المتكرر قد يؤثر على مقاييس السائق الخاصة بك. سيعود الطلب إلى مجموعة الطلبات المتاحة.';

  @override
  String get cantCompleteOrder => 'لا يمكن الإكمال';

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
  String get paySystemDebt => 'دفع دين النظام';

  @override
  String get paymentToRestaurant => 'دفع للمطعم';

  @override
  String get noDebts => 'لا توجد ديون مستحقة';

  @override
  String get confirmedAt => 'تم التأكيد في';

  @override
  String get invalidAmount => 'مبلغ غير صالح';

  @override
  String get record => 'تسجيل';

  @override
  String get noTransactionsFound => 'لا توجد معاملات';

  @override
  String get paymentType => 'نوع الدفع';

  @override
  String get selectRestaurant => 'اختر مطعم';

  @override
  String get paymentDate => 'تاريخ الدفع';

  @override
  String get totalCredits => 'Total Credits';

  @override
  String get overpay => 'دفع زائد';

  @override
  String get credit => 'رصيد';

  @override
  String get pickupSpeed => 'سرعة الاستلام';

  @override
  String get pickupSpeedDescription => 'الوقت من جاهزية الطعام إلى الاستلام';

  @override
  String get pickupSpeedGood => 'الاستلام السريع (أقل من 10 دقائق) يضمن طعامًا طازجًا وعملاء سعداء.';

  @override
  String get pickupSpeedBad => 'الاستلام البطيء (أكثر من 20 دقيقة) قد يؤدي إلى طعام بارد وعملاء غير راضين.';

  @override
  String get deliverySpeed => 'سرعة التوصيل';

  @override
  String get deliverySpeedDescription => 'الوقت من الاستلام إلى التوصيل';

  @override
  String get deliverySpeedGood => 'التوصيل السريع (أقل من 20 دقيقة) يؤدي إلى عملاء راضين وتقييمات أفضل.';

  @override
  String get deliverySpeedBad => 'التوصيل البطيء (أكثر من 40 دقيقة) قد يؤدي إلى شكاوى وتقييمات أقل.';

  @override
  String get completionRate => 'معدل الإكمال';

  @override
  String get completionRateDescription => 'نسبة الطلبات المقبولة التي تم توصيلها';

  @override
  String get completionRateGood => 'معدل عالٍ (95%+) يظهر الموثوقية والاحترافية.';

  @override
  String get completionRateBad => 'معدل منخفض (أقل من 85%) يشير إلى مشاكل في معالجة الطلبات.';

  @override
  String get cancellationRate => 'معدل الإلغاء';

  @override
  String get cancellationRateDescription => 'نسبة الطلبات المقبولة التي تم إلغاؤها';

  @override
  String get cancellationRateGood => 'معدل منخفض (أقل من 5%) ممتاز ويظهر خدمة متسقة.';

  @override
  String get cancellationRateBad => 'معدل عالٍ (أكثر من 15%) يثير مخاوف حول الموثوقية.';

  @override
  String get iHaveArrived => 'لقد وصلت';

  @override
  String get arrived => 'وصل';

  @override
  String get driverArrived => 'وصل السائق';

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
  String get accountNotFoundMessage => 'لم يتم العثور على حساب بهذا البريد الإلكتروني. يرجى التسجيل أولاً.';

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
  String get rejectedStatus => 'مرفوض';

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
  String get zone => 'منطقة';

  @override
  String get zones => 'مناطق';

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
}
