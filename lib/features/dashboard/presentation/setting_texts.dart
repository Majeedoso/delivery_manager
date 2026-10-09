import 'package:delivery_manager/l10n/app_localizations.dart';

/// A platform setting as the manager reads it, in the app's language: its
/// name, what it is for in a line, and how it works. They were written in
/// English in the page, for every language.
class SettingTexts {
  const SettingTexts({
    required this.name,
    required this.role,
    required this.help,
  });

  final String name;
  final String role;
  final String help;
}

/// The texts of the setting [key], or null for one the app has none for (a
/// setting added on the server since).
SettingTexts? settingTexts(AppLocalizations l10n, String key) => switch (key) {
  'system_manager_order_percentage' => SettingTexts(
    name: l10n.settingSystemManagerOrderPercentageName,
    role: l10n.settingSystemManagerOrderPercentageRole,
    help: l10n.settingSystemManagerOrderPercentageHelp,
  ),
  'system_manager_delivery_fee_percentage' => SettingTexts(
    name: l10n.settingSystemManagerDeliveryFeePercentageName,
    role: l10n.settingSystemManagerDeliveryFeePercentageRole,
    help: l10n.settingSystemManagerDeliveryFeePercentageHelp,
  ),
  'contact_email' => SettingTexts(
    name: l10n.settingContactEmailName,
    role: l10n.settingContactEmailRole,
    help: l10n.settingContactEmailHelp,
  ),
  'contact_phone' => SettingTexts(
    name: l10n.settingContactPhoneName,
    role: l10n.settingContactPhoneRole,
    help: l10n.settingContactPhoneHelp,
  ),
  'contact_website' => SettingTexts(
    name: l10n.settingContactWebsiteName,
    role: l10n.settingContactWebsiteRole,
    help: l10n.settingContactWebsiteHelp,
  ),
  'contact_address' => SettingTexts(
    name: l10n.settingContactAddressName,
    role: l10n.settingContactAddressRole,
    help: l10n.settingContactAddressHelp,
  ),
  'minimum_delivery_fee' => SettingTexts(
    name: l10n.settingMinimumDeliveryFeeName,
    role: l10n.settingMinimumDeliveryFeeRole,
    help: l10n.settingMinimumDeliveryFeeHelp,
  ),
  'maximum_delivery_fee' => SettingTexts(
    name: l10n.settingMaximumDeliveryFeeName,
    role: l10n.settingMaximumDeliveryFeeRole,
    help: l10n.settingMaximumDeliveryFeeHelp,
  ),
  'max_driver_concurrent_orders' => SettingTexts(
    name: l10n.settingMaxDriverConcurrentOrdersName,
    role: l10n.settingMaxDriverConcurrentOrdersRole,
    help: l10n.settingMaxDriverConcurrentOrdersHelp,
  ),
  'fixed_delivery_fee' => SettingTexts(
    name: l10n.settingFixedDeliveryFeeName,
    role: l10n.settingFixedDeliveryFeeRole,
    help: l10n.settingFixedDeliveryFeeHelp,
  ),
  'price_per_meter' => SettingTexts(
    name: l10n.settingPricePerMeterName,
    role: l10n.settingPricePerMeterRole,
    help: l10n.settingPricePerMeterHelp,
  ),
  'max_delivery_distance_km' => SettingTexts(
    name: l10n.settingMaxDeliveryDistanceKmName,
    role: l10n.settingMaxDeliveryDistanceKmRole,
    help: l10n.settingMaxDeliveryDistanceKmHelp,
  ),
  'average_city_speed_kmh' => SettingTexts(
    name: l10n.settingAverageCitySpeedKmhName,
    role: l10n.settingAverageCitySpeedKmhRole,
    help: l10n.settingAverageCitySpeedKmhHelp,
  ),
  'average_highway_speed_kmh' => SettingTexts(
    name: l10n.settingAverageHighwaySpeedKmhName,
    role: l10n.settingAverageHighwaySpeedKmhRole,
    help: l10n.settingAverageHighwaySpeedKmhHelp,
  ),
  'city_highway_transition_km' => SettingTexts(
    name: l10n.settingCityHighwayTransitionKmName,
    role: l10n.settingCityHighwayTransitionKmRole,
    help: l10n.settingCityHighwayTransitionKmHelp,
  ),
  'currency' => SettingTexts(
    name: l10n.settingCurrencyName,
    role: l10n.settingCurrencyRole,
    help: l10n.settingCurrencyHelp,
  ),
  'birthday_gift_enabled' => SettingTexts(
    name: l10n.settingBirthdayGiftEnabledName,
    role: l10n.settingBirthdayGiftEnabledRole,
    help: l10n.settingBirthdayGiftEnabledHelp,
  ),
  'birthday_gift_cap' => SettingTexts(
    name: l10n.settingBirthdayGiftCapName,
    role: l10n.settingBirthdayGiftCapRole,
    help: l10n.settingBirthdayGiftCapHelp,
  ),
  'customer_restaurant_radius_km' => SettingTexts(
    name: l10n.settingCustomerRestaurantRadiusKmName,
    role: l10n.settingCustomerRestaurantRadiusKmRole,
    help: l10n.settingCustomerRestaurantRadiusKmHelp,
  ),
  'customer_restaurant_prefilter_radius_km' => SettingTexts(
    name: l10n.settingCustomerRestaurantPrefilterRadiusKmName,
    role: l10n.settingCustomerRestaurantPrefilterRadiusKmRole,
    help: l10n.settingCustomerRestaurantPrefilterRadiusKmHelp,
  ),
  'privacy_policy_url' => SettingTexts(
    name: l10n.settingPrivacyPolicyUrlName,
    role: l10n.settingPrivacyPolicyUrlRole,
    help: l10n.settingPrivacyPolicyUrlHelp,
  ),
  'terms_of_service_url' => SettingTexts(
    name: l10n.settingTermsOfServiceUrlName,
    role: l10n.settingTermsOfServiceUrlRole,
    help: l10n.settingTermsOfServiceUrlHelp,
  ),
  'min_order_scheduling_minutes' => SettingTexts(
    name: l10n.settingMinOrderSchedulingMinutesName,
    role: l10n.settingMinOrderSchedulingMinutesRole,
    help: l10n.settingMinOrderSchedulingMinutesHelp,
  ),
  'number_of_orders_to_be_trusted' => SettingTexts(
    name: l10n.settingNumberOfOrdersToBeTrustedName,
    role: l10n.settingNumberOfOrdersToBeTrustedRole,
    help: l10n.settingNumberOfOrdersToBeTrustedHelp,
  ),
  'otp_validity_minutes' => SettingTexts(
    name: l10n.settingOtpValidityMinutesName,
    role: l10n.settingOtpValidityMinutesRole,
    help: l10n.settingOtpValidityMinutesHelp,
  ),
  'otp_resend_wait_seconds' => SettingTexts(
    name: l10n.settingOtpResendWaitSecondsName,
    role: l10n.settingOtpResendWaitSecondsRole,
    help: l10n.settingOtpResendWaitSecondsHelp,
  ),
  'max_saved_addresses' => SettingTexts(
    name: l10n.settingMaxSavedAddressesName,
    role: l10n.settingMaxSavedAddressesRole,
    help: l10n.settingMaxSavedAddressesHelp,
  ),
  'max_items_per_order' => SettingTexts(
    name: l10n.settingMaxItemsPerOrderName,
    role: l10n.settingMaxItemsPerOrderRole,
    help: l10n.settingMaxItemsPerOrderHelp,
  ),
  'max_quantity_per_item' => SettingTexts(
    name: l10n.settingMaxQuantityPerItemName,
    role: l10n.settingMaxQuantityPerItemRole,
    help: l10n.settingMaxQuantityPerItemHelp,
  ),
  'amount_rounding_step' => SettingTexts(
    name: l10n.settingAmountRoundingStepName,
    role: l10n.settingAmountRoundingStepRole,
    help: l10n.settingAmountRoundingStepHelp,
  ),
  'loyalty_coupon_validity_days' => SettingTexts(
    name: l10n.settingLoyaltyCouponValidityDaysName,
    role: l10n.settingLoyaltyCouponValidityDaysRole,
    help: l10n.settingLoyaltyCouponValidityDaysHelp,
  ),
  'default_delivery_time_minutes' => SettingTexts(
    name: l10n.settingDefaultDeliveryTimeMinutesName,
    role: l10n.settingDefaultDeliveryTimeMinutesRole,
    help: l10n.settingDefaultDeliveryTimeMinutesHelp,
  ),
  'route_cache_minutes' => SettingTexts(
    name: l10n.settingRouteCacheMinutesName,
    role: l10n.settingRouteCacheMinutesRole,
    help: l10n.settingRouteCacheMinutesHelp,
  ),
  'map_default_latitude' => SettingTexts(
    name: l10n.settingMapDefaultLatitudeName,
    role: l10n.settingMapDefaultLatitudeRole,
    help: l10n.settingMapDefaultLatitudeHelp,
  ),
  'map_default_longitude' => SettingTexts(
    name: l10n.settingMapDefaultLongitudeName,
    role: l10n.settingMapDefaultLongitudeRole,
    help: l10n.settingMapDefaultLongitudeHelp,
  ),
  'app_mapbox_access_token' => SettingTexts(
    name: l10n.settingAppMapboxAccessTokenName,
    role: l10n.settingAppMapboxAccessTokenRole,
    help: l10n.settingAppMapboxAccessTokenHelp,
  ),
  'local_timezone' => SettingTexts(
    name: l10n.settingLocalTimezoneName,
    role: l10n.settingLocalTimezoneRole,
    help: l10n.settingLocalTimezoneHelp,
  ),
  'best_seller_count' => SettingTexts(
    name: l10n.settingBestSellerCountName,
    role: l10n.settingBestSellerCountRole,
    help: l10n.settingBestSellerCountHelp,
  ),
  'best_seller_days' => SettingTexts(
    name: l10n.settingBestSellerDaysName,
    role: l10n.settingBestSellerDaysRole,
    help: l10n.settingBestSellerDaysHelp,
  ),
  'best_seller_min_orders' => SettingTexts(
    name: l10n.settingBestSellerMinOrdersName,
    role: l10n.settingBestSellerMinOrdersRole,
    help: l10n.settingBestSellerMinOrdersHelp,
  ),
  'loyalty_enabled' => SettingTexts(
    name: l10n.settingLoyaltyEnabledName,
    role: l10n.settingLoyaltyEnabledRole,
    help: l10n.settingLoyaltyEnabledHelp,
  ),
  'loyalty_earn_rate' => SettingTexts(
    name: l10n.settingLoyaltyEarnRateName,
    role: l10n.settingLoyaltyEarnRateRole,
    help: l10n.settingLoyaltyEarnRateHelp,
  ),
  'loyalty_redeem_rate' => SettingTexts(
    name: l10n.settingLoyaltyRedeemRateName,
    role: l10n.settingLoyaltyRedeemRateRole,
    help: l10n.settingLoyaltyRedeemRateHelp,
  ),
  'loyalty_min_redeem_points' => SettingTexts(
    name: l10n.settingLoyaltyMinRedeemPointsName,
    role: l10n.settingLoyaltyMinRedeemPointsRole,
    help: l10n.settingLoyaltyMinRedeemPointsHelp,
  ),
  'loyalty_tiers' => SettingTexts(
    name: l10n.settingLoyaltyTiersName,
    role: l10n.settingLoyaltyTiersRole,
    help: l10n.settingLoyaltyTiersHelp,
  ),
  'max_coupons_per_category' => SettingTexts(
    name: l10n.settingMaxCouponsPerCategoryName,
    role: l10n.settingMaxCouponsPerCategoryRole,
    help: l10n.settingMaxCouponsPerCategoryHelp,
  ),
  'max_coupon_categories' => SettingTexts(
    name: l10n.settingMaxCouponCategoriesName,
    role: l10n.settingMaxCouponCategoriesRole,
    help: l10n.settingMaxCouponCategoriesHelp,
  ),
  _ => null,
};

