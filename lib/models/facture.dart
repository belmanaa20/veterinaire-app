class Facture {
  final int? id;
  final String? numeroFacture;
  final int clientId;
  final DateTime dateFacture;
  final String statut;
  final double totalHt;
  final double tva;
  final double totalTtc;
  final double montantPaye;
  final double resteAPayer;
  final String? modePaiement;
  final String? notes;
  final DateTime? dateEcheance;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Populated from view
  final String? clientNom;
  final String? clientPrenom;
  final String? nomAnimal;

  Facture({
    this.id,
    this.numeroFacture,
    required this.clientId,
    required this.dateFacture,
    this.statut = 'brouillon',
    this.totalHt = 0.0,
    this.tva = 0.0,
    this.totalTtc = 0.0,
    this.montantPaye = 0.0,
    this.resteAPayer = 0.0,
    this.modePaiement,
    this.notes,
    this.dateEcheance,
    this.createdAt,
    this.updatedAt,
    this.clientNom,
    this.clientPrenom,
    this.nomAnimal,
  });

  factory Facture.fromJson(Map<String, dynamic> json) {
    return Facture(
      id: json['id'] as int?,
      numeroFacture: json['numero_facture'] as String?,
      clientId: json['client_id'] as int,
      dateFacture: DateTime.parse(json['date_facture'] as String),
      statut: json['statut'] as String? ?? 'brouillon',
      totalHt: (json['total_ht'] as num?)?.toDouble() ?? 0.0,
      tva: (json['tva'] as num?)?.toDouble() ?? 0.0,
      totalTtc: (json['total_ttc'] as num?)?.toDouble() ?? 0.0,
      montantPaye: (json['montant_paye'] as num?)?.toDouble() ?? 0.0,
      resteAPayer: (json['reste_a_payer'] as num?)?.toDouble() ?? 0.0,
      modePaiement: json['mode_paiement'] as String?,
      notes: json['notes'] as String?,
      dateEcheance: json['date_echeance'] != null
          ? DateTime.parse(json['date_echeance'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      clientNom: json['client_nom'] as String?,
      clientPrenom: json['client_prenom'] as String?,
      nomAnimal: json['nom_animal'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'numero_facture': numeroFacture,
      'client_id': clientId,
      'date_facture': dateFacture.toIso8601String(),
      'statut': statut,
      'total_ht': totalHt,
      'tva': tva,
      'total_ttc': totalTtc,
      'montant_paye': montantPaye,
      'reste_a_payer': resteAPayer,
      'mode_paiement': modePaiement,
      'notes': notes,
      'date_echeance': dateEcheance?.toIso8601String(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  Facture copyWith({
    int? id,
    String? numeroFacture,
    int? clientId,
    DateTime? dateFacture,
    String? statut,
    double? totalHt,
    double? tva,
    double? totalTtc,
    double? montantPaye,
    double? resteAPayer,
    String? modePaiement,
    String? notes,
    DateTime? dateEcheance,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? clientNom,
    String? clientPrenom,
    String? nomAnimal,
  }) {
    return Facture(
      id: id ?? this.id,
      numeroFacture: numeroFacture ?? this.numeroFacture,
      clientId: clientId ?? this.clientId,
      dateFacture: dateFacture ?? this.dateFacture,
      statut: statut ?? this.statut,
      totalHt: totalHt ?? this.totalHt,
      tva: tva ?? this.tva,
      totalTtc: totalTtc ?? this.totalTtc,
      montantPaye: montantPaye ?? this.montantPaye,
      resteAPayer: resteAPayer ?? this.resteAPayer,
      modePaiement: modePaiement ?? this.modePaiement,
      notes: notes ?? this.notes,
      dateEcheance: dateEcheance ?? this.dateEcheance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      clientNom: clientNom ?? this.clientNom,
      clientPrenom: clientPrenom ?? this.clientPrenom,
      nomAnimal: nomAnimal ?? this.nomAnimal,
    );
  }

  String get clientFullName {
    if (clientPrenom != null && clientNom != null) {
      return '$clientPrenom $clientNom';
    }
    return clientNom ?? '';
  }

  bool get isPaid => statut == 'payee';
  bool get isValidated => statut == 'validee' || statut == 'payee';
  bool get isDraft => statut == 'brouillon';
  bool get isCancelled => statut == 'annulee';
}
