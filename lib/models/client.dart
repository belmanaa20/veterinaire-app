class Client {
  final int? id;
  final String nom;
  final String? prenom;
  final String? telephone;
  final String? email;
  final String? adresse;
  final String? notes;
  final String? nomAnimal;
  final String? typeAnimal;
  final String? raceAnimal;
  final DateTime? dateNaissanceAnimal;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Client({
    this.id,
    required this.nom,
    this.prenom,
    this.telephone,
    this.email,
    this.adresse,
    this.notes,
    this.nomAnimal,
    this.typeAnimal,
    this.raceAnimal,
    this.dateNaissanceAnimal,
    this.createdAt,
    this.updatedAt,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as int?,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String?,
      telephone: json['telephone'] as String?,
      email: json['email'] as String?,
      adresse: json['adresse'] as String?,
      notes: json['notes'] as String?,
      nomAnimal: json['nom_animal'] as String?,
      typeAnimal: json['type_animal'] as String?,
      raceAnimal: json['race_animal'] as String?,
      dateNaissanceAnimal: json['date_naissance_animal'] != null
          ? DateTime.parse(json['date_naissance_animal'] as String)
          : null,
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
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'email': email,
      'adresse': adresse,
      'notes': notes,
      'nom_animal': nomAnimal,
      'type_animal': typeAnimal,
      'race_animal': raceAnimal,
      'date_naissance_animal': dateNaissanceAnimal?.toIso8601String(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  Client copyWith({
    int? id,
    String? nom,
    String? prenom,
    String? telephone,
    String? email,
    String? adresse,
    String? notes,
    String? nomAnimal,
    String? typeAnimal,
    String? raceAnimal,
    DateTime? dateNaissanceAnimal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Client(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      adresse: adresse ?? this.adresse,
      notes: notes ?? this.notes,
      nomAnimal: nomAnimal ?? this.nomAnimal,
      typeAnimal: typeAnimal ?? this.typeAnimal,
      raceAnimal: raceAnimal ?? this.raceAnimal,
      dateNaissanceAnimal: dateNaissanceAnimal ?? this.dateNaissanceAnimal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get fullName => prenom != null ? '$prenom $nom' : nom;
}
