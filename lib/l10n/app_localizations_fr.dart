// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Chauffeur de Livraison';

  @override
  String get login => 'Connexion';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get name => 'Nom';

  @override
  String get phone => 'Téléphone';

  @override
  String get rememberMe => 'Se souvenir de moi';

  @override
  String get forgotPassword => 'Mot de passe oublié';

  @override
  String get dontHaveAccount => 'Vous n\'avez pas de compte ? ';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ? ';

  @override
  String get signInWithGoogle => 'Se connecter avec Google';

  @override
  String get signUpWithGoogle => 'S\'inscrire avec Google';

  @override
  String get signUpWithEmail => 'S\'inscrire avec Email';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get checkingAuthentication => 'Vérification de l\'authentification...';

  @override
  String get welcome => 'Bienvenue';

  @override
  String get logout => 'Déconnexion';

  @override
  String get clearSavedCredentials => 'Effacer les identifiants sauvegardés';

  @override
  String get language => 'Langue';

  @override
  String get selectLanguage => 'Sélectionner la langue';

  @override
  String get english => 'Anglais';

  @override
  String get arabic => 'Arabe';

  @override
  String get french => 'Français';

  @override
  String get or => 'OU';

  @override
  String get profile => 'Profil';

  @override
  String get profileInformation => 'Informations du profil';

  @override
  String get userType => 'Type d\'utilisateur';

  @override
  String get settings => 'Paramètres';

  @override
  String get appSettings => 'Paramètres de l\'application';

  @override
  String get deliveryPreferences => 'Pr?f?rences de livraison';

  @override
  String get deliveryPreferencesDescription => 'Choisissez les restaurants pour lesquels vous souhaitez livrer';

  @override
  String get mutualSelected => 'Mutual';

  @override
  String get pendingSelected => 'Pending';

  @override
  String get selectAllRestaurants => 'Tout s?lectionner';

  @override
  String get noSelectionAllRestaurantsHint => 'Aucune s?lection signifie que vous recevrez les commandes de tous les restaurants.';

  @override
  String selectedRestaurantsCount(int count, int total) {
    return '$count sur $total s?lectionn?s';
  }

  @override
  String updatingSelections(int done, int total) {
    return 'Mise ? jour des s?lections $done/$total...';
  }

  @override
  String get linkedRestaurants => 'Restaurants li?s';

  @override
  String get addRestaurantByCode => 'Ajouter un restaurant par code';

  @override
  String get restaurantCode => 'Code du restaurant';

  @override
  String get enterRestaurantCode => 'Saisissez le code du restaurant';

  @override
  String get linkRestaurant => 'Lier';

  @override
  String get linkRestaurantSuccess => 'Li? avec succ?s';

  @override
  String get unlinkRestaurant => 'D?li? avec succ?s';

  @override
  String get noLinkedRestaurants => 'Aucun restaurant li? pour l\'instant';

  @override
  String get noLinkedRestaurantsDescription => 'Ajoutez un code restaurant pour commencer ? livrer pour des restaurants sp?cifiques.';

  @override
  String get notifications => 'Notifications';

  @override
  String get pushNotifications => 'Notifications push';

  @override
  String get pushNotificationsDescription => 'Recevoir des notifications push';

  @override
  String get emailNotifications => 'Notifications par e-mail';

  @override
  String get emailNotificationsDescription => 'Recevoir des notifications par e-mail';

  @override
  String get privacy => 'Confidentialité';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get termsOfService => 'Conditions d\'utilisation';

  @override
  String get appInformation => 'Informations sur l\'application';

  @override
  String get version => 'Version';

  @override
  String get checkForUpdates => 'Vérifier les mises à jour';

  @override
  String get aboutApp => 'À propos de l\'application';

  @override
  String get aboutDescription => 'Cette application est conçue pour les chauffeurs de livraison afin de gérer efficacement leurs livraisons. Les chauffeurs peuvent voir les commandes disponibles, accepter les demandes de livraison, naviguer vers les lieux de collecte et de livraison, mettre à jour le statut de livraison en temps réel, définir leur horaire de disponibilité et suivre leurs gains.';

  @override
  String get features => 'Fonctionnalités';

  @override
  String get userAuthentication => 'Authentification utilisateur';

  @override
  String get userAuthenticationDescription => 'Système de connexion et d\'inscription sécurisé';

  @override
  String get multiLanguageSupport => 'Support multilingue';

  @override
  String get multiLanguageSupportDescription => 'Support pour plusieurs langues';

  @override
  String get secureStorage => 'Stockage sécurisé';

  @override
  String get secureStorageDescription => 'Stockage sécurisé pour les données sensibles';

  @override
  String get googleSignIn => 'Connexion Google';

  @override
  String get googleSignInDescription => 'Connexion rapide avec un compte Google';

  @override
  String get contactUs => 'Nous contacter';

  @override
  String get copyright => '© 2024 Chauffeur de Livraison. Tous droits réservés.';

  @override
  String get website => 'Site web';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get changeEmail => 'Changer l\'email';

  @override
  String get updateProfile => 'Mettre à jour le profil';

  @override
  String get main => 'Principal';

  @override
  String get pendingOrders => 'Commandes en attente';

  @override
  String get pendingOrdersDescription => 'Gérer les commandes en attente de vérification';

  @override
  String get acceptOrder => 'Accepter la commande';

  @override
  String get orderAcceptedSuccessfully => 'Commande acceptée avec succès!';

  @override
  String get noOrdersAvailable => 'Aucune commande disponible';

  @override
  String get checkBackLater => 'Revenez plus tard pour de nouvelles commandes';

  @override
  String get refresh => 'Actualiser';

  @override
  String get noDeliveryAddress => 'Aucune adresse de livraison';

  @override
  String get items => 'articles';

  @override
  String get total => 'Total';

  @override
  String get deliveryFee => 'Frais de livraison';

  @override
  String get cash => 'Espèces';

  @override
  String get card => 'Carte';

  @override
  String get confirmed => 'Confirmé';

  @override
  String get readyForPickup => 'Prête à récupérer';

  @override
  String get showMore => 'Voir plus';

  @override
  String get showLess => 'Voir moins';

  @override
  String get paymentMethod => 'Paiement';

  @override
  String get deliveryNotes => 'Notes';

  @override
  String get ongoingOrders => 'Commandes en cours';

  @override
  String get ongoingOrdersDescription => 'Gérez vos livraisons actives';

  @override
  String get archiveOrders => 'Archive des commandes';

  @override
  String get archiveOrdersDescription => 'Voir les commandes acceptées et rejetées';

  @override
  String get statistics => 'Statistiques';

  @override
  String get statisticsDescription => 'Voir vos métriques de performance';

  @override
  String get noUserDataAvailable => 'Aucune donnée utilisateur disponible';

  @override
  String get user => 'Utilisateur';

  @override
  String get orders => 'Commandes';

  @override
  String get archive => 'Archive';

  @override
  String get ordersArchive => 'Archive des commandes';

  @override
  String get acceptedOrders => 'Commandes acceptées';

  @override
  String get rejectedOrders => 'Commandes rejetées';

  @override
  String get deliveredOrders => 'Commandes livrées';

  @override
  String get canceledOrders => 'Commandes annulées';

  @override
  String get delivered => 'Livré';

  @override
  String get cancelled => 'Annulé';

  @override
  String get resetPassword => 'Réinitialiser le mot de passe';

  @override
  String get resetYourPassword => 'Réinitialiser votre mot de passe';

  @override
  String get enterEmailDescription => 'Entrez votre adresse email et nous vous enverrons un code OTP pour réinitialiser votre mot de passe.';

  @override
  String get emailAddress => 'Adresse email';

  @override
  String get sendResetLink => 'Envoyer le lien de réinitialisation';

  @override
  String get sendOtp => 'Envoyer OTP';

  @override
  String get backToLogin => 'Retour à la connexion';

  @override
  String get enterOtpCode => 'Entrez le code OTP';

  @override
  String get enterOtpDescription => 'Entrez le code OTP à 6 chiffres envoyé à votre email\nIl sera vérifié automatiquement une fois terminé';

  @override
  String get setNewPassword => 'Définir un nouveau mot de passe';

  @override
  String get enterNewPasswordDescription => 'Entrez votre nouveau mot de passe ci-dessous';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get confirmNewPassword => 'Confirmer le mot de passe';

  @override
  String get resendOtp => 'Renvoyer OTP';

  @override
  String get verifyEmail => 'Vérifier l\'email';

  @override
  String get enterOtp => 'Entrez le code OTP';

  @override
  String get otpSentTo => 'Code OTP envoyé à';

  @override
  String get verifyOtp => 'Vérifier le code OTP';

  @override
  String get confirmEmailChange => 'Confirmer le changement d\'email';

  @override
  String resendIn(int seconds) {
    return 'Vous pouvez renvoyer OTP dans ${seconds}s';
  }

  @override
  String get emailNotVerified => 'Email non vérifié';

  @override
  String get emailVerificationRequired => 'Veuillez vérifier votre adresse e-mail avant d\'accéder à cette ressource. Un code de vérification (OTP) a été envoyé à votre adresse e-mail. Veuillez vérifier votre boîte de réception et entrer le code à 6 chiffres pour vérifier votre e-mail.';

  @override
  String get resendVerificationEmail => 'Renvoyer la vérification';

  @override
  String get verificationEmailSent => 'E-mail de vérification envoyé avec succès. Veuillez vérifier votre boîte de réception.';

  @override
  String get checking => 'Vérification...';

  @override
  String get checkStatus => 'Vérifier le statut';

  @override
  String get checkStatusDescription => 'Appuyez sur \"Vérifier le statut\" pour voir si votre compte a été approuvé';

  @override
  String get notificationsRequired => 'Les notifications sont requises pour cette application';

  @override
  String get notificationsRequiredDescription => 'Cette application nécessite l\'autorisation de notification pour recevoir des alertes de nouvelles commandes.';

  @override
  String get enableNotifications => 'Activer les notifications';

  @override
  String get openSettings => 'Ouvrir les paramètres';

  @override
  String get exitApp => 'Quitter l\'application';

  @override
  String get initializing => 'Initialisation...';

  @override
  String get checkingNotifications => 'Vérification des notifications...';

  @override
  String get settingUpNotifications => 'Configuration des notifications...';

  @override
  String get initializationFailed => 'Échec de l\'initialisation';

  @override
  String get requestingPermission => 'Demande d\'autorisation...';

  @override
  String get permissionRequestFailed => 'Échec de la demande d\'autorisation';

  @override
  String get checkingInternet => 'Vérification de la connexion Internet...';

  @override
  String get noInternetConnection => 'Pas de connexion Internet';

  @override
  String get noInternetDescription => 'Veuillez vérifier votre connexion Internet et réessayer.';

  @override
  String get retry => 'Réessayer';

  @override
  String get updateRequired => 'Mise à jour requise';

  @override
  String get updateRequiredDescription => 'Une nouvelle version de l\'application est disponible. Veuillez mettre à jour pour continuer à utiliser l\'application.';

  @override
  String get minimumRequiredVersion => 'Version minimale requise';

  @override
  String get latestAvailableVersion => 'Dernière version disponible';

  @override
  String get updateNow => 'Mettre à jour maintenant';

  @override
  String get updateIsRequired => 'La mise à jour est requise pour continuer';

  @override
  String get yourCurrentVersion => 'Votre version actuelle';

  @override
  String get updateAvailable => 'Une mise à jour est disponible. Veuillez mettre à jour pour continuer à utiliser l\'application.';

  @override
  String get updateAvailableOptional => 'Une nouvelle version est disponible. Mettez à jour pour obtenir les dernières fonctionnalités.';

  @override
  String get appUpToDate => 'Votre application est à jour!';

  @override
  String get accountStatus => 'Statut du compte';

  @override
  String get areYouSureLogout => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get cancel => 'Annuler';

  @override
  String get theme => 'Thème';

  @override
  String get light => 'Clair';

  @override
  String get dark => 'Sombre';

  @override
  String get system => 'Système';

  @override
  String get pleaseEnterEmail => 'Veuillez entrer votre e-mail';

  @override
  String get pleaseEnterValidEmail => 'Veuillez entrer un e-mail valide';

  @override
  String get pleaseEnterPassword => 'Veuillez entrer votre mot de passe';

  @override
  String get passwordMinLength => 'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get newEmailAddress => 'Nouvelle adresse e-mail';

  @override
  String get currentPassword => 'Mot de passe actuel';

  @override
  String get newEmailMustBeDifferent => 'La nouvelle adresse e-mail doit être différente de l\'adresse e-mail actuelle';

  @override
  String get day => 'jour';

  @override
  String get week => 'Semaine';

  @override
  String get month => 'Mois';

  @override
  String get year => 'Année';

  @override
  String get dateRange => 'Plage de dates';

  @override
  String get selectPeriod => 'Sélectionner la période';

  @override
  String get from => 'De';

  @override
  String get to => 'À';

  @override
  String get selectDate => 'Sélectionner la date';

  @override
  String get errorLoadingStatistics => 'Erreur lors du chargement des statistiques';

  @override
  String get noStatisticsAvailable => 'Aucune statistique disponible';

  @override
  String get overview => 'Aperçu';

  @override
  String get totalOrders => 'Total des commandes';

  @override
  String get accepted => 'Accepté';

  @override
  String get pending => 'En attente';

  @override
  String get rejected => 'Rejeté';

  @override
  String get performanceMetrics => 'Métriques de performance';

  @override
  String get averageRespondingTime => 'Temps de réponse moyen';

  @override
  String get acceptedOrdersSuccessRate => 'Taux de bonnes décisions';

  @override
  String get acceptedOrdersSuccessRateExplanation => 'Mesure le nombre de commandes acceptées qui ont été livrées avec succès. Il s\'agit d\'une métrique positive qui se concentre sur les succès.';

  @override
  String get acceptedOrdersSuccessRateGood => 'Un taux de succès élevé signifie que vous acceptez des commandes que vous pouvez honorer de manière fiable.';

  @override
  String get acceptedOrdersSuccessRateBad => 'Un taux de succès faible indique des problèmes - vérifiez votre capacité.';

  @override
  String get acceptedOrdersFailureRate => 'Taux de mauvaises décisions';

  @override
  String get acceptedOrdersFailureRateExplanation => 'Mesure le nombre de commandes acceptées qui ont échoué pour une raison quelconque (annulées, retournées, refusées par le client, non livrées). Il s\'agit d\'une métrique négative qui se concentre sur les échecs.';

  @override
  String get acceptedOrdersFailureRateGood => 'Un faible taux d\'échec montre une gestion fiable des commandes.';

  @override
  String get acceptedOrdersFailureRateBad => 'Un taux d\'échec élevé nuit à la réputation - analysez pourquoi les commandes échouent.';

  @override
  String get averageRespondingTimeExplanation => 'Mesure le temps moyen qu\'il faut à l\'opérateur pour répondre à une commande (accepter ou rejeter) après sa création.';

  @override
  String get averageRespondingTimeGood => 'Des temps de réponse rapides mènent à une meilleure satisfaction client et plus de commandes acceptées.';

  @override
  String get averageRespondingTimeBad => 'Des temps de réponse lents peuvent entraîner des annulations et des clients mécontents.';

  @override
  String get whenGood => 'Quand c\'est bien';

  @override
  String get whenBad => 'Quand c\'est mauvais';

  @override
  String get close => 'Fermeture';

  @override
  String get orderBreakdown => 'Répartition des commandes';

  @override
  String get all => 'Tout';

  @override
  String get second => 'seconde';

  @override
  String get seconds => 'secondes';

  @override
  String get minute => 'minute';

  @override
  String get minutes => 'minutes';

  @override
  String get hour => 'heure';

  @override
  String get hours => 'heures';

  @override
  String get days => 'jours';

  @override
  String get errorGeneric => 'Une erreur s\'est produite. Veuillez réessayer.';

  @override
  String get errorNetworkTimeout => 'La demande a expiré. Veuillez vérifier votre connexion Internet et réessayer.';

  @override
  String get errorConnectionError => 'Impossible de se connecter au serveur. Veuillez vérifier votre connexion Internet et vous assurer que le serveur fonctionne.';

  @override
  String get errorRequestCancelled => 'La demande a été annulée. Veuillez réessayer.';

  @override
  String get errorNetworkGeneric => 'Une erreur réseau s\'est produite. Veuillez vérifier votre connexion Internet et réessayer.';

  @override
  String get errorInvalidRequest => 'Demande invalide. Veuillez vérifier vos entrées et réessayer.';

  @override
  String get errorSessionExpired => 'Votre session a expiré. Veuillez vous reconnecter.';

  @override
  String get errorNoPermission => 'Vous n\'avez pas la permission d\'effectuer cette action.';

  @override
  String get errorNotFound => 'La ressource demandée est introuvable.';

  @override
  String get errorConflict => 'Cette action entre en conflit avec l\'état actuel. Veuillez actualiser et réessayer.';

  @override
  String get errorValidation => 'Erreur de validation. Veuillez vérifier vos entrées.';

  @override
  String get errorTooManyRequests => 'Trop de demandes. Veuillez attendre un moment et réessayer.';

  @override
  String get errorServerUnavailable => 'Service temporairement indisponible. Veuillez réessayer plus tard.';

  @override
  String get errorServerGeneric => 'Une erreur serveur s\'est produite. Veuillez réessayer plus tard.';

  @override
  String get errorDatabaseLocal => 'Impossible d\'enregistrer les données localement. Veuillez réessayer.';

  @override
  String get errorCacheLoad => 'Impossible de charger les données en cache. Veuillez actualiser.';

  @override
  String get errorAuthFailed => 'L\'authentification a échoué. Veuillez vérifier vos identifiants et réessayer.';

  @override
  String get errorInvalidCredentials => 'E-mail ou mot de passe invalide. Veuillez vérifier vos identifiants et réessayer.';

  @override
  String get errorAuthRequired => 'Authentification requise. Veuillez vous reconnecter.';

  @override
  String get errorSignInCancelled => 'La connexion a été annulée.';

  @override
  String get errorServerMaintenance => 'Service temporairement indisponible pour maintenance. Veuillez réessayer plus tard.';

  @override
  String get errorDatabaseServer => 'Une erreur de base de données s\'est produite. Veuillez réessayer plus tard.';

  @override
  String get errorLoadingOrders => 'Erreur lors du chargement des commandes';

  @override
  String get order => 'Commande';

  @override
  String get customer => 'Client';

  @override
  String get restaurant => 'Restaurant';

  @override
  String get description => 'Description';

  @override
  String get address => 'Adresse';

  @override
  String get isOpen => 'Est ouvert';

  @override
  String get restaurantAndNotes => 'Restaurant et Notes';

  @override
  String get notes => 'Notes';

  @override
  String get rejectionReason => 'Raison';

  @override
  String get deliveryInstructions => 'Instructions de livraison';

  @override
  String get confirm => 'Confirmer';

  @override
  String get reject => 'Rejeter';

  @override
  String get startPreparing => 'Commencer la préparation';

  @override
  String get markReady => 'Marquer comme prêt';

  @override
  String get pickedUp => 'Récupéré';

  @override
  String get markDelivered => 'Marquer comme livré';

  @override
  String get loadMore => 'Charger plus';

  @override
  String get noPendingOrders => 'Aucune commande en attente';

  @override
  String get noPendingOrdersDescription => 'Il n\'y a aucune commande en attente dans cette plage de dates.';

  @override
  String get noOngoingOrders => 'Aucune commande en cours';

  @override
  String get noOngoingOrdersDescription => 'Il n\'y a aucune commande en cours dans cette plage de dates.';

  @override
  String get selectDeliveryMethod => 'Sélectionner la méthode de livraison';

  @override
  String get selfDelivery => 'Livraison propre';

  @override
  String get externalDelivery => 'Livraison externe';

  @override
  String get selfDeliveryDescription => 'Le restaurant livrera la commande avec son propre chauffeur';

  @override
  String get externalDeliveryDescription => 'La commande sera récupérée par des chauffeurs tiers';

  @override
  String get pleaseSelectDeliveryMethod => 'Veuillez sélectionner une méthode de livraison avant de marquer la commande comme prête';

  @override
  String get drivers => 'Chauffeurs';

  @override
  String get addDriver => 'Ajouter un chauffeur';

  @override
  String get editDriver => 'Modifier le chauffeur';

  @override
  String get deleteDriver => 'Supprimer le chauffeur';

  @override
  String get driverCode => 'Code du chauffeur';

  @override
  String get driverCodeRequired => 'Le code du chauffeur est requis';

  @override
  String get noDriversAdded => 'Aucun chauffeur ajouté pour le moment';

  @override
  String get pleaseAddDriverBeforeSelfDelivery => 'Veuillez ajouter un chauffeur dans votre profil avant de choisir la livraison propre.';

  @override
  String get selectDriversForDelivery => 'Sélectionner les chauffeurs pour la livraison';

  @override
  String get selectAllDrivers => 'Sélectionner tous les chauffeurs';

  @override
  String get selectSpecificDrivers => 'Sélectionner des chauffeurs spécifiques';

  @override
  String driverSelected(int count) {
    return '$count chauffeur(s) sélectionné(s)';
  }

  @override
  String get driverCodeNotFound => 'Code chauffeur introuvable. Veuillez entrer un code chauffeur valide.';

  @override
  String get driverAlreadyLinked => 'Ce chauffeur est déjà lié à votre restaurant.';

  @override
  String get driverLinkedSuccessfully => 'Chauffeur lié avec succès!';

  @override
  String get requestTimeout => 'Délai d\'attente de la requête';

  @override
  String get requestTimeoutDescription => 'La requête a pris trop de temps à se terminer. Veuillez vérifier votre connexion Internet et réessayer.';

  @override
  String get call => 'Appeler';

  @override
  String get failedToOpenPhoneApp => 'Échec de l\'ouverture de l\'application téléphone';

  @override
  String get errorMakingPhoneCall => 'Erreur lors de l\'appel téléphonique';

  @override
  String get ordersLoadedSuccessfully => 'Commandes chargées avec succès';

  @override
  String get orderConfirmedSuccessfully => 'Commande confirmée avec succès';

  @override
  String get orderRejectedSuccessfully => 'Commande rejetée avec succès';

  @override
  String get confirmOrder => 'Confirmer';

  @override
  String get areYouSureConfirmOrder => 'Êtes-vous sûr de vouloir confirmer cette commande ?';

  @override
  String get confirmOrderDescription => 'Cela approuvera la commande et la rendra visible au restaurant.';

  @override
  String get pleaseSelectRejectReason => 'Veuillez sélectionner une raison pour rejeter cette commande :';

  @override
  String get enterYourReason => 'Entrez votre raison...';

  @override
  String get rejectReasonDidntPickUp => 'N\'a pas répondu au téléphone';

  @override
  String get rejectReasonSuspiciousBehavior => 'Comportement suspect du client';

  @override
  String get rejectReasonInvalidAddress => 'Adresse de livraison invalide';

  @override
  String get rejectReasonUnrealisticAmount => 'Le montant de la commande semble irréaliste';

  @override
  String get rejectReasonInvalidContact => 'Informations de contact du client invalides';

  @override
  String get rejectReasonRestaurantUnavailable => 'Restaurant non disponible';

  @override
  String get other => 'Autre';

  @override
  String get currentPasswordRequired => 'Le mot de passe actuel est requis';

  @override
  String get newPasswordRequired => 'Le nouveau mot de passe est requis';

  @override
  String get passwordMinLength8 => 'Le mot de passe doit contenir au moins 8 caractères';

  @override
  String get passwordComplexity => 'Le mot de passe doit contenir une majuscule, une minuscule, un chiffre et un symbole';

  @override
  String get pleaseConfirmNewPassword => 'Veuillez confirmer votre nouveau mot de passe';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get deleteAccountConfirmation => 'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible et toutes vos données seront définitivement supprimées.\n\nVous devrez vérifier votre identité avec un code OTP envoyé à votre adresse e-mail.';

  @override
  String get continueButton => 'Continuer';

  @override
  String errorOpeningUrl(String error) {
    return 'Erreur lors de l\'ouverture de l\'URL : $error';
  }

  @override
  String get appStoreUrlNotConfigured => 'L\'URL de l\'App Store n\'est pas configurée. Veuillez mettre à jour l\'application manuellement depuis l\'App Store.';

  @override
  String unableToDetermineAppPackage(String store) {
    return 'Impossible de déterminer le package de l\'application. Veuillez mettre à jour l\'application manuellement depuis $store.';
  }

  @override
  String unableToOpenStore(String store) {
    return 'Impossible d\'ouvrir $store. Veuillez mettre à jour l\'application manuellement.';
  }

  @override
  String errorOpeningAppStore(String error) {
    return 'Erreur lors de l\'ouverture du magasin d\'applications : $error. Veuillez mettre à jour l\'application manuellement.';
  }

  @override
  String get emailVerifiedSuccessfully => 'E-mail vérifié avec succès';

  @override
  String get failedToVerifyEmailOtp => 'Échec de la vérification de l\'OTP de l\'e-mail';

  @override
  String get requestTimeoutCheckConnection => 'Délai d\'attente de la requête dépassé. Veuillez vérifier votre connexion Internet et réessayer.';

  @override
  String get cannotConnectToServer => 'Impossible de se connecter au serveur. Veuillez vérifier votre connexion Internet.';

  @override
  String get verificationOtpSentSuccessfully => 'OTP de vérification envoyé avec succès. Veuillez vérifier votre e-mail.';

  @override
  String get failedToResendVerificationOtp => 'Échec de la réenvoi de l\'OTP de vérification';

  @override
  String get emailChangeOtpSentSuccessfully => 'OTP de changement d\'e-mail envoyé avec succès. Veuillez vérifier votre nouvel e-mail.';

  @override
  String get pleaseEnterValid6DigitOtp => 'Veuillez entrer un OTP valide à 6 chiffres';

  @override
  String get failedToGetLegalUrls => 'Échec de la récupération des URL légales';

  @override
  String get networkErrorCheckConnection => 'Erreur réseau. Veuillez vérifier votre connexion Internet.';

  @override
  String get serverErrorOccurred => 'Une erreur serveur s\'est produite';

  @override
  String get failedToGetContactInformation => 'Échec de la récupération des informations de contact';

  @override
  String unexpectedErrorOccurred(String error) {
    return 'Une erreur inattendue s\'est produite : $error';
  }

  @override
  String get appStore => 'App Store';

  @override
  String get playStore => 'Play Store';

  @override
  String get urlNotAvailable => 'URL non disponible. Veuillez réessayer plus tard.';

  @override
  String get unableToOpenUrlTryAgain => 'Impossible d\'ouvrir l\'URL. Veuillez réessayer.';

  @override
  String get unableToOpenUrlCheckConnection => 'Impossible d\'ouvrir l\'URL. Veuillez vérifier votre connexion Internet.';

  @override
  String get anErrorOccurred => 'Une erreur s\'est produite';

  @override
  String get openingHours => 'Heures d\'ouverture';

  @override
  String get closed => 'Fermé';

  @override
  String get monday => 'Lundi';

  @override
  String get tuesday => 'Mardi';

  @override
  String get wednesday => 'Mercredi';

  @override
  String get thursday => 'Jeudi';

  @override
  String get friday => 'Vendredi';

  @override
  String get saturday => 'Samedi';

  @override
  String get sunday => 'Dimanche';

  @override
  String get open => 'Ouverture';

  @override
  String get schedule => 'Horaire';

  @override
  String get restaurantIsOpen => 'Le restaurant est actuellement ouvert';

  @override
  String get restaurantIsClosed => 'Le restaurant est actuellement fermé';

  @override
  String get updateSchedule => 'Mettre à jour l\'horaire';

  @override
  String get driverAvailability => 'Disponibilité';

  @override
  String get driverIsAvailable => 'Vous êtes actuellement disponible pour les livraisons';

  @override
  String get driverIsUnavailable => 'Vous n\'êtes actuellement pas disponible pour les livraisons';

  @override
  String get unsavedChanges => 'Modifications non enregistrées';

  @override
  String get unsavedChangesMessage => 'Vous avez des modifications non enregistrées. Voulez-vous les enregistrer ou les annuler?';

  @override
  String get save => 'Enregistrer';

  @override
  String get discard => 'Annuler';

  @override
  String get selectLocationMethod => 'Sélectionner la méthode de localisation';

  @override
  String get manualEntry => 'Saisie manuelle';

  @override
  String get fromMap => 'Depuis la carte';

  @override
  String get selectLocationOnMap => 'Sélectionner l\'emplacement sur la carte';

  @override
  String get selectLocation => 'Sélectionner l\'emplacement';

  @override
  String get locationCoordinates => 'Coordonnées de l\'emplacement';

  @override
  String get enterCoordinatesManually => 'Entrer les coordonnées manuellement';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get latitudeRequired => 'La latitude est requise';

  @override
  String get longitudeRequired => 'La longitude est requise';

  @override
  String get invalidLatitude => 'Valeur de latitude invalide';

  @override
  String get invalidLongitude => 'Valeur de longitude invalide';

  @override
  String get latitudeRange => 'La latitude doit être entre -90 et 90';

  @override
  String get longitudeRange => 'La longitude doit être entre -180 et 180';

  @override
  String get menu => 'Menu';

  @override
  String get categories => 'Catégories';

  @override
  String get menuItems => 'Articles du menu';

  @override
  String get addCategory => 'Ajouter une catégorie';

  @override
  String get editCategory => 'Modifier la catégorie';

  @override
  String get deleteCategory => 'Supprimer la catégorie';

  @override
  String get addMenuItem => 'Ajouter un article';

  @override
  String get editMenuItem => 'Modifier l\'article';

  @override
  String get deleteMenuItem => 'Supprimer l\'article';

  @override
  String get categoryName => 'Nom de la catégorie';

  @override
  String get categoryDescription => 'Description de la catégorie';

  @override
  String get itemName => 'Nom de l\'article';

  @override
  String get itemDescription => 'Description de l\'article';

  @override
  String get itemPrice => 'Prix';

  @override
  String get preparationTime => 'Temps de préparation';

  @override
  String get ingredients => 'Ingrédients';

  @override
  String get allergens => 'Allergènes';

  @override
  String get nutritionalInfo => 'Informations nutritionnelles';

  @override
  String get image => 'Image';

  @override
  String get selectImage => 'Sélectionner une image';

  @override
  String get takePhoto => 'Prendre une photo';

  @override
  String get chooseFromGallery => 'Choisir dans la galerie';

  @override
  String get search => 'Rechercher';

  @override
  String get filter => 'Filtrer';

  @override
  String get bulkActions => 'Actions groupées';

  @override
  String get deleteSelected => 'Supprimer la sélection';

  @override
  String get toggleAvailability => 'Basculer la disponibilité';

  @override
  String get reorder => 'Réorganiser';

  @override
  String get dragToReorder => 'Glisser pour réorganiser';

  @override
  String get active => 'Actif';

  @override
  String get inactive => 'Inactif';

  @override
  String get edit => 'Modifier';

  @override
  String get delete => 'Supprimer';

  @override
  String get featured => 'En vedette';

  @override
  String get available => 'Disponible';

  @override
  String get unavailable => 'Indisponible';

  @override
  String get selected => 'Sélectionné';

  @override
  String get makeUnavailable => 'Rendre indisponible';

  @override
  String get makeAvailable => 'Rendre disponible';

  @override
  String get remove => 'Retirer';

  @override
  String get removeImage => 'Retirer l\'image';

  @override
  String get areYouSureYouWantToRemoveThisImage => 'Êtes-vous sûr de vouloir retirer cette image ?';

  @override
  String get noCategories => 'Aucune catégorie';

  @override
  String get noCategoriesDescription => 'Vous n\'avez pas encore créé de catégories. Appuyez sur le bouton + pour en ajouter une.';

  @override
  String get noMenuItems => 'Aucun article du menu';

  @override
  String get noMenuItemsDescription => 'Cette catégorie n\'a pas encore d\'articles. Appuyez sur le bouton + pour en ajouter un.';

  @override
  String get areYouSureDeleteCategory => 'Êtes-vous sûr de vouloir supprimer cette catégorie ?';

  @override
  String get areYouSureDeleteMenuItem => 'Êtes-vous sûr de vouloir supprimer cet article du menu ?';

  @override
  String areYouSureDeleteSelected(int count) {
    return 'Êtes-vous sûr de vouloir supprimer $count article(s) sélectionné(s) ?';
  }

  @override
  String categoryHasItems(int count) {
    return 'Cette catégorie contient $count article(s). Veuillez d\'abord supprimer ou déplacer les articles.';
  }

  @override
  String get categoryNameRequired => 'Le nom de la catégorie est requis';

  @override
  String get itemNameRequired => 'Le nom de l\'article est requis';

  @override
  String get priceRequired => 'Le prix est requis';

  @override
  String get priceInvalid => 'Le prix doit être supérieur à 0';

  @override
  String get preparationTimeRequired => 'Le temps de préparation est requis';

  @override
  String get preparationTimeInvalid => 'Le temps de préparation doit être d\'au moins 1 minute';

  @override
  String get categoryRequired => 'La catégorie est requise';

  @override
  String get addIngredient => 'Ajouter un ingrédient';

  @override
  String get addAllergen => 'Ajouter un allergène';

  @override
  String get sortOrder => 'Ordre de tri';

  @override
  String get isActive => 'Est actif';

  @override
  String get isAvailable => 'Est disponible';

  @override
  String get isFeatured => 'Est en vedette';

  @override
  String get clearFilters => 'Effacer les filtres';

  @override
  String get sortByName => 'Trier par nom';

  @override
  String get sortByPrice => 'Trier par prix';

  @override
  String get sortByOrder => 'Trier par ordre';

  @override
  String get sortAscending => 'Croissant';

  @override
  String get sortDescending => 'Décroissant';

  @override
  String get minPrice => 'Prix minimum';

  @override
  String get maxPrice => 'Prix maximum';

  @override
  String get selectCategory => 'Sélectionner une catégorie';

  @override
  String get categoryCreatedSuccessfully => 'Catégorie créée avec succès';

  @override
  String get categoryUpdatedSuccessfully => 'Catégorie mise à jour avec succès';

  @override
  String get categoryDeletedSuccessfully => 'Catégorie supprimée avec succès';

  @override
  String get menuItemCreatedSuccessfully => 'Article du menu créé avec succès';

  @override
  String get menuItemUpdatedSuccessfully => 'Article du menu mis à jour avec succès';

  @override
  String get menuItemDeletedSuccessfully => 'Article du menu supprimé avec succès';

  @override
  String get menuItemsUpdatedSuccessfully => 'Articles du menu mis à jour avec succès';

  @override
  String get menuItemsDeletedSuccessfully => 'Articles du menu supprimés avec succès';

  @override
  String get categoriesReorderedSuccessfully => 'Catégories réorganisées avec succès';

  @override
  String get menuItemsReorderedSuccessfully => 'Articles du menu réorganisés avec succès';

  @override
  String get bank => 'Banque';

  @override
  String get totalExpected => 'Total attendu';

  @override
  String get driverDebts => 'Dettes des chauffeurs';

  @override
  String get pendingPayments => 'Paiements en attente';

  @override
  String get noPendingTransactions => 'Aucune transaction en attente';

  @override
  String get errorLoadingData => 'Erreur de chargement des données';

  @override
  String get noDataAvailable => 'Aucune donnée disponible';

  @override
  String get restaurantSystemManagerDebt => 'Dette du restaurant au gestionnaire système';

  @override
  String get restaurantDebtToSystem => 'La dette du restaurant envers le système';

  @override
  String get restaurantSystemManagerDebtDescription => 'Montant que le restaurant doit au gestionnaire système (10% du total de la commande)';

  @override
  String get amount => 'Montant';

  @override
  String get driver => 'Chauffeur';

  @override
  String get expectedFromDrivers => 'Attendu des chauffeurs';

  @override
  String get payToSystemAdministrator => 'Payer à l\'administrateur système';

  @override
  String get transactions => 'Transactions';

  @override
  String get bankArchive => 'Archives bancaires';

  @override
  String get createTransaction => 'Créer une transaction';

  @override
  String get paySystem => 'Payer le système';

  @override
  String get calculatingAmount => 'Calcul du montant...';

  @override
  String get amountCalculated => 'Montant calculé';

  @override
  String get noAmountForRange => 'Aucun montant dû pour la période sélectionnée';

  @override
  String get amountFieldReadOnly => 'Le montant est calculé automatiquement en fonction de la période sélectionnée';

  @override
  String get pendingApprovals => 'Approbations en attente';

  @override
  String get myPendingTransactions => 'Mes transactions en attente';

  @override
  String get transactionHistory => 'Historique des transactions';

  @override
  String get filterByType => 'Filtrer par type';

  @override
  String get filterByDate => 'Filtrer par date';

  @override
  String get waitingForApproval => 'En attente d\'approbation';

  @override
  String get approvedBy => 'Approuvé par';

  @override
  String get rejectedBy => 'Rejeté par';

  @override
  String get breakdownByDriver => 'Répartition par chauffeur';

  @override
  String get breakdown => 'Détails';

  @override
  String get transactionType => 'Type';

  @override
  String get paymentToDriver => 'Du chauffeur';

  @override
  String get paymentToSystem => 'Paiement au système';

  @override
  String get selectDriver => 'Sélectionner un chauffeur';

  @override
  String get enterAmount => 'Entrer le montant';

  @override
  String get submit => 'Soumettre';

  @override
  String get approve => 'Approuver';

  @override
  String get date => 'Date';

  @override
  String get status => 'Statut';

  @override
  String get confirmCancellation => 'Confirmer l\'annulation';

  @override
  String get cancelTransactionConfirmation => 'Êtes-vous sûr de vouloir annuler cette transaction ? Cette action ne peut pas être annulée.';

  @override
  String get no => 'Non';

  @override
  String get yesCancel => 'Oui, annuler';

  @override
  String get receivables => 'Créances';

  @override
  String get payables => 'Dettes';

  @override
  String get receivablesAndPayables => 'Créances et dettes';

  @override
  String get newTransaction => 'Nouvelle transaction';

  @override
  String get pendingTransactions => 'Transactions en Attente';

  @override
  String get transactionsHistory => 'Historique des transactions';

  @override
  String get ratings => 'Évaluations';

  @override
  String get ratingsTitle => 'Évaluations des clients';

  @override
  String get ratingsDetailTitle => 'Détails de l\'évaluation';

  @override
  String ratingsBasedOn(String count) {
    return 'Basé sur $count évaluations';
  }

  @override
  String get ratingsAnonymous => 'Client anonyme';

  @override
  String get ratingsResponded => 'Répondu';

  @override
  String get ratingsReplyNow => 'Répondre maintenant';

  @override
  String get ratingsResponseSuccess => 'Réponse envoyée avec succès';

  @override
  String get ratingsOverallRating => 'Évaluation globale';

  @override
  String get ratingsDate => 'Date';

  @override
  String get ratingsWouldReorder => 'Commanderait à nouveau';

  @override
  String get ratingsWouldRecommend => 'Recommanderait';

  @override
  String get ratingsDetailedRatings => 'Évaluations détaillées';

  @override
  String get ratingsFoodQuality => 'Qualité de la nourriture';

  @override
  String get ratingsDeliverySpeed => 'Vitesse de livraison';

  @override
  String get ratingsDriver => 'Chauffeur';

  @override
  String get ratingsService => 'Service';

  @override
  String get ratingsComments => 'Commentaires';

  @override
  String get ratingsGeneralComment => 'Commentaire général';

  @override
  String get ratingsFoodComment => 'Commentaire sur la nourriture';

  @override
  String get ratingsDeliveryComment => 'Commentaire sur la livraison';

  @override
  String get ratingsDriverComment => 'Commentaire sur le chauffeur';

  @override
  String get ratingsRestaurantComment => 'Commentaire sur le restaurant';

  @override
  String get ratingsTags => 'Tags';

  @override
  String get ratingsYourResponse => 'Votre réponse';

  @override
  String get ratingsWriteResponse => 'Écrire une réponse';

  @override
  String get ratingsResponseHint => 'Remerciez le client ou répondez à ses commentaires...';

  @override
  String get ratingsResponseRequired => 'Veuillez entrer une réponse';

  @override
  String get ratingsResponseMinLength => 'La réponse doit contenir au moins 10 caractères';

  @override
  String get ratingsSubmitResponse => 'Envoyer la réponse';

  @override
  String get ratingsEmptyTitle => 'Pas encore d\'évaluations';

  @override
  String get ratingsEmptyMessage => 'Les évaluations des clients apparaîtront ici une fois reçues.';

  @override
  String get ratingsLoadMore => 'Charger plus';

  @override
  String get ratingsFilterAll => 'Tout';

  @override
  String get ratingsFilterPositive => 'Positives';

  @override
  String get ratingsFilterNegative => 'Négatives';

  @override
  String get orderCounts => 'Nombre de commandes';

  @override
  String get performance => 'Performance';

  @override
  String get allTime => 'Tout le temps';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get thisWeek => 'Cette semaine';

  @override
  String get thisMonth => 'Ce mois';

  @override
  String get thisYear => 'Cette année';

  @override
  String get custom => 'Personnalisé';

  @override
  String get responseSpeed => 'Vitesse de réponse';

  @override
  String get responseSpeedDescription => 'Temps pour accepter ou rejeter';

  @override
  String get preparationSpeed => 'Vitesse de préparation';

  @override
  String get preparationSpeedDescription => 'Temps pour préparer les commandes';

  @override
  String get decisionQuality => 'Qualité des décisions';

  @override
  String get decisionQualityDescription => 'Taux de commandes terminées vs acceptées';

  @override
  String get poorDecisions => 'Mauvaises décisions';

  @override
  String get poorDecisionsDescription => 'Taux d\'annulation après acceptation';

  @override
  String get statisticsDataFrom => 'Données de';

  @override
  String get orderCapacity => 'Capacité de commandes';

  @override
  String canAcceptMoreOrders(int count) {
    return 'Vous pouvez accepter $count commande(s) supplémentaire(s)';
  }

  @override
  String get maxCapacityReached => 'Capacité maximale atteinte';

  @override
  String get preparing => 'En préparation';

  @override
  String get onDelivery => 'En livraison';

  @override
  String get noPreparingOrders => 'Aucune commande en préparation';

  @override
  String get noPreparingOrdersDescription => 'Les commandes en attente de préparation apparaîtront ici';

  @override
  String get noReadyOrders => 'Aucune commande prête';

  @override
  String get noReadyOrdersDescription => 'Les commandes prêtes à être récupérées apparaîtront ici';

  @override
  String get noDeliveringOrders => 'Aucune commande en livraison';

  @override
  String get noDeliveringOrdersDescription => 'Les commandes que vous livrez apparaîtront ici';

  @override
  String get markPickedUp => 'Marquer comme récupéré';

  @override
  String get navigateToRestaurant => 'Aller au restaurant';

  @override
  String get navigateToCustomer => 'Aller chez le client';

  @override
  String get rejectOrder => 'Rejeter la commande';

  @override
  String get selectRejectionReason => 'Sélectionnez une raison de rejet:';

  @override
  String get rejectionReasonTooFar => 'Trop loin de ma position';

  @override
  String get rejectionReasonLowEarnings => 'Gains trop faibles pour cette commande';

  @override
  String get rejectionReasonBadArea => 'Zone de livraison problématique';

  @override
  String get rejectionReasonBusy => 'Actuellement occupé avec d\'autres livraisons';

  @override
  String get rejectionReasonVehicleIssue => 'Problème de véhicule/transport';

  @override
  String get rejectionReasonPersonal => 'Raisons personnelles';

  @override
  String get rejectionReasonOther => 'Autre';

  @override
  String get additionalNotes => 'Notes supplémentaires (optionnel)';

  @override
  String get additionalNotesHint => 'Ajoutez des détails supplémentaires...';

  @override
  String get confirmRejection => 'Rejeter';

  @override
  String get orderRejected => 'Commande rejetée';

  @override
  String get noRejectedOrders => 'Aucune commande rejetée';

  @override
  String get rejectedAt => 'Rejeté le';

  @override
  String get unassignOrder => 'Se désassigner de la commande';

  @override
  String get selectUnassignReason => 'Pourquoi ne pouvez-vous pas terminer cette commande ?';

  @override
  String get unassignReasonVehicleBreakdown => 'Panne de véhicule';

  @override
  String get unassignReasonPersonalEmergency => 'Urgence personnelle';

  @override
  String get unassignReasonSafetyConcern => 'Problème de sécurité sur place';

  @override
  String get unassignReasonCannotReach => 'Impossible d\'atteindre le lieu de prise en charge/livraison';

  @override
  String get unassignReasonLongWait => 'Temps d\'attente au restaurant trop long';

  @override
  String get unassignReasonOrderIssue => 'Problème avec la commande (articles manquants, mauvaise commande)';

  @override
  String get unassignReasonOther => 'Autre raison';

  @override
  String get confirmUnassign => 'Se désassigner';

  @override
  String get orderUnassigned => 'Désassigné de la commande';

  @override
  String get unassignOnDeliveryWarning => 'Urgence uniquement ! Se désassigner pendant la livraison est grave et sera examiné. N\'utilisez que pour de véritables urgences.';

  @override
  String get unassignReadyWarning => 'La nourriture est prête et attend. Se désassigner maintenant peut affecter la qualité de la nourriture pour le client.';

  @override
  String get unassignEmergencyNotesHint => 'Veuillez décrire la situation d\'urgence...';

  @override
  String get unassignConsequenceNotice => 'Les désassignements fréquents peuvent affecter vos métriques de conducteur. La commande retournera dans le pool disponible.';

  @override
  String get cantCompleteOrder => 'Impossible de terminer';

  @override
  String get totalDebt => 'Dette totale';

  @override
  String get systemDebt => 'Dette système';

  @override
  String get systemDebtDescription => 'Montant dû au gestionnaire du système pour les frais de livraison';

  @override
  String get restaurantDebts => 'Dettes restaurant';

  @override
  String get restaurantCredits => 'Restaurants';

  @override
  String get recordPayment => 'Enregistrer le paiement';

  @override
  String get recordSystemPayment => 'Enregistrer le paiement système';

  @override
  String get paySystemDebt => 'Payer la dette système';

  @override
  String get paymentToRestaurant => 'Paiement au restaurant';

  @override
  String get noDebts => 'Aucune dette en cours';

  @override
  String get confirmedAt => 'Confirmé le';

  @override
  String get invalidAmount => 'Montant invalide';

  @override
  String get record => 'Enregistrer';

  @override
  String get noTransactionsFound => 'Aucune transaction trouvée';

  @override
  String get paymentType => 'Type de paiement';

  @override
  String get selectRestaurant => 'Sélectionner un restaurant';

  @override
  String get paymentDate => 'Date de paiement';

  @override
  String get totalCredits => 'Total Credits';

  @override
  String get overpay => 'Paiement excédentaire';

  @override
  String get credit => 'Crédit';

  @override
  String get pickupSpeed => 'Vitesse de récupération';

  @override
  String get pickupSpeedDescription => 'Temps entre la préparation et la récupération';

  @override
  String get pickupSpeedGood => 'Une récupération rapide (moins de 10 minutes) garantit une nourriture fraîche et des clients satisfaits.';

  @override
  String get pickupSpeedBad => 'Une récupération lente (plus de 20 minutes) peut entraîner une nourriture froide et des clients mécontents.';

  @override
  String get deliverySpeed => 'Vitesse de livraison';

  @override
  String get deliverySpeedDescription => 'Temps entre la récupération et la livraison';

  @override
  String get deliverySpeedGood => 'Une livraison rapide (moins de 20 minutes) mène à des clients satisfaits et de meilleures notes.';

  @override
  String get deliverySpeedBad => 'Une livraison lente (plus de 40 minutes) peut entraîner des plaintes et des notes plus basses.';

  @override
  String get completionRate => 'Taux de réalisation';

  @override
  String get completionRateDescription => 'Pourcentage de commandes acceptées qui ont été livrées';

  @override
  String get completionRateGood => 'Un taux élevé (95%+) montre fiabilité et professionnalisme.';

  @override
  String get completionRateBad => 'Un taux bas (moins de 85%) indique des problèmes dans la gestion des commandes.';

  @override
  String get cancellationRate => 'Taux d\'annulation';

  @override
  String get cancellationRateDescription => 'Pourcentage de commandes acceptées qui ont été annulées';

  @override
  String get cancellationRateGood => 'Un taux bas (moins de 5%) est excellent et montre un service constant.';

  @override
  String get cancellationRateBad => 'Un taux élevé (plus de 15%) soulève des inquiétudes sur la fiabilité.';

  @override
  String get iHaveArrived => 'Je suis arrivé';

  @override
  String get arrived => 'Arrivé';

  @override
  String get driverArrived => 'Chauffeur arrivé';

  @override
  String get ok => 'OK';

  @override
  String get understood => 'Compris';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get wrongApp => 'Mauvaise application';

  @override
  String get accountNotFound => 'Compte non trouvé';

  @override
  String get accountNotFoundMessage => 'Aucun compte trouvé avec cet e-mail. Veuillez d\'abord vous inscrire.';

  @override
  String get loginFailed => 'Échec de la connexion';

  @override
  String get invalidCredentialsMessage => 'L\'e-mail ou le mot de passe que vous avez entré est incorrect. Veuillez vérifier vos identifiants et réessayer.';
}
