// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Manager App';

  @override
  String get login => 'Login';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get name => 'Name';

  @override
  String get phone => 'Phone';

  @override
  String get rememberMe => 'Remember Me';

  @override
  String get forgotPassword => 'Forgot Password';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get checkingAuthentication => 'Checking authentication...';

  @override
  String get logout => 'Logout';

  @override
  String get language => 'Language';

  @override
  String get or => 'OR';

  @override
  String get profile => 'Profile';

  @override
  String get userType => 'User Type';

  @override
  String get settings => 'Settings';

  @override
  String get appSettings => 'App Settings';

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
  String get aboutDescription => 'The Manager app gives you complete oversight of the entire delivery platform. Approve users, monitor performance, configure system settings, and manage coupons — all from a powerful admin dashboard.';

  @override
  String get features => 'Features';

  @override
  String get userAuthentication => 'User Management';

  @override
  String get userAuthenticationDescription => 'Approve drivers, restaurants, and operators, and manage account suspensions';

  @override
  String get multiLanguageSupport => 'Analytics & Reports';

  @override
  String get multiLanguageSupportDescription => 'Monitor revenue, order trends, and platform performance through detailed dashboards';

  @override
  String get secureStorage => 'System Settings';

  @override
  String get secureStorageDescription => 'Configure delivery fees, commission rates, and platform-wide operational rules';

  @override
  String get googleSignIn => 'Coupons';

  @override
  String get googleSignInDescription => 'Create coupons, set their limits and the zones where they apply';

  @override
  String get contactUs => 'Contact Us';

  @override
  String copyright(String year) {
    return '© $year Manager App. All rights reserved.';
  }

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
  String get refresh => 'Refresh';

  @override
  String get total => 'Total';

  @override
  String get deliveryFee => 'Delivery Fee';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get statistics => 'Statistics';

  @override
  String get statisticsMoney => 'Money';

  @override
  String get statisticsOrders => 'Orders';

  @override
  String get ordersPlaced => 'Orders';

  @override
  String get ordersPendingVerification => 'Pending Verification';

  @override
  String get ordersAcceptedByOperator => 'Accepted by Operator';

  @override
  String get ordersAcceptedByRestaurant => 'Accepted by Restaurant';

  @override
  String get ordersRejectedByOperator => 'Rejected by Operator';

  @override
  String get ordersRejectedByRestaurant => 'Rejected by Restaurant';

  @override
  String get ordersAcceptedByDriver => 'Accepted by Driver';

  @override
  String get ordersCancelled => 'Canceled';

  @override
  String get noUserDataAvailable => 'No user data available';

  @override
  String get user => 'User';

  @override
  String get delivered => 'Delivered';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetYourPassword => 'Reset Your Password';

  @override
  String get enterEmailDescription => 'Enter your email address and we\'ll send you an OTP code to reset your password.';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get sendOtp => 'Send OTP';

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
  String get checkStatus => 'Check Status';

  @override
  String get checkStatusDescription => 'Tap \"Check Status\" to see if your account has been approved';

  @override
  String get initializing => 'Initializing...';

  @override
  String get initializationFailed => 'Initialization failed';

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
  String get month => 'Month';

  @override
  String get year => 'Year';

  @override
  String get dateRange => 'Date Range';

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
  String get acceptedOrdersSuccessRateGood => 'High success rate means you\'re accepting orders you can fulfill reliably.';

  @override
  String get acceptedOrdersSuccessRateBad => 'Low success rate indicates issues with order fulfillment - review your capacity.';

  @override
  String get acceptedOrdersFailureRateGood => 'Low failure rate shows reliable order handling.';

  @override
  String get acceptedOrdersFailureRateBad => 'High failure rate damages reputation - consider why orders are failing.';

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
  String get all => 'All';

  @override
  String get second => 'second';

  @override
  String get seconds => 'seconds';

  @override
  String get minute => 'minute';

  @override
  String get hour => 'hour';

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
  String get customer => 'Customer';

  @override
  String get restaurant => 'Restaurant';

  @override
  String get description => 'Description';

  @override
  String get isOpen => 'Is Open';

  @override
  String get notes => 'Notes';

  @override
  String get rejectionReason => 'Reason';

  @override
  String get confirm => 'Confirm';

  @override
  String get loadMore => 'Load More';

  @override
  String get drivers => 'Drivers';

  @override
  String get call => 'Call';

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
  String get urlNotAvailable => 'URL not available. Please try again later.';

  @override
  String get closed => 'Closed';

  @override
  String get sunday => 'Sunday';

  @override
  String get open => 'Open';

  @override
  String get unsavedChanges => 'Unsaved Changes';

  @override
  String get unsavedChangesMessage => 'You have unsaved changes. Do you want to save them or discard them?';

  @override
  String get save => 'Save';

  @override
  String get discard => 'Discard';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get search => 'Search';

  @override
  String get active => 'Active';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get selected => 'Selected';

  @override
  String get remove => 'Remove';

  @override
  String get isActive => 'Is Active';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get bank => 'Bank';

  @override
  String get errorLoadingData => 'Error loading data';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get amount => 'Amount';

  @override
  String get driver => 'Driver';

  @override
  String get transactions => 'Transactions';

  @override
  String get bankArchive => 'Bank Archive';

  @override
  String get approvedBy => 'Approved by';

  @override
  String get transactionType => 'Type';

  @override
  String get selectDriver => 'Select Driver';

  @override
  String get date => 'Date';

  @override
  String get status => 'Status';

  @override
  String get receivables => 'Credits';

  @override
  String get payables => 'Debts';

  @override
  String get receivablesAndPayables => 'Credits and Debts';

  @override
  String get newTransaction => 'New Transaction';

  @override
  String get transactionsHistory => 'Transaction History';

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
  String get noDebts => 'No Outstanding Debts';

  @override
  String get confirmedAt => 'Confirmed At';

  @override
  String get invalidAmount => 'Invalid amount';

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
  String get pickupSpeed => 'Pickup Speed';

  @override
  String get pickupSpeedDescription => 'Time from food ready to pickup';

  @override
  String get completionRate => 'Completion Rate';

  @override
  String get cancellationRate => 'Cancellation Rate';

  @override
  String get cancellationRateDescription => 'Percentage of accepted orders that were cancelled';

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
  String get accountNotFoundMessage => 'No manager account uses this email. Manager accounts are created by the platform\'s team, not in the app.';

  @override
  String get loginFailed => 'Login Failed';

  @override
  String get invalidCredentialsMessage => 'The email or password you entered is incorrect. Please check your credentials and try again.';

  @override
  String get userManagement => 'User Management';

  @override
  String get errorLoadingUsers => 'Error Loading Users';

  @override
  String get noUsersFound => 'No Users Found';

  @override
  String get noUsersMatchFilters => 'No users match your filters';

  @override
  String get noUsersInSystem => 'No users in the system';

  @override
  String get userApprovedSuccessfully => 'User approved successfully';

  @override
  String get userRejectedSuccessfully => 'User rejected successfully';

  @override
  String get userSuspendedSuccessfully => 'User suspended successfully';

  @override
  String get userActivatedSuccessfully => 'User activated successfully';

  @override
  String get changeStatus => 'Change Status';

  @override
  String get pendingApproval => 'Pending Approval';

  @override
  String get suspended => 'Suspended';

  @override
  String get operator => 'Operator';

  @override
  String get manager => 'Manager';

  @override
  String get filters => 'Filters';

  @override
  String get clear => 'Clear';

  @override
  String get allRoles => 'All Roles';

  @override
  String get allStatuses => 'All Statuses';

  @override
  String get rejectUser => 'Reject User';

  @override
  String rejectingUser(String userName) {
    return 'Rejecting: $userName';
  }

  @override
  String get rejectionReasonLabel => 'Rejection Reason *';

  @override
  String get enterRejectionReason => 'Enter reason for rejection...';

  @override
  String get minimumCharacters => 'Minimum 10 characters';

  @override
  String get rejectionReasonRequired => 'Rejection reason is required';

  @override
  String get reasonMinimum10Characters => 'Reason must be at least 10 characters';

  @override
  String get suspendUser => 'Suspend User';

  @override
  String suspendingUser(String userName) {
    return 'Suspending: $userName';
  }

  @override
  String get suspensionReasonLabel => 'Suspension Reason *';

  @override
  String get enterSuspensionReason => 'Enter reason for suspension...';

  @override
  String get suspensionReasonRequired => 'Suspension reason is required';

  @override
  String get searchUsers => 'Search by name, email or phone';

  @override
  String get coupons => 'Coupons';

  @override
  String get restaurantCoupons => 'Restaurant Coupons';

  @override
  String get deliveryCoupons => 'Delivery Coupons';

  @override
  String get draft => 'Draft';

  @override
  String get disabled => 'Disabled';

  @override
  String get newDeliveryCoupon => 'New Delivery Coupon';

  @override
  String get newCoupon => 'New Coupon';

  @override
  String get noDeliveryCouponsYet => 'No delivery coupons yet';

  @override
  String get noCouponsYet => 'No coupons yet';

  @override
  String get createFirstDeliveryCoupon => 'Create your first delivery coupon!';

  @override
  String get createFirstCoupon => 'Create your first coupon to attract more customers!';

  @override
  String get off => 'OFF';

  @override
  String get discount => 'Discount';

  @override
  String get valid => 'Valid';

  @override
  String get uses => 'Uses';

  @override
  String get minOrder => 'Min Order';

  @override
  String get dzd => 'DZD';

  @override
  String get expired => 'Expired';

  @override
  String get globalAllRestaurants => 'Global (all restaurants)';

  @override
  String get issuer => 'Issuer: ';

  @override
  String get discardChanges => 'Discard Changes?';

  @override
  String get editCoupon => 'Edit Coupon';

  @override
  String get update => 'Update';

  @override
  String get create => 'Create';

  @override
  String get couponCode => 'Coupon Code';

  @override
  String get couponCodeHint => 'e.g. SUMMER20';

  @override
  String get pleaseEnterCouponCode => 'Please enter a coupon code';

  @override
  String get codeMinLength => 'Code must be at least 3 characters';

  @override
  String get type => 'Type';

  @override
  String get percentage => 'Percentage';

  @override
  String get fixedAmount => 'Fixed Amount';

  @override
  String get value => 'Value';

  @override
  String get required => 'Required';

  @override
  String get min1 => 'Min 1';

  @override
  String get max100Percent => 'Max 100%';

  @override
  String get discountAppliesTo => 'Discount Applies To';

  @override
  String get orderSubtotal => 'Order Subtotal';

  @override
  String get validityPeriod => 'Validity Period';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get restaurantOptional => 'Restaurant (Optional)';

  @override
  String get couponZonesOptional => 'Coupon Zones (Optional)';

  @override
  String get manageZones => 'Manage Zones';

  @override
  String get usageLimitsOptional => 'Usage Limits (Optional)';

  @override
  String get totalUses => 'Total uses';

  @override
  String get perCustomer => 'Per customer';

  @override
  String get orderConstraintsOptional => 'Order Constraints (Optional)';

  @override
  String get minOrderDzd => 'Min order (DZD)';

  @override
  String get maxDiscountDzd => 'Max discount (DZD)';

  @override
  String get descriptionOptional => 'Description (Optional)';

  @override
  String get internalNoteHint => 'Internal note about this coupon...';

  @override
  String get noCouponZonesAvailable => 'No coupon zones available. Create zones to restrict coupon availability.';

  @override
  String get selectZonesInfo => 'Select zones (applies to all if none selected)';

  @override
  String get noRestaurantsAvailable => 'No restaurants available. This coupon will be global.';

  @override
  String get selectedRestaurant => 'Selected Restaurant';

  @override
  String get allRestaurantsGlobal => 'All Restaurants (Global)';

  @override
  String get kmRadius => 'km radius';

  @override
  String get couponZones => 'Coupon Zones';

  @override
  String get addZone => 'Add Zone';

  @override
  String get success => 'Success!';

  @override
  String get errorOccurred => 'Error occurred';

  @override
  String get noCouponZonesYet => 'No coupon zones yet';

  @override
  String get createZonesToRestrict => 'Create zones to restrict coupons\\nto specific areas';

  @override
  String get createZone => 'Create Zone';

  @override
  String get editZone => 'Edit Zone';

  @override
  String get zoneNameRequired => 'Zone Name *';

  @override
  String get zoneNameHint => 'e.g., Downtown Area';

  @override
  String get optionalDescription => 'Optional description';

  @override
  String get latitudeHint => 'e.g., 36.7538';

  @override
  String get longitudeHint => 'e.g., 3.0588';

  @override
  String get radiusKm => 'Radius (km)';

  @override
  String get radiusHint => 'e.g., 5.0';

  @override
  String get km => 'km';

  @override
  String get zoneNameIsRequired => 'Zone name is required';

  @override
  String get deleteZone => 'Delete Zone';

  @override
  String deleteZoneConfirmation(Object zoneName) {
    return 'Are you sure you want to delete \"$zoneName\"?';
  }

  @override
  String get currency => 'DZD';

  @override
  String get revenueOverview => 'Overview';

  @override
  String get totalRevenue => 'Total Revenue';

  @override
  String get subtotalRevenue => 'Food Subtotal';

  @override
  String get deliveryFeesCollected => 'Delivery Fees';

  @override
  String get platformEarnings => 'Revenues';

  @override
  String get platformRevenue => 'Platform Revenue';

  @override
  String get platformShort => 'Platform';

  @override
  String get driverEarnings => 'Driver Earnings';

  @override
  String get driversShort => 'Drivers';

  @override
  String get restaurantEarnings => 'Restaurant Earnings';

  @override
  String get restaurantsShort => 'Restaurants';

  @override
  String get totalRevenueDesc => 'Total amount paid by customers for all delivered orders, including food cost and delivery fees.';

  @override
  String get subtotalRevenueDesc => 'The food cost total across all delivered orders, excluding delivery fees.';

  @override
  String get deliveryFeesDesc => 'Total delivery fees charged to customers across all delivered orders.';

  @override
  String get platformRevenueDesc => 'The platform\'s commission: a percentage taken from restaurant food orders and from driver delivery fees.';

  @override
  String get driversRevenueDesc => 'What drivers actually keep: delivery fees collected minus the platform\'s commission on deliveries.';

  @override
  String get restaurantsRevenueDesc => 'What restaurants actually keep: food order revenue minus the platform\'s commission on food orders.';

  @override
  String get restaurantEarningsSection => 'Earnings';

  @override
  String get restaurantNetEarnings => 'Net Earnings';

  @override
  String get driverEarningsSection => 'Earnings';

  @override
  String get driverNetEarnings => 'Net Earnings';

  @override
  String get averageOrderValueDesc => 'The average total amount (food + delivery) per delivered order in the selected period.';

  @override
  String get orderMetrics => 'Order Metrics';

  @override
  String get averageOrderValue => 'Average Order Value';

  @override
  String get statisticsRatings => 'Ratings';

  @override
  String get statisticsPerformance => 'Performance';

  @override
  String get deliveryPerformance => 'Delivery Performance';

  @override
  String get totalDeliveries => 'Total Deliveries';

  @override
  String get completedDeliveries => 'Completed Deliveries';

  @override
  String get cancelledDeliveries => 'Cancelled Deliveries';

  @override
  String get onTimeRate => 'On-Time Rate';

  @override
  String get avgDeliveryTime => 'Avg. Delivery Time';

  @override
  String get fastestDelivery => 'Fastest Delivery';

  @override
  String get slowestDelivery => 'Slowest Delivery';

  @override
  String get totalDeliveriesDesc => 'The total number of delivery orders in the selected period.';

  @override
  String get completedDeliveriesDesc => 'Orders that were successfully delivered to the customer.';

  @override
  String get cancelledDeliveriesDesc => 'Orders that were cancelled after being accepted.';

  @override
  String get completionRateDesc => 'Percentage of accepted orders that were successfully delivered.';

  @override
  String get avgDeliveryTimeDesc => 'Average time in minutes from order pickup to delivery.';

  @override
  String get onTimeRateDesc => 'Percentage of deliveries completed within the target time.';

  @override
  String get fastestDeliveryDesc => 'The shortest delivery time recorded in the selected period.';

  @override
  String get slowestDeliveryDesc => 'The longest delivery time recorded in the selected period.';

  @override
  String get minutesAbbr => 'min';

  @override
  String get averageRating => 'Average Rating';

  @override
  String get totalRatings => 'Total Ratings';

  @override
  String get ratingDistribution => 'Rating Distribution';

  @override
  String get foodQualityRating => 'Food Quality';

  @override
  String get restaurantServiceRating => 'Restaurant Service';

  @override
  String get deliverySpeedRating => 'Delivery Speed';

  @override
  String get reorderRate => 'Reorder Rate';

  @override
  String get recommendRate => 'Recommend Rate';

  @override
  String get outOf5 => 'out of 5';

  @override
  String get restaurantsTab => 'Restaurants';

  @override
  String get reviews => 'reviews';

  @override
  String get noRatingsYet => 'No ratings yet';

  @override
  String get driversTab => 'Drivers';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get failedToLoadSettings => 'Failed to load settings';

  @override
  String get noSettingsFound => 'No settings found';

  @override
  String get noSettingsInThisCategory => 'No settings in this category';

  @override
  String get settingUpdatedSuccessfully => 'Setting updated successfully';

  @override
  String get emptyInParentheses => '(empty)';

  @override
  String get currentValue => 'Current value';

  @override
  String get keyLabel => 'Key';

  @override
  String get editValue => 'Edit value';

  @override
  String get newValue => 'New value';

  @override
  String get invalidRouteArguments => 'Invalid route arguments';

  @override
  String get invalidAppVersionArgument => 'Invalid app version argument';

  @override
  String get globalCoupons => 'Global Coupons';

  @override
  String get enterVerificationCode => 'Enter Verification Code';

  @override
  String weSentVerificationCodeTo(Object email) {
    return 'We sent a verification code to $email';
  }

  @override
  String get confirmAccountDeletionCodeMessage => 'Please enter the code to confirm account deletion. This action cannot be undone.';

  @override
  String get unableToCheckForUpdates => 'Unable to check for updates. Please try again later.';

  @override
  String get accountPendingApprovalMessage => 'Your account is pending manager approval. Please wait for a manager to review and approve your account before you can access the system. You will be notified once your account is approved.';

  @override
  String get accountSuspendedMessage => 'Your account has been suspended. Please contact support for assistance.';

  @override
  String get accountRejectedMessage => 'Your account has been rejected. Please contact support for more information.';

  @override
  String balanceForPeriod(String period) {
    return '($period Balance)';
  }

  @override
  String get updateLinkUnavailable => 'The update can\'t be opened on this device. Please contact us to get the new version.';

  @override
  String get pageNotFound => 'Page Not Found';

  @override
  String get accountApprovedRedirectingMessage => 'Your account has been approved! Redirecting...';

  @override
  String get accountPendingApproval => 'Account Pending Approval';

  @override
  String get accountPendingApprovalFallbackMessage => 'Your account is pending manager approval. Please wait for a manager to review and approve your account before you can access the system.';

  @override
  String get accountRejected => 'Account Rejected';

  @override
  String get accountSuspended => 'Account Suspended';

  @override
  String get appFailedToInitializeProperly => 'The app failed to initialize properly.';

  @override
  String get pleaseConfirmYourPassword => 'Please confirm your password';

  @override
  String get nameIsRequired => 'Name is required';

  @override
  String get nameTooShort => 'Name must be at least 2 characters';

  @override
  String get phoneTooShort => 'Phone number must be at least 10 digits';

  @override
  String usesUnlimited(int count) {
    return '$count (unlimited)';
  }

  @override
  String get finalTotalGlobal => 'Final Total (Global)';

  @override
  String zonesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zones selected',
      one: '1 zone selected',
    );
    return '$_temp0';
  }

  @override
  String get settingsCategoryDelivery => 'Delivery';

  @override
  String get settingsCategoryFinancials => 'Financials';

  @override
  String get settingsCategoryCustomersOrders => 'Customers & Orders';

  @override
  String get settingsCategoryLoyaltyPromotions => 'Loyalty & Promotions';

  @override
  String get settingsCategoryAccountsSecurity => 'Accounts & Security';

  @override
  String get settingsCategoryApiIntegrations => 'API & Integrations';

  @override
  String get settingsCategoryLegalContact => 'Legal & Contact';

  @override
  String get settingTypeText => 'Text';

  @override
  String get settingTypeWhole => 'Whole number';

  @override
  String get settingTypeNumber => 'Number';

  @override
  String get settingTypeYesNo => 'Yes or no';

  @override
  String get settingTypeList => 'List (JSON)';

  @override
  String get settingSystemManagerOrderPercentageName => 'Commission on orders (%)';

  @override
  String get settingSystemManagerOrderPercentageRole => 'The platform\'s part of the food subtotal';

  @override
  String get settingSystemManagerOrderPercentageHelp => 'The percentage of every order\'s food subtotal that the platform keeps as its commission. For example, 10 means the platform earns 10 DZD for every 100 DZD of food ordered. When an order is delivered, the bank records it as owed by the restaurant to the platform (the driver owes the restaurant the whole food subtotal).';

  @override
  String get settingSystemManagerDeliveryFeePercentageName => 'Share of the delivery fee (%)';

  @override
  String get settingSystemManagerDeliveryFeePercentageRole => 'The platform\'s part of each delivery fee';

  @override
  String get settingSystemManagerDeliveryFeePercentageHelp => 'The percentage of the delivery fee that goes to the platform; the driver keeps the rest. For example, with 30 the platform keeps 30% of each delivery fee and the driver 70%. The bank applies it every time an order is delivered.';

  @override
  String get settingContactEmailName => 'Support email';

  @override
  String get settingContactEmailRole => 'Shown in every app';

  @override
  String get settingContactEmailHelp => 'Shown with the other contact details on the Contact and About pages of every app (customer, driver, restaurant, operator). Change it whenever your support address changes, so users always reach the right inbox.';

  @override
  String get settingContactPhoneName => 'Support phone';

  @override
  String get settingContactPhoneRole => 'Shown in every app';

  @override
  String get settingContactPhoneHelp => 'Shown on the Contact page of every app. The apps read it from the server, so a change here reaches every app at once, with no new app version.';

  @override
  String get settingContactWebsiteName => 'Website';

  @override
  String get settingContactWebsiteRole => 'Shown in every app';

  @override
  String get settingContactWebsiteHelp => 'The address of your platform\'s website, shown on the About and Contact pages of every app and opened in the phone\'s browser when tapped.';

  @override
  String get settingContactAddressName => 'Postal address';

  @override
  String get settingContactAddressRole => 'The company\'s address';

  @override
  String get settingContactAddressHelp => 'Your company\'s official address. It is printed in the contact part of the Privacy Policy and Terms of Service pages (in every language) and sent to the apps with the other contact details. Leave it empty to hide the address line.';

  @override
  String get settingMinimumDeliveryFeeName => 'Minimum delivery fee';

  @override
  String get settingMinimumDeliveryFeeRole => 'The least a delivery costs';

  @override
  String get settingMinimumDeliveryFeeHelp => 'The least a customer is ever charged for delivery, however close the restaurant is. For example, 50 means even a 300-metre order costs 50 DZD for delivery. Set 0 for no minimum: the formula\'s result is used as it is.';

  @override
  String get settingMaximumDeliveryFeeName => 'Maximum delivery fee';

  @override
  String get settingMaximumDeliveryFeeRole => 'The most a delivery costs';

  @override
  String get settingMaximumDeliveryFeeHelp => 'The most a customer can be charged for delivery, however far the restaurant is. For example, 500 means a 20 km order never costs more than 500 DZD for delivery. Set 0 for no maximum: the formula\'s result is used as it is.';

  @override
  String get settingMaxDriverConcurrentOrdersName => 'Orders a driver holds at once';

  @override
  String get settingMaxDriverConcurrentOrdersRole => 'The most active orders per driver';

  @override
  String get settingMaxDriverConcurrentOrdersHelp => 'The most active orders one driver can hold at the same time. Once a driver holds this many, no new order is offered to them until one is delivered or given back. Raise it for busy periods; lower it to keep deliveries short.';

  @override
  String get settingFixedDeliveryFeeName => 'Fixed delivery fee';

  @override
  String get settingFixedDeliveryFeeRole => 'The flat part of every delivery fee';

  @override
  String get settingFixedDeliveryFeeHelp => 'A flat amount in every delivery fee, whatever the distance: fee = fixed fee + (price per metre × distance in metres), then rounded and kept between the minimum and the maximum. Raising it raises what every customer pays for delivery.';

  @override
  String get settingPricePerMeterName => 'Price per metre';

  @override
  String get settingPricePerMeterRole => 'The distance part of the delivery fee';

  @override
  String get settingPricePerMeterHelp => 'What each metre of road between the restaurant and the delivery address adds to the fee. For example, 0.02 DZD per metre means a 5 km route adds 100 DZD to the fixed fee. The road distance comes from Mapbox or OpenRouteService.';

  @override
  String get settingMaxDeliveryDistanceKmName => 'Maximum delivery distance (km)';

  @override
  String get settingMaxDeliveryDistanceKmRole => 'How far a delivery can go';

  @override
  String get settingMaxDeliveryDistanceKmHelp => 'An order whose delivery address is farther than this many kilometres from the restaurant is refused when it is placed. It spares drivers very long trips and keeps delivery times predictable. Raise or lower it to widen or narrow your service area.';

  @override
  String get settingAverageCitySpeedKmhName => 'City speed (km/h)';

  @override
  String get settingAverageCitySpeedKmhRole => 'For the delivery time when no route is known';

  @override
  String get settingAverageCitySpeedKmhHelp => 'When neither Mapbox nor OpenRouteService answers, the distance is measured in a straight line and this speed gives the time the delivery takes through city streets. A usual value is 25 to 40 km/h, for traffic and stops.';

  @override
  String get settingAverageHighwaySpeedKmhName => 'Highway speed (km/h)';

  @override
  String get settingAverageHighwaySpeedKmhRole => 'For the long part of such a trip';

  @override
  String get settingAverageHighwaySpeedKmhHelp => 'Used with the city speed in that straight-line estimate: beyond the city-to-highway distance, the rest of the trip is counted at this faster speed. A usual value is 80 to 120 km/h.';

  @override
  String get settingCityHighwayTransitionKmName => 'City-to-highway distance (km)';

  @override
  String get settingCityHighwayTransitionKmRole => 'Where the city speed stops';

  @override
  String get settingCityHighwayTransitionKmHelp => 'In that straight-line estimate, a trip shorter than this is counted entirely at city speed; the kilometres beyond it at highway speed. For example, 5 means the first 5 km at city speed and the rest at highway speed.';

  @override
  String get settingCurrencyName => 'Currency';

  @override
  String get settingCurrencyRole => 'The platform\'s currency code';

  @override
  String get settingCurrencyHelp => 'The ISO 4217 code of the currency of every amount on the platform: order totals, delivery fees, earnings, notifications. For example, \"DZD\" for the Algerian dinar. The server writes it after amounts and sends it to every app.';

  @override
  String get settingBirthdayGiftEnabledName => 'Birthday gift';

  @override
  String get settingBirthdayGiftEnabledRole => 'On or off';

  @override
  String get settingBirthdayGiftEnabledHelp => 'When true (or 1), a customer who orders on their birthday gets that order paid for, up to the birthday gift cap, once a year. When false (or 0), there is no birthday gift. It turns the promotion on or off without touching the code.';

  @override
  String get settingBirthdayGiftCapName => 'Birthday gift cap (DZD)';

  @override
  String get settingBirthdayGiftCapRole => 'The most a birthday gift covers';

  @override
  String get settingBirthdayGiftCapHelp => 'The most a birthday gift covers, in the platform\'s currency. For example, with a cap of 500, a 700 DZD birthday order is reduced by 500 DZD. It keeps the gift reasonable on large orders.';

  @override
  String get settingCustomerRestaurantRadiusKmName => 'Restaurant search radius (km)';

  @override
  String get settingCustomerRestaurantRadiusKmRole => 'Which restaurants a customer sees';

  @override
  String get settingCustomerRestaurantRadiusKmHelp => 'A customer is shown the restaurants within this many kilometres of where they are. A larger radius shows more choice, but may include restaurants too far to deliver in good time.';

  @override
  String get settingCustomerRestaurantPrefilterRadiusKmName => 'Search pre-filter radius (km)';

  @override
  String get settingCustomerRestaurantPrefilterRadiusKmRole => 'A first, quicker sorting of the restaurants';

  @override
  String get settingCustomerRestaurantPrefilterRadiusKmHelp => 'Before the exact distance check, the database keeps only the restaurants within this larger radius, which is quicker. It must be at least the restaurant search radius: smaller, it would leave out nearby restaurants; much larger, it only makes the search slower.';

  @override
  String get settingPrivacyPolicyUrlName => 'Privacy Policy link';

  @override
  String get settingPrivacyPolicyUrlRole => 'Shown in every app';

  @override
  String get settingPrivacyPolicyUrlHelp => 'Opened in the phone\'s browser when someone taps \"Privacy Policy\" in any app. Change it here whenever you publish a new version of your policy: no app update is needed.';

  @override
  String get settingTermsOfServiceUrlName => 'Terms of Service link';

  @override
  String get settingTermsOfServiceUrlRole => 'Shown in every app';

  @override
  String get settingTermsOfServiceUrlHelp => 'Opened in the phone\'s browser when someone taps \"Terms of Service\" in any app. Change it here whenever you revise your terms: no app update is needed.';

  @override
  String get settingMinOrderSchedulingMinutesName => 'Scheduling notice (minutes)';

  @override
  String get settingMinOrderSchedulingMinutesRole => 'How far ahead an order is scheduled';

  @override
  String get settingMinOrderSchedulingMinutesHelp => 'A customer scheduling an order must pick a time at least this many minutes ahead. For example, 30 means no order can be scheduled for the next 30 minutes. It gives restaurants and drivers enough time to get ready.';

  @override
  String get settingNumberOfOrdersToBeTrustedName => 'Orders to become trusted';

  @override
  String get settingNumberOfOrdersToBeTrustedRole => 'When an operator stops checking a customer\'s orders';

  @override
  String get settingNumberOfOrdersToBeTrustedHelp => 'A new customer\'s orders are checked by an operator before they reach the restaurant. Once a customer has this many delivered orders, they become \"trusted\" and their next orders go straight to the restaurant. Lower it to trust sooner; raise it for more checking.';

  @override
  String get settingOtpValidityMinutesName => 'Code validity (minutes)';

  @override
  String get settingOtpValidityMinutesRole => 'How long an emailed code works';

  @override
  String get settingOtpValidityMinutesHelp => 'Codes are emailed to reset a password, verify or change an email address and confirm an account deletion. A code works for this many minutes after it is sent, and the email says so. Shorter is safer; longer is kinder to slow mailboxes.';

  @override
  String get settingOtpResendWaitSecondsName => 'Wait before a new code (seconds)';

  @override
  String get settingOtpResendWaitSecondsRole => 'Between two emailed codes';

  @override
  String get settingOtpResendWaitSecondsHelp => 'After a code is emailed, a new one can be asked for only after this many seconds; the apps show the countdown. It limits the emails sent to one address.';

  @override
  String get settingMaxSavedAddressesName => 'Saved addresses per customer';

  @override
  String get settingMaxSavedAddressesRole => 'How many addresses a customer keeps';

  @override
  String get settingMaxSavedAddressesHelp => 'The most delivery addresses one customer can keep in the app. One more is refused with a message.';

  @override
  String get settingMaxItemsPerOrderName => 'Dishes per order';

  @override
  String get settingMaxItemsPerOrderRole => 'Different dishes in one order';

  @override
  String get settingMaxItemsPerOrderHelp => 'An order with more different dishes than this is refused. It keeps one order to what a kitchen and a driver can handle at once.';

  @override
  String get settingMaxQuantityPerItemName => 'Portions per dish';

  @override
  String get settingMaxQuantityPerItemRole => 'Portions of one dish in one order';

  @override
  String get settingMaxQuantityPerItemHelp => 'The largest quantity of one dish a customer can order. A larger quantity is refused with a message.';

  @override
  String get settingAmountRoundingStepName => 'Rounding step (DZD)';

  @override
  String get settingAmountRoundingStepRole => 'Rounding of delivery fees and coupon discounts';

  @override
  String get settingAmountRoundingStepHelp => 'Delivery fees are rounded up, and coupon discounts down, to a multiple of this amount. With 5, a fee of 162 DZD becomes 165 and a discount of 312 DZD becomes 310. Set 1 to stop rounding.';

  @override
  String get settingLoyaltyCouponValidityDaysName => 'Loyalty coupon validity (days)';

  @override
  String get settingLoyaltyCouponValidityDaysRole => 'How long a loyalty coupon can be used';

  @override
  String get settingLoyaltyCouponValidityDaysHelp => 'A coupon obtained with loyalty points can be used for this many days. The customer app shows the number before the points are spent.';

  @override
  String get settingDefaultDeliveryTimeMinutesName => 'Default delivery time (minutes)';

  @override
  String get settingDefaultDeliveryTimeMinutesRole => 'When the route is unknown';

  @override
  String get settingDefaultDeliveryTimeMinutesHelp => 'When the road route to a customer can\'t be computed (no position yet, or no routing service), this many minutes is shown and used as the delivery time.';

  @override
  String get settingRouteCacheMinutesName => 'Road distance kept (minutes)';

  @override
  String get settingRouteCacheMinutesRole => 'How long a computed distance is reused';

  @override
  String get settingRouteCacheMinutesHelp => 'The road distance between a restaurant and a delivery spot is kept this many minutes instead of being asked again. The fee charged is then the fee shown, and fewer routing requests are made. Lower it only if roads change very often.';

  @override
  String get settingMapDefaultLatitudeName => 'Map centre: latitude';

  @override
  String get settingMapDefaultLatitudeRole => 'Where the apps\' map opens';

  @override
  String get settingMapDefaultLatitudeHelp => 'When someone opens the map to pick a place and no position is known yet, the map opens here. Set it, with the longitude, to the centre of your service area. A value between -90 and 90.';

  @override
  String get settingMapDefaultLongitudeName => 'Map centre: longitude';

  @override
  String get settingMapDefaultLongitudeRole => 'Where the apps\' map opens';

  @override
  String get settingMapDefaultLongitudeHelp => 'The longitude that goes with the map centre\'s latitude: the centre of your service area. A value between -180 and 180.';

  @override
  String get settingAppMapboxAccessTokenName => 'Map token (Mapbox)';

  @override
  String get settingAppMapboxAccessTokenRole => 'Draws the maps in the apps';

  @override
  String get settingAppMapboxAccessTokenHelp => 'The Mapbox public token (it starts with \"pk.\") the customer, driver, restaurant and manager apps draw their maps with. The apps read it from the server, so replacing it here needs no new app version. A secret token (\"sk.\") is refused: this one is handed to every app. The keys the server measures road distances with are not here: they are secrets, kept in the server\'s .env file.';

  @override
  String get settingLocalTimezoneName => 'Time zone';

  @override
  String get settingLocalTimezoneRole => 'Of the restaurants\' opening hours';

  @override
  String get settingLocalTimezoneHelp => 'Restaurants enter their opening hours as local times, for example 11:00 to 23:00. This is the time zone those hours are read in when the platform decides whether a restaurant is open. Use a standard name such as \"Africa/Algiers\"; anything else is refused.';

  @override
  String get settingBestSellerCountName => 'Best sellers per restaurant';

  @override
  String get settingBestSellerCountRole => 'How many dishes get the badge';

  @override
  String get settingBestSellerCountHelp => 'In the customer app, a restaurant\'s most ordered dishes carry a \"Best seller\" badge. This is how many of its dishes get it: those in the most delivered orders. Set 0 to show no badge.';

  @override
  String get settingBestSellerDaysName => 'Best seller period (days)';

  @override
  String get settingBestSellerDaysRole => 'The days the badge looks back on';

  @override
  String get settingBestSellerDaysHelp => 'Only orders delivered within this many past days count for the badge, so it follows what customers order now. For example, 30 means the last month of delivered orders.';

  @override
  String get settingBestSellerMinOrdersName => 'Orders to be a best seller';

  @override
  String get settingBestSellerMinOrdersRole => 'The least a dish needs for the badge';

  @override
  String get settingBestSellerMinOrdersHelp => 'A dish gets the badge only if it was in at least this many delivered orders during that period. A new restaurant with few orders shows no badge until its dishes reach this number.';

  @override
  String get settingLoyaltyEnabledName => 'Loyalty points';

  @override
  String get settingLoyaltyEnabledRole => 'On or off';

  @override
  String get settingLoyaltyEnabledHelp => 'When true, customers earn points on every delivered order and can spend them on discount coupons. When false, no point is earned and none can be spent; the balances already earned are kept. It pauses the loyalty programme without losing anything.';

  @override
  String get settingLoyaltyEarnRateName => 'Points earned per DZD';

  @override
  String get settingLoyaltyEarnRateRole => 'What an order earns';

  @override
  String get settingLoyaltyEarnRateHelp => 'The loyalty points a customer receives for each dinar paid for a delivered order (its total, delivery included, after discounts). For example, 0.1 means a 1000 DZD order earns 100 points. A higher rate makes the programme more rewarding; a lower one costs the platform less.';

  @override
  String get settingLoyaltyRedeemRateName => 'DZD per point spent';

  @override
  String get settingLoyaltyRedeemRateRole => 'What a point is worth';

  @override
  String get settingLoyaltyRedeemRateHelp => 'What one loyalty point is worth when a customer spends it on a coupon. For example, 0.5 means 200 points make a 100 DZD coupon. It sets the real cost of the programme: lower protects margins, higher attracts more customers to spend their points.';

  @override
  String get settingLoyaltyMinRedeemPointsName => 'Minimum points to spend';

  @override
  String get settingLoyaltyMinRedeemPointsRole => 'The least a customer spends at once';

  @override
  String get settingLoyaltyMinRedeemPointsHelp => 'A customer can\'t spend fewer points than this at once. A floor (for example 100 points) avoids tiny coupons and lets customers build up a real balance first.';

  @override
  String get settingLoyaltyTiersName => 'Redemption tiers';

  @override
  String get settingLoyaltyTiersRole => 'The point amounts a customer can spend';

  @override
  String get settingLoyaltyTiersHelp => 'The exact point amounts a customer can spend at once, as a JSON list of whole numbers, for example [100, 500, 1000, 2000]. The customer app offers only these. Each should be at least the minimum points to spend.';

  @override
  String get settingMaxCouponsPerCategoryName => 'Coupons of one kind per order';

  @override
  String get settingMaxCouponsPerCategoryRole => 'Stacking coupons of the same kind';

  @override
  String get settingMaxCouponsPerCategoryHelp => 'The most coupons of the same kind (restaurant, delivery or global) one order can use. With 1, a customer can\'t put two restaurant coupons on one order. Loyalty coupons count as restaurant coupons. Raise it to let coupons of the same kind be combined.';

  @override
  String get settingMaxCouponCategoriesName => 'Kinds of coupon per order';

  @override
  String get settingMaxCouponCategoriesRole => 'Combining different kinds of coupon';

  @override
  String get settingMaxCouponCategoriesHelp => 'The most different kinds of coupon (restaurant, delivery, global) one order can use together. For example, 2 means an order can combine at most two kinds, such as a restaurant coupon and a delivery coupon. With 3, all three can be used together.';

  @override
  String confirmPaymentReceived(String amount, String payer) {
    return 'Did you receive $amount from $payer?';
  }

  @override
  String get paymentRecordedNotice => 'Payment recorded';

  @override
  String get refusedAt => 'Refused At';

  @override
  String get paymentWaitingForAnswer => 'A payment they sent from their app is waiting for your answer in the transaction history: it is not counted yet.';

  @override
  String get reasonLoyaltyCouponCredit => 'Loyalty Coupon Credit';

  @override
  String get reject => 'Reject';

  @override
  String paymentNote(String note) {
    return 'Note: $note';
  }

  @override
  String paymentAnswer(String note) {
    return 'Answer: $note';
  }

  @override
  String get paymentConfirmedNotice => 'Payment confirmed';

  @override
  String get paymentRefusedNotice => 'Payment refused';

  @override
  String get refusePaymentTitle => 'Refuse this payment?';

  @override
  String get refusePaymentReasonHint => 'Why? (e.g. not received)';

  @override
  String get confirmPaymentReceivedTitle => 'Payment received?';

  @override
  String get creditDetails => 'Credit Details';

  @override
  String get debtDetails => 'Debt Details';

  @override
  String get orderSettlements => 'Order Settlements';

  @override
  String get cashTransactions => 'Cash Transactions';

  @override
  String get noTransactionsInPeriod => 'No transactions in selected date range';

  @override
  String get receivedPayment => 'Received Payment';

  @override
  String get sentPayment => 'Sent Payment';

  @override
  String get totalOrderSettlements => 'Total Order Settlements';

  @override
  String get totalCashOutgoing => 'Total Cash Outgoing';

  @override
  String get totalCashIncoming => 'Total Cash Incoming';

  @override
  String get netBalance => 'Net Balance';

  @override
  String get paidTowardsOrders => 'Paid towards these orders';

  @override
  String get cashPaidInTheseDays => 'Cash paid in these days';

  @override
  String get cashReceivedInTheseDays => 'Cash received in these days';

  @override
  String get reasonOvercharge => 'Overcharge';

  @override
  String get reasonOrderSettlement => 'Order Settlement';

  @override
  String get reasonCouponCredit => 'Coupon Credit';

  @override
  String get reasonGlobalCouponCredit => 'Global Coupon Credit';

  @override
  String get reasonBirthdayCredit => 'Birthday Gift Credit';

  @override
  String get deliveryAreas => 'Delivery Zones';

  @override
  String get deliveryAreasHelp => 'Customers can order only at a door inside a zone that is on.';

  @override
  String get noDeliveryAreasYet => 'No delivery zone yet: no customer can order.';

  @override
  String get addDeliveryArea => 'Add a delivery zone';

  @override
  String get editDeliveryArea => 'Edit the delivery zone';

  @override
  String get deliveryAreaOn => 'On: customers can order there';

  @override
  String get deliveryAreaOff => 'Off: no customer can order there';

  @override
  String get deleteDeliveryArea => 'Delete the delivery zone';

  @override
  String deleteDeliveryAreaConfirmation(String name) {
    return 'Delete $name? Customers there will no longer be able to order.';
  }

  @override
  String get coordinatesInvalid => 'Latitude from -90 to 90, longitude from -180 to 180';

  @override
  String get radiusOutOfRange => 'The radius goes from 0.1 to 100 km';

  @override
  String get payFromPlatform => 'Pay from the platform';

  @override
  String platformPaymentTitle(String name) {
    return 'A payment from the platform to $name';
  }

  @override
  String get platformPaymentHelp => 'It counts at once, and they are told. Paying more than is owed makes the difference their debt to the platform.';

  @override
  String get platformPaymentRecorded => 'Payment from the platform recorded';

  @override
  String get paidByThePlatform => 'Paid by the platform';

  @override
  String get paidBeyondWhatWasOwed => 'Paid beyond what was owed';
}
