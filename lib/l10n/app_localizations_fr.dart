// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Appli Gestionnaire';

  @override
  String get login => 'Connexion';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get name => 'Nom';

  @override
  String get phone => 'Téléphone';

  @override
  String get rememberMe => 'Se souvenir de moi';

  @override
  String get forgotPassword => 'Mot de passe oublié';

  @override
  String get signInWithGoogle => 'Se connecter avec Google';

  @override
  String get checkingAuthentication => 'Vérification de l\'authentification...';

  @override
  String get logout => 'Déconnexion';

  @override
  String get language => 'Langue';

  @override
  String get or => 'OU';

  @override
  String get profile => 'Profil';

  @override
  String get userType => 'Type d\'utilisateur';

  @override
  String get settings => 'Paramètres';

  @override
  String get appSettings => 'Paramètres de l\'application';

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
  String get aboutDescription => 'L\'application Gestionnaire vous donne une supervision complète de toute la plateforme de livraison. Approuvez les utilisateurs, surveillez les performances, configurez les paramètres système et gérez les coupons — le tout depuis un tableau de bord d\'administration puissant.';

  @override
  String get features => 'Fonctionnalités';

  @override
  String get userAuthentication => 'Gestion des utilisateurs';

  @override
  String get userAuthenticationDescription => 'Approuver les livreurs, restaurants et opérateurs, et gérer les suspensions de comptes';

  @override
  String get multiLanguageSupport => 'Analyses et rapports';

  @override
  String get multiLanguageSupportDescription => 'Suivre les revenus, les tendances des commandes et les performances de la plateforme via des tableaux de bord détaillés';

  @override
  String get secureStorage => 'Paramètres système';

  @override
  String get secureStorageDescription => 'Configurer les frais de livraison, les taux de commission et les règles opérationnelles de la plateforme';

  @override
  String get googleSignIn => 'Coupons';

  @override
  String get googleSignInDescription => 'Créer des coupons, fixer leurs limites et les zones où ils s’appliquent';

  @override
  String get contactUs => 'Nous contacter';

  @override
  String copyright(String year) {
    return '© $year Appli Gestionnaire. Tous droits réservés.';
  }

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
  String get refresh => 'Actualiser';

  @override
  String get total => 'Total';

  @override
  String get deliveryFee => 'Frais de livraison';

  @override
  String get confirmed => 'Confirmé';

  @override
  String get statistics => 'Statistiques';

  @override
  String get statisticsMoney => 'Argent';

  @override
  String get statisticsOrders => 'Commandes';

  @override
  String get ordersPlaced => 'Commandes';

  @override
  String get ordersPendingVerification => 'En attente de vérification';

  @override
  String get ordersAcceptedByOperator => 'Acceptées par l\'opérateur';

  @override
  String get ordersAcceptedByRestaurant => 'Acceptées par le restaurant';

  @override
  String get ordersRejectedByOperator => 'Rejetées par l\'opérateur';

  @override
  String get ordersRejectedByRestaurant => 'Rejetées par le restaurant';

  @override
  String get ordersAcceptedByDriver => 'Acceptées par le livreur';

  @override
  String get ordersCancelled => 'Annulées';

  @override
  String get noUserDataAvailable => 'Aucune donnée utilisateur disponible';

  @override
  String get user => 'Utilisateur';

  @override
  String get delivered => 'Livré';

  @override
  String get resetPassword => 'Réinitialiser le mot de passe';

  @override
  String get resetYourPassword => 'Réinitialiser votre mot de passe';

  @override
  String get enterEmailDescription => 'Entrez votre adresse email et nous vous enverrons un code OTP pour réinitialiser votre mot de passe.';

  @override
  String get emailAddress => 'Adresse email';

  @override
  String get sendOtp => 'Envoyer OTP';

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
  String get emailNotVerified => 'E-mail non vérifié';

  @override
  String get emailVerificationRequired => 'Veuillez vérifier votre adresse e-mail avant d\'accéder à cette ressource. Un code de vérification (OTP) a été envoyé à votre adresse e-mail. Veuillez vérifier votre boîte de réception et entrer le code à 6 chiffres pour vérifier votre e-mail.';

  @override
  String get resendVerificationEmail => 'Renvoyer la vérification';

  @override
  String get checkStatus => 'Vérifier le statut';

  @override
  String get checkStatusDescription => 'Appuyez sur \"Vérifier le statut\" pour voir si votre compte a été approuvé';

  @override
  String get initializing => 'Initialisation...';

  @override
  String get initializationFailed => 'Échec de l\'initialisation';

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
  String get month => 'Mois';

  @override
  String get year => 'Année';

  @override
  String get dateRange => 'Plage de dates';

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
  String get acceptedOrdersSuccessRateGood => 'Un taux de succès élevé signifie que vous acceptez des commandes que vous pouvez honorer de manière fiable.';

  @override
  String get acceptedOrdersSuccessRateBad => 'Un taux de succès faible indique des problèmes - vérifiez votre capacité.';

  @override
  String get acceptedOrdersFailureRateGood => 'Un faible taux d\'échec montre une gestion fiable des commandes.';

  @override
  String get acceptedOrdersFailureRateBad => 'Un taux d\'échec élevé nuit à la réputation - analysez pourquoi les commandes échouent.';

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
  String get all => 'Tout';

  @override
  String get second => 'seconde';

  @override
  String get seconds => 'secondes';

  @override
  String get minute => 'minute';

  @override
  String get hour => 'heure';

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
  String get customer => 'Client';

  @override
  String get restaurant => 'Restaurant';

  @override
  String get description => 'Description';

  @override
  String get isOpen => 'Est ouvert';

  @override
  String get notes => 'Notes';

  @override
  String get rejectionReason => 'Raison';

  @override
  String get confirm => 'Confirmer';

  @override
  String get loadMore => 'Charger plus';

  @override
  String get drivers => 'Livreurs';

  @override
  String get call => 'Appeler';

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
  String get urlNotAvailable => 'URL non disponible. Veuillez réessayer plus tard.';

  @override
  String get closed => 'Fermé';

  @override
  String get sunday => 'Dimanche';

  @override
  String get open => 'Ouverture';

  @override
  String get unsavedChanges => 'Modifications non enregistrées';

  @override
  String get unsavedChangesMessage => 'Vous avez des modifications non enregistrées. Voulez-vous les enregistrer ou les annuler?';

  @override
  String get save => 'Enregistrer';

  @override
  String get discard => 'Ignorer';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get search => 'Rechercher';

  @override
  String get active => 'Actif';

  @override
  String get edit => 'Modifier';

  @override
  String get delete => 'Supprimer';

  @override
  String get selected => 'Sélectionné';

  @override
  String get remove => 'Retirer';

  @override
  String get isActive => 'Est actif';

  @override
  String get clearFilters => 'Effacer les filtres';

  @override
  String get bank => 'Banque';

  @override
  String get errorLoadingData => 'Erreur de chargement des données';

  @override
  String get noDataAvailable => 'Aucune donnée disponible';

  @override
  String get amount => 'Montant';

  @override
  String get driver => 'Livreur';

  @override
  String get transactions => 'Transactions';

  @override
  String get bankArchive => 'Archives bancaires';

  @override
  String get approvedBy => 'Approuvé par';

  @override
  String get transactionType => 'Type';

  @override
  String get selectDriver => 'Sélectionner un livreur';

  @override
  String get date => 'Date';

  @override
  String get status => 'Statut';

  @override
  String get receivables => 'Créances';

  @override
  String get payables => 'Dettes';

  @override
  String get receivablesAndPayables => 'Créances et dettes';

  @override
  String get newTransaction => 'Nouvelle transaction';

  @override
  String get transactionsHistory => 'Historique des transactions';

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
  String get noDebts => 'Aucune dette en cours';

  @override
  String get confirmedAt => 'Confirmé le';

  @override
  String get invalidAmount => 'Montant invalide';

  @override
  String get noTransactionsFound => 'Aucune transaction trouvée';

  @override
  String get paymentType => 'Type de paiement';

  @override
  String get selectRestaurant => 'Sélectionner un restaurant';

  @override
  String get paymentDate => 'Date de paiement';

  @override
  String get totalCredits => 'Total des Crédits';

  @override
  String get overpay => 'Paiement excédentaire';

  @override
  String get pickupSpeed => 'Vitesse de récupération';

  @override
  String get pickupSpeedDescription => 'Temps entre la préparation et la récupération';

  @override
  String get completionRate => 'Taux de réalisation';

  @override
  String get cancellationRate => 'Taux d\'annulation';

  @override
  String get cancellationRateDescription => 'Pourcentage de commandes acceptées qui ont été annulées';

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
  String get accountNotFoundMessage => 'Aucun compte gestionnaire n\'utilise cet e-mail. Les comptes gestionnaires sont créés par l\'équipe de la plateforme, pas dans l\'application.';

  @override
  String get loginFailed => 'Échec de la connexion';

  @override
  String get invalidCredentialsMessage => 'L\'e-mail ou le mot de passe que vous avez entré est incorrect. Veuillez vérifier vos identifiants et réessayer.';

  @override
  String get userManagement => 'Gestion des utilisateurs';

  @override
  String get errorLoadingUsers => 'Erreur de chargement des utilisateurs';

  @override
  String get noUsersFound => 'Aucun utilisateur trouvé';

  @override
  String get noUsersMatchFilters => 'Aucun utilisateur ne correspond à vos filtres';

  @override
  String get noUsersInSystem => 'Aucun utilisateur dans le système';

  @override
  String get userApprovedSuccessfully => 'Utilisateur approuvé avec succès';

  @override
  String get userRejectedSuccessfully => 'Utilisateur rejeté avec succès';

  @override
  String get userSuspendedSuccessfully => 'Utilisateur suspendu avec succès';

  @override
  String get userActivatedSuccessfully => 'Utilisateur activé avec succès';

  @override
  String get changeStatus => 'Changer le statut';

  @override
  String get pendingApproval => 'En attente d\'approbation';

  @override
  String get suspended => 'Suspendu';

  @override
  String get operator => 'Opérateur';

  @override
  String get manager => 'Gestionnaire';

  @override
  String get filters => 'Filtres';

  @override
  String get clear => 'Effacer';

  @override
  String get allRoles => 'Tous les rôles';

  @override
  String get allStatuses => 'Tous les statuts';

  @override
  String get rejectUser => 'Rejeter l\'utilisateur';

  @override
  String rejectingUser(String userName) {
    return 'Rejet en cours: $userName';
  }

  @override
  String get rejectionReasonLabel => 'Motif du rejet *';

  @override
  String get enterRejectionReason => 'Entrez le motif du rejet...';

  @override
  String get minimumCharacters => 'Minimum 10 caractères';

  @override
  String get rejectionReasonRequired => 'Le motif du rejet est obligatoire';

  @override
  String get reasonMinimum10Characters => 'Le motif doit contenir au moins 10 caractères';

  @override
  String get suspendUser => 'Suspendre l\'utilisateur';

  @override
  String suspendingUser(String userName) {
    return 'Suspension en cours: $userName';
  }

  @override
  String get suspensionReasonLabel => 'Motif de suspension *';

  @override
  String get enterSuspensionReason => 'Entrez le motif de suspension...';

  @override
  String get suspensionReasonRequired => 'Le motif de suspension est obligatoire';

  @override
  String get searchUsers => 'Rechercher par nom, e-mail ou téléphone';

  @override
  String get coupons => 'Coupons';

  @override
  String get restaurantCoupons => 'Coupons de restaurant';

  @override
  String get deliveryCoupons => 'Coupons de livraison';

  @override
  String get draft => 'Brouillon';

  @override
  String get disabled => 'Désactivé';

  @override
  String get newDeliveryCoupon => 'Nouveau coupon de livraison';

  @override
  String get newCoupon => 'Nouveau coupon';

  @override
  String get noDeliveryCouponsYet => 'Aucun coupon de livraison pour le moment';

  @override
  String get noCouponsYet => 'Aucun coupon pour le moment';

  @override
  String get createFirstDeliveryCoupon => 'Créez votre premier coupon de livraison!';

  @override
  String get createFirstCoupon => 'Créez votre premier coupon pour attirer plus de clients!';

  @override
  String get off => 'REMISE';

  @override
  String get discount => 'Remise';

  @override
  String get valid => 'Valide';

  @override
  String get uses => 'Utilisations';

  @override
  String get minOrder => 'Commande minimale';

  @override
  String get dzd => 'DZD';

  @override
  String get expired => 'Expiré';

  @override
  String get globalAllRestaurants => 'Global (tous les restaurants)';

  @override
  String get issuer => 'Émetteur: ';

  @override
  String get discardChanges => 'Ignorer les modifications?';

  @override
  String get editCoupon => 'Modifier le coupon';

  @override
  String get update => 'Mettre à jour';

  @override
  String get create => 'Créer';

  @override
  String get couponCode => 'Code du coupon';

  @override
  String get couponCodeHint => 'ex. SUMMER20';

  @override
  String get pleaseEnterCouponCode => 'Veuillez saisir un code de coupon';

  @override
  String get codeMinLength => 'Le code doit contenir au moins 3 caractères';

  @override
  String get type => 'Type';

  @override
  String get percentage => 'Pourcentage';

  @override
  String get fixedAmount => 'Montant fixe';

  @override
  String get value => 'Valeur';

  @override
  String get required => 'Requis';

  @override
  String get min1 => 'Min 1';

  @override
  String get max100Percent => 'Max 100%';

  @override
  String get discountAppliesTo => 'Réduction applicable à';

  @override
  String get orderSubtotal => 'Sous-total de la commande';

  @override
  String get validityPeriod => 'Période de validité';

  @override
  String get startDate => 'Date de début';

  @override
  String get endDate => 'Date de fin';

  @override
  String get restaurantOptional => 'Restaurant (Optionnel)';

  @override
  String get couponZonesOptional => 'Zones de coupon (Optionnel)';

  @override
  String get manageZones => 'Gérer les zones';

  @override
  String get usageLimitsOptional => 'Limites d\'utilisation (Optionnel)';

  @override
  String get totalUses => 'Utilisations totales';

  @override
  String get perCustomer => 'Par client';

  @override
  String get orderConstraintsOptional => 'Contraintes de commande (Optionnel)';

  @override
  String get minOrderDzd => 'Commande min (DZD)';

  @override
  String get maxDiscountDzd => 'Remise max (DZD)';

  @override
  String get descriptionOptional => 'Description (Optionnel)';

  @override
  String get internalNoteHint => 'Note interne sur ce coupon...';

  @override
  String get noCouponZonesAvailable => 'Aucune zone de coupon disponible. Créez des zones pour restreindre la disponibilité du coupon.';

  @override
  String get selectZonesInfo => 'Sélectionner les zones (s\'applique à tous si aucune sélection)';

  @override
  String get noRestaurantsAvailable => 'Aucun restaurant disponible. Ce coupon sera global.';

  @override
  String get selectedRestaurant => 'Restaurant sélectionné';

  @override
  String get allRestaurantsGlobal => 'Tous les restaurants (Global)';

  @override
  String get kmRadius => 'km de rayon';

  @override
  String get couponZones => 'Zones de coupon';

  @override
  String get addZone => 'Ajouter une zone';

  @override
  String get success => 'Succès!';

  @override
  String get errorOccurred => 'Une erreur s\'est produite';

  @override
  String get noCouponZonesYet => 'Aucune zone de coupon pour le moment';

  @override
  String get createZonesToRestrict => 'Créez des zones pour restreindre les coupons\\nà des zones spécifiques';

  @override
  String get createZone => 'Créer une zone';

  @override
  String get editZone => 'Modifier la zone';

  @override
  String get zoneNameRequired => 'Nom de la zone *';

  @override
  String get zoneNameHint => 'ex. Centre-ville';

  @override
  String get optionalDescription => 'Description optionnelle';

  @override
  String get latitudeHint => 'ex. 36.7538';

  @override
  String get longitudeHint => 'ex. 3.0588';

  @override
  String get radiusKm => 'Rayon (km)';

  @override
  String get radiusHint => 'ex. 5.0';

  @override
  String get km => 'km';

  @override
  String get zoneNameIsRequired => 'Le nom de la zone est requis';

  @override
  String get deleteZone => 'Supprimer la zone';

  @override
  String deleteZoneConfirmation(Object zoneName) {
    return 'Êtes-vous sûr de vouloir supprimer \"$zoneName\"?';
  }

  @override
  String get currency => 'DZD';

  @override
  String get revenueOverview => 'Aperçu';

  @override
  String get totalRevenue => 'Revenu total';

  @override
  String get subtotalRevenue => 'Sous-total nourriture';

  @override
  String get deliveryFeesCollected => 'Frais de livraison';

  @override
  String get platformEarnings => 'Revenus';

  @override
  String get platformRevenue => 'Revenu de la plateforme';

  @override
  String get platformShort => 'Plateforme';

  @override
  String get driverEarnings => 'Gains du livreur';

  @override
  String get driversShort => 'Livreurs';

  @override
  String get restaurantEarnings => 'Gains des restaurants';

  @override
  String get restaurantsShort => 'Restaurants';

  @override
  String get totalRevenueDesc => 'Montant total payé par les clients pour toutes les commandes livrées, incluant le coût des plats et les frais de livraison.';

  @override
  String get subtotalRevenueDesc => 'Total du coût des plats sur toutes les commandes livrées, hors frais de livraison.';

  @override
  String get deliveryFeesDesc => 'Total des frais de livraison facturés aux clients sur toutes les commandes livrées.';

  @override
  String get platformRevenueDesc => 'La commission de la plateforme : un pourcentage prélevé sur les commandes de nourriture des restaurants et sur les frais de livraison des livreurs.';

  @override
  String get driversRevenueDesc => 'Ce que les livreurs conservent réellement : frais de livraison collectés moins la commission de la plateforme sur les livraisons.';

  @override
  String get restaurantsRevenueDesc => 'Ce que les restaurants conservent réellement : revenus des commandes alimentaires moins la commission de la plateforme sur les plats.';

  @override
  String get restaurantEarningsSection => 'Gains';

  @override
  String get restaurantNetEarnings => 'Gains nets';

  @override
  String get driverEarningsSection => 'Gains';

  @override
  String get driverNetEarnings => 'Gains nets';

  @override
  String get averageOrderValueDesc => 'Montant total moyen (nourriture + livraison) par commande livrée dans la période sélectionnée.';

  @override
  String get orderMetrics => 'Métriques des commandes';

  @override
  String get averageOrderValue => 'Valeur moyenne des commandes';

  @override
  String get statisticsRatings => 'Évaluations';

  @override
  String get statisticsPerformance => 'Performance';

  @override
  String get deliveryPerformance => 'Performance de livraison';

  @override
  String get totalDeliveries => 'Total des livraisons';

  @override
  String get completedDeliveries => 'Livraisons complétées';

  @override
  String get cancelledDeliveries => 'Livraisons annulées';

  @override
  String get onTimeRate => 'Taux de ponctualité';

  @override
  String get avgDeliveryTime => 'Temps moy. de livraison';

  @override
  String get fastestDelivery => 'Livraison la plus rapide';

  @override
  String get slowestDelivery => 'Livraison la plus lente';

  @override
  String get totalDeliveriesDesc => 'Nombre total de commandes de livraison sur la période sélectionnée.';

  @override
  String get completedDeliveriesDesc => 'Commandes livrées avec succès au client.';

  @override
  String get cancelledDeliveriesDesc => 'Commandes annulées après avoir été acceptées.';

  @override
  String get completionRateDesc => 'Pourcentage des commandes acceptées qui ont été livrées avec succès.';

  @override
  String get avgDeliveryTimeDesc => 'Temps moyen en minutes entre la prise en charge et la livraison.';

  @override
  String get onTimeRateDesc => 'Pourcentage de livraisons effectuées dans le délai cible.';

  @override
  String get fastestDeliveryDesc => 'Le temps de livraison le plus court enregistré sur la période.';

  @override
  String get slowestDeliveryDesc => 'Le temps de livraison le plus long enregistré sur la période.';

  @override
  String get minutesAbbr => 'min';

  @override
  String get averageRating => 'Note moyenne';

  @override
  String get totalRatings => 'Total des évaluations';

  @override
  String get ratingDistribution => 'Distribution des notes';

  @override
  String get foodQualityRating => 'Qualité des aliments';

  @override
  String get restaurantServiceRating => 'Service du restaurant';

  @override
  String get deliverySpeedRating => 'Vitesse de livraison';

  @override
  String get reorderRate => 'Taux de récommande';

  @override
  String get recommendRate => 'Taux de recommandation';

  @override
  String get outOf5 => 'sur 5';

  @override
  String get restaurantsTab => 'Restaurants';

  @override
  String get reviews => 'avis';

  @override
  String get noRatingsYet => 'Aucune note pour l\'instant';

  @override
  String get driversTab => 'Livreurs';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get failedToLoadSettings => 'Impossible de charger les paramètres';

  @override
  String get noSettingsFound => 'Aucun paramètre trouvé';

  @override
  String get noSettingsInThisCategory => 'Aucun paramètre dans cette catégorie';

  @override
  String get settingUpdatedSuccessfully => 'Paramètre mis à jour';

  @override
  String get emptyInParentheses => '(vide)';

  @override
  String get currentValue => 'Valeur actuelle';

  @override
  String get keyLabel => 'Clé';

  @override
  String get editValue => 'Modifier la valeur';

  @override
  String get newValue => 'Nouvelle valeur';

  @override
  String get invalidRouteArguments => 'Arguments de navigation invalides';

  @override
  String get invalidAppVersionArgument => 'Information de version invalide';

  @override
  String get globalCoupons => 'Coupons globaux';

  @override
  String get enterVerificationCode => 'Entrer le code de vérification';

  @override
  String weSentVerificationCodeTo(Object email) {
    return 'Nous avons envoyé un code de vérification à $email';
  }

  @override
  String get confirmAccountDeletionCodeMessage => 'Veuillez entrer le code pour confirmer la suppression du compte. Cette action est irréversible.';

  @override
  String get unableToCheckForUpdates => 'Impossible de vérifier les mises à jour. Veuillez réessayer plus tard.';

  @override
  String get accountPendingApprovalMessage => 'Votre compte est en attente d\'approbation par un gestionnaire. Veuillez attendre qu\'un gestionnaire examine et approuve votre compte avant de pouvoir accéder au système. Vous serez notifié une fois votre compte approuvé.';

  @override
  String get accountSuspendedMessage => 'Votre compte a été suspendu. Veuillez contacter le support pour obtenir de l\'aide.';

  @override
  String get accountRejectedMessage => 'Votre compte a été rejeté. Veuillez contacter le support pour plus d\'informations.';

  @override
  String balanceForPeriod(String period) {
    return '(Solde : $period)';
  }

  @override
  String get updateLinkUnavailable => 'La mise à jour ne peut pas être ouverte sur cet appareil. Contactez-nous pour obtenir la nouvelle version.';

  @override
  String get pageNotFound => 'Page introuvable';

  @override
  String get accountApprovedRedirectingMessage => 'Votre compte a été approuvé ! Redirection...';

  @override
  String get accountPendingApproval => 'Compte en attente d\'approbation';

  @override
  String get accountPendingApprovalFallbackMessage => 'Votre compte est en attente d\'approbation par un gestionnaire. Veuillez patienter jusqu\'à ce qu\'un gestionnaire examine et approuve votre compte avant de pouvoir accéder au système.';

  @override
  String get accountRejected => 'Compte rejeté';

  @override
  String get accountSuspended => 'Compte suspendu';

  @override
  String get appFailedToInitializeProperly => 'L\'application n\'a pas pu démarrer correctement.';

  @override
  String get pleaseConfirmYourPassword => 'Veuillez confirmer votre mot de passe';

  @override
  String get nameIsRequired => 'Le nom est requis';

  @override
  String get nameTooShort => 'Le nom doit contenir au moins 2 caractères';

  @override
  String get phoneTooShort => 'Le numéro doit contenir au moins 10 chiffres';

  @override
  String usesUnlimited(int count) {
    return '$count (illimité)';
  }

  @override
  String get finalTotalGlobal => 'Total final (global)';

  @override
  String zonesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zones sélectionnées',
      one: '1 zone sélectionnée',
    );
    return '$_temp0';
  }

  @override
  String get settingsCategoryDelivery => 'Livraison';

  @override
  String get settingsCategoryFinancials => 'Finances';

  @override
  String get settingsCategoryCustomersOrders => 'Clients et commandes';

  @override
  String get settingsCategoryLoyaltyPromotions => 'Fidélité et promotions';

  @override
  String get settingsCategoryAccountsSecurity => 'Comptes et sécurité';

  @override
  String get settingsCategoryApiIntegrations => 'API et intégrations';

  @override
  String get settingsCategoryLegalContact => 'Mentions légales et contact';

  @override
  String get settingTypeText => 'Texte';

  @override
  String get settingTypeWhole => 'Nombre entier';

  @override
  String get settingTypeNumber => 'Nombre';

  @override
  String get settingTypeYesNo => 'Oui ou non';

  @override
  String get settingTypeList => 'Liste (JSON)';

  @override
  String get settingSystemManagerOrderPercentageName => 'Commission sur les commandes (%)';

  @override
  String get settingSystemManagerOrderPercentageRole => 'La part de la plateforme sur le sous-total des plats';

  @override
  String get settingSystemManagerOrderPercentageHelp => 'Le pourcentage du sous-total des plats de chaque commande que la plateforme garde comme commission. Par exemple, 10 signifie que la plateforme gagne 10 DZD pour chaque tranche de 100 DZD de plats commandés. Quand une commande est livrée, la banque l\'enregistre comme due par le restaurant à la plateforme (le livreur doit au restaurant tout le sous-total des plats).';

  @override
  String get settingSystemManagerDeliveryFeePercentageName => 'Part des frais de livraison (%)';

  @override
  String get settingSystemManagerDeliveryFeePercentageRole => 'La part de la plateforme sur chaque frais de livraison';

  @override
  String get settingSystemManagerDeliveryFeePercentageHelp => 'Le pourcentage des frais de livraison qui revient à la plateforme ; le livreur garde le reste. Par exemple, avec 30, la plateforme garde 30 % de chaque frais de livraison et le livreur 70 %. La banque l\'applique chaque fois qu\'une commande est livrée.';

  @override
  String get settingContactEmailName => 'E-mail du support';

  @override
  String get settingContactEmailRole => 'Affiché dans toutes les applications';

  @override
  String get settingContactEmailHelp => 'Affiché avec les autres coordonnées sur les pages Contact et À propos de toutes les applications (client, livreur, restaurant, opérateur). Modifiez-le dès que l\'adresse du support change, pour que les utilisateurs écrivent toujours à la bonne adresse.';

  @override
  String get settingContactPhoneName => 'Téléphone du support';

  @override
  String get settingContactPhoneRole => 'Affiché dans toutes les applications';

  @override
  String get settingContactPhoneHelp => 'Affiché sur la page Contact de toutes les applications. Les applications le lisent sur le serveur : une modification ici les atteint toutes aussitôt, sans nouvelle version.';

  @override
  String get settingContactWebsiteName => 'Site web';

  @override
  String get settingContactWebsiteRole => 'Affiché dans toutes les applications';

  @override
  String get settingContactWebsiteHelp => 'L\'adresse du site web de votre plateforme, affichée sur les pages À propos et Contact de toutes les applications et ouverte dans le navigateur du téléphone quand on la touche.';

  @override
  String get settingContactAddressName => 'Adresse postale';

  @override
  String get settingContactAddressRole => 'L\'adresse de la société';

  @override
  String get settingContactAddressHelp => 'L\'adresse officielle de votre société. Elle figure dans la partie contact des pages Politique de confidentialité et Conditions d\'utilisation (dans toutes les langues) et est envoyée aux applications avec les autres coordonnées. Laissez-la vide pour masquer la ligne d\'adresse.';

  @override
  String get settingMinimumDeliveryFeeName => 'Frais de livraison minimum';

  @override
  String get settingMinimumDeliveryFeeRole => 'Le moins qu\'une livraison coûte';

  @override
  String get settingMinimumDeliveryFeeHelp => 'Le moins qu\'un client paie jamais pour une livraison, aussi proche que soit le restaurant. Par exemple, 50 signifie qu\'une commande à 300 mètres coûte quand même 50 DZD de livraison. Mettez 0 pour n\'avoir aucun minimum : le résultat du calcul est utilisé tel quel.';

  @override
  String get settingMaximumDeliveryFeeName => 'Frais de livraison maximum';

  @override
  String get settingMaximumDeliveryFeeRole => 'Le plus qu\'une livraison coûte';

  @override
  String get settingMaximumDeliveryFeeHelp => 'Le plus qu\'un client peut payer pour une livraison, aussi loin que soit le restaurant. Par exemple, 500 signifie qu\'une commande à 20 km ne coûte jamais plus de 500 DZD de livraison. Mettez 0 pour n\'avoir aucun maximum : le résultat du calcul est utilisé tel quel.';

  @override
  String get settingMaxDriverConcurrentOrdersName => 'Commandes par livreur à la fois';

  @override
  String get settingMaxDriverConcurrentOrdersRole => 'Le plus de commandes en cours par livreur';

  @override
  String get settingMaxDriverConcurrentOrdersHelp => 'Le plus grand nombre de commandes en cours qu\'un livreur peut avoir en même temps. Une fois ce nombre atteint, aucune nouvelle commande ne lui est proposée tant qu\'il n\'en a pas livré ou rendu une. Augmentez-le aux heures de pointe ; baissez-le pour garder des livraisons courtes.';

  @override
  String get settingFixedDeliveryFeeName => 'Frais de livraison fixes';

  @override
  String get settingFixedDeliveryFeeRole => 'La part fixe de chaque frais de livraison';

  @override
  String get settingFixedDeliveryFeeHelp => 'Un montant fixe compris dans chaque frais de livraison, quelle que soit la distance : frais = frais fixes + (prix par mètre × distance en mètres), puis arrondis et gardés entre le minimum et le maximum. L\'augmenter augmente ce que chaque client paie pour la livraison.';

  @override
  String get settingPricePerMeterName => 'Prix par mètre';

  @override
  String get settingPricePerMeterRole => 'La part de la distance dans les frais de livraison';

  @override
  String get settingPricePerMeterHelp => 'Ce que chaque mètre de route entre le restaurant et l\'adresse de livraison ajoute aux frais. Par exemple, 0,02 DZD par mètre signifie qu\'un trajet de 5 km ajoute 100 DZD aux frais fixes. La distance par la route vient de Mapbox ou d\'OpenRouteService.';

  @override
  String get settingMaxDeliveryDistanceKmName => 'Distance de livraison maximale (km)';

  @override
  String get settingMaxDeliveryDistanceKmRole => 'Jusqu\'où une livraison peut aller';

  @override
  String get settingMaxDeliveryDistanceKmHelp => 'Une commande dont l\'adresse de livraison est à plus de ce nombre de kilomètres du restaurant est refusée au moment où elle est passée. Cela évite aux livreurs des trajets trop longs et garde des délais prévisibles. Augmentez-le ou baissez-le pour élargir ou réduire votre zone de service.';

  @override
  String get settingAverageCitySpeedKmhName => 'Vitesse en ville (km/h)';

  @override
  String get settingAverageCitySpeedKmhRole => 'Pour la durée de livraison sans itinéraire';

  @override
  String get settingAverageCitySpeedKmhHelp => 'Quand ni Mapbox ni OpenRouteService ne répondent, la distance est mesurée à vol d\'oiseau et cette vitesse donne le temps de livraison dans les rues de la ville. Une valeur habituelle est de 25 à 40 km/h, pour la circulation et les arrêts.';

  @override
  String get settingAverageHighwaySpeedKmhName => 'Vitesse sur route (km/h)';

  @override
  String get settingAverageHighwaySpeedKmhRole => 'Pour la partie longue d\'un tel trajet';

  @override
  String get settingAverageHighwaySpeedKmhHelp => 'Utilisée avec la vitesse en ville dans cette estimation à vol d\'oiseau : au-delà de la distance ville-route, le reste du trajet est compté à cette vitesse plus élevée. Une valeur habituelle est de 80 à 120 km/h.';

  @override
  String get settingCityHighwayTransitionKmName => 'Distance ville-route (km)';

  @override
  String get settingCityHighwayTransitionKmRole => 'Là où s\'arrête la vitesse en ville';

  @override
  String get settingCityHighwayTransitionKmHelp => 'Dans cette estimation à vol d\'oiseau, un trajet plus court que cette distance est compté entièrement à la vitesse en ville ; les kilomètres au-delà, à la vitesse sur route. Par exemple, 5 signifie les 5 premiers km à la vitesse en ville et le reste à la vitesse sur route.';

  @override
  String get settingCurrencyName => 'Devise';

  @override
  String get settingCurrencyRole => 'Le code de la devise de la plateforme';

  @override
  String get settingCurrencyHelp => 'Le code ISO 4217 de la devise de tous les montants de la plateforme : totaux des commandes, frais de livraison, gains, notifications. Par exemple, « DZD » pour le dinar algérien. Le serveur l\'écrit après les montants et l\'envoie à toutes les applications.';

  @override
  String get settingBirthdayGiftEnabledName => 'Cadeau d\'anniversaire';

  @override
  String get settingBirthdayGiftEnabledRole => 'Activé ou non';

  @override
  String get settingBirthdayGiftEnabledHelp => 'Si vrai (ou 1), un client qui commande le jour de son anniversaire voit cette commande offerte, jusqu\'au plafond du cadeau, une fois par an. Si faux (ou 0), il n\'y a pas de cadeau d\'anniversaire. Cela active ou désactive la promotion sans toucher au code.';

  @override
  String get settingBirthdayGiftCapName => 'Plafond du cadeau d\'anniversaire (DZD)';

  @override
  String get settingBirthdayGiftCapRole => 'Le plus qu\'un cadeau d\'anniversaire couvre';

  @override
  String get settingBirthdayGiftCapHelp => 'Le plus qu\'un cadeau d\'anniversaire couvre, dans la devise de la plateforme. Par exemple, avec un plafond de 500, une commande d\'anniversaire de 700 DZD est réduite de 500 DZD. Cela garde le cadeau raisonnable sur les grosses commandes.';

  @override
  String get settingCustomerRestaurantRadiusKmName => 'Rayon de recherche des restaurants (km)';

  @override
  String get settingCustomerRestaurantRadiusKmRole => 'Les restaurants qu\'un client voit';

  @override
  String get settingCustomerRestaurantRadiusKmHelp => 'Un client voit les restaurants situés à moins de ce nombre de kilomètres de lui. Un rayon plus grand offre plus de choix, mais peut montrer des restaurants trop loin pour livrer à temps.';

  @override
  String get settingCustomerRestaurantPrefilterRadiusKmName => 'Rayon du pré-filtre de recherche (km)';

  @override
  String get settingCustomerRestaurantPrefilterRadiusKmRole => 'Un premier tri, plus rapide, des restaurants';

  @override
  String get settingCustomerRestaurantPrefilterRadiusKmHelp => 'Avant le calcul exact de la distance, la base de données ne garde que les restaurants dans ce rayon plus large, ce qui est plus rapide. Il doit être au moins égal au rayon de recherche des restaurants : plus petit, il écarterait des restaurants proches ; beaucoup plus grand, il ne fait que ralentir la recherche.';

  @override
  String get settingPrivacyPolicyUrlName => 'Lien de la politique de confidentialité';

  @override
  String get settingPrivacyPolicyUrlRole => 'Affiché dans toutes les applications';

  @override
  String get settingPrivacyPolicyUrlHelp => 'Ouvert dans le navigateur du téléphone quand on touche « Politique de confidentialité » dans n\'importe quelle application. Modifiez-le ici dès que vous publiez une nouvelle version : aucune mise à jour des applications n\'est nécessaire.';

  @override
  String get settingTermsOfServiceUrlName => 'Lien des conditions d\'utilisation';

  @override
  String get settingTermsOfServiceUrlRole => 'Affiché dans toutes les applications';

  @override
  String get settingTermsOfServiceUrlHelp => 'Ouvert dans le navigateur du téléphone quand on touche « Conditions d\'utilisation » dans n\'importe quelle application. Modifiez-le ici dès que vous révisez vos conditions : aucune mise à jour des applications n\'est nécessaire.';

  @override
  String get settingMinOrderSchedulingMinutesName => 'Délai de programmation (minutes)';

  @override
  String get settingMinOrderSchedulingMinutesRole => 'Combien de temps à l\'avance une commande est programmée';

  @override
  String get settingMinOrderSchedulingMinutesHelp => 'Un client qui programme une commande doit choisir une heure au moins ce nombre de minutes plus tard. Par exemple, 30 signifie qu\'aucune commande ne peut être programmée dans les 30 prochaines minutes. Cela laisse aux restaurants et aux livreurs le temps de se préparer.';

  @override
  String get settingNumberOfOrdersToBeTrustedName => 'Commandes pour devenir client de confiance';

  @override
  String get settingNumberOfOrdersToBeTrustedRole => 'Quand un opérateur cesse de vérifier les commandes d\'un client';

  @override
  String get settingNumberOfOrdersToBeTrustedHelp => 'Les commandes d\'un nouveau client sont vérifiées par un opérateur avant d\'arriver au restaurant. Dès qu\'un client compte ce nombre de commandes livrées, il devient « de confiance » et ses commandes suivantes vont directement au restaurant. Baissez-le pour faire confiance plus tôt ; augmentez-le pour vérifier davantage.';

  @override
  String get settingOtpValidityMinutesName => 'Validité des codes (minutes)';

  @override
  String get settingOtpValidityMinutesRole => 'Combien de temps un code reçu par e-mail fonctionne';

  @override
  String get settingOtpValidityMinutesHelp => 'Des codes sont envoyés par e-mail pour réinitialiser un mot de passe, vérifier ou changer une adresse e-mail et confirmer la suppression d\'un compte. Un code fonctionne ce nombre de minutes après son envoi, et l\'e-mail le dit. Plus court est plus sûr ; plus long ménage les boîtes lentes.';

  @override
  String get settingOtpResendWaitSecondsName => 'Attente avant un nouveau code (secondes)';

  @override
  String get settingOtpResendWaitSecondsRole => 'Entre deux codes envoyés par e-mail';

  @override
  String get settingOtpResendWaitSecondsHelp => 'Après l\'envoi d\'un code, un nouveau ne peut être demandé qu\'après ce nombre de secondes ; les applications affichent le compte à rebours. Cela limite les e-mails envoyés à une même adresse.';

  @override
  String get settingMaxSavedAddressesName => 'Adresses enregistrées par client';

  @override
  String get settingMaxSavedAddressesRole => 'Combien d\'adresses un client garde';

  @override
  String get settingMaxSavedAddressesHelp => 'Le plus grand nombre d\'adresses de livraison qu\'un client peut garder dans l\'application. Une de plus est refusée avec un message.';

  @override
  String get settingMaxItemsPerOrderName => 'Plats par commande';

  @override
  String get settingMaxItemsPerOrderRole => 'Plats différents dans une commande';

  @override
  String get settingMaxItemsPerOrderHelp => 'Une commande avec plus de plats différents que ce nombre est refusée. Cela garde une commande à ce qu\'une cuisine et un livreur peuvent gérer à la fois.';

  @override
  String get settingMaxQuantityPerItemName => 'Portions par plat';

  @override
  String get settingMaxQuantityPerItemRole => 'Portions d\'un même plat dans une commande';

  @override
  String get settingMaxQuantityPerItemHelp => 'La plus grande quantité d\'un même plat qu\'un client peut commander. Une quantité plus grande est refusée avec un message.';

  @override
  String get settingAmountRoundingStepName => 'Pas d\'arrondi (DZD)';

  @override
  String get settingAmountRoundingStepRole => 'Arrondi des frais de livraison et des remises';

  @override
  String get settingAmountRoundingStepHelp => 'Les frais de livraison sont arrondis au-dessus, et les remises des coupons au-dessous, à un multiple de ce montant. Avec 5, des frais de 162 DZD deviennent 165 et une remise de 312 DZD devient 310. Mettez 1 pour ne plus arrondir.';

  @override
  String get settingLoyaltyCouponValidityDaysName => 'Validité des coupons de fidélité (jours)';

  @override
  String get settingLoyaltyCouponValidityDaysRole => 'Combien de temps un coupon de fidélité peut servir';

  @override
  String get settingLoyaltyCouponValidityDaysHelp => 'Un coupon obtenu avec des points de fidélité peut servir pendant ce nombre de jours. L\'application client l\'indique avant que les points soient dépensés.';

  @override
  String get settingDefaultDeliveryTimeMinutesName => 'Délai de livraison par défaut (minutes)';

  @override
  String get settingDefaultDeliveryTimeMinutesRole => 'Quand l\'itinéraire est inconnu';

  @override
  String get settingDefaultDeliveryTimeMinutesHelp => 'Quand l\'itinéraire jusqu\'à un client ne peut pas être calculé (pas encore de position, ou pas de service d\'itinéraire), ce nombre de minutes est affiché et utilisé comme délai de livraison.';

  @override
  String get settingRouteCacheMinutesName => 'Distance routière gardée (minutes)';

  @override
  String get settingRouteCacheMinutesRole => 'Combien de temps une distance calculée est réutilisée';

  @override
  String get settingRouteCacheMinutesHelp => 'La distance routière entre un restaurant et un lieu de livraison est gardée ce nombre de minutes au lieu d\'être redemandée. Les frais facturés sont alors ceux affichés, et moins de demandes d\'itinéraire sont faites. Ne le baissez que si les routes changent très souvent.';

  @override
  String get settingMapDefaultLatitudeName => 'Centre de la carte : latitude';

  @override
  String get settingMapDefaultLatitudeRole => 'Là où s\'ouvre la carte des applications';

  @override
  String get settingMapDefaultLatitudeHelp => 'Quand quelqu\'un ouvre la carte pour choisir un lieu et qu\'aucune position n\'est encore connue, la carte s\'ouvre ici. Réglez-la, avec la longitude, sur le centre de votre zone de service. Une valeur entre -90 et 90.';

  @override
  String get settingMapDefaultLongitudeName => 'Centre de la carte : longitude';

  @override
  String get settingMapDefaultLongitudeRole => 'Là où s\'ouvre la carte des applications';

  @override
  String get settingMapDefaultLongitudeHelp => 'La longitude qui va avec la latitude du centre de la carte : le centre de votre zone de service. Une valeur entre -180 et 180.';

  @override
  String get settingAppMapboxAccessTokenName => 'Jeton des cartes (Mapbox)';

  @override
  String get settingAppMapboxAccessTokenRole => 'Dessine les cartes des applications';

  @override
  String get settingAppMapboxAccessTokenHelp => 'Le jeton public Mapbox (il commence par « pk. ») avec lequel les applications client, livreur, restaurant et gestionnaire dessinent leurs cartes. Les applications le lisent sur le serveur : le remplacer ici ne demande aucune nouvelle version. Un jeton secret (« sk. ») est refusé : celui-ci est remis à toutes les applications. Les clés avec lesquelles le serveur mesure les distances routières ne sont pas ici : ce sont des secrets, gardés dans le fichier .env du serveur.';

  @override
  String get settingLocalTimezoneName => 'Fuseau horaire';

  @override
  String get settingLocalTimezoneRole => 'Des horaires d\'ouverture des restaurants';

  @override
  String get settingLocalTimezoneHelp => 'Les restaurants saisissent leurs horaires en heure locale, par exemple de 11:00 à 23:00. C\'est le fuseau horaire dans lequel ces horaires sont lus quand la plateforme décide si un restaurant est ouvert. Utilisez un nom standard comme « Africa/Algiers » ; tout autre est refusé.';

  @override
  String get settingBestSellerCountName => 'Meilleures ventes par restaurant';

  @override
  String get settingBestSellerCountRole => 'Combien de plats ont le badge';

  @override
  String get settingBestSellerCountHelp => 'Dans l\'application client, les plats les plus commandés d\'un restaurant portent un badge « Meilleure vente ». C\'est le nombre de ses plats qui l\'obtiennent : ceux des commandes livrées les plus nombreuses. Mettez 0 pour n\'afficher aucun badge.';

  @override
  String get settingBestSellerDaysName => 'Période des meilleures ventes (jours)';

  @override
  String get settingBestSellerDaysRole => 'Les jours que le badge prend en compte';

  @override
  String get settingBestSellerDaysHelp => 'Seules les commandes livrées au cours de ce nombre de jours passés comptent pour le badge, qui suit ainsi ce que les clients commandent aujourd\'hui. Par exemple, 30 signifie le dernier mois de commandes livrées.';

  @override
  String get settingBestSellerMinOrdersName => 'Commandes pour une meilleure vente';

  @override
  String get settingBestSellerMinOrdersRole => 'Le minimum qu\'un plat doit atteindre pour le badge';

  @override
  String get settingBestSellerMinOrdersHelp => 'Un plat n\'obtient le badge que s\'il figure dans au moins ce nombre de commandes livrées pendant cette période. Un nouveau restaurant avec peu de commandes n\'affiche aucun badge tant que ses plats n\'atteignent pas ce nombre.';

  @override
  String get settingLoyaltyEnabledName => 'Points de fidélité';

  @override
  String get settingLoyaltyEnabledRole => 'Activés ou non';

  @override
  String get settingLoyaltyEnabledHelp => 'Si vrai, les clients gagnent des points à chaque commande livrée et peuvent les échanger contre des coupons de réduction. Si faux, aucun point n\'est gagné ni échangé ; les soldes déjà acquis sont gardés. Cela suspend le programme de fidélité sans rien perdre.';

  @override
  String get settingLoyaltyEarnRateName => 'Points gagnés par DZD';

  @override
  String get settingLoyaltyEarnRateRole => 'Ce qu\'une commande rapporte';

  @override
  String get settingLoyaltyEarnRateHelp => 'Les points de fidélité qu\'un client reçoit pour chaque dinar payé pour une commande livrée (son total, livraison comprise, après remises). Par exemple, 0,1 signifie qu\'une commande de 1000 DZD rapporte 100 points. Un taux plus élevé rend le programme plus généreux ; un taux plus bas coûte moins à la plateforme.';

  @override
  String get settingLoyaltyRedeemRateName => 'DZD par point échangé';

  @override
  String get settingLoyaltyRedeemRateRole => 'Ce que vaut un point';

  @override
  String get settingLoyaltyRedeemRateHelp => 'Ce que vaut un point de fidélité quand un client l\'échange contre un coupon. Par exemple, 0,5 signifie que 200 points font un coupon de 100 DZD. Cela fixe le coût réel du programme : plus bas protège les marges, plus haut incite davantage les clients à échanger leurs points.';

  @override
  String get settingLoyaltyMinRedeemPointsName => 'Points minimum à échanger';

  @override
  String get settingLoyaltyMinRedeemPointsRole => 'Le moins qu\'un client échange en une fois';

  @override
  String get settingLoyaltyMinRedeemPointsHelp => 'Un client ne peut pas échanger moins de points que cela en une fois. Un plancher (par exemple 100 points) évite les coupons minuscules et laisse les clients accumuler d\'abord un vrai solde.';

  @override
  String get settingLoyaltyTiersName => 'Paliers d\'échange';

  @override
  String get settingLoyaltyTiersRole => 'Les montants de points qu\'un client peut échanger';

  @override
  String get settingLoyaltyTiersHelp => 'Les montants exacts de points qu\'un client peut échanger en une fois, sous forme de liste JSON de nombres entiers, par exemple [100, 500, 1000, 2000]. L\'application client ne propose que ceux-là. Chacun devrait valoir au moins le minimum de points à échanger.';

  @override
  String get settingMaxCouponsPerCategoryName => 'Coupons d\'un même type par commande';

  @override
  String get settingMaxCouponsPerCategoryRole => 'Cumul de coupons du même type';

  @override
  String get settingMaxCouponsPerCategoryHelp => 'Le plus grand nombre de coupons d\'un même type (restaurant, livraison ou global) qu\'une commande peut utiliser. Avec 1, un client ne peut pas mettre deux coupons de restaurant sur une commande. Les coupons de fidélité comptent comme coupons de restaurant. Augmentez-le pour permettre de cumuler des coupons du même type.';

  @override
  String get settingMaxCouponCategoriesName => 'Types de coupon par commande';

  @override
  String get settingMaxCouponCategoriesRole => 'Combinaison de types de coupon différents';

  @override
  String get settingMaxCouponCategoriesHelp => 'Le plus grand nombre de types de coupon différents (restaurant, livraison, global) qu\'une commande peut utiliser ensemble. Par exemple, 2 signifie qu\'une commande peut combiner au plus deux types, comme un coupon de restaurant et un coupon de livraison. Avec 3, les trois peuvent être utilisés ensemble.';

  @override
  String confirmPaymentReceived(String amount, String payer) {
    return 'Avez-vous reçu $amount de $payer ?';
  }

  @override
  String get paymentRecordedNotice => 'Paiement enregistré';

  @override
  String get refusedAt => 'Refusé le';

  @override
  String get paymentWaitingForAnswer => 'Un paiement envoyé depuis leur application attend votre réponse dans l\'historique des transactions : il n\'est pas encore compté.';

  @override
  String get reasonLoyaltyCouponCredit => 'Crédit de coupon fidélité';

  @override
  String get reject => 'Rejeter';

  @override
  String paymentNote(String note) {
    return 'Note : $note';
  }

  @override
  String paymentAnswer(String note) {
    return 'Réponse : $note';
  }

  @override
  String get paymentConfirmedNotice => 'Paiement confirmé';

  @override
  String get paymentRefusedNotice => 'Paiement refusé';

  @override
  String get refusePaymentTitle => 'Refuser ce paiement ?';

  @override
  String get refusePaymentReasonHint => 'Pourquoi ? (ex. non reçu)';

  @override
  String get confirmPaymentReceivedTitle => 'Paiement reçu ?';

  @override
  String get creditDetails => 'Détails de la créance';

  @override
  String get debtDetails => 'Détails de la dette';

  @override
  String get orderSettlements => 'Règlements des commandes';

  @override
  String get cashTransactions => 'Paiements en espèces';

  @override
  String get noTransactionsInPeriod => 'Aucune opération sur cette période';

  @override
  String get receivedPayment => 'Paiement reçu';

  @override
  String get sentPayment => 'Paiement envoyé';

  @override
  String get totalOrderSettlements => 'Total des règlements';

  @override
  String get totalCashOutgoing => 'Total des paiements envoyés';

  @override
  String get totalCashIncoming => 'Total des paiements reçus';

  @override
  String get netBalance => 'Solde net';

  @override
  String get paidTowardsOrders => 'Déjà payé sur ces commandes';

  @override
  String get cashPaidInTheseDays => 'Espèces versées ces jours-là';

  @override
  String get cashReceivedInTheseDays => 'Espèces reçues ces jours-là';

  @override
  String get reasonOvercharge => 'Trop-payé';

  @override
  String get reasonOrderSettlement => 'Règlement de commande';

  @override
  String get reasonCouponCredit => 'Crédit de coupon';

  @override
  String get reasonGlobalCouponCredit => 'Crédit de coupon global';

  @override
  String get reasonBirthdayCredit => 'Crédit cadeau d\'anniversaire';

  @override
  String get deliveryAreas => 'Zones de livraison';

  @override
  String get deliveryAreasHelp => 'Les clients ne peuvent commander qu\'à une adresse située dans une zone activée.';

  @override
  String get noDeliveryAreasYet => 'Aucune zone de livraison : aucun client ne peut commander.';

  @override
  String get addDeliveryArea => 'Ajouter une zone de livraison';

  @override
  String get editDeliveryArea => 'Modifier la zone de livraison';

  @override
  String get deliveryAreaOn => 'Activée : les clients peuvent y commander';

  @override
  String get deliveryAreaOff => 'Désactivée : aucun client ne peut y commander';

  @override
  String get deleteDeliveryArea => 'Supprimer la zone de livraison';

  @override
  String deleteDeliveryAreaConfirmation(String name) {
    return 'Supprimer $name ? Les clients de cette zone ne pourront plus commander.';
  }

  @override
  String get coordinatesInvalid => 'Latitude de -90 à 90, longitude de -180 à 180';

  @override
  String get radiusOutOfRange => 'Le rayon va de 0,1 à 100 km';

  @override
  String get payFromPlatform => 'Payer depuis la plateforme';

  @override
  String platformPaymentTitle(String name) {
    return 'Un paiement de la plateforme à $name';
  }

  @override
  String get platformPaymentHelp => 'Il compte aussitôt, et le bénéficiaire en est averti. Payer plus que le dû lui fait devoir la différence à la plateforme.';

  @override
  String get platformPaymentRecorded => 'Paiement de la plateforme enregistré';

  @override
  String get paidByThePlatform => 'Payé par la plateforme';

  @override
  String get paidBeyondWhatWasOwed => 'Payé au-delà du dû';
}
