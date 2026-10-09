import 'package:delivery_manager/core/config/app_config.dart';

class ApiConstance {
  static String get baseUrl => AppConfig.baseUrl;

  // Auth endpoints (relative paths - Dio has baseUrl configured)
  static const String loginPath = "/auth/login";
  static const String logoutPath = "/auth/logout";
  static const String userPath = "/auth/user";
  static const String googleSignInPath = "/auth/google/login";
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
  // The manager's own route: /auth/user can only be read
  static const String updateProfilePath = "/manager/profile";

  // Manager bank endpoints
  static const String managerCreditsDebtsPath = "/manager/credits-debts";
  static const String managerRestaurantPaymentAmountPath =
      "/manager/restaurant-payment-amount";
  static const String managerSystemPaymentAmountPath =
      "/manager/system-payment-amount";
  static const String managerRestaurantPaymentsPath = "/manager/restaurant-payments";
  static const String managerSystemPaymentsPath = "/manager/system-payments";
  // What the platform pays a restaurant or a driver
  static const String managerPlatformPaymentsPath =
      "/manager/platform-payments";
  static String managerAnswerPaymentPath(int id) =>
      "/manager/system-payments/$id/confirm";
  static const String managerOrderStatisticsPath =
      "/manager/statistics/orders";

  // Manager coupons endpoints
  // The delivery zones: where customers can order
  static const String managerDeliveryZonesPath = "/manager/delivery-zones";
  static String managerDeliveryZonePath(int id) =>
      "/manager/delivery-zones/$id";
  static String managerDeliveryZoneSwitchPath(int id) =>
      "/manager/delivery-zones/$id/toggle-active";
  static const String managerCouponsPath = "/manager/coupons";
  static String managerCouponByIdPath(int id) => "/manager/coupons/$id";

  // Manager coupon zones endpoints
  static const String managerCouponZonesPath = "/manager/coupon-zones";
  static String managerCouponZoneByIdPath(int id) =>
      "/manager/coupon-zones/$id";

  // Manager user management endpoints
  static const String managerUsersPath = "/manager/users";
  static String managerApproveUserPath(int id) => "/manager/users/$id/approve";
  static String managerRejectUserPath(int id) => "/manager/users/$id/reject";
  static String managerSuspendUserPath(int id) => "/manager/users/$id/suspend";
  static String managerActivateUserPath(int id) => "/manager/users/$id/activate";

  // Manager analytics endpoints
  static const String managerAnalyticsRevenuePath = "/manager/analytics/revenue";
  static const String managerDeliveryAnalyticsPath =
      "/manager/deliveries/analytics";
  static const String managerRatingStatisticsPath =
      "/manager/ratings/statistics";
  static const String managerRestaurantsPath = "/manager/restaurants";
  static String managerRestaurantRatingsPath(int id) =>
      "/manager/restaurants/$id/ratings";
  static String managerRestaurantStatisticsPath(int id) =>
      "/manager/restaurants/$id/statistics";
  static const String managerRestaurantStatisticsOverviewPath =
      "/manager/restaurants/statistics/overview";
  static const String managerDriversPath = "/manager/drivers";
  static String managerDriverRatingsPath(int id) =>
      "/manager/drivers/$id/ratings";

  // Manager settings (dashboard) endpoints
  static const String managerSettingsPath = "/manager/settings";
  static String managerSettingByIdPath(int id) => "/manager/settings/$id";
}
