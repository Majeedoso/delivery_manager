import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'Manager App'**
  String get appName;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Phone field label
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// Remember me checkbox label
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get rememberMe;

  /// Forgot password screen title
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// Google sign in button text
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// Checking authentication status message
  ///
  /// In en, this message translates to:
  /// **'Checking authentication...'**
  String get checkingAuthentication;

  /// Logout button text
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Language selection label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// OR text between login options
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// Profile screen title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// User type field label
  ///
  /// In en, this message translates to:
  /// **'User Type'**
  String get userType;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// App settings section title
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// Privacy section title
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// Privacy policy link
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Terms of service link
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// App information section title
  ///
  /// In en, this message translates to:
  /// **'App Information'**
  String get appInformation;

  /// App version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Check for updates option
  ///
  /// In en, this message translates to:
  /// **'Check for Updates'**
  String get checkForUpdates;

  /// About app screen title
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// Description of the app shown in about page
  ///
  /// In en, this message translates to:
  /// **'The Manager app gives you complete oversight of the entire delivery platform. Approve users, monitor performance, configure system settings, and manage coupons — all from a powerful admin dashboard.'**
  String get aboutDescription;

  /// Features section title
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// User authentication feature
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get userAuthentication;

  /// User authentication description
  ///
  /// In en, this message translates to:
  /// **'Approve drivers, restaurants, and operators, and manage account suspensions'**
  String get userAuthenticationDescription;

  /// Multi-language support feature
  ///
  /// In en, this message translates to:
  /// **'Analytics & Reports'**
  String get multiLanguageSupport;

  /// Multi-language support description
  ///
  /// In en, this message translates to:
  /// **'Monitor revenue, order trends, and platform performance through detailed dashboards'**
  String get multiLanguageSupportDescription;

  /// Secure storage feature
  ///
  /// In en, this message translates to:
  /// **'System Settings'**
  String get secureStorage;

  /// Secure storage description
  ///
  /// In en, this message translates to:
  /// **'Configure delivery fees, commission rates, and platform-wide operational rules'**
  String get secureStorageDescription;

  /// Google sign-in feature
  ///
  /// In en, this message translates to:
  /// **'Coupons'**
  String get googleSignIn;

  /// Google sign-in description
  ///
  /// In en, this message translates to:
  /// **'Create coupons, set their limits and the zones where they apply'**
  String get googleSignInDescription;

  /// Contact us section title
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// The copyright line, with the current year
  ///
  /// In en, this message translates to:
  /// **'© {year} Manager App. All rights reserved.'**
  String copyright(String year);

  /// Website label
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// Edit profile screen title
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Change password screen title
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// Change email screen title
  ///
  /// In en, this message translates to:
  /// **'Change Email'**
  String get changeEmail;

  /// Update profile button text
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfile;

  /// Main screen title
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get main;

  /// Refresh button text
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Total label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Delivery fee label
  ///
  /// In en, this message translates to:
  /// **'Delivery Fee'**
  String get deliveryFee;

  /// Confirmed status
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// Statistics screen title
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// Statistics money tab title
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get statisticsMoney;

  /// Statistics orders tab title
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get statisticsOrders;

  /// Orders placed count label
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersPlaced;

  /// Orders pending verification count label
  ///
  /// In en, this message translates to:
  /// **'Pending Verification'**
  String get ordersPendingVerification;

  /// Orders accepted by operator count label
  ///
  /// In en, this message translates to:
  /// **'Accepted by Operator'**
  String get ordersAcceptedByOperator;

  /// Orders accepted by restaurant count label
  ///
  /// In en, this message translates to:
  /// **'Accepted by Restaurant'**
  String get ordersAcceptedByRestaurant;

  /// Orders rejected by operator count label
  ///
  /// In en, this message translates to:
  /// **'Rejected by Operator'**
  String get ordersRejectedByOperator;

  /// Orders rejected by restaurant count label
  ///
  /// In en, this message translates to:
  /// **'Rejected by Restaurant'**
  String get ordersRejectedByRestaurant;

  /// Orders accepted by driver count label
  ///
  /// In en, this message translates to:
  /// **'Accepted by Driver'**
  String get ordersAcceptedByDriver;

  /// Orders canceled count label
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get ordersCancelled;

  /// Message when no user data is available
  ///
  /// In en, this message translates to:
  /// **'No user data available'**
  String get noUserDataAvailable;

  /// Default user name when no name is available
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// Delivered orders status label
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// Reset password screen title
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// Reset password form title
  ///
  /// In en, this message translates to:
  /// **'Reset Your Password'**
  String get resetYourPassword;

  /// Description for forgot password form
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you an OTP code to reset your password.'**
  String get enterEmailDescription;

  /// Email address field label
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// Send OTP button text
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// OTP input screen title
  ///
  /// In en, this message translates to:
  /// **'Enter OTP Code'**
  String get enterOtpCode;

  /// OTP input description
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit OTP sent to your email\nIt will be verified automatically when complete'**
  String get enterOtpDescription;

  /// Set new password screen title
  ///
  /// In en, this message translates to:
  /// **'Set New Password'**
  String get setNewPassword;

  /// New password form description
  ///
  /// In en, this message translates to:
  /// **'Enter your new password below'**
  String get enterNewPasswordDescription;

  /// New password field label
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// Confirm new password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmNewPassword;

  /// Resend OTP button text
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// Verify email screen title
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get verifyEmail;

  /// Enter OTP label
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOtp;

  /// OTP sent to email message
  ///
  /// In en, this message translates to:
  /// **'OTP sent to'**
  String get otpSentTo;

  /// Verify OTP button text
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// Confirm email change button text
  ///
  /// In en, this message translates to:
  /// **'Confirm Email Change'**
  String get confirmEmailChange;

  /// Resend countdown text
  ///
  /// In en, this message translates to:
  /// **'You can resend OTP in {seconds}s'**
  String resendIn(int seconds);

  /// Badge text for unverified email
  ///
  /// In en, this message translates to:
  /// **'Email Not Verified'**
  String get emailNotVerified;

  /// Email verification required message
  ///
  /// In en, this message translates to:
  /// **'Please verify your email address before accessing this resource. A verification code (OTP) has been sent to your email address. Please check your inbox and enter the 6-digit code to verify your email.'**
  String get emailVerificationRequired;

  /// Resend verification email button text
  ///
  /// In en, this message translates to:
  /// **'Resend Verification'**
  String get resendVerificationEmail;

  /// Check status button text
  ///
  /// In en, this message translates to:
  /// **'Check Status'**
  String get checkStatus;

  /// Check status description text
  ///
  /// In en, this message translates to:
  /// **'Tap \"Check Status\" to see if your account has been approved'**
  String get checkStatusDescription;

  /// Initialization status message
  ///
  /// In en, this message translates to:
  /// **'Initializing...'**
  String get initializing;

  /// Initialization failed error message
  ///
  /// In en, this message translates to:
  /// **'Initialization failed'**
  String get initializationFailed;

  /// Checking internet connection status message
  ///
  /// In en, this message translates to:
  /// **'Checking internet connection...'**
  String get checkingInternet;

  /// No internet connection error message
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// No internet connection description
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again.'**
  String get noInternetDescription;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Update required screen title
  ///
  /// In en, this message translates to:
  /// **'Update Required'**
  String get updateRequired;

  /// Update required description text
  ///
  /// In en, this message translates to:
  /// **'A new version of the app is available. Please update to continue using the app.'**
  String get updateRequiredDescription;

  /// Minimum required version label
  ///
  /// In en, this message translates to:
  /// **'Minimum Required Version'**
  String get minimumRequiredVersion;

  /// Latest available version label
  ///
  /// In en, this message translates to:
  /// **'Latest Available Version'**
  String get latestAvailableVersion;

  /// Update now button text
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateNow;

  /// Update is required message
  ///
  /// In en, this message translates to:
  /// **'Update is required to continue'**
  String get updateIsRequired;

  /// User's current app version label
  ///
  /// In en, this message translates to:
  /// **'Your Current Version'**
  String get yourCurrentVersion;

  /// Update available message (required)
  ///
  /// In en, this message translates to:
  /// **'An update is available. Please update to continue using the app.'**
  String get updateAvailable;

  /// Optional update available message
  ///
  /// In en, this message translates to:
  /// **'A new version is available. Update to get the latest features.'**
  String get updateAvailableOptional;

  /// App up to date message
  ///
  /// In en, this message translates to:
  /// **'Your app is up to date!'**
  String get appUpToDate;

  /// Account status label
  ///
  /// In en, this message translates to:
  /// **'Account Status'**
  String get accountStatus;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get areYouSureLogout;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Theme setting label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// System payment option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// Email required validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// Email format validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// Password required validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// Password minimum length validation message
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// New email address field label
  ///
  /// In en, this message translates to:
  /// **'New Email Address'**
  String get newEmailAddress;

  /// Current password field label
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// Validation message when new email is same as current email
  ///
  /// In en, this message translates to:
  /// **'New email must be different from current email'**
  String get newEmailMustBeDifferent;

  /// Single day time unit
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get day;

  /// Month period option for period selector
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// Year period option for period selector
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// Date range period option for period selector
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// From label
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// To label
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// Select date placeholder
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// Error message for statistics loading
  ///
  /// In en, this message translates to:
  /// **'Error loading statistics'**
  String get errorLoadingStatistics;

  /// Message when no statistics data is available
  ///
  /// In en, this message translates to:
  /// **'No statistics available'**
  String get noStatisticsAvailable;

  /// Overview section title
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// Label for total count of orders
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get totalOrders;

  /// Accepted label (singular)
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// Pending status label
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Rejected status
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// Performance metrics section title
  ///
  /// In en, this message translates to:
  /// **'Performance Metrics'**
  String get performanceMetrics;

  /// Explanation when success rate is good
  ///
  /// In en, this message translates to:
  /// **'High success rate means you\'re accepting orders you can fulfill reliably.'**
  String get acceptedOrdersSuccessRateGood;

  /// Explanation when success rate is bad
  ///
  /// In en, this message translates to:
  /// **'Low success rate indicates issues with order fulfillment - review your capacity.'**
  String get acceptedOrdersSuccessRateBad;

  /// Explanation when failure rate is good
  ///
  /// In en, this message translates to:
  /// **'Low failure rate shows reliable order handling.'**
  String get acceptedOrdersFailureRateGood;

  /// Explanation when failure rate is bad
  ///
  /// In en, this message translates to:
  /// **'High failure rate damages reputation - consider why orders are failing.'**
  String get acceptedOrdersFailureRateBad;

  /// Explanation when response time is good
  ///
  /// In en, this message translates to:
  /// **'Fast response times lead to better customer satisfaction and higher order acceptance.'**
  String get averageRespondingTimeGood;

  /// Explanation when response time is bad
  ///
  /// In en, this message translates to:
  /// **'Slow response times may result in cancelled orders and unhappy customers.'**
  String get averageRespondingTimeBad;

  /// Label for good performance explanation
  ///
  /// In en, this message translates to:
  /// **'When good'**
  String get whenGood;

  /// Label for bad performance explanation
  ///
  /// In en, this message translates to:
  /// **'When bad'**
  String get whenBad;

  /// Closing time label
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// All period option for period selector
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Single second time unit
  ///
  /// In en, this message translates to:
  /// **'second'**
  String get second;

  /// Plural seconds time unit
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get seconds;

  /// Single minute time unit
  ///
  /// In en, this message translates to:
  /// **'minute'**
  String get minute;

  /// Single hour time unit
  ///
  /// In en, this message translates to:
  /// **'hour'**
  String get hour;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// Network timeout error message
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Please check your internet connection and try again.'**
  String get errorNetworkTimeout;

  /// Connection error message
  ///
  /// In en, this message translates to:
  /// **'Cannot connect to server. Please check your internet connection and ensure the server is running.'**
  String get errorConnectionError;

  /// Request cancelled error message
  ///
  /// In en, this message translates to:
  /// **'Request was cancelled. Please try again.'**
  String get errorRequestCancelled;

  /// Generic network error message
  ///
  /// In en, this message translates to:
  /// **'Network error occurred. Please check your internet connection and try again.'**
  String get errorNetworkGeneric;

  /// Invalid request error (400)
  ///
  /// In en, this message translates to:
  /// **'Invalid request. Please check your input and try again.'**
  String get errorInvalidRequest;

  /// Session expired error (401)
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please login again.'**
  String get errorSessionExpired;

  /// No permission error (403)
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to perform this action.'**
  String get errorNoPermission;

  /// Not found error (404)
  ///
  /// In en, this message translates to:
  /// **'The requested resource was not found.'**
  String get errorNotFound;

  /// Conflict error (409)
  ///
  /// In en, this message translates to:
  /// **'This action conflicts with the current state. Please refresh and try again.'**
  String get errorConflict;

  /// Validation error (422)
  ///
  /// In en, this message translates to:
  /// **'Validation error. Please check your input.'**
  String get errorValidation;

  /// Too many requests error (429)
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait a moment and try again.'**
  String get errorTooManyRequests;

  /// Server unavailable error (5xx)
  ///
  /// In en, this message translates to:
  /// **'Service temporarily unavailable. Please try again later.'**
  String get errorServerUnavailable;

  /// Generic server error
  ///
  /// In en, this message translates to:
  /// **'Server error occurred. Please try again later.'**
  String get errorServerGeneric;

  /// Local database error
  ///
  /// In en, this message translates to:
  /// **'Unable to save data locally. Please try again.'**
  String get errorDatabaseLocal;

  /// Cache load error
  ///
  /// In en, this message translates to:
  /// **'Unable to load cached data. Please refresh.'**
  String get errorCacheLoad;

  /// Authentication failed error
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please check your credentials and try again.'**
  String get errorAuthFailed;

  /// Invalid credentials error
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password. Please check your credentials and try again.'**
  String get errorInvalidCredentials;

  /// Authentication required error
  ///
  /// In en, this message translates to:
  /// **'Authentication required. Please login again.'**
  String get errorAuthRequired;

  /// Sign-in cancelled message
  ///
  /// In en, this message translates to:
  /// **'Sign-in was cancelled.'**
  String get errorSignInCancelled;

  /// Server maintenance message
  ///
  /// In en, this message translates to:
  /// **'Service is temporarily unavailable for maintenance. Please try again later.'**
  String get errorServerMaintenance;

  /// Database server error
  ///
  /// In en, this message translates to:
  /// **'Database error occurred. Please try again later.'**
  String get errorDatabaseServer;

  /// Role name for customer
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// Role name for restaurant
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get restaurant;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Is Open toggle label
  ///
  /// In en, this message translates to:
  /// **'Is Open'**
  String get isOpen;

  /// Notes field label
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// Label for rejection reason
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get rejectionReason;

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Load more button text
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get loadMore;

  /// Drivers section title
  ///
  /// In en, this message translates to:
  /// **'Drivers'**
  String get drivers;

  /// Call button tooltip
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// Current password required validation message
  ///
  /// In en, this message translates to:
  /// **'Current password is required'**
  String get currentPasswordRequired;

  /// New password required validation message
  ///
  /// In en, this message translates to:
  /// **'New password is required'**
  String get newPasswordRequired;

  /// Password minimum length validation message (8 characters)
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength8;

  /// Password complexity validation message
  ///
  /// In en, this message translates to:
  /// **'Password must contain uppercase, lowercase, number, and symbol'**
  String get passwordComplexity;

  /// Confirm new password required validation message
  ///
  /// In en, this message translates to:
  /// **'Please confirm your new password'**
  String get pleaseConfirmNewPassword;

  /// Passwords do not match validation message
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Delete account dialog title and button text
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Delete account confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.\n\nYou will need to verify your identity with an OTP code sent to your email.'**
  String get deleteAccountConfirmation;

  /// Continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Error message when URL cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Error opening URL: {error}'**
  String errorOpeningUrl(String error);

  /// Success message when email is verified
  ///
  /// In en, this message translates to:
  /// **'Email verified successfully'**
  String get emailVerifiedSuccessfully;

  /// Error message when email OTP verification fails
  ///
  /// In en, this message translates to:
  /// **'Failed to verify email OTP'**
  String get failedToVerifyEmailOtp;

  /// Request timeout error message
  ///
  /// In en, this message translates to:
  /// **'Request timeout. Please check your internet connection and try again.'**
  String get requestTimeoutCheckConnection;

  /// Connection error message
  ///
  /// In en, this message translates to:
  /// **'Cannot connect to server. Please check your internet connection.'**
  String get cannotConnectToServer;

  /// Success message when verification OTP is sent
  ///
  /// In en, this message translates to:
  /// **'Verification OTP sent successfully. Please check your email.'**
  String get verificationOtpSentSuccessfully;

  /// Error message when resending verification OTP fails
  ///
  /// In en, this message translates to:
  /// **'Failed to resend verification OTP'**
  String get failedToResendVerificationOtp;

  /// Success message when email change OTP is sent
  ///
  /// In en, this message translates to:
  /// **'Email change OTP sent successfully. Please check your new email.'**
  String get emailChangeOtpSentSuccessfully;

  /// Validation message for OTP input
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 6-digit OTP'**
  String get pleaseEnterValid6DigitOtp;

  /// Message when URL is not available
  ///
  /// In en, this message translates to:
  /// **'URL not available. Please try again later.'**
  String get urlNotAvailable;

  /// Closed status for a day
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// Sunday day name
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// Opening time label
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// Title for unsaved changes dialog
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get unsavedChanges;

  /// Message for unsaved changes dialog
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Do you want to save them or discard them?'**
  String get unsavedChangesMessage;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Discard button text
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// Latitude field label
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// Longitude field label
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// Search hint text
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Status name for active
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Edit button text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Selected label
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// Remove button text
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Is active toggle label
  ///
  /// In en, this message translates to:
  /// **'Is Active'**
  String get isActive;

  /// Clear filters button text
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// Bank feature title
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get bank;

  /// Error message when data fails to load
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// No data available message
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// Amount label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Role name for driver
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driver;

  /// Transactions page title
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// Bank archive page title
  ///
  /// In en, this message translates to:
  /// **'Bank Archive'**
  String get bankArchive;

  /// Approved by label
  ///
  /// In en, this message translates to:
  /// **'Approved by'**
  String get approvedBy;

  /// Transaction type label
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get transactionType;

  /// Select driver label
  ///
  /// In en, this message translates to:
  /// **'Select Driver'**
  String get selectDriver;

  /// Date label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Status label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Tab label for credits (money owed to driver)
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get receivables;

  /// Tab label for debts (money driver owes)
  ///
  /// In en, this message translates to:
  /// **'Debts'**
  String get payables;

  /// Credits and Debts screen title
  ///
  /// In en, this message translates to:
  /// **'Credits and Debts'**
  String get receivablesAndPayables;

  /// New transaction screen title
  ///
  /// In en, this message translates to:
  /// **'New Transaction'**
  String get newTransaction;

  /// Transaction history screen title
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionsHistory;

  /// Section title for performance metrics
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performance;

  /// All time period option
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// Today period option
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// This week period option
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// This month period option
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// This year period option
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get thisYear;

  /// Response speed metric label
  ///
  /// In en, this message translates to:
  /// **'Response Speed'**
  String get responseSpeed;

  /// Description of response speed metric
  ///
  /// In en, this message translates to:
  /// **'Time to accept or reject orders'**
  String get responseSpeedDescription;

  /// Preparation speed metric label
  ///
  /// In en, this message translates to:
  /// **'Preparation Speed'**
  String get preparationSpeed;

  /// Description of preparation speed metric
  ///
  /// In en, this message translates to:
  /// **'Time to prepare accepted orders'**
  String get preparationSpeedDescription;

  /// Decision quality metric label
  ///
  /// In en, this message translates to:
  /// **'Decision Quality'**
  String get decisionQuality;

  /// Description of decision quality metric
  ///
  /// In en, this message translates to:
  /// **'Rate of completed vs accepted orders'**
  String get decisionQualityDescription;

  /// Poor decisions metric label
  ///
  /// In en, this message translates to:
  /// **'Poor Decisions'**
  String get poorDecisions;

  /// Description of poor decisions metric
  ///
  /// In en, this message translates to:
  /// **'Rate of cancelled orders after acceptance'**
  String get poorDecisionsDescription;

  /// Label for total debt amount
  ///
  /// In en, this message translates to:
  /// **'Total Debt'**
  String get totalDebt;

  /// System debt label
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemDebt;

  /// System debt description
  ///
  /// In en, this message translates to:
  /// **'Amount owed to system manager for delivery fees'**
  String get systemDebtDescription;

  /// Restaurant debts section title
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get restaurantDebts;

  /// Restaurants section title
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get restaurantCredits;

  /// Record payment dialog title
  ///
  /// In en, this message translates to:
  /// **'Record Payment'**
  String get recordPayment;

  /// Record system payment dialog title
  ///
  /// In en, this message translates to:
  /// **'Record System Payment'**
  String get recordSystemPayment;

  /// Message when driver has no debts
  ///
  /// In en, this message translates to:
  /// **'No Outstanding Debts'**
  String get noDebts;

  /// Confirmed at label
  ///
  /// In en, this message translates to:
  /// **'Confirmed At'**
  String get confirmedAt;

  /// Invalid amount error message
  ///
  /// In en, this message translates to:
  /// **'Invalid amount'**
  String get invalidAmount;

  /// Message when no transactions are available
  ///
  /// In en, this message translates to:
  /// **'No Transactions Found'**
  String get noTransactionsFound;

  /// Payment type label
  ///
  /// In en, this message translates to:
  /// **'Payment Type'**
  String get paymentType;

  /// Restaurant selection hint
  ///
  /// In en, this message translates to:
  /// **'Select Restaurant'**
  String get selectRestaurant;

  /// Label for payment date selection
  ///
  /// In en, this message translates to:
  /// **'Payment Date'**
  String get paymentDate;

  /// Label for total credits amount
  ///
  /// In en, this message translates to:
  /// **'Total Credits'**
  String get totalCredits;

  /// Label indicating overpayment credit (money paid in excess)
  ///
  /// In en, this message translates to:
  /// **'Overpay'**
  String get overpay;

  /// Time between food ready and driver pickup
  ///
  /// In en, this message translates to:
  /// **'Pickup Speed'**
  String get pickupSpeed;

  /// Description of pickup speed metric
  ///
  /// In en, this message translates to:
  /// **'Time from food ready to pickup'**
  String get pickupSpeedDescription;

  /// Percentage of orders completed successfully
  ///
  /// In en, this message translates to:
  /// **'Completion Rate'**
  String get completionRate;

  /// Percentage of orders cancelled
  ///
  /// In en, this message translates to:
  /// **'Cancellation Rate'**
  String get cancellationRate;

  /// Description of cancellation rate metric
  ///
  /// In en, this message translates to:
  /// **'Percentage of accepted orders that were cancelled'**
  String get cancellationRateDescription;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Understood button text for dialogs
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get understood;

  /// Try again button text
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Title for wrong app error dialog
  ///
  /// In en, this message translates to:
  /// **'Wrong App'**
  String get wrongApp;

  /// Title for account not found error dialog
  ///
  /// In en, this message translates to:
  /// **'Account Not Found'**
  String get accountNotFound;

  /// Message for account not found error
  ///
  /// In en, this message translates to:
  /// **'No manager account uses this email. Manager accounts are created by the platform\'s team, not in the app.'**
  String get accountNotFoundMessage;

  /// Title for login failed error dialog
  ///
  /// In en, this message translates to:
  /// **'Login Failed'**
  String get loginFailed;

  /// Message for invalid credentials error
  ///
  /// In en, this message translates to:
  /// **'The email or password you entered is incorrect. Please check your credentials and try again.'**
  String get invalidCredentialsMessage;

  /// User management screen title
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get userManagement;

  /// Error title when users fail to load
  ///
  /// In en, this message translates to:
  /// **'Error Loading Users'**
  String get errorLoadingUsers;

  /// Empty state title
  ///
  /// In en, this message translates to:
  /// **'No Users Found'**
  String get noUsersFound;

  /// Message when filtered results are empty
  ///
  /// In en, this message translates to:
  /// **'No users match your filters'**
  String get noUsersMatchFilters;

  /// Message when there are no users at all
  ///
  /// In en, this message translates to:
  /// **'No users in the system'**
  String get noUsersInSystem;

  /// Success message after approving user
  ///
  /// In en, this message translates to:
  /// **'User approved successfully'**
  String get userApprovedSuccessfully;

  /// Success message after rejecting user
  ///
  /// In en, this message translates to:
  /// **'User rejected successfully'**
  String get userRejectedSuccessfully;

  /// Success message after suspending user
  ///
  /// In en, this message translates to:
  /// **'User suspended successfully'**
  String get userSuspendedSuccessfully;

  /// Success message after activating user
  ///
  /// In en, this message translates to:
  /// **'User activated successfully'**
  String get userActivatedSuccessfully;

  /// Status dropdown hint
  ///
  /// In en, this message translates to:
  /// **'Change Status'**
  String get changeStatus;

  /// Status name for pending approval
  ///
  /// In en, this message translates to:
  /// **'Pending Approval'**
  String get pendingApproval;

  /// Status name for suspended
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get suspended;

  /// Role name for operator
  ///
  /// In en, this message translates to:
  /// **'Operator'**
  String get operator;

  /// Role name for manager
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get manager;

  /// Filters section title
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// Clear button text
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// All roles filter option
  ///
  /// In en, this message translates to:
  /// **'All Roles'**
  String get allRoles;

  /// All statuses filter option
  ///
  /// In en, this message translates to:
  /// **'All Statuses'**
  String get allStatuses;

  /// Reject user dialog title
  ///
  /// In en, this message translates to:
  /// **'Reject User'**
  String get rejectUser;

  /// Reject user dialog subtitle
  ///
  /// In en, this message translates to:
  /// **'Rejecting: {userName}'**
  String rejectingUser(String userName);

  /// Rejection reason field label
  ///
  /// In en, this message translates to:
  /// **'Rejection Reason *'**
  String get rejectionReasonLabel;

  /// Rejection reason field hint
  ///
  /// In en, this message translates to:
  /// **'Enter reason for rejection...'**
  String get enterRejectionReason;

  /// Helper text for minimum characters
  ///
  /// In en, this message translates to:
  /// **'Minimum 10 characters'**
  String get minimumCharacters;

  /// Validation error for empty rejection reason
  ///
  /// In en, this message translates to:
  /// **'Rejection reason is required'**
  String get rejectionReasonRequired;

  /// Validation error for short rejection reason
  ///
  /// In en, this message translates to:
  /// **'Reason must be at least 10 characters'**
  String get reasonMinimum10Characters;

  /// Suspend user dialog title
  ///
  /// In en, this message translates to:
  /// **'Suspend User'**
  String get suspendUser;

  /// Suspend user dialog subtitle
  ///
  /// In en, this message translates to:
  /// **'Suspending: {userName}'**
  String suspendingUser(String userName);

  /// Suspension reason field label
  ///
  /// In en, this message translates to:
  /// **'Suspension Reason *'**
  String get suspensionReasonLabel;

  /// Suspension reason field hint
  ///
  /// In en, this message translates to:
  /// **'Enter reason for suspension...'**
  String get enterSuspensionReason;

  /// Validation error for empty suspension reason
  ///
  /// In en, this message translates to:
  /// **'Suspension reason is required'**
  String get suspensionReasonRequired;

  /// Search users hint text
  ///
  /// In en, this message translates to:
  /// **'Search by name, email or phone'**
  String get searchUsers;

  /// No description provided for @coupons.
  ///
  /// In en, this message translates to:
  /// **'Coupons'**
  String get coupons;

  /// No description provided for @restaurantCoupons.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Coupons'**
  String get restaurantCoupons;

  /// No description provided for @deliveryCoupons.
  ///
  /// In en, this message translates to:
  /// **'Delivery Coupons'**
  String get deliveryCoupons;

  /// No description provided for @draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draft;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @newDeliveryCoupon.
  ///
  /// In en, this message translates to:
  /// **'New Delivery Coupon'**
  String get newDeliveryCoupon;

  /// No description provided for @newCoupon.
  ///
  /// In en, this message translates to:
  /// **'New Coupon'**
  String get newCoupon;

  /// No description provided for @noDeliveryCouponsYet.
  ///
  /// In en, this message translates to:
  /// **'No delivery coupons yet'**
  String get noDeliveryCouponsYet;

  /// No description provided for @noCouponsYet.
  ///
  /// In en, this message translates to:
  /// **'No coupons yet'**
  String get noCouponsYet;

  /// No description provided for @createFirstDeliveryCoupon.
  ///
  /// In en, this message translates to:
  /// **'Create your first delivery coupon!'**
  String get createFirstDeliveryCoupon;

  /// No description provided for @createFirstCoupon.
  ///
  /// In en, this message translates to:
  /// **'Create your first coupon to attract more customers!'**
  String get createFirstCoupon;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get off;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @valid.
  ///
  /// In en, this message translates to:
  /// **'Valid'**
  String get valid;

  /// No description provided for @uses.
  ///
  /// In en, this message translates to:
  /// **'Uses'**
  String get uses;

  /// No description provided for @minOrder.
  ///
  /// In en, this message translates to:
  /// **'Min Order'**
  String get minOrder;

  /// No description provided for @dzd.
  ///
  /// In en, this message translates to:
  /// **'DZD'**
  String get dzd;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @globalAllRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Global (all restaurants)'**
  String get globalAllRestaurants;

  /// No description provided for @issuer.
  ///
  /// In en, this message translates to:
  /// **'Issuer: '**
  String get issuer;

  /// No description provided for @discardChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard Changes?'**
  String get discardChanges;

  /// No description provided for @editCoupon.
  ///
  /// In en, this message translates to:
  /// **'Edit Coupon'**
  String get editCoupon;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @couponCode.
  ///
  /// In en, this message translates to:
  /// **'Coupon Code'**
  String get couponCode;

  /// No description provided for @couponCodeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. SUMMER20'**
  String get couponCodeHint;

  /// No description provided for @pleaseEnterCouponCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter a coupon code'**
  String get pleaseEnterCouponCode;

  /// No description provided for @codeMinLength.
  ///
  /// In en, this message translates to:
  /// **'Code must be at least 3 characters'**
  String get codeMinLength;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @percentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get percentage;

  /// No description provided for @fixedAmount.
  ///
  /// In en, this message translates to:
  /// **'Fixed Amount'**
  String get fixedAmount;

  /// No description provided for @value.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get value;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @min1.
  ///
  /// In en, this message translates to:
  /// **'Min 1'**
  String get min1;

  /// No description provided for @max100Percent.
  ///
  /// In en, this message translates to:
  /// **'Max 100%'**
  String get max100Percent;

  /// No description provided for @discountAppliesTo.
  ///
  /// In en, this message translates to:
  /// **'Discount Applies To'**
  String get discountAppliesTo;

  /// No description provided for @orderSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Order Subtotal'**
  String get orderSubtotal;

  /// No description provided for @validityPeriod.
  ///
  /// In en, this message translates to:
  /// **'Validity Period'**
  String get validityPeriod;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @restaurantOptional.
  ///
  /// In en, this message translates to:
  /// **'Restaurant (Optional)'**
  String get restaurantOptional;

  /// No description provided for @couponZonesOptional.
  ///
  /// In en, this message translates to:
  /// **'Coupon Zones (Optional)'**
  String get couponZonesOptional;

  /// No description provided for @manageZones.
  ///
  /// In en, this message translates to:
  /// **'Manage Zones'**
  String get manageZones;

  /// No description provided for @usageLimitsOptional.
  ///
  /// In en, this message translates to:
  /// **'Usage Limits (Optional)'**
  String get usageLimitsOptional;

  /// No description provided for @totalUses.
  ///
  /// In en, this message translates to:
  /// **'Total uses'**
  String get totalUses;

  /// No description provided for @perCustomer.
  ///
  /// In en, this message translates to:
  /// **'Per customer'**
  String get perCustomer;

  /// No description provided for @orderConstraintsOptional.
  ///
  /// In en, this message translates to:
  /// **'Order Constraints (Optional)'**
  String get orderConstraintsOptional;

  /// No description provided for @minOrderDzd.
  ///
  /// In en, this message translates to:
  /// **'Min order (DZD)'**
  String get minOrderDzd;

  /// No description provided for @maxDiscountDzd.
  ///
  /// In en, this message translates to:
  /// **'Max discount (DZD)'**
  String get maxDiscountDzd;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionOptional;

  /// No description provided for @internalNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Internal note about this coupon...'**
  String get internalNoteHint;

  /// No description provided for @noCouponZonesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No coupon zones available. Create zones to restrict coupon availability.'**
  String get noCouponZonesAvailable;

  /// No description provided for @selectZonesInfo.
  ///
  /// In en, this message translates to:
  /// **'Select zones (applies to all if none selected)'**
  String get selectZonesInfo;

  /// No description provided for @noRestaurantsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No restaurants available. This coupon will be global.'**
  String get noRestaurantsAvailable;

  /// No description provided for @selectedRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Selected Restaurant'**
  String get selectedRestaurant;

  /// No description provided for @allRestaurantsGlobal.
  ///
  /// In en, this message translates to:
  /// **'All Restaurants (Global)'**
  String get allRestaurantsGlobal;

  /// No description provided for @kmRadius.
  ///
  /// In en, this message translates to:
  /// **'km radius'**
  String get kmRadius;

  /// No description provided for @couponZones.
  ///
  /// In en, this message translates to:
  /// **'Coupon Zones'**
  String get couponZones;

  /// No description provided for @addZone.
  ///
  /// In en, this message translates to:
  /// **'Add Zone'**
  String get addZone;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get success;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Error occurred'**
  String get errorOccurred;

  /// No description provided for @noCouponZonesYet.
  ///
  /// In en, this message translates to:
  /// **'No coupon zones yet'**
  String get noCouponZonesYet;

  /// No description provided for @createZonesToRestrict.
  ///
  /// In en, this message translates to:
  /// **'Create zones to restrict coupons\\nto specific areas'**
  String get createZonesToRestrict;

  /// No description provided for @createZone.
  ///
  /// In en, this message translates to:
  /// **'Create Zone'**
  String get createZone;

  /// No description provided for @editZone.
  ///
  /// In en, this message translates to:
  /// **'Edit Zone'**
  String get editZone;

  /// No description provided for @zoneNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Zone Name *'**
  String get zoneNameRequired;

  /// No description provided for @zoneNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Downtown Area'**
  String get zoneNameHint;

  /// No description provided for @optionalDescription.
  ///
  /// In en, this message translates to:
  /// **'Optional description'**
  String get optionalDescription;

  /// No description provided for @latitudeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 36.7538'**
  String get latitudeHint;

  /// No description provided for @longitudeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 3.0588'**
  String get longitudeHint;

  /// No description provided for @radiusKm.
  ///
  /// In en, this message translates to:
  /// **'Radius (km)'**
  String get radiusKm;

  /// No description provided for @radiusHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 5.0'**
  String get radiusHint;

  /// No description provided for @km.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get km;

  /// No description provided for @zoneNameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Zone name is required'**
  String get zoneNameIsRequired;

  /// No description provided for @deleteZone.
  ///
  /// In en, this message translates to:
  /// **'Delete Zone'**
  String get deleteZone;

  /// No description provided for @deleteZoneConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{zoneName}\"?'**
  String deleteZoneConfirmation(Object zoneName);

  /// Currency abbreviation
  ///
  /// In en, this message translates to:
  /// **'DZD'**
  String get currency;

  /// Revenue overview section header
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get revenueOverview;

  /// Total revenue label
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenue;

  /// Food subtotal label
  ///
  /// In en, this message translates to:
  /// **'Food Subtotal'**
  String get subtotalRevenue;

  /// Delivery fees collected label
  ///
  /// In en, this message translates to:
  /// **'Delivery Fees'**
  String get deliveryFeesCollected;

  /// Platform earnings section header
  ///
  /// In en, this message translates to:
  /// **'Revenues'**
  String get platformEarnings;

  /// Platform revenue label
  ///
  /// In en, this message translates to:
  /// **'Platform Revenue'**
  String get platformRevenue;

  /// Short label for platform revenue card
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get platformShort;

  /// Driver earnings label
  ///
  /// In en, this message translates to:
  /// **'Driver Earnings'**
  String get driverEarnings;

  /// Short label for drivers earnings card
  ///
  /// In en, this message translates to:
  /// **'Drivers'**
  String get driversShort;

  /// Restaurant earnings label
  ///
  /// In en, this message translates to:
  /// **'Restaurant Earnings'**
  String get restaurantEarnings;

  /// Short label for restaurants earnings card
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get restaurantsShort;

  /// No description provided for @totalRevenueDesc.
  ///
  /// In en, this message translates to:
  /// **'Total amount paid by customers for all delivered orders, including food cost and delivery fees.'**
  String get totalRevenueDesc;

  /// No description provided for @subtotalRevenueDesc.
  ///
  /// In en, this message translates to:
  /// **'The food cost total across all delivered orders, excluding delivery fees.'**
  String get subtotalRevenueDesc;

  /// No description provided for @deliveryFeesDesc.
  ///
  /// In en, this message translates to:
  /// **'Total delivery fees charged to customers across all delivered orders.'**
  String get deliveryFeesDesc;

  /// No description provided for @platformRevenueDesc.
  ///
  /// In en, this message translates to:
  /// **'The platform\'s commission: a percentage taken from restaurant food orders and from driver delivery fees.'**
  String get platformRevenueDesc;

  /// No description provided for @driversRevenueDesc.
  ///
  /// In en, this message translates to:
  /// **'What drivers actually keep: delivery fees collected minus the platform\'s commission on deliveries.'**
  String get driversRevenueDesc;

  /// No description provided for @restaurantsRevenueDesc.
  ///
  /// In en, this message translates to:
  /// **'What restaurants actually keep: food order revenue minus the platform\'s commission on food orders.'**
  String get restaurantsRevenueDesc;

  /// No description provided for @restaurantEarningsSection.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get restaurantEarningsSection;

  /// No description provided for @restaurantNetEarnings.
  ///
  /// In en, this message translates to:
  /// **'Net Earnings'**
  String get restaurantNetEarnings;

  /// No description provided for @driverEarningsSection.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get driverEarningsSection;

  /// No description provided for @driverNetEarnings.
  ///
  /// In en, this message translates to:
  /// **'Net Earnings'**
  String get driverNetEarnings;

  /// No description provided for @averageOrderValueDesc.
  ///
  /// In en, this message translates to:
  /// **'The average total amount (food + delivery) per delivered order in the selected period.'**
  String get averageOrderValueDesc;

  /// Order metrics section header
  ///
  /// In en, this message translates to:
  /// **'Order Metrics'**
  String get orderMetrics;

  /// Average order value label
  ///
  /// In en, this message translates to:
  /// **'Average Order Value'**
  String get averageOrderValue;

  /// Statistics ratings tab title
  ///
  /// In en, this message translates to:
  /// **'Ratings'**
  String get statisticsRatings;

  /// Statistics performance tile title
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get statisticsPerformance;

  /// Delivery performance section header
  ///
  /// In en, this message translates to:
  /// **'Delivery Performance'**
  String get deliveryPerformance;

  /// Total deliveries label
  ///
  /// In en, this message translates to:
  /// **'Total Deliveries'**
  String get totalDeliveries;

  /// Completed deliveries label
  ///
  /// In en, this message translates to:
  /// **'Completed Deliveries'**
  String get completedDeliveries;

  /// Cancelled deliveries label
  ///
  /// In en, this message translates to:
  /// **'Cancelled Deliveries'**
  String get cancelledDeliveries;

  /// On-time delivery rate label
  ///
  /// In en, this message translates to:
  /// **'On-Time Rate'**
  String get onTimeRate;

  /// Average delivery time label
  ///
  /// In en, this message translates to:
  /// **'Avg. Delivery Time'**
  String get avgDeliveryTime;

  /// Fastest delivery label
  ///
  /// In en, this message translates to:
  /// **'Fastest Delivery'**
  String get fastestDelivery;

  /// Slowest delivery label
  ///
  /// In en, this message translates to:
  /// **'Slowest Delivery'**
  String get slowestDelivery;

  /// Tooltip for total deliveries card
  ///
  /// In en, this message translates to:
  /// **'The total number of delivery orders in the selected period.'**
  String get totalDeliveriesDesc;

  /// Tooltip for completed deliveries card
  ///
  /// In en, this message translates to:
  /// **'Orders that were successfully delivered to the customer.'**
  String get completedDeliveriesDesc;

  /// Tooltip for cancelled deliveries card
  ///
  /// In en, this message translates to:
  /// **'Orders that were cancelled after being accepted.'**
  String get cancelledDeliveriesDesc;

  /// Tooltip for completion rate card
  ///
  /// In en, this message translates to:
  /// **'Percentage of accepted orders that were successfully delivered.'**
  String get completionRateDesc;

  /// Tooltip for average delivery time card
  ///
  /// In en, this message translates to:
  /// **'Average time in minutes from order pickup to delivery.'**
  String get avgDeliveryTimeDesc;

  /// Tooltip for on-time rate card
  ///
  /// In en, this message translates to:
  /// **'Percentage of deliveries completed within the target time.'**
  String get onTimeRateDesc;

  /// Tooltip for fastest delivery card
  ///
  /// In en, this message translates to:
  /// **'The shortest delivery time recorded in the selected period.'**
  String get fastestDeliveryDesc;

  /// Tooltip for slowest delivery card
  ///
  /// In en, this message translates to:
  /// **'The longest delivery time recorded in the selected period.'**
  String get slowestDeliveryDesc;

  /// Minutes abbreviation
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutesAbbr;

  /// Average rating label
  ///
  /// In en, this message translates to:
  /// **'Average Rating'**
  String get averageRating;

  /// Total ratings count label
  ///
  /// In en, this message translates to:
  /// **'Total Ratings'**
  String get totalRatings;

  /// Rating distribution section header
  ///
  /// In en, this message translates to:
  /// **'Rating Distribution'**
  String get ratingDistribution;

  /// Food quality rating label
  ///
  /// In en, this message translates to:
  /// **'Food Quality'**
  String get foodQualityRating;

  /// Restaurant service rating label
  ///
  /// In en, this message translates to:
  /// **'Restaurant Service'**
  String get restaurantServiceRating;

  /// Delivery speed rating label
  ///
  /// In en, this message translates to:
  /// **'Delivery Speed'**
  String get deliverySpeedRating;

  /// Customer reorder rate label
  ///
  /// In en, this message translates to:
  /// **'Reorder Rate'**
  String get reorderRate;

  /// Customer recommend rate label
  ///
  /// In en, this message translates to:
  /// **'Recommend Rate'**
  String get recommendRate;

  /// Rating out of 5 suffix
  ///
  /// In en, this message translates to:
  /// **'out of 5'**
  String get outOf5;

  /// Restaurants tab label in ratings screen
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get restaurantsTab;

  /// Reviews count suffix
  ///
  /// In en, this message translates to:
  /// **'reviews'**
  String get reviews;

  /// Empty state when no ratings exist
  ///
  /// In en, this message translates to:
  /// **'No ratings yet'**
  String get noRatingsYet;

  /// Drivers tab label in ratings screen
  ///
  /// In en, this message translates to:
  /// **'Drivers'**
  String get driversTab;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @failedToLoadSettings.
  ///
  /// In en, this message translates to:
  /// **'Failed to load settings'**
  String get failedToLoadSettings;

  /// No description provided for @noSettingsFound.
  ///
  /// In en, this message translates to:
  /// **'No settings found'**
  String get noSettingsFound;

  /// No description provided for @noSettingsInThisCategory.
  ///
  /// In en, this message translates to:
  /// **'No settings in this category'**
  String get noSettingsInThisCategory;

  /// No description provided for @settingUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Setting updated successfully'**
  String get settingUpdatedSuccessfully;

  /// No description provided for @emptyInParentheses.
  ///
  /// In en, this message translates to:
  /// **'(empty)'**
  String get emptyInParentheses;

  /// No description provided for @currentValue.
  ///
  /// In en, this message translates to:
  /// **'Current value'**
  String get currentValue;

  /// No description provided for @keyLabel.
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get keyLabel;

  /// No description provided for @editValue.
  ///
  /// In en, this message translates to:
  /// **'Edit value'**
  String get editValue;

  /// No description provided for @newValue.
  ///
  /// In en, this message translates to:
  /// **'New value'**
  String get newValue;

  /// No description provided for @invalidRouteArguments.
  ///
  /// In en, this message translates to:
  /// **'Invalid route arguments'**
  String get invalidRouteArguments;

  /// No description provided for @invalidAppVersionArgument.
  ///
  /// In en, this message translates to:
  /// **'Invalid app version argument'**
  String get invalidAppVersionArgument;

  /// No description provided for @globalCoupons.
  ///
  /// In en, this message translates to:
  /// **'Global Coupons'**
  String get globalCoupons;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Verification Code'**
  String get enterVerificationCode;

  /// No description provided for @weSentVerificationCodeTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification code to {email}'**
  String weSentVerificationCodeTo(Object email);

  /// No description provided for @confirmAccountDeletionCodeMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter the code to confirm account deletion. This action cannot be undone.'**
  String get confirmAccountDeletionCodeMessage;

  /// Fallback error message when app version check fails
  ///
  /// In en, this message translates to:
  /// **'Unable to check for updates. Please try again later.'**
  String get unableToCheckForUpdates;

  /// Detailed account status message shown while account is pending approval
  ///
  /// In en, this message translates to:
  /// **'Your account is pending manager approval. Please wait for a manager to review and approve your account before you can access the system. You will be notified once your account is approved.'**
  String get accountPendingApprovalMessage;

  /// Account status message shown when account is suspended
  ///
  /// In en, this message translates to:
  /// **'Your account has been suspended. Please contact support for assistance.'**
  String get accountSuspendedMessage;

  /// Account status message shown when account is rejected
  ///
  /// In en, this message translates to:
  /// **'Your account has been rejected. Please contact support for more information.'**
  String get accountRejectedMessage;

  /// Under the amount of a debt or credit: the period it covers, e.g. "(Week Balance)"
  ///
  /// In en, this message translates to:
  /// **'({period} Balance)'**
  String balanceForPeriod(String period);

  /// The update button when there is no download for this device (an iPhone without a link) or it can't be opened
  ///
  /// In en, this message translates to:
  /// **'The update can\'t be opened on this device. Please contact us to get the new version.'**
  String get updateLinkUnavailable;

  /// pageNotFound
  ///
  /// In en, this message translates to:
  /// **'Page Not Found'**
  String get pageNotFound;

  /// accountApprovedRedirectingMessage
  ///
  /// In en, this message translates to:
  /// **'Your account has been approved! Redirecting...'**
  String get accountApprovedRedirectingMessage;

  /// accountPendingApproval
  ///
  /// In en, this message translates to:
  /// **'Account Pending Approval'**
  String get accountPendingApproval;

  /// accountPendingApprovalFallbackMessage
  ///
  /// In en, this message translates to:
  /// **'Your account is pending manager approval. Please wait for a manager to review and approve your account before you can access the system.'**
  String get accountPendingApprovalFallbackMessage;

  /// accountRejected
  ///
  /// In en, this message translates to:
  /// **'Account Rejected'**
  String get accountRejected;

  /// accountSuspended
  ///
  /// In en, this message translates to:
  /// **'Account Suspended'**
  String get accountSuspended;

  /// appFailedToInitializeProperly
  ///
  /// In en, this message translates to:
  /// **'The app failed to initialize properly.'**
  String get appFailedToInitializeProperly;

  /// pleaseConfirmYourPassword
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmYourPassword;

  /// nameIsRequired
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameIsRequired;

  /// Edit profile: the name is under 2 characters
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameTooShort;

  /// Edit profile: the phone number is under 10 digits
  ///
  /// In en, this message translates to:
  /// **'Phone number must be at least 10 digits'**
  String get phoneTooShort;

  /// How many times a coupon was used, when it has no limit
  ///
  /// In en, this message translates to:
  /// **'{count} (unlimited)'**
  String usesUnlimited(int count);

  /// What a global coupon's discount applies to: the order's final total
  ///
  /// In en, this message translates to:
  /// **'Final Total (Global)'**
  String get finalTotalGlobal;

  /// How many coupon zones the coupon form has selected
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 zone selected} other{{count} zones selected}}'**
  String zonesSelected(int count);

  /// A group of platform settings on the manager's dashboard
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get settingsCategoryDelivery;

  /// A group of platform settings on the manager's dashboard
  ///
  /// In en, this message translates to:
  /// **'Financials'**
  String get settingsCategoryFinancials;

  /// A group of platform settings on the manager's dashboard
  ///
  /// In en, this message translates to:
  /// **'Customers & Orders'**
  String get settingsCategoryCustomersOrders;

  /// A group of platform settings on the manager's dashboard
  ///
  /// In en, this message translates to:
  /// **'Loyalty & Promotions'**
  String get settingsCategoryLoyaltyPromotions;

  /// A group of platform settings on the manager's dashboard
  ///
  /// In en, this message translates to:
  /// **'Accounts & Security'**
  String get settingsCategoryAccountsSecurity;

  /// A group of platform settings on the manager's dashboard
  ///
  /// In en, this message translates to:
  /// **'API & Integrations'**
  String get settingsCategoryApiIntegrations;

  /// A group of platform settings on the manager's dashboard
  ///
  /// In en, this message translates to:
  /// **'Legal & Contact'**
  String get settingsCategoryLegalContact;

  /// The kind of value a platform setting holds
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get settingTypeText;

  /// The kind of value a platform setting holds
  ///
  /// In en, this message translates to:
  /// **'Whole number'**
  String get settingTypeWhole;

  /// The kind of value a platform setting holds
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get settingTypeNumber;

  /// The kind of value a platform setting holds
  ///
  /// In en, this message translates to:
  /// **'Yes or no'**
  String get settingTypeYesNo;

  /// The kind of value a platform setting holds
  ///
  /// In en, this message translates to:
  /// **'List (JSON)'**
  String get settingTypeList;

  /// The platform setting system_manager_order_percentage: its name
  ///
  /// In en, this message translates to:
  /// **'Commission on orders (%)'**
  String get settingSystemManagerOrderPercentageName;

  /// The platform setting system_manager_order_percentage: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'The platform\'s part of the food subtotal'**
  String get settingSystemManagerOrderPercentageRole;

  /// The platform setting system_manager_order_percentage: its how it works
  ///
  /// In en, this message translates to:
  /// **'The percentage of every order\'s food subtotal that the platform keeps as its commission. For example, 10 means the platform earns 10 DZD for every 100 DZD of food ordered. When an order is delivered, the bank records it as owed by the restaurant to the platform (the driver owes the restaurant the whole food subtotal).'**
  String get settingSystemManagerOrderPercentageHelp;

  /// The platform setting system_manager_delivery_fee_percentage: its name
  ///
  /// In en, this message translates to:
  /// **'Share of the delivery fee (%)'**
  String get settingSystemManagerDeliveryFeePercentageName;

  /// The platform setting system_manager_delivery_fee_percentage: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'The platform\'s part of each delivery fee'**
  String get settingSystemManagerDeliveryFeePercentageRole;

  /// The platform setting system_manager_delivery_fee_percentage: its how it works
  ///
  /// In en, this message translates to:
  /// **'The percentage of the delivery fee that goes to the platform; the driver keeps the rest. For example, with 30 the platform keeps 30% of each delivery fee and the driver 70%. The bank applies it every time an order is delivered.'**
  String get settingSystemManagerDeliveryFeePercentageHelp;

  /// The platform setting contact_email: its name
  ///
  /// In en, this message translates to:
  /// **'Support email'**
  String get settingContactEmailName;

  /// The platform setting contact_email: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'Shown in every app'**
  String get settingContactEmailRole;

  /// The platform setting contact_email: its how it works
  ///
  /// In en, this message translates to:
  /// **'Shown with the other contact details on the Contact and About pages of every app (customer, driver, restaurant, operator). Change it whenever your support address changes, so users always reach the right inbox.'**
  String get settingContactEmailHelp;

  /// The platform setting contact_phone: its name
  ///
  /// In en, this message translates to:
  /// **'Support phone'**
  String get settingContactPhoneName;

  /// The platform setting contact_phone: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'Shown in every app'**
  String get settingContactPhoneRole;

  /// The platform setting contact_phone: its how it works
  ///
  /// In en, this message translates to:
  /// **'Shown on the Contact page of every app. The apps read it from the server, so a change here reaches every app at once, with no new app version.'**
  String get settingContactPhoneHelp;

  /// The platform setting contact_website: its name
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get settingContactWebsiteName;

  /// The platform setting contact_website: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'Shown in every app'**
  String get settingContactWebsiteRole;

  /// The platform setting contact_website: its how it works
  ///
  /// In en, this message translates to:
  /// **'The address of your platform\'s website, shown on the About and Contact pages of every app and opened in the phone\'s browser when tapped.'**
  String get settingContactWebsiteHelp;

  /// The platform setting contact_address: its name
  ///
  /// In en, this message translates to:
  /// **'Postal address'**
  String get settingContactAddressName;

  /// The platform setting contact_address: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'The company\'s address'**
  String get settingContactAddressRole;

  /// The platform setting contact_address: its how it works
  ///
  /// In en, this message translates to:
  /// **'Your company\'s official address. It is printed in the contact part of the Privacy Policy and Terms of Service pages (in every language) and sent to the apps with the other contact details. Leave it empty to hide the address line.'**
  String get settingContactAddressHelp;

  /// The platform setting minimum_delivery_fee: its name
  ///
  /// In en, this message translates to:
  /// **'Minimum delivery fee'**
  String get settingMinimumDeliveryFeeName;

  /// The platform setting minimum_delivery_fee: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'The least a delivery costs'**
  String get settingMinimumDeliveryFeeRole;

  /// The platform setting minimum_delivery_fee: its how it works
  ///
  /// In en, this message translates to:
  /// **'The least a customer is ever charged for delivery, however close the restaurant is. For example, 50 means even a 300-metre order costs 50 DZD for delivery. Set 0 for no minimum: the formula\'s result is used as it is.'**
  String get settingMinimumDeliveryFeeHelp;

  /// The platform setting maximum_delivery_fee: its name
  ///
  /// In en, this message translates to:
  /// **'Maximum delivery fee'**
  String get settingMaximumDeliveryFeeName;

  /// The platform setting maximum_delivery_fee: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'The most a delivery costs'**
  String get settingMaximumDeliveryFeeRole;

  /// The platform setting maximum_delivery_fee: its how it works
  ///
  /// In en, this message translates to:
  /// **'The most a customer can be charged for delivery, however far the restaurant is. For example, 500 means a 20 km order never costs more than 500 DZD for delivery. Set 0 for no maximum: the formula\'s result is used as it is.'**
  String get settingMaximumDeliveryFeeHelp;

  /// The platform setting max_driver_concurrent_orders: its name
  ///
  /// In en, this message translates to:
  /// **'Orders a driver holds at once'**
  String get settingMaxDriverConcurrentOrdersName;

  /// The platform setting max_driver_concurrent_orders: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'The most active orders per driver'**
  String get settingMaxDriverConcurrentOrdersRole;

  /// The platform setting max_driver_concurrent_orders: its how it works
  ///
  /// In en, this message translates to:
  /// **'The most active orders one driver can hold at the same time. Once a driver holds this many, no new order is offered to them until one is delivered or given back. Raise it for busy periods; lower it to keep deliveries short.'**
  String get settingMaxDriverConcurrentOrdersHelp;

  /// The platform setting fixed_delivery_fee: its name
  ///
  /// In en, this message translates to:
  /// **'Fixed delivery fee'**
  String get settingFixedDeliveryFeeName;

  /// The platform setting fixed_delivery_fee: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'The flat part of every delivery fee'**
  String get settingFixedDeliveryFeeRole;

  /// The platform setting fixed_delivery_fee: its how it works
  ///
  /// In en, this message translates to:
  /// **'A flat amount in every delivery fee, whatever the distance: fee = fixed fee + (price per metre × distance in metres), then rounded and kept between the minimum and the maximum. Raising it raises what every customer pays for delivery.'**
  String get settingFixedDeliveryFeeHelp;

  /// The platform setting price_per_meter: its name
  ///
  /// In en, this message translates to:
  /// **'Price per metre'**
  String get settingPricePerMeterName;

  /// The platform setting price_per_meter: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'The distance part of the delivery fee'**
  String get settingPricePerMeterRole;

  /// The platform setting price_per_meter: its how it works
  ///
  /// In en, this message translates to:
  /// **'What each metre of road between the restaurant and the delivery address adds to the fee. For example, 0.02 DZD per metre means a 5 km route adds 100 DZD to the fixed fee. The road distance comes from Mapbox or OpenRouteService.'**
  String get settingPricePerMeterHelp;

  /// The platform setting max_delivery_distance_km: its name
  ///
  /// In en, this message translates to:
  /// **'Maximum delivery distance (km)'**
  String get settingMaxDeliveryDistanceKmName;

  /// The platform setting max_delivery_distance_km: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'How far a delivery can go'**
  String get settingMaxDeliveryDistanceKmRole;

  /// The platform setting max_delivery_distance_km: its how it works
  ///
  /// In en, this message translates to:
  /// **'An order whose delivery address is farther than this many kilometres from the restaurant is refused when it is placed. It spares drivers very long trips and keeps delivery times predictable. Raise or lower it to widen or narrow your service area.'**
  String get settingMaxDeliveryDistanceKmHelp;

  /// The platform setting average_city_speed_kmh: its name
  ///
  /// In en, this message translates to:
  /// **'City speed (km/h)'**
  String get settingAverageCitySpeedKmhName;

  /// The platform setting average_city_speed_kmh: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'For the delivery time when no route is known'**
  String get settingAverageCitySpeedKmhRole;

  /// The platform setting average_city_speed_kmh: its how it works
  ///
  /// In en, this message translates to:
  /// **'When neither Mapbox nor OpenRouteService answers, the distance is measured in a straight line and this speed gives the time the delivery takes through city streets. A usual value is 25 to 40 km/h, for traffic and stops.'**
  String get settingAverageCitySpeedKmhHelp;

  /// The platform setting average_highway_speed_kmh: its name
  ///
  /// In en, this message translates to:
  /// **'Highway speed (km/h)'**
  String get settingAverageHighwaySpeedKmhName;

  /// The platform setting average_highway_speed_kmh: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'For the long part of such a trip'**
  String get settingAverageHighwaySpeedKmhRole;

  /// The platform setting average_highway_speed_kmh: its how it works
  ///
  /// In en, this message translates to:
  /// **'Used with the city speed in that straight-line estimate: beyond the city-to-highway distance, the rest of the trip is counted at this faster speed. A usual value is 80 to 120 km/h.'**
  String get settingAverageHighwaySpeedKmhHelp;

  /// The platform setting city_highway_transition_km: its name
  ///
  /// In en, this message translates to:
  /// **'City-to-highway distance (km)'**
  String get settingCityHighwayTransitionKmName;

  /// The platform setting city_highway_transition_km: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'Where the city speed stops'**
  String get settingCityHighwayTransitionKmRole;

  /// The platform setting city_highway_transition_km: its how it works
  ///
  /// In en, this message translates to:
  /// **'In that straight-line estimate, a trip shorter than this is counted entirely at city speed; the kilometres beyond it at highway speed. For example, 5 means the first 5 km at city speed and the rest at highway speed.'**
  String get settingCityHighwayTransitionKmHelp;

  /// The platform setting currency: its name
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get settingCurrencyName;

  /// The platform setting currency: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'The platform\'s currency code'**
  String get settingCurrencyRole;

  /// The platform setting currency: its how it works
  ///
  /// In en, this message translates to:
  /// **'The ISO 4217 code of the currency of every amount on the platform: order totals, delivery fees, earnings, notifications. For example, \"DZD\" for the Algerian dinar. The server writes it after amounts and sends it to every app.'**
  String get settingCurrencyHelp;

  /// The platform setting birthday_gift_enabled: its name
  ///
  /// In en, this message translates to:
  /// **'Birthday gift'**
  String get settingBirthdayGiftEnabledName;

  /// The platform setting birthday_gift_enabled: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'On or off'**
  String get settingBirthdayGiftEnabledRole;

  /// The platform setting birthday_gift_enabled: its how it works
  ///
  /// In en, this message translates to:
  /// **'When true (or 1), a customer who orders on their birthday gets that order paid for, up to the birthday gift cap, once a year. When false (or 0), there is no birthday gift. It turns the promotion on or off without touching the code.'**
  String get settingBirthdayGiftEnabledHelp;

  /// The platform setting birthday_gift_cap: its name
  ///
  /// In en, this message translates to:
  /// **'Birthday gift cap (DZD)'**
  String get settingBirthdayGiftCapName;

  /// The platform setting birthday_gift_cap: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'The most a birthday gift covers'**
  String get settingBirthdayGiftCapRole;

  /// The platform setting birthday_gift_cap: its how it works
  ///
  /// In en, this message translates to:
  /// **'The most a birthday gift covers, in the platform\'s currency. For example, with a cap of 500, a 700 DZD birthday order is reduced by 500 DZD. It keeps the gift reasonable on large orders.'**
  String get settingBirthdayGiftCapHelp;

  /// The platform setting customer_restaurant_radius_km: its name
  ///
  /// In en, this message translates to:
  /// **'Restaurant search radius (km)'**
  String get settingCustomerRestaurantRadiusKmName;

  /// The platform setting customer_restaurant_radius_km: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'Which restaurants a customer sees'**
  String get settingCustomerRestaurantRadiusKmRole;

  /// The platform setting customer_restaurant_radius_km: its how it works
  ///
  /// In en, this message translates to:
  /// **'A customer is shown the restaurants within this many kilometres of where they are. A larger radius shows more choice, but may include restaurants too far to deliver in good time.'**
  String get settingCustomerRestaurantRadiusKmHelp;

  /// The platform setting customer_restaurant_prefilter_radius_km: its name
  ///
  /// In en, this message translates to:
  /// **'Search pre-filter radius (km)'**
  String get settingCustomerRestaurantPrefilterRadiusKmName;

  /// The platform setting customer_restaurant_prefilter_radius_km: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'A first, quicker sorting of the restaurants'**
  String get settingCustomerRestaurantPrefilterRadiusKmRole;

  /// The platform setting customer_restaurant_prefilter_radius_km: its how it works
  ///
  /// In en, this message translates to:
  /// **'Before the exact distance check, the database keeps only the restaurants within this larger radius, which is quicker. It must be at least the restaurant search radius: smaller, it would leave out nearby restaurants; much larger, it only makes the search slower.'**
  String get settingCustomerRestaurantPrefilterRadiusKmHelp;

  /// The platform setting privacy_policy_url: its name
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy link'**
  String get settingPrivacyPolicyUrlName;

  /// The platform setting privacy_policy_url: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'Shown in every app'**
  String get settingPrivacyPolicyUrlRole;

  /// The platform setting privacy_policy_url: its how it works
  ///
  /// In en, this message translates to:
  /// **'Opened in the phone\'s browser when someone taps \"Privacy Policy\" in any app. Change it here whenever you publish a new version of your policy: no app update is needed.'**
  String get settingPrivacyPolicyUrlHelp;

  /// The platform setting terms_of_service_url: its name
  ///
  /// In en, this message translates to:
  /// **'Terms of Service link'**
  String get settingTermsOfServiceUrlName;

  /// The platform setting terms_of_service_url: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'Shown in every app'**
  String get settingTermsOfServiceUrlRole;

  /// The platform setting terms_of_service_url: its how it works
  ///
  /// In en, this message translates to:
  /// **'Opened in the phone\'s browser when someone taps \"Terms of Service\" in any app. Change it here whenever you revise your terms: no app update is needed.'**
  String get settingTermsOfServiceUrlHelp;

  /// The platform setting min_order_scheduling_minutes: its name
  ///
  /// In en, this message translates to:
  /// **'Scheduling notice (minutes)'**
  String get settingMinOrderSchedulingMinutesName;

  /// The platform setting min_order_scheduling_minutes: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'How far ahead an order is scheduled'**
  String get settingMinOrderSchedulingMinutesRole;

  /// The platform setting min_order_scheduling_minutes: its how it works
  ///
  /// In en, this message translates to:
  /// **'A customer scheduling an order must pick a time at least this many minutes ahead. For example, 30 means no order can be scheduled for the next 30 minutes. It gives restaurants and drivers enough time to get ready.'**
  String get settingMinOrderSchedulingMinutesHelp;

  /// The platform setting number_of_orders_to_be_trusted: its name
  ///
  /// In en, this message translates to:
  /// **'Orders to become trusted'**
  String get settingNumberOfOrdersToBeTrustedName;

  /// The platform setting number_of_orders_to_be_trusted: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'When an operator stops checking a customer\'s orders'**
  String get settingNumberOfOrdersToBeTrustedRole;

  /// The platform setting number_of_orders_to_be_trusted: its how it works
  ///
  /// In en, this message translates to:
  /// **'A new customer\'s orders are checked by an operator before they reach the restaurant. Once a customer has this many delivered orders, they become \"trusted\" and their next orders go straight to the restaurant. Lower it to trust sooner; raise it for more checking.'**
  String get settingNumberOfOrdersToBeTrustedHelp;

  /// The platform setting otp_validity_minutes: its name
  ///
  /// In en, this message translates to:
  /// **'Code validity (minutes)'**
  String get settingOtpValidityMinutesName;

  /// The platform setting otp_validity_minutes: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'How long an emailed code works'**
  String get settingOtpValidityMinutesRole;

  /// The platform setting otp_validity_minutes: its how it works
  ///
  /// In en, this message translates to:
  /// **'Codes are emailed to reset a password, verify or change an email address and confirm an account deletion. A code works for this many minutes after it is sent, and the email says so. Shorter is safer; longer is kinder to slow mailboxes.'**
  String get settingOtpValidityMinutesHelp;

  /// The platform setting otp_resend_wait_seconds: its name
  ///
  /// In en, this message translates to:
  /// **'Wait before a new code (seconds)'**
  String get settingOtpResendWaitSecondsName;

  /// The platform setting otp_resend_wait_seconds: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'Between two emailed codes'**
  String get settingOtpResendWaitSecondsRole;

  /// The platform setting otp_resend_wait_seconds: its how it works
  ///
  /// In en, this message translates to:
  /// **'After a code is emailed, a new one can be asked for only after this many seconds; the apps show the countdown. It limits the emails sent to one address.'**
  String get settingOtpResendWaitSecondsHelp;

  /// The platform setting max_saved_addresses: its name
  ///
  /// In en, this message translates to:
  /// **'Saved addresses per customer'**
  String get settingMaxSavedAddressesName;

  /// The platform setting max_saved_addresses: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'How many addresses a customer keeps'**
  String get settingMaxSavedAddressesRole;

  /// The platform setting max_saved_addresses: its how it works
  ///
  /// In en, this message translates to:
  /// **'The most delivery addresses one customer can keep in the app. One more is refused with a message.'**
  String get settingMaxSavedAddressesHelp;

  /// The platform setting max_items_per_order: its name
  ///
  /// In en, this message translates to:
  /// **'Dishes per order'**
  String get settingMaxItemsPerOrderName;

  /// The platform setting max_items_per_order: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'Different dishes in one order'**
  String get settingMaxItemsPerOrderRole;

  /// The platform setting max_items_per_order: its how it works
  ///
  /// In en, this message translates to:
  /// **'An order with more different dishes than this is refused. It keeps one order to what a kitchen and a driver can handle at once.'**
  String get settingMaxItemsPerOrderHelp;

  /// The platform setting max_quantity_per_item: its name
  ///
  /// In en, this message translates to:
  /// **'Portions per dish'**
  String get settingMaxQuantityPerItemName;

  /// The platform setting max_quantity_per_item: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'Portions of one dish in one order'**
  String get settingMaxQuantityPerItemRole;

  /// The platform setting max_quantity_per_item: its how it works
  ///
  /// In en, this message translates to:
  /// **'The largest quantity of one dish a customer can order. A larger quantity is refused with a message.'**
  String get settingMaxQuantityPerItemHelp;

  /// The platform setting amount_rounding_step: its name
  ///
  /// In en, this message translates to:
  /// **'Rounding step (DZD)'**
  String get settingAmountRoundingStepName;

  /// The platform setting amount_rounding_step: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'Rounding of delivery fees and coupon discounts'**
  String get settingAmountRoundingStepRole;

  /// The platform setting amount_rounding_step: its how it works
  ///
  /// In en, this message translates to:
  /// **'Delivery fees are rounded up, and coupon discounts down, to a multiple of this amount. With 5, a fee of 162 DZD becomes 165 and a discount of 312 DZD becomes 310. Set 1 to stop rounding.'**
  String get settingAmountRoundingStepHelp;

  /// The platform setting loyalty_coupon_validity_days: its name
  ///
  /// In en, this message translates to:
  /// **'Loyalty coupon validity (days)'**
  String get settingLoyaltyCouponValidityDaysName;

  /// The platform setting loyalty_coupon_validity_days: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'How long a loyalty coupon can be used'**
  String get settingLoyaltyCouponValidityDaysRole;

  /// The platform setting loyalty_coupon_validity_days: its how it works
  ///
  /// In en, this message translates to:
  /// **'A coupon obtained with loyalty points can be used for this many days. The customer app shows the number before the points are spent.'**
  String get settingLoyaltyCouponValidityDaysHelp;

  /// The platform setting default_delivery_time_minutes: its name
  ///
  /// In en, this message translates to:
  /// **'Default delivery time (minutes)'**
  String get settingDefaultDeliveryTimeMinutesName;

  /// The platform setting default_delivery_time_minutes: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'When the route is unknown'**
  String get settingDefaultDeliveryTimeMinutesRole;

  /// The platform setting default_delivery_time_minutes: its how it works
  ///
  /// In en, this message translates to:
  /// **'When the road route to a customer can\'t be computed (no position yet, or no routing service), this many minutes is shown and used as the delivery time.'**
  String get settingDefaultDeliveryTimeMinutesHelp;

  /// The platform setting route_cache_minutes: its name
  ///
  /// In en, this message translates to:
  /// **'Road distance kept (minutes)'**
  String get settingRouteCacheMinutesName;

  /// The platform setting route_cache_minutes: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'How long a computed distance is reused'**
  String get settingRouteCacheMinutesRole;

  /// The platform setting route_cache_minutes: its how it works
  ///
  /// In en, this message translates to:
  /// **'The road distance between a restaurant and a delivery spot is kept this many minutes instead of being asked again. The fee charged is then the fee shown, and fewer routing requests are made. Lower it only if roads change very often.'**
  String get settingRouteCacheMinutesHelp;

  /// The platform setting map_default_latitude: its name
  ///
  /// In en, this message translates to:
  /// **'Map centre: latitude'**
  String get settingMapDefaultLatitudeName;

  /// The platform setting map_default_latitude: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'Where the apps\' map opens'**
  String get settingMapDefaultLatitudeRole;

  /// The platform setting map_default_latitude: its how it works
  ///
  /// In en, this message translates to:
  /// **'When someone opens the map to pick a place and no position is known yet, the map opens here. Set it, with the longitude, to the centre of your service area. A value between -90 and 90.'**
  String get settingMapDefaultLatitudeHelp;

  /// The platform setting map_default_longitude: its name
  ///
  /// In en, this message translates to:
  /// **'Map centre: longitude'**
  String get settingMapDefaultLongitudeName;

  /// The platform setting map_default_longitude: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'Where the apps\' map opens'**
  String get settingMapDefaultLongitudeRole;

  /// The platform setting map_default_longitude: its how it works
  ///
  /// In en, this message translates to:
  /// **'The longitude that goes with the map centre\'s latitude: the centre of your service area. A value between -180 and 180.'**
  String get settingMapDefaultLongitudeHelp;

  /// The platform setting app_mapbox_access_token: its name
  ///
  /// In en, this message translates to:
  /// **'Map token (Mapbox)'**
  String get settingAppMapboxAccessTokenName;

  /// The platform setting app_mapbox_access_token: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'Draws the maps in the apps'**
  String get settingAppMapboxAccessTokenRole;

  /// The platform setting app_mapbox_access_token: its how it works
  ///
  /// In en, this message translates to:
  /// **'The Mapbox public token (it starts with \"pk.\") the customer, driver, restaurant and manager apps draw their maps with. The apps read it from the server, so replacing it here needs no new app version. A secret token (\"sk.\") is refused: this one is handed to every app. The keys the server measures road distances with are not here: they are secrets, kept in the server\'s .env file.'**
  String get settingAppMapboxAccessTokenHelp;

  /// The platform setting local_timezone: its name
  ///
  /// In en, this message translates to:
  /// **'Time zone'**
  String get settingLocalTimezoneName;

  /// The platform setting local_timezone: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'Of the restaurants\' opening hours'**
  String get settingLocalTimezoneRole;

  /// The platform setting local_timezone: its how it works
  ///
  /// In en, this message translates to:
  /// **'Restaurants enter their opening hours as local times, for example 11:00 to 23:00. This is the time zone those hours are read in when the platform decides whether a restaurant is open. Use a standard name such as \"Africa/Algiers\"; anything else is refused.'**
  String get settingLocalTimezoneHelp;

  /// The platform setting best_seller_count: its name
  ///
  /// In en, this message translates to:
  /// **'Best sellers per restaurant'**
  String get settingBestSellerCountName;

  /// The platform setting best_seller_count: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'How many dishes get the badge'**
  String get settingBestSellerCountRole;

  /// The platform setting best_seller_count: its how it works
  ///
  /// In en, this message translates to:
  /// **'In the customer app, a restaurant\'s most ordered dishes carry a \"Best seller\" badge. This is how many of its dishes get it: those in the most delivered orders. Set 0 to show no badge.'**
  String get settingBestSellerCountHelp;

  /// The platform setting best_seller_days: its name
  ///
  /// In en, this message translates to:
  /// **'Best seller period (days)'**
  String get settingBestSellerDaysName;

  /// The platform setting best_seller_days: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'The days the badge looks back on'**
  String get settingBestSellerDaysRole;

  /// The platform setting best_seller_days: its how it works
  ///
  /// In en, this message translates to:
  /// **'Only orders delivered within this many past days count for the badge, so it follows what customers order now. For example, 30 means the last month of delivered orders.'**
  String get settingBestSellerDaysHelp;

  /// The platform setting best_seller_min_orders: its name
  ///
  /// In en, this message translates to:
  /// **'Orders to be a best seller'**
  String get settingBestSellerMinOrdersName;

  /// The platform setting best_seller_min_orders: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'The least a dish needs for the badge'**
  String get settingBestSellerMinOrdersRole;

  /// The platform setting best_seller_min_orders: its how it works
  ///
  /// In en, this message translates to:
  /// **'A dish gets the badge only if it was in at least this many delivered orders during that period. A new restaurant with few orders shows no badge until its dishes reach this number.'**
  String get settingBestSellerMinOrdersHelp;

  /// The platform setting loyalty_enabled: its name
  ///
  /// In en, this message translates to:
  /// **'Loyalty points'**
  String get settingLoyaltyEnabledName;

  /// The platform setting loyalty_enabled: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'On or off'**
  String get settingLoyaltyEnabledRole;

  /// The platform setting loyalty_enabled: its how it works
  ///
  /// In en, this message translates to:
  /// **'When true, customers earn points on every delivered order and can spend them on discount coupons. When false, no point is earned and none can be spent; the balances already earned are kept. It pauses the loyalty programme without losing anything.'**
  String get settingLoyaltyEnabledHelp;

  /// The platform setting loyalty_earn_rate: its name
  ///
  /// In en, this message translates to:
  /// **'Points earned per DZD'**
  String get settingLoyaltyEarnRateName;

  /// The platform setting loyalty_earn_rate: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'What an order earns'**
  String get settingLoyaltyEarnRateRole;

  /// The platform setting loyalty_earn_rate: its how it works
  ///
  /// In en, this message translates to:
  /// **'The loyalty points a customer receives for each dinar paid for a delivered order (its total, delivery included, after discounts). For example, 0.1 means a 1000 DZD order earns 100 points. A higher rate makes the programme more rewarding; a lower one costs the platform less.'**
  String get settingLoyaltyEarnRateHelp;

  /// The platform setting loyalty_redeem_rate: its name
  ///
  /// In en, this message translates to:
  /// **'DZD per point spent'**
  String get settingLoyaltyRedeemRateName;

  /// The platform setting loyalty_redeem_rate: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'What a point is worth'**
  String get settingLoyaltyRedeemRateRole;

  /// The platform setting loyalty_redeem_rate: its how it works
  ///
  /// In en, this message translates to:
  /// **'What one loyalty point is worth when a customer spends it on a coupon. For example, 0.5 means 200 points make a 100 DZD coupon. It sets the real cost of the programme: lower protects margins, higher attracts more customers to spend their points.'**
  String get settingLoyaltyRedeemRateHelp;

  /// The platform setting loyalty_min_redeem_points: its name
  ///
  /// In en, this message translates to:
  /// **'Minimum points to spend'**
  String get settingLoyaltyMinRedeemPointsName;

  /// The platform setting loyalty_min_redeem_points: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'The least a customer spends at once'**
  String get settingLoyaltyMinRedeemPointsRole;

  /// The platform setting loyalty_min_redeem_points: its how it works
  ///
  /// In en, this message translates to:
  /// **'A customer can\'t spend fewer points than this at once. A floor (for example 100 points) avoids tiny coupons and lets customers build up a real balance first.'**
  String get settingLoyaltyMinRedeemPointsHelp;

  /// The platform setting loyalty_tiers: its name
  ///
  /// In en, this message translates to:
  /// **'Redemption tiers'**
  String get settingLoyaltyTiersName;

  /// The platform setting loyalty_tiers: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'The point amounts a customer can spend'**
  String get settingLoyaltyTiersRole;

  /// The platform setting loyalty_tiers: its how it works
  ///
  /// In en, this message translates to:
  /// **'The exact point amounts a customer can spend at once, as a JSON list of whole numbers, for example [100, 500, 1000, 2000]. The customer app offers only these. Each should be at least the minimum points to spend.'**
  String get settingLoyaltyTiersHelp;

  /// The platform setting max_coupons_per_category: its name
  ///
  /// In en, this message translates to:
  /// **'Coupons of one kind per order'**
  String get settingMaxCouponsPerCategoryName;

  /// The platform setting max_coupons_per_category: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'Stacking coupons of the same kind'**
  String get settingMaxCouponsPerCategoryRole;

  /// The platform setting max_coupons_per_category: its how it works
  ///
  /// In en, this message translates to:
  /// **'The most coupons of the same kind (restaurant, delivery or global) one order can use. With 1, a customer can\'t put two restaurant coupons on one order. Loyalty coupons count as restaurant coupons. Raise it to let coupons of the same kind be combined.'**
  String get settingMaxCouponsPerCategoryHelp;

  /// The platform setting max_coupon_categories: its name
  ///
  /// In en, this message translates to:
  /// **'Kinds of coupon per order'**
  String get settingMaxCouponCategoriesName;

  /// The platform setting max_coupon_categories: its what it is for, in a line
  ///
  /// In en, this message translates to:
  /// **'Combining different kinds of coupon'**
  String get settingMaxCouponCategoriesRole;

  /// The platform setting max_coupon_categories: its how it works
  ///
  /// In en, this message translates to:
  /// **'The most different kinds of coupon (restaurant, delivery, global) one order can use together. For example, 2 means an order can combine at most two kinds, such as a restaurant coupon and a delivery coupon. With 3, all three can be used together.'**
  String get settingMaxCouponCategoriesHelp;

  /// Question before the manager confirms a payment a driver or a restaurant sent: the amount and who sent it
  ///
  /// In en, this message translates to:
  /// **'Did you receive {amount} from {payer}?'**
  String confirmPaymentReceived(String amount, String payer);

  /// Confirmation once the manager recorded a payment received from a restaurant or a driver (the form starts again)
  ///
  /// In en, this message translates to:
  /// **'Payment recorded'**
  String get paymentRecordedNotice;

  /// Label before the date a payment was refused, as confirmedAt for a confirmed one
  ///
  /// In en, this message translates to:
  /// **'Refused At'**
  String get refusedAt;

  /// On the new payment page, when the restaurant or driver chosen has sent a payment the manager has not answered yet
  ///
  /// In en, this message translates to:
  /// **'A payment they sent from their app is waiting for your answer in the transaction history: it is not counted yet.'**
  String get paymentWaitingForAnswer;

  /// Why the platform owes a restaurant: a loyalty coupon a customer used there
  ///
  /// In en, this message translates to:
  /// **'Loyalty Coupon Credit'**
  String get reasonLoyaltyCouponCredit;

  /// Reject button text
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// On a payment: the note its payer wrote with it
  ///
  /// In en, this message translates to:
  /// **'Note: {note}'**
  String paymentNote(String note);

  /// On a payment: why the other side confirmed or refused it
  ///
  /// In en, this message translates to:
  /// **'Answer: {note}'**
  String paymentAnswer(String note);

  /// Confirmation once the driver confirmed a restaurant's payment (its card leaves the list)
  ///
  /// In en, this message translates to:
  /// **'Payment confirmed'**
  String get paymentConfirmedNotice;

  /// Confirmation once the driver refused a restaurant's payment (its card leaves the list)
  ///
  /// In en, this message translates to:
  /// **'Payment refused'**
  String get paymentRefusedNotice;

  /// Title of the dialog where the driver refuses a restaurant's payment, saying why
  ///
  /// In en, this message translates to:
  /// **'Refuse this payment?'**
  String get refusePaymentTitle;

  /// Hint of the reason field when the driver refuses a restaurant's payment
  ///
  /// In en, this message translates to:
  /// **'Why? (e.g. not received)'**
  String get refusePaymentReasonHint;

  /// Title of the dialog before the driver confirms a restaurant's payment
  ///
  /// In en, this message translates to:
  /// **'Payment received?'**
  String get confirmPaymentReceivedTitle;

  /// Title of the page listing what makes up an amount owed to the driver
  ///
  /// In en, this message translates to:
  /// **'Credit Details'**
  String get creditDetails;

  /// Title of the page listing what makes up an amount the driver owes
  ///
  /// In en, this message translates to:
  /// **'Debt Details'**
  String get debtDetails;

  /// Section: the amounts each delivered order put on the driver
  ///
  /// In en, this message translates to:
  /// **'Order Settlements'**
  String get orderSettlements;

  /// Section: the payments made or received in cash
  ///
  /// In en, this message translates to:
  /// **'Cash Transactions'**
  String get cashTransactions;

  /// A debt or credit with nothing in the chosen period
  ///
  /// In en, this message translates to:
  /// **'No transactions in selected date range'**
  String get noTransactionsInPeriod;

  /// A payment the driver received
  ///
  /// In en, this message translates to:
  /// **'Received Payment'**
  String get receivedPayment;

  /// A payment the driver made
  ///
  /// In en, this message translates to:
  /// **'Sent Payment'**
  String get sentPayment;

  /// Sum of the order settlements of a debt
  ///
  /// In en, this message translates to:
  /// **'Total Order Settlements'**
  String get totalOrderSettlements;

  /// Sum of the payments the driver made
  ///
  /// In en, this message translates to:
  /// **'Total Cash Outgoing'**
  String get totalCashOutgoing;

  /// Sum of the payments the driver received
  ///
  /// In en, this message translates to:
  /// **'Total Cash Incoming'**
  String get totalCashIncoming;

  /// What remains once settlements and payments are counted
  ///
  /// In en, this message translates to:
  /// **'Net Balance'**
  String get netBalance;

  /// Balance details: how much of these orders the payments (of any date, the oldest orders first) already paid
  ///
  /// In en, this message translates to:
  /// **'Paid towards these orders'**
  String get paidTowardsOrders;

  /// Balance details, days chosen: the cash the restaurant paid during those days (it may pay other days' orders)
  ///
  /// In en, this message translates to:
  /// **'Cash paid in these days'**
  String get cashPaidInTheseDays;

  /// Balance details, days chosen: the cash the restaurant received during those days (it may pay other days' orders)
  ///
  /// In en, this message translates to:
  /// **'Cash received in these days'**
  String get cashReceivedInTheseDays;

  /// Why a payment the driver made was counted
  ///
  /// In en, this message translates to:
  /// **'Overcharge'**
  String get reasonOvercharge;

  /// Why an amount was counted: a delivered order
  ///
  /// In en, this message translates to:
  /// **'Order Settlement'**
  String get reasonOrderSettlement;

  /// Why an amount was counted: a coupon the platform pays back to the driver
  ///
  /// In en, this message translates to:
  /// **'Coupon Credit'**
  String get reasonCouponCredit;

  /// Why an amount was counted: a coupon for every customer, paid back to the driver
  ///
  /// In en, this message translates to:
  /// **'Global Coupon Credit'**
  String get reasonGlobalCouponCredit;

  /// Why an amount was counted: a customer's birthday gift, paid back to the driver
  ///
  /// In en, this message translates to:
  /// **'Birthday Gift Credit'**
  String get reasonBirthdayCredit;

  /// The delivery zones page and its door on the home page: where customers can order (not the coupons' zones)
  ///
  /// In en, this message translates to:
  /// **'Delivery Zones'**
  String get deliveryAreas;

  /// The delivery zones page: what the zones are for
  ///
  /// In en, this message translates to:
  /// **'Customers can order only at a door inside a zone that is on.'**
  String get deliveryAreasHelp;

  /// The delivery zones page, empty
  ///
  /// In en, this message translates to:
  /// **'No delivery zone yet: no customer can order.'**
  String get noDeliveryAreasYet;

  /// The delivery zones page: the button and the form's title for a new zone
  ///
  /// In en, this message translates to:
  /// **'Add a delivery zone'**
  String get addDeliveryArea;

  /// The delivery zones page: the form's title for a zone changed
  ///
  /// In en, this message translates to:
  /// **'Edit the delivery zone'**
  String get editDeliveryArea;

  /// The delivery zones page: under a zone that is on
  ///
  /// In en, this message translates to:
  /// **'On: customers can order there'**
  String get deliveryAreaOn;

  /// The delivery zones page: under a zone that is off
  ///
  /// In en, this message translates to:
  /// **'Off: no customer can order there'**
  String get deliveryAreaOff;

  /// The delivery zones page: the question's title before a zone is deleted
  ///
  /// In en, this message translates to:
  /// **'Delete the delivery zone'**
  String get deleteDeliveryArea;

  /// The delivery zones page: the question before a zone is deleted
  ///
  /// In en, this message translates to:
  /// **'Delete {name}? Customers there will no longer be able to order.'**
  String deleteDeliveryAreaConfirmation(String name);

  /// The delivery zone form: a centre that is no place on Earth
  ///
  /// In en, this message translates to:
  /// **'Latitude from -90 to 90, longitude from -180 to 180'**
  String get coordinatesInvalid;

  /// The delivery zone form: a radius the server would refuse
  ///
  /// In en, this message translates to:
  /// **'The radius goes from 0.1 to 100 km'**
  String get radiusOutOfRange;

  /// The bank: the button on what the platform owes a restaurant or a driver
  ///
  /// In en, this message translates to:
  /// **'Pay from the platform'**
  String get payFromPlatform;

  /// The bank: the title of the platform payment form
  ///
  /// In en, this message translates to:
  /// **'A payment from the platform to {name}'**
  String platformPaymentTitle(String name);

  /// The bank: under the platform payment form's title
  ///
  /// In en, this message translates to:
  /// **'It counts at once, and they are told. Paying more than is owed makes the difference their debt to the platform.'**
  String get platformPaymentHelp;

  /// The bank: once the platform payment is recorded
  ///
  /// In en, this message translates to:
  /// **'Payment from the platform recorded'**
  String get platformPaymentRecorded;

  /// The bank's archive: a payment the platform made
  ///
  /// In en, this message translates to:
  /// **'Paid by the platform'**
  String get paidByThePlatform;

  /// A balance's details: what a side paid beyond its debts, owed back by the other (anyone may pay more than they owe)
  ///
  /// In en, this message translates to:
  /// **'Paid beyond what was owed'**
  String get paidBeyondWhatWasOwed;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
