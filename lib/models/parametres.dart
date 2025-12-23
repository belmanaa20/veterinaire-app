class Parametres {
  final int id;
  final String? nomMagasin;
  final String? adresse;
  final String? telephone;
  final String? nif;
  final String? logoUrl;
  final String? signatureUrl;
  final String? cachetUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Parametres({
    required this.id,
    this.nomMagasin,
    this.adresse,
    this.telephone,
    this.nif,
    this.logoUrl,
    this.signatureUrl,
    this.cachetUrl,
    required this.createdAt,
    this.updatedAt,
  });

  factory Parametres.fromJson(Map<String, dynamic> json) {
    return Parametres(
      id: json['id'] as int,
      nomMagasin: json['nom_magasin'] as String?,
      adresse: json['adresse'] as String?,
      telephone: json['telephone'] as String?,
      nif: json['nif'] as String?,
      logoUrl: json['logo_url'] as String?,
      signatureUrl: json['signature_url'] as String?,
      cachetUrl: json['cachet_url'] as String?,
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
      'nom_magasin': nomMagasin,
      'adresse': adresse,
      'telephone': telephone,
      'nif': nif,
      'logo_url': logoUrl,
      'signature_url': signatureUrl,
      'cachet_url': cachetUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Parametres copyWith({
    int? id,
    String? nomMagasin,
    String? adresse,
    String? telephone,
    String? nif,
    String? logoUrl,
    String? signatureUrl,
    String? cachetUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Parametres(
      id: id ?? this.id,
      nomMagasin: nomMagasin ?? this.nomMagasin,
      adresse: adresse ?? this.adresse,
      telephone: telephone ?? this.telephone,
      nif: nif ?? this.nif,
      logoUrl: logoUrl ?? this.logoUrl,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      cachetUrl: cachetUrl ?? this.cachetUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
