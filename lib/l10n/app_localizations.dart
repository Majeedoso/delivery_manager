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
  /// **'Delivery Driver'**
  String get appName;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Sign up button text
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

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

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

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

  /// Text before sign up link
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// Text before login link
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// Google sign in button text
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// Google sign up button text
  ///
  /// In en, this message translates to:
  /// **'Sign up with Google'**
  String get signUpWithGoogle;

  /// Email sign up button text
  ///
  /// In en, this message translates to:
  /// **'Sign up with Email'**
  String get signUpWithEmail;

  /// Create account title
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Checking authentication status message
  ///
  /// In en, this message translates to:
  /// **'Checking authentication...'**
  String get checkingAuthentication;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Logout button text
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Clear saved credentials button text
  ///
  /// In en, this message translates to:
  /// **'Clear Saved Credentials'**
  String get clearSavedCredentials;

  /// Language selection label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Language selection dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Arabic language name
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// French language name
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

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

  /// Profile information section title
  ///
  /// In en, this message translates to:
  /// **'Profile Information'**
  String get profileInformation;

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

  /// Delivery preferences screen title
  ///
  /// In en, this message translates to:
  /// **'Delivery Preferences'**
  String get deliveryPreferences;

  /// Delivery preferences description
  ///
  /// In en, this message translates to:
  /// **'Choose which restaurants you want to deliver for'**
  String get deliveryPreferencesDescription;

  /// mutualSelected badge
  ///
  /// In en, this message translates to:
  /// **'Mutual'**
  String get mutualSelected;

  /// pendingSelected badge
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingSelected;

  /// selectAllRestaurants label
  ///
  /// In en, this message translates to:
  /// **'Select All Restaurants'**
  String get selectAllRestaurants;

  /// Hint shown when no restaurants are selected
  ///
  /// In en, this message translates to:
  /// **'No selection means you will receive orders from all restaurants.'**
  String get noSelectionAllRestaurantsHint;

  /// selectedRestaurantsCount label
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} selected'**
  String selectedRestaurantsCount(int count, int total);

  /// updatingSelections label
  ///
  /// In en, this message translates to:
  /// **'Updating selections {done}/{total}...'**
  String updatingSelections(int done, int total);

  /// Linked restaurants section title
  ///
  /// In en, this message translates to:
  /// **'Linked Restaurants'**
  String get linkedRestaurants;

  /// Button label to add restaurant by code
  ///
  /// In en, this message translates to:
  /// **'Add Restaurant by Code'**
  String get addRestaurantByCode;

  /// Restaurant code field label
  ///
  /// In en, this message translates to:
  /// **'Restaurant Code'**
  String get restaurantCode;

  /// Restaurant code input hint
  ///
  /// In en, this message translates to:
  /// **'Enter restaurant code'**
  String get enterRestaurantCode;

  /// Button label to link restaurant
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get linkRestaurant;

  /// Success message when restaurant is linked
  ///
  /// In en, this message translates to:
  /// **'Linked successfully'**
  String get linkRestaurantSuccess;

  /// Success message when restaurant is unlinked
  ///
  /// In en, this message translates to:
  /// **'Unlinked successfully'**
  String get unlinkRestaurant;

  /// Empty state title when no linked restaurants
  ///
  /// In en, this message translates to:
  /// **'No linked restaurants yet'**
  String get noLinkedRestaurants;

  /// Empty state description when no linked restaurants
  ///
  /// In en, this message translates to:
  /// **'Add a restaurant code to start delivering for specific restaurants.'**
  String get noLinkedRestaurantsDescription;

  /// Notifications section title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Push notifications setting
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// Push notifications description
  ///
  /// In en, this message translates to:
  /// **'Receive push notifications'**
  String get pushNotificationsDescription;

  /// Email notifications setting
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get emailNotifications;

  /// Email notifications description
  ///
  /// In en, this message translates to:
  /// **'Receive email notifications'**
  String get emailNotificationsDescription;

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
  /// **'This application is designed for delivery drivers to manage their deliveries efficiently. Drivers can view available orders, accept delivery requests, navigate to pickup and delivery locations, update delivery status in real-time, set their availability schedule, and track their earnings.'**
  String get aboutDescription;

  /// Features section title
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// User authentication feature
  ///
  /// In en, this message translates to:
  /// **'User Authentication'**
  String get userAuthentication;

  /// User authentication description
  ///
  /// In en, this message translates to:
  /// **'Secure login and registration system'**
  String get userAuthenticationDescription;

  /// Multi-language support feature
  ///
  /// In en, this message translates to:
  /// **'Multi-Language Support'**
  String get multiLanguageSupport;

  /// Multi-language support description
  ///
  /// In en, this message translates to:
  /// **'Support for multiple languages'**
  String get multiLanguageSupportDescription;

  /// Secure storage feature
  ///
  /// In en, this message translates to:
  /// **'Secure Storage'**
  String get secureStorage;

  /// Secure storage description
  ///
  /// In en, this message translates to:
  /// **'Secure storage for sensitive data'**
  String get secureStorageDescription;

  /// Google sign-in feature
  ///
  /// In en, this message translates to:
  /// **'Google Sign-In'**
  String get googleSignIn;

  /// Google sign-in description
  ///
  /// In en, this message translates to:
  /// **'Quick sign-in with Google account'**
  String get googleSignInDescription;

  /// Contact us section title
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// Copyright text
  ///
  /// In en, this message translates to:
  /// **'© 2024 Delivery Driver. All rights reserved.'**
  String get copyright;

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

  /// Pending orders container title
  ///
  /// In en, this message translates to:
  /// **'Pending Orders'**
  String get pendingOrders;

  /// Pending orders container description
  ///
  /// In en, this message translates to:
  /// **'Manage orders waiting for verification'**
  String get pendingOrdersDescription;

  /// Accept order button text
  ///
  /// In en, this message translates to:
  /// **'Accept Order'**
  String get acceptOrder;

  /// Success message when order is accepted
  ///
  /// In en, this message translates to:
  /// **'Order accepted successfully!'**
  String get orderAcceptedSuccessfully;

  /// Empty state message when no orders
  ///
  /// In en, this message translates to:
  /// **'No orders available'**
  String get noOrdersAvailable;

  /// Empty state subtitle
  ///
  /// In en, this message translates to:
  /// **'Check back later for new orders'**
  String get checkBackLater;

  /// Refresh button text
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Placeholder when no delivery address
  ///
  /// In en, this message translates to:
  /// **'No delivery address'**
  String get noDeliveryAddress;

  /// Items label (plural)
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get items;

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

  /// Cash payment method
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// Card payment method
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get card;

  /// Confirmed status
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// Ready for pickup status
  ///
  /// In en, this message translates to:
  /// **'Ready for Pickup'**
  String get readyForPickup;

  /// Show more details button
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get showMore;

  /// Show less details button
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// Payment method label
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentMethod;

  /// Delivery notes label
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get deliveryNotes;

  /// Title for ongoing orders feature
  ///
  /// In en, this message translates to:
  /// **'Ongoing Orders'**
  String get ongoingOrders;

  /// Description for ongoing orders hub screen
  ///
  /// In en, this message translates to:
  /// **'Manage your active deliveries'**
  String get ongoingOrdersDescription;

  /// Archive orders container title
  ///
  /// In en, this message translates to:
  /// **'Archive Orders'**
  String get archiveOrders;

  /// Archive orders container description
  ///
  /// In en, this message translates to:
  /// **'View accepted and rejected orders'**
  String get archiveOrdersDescription;

  /// Statistics screen title
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// Statistics container description
  ///
  /// In en, this message translates to:
  /// **'View your performance metrics'**
  String get statisticsDescription;

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

  /// Orders screen title
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// Archive screen title
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// Orders archive container title
  ///
  /// In en, this message translates to:
  /// **'Orders Archive'**
  String get ordersArchive;

  /// Accepted orders screen title
  ///
  /// In en, this message translates to:
  /// **'Accepted Orders'**
  String get acceptedOrders;

  /// Title for rejected orders screen
  ///
  /// In en, this message translates to:
  /// **'Rejected Orders'**
  String get rejectedOrders;

  /// Delivered orders screen title
  ///
  /// In en, this message translates to:
  /// **'Delivered Orders'**
  String get deliveredOrders;

  /// Canceled orders screen title
  ///
  /// In en, this message translates to:
  /// **'Canceled Orders'**
  String get canceledOrders;

  /// Delivered orders status label
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// Cancelled status label
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

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

  /// Send reset link button text
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// Send OTP button text
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// Back to login button text
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

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

  /// Email not verified status title
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

  /// Verification email sent success message
  ///
  /// In en, this message translates to:
  /// **'Verification email sent successfully. Please check your inbox.'**
  String get verificationEmailSent;

  /// Checking status text
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get checking;

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

  /// Message when notifications are required
  ///
  /// In en, this message translates to:
  /// **'Notifications are required for this app'**
  String get notificationsRequired;

  /// Description of why notifications are required
  ///
  /// In en, this message translates to:
  /// **'This app requires notification permission to receive new order alerts.'**
  String get notificationsRequiredDescription;

  /// Enable notifications button text
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// Open settings button text
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// Exit app button text
  ///
  /// In en, this message translates to:
  /// **'Exit App'**
  String get exitApp;

  /// Initialization status message
  ///
  /// In en, this message translates to:
  /// **'Initializing...'**
  String get initializing;

  /// Checking notifications status message
  ///
  /// In en, this message translates to:
  /// **'Checking notifications...'**
  String get checkingNotifications;

  /// Setting up notifications status message
  ///
  /// In en, this message translates to:
  /// **'Setting up notifications...'**
  String get settingUpNotifications;

  /// Initialization failed error message
  ///
  /// In en, this message translates to:
  /// **'Initialization failed'**
  String get initializationFailed;

  /// Requesting permission status message
  ///
  /// In en, this message translates to:
  /// **'Requesting permission...'**
  String get requestingPermission;

  /// Permission request failed error message
  ///
  /// In en, this message translates to:
  /// **'Permission request failed'**
  String get permissionRequestFailed;

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

  /// Week period option for period selector
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

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

  /// Period selection dropdown label
  ///
  /// In en, this message translates to:
  /// **'Select Period'**
  String get selectPeriod;

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

  /// Average responding time label
  ///
  /// In en, this message translates to:
  /// **'Average Responding Time'**
  String get averageRespondingTime;

  /// Accepted orders success rate label - measures how many accepted orders were actually delivered successfully
  ///
  /// In en, this message translates to:
  /// **'Good Decisions Rate'**
  String get acceptedOrdersSuccessRate;

  /// Explanation of accepted orders success rate metric
  ///
  /// In en, this message translates to:
  /// **'Measures how many accepted orders were successfully delivered. This is a positive metric that focuses on successes.'**
  String get acceptedOrdersSuccessRateExplanation;

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

  /// Accepted orders failure rate label - measures how many accepted orders failed
  ///
  /// In en, this message translates to:
  /// **'Bad Decisions Rate'**
  String get acceptedOrdersFailureRate;

  /// Explanation of accepted orders failure rate metric
  ///
  /// In en, this message translates to:
  /// **'Measures how many accepted orders failed for any reason (canceled, returned, refused by customer, not delivered). This is a negative metric that focuses on failures.'**
  String get acceptedOrdersFailureRateExplanation;

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

  /// Explanation of average responding time metric
  ///
  /// In en, this message translates to:
  /// **'Measures the average time it takes for the operator to respond to an order (accept or reject) after it\'s created.'**
  String get averageRespondingTimeExplanation;

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

  /// Order breakdown section title
  ///
  /// In en, this message translates to:
  /// **'Order Breakdown'**
  String get orderBreakdown;

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

  /// Plural minutes time unit
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// Single hour time unit
  ///
  /// In en, this message translates to:
  /// **'hour'**
  String get hour;

  /// Plural hours time unit
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// Plural days time unit
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

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

  /// Error loading orders message
  ///
  /// In en, this message translates to:
  /// **'Error loading orders'**
  String get errorLoadingOrders;

  /// Order label
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// Customer label
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// Restaurant label
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get restaurant;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Address field label
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// Is Open toggle label
  ///
  /// In en, this message translates to:
  /// **'Is Open'**
  String get isOpen;

  /// Restaurant and Notes toggle button label
  ///
  /// In en, this message translates to:
  /// **'Restaurant & Notes'**
  String get restaurantAndNotes;

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

  /// Delivery Instructions label
  ///
  /// In en, this message translates to:
  /// **'Delivery Instructions'**
  String get deliveryInstructions;

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Reject button text
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// Start Preparing button text
  ///
  /// In en, this message translates to:
  /// **'Start Preparing'**
  String get startPreparing;

  /// Mark Ready button text
  ///
  /// In en, this message translates to:
  /// **'Mark Ready'**
  String get markReady;

  /// Picked Up button text
  ///
  /// In en, this message translates to:
  /// **'Picked Up'**
  String get pickedUp;

  /// Mark Delivered button text
  ///
  /// In en, this message translates to:
  /// **'Mark Delivered'**
  String get markDelivered;

  /// Load More button text
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get loadMore;

  /// No pending orders message
  ///
  /// In en, this message translates to:
  /// **'No Pending Orders'**
  String get noPendingOrders;

  /// No pending orders description
  ///
  /// In en, this message translates to:
  /// **'There are no pending orders in this date range.'**
  String get noPendingOrdersDescription;

  /// No ongoing orders message
  ///
  /// In en, this message translates to:
  /// **'No Ongoing Orders'**
  String get noOngoingOrders;

  /// No ongoing orders description
  ///
  /// In en, this message translates to:
  /// **'There are no ongoing orders in this date range.'**
  String get noOngoingOrdersDescription;

  /// Dialog title for selecting delivery method
  ///
  /// In en, this message translates to:
  /// **'Select Delivery Method'**
  String get selectDeliveryMethod;

  /// Self delivery option label
  ///
  /// In en, this message translates to:
  /// **'Self Delivery'**
  String get selfDelivery;

  /// External delivery option label
  ///
  /// In en, this message translates to:
  /// **'External Delivery'**
  String get externalDelivery;

  /// Self delivery description
  ///
  /// In en, this message translates to:
  /// **'The restaurant will deliver the order with its own driver'**
  String get selfDeliveryDescription;

  /// External delivery description
  ///
  /// In en, this message translates to:
  /// **'The order will be picked up by third-party drivers'**
  String get externalDeliveryDescription;

  /// Message prompting user to select delivery method
  ///
  /// In en, this message translates to:
  /// **'Please select a delivery method before marking the order as ready'**
  String get pleaseSelectDeliveryMethod;

  /// Drivers section title
  ///
  /// In en, this message translates to:
  /// **'Drivers'**
  String get drivers;

  /// Add driver button text
  ///
  /// In en, this message translates to:
  /// **'Add Driver'**
  String get addDriver;

  /// Edit driver button text
  ///
  /// In en, this message translates to:
  /// **'Edit Driver'**
  String get editDriver;

  /// Delete driver button text
  ///
  /// In en, this message translates to:
  /// **'Delete Driver'**
  String get deleteDriver;

  /// Driver code field label
  ///
  /// In en, this message translates to:
  /// **'Driver Code'**
  String get driverCode;

  /// Driver code required validation message
  ///
  /// In en, this message translates to:
  /// **'Driver code is required'**
  String get driverCodeRequired;

  /// Message when no drivers are added
  ///
  /// In en, this message translates to:
  /// **'No drivers added yet'**
  String get noDriversAdded;

  /// Warning message when no drivers exist for self delivery
  ///
  /// In en, this message translates to:
  /// **'Please add a driver in your profile before choosing Self Delivery.'**
  String get pleaseAddDriverBeforeSelfDelivery;

  /// Dialog title for selecting drivers
  ///
  /// In en, this message translates to:
  /// **'Select Drivers for Delivery'**
  String get selectDriversForDelivery;

  /// Option to select all drivers
  ///
  /// In en, this message translates to:
  /// **'Select All Drivers'**
  String get selectAllDrivers;

  /// Option to select specific drivers
  ///
  /// In en, this message translates to:
  /// **'Select Specific Drivers'**
  String get selectSpecificDrivers;

  /// Message showing number of selected drivers
  ///
  /// In en, this message translates to:
  /// **'{count} driver(s) selected'**
  String driverSelected(int count);

  /// Error message when driver code doesn't exist
  ///
  /// In en, this message translates to:
  /// **'Driver code not found. Please enter a valid driver code.'**
  String get driverCodeNotFound;

  /// Error message when trying to link an already linked driver
  ///
  /// In en, this message translates to:
  /// **'This driver is already linked to your restaurant.'**
  String get driverAlreadyLinked;

  /// Success message when driver is linked successfully
  ///
  /// In en, this message translates to:
  /// **'Driver linked successfully!'**
  String get driverLinkedSuccessfully;

  /// Request timeout error message
  ///
  /// In en, this message translates to:
  /// **'Request Timeout'**
  String get requestTimeout;

  /// Request timeout description
  ///
  /// In en, this message translates to:
  /// **'The request took too long to complete. Please check your internet connection and try again.'**
  String get requestTimeoutDescription;

  /// Call button tooltip
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// Failed to open phone app error message
  ///
  /// In en, this message translates to:
  /// **'Failed to open phone app'**
  String get failedToOpenPhoneApp;

  /// Error making phone call message
  ///
  /// In en, this message translates to:
  /// **'Error making phone call'**
  String get errorMakingPhoneCall;

  /// Orders loaded successfully message
  ///
  /// In en, this message translates to:
  /// **'Orders loaded successfully'**
  String get ordersLoadedSuccessfully;

  /// Order confirmed successfully message
  ///
  /// In en, this message translates to:
  /// **'Order confirmed successfully'**
  String get orderConfirmedSuccessfully;

  /// Order rejected successfully message
  ///
  /// In en, this message translates to:
  /// **'Order rejected successfully'**
  String get orderRejectedSuccessfully;

  /// Confirm order dialog title and button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmOrder;

  /// Confirm order confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to confirm this order?'**
  String get areYouSureConfirmOrder;

  /// Confirm order description
  ///
  /// In en, this message translates to:
  /// **'This will approve the order and make it visible to the restaurant.'**
  String get confirmOrderDescription;

  /// Reject order dialog title
  ///
  /// In en, this message translates to:
  /// **'Please select a reason for rejecting this order:'**
  String get pleaseSelectRejectReason;

  /// Custom reject reason input hint
  ///
  /// In en, this message translates to:
  /// **'Enter your reason...'**
  String get enterYourReason;

  /// Reject reason option
  ///
  /// In en, this message translates to:
  /// **'Didn\'t pick up the phone'**
  String get rejectReasonDidntPickUp;

  /// Reject reason option
  ///
  /// In en, this message translates to:
  /// **'Suspicious customer behavior'**
  String get rejectReasonSuspiciousBehavior;

  /// Reject reason option
  ///
  /// In en, this message translates to:
  /// **'Invalid delivery address'**
  String get rejectReasonInvalidAddress;

  /// Reject reason option
  ///
  /// In en, this message translates to:
  /// **'Order amount seems unrealistic'**
  String get rejectReasonUnrealisticAmount;

  /// Reject reason option
  ///
  /// In en, this message translates to:
  /// **'Customer contact information invalid'**
  String get rejectReasonInvalidContact;

  /// Reject reason option
  ///
  /// In en, this message translates to:
  /// **'Restaurant not available'**
  String get rejectReasonRestaurantUnavailable;

  /// Other option label
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

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

  /// Message when App Store URL is not configured
  ///
  /// In en, this message translates to:
  /// **'App Store URL is not configured. Please update the app manually from the App Store.'**
  String get appStoreUrlNotConfigured;

  /// Message when app package cannot be determined
  ///
  /// In en, this message translates to:
  /// **'Unable to determine app package. Please update the app manually from {store}.'**
  String unableToDetermineAppPackage(String store);

  /// Message when app store cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Unable to open {store}. Please update the app manually.'**
  String unableToOpenStore(String store);

  /// Error message when app store cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Error opening app store: {error}. Please update the app manually.'**
  String errorOpeningAppStore(String error);

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

  /// Error message when legal URLs cannot be retrieved
  ///
  /// In en, this message translates to:
  /// **'Failed to get legal URLs'**
  String get failedToGetLegalUrls;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your internet connection.'**
  String get networkErrorCheckConnection;

  /// Generic server error message
  ///
  /// In en, this message translates to:
  /// **'Server error occurred'**
  String get serverErrorOccurred;

  /// Error message when contact information cannot be retrieved
  ///
  /// In en, this message translates to:
  /// **'Failed to get contact information'**
  String get failedToGetContactInformation;

  /// Unexpected error message
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred: {error}'**
  String unexpectedErrorOccurred(String error);

  /// App Store name
  ///
  /// In en, this message translates to:
  /// **'App Store'**
  String get appStore;

  /// Play Store name
  ///
  /// In en, this message translates to:
  /// **'Play Store'**
  String get playStore;

  /// Message when URL is not available
  ///
  /// In en, this message translates to:
  /// **'URL not available. Please try again later.'**
  String get urlNotAvailable;

  /// Message when URL cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Unable to open URL. Please try again.'**
  String get unableToOpenUrlTryAgain;

  /// Message when URL cannot be opened due to connection issues
  ///
  /// In en, this message translates to:
  /// **'Unable to open URL. Please check your internet connection.'**
  String get unableToOpenUrlCheckConnection;

  /// Generic error message fallback
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get anErrorOccurred;

  /// Opening hours section title
  ///
  /// In en, this message translates to:
  /// **'Opening Hours'**
  String get openingHours;

  /// Closed status for a day
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// Monday day name
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// Tuesday day name
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// Wednesday day name
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// Thursday day name
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// Friday day name
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// Saturday day name
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

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

  /// Schedule page title
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// Message when restaurant is open
  ///
  /// In en, this message translates to:
  /// **'Restaurant is currently open'**
  String get restaurantIsOpen;

  /// Message when restaurant is closed
  ///
  /// In en, this message translates to:
  /// **'Restaurant is currently closed'**
  String get restaurantIsClosed;

  /// Button text to update schedule
  ///
  /// In en, this message translates to:
  /// **'Update Schedule'**
  String get updateSchedule;

  /// Driver availability toggle label
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get driverAvailability;

  /// Message when driver is available
  ///
  /// In en, this message translates to:
  /// **'You are currently available for deliveries'**
  String get driverIsAvailable;

  /// Message when driver is unavailable
  ///
  /// In en, this message translates to:
  /// **'You are currently unavailable for deliveries'**
  String get driverIsUnavailable;

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

  /// Title for location selection dialog
  ///
  /// In en, this message translates to:
  /// **'Select Location Method'**
  String get selectLocationMethod;

  /// Manual entry option for location
  ///
  /// In en, this message translates to:
  /// **'Manual Entry'**
  String get manualEntry;

  /// Map selection option for location
  ///
  /// In en, this message translates to:
  /// **'From Map'**
  String get fromMap;

  /// Title for map picker page
  ///
  /// In en, this message translates to:
  /// **'Select Location on Map'**
  String get selectLocationOnMap;

  /// Button text to select location
  ///
  /// In en, this message translates to:
  /// **'Select Location'**
  String get selectLocation;

  /// Label for location coordinates field
  ///
  /// In en, this message translates to:
  /// **'Location Coordinates'**
  String get locationCoordinates;

  /// Title for manual coordinates dialog
  ///
  /// In en, this message translates to:
  /// **'Enter Coordinates Manually'**
  String get enterCoordinatesManually;

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

  /// Validation message for required latitude
  ///
  /// In en, this message translates to:
  /// **'Latitude is required'**
  String get latitudeRequired;

  /// Validation message for required longitude
  ///
  /// In en, this message translates to:
  /// **'Longitude is required'**
  String get longitudeRequired;

  /// Validation message for invalid latitude
  ///
  /// In en, this message translates to:
  /// **'Invalid latitude value'**
  String get invalidLatitude;

  /// Validation message for invalid longitude
  ///
  /// In en, this message translates to:
  /// **'Invalid longitude value'**
  String get invalidLongitude;

  /// Validation message for latitude range
  ///
  /// In en, this message translates to:
  /// **'Latitude must be between -90 and 90'**
  String get latitudeRange;

  /// Validation message for longitude range
  ///
  /// In en, this message translates to:
  /// **'Longitude must be between -180 and 180'**
  String get longitudeRange;

  /// Menu feature title
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// Categories label
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// Menu items label
  ///
  /// In en, this message translates to:
  /// **'Menu Items'**
  String get menuItems;

  /// Add category button text
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// Edit category button text
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// Delete category button text
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get deleteCategory;

  /// Add menu item button text
  ///
  /// In en, this message translates to:
  /// **'Add Menu Item'**
  String get addMenuItem;

  /// Edit menu item button text
  ///
  /// In en, this message translates to:
  /// **'Edit Menu Item'**
  String get editMenuItem;

  /// Delete menu item button text
  ///
  /// In en, this message translates to:
  /// **'Delete Menu Item'**
  String get deleteMenuItem;

  /// Category name field label
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// Category description field label
  ///
  /// In en, this message translates to:
  /// **'Category Description'**
  String get categoryDescription;

  /// Menu item name field label
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemName;

  /// Menu item description field label
  ///
  /// In en, this message translates to:
  /// **'Item Description'**
  String get itemDescription;

  /// Menu item price field label
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get itemPrice;

  /// Preparation time field label
  ///
  /// In en, this message translates to:
  /// **'Preparation Time'**
  String get preparationTime;

  /// Ingredients label
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// Allergens label
  ///
  /// In en, this message translates to:
  /// **'Allergens'**
  String get allergens;

  /// Nutritional information label
  ///
  /// In en, this message translates to:
  /// **'Nutritional Information'**
  String get nutritionalInfo;

  /// Image label
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

  /// Select image button text
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get selectImage;

  /// Take photo option
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// Choose from gallery option
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// Search field label
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Filter button text
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// Bulk actions label
  ///
  /// In en, this message translates to:
  /// **'Bulk Actions'**
  String get bulkActions;

  /// Delete selected items button text
  ///
  /// In en, this message translates to:
  /// **'Delete Selected'**
  String get deleteSelected;

  /// Toggle availability button text
  ///
  /// In en, this message translates to:
  /// **'Toggle Availability'**
  String get toggleAvailability;

  /// Reorder button text
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get reorder;

  /// Drag to reorder instruction
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get dragToReorder;

  /// Active status label
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Inactive status label
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

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

  /// Featured label
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featured;

  /// Available status label
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// Unavailable status label
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// Selected label
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// Make unavailable button text
  ///
  /// In en, this message translates to:
  /// **'Make Unavailable'**
  String get makeUnavailable;

  /// Make available button text
  ///
  /// In en, this message translates to:
  /// **'Make Available'**
  String get makeAvailable;

  /// Remove button text
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Remove image dialog title
  ///
  /// In en, this message translates to:
  /// **'Remove Image'**
  String get removeImage;

  /// Remove image confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this image?'**
  String get areYouSureYouWantToRemoveThisImage;

  /// No categories message
  ///
  /// In en, this message translates to:
  /// **'No Categories'**
  String get noCategories;

  /// No categories description
  ///
  /// In en, this message translates to:
  /// **'You haven\'t created any categories yet. Tap the + button to add one.'**
  String get noCategoriesDescription;

  /// No menu items message
  ///
  /// In en, this message translates to:
  /// **'No Menu Items'**
  String get noMenuItems;

  /// No menu items description
  ///
  /// In en, this message translates to:
  /// **'This category doesn\'t have any items yet. Tap the + button to add one.'**
  String get noMenuItemsDescription;

  /// Delete category confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this category?'**
  String get areYouSureDeleteCategory;

  /// Delete menu item confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this menu item?'**
  String get areYouSureDeleteMenuItem;

  /// Delete selected items confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {count} selected item(s)?'**
  String areYouSureDeleteSelected(int count);

  /// Message when trying to delete category with items
  ///
  /// In en, this message translates to:
  /// **'This category contains {count} item(s). Please delete or move the items first.'**
  String categoryHasItems(int count);

  /// Category name required validation
  ///
  /// In en, this message translates to:
  /// **'Category name is required'**
  String get categoryNameRequired;

  /// Item name required validation
  ///
  /// In en, this message translates to:
  /// **'Item name is required'**
  String get itemNameRequired;

  /// Price required validation
  ///
  /// In en, this message translates to:
  /// **'Price is required'**
  String get priceRequired;

  /// Price invalid validation
  ///
  /// In en, this message translates to:
  /// **'Price must be greater than 0'**
  String get priceInvalid;

  /// Preparation time required validation
  ///
  /// In en, this message translates to:
  /// **'Preparation time is required'**
  String get preparationTimeRequired;

  /// Preparation time invalid validation
  ///
  /// In en, this message translates to:
  /// **'Preparation time must be at least 1 minute'**
  String get preparationTimeInvalid;

  /// Category required validation
  ///
  /// In en, this message translates to:
  /// **'Category is required'**
  String get categoryRequired;

  /// Add ingredient button text
  ///
  /// In en, this message translates to:
  /// **'Add Ingredient'**
  String get addIngredient;

  /// Add allergen button text
  ///
  /// In en, this message translates to:
  /// **'Add Allergen'**
  String get addAllergen;

  /// Sort order field label
  ///
  /// In en, this message translates to:
  /// **'Sort Order'**
  String get sortOrder;

  /// Is active toggle label
  ///
  /// In en, this message translates to:
  /// **'Is Active'**
  String get isActive;

  /// Is available toggle label
  ///
  /// In en, this message translates to:
  /// **'Is Available'**
  String get isAvailable;

  /// Is featured toggle label
  ///
  /// In en, this message translates to:
  /// **'Is Featured'**
  String get isFeatured;

  /// Clear filters button text
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// Sort by name option
  ///
  /// In en, this message translates to:
  /// **'Sort by Name'**
  String get sortByName;

  /// Sort by price option
  ///
  /// In en, this message translates to:
  /// **'Sort by Price'**
  String get sortByPrice;

  /// Sort by order option
  ///
  /// In en, this message translates to:
  /// **'Sort by Order'**
  String get sortByOrder;

  /// Sort ascending option
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get sortAscending;

  /// Sort descending option
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get sortDescending;

  /// Minimum price filter label
  ///
  /// In en, this message translates to:
  /// **'Min Price'**
  String get minPrice;

  /// Maximum price filter label
  ///
  /// In en, this message translates to:
  /// **'Max Price'**
  String get maxPrice;

  /// Select category label
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// Category created success message
  ///
  /// In en, this message translates to:
  /// **'Category created successfully'**
  String get categoryCreatedSuccessfully;

  /// Category updated success message
  ///
  /// In en, this message translates to:
  /// **'Category updated successfully'**
  String get categoryUpdatedSuccessfully;

  /// Category deleted success message
  ///
  /// In en, this message translates to:
  /// **'Category deleted successfully'**
  String get categoryDeletedSuccessfully;

  /// Menu item created success message
  ///
  /// In en, this message translates to:
  /// **'Menu item created successfully'**
  String get menuItemCreatedSuccessfully;

  /// Menu item updated success message
  ///
  /// In en, this message translates to:
  /// **'Menu item updated successfully'**
  String get menuItemUpdatedSuccessfully;

  /// Menu item deleted success message
  ///
  /// In en, this message translates to:
  /// **'Menu item deleted successfully'**
  String get menuItemDeletedSuccessfully;

  /// Menu items updated success message
  ///
  /// In en, this message translates to:
  /// **'Menu items updated successfully'**
  String get menuItemsUpdatedSuccessfully;

  /// Menu items deleted success message
  ///
  /// In en, this message translates to:
  /// **'Menu items deleted successfully'**
  String get menuItemsDeletedSuccessfully;

  /// Categories reordered success message
  ///
  /// In en, this message translates to:
  /// **'Categories reordered successfully'**
  String get categoriesReorderedSuccessfully;

  /// Menu items reordered success message
  ///
  /// In en, this message translates to:
  /// **'Menu items reordered successfully'**
  String get menuItemsReorderedSuccessfully;

  /// Bank feature title
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get bank;

  /// Total expected amount label
  ///
  /// In en, this message translates to:
  /// **'Total Expected'**
  String get totalExpected;

  /// Driver debts section title
  ///
  /// In en, this message translates to:
  /// **'Driver Debts'**
  String get driverDebts;

  /// Section header for pending payments
  ///
  /// In en, this message translates to:
  /// **'Pending Payments'**
  String get pendingPayments;

  /// No pending transactions message
  ///
  /// In en, this message translates to:
  /// **'No pending transactions'**
  String get noPendingTransactions;

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

  /// Restaurant system manager debt label
  ///
  /// In en, this message translates to:
  /// **'Restaurant System Manager Debt'**
  String get restaurantSystemManagerDebt;

  /// Restaurant debt to system title
  ///
  /// In en, this message translates to:
  /// **'The restaurant\'s debt to the system'**
  String get restaurantDebtToSystem;

  /// Restaurant system manager debt description
  ///
  /// In en, this message translates to:
  /// **'Amount restaurant owes to system manager (10% of order total)'**
  String get restaurantSystemManagerDebtDescription;

  /// Amount label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Driver label
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driver;

  /// Expected from drivers page title
  ///
  /// In en, this message translates to:
  /// **'Expected from Drivers'**
  String get expectedFromDrivers;

  /// Pay to system administrator page title
  ///
  /// In en, this message translates to:
  /// **'Pay to System Administrator'**
  String get payToSystemAdministrator;

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

  /// Create transaction button/label
  ///
  /// In en, this message translates to:
  /// **'Create Transaction'**
  String get createTransaction;

  /// Pay System tab label
  ///
  /// In en, this message translates to:
  /// **'Pay System'**
  String get paySystem;

  /// Message shown while calculating payment amount
  ///
  /// In en, this message translates to:
  /// **'Calculating amount...'**
  String get calculatingAmount;

  /// Message shown when amount is calculated
  ///
  /// In en, this message translates to:
  /// **'Amount calculated'**
  String get amountCalculated;

  /// Message shown when calculated amount is zero
  ///
  /// In en, this message translates to:
  /// **'No amount due for the selected date range'**
  String get noAmountForRange;

  /// Helper text for read-only amount field
  ///
  /// In en, this message translates to:
  /// **'Amount is automatically calculated based on selected date range'**
  String get amountFieldReadOnly;

  /// Pending approvals section title
  ///
  /// In en, this message translates to:
  /// **'Pending Approvals'**
  String get pendingApprovals;

  /// My pending transactions section title
  ///
  /// In en, this message translates to:
  /// **'My Pending Transactions'**
  String get myPendingTransactions;

  /// Transaction history section title
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistory;

  /// Filter by type label
  ///
  /// In en, this message translates to:
  /// **'Filter by Type'**
  String get filterByType;

  /// Filter by date label
  ///
  /// In en, this message translates to:
  /// **'Filter by Date'**
  String get filterByDate;

  /// Waiting for approval status
  ///
  /// In en, this message translates to:
  /// **'Waiting for Approval'**
  String get waitingForApproval;

  /// Approved by label
  ///
  /// In en, this message translates to:
  /// **'Approved by'**
  String get approvedBy;

  /// Rejected by label
  ///
  /// In en, this message translates to:
  /// **'Rejected by'**
  String get rejectedBy;

  /// Breakdown by driver section title
  ///
  /// In en, this message translates to:
  /// **'Breakdown by Driver'**
  String get breakdownByDriver;

  /// Section title for breakdown details
  ///
  /// In en, this message translates to:
  /// **'Breakdown'**
  String get breakdown;

  /// Transaction type label
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get transactionType;

  /// Payment to driver transaction type
  ///
  /// In en, this message translates to:
  /// **'From Driver'**
  String get paymentToDriver;

  /// Payment to system transaction type
  ///
  /// In en, this message translates to:
  /// **'Payment to System'**
  String get paymentToSystem;

  /// Select driver label
  ///
  /// In en, this message translates to:
  /// **'Select Driver'**
  String get selectDriver;

  /// Enter amount label
  ///
  /// In en, this message translates to:
  /// **'Enter Amount'**
  String get enterAmount;

  /// Submit button text
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Approve button text
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

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

  /// Confirm cancellation dialog title
  ///
  /// In en, this message translates to:
  /// **'Confirm Cancellation'**
  String get confirmCancellation;

  /// Cancel transaction confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this transaction? This action cannot be undone.'**
  String get cancelTransactionConfirmation;

  /// No button text
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Yes cancel button text
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get yesCancel;

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

  /// Pending transactions screen title
  ///
  /// In en, this message translates to:
  /// **'Pending Transactions'**
  String get pendingTransactions;

  /// Transaction history screen title
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionsHistory;

  /// Ratings menu item title
  ///
  /// In en, this message translates to:
  /// **'Ratings'**
  String get ratings;

  /// Ratings screen title
  ///
  /// In en, this message translates to:
  /// **'Customer Ratings'**
  String get ratingsTitle;

  /// Rating detail screen title
  ///
  /// In en, this message translates to:
  /// **'Rating Details'**
  String get ratingsDetailTitle;

  /// Label showing number of ratings
  ///
  /// In en, this message translates to:
  /// **'Based on {count} ratings'**
  String ratingsBasedOn(String count);

  /// Placeholder name for anonymous ratings
  ///
  /// In en, this message translates to:
  /// **'Anonymous Customer'**
  String get ratingsAnonymous;

  /// Badge showing rating has been responded to
  ///
  /// In en, this message translates to:
  /// **'Responded'**
  String get ratingsResponded;

  /// Button to reply to a rating
  ///
  /// In en, this message translates to:
  /// **'Reply Now'**
  String get ratingsReplyNow;

  /// Success message after submitting response
  ///
  /// In en, this message translates to:
  /// **'Response submitted successfully'**
  String get ratingsResponseSuccess;

  /// Label for overall rating
  ///
  /// In en, this message translates to:
  /// **'Overall Rating'**
  String get ratingsOverallRating;

  /// Label for rating date
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get ratingsDate;

  /// Badge showing customer would reorder
  ///
  /// In en, this message translates to:
  /// **'Would Reorder'**
  String get ratingsWouldReorder;

  /// Badge showing customer would recommend
  ///
  /// In en, this message translates to:
  /// **'Would Recommend'**
  String get ratingsWouldRecommend;

  /// Section title for detailed ratings breakdown
  ///
  /// In en, this message translates to:
  /// **'Detailed Ratings'**
  String get ratingsDetailedRatings;

  /// Label for food quality rating
  ///
  /// In en, this message translates to:
  /// **'Food Quality'**
  String get ratingsFoodQuality;

  /// Label for delivery speed rating
  ///
  /// In en, this message translates to:
  /// **'Delivery Speed'**
  String get ratingsDeliverySpeed;

  /// Label for driver rating
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get ratingsDriver;

  /// Label for restaurant service rating
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get ratingsService;

  /// Section title for rating comments
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get ratingsComments;

  /// Label for general comment
  ///
  /// In en, this message translates to:
  /// **'General Comment'**
  String get ratingsGeneralComment;

  /// Label for food comment
  ///
  /// In en, this message translates to:
  /// **'Food Comment'**
  String get ratingsFoodComment;

  /// Label for delivery comment
  ///
  /// In en, this message translates to:
  /// **'Delivery Comment'**
  String get ratingsDeliveryComment;

  /// Label for driver comment
  ///
  /// In en, this message translates to:
  /// **'Driver Comment'**
  String get ratingsDriverComment;

  /// Label for restaurant comment
  ///
  /// In en, this message translates to:
  /// **'Restaurant Comment'**
  String get ratingsRestaurantComment;

  /// Section title for rating tags
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get ratingsTags;

  /// Section title for existing response
  ///
  /// In en, this message translates to:
  /// **'Your Response'**
  String get ratingsYourResponse;

  /// Section title for response form
  ///
  /// In en, this message translates to:
  /// **'Write a Response'**
  String get ratingsWriteResponse;

  /// Placeholder text for response input
  ///
  /// In en, this message translates to:
  /// **'Thank the customer or address their feedback...'**
  String get ratingsResponseHint;

  /// Validation message when response is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter a response'**
  String get ratingsResponseRequired;

  /// Validation message when response is too short
  ///
  /// In en, this message translates to:
  /// **'Response must be at least 10 characters'**
  String get ratingsResponseMinLength;

  /// Button to submit response
  ///
  /// In en, this message translates to:
  /// **'Submit Response'**
  String get ratingsSubmitResponse;

  /// Title when no ratings are available
  ///
  /// In en, this message translates to:
  /// **'No Ratings Yet'**
  String get ratingsEmptyTitle;

  /// Message when no ratings are available
  ///
  /// In en, this message translates to:
  /// **'Customer ratings will appear here once you receive them.'**
  String get ratingsEmptyMessage;

  /// Button to load more ratings
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get ratingsLoadMore;

  /// Filter option for all ratings
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get ratingsFilterAll;

  /// Filter option for positive ratings (4+ stars)
  ///
  /// In en, this message translates to:
  /// **'Positive'**
  String get ratingsFilterPositive;

  /// Filter option for negative ratings (2 or less stars)
  ///
  /// In en, this message translates to:
  /// **'Negative'**
  String get ratingsFilterNegative;

  /// Section title for order counts
  ///
  /// In en, this message translates to:
  /// **'Order Counts'**
  String get orderCounts;

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

  /// Custom period option
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

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

  /// Statistics data from date label
  ///
  /// In en, this message translates to:
  /// **'Data from'**
  String get statisticsDataFrom;

  /// Order capacity indicator title
  ///
  /// In en, this message translates to:
  /// **'Order Capacity'**
  String get orderCapacity;

  /// Message showing how many more orders driver can accept
  ///
  /// In en, this message translates to:
  /// **'You can accept {count} more order(s)'**
  String canAcceptMoreOrders(int count);

  /// Message when driver has reached maximum order capacity
  ///
  /// In en, this message translates to:
  /// **'Maximum capacity reached'**
  String get maxCapacityReached;

  /// Orders being prepared by restaurant
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get preparing;

  /// Orders currently being delivered
  ///
  /// In en, this message translates to:
  /// **'On Delivery'**
  String get onDelivery;

  /// Empty state title for preparing orders tab
  ///
  /// In en, this message translates to:
  /// **'No orders being prepared'**
  String get noPreparingOrders;

  /// Empty state description for preparing orders tab
  ///
  /// In en, this message translates to:
  /// **'Orders waiting for food preparation will appear here'**
  String get noPreparingOrdersDescription;

  /// Empty state title for ready orders tab
  ///
  /// In en, this message translates to:
  /// **'No orders ready for pickup'**
  String get noReadyOrders;

  /// Empty state description for ready orders tab
  ///
  /// In en, this message translates to:
  /// **'Orders ready to be picked up will appear here'**
  String get noReadyOrdersDescription;

  /// Empty state title for delivering orders tab
  ///
  /// In en, this message translates to:
  /// **'No orders on delivery'**
  String get noDeliveringOrders;

  /// Empty state description for delivering orders tab
  ///
  /// In en, this message translates to:
  /// **'Orders you are delivering will appear here'**
  String get noDeliveringOrdersDescription;

  /// Button to mark order as picked up from restaurant
  ///
  /// In en, this message translates to:
  /// **'Mark as Picked Up'**
  String get markPickedUp;

  /// Button to open Google Maps navigation to restaurant
  ///
  /// In en, this message translates to:
  /// **'Navigate to Restaurant'**
  String get navigateToRestaurant;

  /// Button to open Google Maps navigation to customer
  ///
  /// In en, this message translates to:
  /// **'Navigate to Customer'**
  String get navigateToCustomer;

  /// Title for reject order dialog
  ///
  /// In en, this message translates to:
  /// **'Reject Order'**
  String get rejectOrder;

  /// Prompt to select rejection reason
  ///
  /// In en, this message translates to:
  /// **'Select a reason for rejection:'**
  String get selectRejectionReason;

  /// Rejection reason: distance too far
  ///
  /// In en, this message translates to:
  /// **'Too far from my location'**
  String get rejectionReasonTooFar;

  /// Rejection reason: low pay
  ///
  /// In en, this message translates to:
  /// **'Low earnings for this order'**
  String get rejectionReasonLowEarnings;

  /// Rejection reason: bad delivery area
  ///
  /// In en, this message translates to:
  /// **'Delivery area is problematic'**
  String get rejectionReasonBadArea;

  /// Rejection reason: driver busy
  ///
  /// In en, this message translates to:
  /// **'Currently busy with other deliveries'**
  String get rejectionReasonBusy;

  /// Rejection reason: vehicle problem
  ///
  /// In en, this message translates to:
  /// **'Vehicle/transportation issue'**
  String get rejectionReasonVehicleIssue;

  /// Rejection reason: personal
  ///
  /// In en, this message translates to:
  /// **'Personal reasons'**
  String get rejectionReasonPersonal;

  /// Rejection reason: other
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get rejectionReasonOther;

  /// Label for additional notes field
  ///
  /// In en, this message translates to:
  /// **'Additional Notes (optional)'**
  String get additionalNotes;

  /// Hint for additional notes field
  ///
  /// In en, this message translates to:
  /// **'Add any additional details...'**
  String get additionalNotesHint;

  /// Button to confirm order rejection
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get confirmRejection;

  /// Message shown when order is successfully rejected
  ///
  /// In en, this message translates to:
  /// **'Order rejected'**
  String get orderRejected;

  /// Message when there are no rejected orders
  ///
  /// In en, this message translates to:
  /// **'No rejected orders'**
  String get noRejectedOrders;

  /// Label for rejection timestamp
  ///
  /// In en, this message translates to:
  /// **'Rejected at'**
  String get rejectedAt;

  /// Title for unassign order dialog
  ///
  /// In en, this message translates to:
  /// **'Unassign from Order'**
  String get unassignOrder;

  /// Prompt to select unassign reason
  ///
  /// In en, this message translates to:
  /// **'Why can\'t you complete this order?'**
  String get selectUnassignReason;

  /// Unassign reason: vehicle broke down
  ///
  /// In en, this message translates to:
  /// **'Vehicle breakdown'**
  String get unassignReasonVehicleBreakdown;

  /// Unassign reason: personal emergency
  ///
  /// In en, this message translates to:
  /// **'Personal emergency'**
  String get unassignReasonPersonalEmergency;

  /// Unassign reason: safety issue
  ///
  /// In en, this message translates to:
  /// **'Safety concern at location'**
  String get unassignReasonSafetyConcern;

  /// Unassign reason: inaccessible location
  ///
  /// In en, this message translates to:
  /// **'Cannot reach pickup/delivery location'**
  String get unassignReasonCannotReach;

  /// Unassign reason: excessive waiting
  ///
  /// In en, this message translates to:
  /// **'Restaurant wait time too long'**
  String get unassignReasonLongWait;

  /// Unassign reason: order problem
  ///
  /// In en, this message translates to:
  /// **'Issue with order (missing items, wrong order)'**
  String get unassignReasonOrderIssue;

  /// Unassign reason: other
  ///
  /// In en, this message translates to:
  /// **'Other reason'**
  String get unassignReasonOther;

  /// Button to confirm order unassignment
  ///
  /// In en, this message translates to:
  /// **'Unassign'**
  String get confirmUnassign;

  /// Message when order is successfully unassigned
  ///
  /// In en, this message translates to:
  /// **'Unassigned from order'**
  String get orderUnassigned;

  /// Warning for unassigning during delivery
  ///
  /// In en, this message translates to:
  /// **'Emergency only! Unassigning during delivery is serious and will be reviewed. Only use for genuine emergencies.'**
  String get unassignOnDeliveryWarning;

  /// Warning for unassigning when food is ready
  ///
  /// In en, this message translates to:
  /// **'The food is ready and waiting. Unassigning now may affect food quality for the customer.'**
  String get unassignReadyWarning;

  /// Hint for emergency notes
  ///
  /// In en, this message translates to:
  /// **'Please describe the emergency situation...'**
  String get unassignEmergencyNotesHint;

  /// Notice about consequences of unassigning
  ///
  /// In en, this message translates to:
  /// **'Frequent unassignments may affect your driver metrics. The order will be returned to the available pool.'**
  String get unassignConsequenceNotice;

  /// Button label for unassigning from order
  ///
  /// In en, this message translates to:
  /// **'Can\'t Complete'**
  String get cantCompleteOrder;

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

  /// Pay system debt button text
  ///
  /// In en, this message translates to:
  /// **'Pay System Debt'**
  String get paySystemDebt;

  /// Payment to restaurant transaction type
  ///
  /// In en, this message translates to:
  /// **'Payment to Restaurant'**
  String get paymentToRestaurant;

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

  /// Record button text
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get record;

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

  /// Credit label
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get credit;

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

  /// When pickup speed is good
  ///
  /// In en, this message translates to:
  /// **'Faster pickup (under 10 minutes) ensures fresh food and happy customers.'**
  String get pickupSpeedGood;

  /// When pickup speed is bad
  ///
  /// In en, this message translates to:
  /// **'Slow pickup (over 20 minutes) may result in cold food and unhappy customers.'**
  String get pickupSpeedBad;

  /// Time between pickup and delivery
  ///
  /// In en, this message translates to:
  /// **'Delivery Speed'**
  String get deliverySpeed;

  /// Description of delivery speed metric
  ///
  /// In en, this message translates to:
  /// **'Time from pickup to delivery'**
  String get deliverySpeedDescription;

  /// When delivery speed is good
  ///
  /// In en, this message translates to:
  /// **'Fast delivery (under 20 minutes) leads to satisfied customers and better ratings.'**
  String get deliverySpeedGood;

  /// When delivery speed is bad
  ///
  /// In en, this message translates to:
  /// **'Slow delivery (over 40 minutes) can result in complaints and lower ratings.'**
  String get deliverySpeedBad;

  /// Percentage of orders completed successfully
  ///
  /// In en, this message translates to:
  /// **'Completion Rate'**
  String get completionRate;

  /// Description of completion rate metric
  ///
  /// In en, this message translates to:
  /// **'Percentage of accepted orders that were delivered'**
  String get completionRateDescription;

  /// When completion rate is good
  ///
  /// In en, this message translates to:
  /// **'High rate (95%+) shows reliability and professionalism.'**
  String get completionRateGood;

  /// When completion rate is bad
  ///
  /// In en, this message translates to:
  /// **'Low rate (below 85%) indicates issues with order handling.'**
  String get completionRateBad;

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

  /// When cancellation rate is good
  ///
  /// In en, this message translates to:
  /// **'Low rate (under 5%) is excellent and shows consistent service.'**
  String get cancellationRateGood;

  /// When cancellation rate is bad
  ///
  /// In en, this message translates to:
  /// **'High rate (over 15%) raises concerns about reliability.'**
  String get cancellationRateBad;

  /// Button text for driver to mark arrival at customer location
  ///
  /// In en, this message translates to:
  /// **'I\'ve Arrived'**
  String get iHaveArrived;

  /// Status label when driver has arrived at delivery location
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get arrived;

  /// Notification/status text when driver has arrived
  ///
  /// In en, this message translates to:
  /// **'Driver Arrived'**
  String get driverArrived;

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
  /// **'No account found with this email. Please sign up first.'**
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