/// A setting's name; one the app has none for shows its key, made readable.
String settingName(AppLocalizations l10n, String key) =>
    settingTexts(l10n, key)?.name ?? readableKey(key);

/// A group of settings, by name.
String settingCategoryName(AppLocalizations l10n, String category) =>
    switch (category) {
      'delivery' => l10n.settingsCategoryDelivery,
      'financials' => l10n.settingsCategoryFinancials,
      'customers_orders' => l10n.settingsCategoryCustomersOrders,
      'loyalty_promotions' => l10n.settingsCategoryLoyaltyPromotions,
      'accounts_security' => l10n.settingsCategoryAccountsSecurity,
      'api_integrations' => l10n.settingsCategoryApiIntegrations,
      'legal_contact' => l10n.settingsCategoryLegalContact,
      _ => readableKey(category),
    };

/// The kind of value a setting holds, as the server names it.
String settingTypeName(AppLocalizations l10n, String type) => switch (type) {
  'string' => l10n.settingTypeText,
  'integer' || 'int' => l10n.settingTypeWhole,
  'decimal' || 'number' || 'float' => l10n.settingTypeNumber,
  'boolean' || 'bool' => l10n.settingTypeYesNo,
  'json' || 'array' => l10n.settingTypeList,
  _ => type,
};

/// A key the app has no name for, made readable: "max_items" reads
/// "Max Items".
String readableKey(String raw) => raw
    .replaceAll('_', ' ')
    .split(' ')
    .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
    .join(' ');
