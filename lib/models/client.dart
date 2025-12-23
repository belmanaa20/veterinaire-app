class Client {
  final int id;
  final String nom;
  final String? adresse;
  final String? telephone;
  final String? culture;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Client({
    required this.id,
    required this.nom,
    this.adresse,
    this.telephone,
    this.culture,
    required this.createdAt,
    this.updatedAt,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as int,
      nom: (json['nom'] as String?) ?? '',
      adresse: json['adresse'] as String?,
      telephone: json['telephone'] as String?,
      culture: json['culture'] as String?,
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
      'nom': nom,
      'adresse': adresse,
      'telephone': telephone,
      'culture': culture,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsert() {
    return {
      'nom': nom,
      'adresse': adresse,
      'telephone': telephone,
      'culture': culture,
    };
  }

  Client copyWith({
    int? id,
    String? nom,
    String? adresse,
    String? telephone,
    String? culture,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Client(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      adresse: adresse ?? this.adresse,
      telephone: telephone ?? this.telephone,
      culture: culture ?? this.culture,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Client(id: $id, nom: $nom, culture: $culture)';
  }
}
