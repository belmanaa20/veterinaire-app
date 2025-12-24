class Produit {
  final int? id;
  final String designation;
  final String? codeBarre;
  final double prixUnitaire;
  final int stockActuel;
  final int stockMinimum;
  final String unite;
  final String? categorie;
  final String? description;
  final bool actif;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Produit({
    this.id,
    required this.designation,
    this.codeBarre,
    required this.prixUnitaire,
    required this.stockActuel,
    required this.stockMinimum,
    required this.unite,
    this.categorie,
    this.description,
    this.actif = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Produit.fromJson(Map<String, dynamic> json) {
    return Produit(
      id: json['id'] as int?,
      designation: json['designation'] as String,
      codeBarre: json['code_barre'] as String?,
      prixUnitaire: (json['prix_unitaire'] as num).toDouble(),
      stockActuel: json['stock_actuel'] as int,
      stockMinimum: json['stock_minimum'] as int,
      unite: json['unite'] as String,
      categorie: json['categorie'] as String?,
      description: json['description'] as String?,
      actif: json['actif'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'designation': designation,
      'code_barre': codeBarre,
      'prix_unitaire': prixUnitaire,
      'stock_actuel': stockActuel,
      'stock_minimum': stockMinimum,
      'unite': unite,
      'categorie': categorie,
      'description': description,
      'actif': actif,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  Produit copyWith({
    int? id,
    String? designation,
    String? codeBarre,
    double? prixUnitaire,
    int? stockActuel,
    int? stockMinimum,
    String? unite,
    String? categorie,
    String? description,
    bool? actif,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Produit(
      id: id ?? this.id,
      designation: designation ?? this.designation,
      codeBarre: codeBarre ?? this.codeBarre,
      prixUnitaire: prixUnitaire ?? this.prixUnitaire,
      stockActuel: stockActuel ?? this.stockActuel,
      stockMinimum: stockMinimum ?? this.stockMinimum,
      unite: unite ?? this.unite,
      categorie: categorie ?? this.categorie,
      description: description ?? this.description,
      actif: actif ?? this.actif,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isLowStock => stockActuel <= stockMinimum;
  bool get isOutOfStock => stockActuel <= 0;
}
