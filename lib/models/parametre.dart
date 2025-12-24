class Parametre {
  final int id;
  final String nomEntreprise;
  final String? adresse;
  final String? telephone;
  final String? email;
  final double tvaDefaut;
  final int delaiNotificationRappel;
  final int seuilStockFaible;
  final DateTime createdAt;
  final DateTime updatedAt;

  Parametre({
    required this.id,
    required this.nomEntreprise,
    this.adresse,
    this.telephone,
    this.email,
    required this.tvaDefaut,
    required this.delaiNotificationRappel,
    required this.seuilStockFaible,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Parametre.fromJson(Map<String, dynamic> json) {
    return Parametre(
      id: json['id'] as int,
      nomEntreprise: json['nom_entreprise'] as String,
      adresse: json['adresse'] as String?,
      telephone: json['telephone'] as String?,
      email: json['email'] as String?,
      tvaDefaut: (json['tva_defaut'] as num).toDouble(),
      delaiNotificationRappel: json['delai_notification_rappel'] as int,
      seuilStockFaible: json['seuil_stock_faible'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom_entreprise': nomEntreprise,
      'adresse': adresse,
      'telephone': telephone,
      'email': email,
      'tva_defaut': tvaDefaut,
      'delai_notification_rappel': delaiNotificationRappel,
      'seuil_stock_faible': seuilStockFaible,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Parametre copyWith({
    int? id,
    String? nomEntreprise,
    String? adresse,
    String? telephone,
    String? email,
    double? tvaDefaut,
    int? delaiNotificationRappel,
    int? seuilStockFaible,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Parametre(
      id: id ?? this.id,
      nomEntreprise: nomEntreprise ?? this.nomEntreprise,
      adresse: adresse ?? this.adresse,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      tvaDefaut: tvaDefaut ?? this.tvaDefaut,
      delaiNotificationRappel: delaiNotificationRappel ?? this.delaiNotificationRappel,
      seuilStockFaible: seuilStockFaible ?? this.seuilStockFaible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
