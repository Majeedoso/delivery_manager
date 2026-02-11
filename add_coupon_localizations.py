#!/usr/bin/env python3
import json

# Coupon localization keys in English, Arabic, and French
coupon_keys = {
    # Coupons Home Screen
    "coupons": {
        "en": "Coupons",
        "ar": "قسائم الخصم",
        "fr": "Coupons"
    },
    "restaurantCoupons": {
        "en": "Restaurant Coupons",
        "ar": "قسائم المطاعم",
        "fr": "Coupons de restaurant"
    },
    "deliveryCoupons": {
        "en": "Delivery Coupons",
        "ar": "قسائم التوصيل",
        "fr": "Coupons de livraison"
    },

    # Coupons List Screen
    "all": {
        "en": "All",
        "ar": "الكل",
        "fr": "Tous"
    },
    "draft": {
        "en": "Draft",
        "ar": "مسودة",
        "fr": "Brouillon"
    },
    "disabled": {
        "en": "Disabled",
        "ar": "معطل",
        "fr": "Désactivé"
    },
    "newDeliveryCoupon": {
        "en": "New Delivery Coupon",
        "ar": "قسيمة توصيل جديدة",
        "fr": "Nouveau coupon de livraison"
    },
    "newCoupon": {
        "en": "New Coupon",
        "ar": "قسيمة جديدة",
        "fr": "Nouveau coupon"
    },
    "retry": {
        "en": "Retry",
        "ar": "إعادة المحاولة",
        "fr": "Réessayer"
    },
    "noDeliveryCouponsYet": {
        "en": "No delivery coupons yet",
        "ar": "لا توجد قسائم توصيل بعد",
        "fr": "Aucun coupon de livraison pour le moment"
    },
    "noCouponsYet": {
        "en": "No coupons yet",
        "ar": "لا توجد قسائم بعد",
        "fr": "Aucun coupon pour le moment"
    },
    "createFirstDeliveryCoupon": {
        "en": "Create your first delivery coupon!",
        "ar": "أنشئ قسيمة التوصيل الأولى!",
        "fr": "Créez votre premier coupon de livraison!"
    },
    "createFirstCoupon": {
        "en": "Create your first coupon to attract more customers!",
        "ar": "أنشئ قسيمتك الأولى لجذب المزيد من العملاء!",
        "fr": "Créez votre premier coupon pour attirer plus de clients!"
    },
    "off": {
        "en": "OFF",
        "ar": "خصم",
        "fr": "REMISE"
    },
    "discount": {
        "en": "Discount",
        "ar": "خصم",
        "fr": "Remise"
    },
    "valid": {
        "en": "Valid",
        "ar": "صالح",
        "fr": "Valide"
    },
    "uses": {
        "en": "Uses",
        "ar": "الاستخدامات",
        "fr": "Utilisations"
    },
    "minOrder": {
        "en": "Min Order",
        "ar": "الحد الأدنى للطلب",
        "fr": "Commande minimale"
    },
    "dzd": {
        "en": "DZD",
        "ar": "دج",
        "fr": "DZD"
    },
    "expired": {
        "en": "Expired",
        "ar": "منتهية الصلاحية",
        "fr": "Expiré"
    },
    "restaurant": {
        "en": "Restaurant: ",
        "ar": "المطعم: ",
        "fr": "Restaurant: "
    },
    "globalAllRestaurants": {
        "en": "Global (all restaurants)",
        "ar": "عام (جميع المطاعم)",
        "fr": "Global (tous les restaurants)"
    },
    "issuer": {
        "en": "Issuer: ",
        "ar": "المُصدر: ",
        "fr": "Émetteur: "
    },

    # Add/Edit Coupon Screen
    "discardChanges": {
        "en": "Discard Changes?",
        "ar": "تجاهل التغييرات؟",
        "fr": "Ignorer les modifications?"
    },
    "unsavedChangesMessage": {
        "en": "You have unsaved changes. Do you want to discard them?",
        "ar": "لديك تغييرات غير محفوظة. هل تريد تجاهلها؟",
        "fr": "Vous avez des modifications non enregistrées. Voulez-vous les ignorer?"
    },
    "discard": {
        "en": "Discard",
        "ar": "تجاهل",
        "fr": "Ignorer"
    },
    "editCoupon": {
        "en": "Edit Coupon",
        "ar": "تعديل القسيمة",
        "fr": "Modifier le coupon"
    },
    "update": {
        "en": "Update",
        "ar": "تحديث",
        "fr": "Mettre à jour"
    },
    "create": {
        "en": "Create",
        "ar": "إنشاء",
        "fr": "Créer"
    },
    "couponCode": {
        "en": "Coupon Code",
        "ar": "كود القسيمة",
        "fr": "Code du coupon"
    },
    "couponCodeHint": {
        "en": "e.g. SUMMER20",
        "ar": "مثال: SUMMER20",
        "fr": "ex. SUMMER20"
    },
    "pleaseEnterCouponCode": {
        "en": "Please enter a coupon code",
        "ar": "الرجاء إدخال كود القسيمة",
        "fr": "Veuillez saisir un code de coupon"
    },
    "codeMinLength": {
        "en": "Code must be at least 3 characters",
        "ar": "يجب أن يكون الكود 3 أحرف على الأقل",
        "fr": "Le code doit contenir au moins 3 caractères"
    },
    "type": {
        "en": "Type",
        "ar": "النوع",
        "fr": "Type"
    },
    "percentage": {
        "en": "Percentage",
        "ar": "نسبة مئوية",
        "fr": "Pourcentage"
    },
    "fixedAmount": {
        "en": "Fixed Amount",
        "ar": "مبلغ ثابت",
        "fr": "Montant fixe"
    },
    "value": {
        "en": "Value",
        "ar": "القيمة",
        "fr": "Valeur"
    },
    "required": {
        "en": "Required",
        "ar": "مطلوب",
        "fr": "Requis"
    },
    "min1": {
        "en": "Min 1",
        "ar": "الحد الأدنى 1",
        "fr": "Min 1"
    },
    "max100Percent": {
        "en": "Max 100%",
        "ar": "الحد الأقصى 100%",
        "fr": "Max 100%"
    },
    "discountAppliesTo": {
        "en": "Discount Applies To",
        "ar": "الخصم ينطبق على",
        "fr": "Réduction applicable à"
    },
    "deliveryFee": {
        "en": "Delivery Fee",
        "ar": "رسوم التوصيل",
        "fr": "Frais de livraison"
    },
    "orderSubtotal": {
        "en": "Order Subtotal",
        "ar": "المجموع الفرعي للطلب",
        "fr": "Sous-total de la commande"
    },
    "status": {
        "en": "Status",
        "ar": "الحالة",
        "fr": "Statut"
    },
    "active": {
        "en": "Active",
        "ar": "نشط",
        "fr": "Actif"
    },
    "validityPeriod": {
        "en": "Validity Period",
        "ar": "فترة الصلاحية",
        "fr": "Période de validité"
    },
    "startDate": {
        "en": "Start Date",
        "ar": "تاريخ البدء",
        "fr": "Date de début"
    },
    "endDate": {
        "en": "End Date",
        "ar": "تاريخ الانتهاء",
        "fr": "Date de fin"
    },
    "restaurantOptional": {
        "en": "Restaurant (Optional)",
        "ar": "المطعم (اختياري)",
        "fr": "Restaurant (Optionnel)"
    },
    "couponZonesOptional": {
        "en": "Coupon Zones (Optional)",
        "ar": "مناطق القسيمة (اختياري)",
        "fr": "Zones de coupon (Optionnel)"
    },
    "manageZones": {
        "en": "Manage Zones",
        "ar": "إدارة المناطق",
        "fr": "Gérer les zones"
    },
    "usageLimitsOptional": {
        "en": "Usage Limits (Optional)",
        "ar": "حدود الاستخدام (اختياري)",
        "fr": "Limites d'utilisation (Optionnel)"
    },
    "totalUses": {
        "en": "Total uses",
        "ar": "إجمالي الاستخدامات",
        "fr": "Utilisations totales"
    },
    "perCustomer": {
        "en": "Per customer",
        "ar": "لكل عميل",
        "fr": "Par client"
    },
    "orderConstraintsOptional": {
        "en": "Order Constraints (Optional)",
        "ar": "قيود الطلب (اختياري)",
        "fr": "Contraintes de commande (Optionnel)"
    },
    "minOrderDzd": {
        "en": "Min order (DZD)",
        "ar": "الحد الأدنى للطلب (دج)",
        "fr": "Commande min (DZD)"
    },
    "maxDiscountDzd": {
        "en": "Max discount (DZD)",
        "ar": "الحد الأقصى للخصم (دج)",
        "fr": "Remise max (DZD)"
    },
    "descriptionOptional": {
        "en": "Description (Optional)",
        "ar": "الوصف (اختياري)",
        "fr": "Description (Optionnel)"
    },
    "internalNoteHint": {
        "en": "Internal note about this coupon...",
        "ar": "ملاحظة داخلية حول هذه القسيمة...",
        "fr": "Note interne sur ce coupon..."
    },
    "noCouponZonesAvailable": {
        "en": "No coupon zones available. Create zones to restrict coupon availability.",
        "ar": "لا توجد مناطق متاحة للقسيمة. أنشئ مناطق لتقييد توفر القسيمة.",
        "fr": "Aucune zone de coupon disponible. Créez des zones pour restreindre la disponibilité du coupon."
    },
    "selectZonesInfo": {
        "en": "Select zones (applies to all if none selected)",
        "ar": "اختر المناطق (ينطبق على الكل إذا لم يتم الاختيار)",
        "fr": "Sélectionner les zones (s'applique à tous si aucune sélection)"
    },
    "zone": {
        "en": "zone",
        "ar": "منطقة",
        "fr": "zone"
    },
    "zones": {
        "en": "zones",
        "ar": "مناطق",
        "fr": "zones"
    },
    "noRestaurantsAvailable": {
        "en": "No restaurants available. This coupon will be global.",
        "ar": "لا توجد مطاعم متاحة. ستكون هذه القسيمة عامة.",
        "fr": "Aucun restaurant disponible. Ce coupon sera global."
    },
    "selectedRestaurant": {
        "en": "Selected Restaurant",
        "ar": "المطعم المحدد",
        "fr": "Restaurant sélectionné"
    },
    "allRestaurantsGlobal": {
        "en": "All Restaurants (Global)",
        "ar": "جميع المطاعم (عام)",
        "fr": "Tous les restaurants (Global)"
    },
    "kmRadius": {
        "en": "km radius",
        "ar": "كم نصف قطر",
        "fr": "km de rayon"
    },

    # Delivery Zones Screen
    "couponZones": {
        "en": "Coupon Zones",
        "ar": "مناطق القسيمة",
        "fr": "Zones de coupon"
    },
    "addZone": {
        "en": "Add Zone",
        "ar": "إضافة منطقة",
        "fr": "Ajouter une zone"
    },
    "success": {
        "en": "Success!",
        "ar": "نجح!",
        "fr": "Succès!"
    },
    "errorOccurred": {
        "en": "Error occurred",
        "ar": "حدث خطأ",
        "fr": "Une erreur s'est produite"
    },
    "noCouponZonesYet": {
        "en": "No coupon zones yet",
        "ar": "لا توجد مناطق قسيمة بعد",
        "fr": "Aucune zone de coupon pour le moment"
    },
    "createZonesToRestrict": {
        "en": "Create zones to restrict coupons\\nto specific areas",
        "ar": "أنشئ مناطق لتقييد القسائم\\nإلى مناطق محددة",
        "fr": "Créez des zones pour restreindre les coupons\\nà des zones spécifiques"
    },
    "createZone": {
        "en": "Create Zone",
        "ar": "إنشاء منطقة",
        "fr": "Créer une zone"
    },
    "edit": {
        "en": "Edit",
        "ar": "تعديل",
        "fr": "Modifier"
    },
    "delete": {
        "en": "Delete",
        "ar": "حذف",
        "fr": "Supprimer"
    },
    "editZone": {
        "en": "Edit Zone",
        "ar": "تعديل المنطقة",
        "fr": "Modifier la zone"
    },
    "zoneNameRequired": {
        "en": "Zone Name *",
        "ar": "اسم المنطقة *",
        "fr": "Nom de la zone *"
    },
    "zoneNameHint": {
        "en": "e.g., Downtown Area",
        "ar": "مثال: منطقة وسط المدينة",
        "fr": "ex. Centre-ville"
    },
    "description": {
        "en": "Description",
        "ar": "الوصف",
        "fr": "Description"
    },
    "optionalDescription": {
        "en": "Optional description",
        "ar": "وصف اختياري",
        "fr": "Description optionnelle"
    },
    "latitude": {
        "en": "Latitude",
        "ar": "خط العرض",
        "fr": "Latitude"
    },
    "latitudeHint": {
        "en": "e.g., 36.7538",
        "ar": "مثال: 36.7538",
        "fr": "ex. 36.7538"
    },
    "longitude": {
        "en": "Longitude",
        "ar": "خط الطول",
        "fr": "Longitude"
    },
    "longitudeHint": {
        "en": "e.g., 3.0588",
        "ar": "مثال: 3.0588",
        "fr": "ex. 3.0588"
    },
    "radiusKm": {
        "en": "Radius (km)",
        "ar": "نصف القطر (كم)",
        "fr": "Rayon (km)"
    },
    "radiusHint": {
        "en": "e.g., 5.0",
        "ar": "مثال: 5.0",
        "fr": "ex. 5.0"
    },
    "km": {
        "en": "km",
        "ar": "كم",
        "fr": "km"
    },
    "zoneNameIsRequired": {
        "en": "Zone name is required",
        "ar": "اسم المنطقة مطلوب",
        "fr": "Le nom de la zone est requis"
    },
    "deleteZone": {
        "en": "Delete Zone",
        "ar": "حذف المنطقة",
        "fr": "Supprimer la zone"
    },
    "deleteZoneConfirmation": {
        "en": "Are you sure you want to delete \"{zoneName}\"?",
        "ar": "هل أنت متأكد أنك تريد حذف \"{zoneName}\"؟",
        "fr": "Êtes-vous sûr de vouloir supprimer \"{zoneName}\"?",
        "placeholders": {
            "zoneName": {
                "type": "String"
            }
        }
    }
}

# File paths
files = {
    "en": "lib/l10n/app_en.arb",
    "ar": "lib/l10n/app_ar.arb",
    "fr": "lib/l10n/app_fr.arb"
}

def add_keys_to_file(lang_code):
    file_path = files[lang_code]

    # Read existing file
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    # Add new keys
    added_count = 0
    for key, translations in coupon_keys.items():
        if key not in data:
            if isinstance(translations[lang_code], dict):
                # Handle placeholders
                data[key] = translations[lang_code]["text"] if "text" in translations[lang_code] else translations[lang_code]
            else:
                data[key] = translations[lang_code]

            # Add placeholders metadata if it exists
            if "placeholders" in translations.get(lang_code, {}):
                data[f"@{key}"] = {
                    "placeholders": translations[lang_code]["placeholders"]
                }

            added_count += 1
            print(f"Added '{key}' to {lang_code}")

    # Write back to file
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"\n[OK] Added {added_count} keys to {file_path}")
    return added_count

# Process all language files
total_added = 0
for lang in ["en", "ar", "fr"]:
    count = add_keys_to_file(lang)
    total_added += count

print(f"\n[SUCCESS] Total: Added {total_added} localization keys across all files")
