class Produit {
  final int id;
  final String code;
  final String barcode;
  final String designation;
  final double prixUnitaire;
  final double stock;
  final double stockMin;
  final String? categorie;
  final String? unite;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Produit({
    required this.id,
    required this.code,
    required this.barcode,
    required this.designation,
    required this.prixUnitaire,
    required this.stock,
    required this.stockMin,
    this.categorie,
    this.unite,
    required this.createdAt,
    this.updatedAt,
  });

  // Check if stock is low
  bool get isStockFaible => stock <= stockMin;

  factory Produit.fromJson(Map<String, dynamic> json) {
    return Produit(
      id: json['id'] as int,
      code: (json['code'] as String?) ?? '',
      // Handle both 'barcode' and 'code_barre' columns for database compatibility
      barcode: (json['barcode'] as String?) ?? (json['code_barre'] as String?) ?? '',
      designation: (json['designation'] as String?) ?? '',
      prixUnitaire: ((json['prix_unitaire'] as num?) ?? 0).toDouble(),
      stock: ((json['stock'] as num?) ?? 0).toDouble(),
      stockMin: ((json['stock_min'] as num?) ?? 0).toDouble(),
      categorie: json['categorie'] as String?,
      unite: json['unite'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'barcode': barcode,
      'designation': designation,
      'prix_unitaire': prixUnitaire,
      'stock': stock,
      'stock_min': stockMin,
      'categorie': categorie,
      'unite': unite,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsert() {
    return {
      'code': code,
      'barcode': barcode,
      'designation': designation,
      'prix_unitaire': prixUnitaire,
      'stock': stock,
      'stock_min': stockMin,
      'categorie': categorie,
      'unite': unite,
    };
  }

  Produit copyWith({
    int? id,
    String? code,
    String? barcode,
    String? designation,
    double? prixUnitaire,
    double? stock,
    double? stockMin,
    String? categorie,
    String? unite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Produit(
      id: id ?? this.id,
      code: code ?? this.code,
      barcode: barcode ?? this.barcode,
      designation: designation ?? this.designation,
      prixUnitaire: prixUnitaire ?? this.prixUnitaire,
      stock: stock ?? this.stock,
      stockMin: stockMin ?? this.stockMin,
      categorie: categorie ?? this.categorie,
      unite: unite ?? this.unite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Produit(id: $id, code: $code, designation: $designation, stock: $stock)';
  }
}
