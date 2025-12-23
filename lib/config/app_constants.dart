class AppConstants {
  // App Information
  static const String appName = 'Pharmacie Vétérinaire';
  static const String appVersion = '1.0.0';
  
  // Billing Constants
  static const int defaultDelaiJours = 45;
  static const int joursAlerte = 7;
  
  // Facture Status
  static const String statutOuverte = 'OUVERTE';
  static const String statutFermee = 'FERMEE';
  static const String statutPayee = 'PAYEE';
  static const String statutEnRetard = 'EN_RETARD';
  
  // Offline Mode & Sync
  static const int maxSyncRetries = 5;
  static const int cacheFacturesDays = 90;
  static const List<String> connectivityPingHosts = [
    'google.com',
    'cloudflare.com',
    '1.1.1.1',
  ];
  
  // Culture Types (Client types)
  static const List<String> cultureTypes = [
    'Elevage Bovin',
    'Elevage Ovin',
    'Elevage Caprin',
    'Elevage Avicole',
    'Elevage Équin',
    'Autre',
  ];
  
  // Product Categories
  static const List<String> productCategories = [
    'Antibiotiques',
    'Antiparasitaires',
    'Vaccins',
    'Vitamines',
    'Hormones',
    'Antiseptiques',
    'Matériel médical',
    'Autre',
  ];
  
  // Product Units
  static const List<String> productUnits = [
    'Comprimé',
    'Flacon',
    'Ampoule',
    'Sachet',
    'Boîte',
    'Litre',
    'Kilogramme',
    'Unité',
  ];
  
  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  
  // PDF Settings
  static const String pdfDateFormat = 'dd/MM/yyyy';
  static const double pdfMargin = 20.0;
  
  // Label Settings (80mm x 50mm)
  static const double labelWidth = 80.0;
  static const double labelHeight = 50.0;
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Language Codes
  static const String langFrench = 'fr';
  static const String langArabic = 'ar';
  
  // Currency
  static const String currency = 'DA';
  
  // Stock Alerts
  static const String stockAlertMessage = 'Stock faible!';
  static const String echeanceAlertMessage = 'Facture proche de l\'échéance!';
  
  // Error Messages
  static const String errorGeneric = 'Une erreur est survenue';
  static const String errorNetwork = 'Erreur de connexion';
  static const String errorNotFound = 'Élément introuvable';
  static const String errorInvalidData = 'Données invalides';
  
  // Success Messages
  static const String successCreate = 'Créé avec succès';
  static const String successUpdate = 'Modifié avec succès';
  static const String successDelete = 'Supprimé avec succès';
  static const String successPayment = 'Paiement enregistré avec succès';
  
  // Validation Messages
  static const String validationRequired = 'Ce champ est obligatoire';
  static const String validationEmail = 'Email invalide';
  static const String validationPhone = 'Numéro de téléphone invalide';
  static const String validationNumber = 'Nombre invalide';
  static const String validationPositive = 'Le nombre doit être positif';
}
