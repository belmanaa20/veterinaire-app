class LigneFacture {
  final int? id;
  final int factureId;
  final int produitId;
  final String designation;
  final double quantite;
  final double prixUnitaire;
  final double remise;
  final double totalLigne;
  final DateTime? createdAt;

  LigneFacture({
    this.id,
    required this.factureId,
    required this.produitId,
    required this.designation,
    required this.quantite,
    required this.prixUnitaire,
    this.remise = 0.0,
    required this.totalLigne,
    this.createdAt,
  });

  factory LigneFacture.fromJson(Map<String, dynamic> json) {
    return LigneFacture(
      id: json['id'] as int?,
      factureId: json['facture_id'] as int,
      produitId: json['produit_id'] as int,
      designation: json['designation'] as String,
      quantite: (json['quantite'] as num).toDouble(),
      prixUnitaire: (json['prix_unitaire'] as num).toDouble(),
      remise: (json['remise'] as num?)?.toDouble() ?? 0.0,
      totalLigne: (json['total_ligne'] as num).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'facture_id': factureId,
      'produit_id': produitId,
      'designation': designation,
      'quantite': quantite,
      'prix_unitaire': prixUnitaire,
      'remise': remise,
      'total_ligne': totalLigne,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  LigneFacture copyWith({
    int? id,
    int? factureId,
    int? produitId,
    String? designation,
    double? quantite,
    double? prixUnitaire,
    double? remise,
    double? totalLigne,
    DateTime? createdAt,
  }) {
    return LigneFacture(
      id: id ?? this.id,
      factureId: factureId ?? this.factureId,
      produitId: produitId ?? this.produitId,
      designation: designation ?? this.designation,
      quantite: quantite ?? this.quantite,
      prixUnitaire: prixUnitaire ?? this.prixUnitaire,
      remise: remise ?? this.remise,
      totalLigne: totalLigne ?? this.totalLigne,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  double calculateTotal() {
    return (quantite * prixUnitaire) - remise;
  }
}
