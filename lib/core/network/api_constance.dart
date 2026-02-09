import 'package:delivery_manager/core/config/app_config.dart';

class ApiConstance {
  static String get baseUrl => AppConfig.baseUrl;
  //  static const String baseUrl = "http://192.168.1.38:8001/api";

  // Auth endpoints (relative paths - Dio has baseUrl configured)
  static const String registerPath = "/auth/register";
  static const String loginPath = "/auth/login";
  static const String logoutPath = "/auth/logout";
  static const String userPath = "/auth/user";
  static const String googleSignInPath = "/auth/google/login";
  static const String googleSignUpPath = "/auth/google/signup";
  static const String changePasswordPath = "/auth/change-password";
  static const String changeEmailPath = "/auth/change-email";
  static const String updateFcmTokenEndpoint = "/auth/update-fcm-token";
  static const String resendVerificationEmailPath = "/auth/email/resend";
  static const String verifyEmailOtpPath = "/auth/email/verify-email-otp";
  // Password reset endpoints (unauthenticated - from login page)
  static const String sendPasswordResetOtpUnauthenticatedPath =
      "/auth/password/forgot-password";
  static const String verifyPasswordResetOtpUnauthenticatedPath =
      "/auth/password/verify-otp-unauthenticated";
  static const String resetPasswordUnauthenticatedPath =
      "/auth/password/reset-password-unauthenticated";

  // Password reset endpoints (authenticated - from profile page)
  static const String sendPasswordResetOtpAuthenticatedPath =
      "/auth/password/resend-reset-otp-authenticated";
  static const String verifyPasswordResetOtpAuthenticatedPath =
      "/auth/password/verify-otp-authenticated";
  static const String resetPasswordAuthenticatedPath =
      "/auth/password/reset-password-authenticated";

  // Legacy names for backward compatibility (deprecated - use specific paths above)
  static const String verifyOtpPath = verifyPasswordResetOtpUnauthenticatedPath;
  static const String resetPasswordPath = resetPasswordUnauthenticatedPath;
  static const String forgotPasswordPath =
      sendPasswordResetOtpUnauthenticatedPath;
  static const String sendPasswordResetOtpPath =
      sendPasswordResetOtpAuthenticatedPath;
  static const String verifyPasswordResetOtpOnlyPath =
      verifyPasswordResetOtpAuthenticatedPath;
  static const String verifyPasswordResetOtpPath =
      resetPasswordAuthenticatedPath;

  static const String confirmEmailChangePath = "/auth/email/confirm-change";
  static const String sendDeleteAccountOtpPath =
      "/auth/account/delete/send-otp";
  static const String verifyDeleteAccountOtpPath =
      "/auth/account/delete/verify-otp";

  // App version endpoint
  static const String appVersionPath = "/app/version";

  // App config endpoints
  static const String legalUrlsPath = "/app/legal-urls";
  static const String contactInfoPath = "/app/contact-info";

  // Profile endpoints (User profile - for editing name, phone)
  static const String getProfilePath = "/auth/user";
  static const String updateProfilePath =
      "/auth/user"; // User profile update endpoint

  // Restaurant Profile endpoints
  static const String getRestaurantProfilePath = "/restaurant/profile";
  static const String updateRestaurantProfilePath = "/restaurant/profile";

  // Order endpoints
  static const String ordersPath = "/restaurant/orders";
  static const String pendingOrdersCountPath =
      "/restaurant/orders/pending/count";
  static const String ongoingOrdersCountPath =
      "/restaurant/orders/ongoing/count";
  static const String acceptedOrdersPath = "/restaurant/orders/accepted";
  static const String rejectedOrdersPath = "/restaurant/orders/rejected";
  static String orderByIdPath(int id) => "/restaurant/orders/$id";
  static String updateOrderStatusPath(int orderId) =>
      "/restaurant/orders/$orderId/status";

  // Menu endpoints
  static const String categoriesPath = "/restaurant/categories";
  static String categoryByIdPath(int id) => "/restaurant/categories/$id";
  static const String menuItemsPath = "/restaurant/menu-items";
  static String menuItemByIdPath(int id) => "/restaurant/menu-items/$id";

  // Driver endpoints
  static const String restaurantDriversPath = "/restaurant/drivers";
  static String restaurantDriverByIdPath(int driverId) =>
      "/restaurant/drivers/$driverId";
  static const String restaurantDriversAllPath = "/restaurant/drivers/all";
  static const String restaurantDriversLinkByIdPath =
      "/restaurant/drivers/link-by-id";

  // Bank endpoints
  static const String restaurantBalancePath = "/restaurant/balance";
  static String confirmPaymentPath(int transactionId) =>
      "/restaurant/payments/$transactionId/confirm";
  static const String restaurantTransactionsPath = "/restaurant/transactions";
  static const String systemPaymentAmountPath =
      "/restaurant/system-payment-amount";

  // Statistics endpoints
  static const String restaurantStatisticsPath = "/restaurant/statistics";

  // Driver schedule endpoints
  static const String driverSchedulePath = "/driver/schedule";

  // Ratings endpoints
  static const String restaurantRatingsPath = "/restaurant/ratings";
  static String respondToRatingPath(int ratingId) =>
      "/restaurant/ratings/$ratingId/respond";

  // Driver orders endpoints
  static const String availableOrdersPath = "/driver/orders/available";
  static const String availableOrdersCountPath =
      "/driver/orders/available/count";
  static const String driverCapacityPath = "/driver/orders/capacity";
  static const String driverActiveOrdersPath = "/driver/orders/active";
  static const String acceptOrderPath = "/driver/orders";
  static String driverOrderStatusPath(int orderId) =>
      "/driver/orders/$orderId/status";

  // Driver history endpoint for archive orders
  static const String driverHistoryPath = "/driver/history";

  // Driver order rejection
  static String rejectOrderPath(int orderId) =>
      "/driver/orders/$orderId/reject";
  static const String driverRejectedOrdersPath = "/driver/rejected-orders";

  // Driver order unassignment (for accepted orders)
  static String unassignOrderPath(int orderId) =>
      "/driver/orders/$orderId/unassign";
  static const String driverUnassignedOrdersPath = "/driver/unassigned-orders";

  // Driver restaurant linking endpoints
  static const String driverLinkedRestaurantsPath = "/driver/restaurants";
  static const String driverBrowseRestaurantsPath =
      "/driver/restaurants/browse";
  static const String driverAllRestaurantsPath = "/driver/restaurants/all";
  static const String linkRestaurantByIdPath =
      "/driver/restaurants/link-by-id";
  static const String linkRestaurantPath = "/driver/restaurants/link";
  static String unlinkRestaurantPath(int restaurantId) =>
      "/driver/restaurants/$restaurantId";

  // Driver bank endpoints
  static const String driverBalancePath = "/driver/credits-debts";
  static const String driverRestaurantPaymentAmountPath =
      "/driver/restaurant-payment-amount";
  static const String driverSystemPaymentAmountPath =
      "/driver/system-payment-amount";
  static const String driverPaymentsPath = "/driver/payments";
  static const String driverSystemPaymentsPath = "/driver/system-payments";
  static const String driverTransactionsPath = "/driver/transactions";

  // Driver statistics endpoint
  static const String driverStatisticsPath = "/driver/statistics";
}
