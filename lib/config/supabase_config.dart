class SupabaseConfig {
  // Supabase Configuration - Hardcoded for easy deployment
  static const String supabaseUrl = 'https://teaawvipetvopccqmxpsj.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_vFTEmjjf_jWSK-zaPquzsw_8PtVCYXQ';
  
  // Database table names
  static const String tableParametres = 'parametres';
  static const String tableClients = 'clients';
  static const String tableProduits = 'produits';
  static const String tableFactures = 'factures';
  static const String tableLignesFacture = 'lignes_facture';
  
  // Database views
  static const String viewFacturesComplet = 'v_factures_complet';
  static const String viewFacturesANotifier = 'v_factures_a_notifier';
  static const String viewProduitsStockFaible = 'v_produits_stock_faible';
  
  // RPC Function names
  static const String rpcCreerFacture = 'creer_facture';
  static const String rpcAjouterLigneFacture = 'ajouter_ligne_facture';
  static const String rpcAjouterLigneByBarcode = 'ajouter_ligne_by_barcode';
  static const String rpcRecalculerFacture = 'recalculer_facture';
  static const String rpcFermerFacture = 'fermer_facture';
  static const String rpcEnregistrerPaiement = 'enregistrer_paiement';
}
