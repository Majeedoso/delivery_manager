// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Delivery Driver';

  @override
  String get login => 'Login';

  @override
  String get signUp => 'Sign Up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get name => 'Name';

  @override
  String get phone => 'Phone';

  @override
  String get rememberMe => 'Remember Me';

  @override
  String get forgotPassword => 'Forgot Password';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get signUpWithGoogle => 'Sign up with Google';

  @override
  String get signUpWithEmail => 'Sign up with Email';

  @override
  String get createAccount => 'Create Account';

  @override
  String get checkingAuthentication => 'Checking authentication...';

  @override
  String get welcome => 'Welcome';

  @override
  String get logout => 'Logout';

  @override
  String get clearSavedCredentials => 'Clear Saved Credentials';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get french => 'French';

  @override
  String get or => 'OR';

  @override
  String get profile => 'Profile';

  @override
  String get profileInformation => 'Profile Information';

  @override
  String get userType => 'User Type';

  @override
  String get settings => 'Settings';

  @override
  String get appSettings => 'App Settings';

  @override
  String get deliveryPreferences => 'Delivery Preferences';

  @override
  String get deliveryPreferencesDescription => 'Choose which restaurants you want to deliver for';

  @override
  String get mutualSelected => 'Mutual';

  @override
  String get pendingSelected => 'Pending';

  @override
  String get selectAllRestaurants => 'Select All Restaurants';

  @override
  String get noSelectionAllRestaurantsHint => 'No selection means you will receive orders from all restaurants.';

  @override
  String selectedRestaurantsCount(int count, int total) {
    return '$count of $total selected';
  }

  @override
  String updatingSelections(int done, int total) {
    return 'Updating selections $done/$total...';
  }

  @override
  String get linkedRestaurants => 'Linked Restaurants';

  @override
  String get addRestaurantByCode => 'Add Restaurant by Code';

  @override
  String get restaurantCode => 'Restaurant Code';

  @override
  String get enterRestaurantCode => 'Enter restaurant code';

  @override
  String get linkRestaurant => 'Link';

  @override
  String get linkRestaurantSuccess => 'Linked successfully';

  @override
  String get unlinkRestaurant => 'Unlinked successfully';

  @override
  String get noLinkedRestaurants => 'No linked restaurants yet';

  @override
  String get noLinkedRestaurantsDescription => 'Add a restaurant code to start delivering for specific restaurants.';

  @override
  String get notifications => 'Notifications';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get pushNotificationsDescription => 'Receive push notifications';

  @override
  String get emailNotifications => 'Email Notifications';

  @override
  String get emailNotificationsDescription => 'Receive email notifications';

  @override
  String get privacy => 'Privacy';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get appInformation => 'App Information';

  @override
  String get version => 'Version';

  @override
  String get checkForUpdates => 'Check for Updates';

  @override
  String get aboutApp => 'About App';

  @override
  String get aboutDescription => 'This application is designed for delivery drivers to manage their deliveries efficiently. Drivers can view available orders, accept delivery requests, navigate to pickup and delivery locations, update delivery status in real-time, set their availability schedule, and track their earnings.';

  @override
  String get features => 'Features';

  @override
  String get userAuthentication => 'User Authentication';

  @override
  String get userAuthenticationDescription => 'Secure login and registration system';

  @override
  String get multiLanguageSupport => 'Multi-Language Support';

  @override
  String get multiLanguageSupportDescription => 'Support for multiple languages';

  @override
  String get secureStorage => 'Secure Storage';

  @override
  String get secureStorageDescription => 'Secure storage for sensitive data';

  @override
  String get googleSignIn => 'Google Sign-In';

  @override
  String get googleSignInDescription => 'Quick sign-in with Google account';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get copyright => '© 2024 Delivery Driver. All rights reserved.';

  @override
  String get website => 'Website';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get changePassword => 'Change Password';

  @override
  String get changeEmail => 'Change Email';

  @override
  String get updateProfile => 'Update Profile';

  @override
  String get main => 'Main';

  @override
  String get pendingOrders => 'Pending Orders';

  @override
  String get pendingOrdersDescription => 'Manage orders waiting for verification';

  @override
  String get acceptOrder => 'Accept Order';

  @override
  String get orderAcceptedSuccessfully => 'Order accepted successfully!';

  @override
  String get noOrdersAvailable => 'No orders available';

  @override
  String get checkBackLater => 'Check back later for new orders';

  @override
  String get refresh => 'Refresh';

  @override
  String get noDeliveryAddress => 'No delivery address';

  @override
  String get items => 'items';

  @override
  String get total => 'Total';

  @override
  String get deliveryFee => 'Delivery Fee';

  @override
  String get cash => 'Cash';

  @override
  String get card => 'Card';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get readyForPickup => 'Ready for Pickup';

  @override
  String get showMore => 'Show more';

  @override
  String get showLess => 'Show less';

  @override
  String get paymentMethod => 'Payment';

  @override
  String get deliveryNotes => 'Notes';

  @override
  String get ongoingOrders => 'Ongoing Orders';

  @override
  String get ongoingOrdersDescription => 'Manage your active deliveries';

  @override
  String get archiveOrders => 'Archive Orders';

  @override
  String get archiveOrdersDescription => 'View accepted and rejected orders';

  @override
  String get statistics => 'Statistics';

  @override
  String get statisticsDescription => 'View your performance metrics';

  @override
  String get noUserDataAvailable => 'No user data available';

  @override
  String get user => 'User';

  @override
  String get orders => 'Orders';

  @override
  String get archive => 'Archive';

  @override
  String get ordersArchive => 'Orders Archive';

  @override
  String get acceptedOrders => 'Accepted Orders';

  @override
  String get rejectedOrders => 'Rejected Orders';

  @override
  String get deliveredOrders => 'Delivered Orders';

  @override
  String get canceledOrders => 'Canceled Orders';

  @override
  String get delivered => 'Delivered';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetYourPassword => 'Reset Your Password';

  @override
  String get enterEmailDescription => 'Enter your email address and we\'ll send you an OTP code to reset your password.';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get enterOtpCode => 'Enter OTP Code';

  @override
  String get enterOtpDescription => 'Enter the 6-digit OTP sent to your email\nIt will be verified automatically when complete';

  @override
  String get setNewPassword => 'Set New Password';

  @override
  String get enterNewPasswordDescription => 'Enter your new password below';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmNewPassword => 'Confirm Password';

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String get verifyEmail => 'Verify Email';

  @override
  String get enterOtp => 'Enter OTP';

  @override
  String get otpSentTo => 'OTP sent to';

  @override
  String get verifyOtp => 'Verify OTP';

  @override
  String get confirmEmailChange => 'Confirm Email Change';

  @override
  String resendIn(int seconds) {
    return 'You can resend OTP in ${seconds}s';
  }

  @override
  String get emailNotVerified => 'Email Not Verified';

  @override
  String get emailVerificationRequired => 'Please verify your email address before accessing this resource. A verification code (OTP) has been sent to your email address. Please check your inbox and enter the 6-digit code to verify your email.';

  @override
  String get resendVerificationEmail => 'Resend Verification';

  @override
  String get verificationEmailSent => 'Verification email sent successfully. Please check your inbox.';

  @override
  String get checking => 'Checking...';

  @override
  String get checkStatus => 'Check Status';

  @override
  String get checkStatusDescription => 'Tap \"Check Status\" to see if your account has been approved';

  @override
  String get notificationsRequired => 'Notifications are required for this app';

  @override
  String get notificationsRequiredDescription => 'This app requires notification permission to receive new order alerts.';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get exitApp => 'Exit App';

  @override
  String get initializing => 'Initializing...';

  @override
  String get checkingNotifications => 'Checking notifications...';

  @override
  String get settingUpNotifications => 'Setting up notifications...';

  @override
  String get initializationFailed => 'Initialization failed';

  @override
  String get requestingPermission => 'Requesting permission...';

  @override
  String get permissionRequestFailed => 'Permission request failed';

  @override
  String get checkingInternet => 'Checking internet connection...';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String get noInternetDescription => 'Please check your internet connection and try again.';

  @override
  String get retry => 'Retry';

  @override
  String get updateRequired => 'Update Required';

  @override
  String get updateRequiredDescription => 'A new version of the app is available. Please update to continue using the app.';

  @override
  String get minimumRequiredVersion => 'Minimum Required Version';

  @override
  String get latestAvailableVersion => 'Latest Available Version';

  @override
  String get updateNow => 'Update Now';

  @override
  String get updateIsRequired => 'Update is required to continue';

  @override
  String get yourCurrentVersion => 'Your Current Version';

  @override
  String get updateAvailable => 'An update is available. Please update to continue using the app.';

  @override
  String get updateAvailableOptional => 'A new version is available. Update to get the latest features.';

  @override
  String get appUpToDate => 'Your app is up to date!';

  @override
  String get accountStatus => 'Account Status';

  @override
  String get areYouSureLogout => 'Are you sure you want to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get newEmailAddress => 'New Email Address';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newEmailMustBeDifferent => 'New email must be different from current email';

  @override
  String get day => 'day';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get year => 'Year';

  @override
  String get dateRange => 'Date Range';

  @override
  String get selectPeriod => 'Select Period';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get selectDate => 'Select date';

  @override
  String get errorLoadingStatistics => 'Error loading statistics';

  @override
  String get noStatisticsAvailable => 'No statistics available';

  @override
  String get overview => 'Overview';

  @override
  String get totalOrders => 'Total Orders';

  @override
  String get accepted => 'Accepted';

  @override
  String get pending => 'Pending';

  @override
  String get rejected => 'Rejected';

  @override
  String get performanceMetrics => 'Performance Metrics';

  @override
  String get averageRespondingTime => 'Average Responding Time';

  @override
  String get acceptedOrdersSuccessRate => 'Good Decisions Rate';

  @override
  String get acceptedOrdersSuccessRateExplanation => 'Measures how many accepted orders were successfully delivered. This is a positive metric that focuses on successes.';

  @override
  String get acceptedOrdersSuccessRateGood => 'High success rate means you\'re accepting orders you can fulfill reliably.';

  @override
  String get acceptedOrdersSuccessRateBad => 'Low success rate indicates issues with order fulfillment - review your capacity.';

  @override
  String get acceptedOrdersFailureRate => 'Bad Decisions Rate';

  @override
  String get acceptedOrdersFailureRateExplanation => 'Measures how many accepted orders failed for any reason (canceled, returned, refused by customer, not delivered). This is a negative metric that focuses on failures.';

  @override
  String get acceptedOrdersFailureRateGood => 'Low failure rate shows reliable order handling.';

  @override
  String get acceptedOrdersFailureRateBad => 'High failure rate damages reputation - consider why orders are failing.';

  @override
  String get averageRespondingTimeExplanation => 'Measures the average time it takes for the operator to respond to an order (accept or reject) after it\'s created.';

  @override
  String get averageRespondingTimeGood => 'Fast response times lead to better customer satisfaction and higher order acceptance.';

  @override
  String get averageRespondingTimeBad => 'Slow response times may result in cancelled orders and unhappy customers.';

  @override
  String get whenGood => 'When good';

  @override
  String get whenBad => 'When bad';

  @override
  String get close => 'Close';

  @override
  String get orderBreakdown => 'Order Breakdown';

  @override
  String get all => 'All';

  @override
  String get second => 'second';

  @override
  String get seconds => 'seconds';

  @override
  String get minute => 'minute';

  @override
  String get minutes => 'minutes';

  @override
  String get hour => 'hour';

  @override
  String get hours => 'hours';

  @override
  String get days => 'days';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetworkTimeout => 'Request timed out. Please check your internet connection and try again.';

  @override
  String get errorConnectionError => 'Cannot connect to server. Please check your internet connection and ensure the server is running.';

  @override
  String get errorRequestCancelled => 'Request was cancelled. Please try again.';

  @override
  String get errorNetworkGeneric => 'Network error occurred. Please check your internet connection and try again.';

  @override
  String get errorInvalidRequest => 'Invalid request. Please check your input and try again.';

  @override
  String get errorSessionExpired => 'Your session has expired. Please login again.';

  @override
  String get errorNoPermission => 'You do not have permission to perform this action.';

  @override
  String get errorNotFound => 'The requested resource was not found.';

  @override
  String get errorConflict => 'This action conflicts with the current state. Please refresh and try again.';

  @override
  String get errorValidation => 'Validation error. Please check your input.';

  @override
  String get errorTooManyRequests => 'Too many requests. Please wait a moment and try again.';

  @override
  String get errorServerUnavailable => 'Service temporarily unavailable. Please try again later.';

  @override
  String get errorServerGeneric => 'Server error occurred. Please try again later.';

  @override
  String get errorDatabaseLocal => 'Unable to save data locally. Please try again.';

  @override
  String get errorCacheLoad => 'Unable to load cached data. Please refresh.';

  @override
  String get errorAuthFailed => 'Authentication failed. Please check your credentials and try again.';

  @override
  String get errorInvalidCredentials => 'Invalid email or password. Please check your credentials and try again.';

  @override
  String get errorAuthRequired => 'Authentication required. Please login again.';

  @override
  String get errorSignInCancelled => 'Sign-in was cancelled.';

  @override
  String get errorServerMaintenance => 'Service is temporarily unavailable for maintenance. Please try again later.';

  @override
  String get errorDatabaseServer => 'Database error occurred. Please try again later.';

  @override
  String get errorLoadingOrders => 'Error loading orders';

  @override
  String get order => 'Order';

  @override
  String get customer => 'Customer';

  @override
  String get restaurant => 'Restaurant';

  @override
  String get description => 'Description';

  @override
  String get address => 'Address';

  @override
  String get isOpen => 'Is Open';

  @override
  String get restaurantAndNotes => 'Restaurant & Notes';

  @override
  String get notes => 'Notes';

  @override
  String get rejectionReason => 'Reason';

  @override
  String get deliveryInstructions => 'Delivery Instructions';

  @override
  String get confirm => 'Confirm';

  @override
  String get reject => 'Reject';

  @override
  String get startPreparing => 'Start Preparing';

  @override
  String get markReady => 'Mark Ready';

  @override
  String get pickedUp => 'Picked Up';

  @override
  String get markDelivered => 'Mark Delivered';

  @override
  String get loadMore => 'Load More';

  @override
  String get noPendingOrders => 'No Pending Orders';

  @override
  String get noPendingOrdersDescription => 'There are no pending orders in this date range.';

  @override
  String get noOngoingOrders => 'No Ongoing Orders';

  @override
  String get noOngoingOrdersDescription => 'There are no ongoing orders in this date range.';

  @override
  String get selectDeliveryMethod => 'Select Delivery Method';

  @override
  String get selfDelivery => 'Self Delivery';

  @override
  String get externalDelivery => 'External Delivery';

  @override
  String get selfDeliveryDescription => 'The restaurant will deliver the order with its own driver';

  @override
  String get externalDeliveryDescription => 'The order will be picked up by third-party drivers';

  @override
  String get pleaseSelectDeliveryMethod => 'Please select a delivery method before marking the order as ready';

  @override
  String get drivers => 'Drivers';

  @override
  String get addDriver => 'Add Driver';

  @override
  String get editDriver => 'Edit Driver';

  @override
  String get deleteDriver => 'Delete Driver';

  @override
  String get driverCode => 'Driver Code';

  @override
  String get driverCodeRequired => 'Driver code is required';

  @override
  String get noDriversAdded => 'No drivers added yet';

  @override
  String get pleaseAddDriverBeforeSelfDelivery => 'Please add a driver in your profile before choosing Self Delivery.';

  @override
  String get selectDriversForDelivery => 'Select Drivers for Delivery';

  @override
  String get selectAllDrivers => 'Select All Drivers';

  @override
  String get selectSpecificDrivers => 'Select Specific Drivers';

  @override
  String driverSelected(int count) {
    return '$count driver(s) selected';
  }

  @override
  String get driverCodeNotFound => 'Driver code not found. Please enter a valid driver code.';

  @override
  String get driverAlreadyLinked => 'This driver is already linked to your restaurant.';

  @override
  String get driverLinkedSuccessfully => 'Driver linked successfully!';

  @override
  String get requestTimeout => 'Request Timeout';

  @override
  String get requestTimeoutDescription => 'The request took too long to complete. Please check your internet connection and try again.';

  @override
  String get call => 'Call';

  @override
  String get failedToOpenPhoneApp => 'Failed to open phone app';

  @override
  String get errorMakingPhoneCall => 'Error making phone call';

  @override
  String get ordersLoadedSuccessfully => 'Orders loaded successfully';

  @override
  String get orderConfirmedSuccessfully => 'Order confirmed successfully';

  @override
  String get orderRejectedSuccessfully => 'Order rejected successfully';

  @override
  String get confirmOrder => 'Confirm';

  @override
  String get areYouSureConfirmOrder => 'Are you sure you want to confirm this order?';

  @override
  String get confirmOrderDescription => 'This will approve the order and make it visible to the restaurant.';

  @override
  String get pleaseSelectRejectReason => 'Please select a reason for rejecting this order:';

  @override
  String get enterYourReason => 'Enter your reason...';

  @override
  String get rejectReasonDidntPickUp => 'Didn\'t pick up the phone';

  @override
  String get rejectReasonSuspiciousBehavior => 'Suspicious customer behavior';

  @override
  String get rejectReasonInvalidAddress => 'Invalid delivery address';

  @override
  String get rejectReasonUnrealisticAmount => 'Order amount seems unrealistic';

  @override
  String get rejectReasonInvalidContact => 'Customer contact information invalid';

  @override
  String get rejectReasonRestaurantUnavailable => 'Restaurant not available';

  @override
  String get other => 'Other';

  @override
  String get currentPasswordRequired => 'Current password is required';

  @override
  String get newPasswordRequired => 'New password is required';

  @override
  String get passwordMinLength8 => 'Password must be at least 8 characters';

  @override
  String get passwordComplexity => 'Password must contain uppercase, lowercase, number, and symbol';

  @override
  String get pleaseConfirmNewPassword => 'Please confirm your new password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountConfirmation => 'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.\n\nYou will need to verify your identity with an OTP code sent to your email.';

  @override
  String get continueButton => 'Continue';

  @override
  String errorOpeningUrl(String error) {
    return 'Error opening URL: $error';
  }

  @override
  String get appStoreUrlNotConfigured => 'App Store URL is not configured. Please update the app manually from the App Store.';

  @override
  String unableToDetermineAppPackage(String store) {
    return 'Unable to determine app package. Please update the app manually from $store.';
  }

  @override
  String unableToOpenStore(String store) {
    return 'Unable to open $store. Please update the app manually.';
  }

  @override
  String errorOpeningAppStore(String error) {
    return 'Error opening app store: $error. Please update the app manually.';
  }

  @override
  String get emailVerifiedSuccessfully => 'Email verified successfully';

  @override
  String get failedToVerifyEmailOtp => 'Failed to verify email OTP';

  @override
  String get requestTimeoutCheckConnection => 'Request timeout. Please check your internet connection and try again.';

  @override
  String get cannotConnectToServer => 'Cannot connect to server. Please check your internet connection.';

  @override
  String get verificationOtpSentSuccessfully => 'Verification OTP sent successfully. Please check your email.';

  @override
  String get failedToResendVerificationOtp => 'Failed to resend verification OTP';

  @override
  String get emailChangeOtpSentSuccessfully => 'Email change OTP sent successfully. Please check your new email.';

  @override
  String get pleaseEnterValid6DigitOtp => 'Please enter a valid 6-digit OTP';

  @override
  String get failedToGetLegalUrls => 'Failed to get legal URLs';

  @override
  String get networkErrorCheckConnection => 'Network error. Please check your internet connection.';

  @override
  String get serverErrorOccurred => 'Server error occurred';

  @override
  String get failedToGetContactInformation => 'Failed to get contact information';

  @override
  String unexpectedErrorOccurred(String error) {
    return 'An unexpected error occurred: $error';
  }

  @override
  String get appStore => 'App Store';

  @override
  String get playStore => 'Play Store';

  @override
  String get urlNotAvailable => 'URL not available. Please try again later.';

  @override
  String get unableToOpenUrlTryAgain => 'Unable to open URL. Please try again.';

  @override
  String get unableToOpenUrlCheckConnection => 'Unable to open URL. Please check your internet connection.';

  @override
  String get anErrorOccurred => 'An error occurred';

  @override
  String get openingHours => 'Opening Hours';

  @override
  String get closed => 'Closed';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get open => 'Open';

  @override
  String get schedule => 'Schedule';

  @override
  String get restaurantIsOpen => 'Restaurant is currently open';

  @override
  String get restaurantIsClosed => 'Restaurant is currently closed';

  @override
  String get updateSchedule => 'Update Schedule';

  @override
  String get driverAvailability => 'Availability';

  @override
  String get driverIsAvailable => 'You are currently available for deliveries';

  @override
  String get driverIsUnavailable => 'You are currently unavailable for deliveries';

  @override
  String get unsavedChanges => 'Unsaved Changes';

  @override
  String get unsavedChangesMessage => 'You have unsaved changes. Do you want to save them or discard them?';

  @override
  String get save => 'Save';

  @override
  String get discard => 'Discard';

  @override
  String get selectLocationMethod => 'Select Location Method';

  @override
  String get manualEntry => 'Manual Entry';

  @override
  String get fromMap => 'From Map';

  @override
  String get selectLocationOnMap => 'Select Location on Map';

  @override
  String get selectLocation => 'Select Location';

  @override
  String get locationCoordinates => 'Location Coordinates';

  @override
  String get enterCoordinatesManually => 'Enter Coordinates Manually';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get latitudeRequired => 'Latitude is required';

  @override
  String get longitudeRequired => 'Longitude is required';

  @override
  String get invalidLatitude => 'Invalid latitude value';

  @override
  String get invalidLongitude => 'Invalid longitude value';

  @override
  String get latitudeRange => 'Latitude must be between -90 and 90';

  @override
  String get longitudeRange => 'Longitude must be between -180 and 180';

  @override
  String get menu => 'Menu';

  @override
  String get categories => 'Categories';

  @override
  String get menuItems => 'Menu Items';

  @override
  String get addCategory => 'Add Category';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get deleteCategory => 'Delete Category';

  @override
  String get addMenuItem => 'Add Menu Item';

  @override
  String get editMenuItem => 'Edit Menu Item';

  @override
  String get deleteMenuItem => 'Delete Menu Item';

  @override
  String get categoryName => 'Category Name';

  @override
  String get categoryDescription => 'Category Description';

  @override
  String get itemName => 'Item Name';

  @override
  String get itemDescription => 'Item Description';

  @override
  String get itemPrice => 'Price';

  @override
  String get preparationTime => 'Preparation Time';

  @override
  String get ingredients => 'Ingredients';

  @override
  String get allergens => 'Allergens';

  @override
  String get nutritionalInfo => 'Nutritional Information';

  @override
  String get image => 'Image';

  @override
  String get selectImage => 'Select Image';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get bulkActions => 'Bulk Actions';

  @override
  String get deleteSelected => 'Delete Selected';

  @override
  String get toggleAvailability => 'Toggle Availability';

  @override
  String get reorder => 'Reorder';

  @override
  String get dragToReorder => 'Drag to reorder';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get featured => 'Featured';

  @override
  String get available => 'Available';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get selected => 'Selected';

  @override
  String get makeUnavailable => 'Make Unavailable';

  @override
  String get makeAvailable => 'Make Available';

  @override
  String get remove => 'Remove';

  @override
  String get removeImage => 'Remove Image';

  @override
  String get areYouSureYouWantToRemoveThisImage => 'Are you sure you want to remove this image?';

  @override
  String get noCategories => 'No Categories';

  @override
  String get noCategoriesDescription => 'You haven\'t created any categories yet. Tap the + button to add one.';

  @override
  String get noMenuItems => 'No Menu Items';

  @override
  String get noMenuItemsDescription => 'This category doesn\'t have any items yet. Tap the + button to add one.';

  @override
  String get areYouSureDeleteCategory => 'Are you sure you want to delete this category?';

  @override
  String get areYouSureDeleteMenuItem => 'Are you sure you want to delete this menu item?';

  @override
  String areYouSureDeleteSelected(int count) {
    return 'Are you sure you want to delete $count selected item(s)?';
  }

  @override
  String categoryHasItems(int count) {
    return 'This category contains $count item(s). Please delete or move the items first.';
  }

  @override
  String get categoryNameRequired => 'Category name is required';

  @override
  String get itemNameRequired => 'Item name is required';

  @override
  String get priceRequired => 'Price is required';

  @override
  String get priceInvalid => 'Price must be greater than 0';

  @override
  String get preparationTimeRequired => 'Preparation time is required';

  @override
  String get preparationTimeInvalid => 'Preparation time must be at least 1 minute';

  @override
  String get categoryRequired => 'Category is required';

  @override
  String get addIngredient => 'Add Ingredient';

  @override
  String get addAllergen => 'Add Allergen';

  @override
  String get sortOrder => 'Sort Order';

  @override
  String get isActive => 'Is Active';

  @override
  String get isAvailable => 'Is Available';

  @override
  String get isFeatured => 'Is Featured';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get sortByName => 'Sort by Name';

  @override
  String get sortByPrice => 'Sort by Price';

  @override
  String get sortByOrder => 'Sort by Order';

  @override
  String get sortAscending => 'Ascending';

  @override
  String get sortDescending => 'Descending';

  @override
  String get minPrice => 'Min Price';

  @override
  String get maxPrice => 'Max Price';

  @override
  String get selectCategory => 'Select Category';

  @override
  String get categoryCreatedSuccessfully => 'Category created successfully';

  @override
  String get categoryUpdatedSuccessfully => 'Category updated successfully';

  @override
  String get categoryDeletedSuccessfully => 'Category deleted successfully';

  @override
  String get menuItemCreatedSuccessfully => 'Menu item created successfully';

  @override
  String get menuItemUpdatedSuccessfully => 'Menu item updated successfully';

  @override
  String get menuItemDeletedSuccessfully => 'Menu item deleted successfully';

  @override
  String get menuItemsUpdatedSuccessfully => 'Menu items updated successfully';

  @override
  String get menuItemsDeletedSuccessfully => 'Menu items deleted successfully';

  @override
  String get categoriesReorderedSuccessfully => 'Categories reordered successfully';

  @override
  String get menuItemsReorderedSuccessfully => 'Menu items reordered successfully';

  @override
  String get bank => 'Bank';

  @override
  String get totalExpected => 'Total Expected';

  @override
  String get driverDebts => 'Driver Debts';

  @override
  String get pendingPayments => 'Pending Payments';

  @override
  String get noPendingTransactions => 'No pending transactions';

  @override
  String get errorLoadingData => 'Error loading data';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get restaurantSystemManagerDebt => 'Restaurant System Manager Debt';

  @override
  String get restaurantDebtToSystem => 'The restaurant\'s debt to the system';

  @override
  String get restaurantSystemManagerDebtDescription => 'Amount restaurant owes to system manager (10% of order total)';

  @override
  String get amount => 'Amount';

  @override
  String get driver => 'Driver';

  @override
  String get expectedFromDrivers => 'Expected from Drivers';

  @override
  String get payToSystemAdministrator => 'Pay to System Administrator';

  @override
  String get transactions => 'Transactions';

  @override
  String get bankArchive => 'Bank Archive';

  @override
  String get createTransaction => 'Create Transaction';

  @override
  String get paySystem => 'Pay System';

  @override
  String get calculatingAmount => 'Calculating amount...';

  @override
  String get amountCalculated => 'Amount calculated';

  @override
  String get noAmountForRange => 'No amount due for the selected date range';

  @override
  String get amountFieldReadOnly => 'Amount is automatically calculated based on selected date range';

  @override
  String get pendingApprovals => 'Pending Approvals';

  @override
  String get myPendingTransactions => 'My Pending Transactions';

  @override
  String get transactionHistory => 'Transaction History';

  @override
  String get filterByType => 'Filter by Type';

  @override
  String get filterByDate => 'Filter by Date';

  @override
  String get waitingForApproval => 'Waiting for Approval';

  @override
  String get approvedBy => 'Approved by';

  @override
  String get rejectedBy => 'Rejected by';

  @override
  String get breakdownByDriver => 'Breakdown by Driver';

  @override
  String get breakdown => 'Breakdown';

  @override
  String get transactionType => 'Type';

  @override
  String get paymentToDriver => 'From Driver';

  @override
  String get paymentToSystem => 'Payment to System';

  @override
  String get selectDriver => 'Select Driver';

  @override
  String get enterAmount => 'Enter Amount';

  @override
  String get submit => 'Submit';

  @override
  String get approve => 'Approve';

  @override
  String get date => 'Date';

  @override
  String get status => 'Status';

  @override
  String get confirmCancellation => 'Confirm Cancellation';

  @override
  String get cancelTransactionConfirmation => 'Are you sure you want to cancel this transaction? This action cannot be undone.';

  @override
  String get no => 'No';

  @override
  String get yesCancel => 'Yes, Cancel';

  @override
  String get receivables => 'Credits';

  @override
  String get payables => 'Debts';

  @override
  String get receivablesAndPayables => 'Credits and Debts';

  @override
  String get newTransaction => 'New Transaction';

  @override
  String get pendingTransactions => 'Pending Transactions';

  @override
  String get transactionsHistory => 'Transaction History';

  @override
  String get ratings => 'Ratings';

  @override
  String get ratingsTitle => 'Customer Ratings';

  @override
  String get ratingsDetailTitle => 'Rating Details';

  @override
  String ratingsBasedOn(String count) {
    return 'Based on $count ratings';
  }

  @override
  String get ratingsAnonymous => 'Anonymous Customer';

  @override
  String get ratingsResponded => 'Responded';

  @override
  String get ratingsReplyNow => 'Reply Now';

  @override
  String get ratingsResponseSuccess => 'Response submitted successfully';

  @override
  String get ratingsOverallRating => 'Overall Rating';

  @override
  String get ratingsDate => 'Date';

  @override
  String get ratingsWouldReorder => 'Would Reorder';

  @override
  String get ratingsWouldRecommend => 'Would Recommend';

  @override
  String get ratingsDetailedRatings => 'Detailed Ratings';

  @override
  String get ratingsFoodQuality => 'Food Quality';

  @override
  String get ratingsDeliverySpeed => 'Delivery Speed';

  @override
  String get ratingsDriver => 'Driver';

  @override
  String get ratingsService => 'Service';

  @override
  String get ratingsComments => 'Comments';

  @override
  String get ratingsGeneralComment => 'General Comment';

  @override
  String get ratingsFoodComment => 'Food Comment';

  @override
  String get ratingsDeliveryComment => 'Delivery Comment';

  @override
  String get ratingsDriverComment => 'Driver Comment';

  @override
  String get ratingsRestaurantComment => 'Restaurant Comment';

  @override
  String get ratingsTags => 'Tags';

  @override
  String get ratingsYourResponse => 'Your Response';

  @override
  String get ratingsWriteResponse => 'Write a Response';

  @override
  String get ratingsResponseHint => 'Thank the customer or address their feedback...';

  @override
  String get ratingsResponseRequired => 'Please enter a response';

  @override
  String get ratingsResponseMinLength => 'Response must be at least 10 characters';

  @override
  String get ratingsSubmitResponse => 'Submit Response';

  @override
  String get ratingsEmptyTitle => 'No Ratings Yet';

  @override
  String get ratingsEmptyMessage => 'Customer ratings will appear here once you receive them.';

  @override
  String get ratingsLoadMore => 'Load More';

  @override
  String get ratingsFilterAll => 'All';

  @override
  String get ratingsFilterPositive => 'Positive';

  @override
  String get ratingsFilterNegative => 'Negative';

  @override
  String get orderCounts => 'Order Counts';

  @override
  String get performance => 'Performance';

  @override
  String get allTime => 'All Time';

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get thisYear => 'This Year';

  @override
  String get custom => 'Custom';

  @override
  String get responseSpeed => 'Response Speed';

  @override
  String get responseSpeedDescription => 'Time to accept or reject orders';

  @override
  String get preparationSpeed => 'Preparation Speed';

  @override
  String get preparationSpeedDescription => 'Time to prepare accepted orders';

  @override
  String get decisionQuality => 'Decision Quality';

  @override
  String get decisionQualityDescription => 'Rate of completed vs accepted orders';

  @override
  String get poorDecisions => 'Poor Decisions';

  @override
  String get poorDecisionsDescription => 'Rate of cancelled orders after acceptance';

  @override
  String get statisticsDataFrom => 'Data from';

  @override
  String get orderCapacity => 'Order Capacity';

  @override
  String canAcceptMoreOrders(int count) {
    return 'You can accept $count more order(s)';
  }

  @override
  String get maxCapacityReached => 'Maximum capacity reached';

  @override
  String get preparing => 'Preparing';

  @override
  String get onDelivery => 'On Delivery';

  @override
  String get noPreparingOrders => 'No orders being prepared';

  @override
  String get noPreparingOrdersDescription => 'Orders waiting for food preparation will appear here';

  @override
  String get noReadyOrders => 'No orders ready for pickup';

  @override
  String get noReadyOrdersDescription => 'Orders ready to be picked up will appear here';

  @override
  String get noDeliveringOrders => 'No orders on delivery';

  @override
  String get noDeliveringOrdersDescription => 'Orders you are delivering will appear here';

  @override
  String get markPickedUp => 'Mark as Picked Up';

  @override
  String get navigateToRestaurant => 'Navigate to Restaurant';

  @override
  String get navigateToCustomer => 'Navigate to Customer';

  @override
  String get rejectOrder => 'Reject Order';

  @override
  String get selectRejectionReason => 'Select a reason for rejection:';

  @override
  String get rejectionReasonTooFar => 'Too far from my location';

  @override
  String get rejectionReasonLowEarnings => 'Low earnings for this order';

  @override
  String get rejectionReasonBadArea => 'Delivery area is problematic';

  @override
  String get rejectionReasonBusy => 'Currently busy with other deliveries';

  @override
  String get rejectionReasonVehicleIssue => 'Vehicle/transportation issue';

  @override
  String get rejectionReasonPersonal => 'Personal reasons';

  @override
  String get rejectionReasonOther => 'Other';

  @override
  String get additionalNotes => 'Additional Notes (optional)';

  @override
  String get additionalNotesHint => 'Add any additional details...';

  @override
  String get confirmRejection => 'Reject';

  @override
  String get orderRejected => 'Order rejected';

  @override
  String get noRejectedOrders => 'No rejected orders';

  @override
  String get rejectedAt => 'Rejected at';

  @override
  String get unassignOrder => 'Unassign from Order';

  @override
  String get selectUnassignReason => 'Why can\'t you complete this order?';

  @override
  String get unassignReasonVehicleBreakdown => 'Vehicle breakdown';

  @override
  String get unassignReasonPersonalEmergency => 'Personal emergency';

  @override
  String get unassignReasonSafetyConcern => 'Safety concern at location';

  @override
  String get unassignReasonCannotReach => 'Cannot reach pickup/delivery location';

  @override
  String get unassignReasonLongWait => 'Restaurant wait time too long';

  @override
  String get unassignReasonOrderIssue => 'Issue with order (missing items, wrong order)';

  @override
  String get unassignReasonOther => 'Other reason';

  @override
  String get confirmUnassign => 'Unassign';

  @override
  String get orderUnassigned => 'Unassigned from order';

  @override
  String get unassignOnDeliveryWarning => 'Emergency only! Unassigning during delivery is serious and will be reviewed. Only use for genuine emergencies.';

  @override
  String get unassignReadyWarning => 'The food is ready and waiting. Unassigning now may affect food quality for the customer.';

  @override
  String get unassignEmergencyNotesHint => 'Please describe the emergency situation...';

  @override
  String get unassignConsequenceNotice => 'Frequent unassignments may affect your driver metrics. The order will be returned to the available pool.';

  @override
  String get cantCompleteOrder => 'Can\'t Complete';

  @override
  String get totalDebt => 'Total Debt';

  @override
  String get systemDebt => 'System';

  @override
  String get systemDebtDescription => 'Amount owed to system manager for delivery fees';

  @override
  String get restaurantDebts => 'Restaurants';

  @override
  String get restaurantCredits => 'Restaurants';

  @override
  String get recordPayment => 'Record Payment';

  @override
  String get recordSystemPayment => 'Record System Payment';

  @override
  String get paySystemDebt => 'Pay System Debt';

  @override
  String get paymentToRestaurant => 'Payment to Restaurant';

  @override
  String get noDebts => 'No Outstanding Debts';

  @override
  String get confirmedAt => 'Confirmed At';

  @override
  String get invalidAmount => 'Invalid amount';

  @override
  String get record => 'Record';

  @override
  String get noTransactionsFound => 'No Transactions Found';

  @override
  String get paymentType => 'Payment Type';

  @override
  String get selectRestaurant => 'Select Restaurant';

  @override
  String get paymentDate => 'Payment Date';

  @override
  String get totalCredits => 'Total Credits';

  @override
  String get overpay => 'Overpay';

  @override
  String get credit => 'Credit';

  @override
  String get pickupSpeed => 'Pickup Speed';

  @override
  String get pickupSpeedDescription => 'Time from food ready to pickup';

  @override
  String get pickupSpeedGood => 'Faster pickup (under 10 minutes) ensures fresh food and happy customers.';

  @override
  String get pickupSpeedBad => 'Slow pickup (over 20 minutes) may result in cold food and unhappy customers.';

  @override
  String get deliverySpeed => 'Delivery Speed';

  @override
  String get deliverySpeedDescription => 'Time from pickup to delivery';

  @override
  String get deliverySpeedGood => 'Fast delivery (under 20 minutes) leads to satisfied customers and better ratings.';

  @override
  String get deliverySpeedBad => 'Slow delivery (over 40 minutes) can result in complaints and lower ratings.';

  @override
  String get completionRate => 'Completion Rate';

  @override
  String get completionRateDescription => 'Percentage of accepted orders that were delivered';

  @override
  String get completionRateGood => 'High rate (95%+) shows reliability and professionalism.';

  @override
  String get completionRateBad => 'Low rate (below 85%) indicates issues with order handling.';

  @override
  String get cancellationRate => 'Cancellation Rate';

  @override
  String get cancellationRateDescription => 'Percentage of accepted orders that were cancelled';

  @override
  String get cancellationRateGood => 'Low rate (under 5%) is excellent and shows consistent service.';

  @override
  String get cancellationRateBad => 'High rate (over 15%) raises concerns about reliability.';

  @override
  String get iHaveArrived => 'I\'ve Arrived';

  @override
  String get arrived => 'Arrived';

  @override
  String get driverArrived => 'Driver Arrived';

  @override
  String get ok => 'OK';

  @override
  String get understood => 'Understood';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get wrongApp => 'Wrong App';

  @override
  String get accountNotFound => 'Account Not Found';

  @override
  String get accountNotFoundMessage => 'No account found with this email. Please sign up first.';

  @override
  String get loginFailed => 'Login Failed';

  @override
  String get invalidCredentialsMessage => 'The email or password you entered is incorrect. Please check your credentials and try again.';
}
