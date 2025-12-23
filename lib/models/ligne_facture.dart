class LigneFacture {
  final int id;
  final int factureId;
  final int produitId;
  final double quantite;
  final double prixUnitaire;
  final double montant;
  final DateTime dateAjout;
  final DateTime createdAt;

  // Optional product information (when loaded with join)
  String? produitCode;
  String? produitDesignation;

  LigneFacture({
    required this.id,
    required this.factureId,
    required this.produitId,
    required this.quantite,
    required this.prixUnitaire,
    required this.montant,
    required this.dateAjout,
    required this.createdAt,
    this.produitCode,
    this.produitDesignation,
  });

  factory LigneFacture.fromJson(Map<String, dynamic> json) {
    return LigneFacture(
      id: json['id'] as int,
      factureId: json['facture_id'] as int,
      produitId: json['produit_id'] as int,
      quantite: ((json['quantite'] as num?) ?? 0).toDouble(),
      prixUnitaire: ((json['prix_unitaire'] as num?) ?? 0).toDouble(),
      montant: ((json['montant'] as num?) ?? 0).toDouble(),
      dateAjout: json['date_ajout'] != null
          ? DateTime.parse(json['date_ajout'] as String)
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      produitCode: json['produit_code'] as String?,
      produitDesignation: json['produit_designation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'facture_id': factureId,
      'produit_id': produitId,
      'quantite': quantite,
      'prix_unitaire': prixUnitaire,
      'montant': montant,
      'date_ajout': dateAjout.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'produit_code': produitCode,
      'produit_designation': produitDesignation,
    };
  }

  LigneFacture copyWith({
    int? id,
    int? factureId,
    int? produitId,
    double? quantite,
    double? prixUnitaire,
    double? montant,
    DateTime? dateAjout,
    DateTime? createdAt,
    String? produitCode,
    String? produitDesignation,
  }) {
    return LigneFacture(
      id: id ?? this.id,
      factureId: factureId ?? this.factureId,
      produitId: produitId ?? this.produitId,
      quantite: quantite ?? this.quantite,
      prixUnitaire: prixUnitaire ?? this.prixUnitaire,
      montant: montant ?? this.montant,
      dateAjout: dateAjout ?? this.dateAjout,
      createdAt: createdAt ?? this.createdAt,
      produitCode: produitCode ?? this.produitCode,
      produitDesignation: produitDesignation ?? this.produitDesignation,
    );
  }

  @override
  String toString() {
    return 'LigneFacture(id: $id, produit: $produitDesignation, quantite: $quantite, montant: $montant)';
  }
}
