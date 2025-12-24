class AppConstants {
  // Statuts de facture
  static const String statutBrouillon = 'brouillon';
  static const String statutValidee = 'validee';
  static const String statutPayee = 'payee';
  static const String statutAnnulee = 'annulee';

  // Modes de paiement
  static const List<String> modesPaiement = [
    'Espèces',
    'Carte bancaire',
    'Chèque',
    'Virement',
  ];

  // Catégories de produits
  static const List<String> categoriesProduits = [
    'Consultation',
    'Médicament',
    'Vaccin',
    'Chirurgie',
    'Alimentation',
    'Accessoire',
    'Autre',
  ];

  // Unités de mesure
  static const List<String> unitesMesure = [
    'Unité',
    'Boîte',
    'Flacon',
    'Kg',
    'g',
    'ml',
    'L',
  ];

  // Types d'animaux
  static const List<String> typesAnimaux = [
    'Chien',
    'Chat',
    'Oiseau',
    'Lapin',
    'Hamster',
    'Autre',
  ];

  // Pagination
  static const int itemsPerPage = 20;

  // Window
  static const double minWindowWidth = 1280;
  static const double minWindowHeight = 720;
}
