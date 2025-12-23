import 'client.dart';
import 'ligne_facture.dart';

class Facture {
  final int id;
  final String numero;
  final int clientId;
  final DateTime dateFacture;
  final DateTime dateEcheance;
  final DateTime? datePaiement;
  final double montantTotal;
  final String statut; // OUVERTE, FERMEE, PAYEE, EN_RETARD
  final bool estModifiable;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Relations
  Client? client;
  List<LigneFacture>? lignes;

  Facture({
    required this.id,
    required this.numero,
    required this.clientId,
    required this.dateFacture,
    required this.dateEcheance,
    this.datePaiement,
    required this.montantTotal,
    required this.statut,
    required this.estModifiable,
    required this.createdAt,
    this.updatedAt,
    this.client,
    this.lignes,
  });

  // Calculate days remaining until due date
  int get joursRestants => dateEcheance.difference(DateTime.now()).inDays;

  // Check if invoice is overdue
  bool get estEnRetard => DateTime.now().isAfter(dateEcheance) && datePaiement == null;

  // Check if invoice is close to due date (7 days or less)
  bool get procheEcheance => joursRestants <= 7 && joursRestants >= 0 && datePaiement == null;

  // Check if invoice is paid
  bool get estPayee => statut == 'PAYEE' || datePaiement != null;

  // Check if invoice is open (can still add products)
  bool get estOuverte => statut == 'OUVERTE';

  factory Facture.fromJson(Map<String, dynamic> json) {
    return Facture(
      id: json['id'] as int,
      numero: (json['numero'] as String?) ?? '',
      clientId: json['client_id'] as int,
      dateFacture: json['date_facture'] != null
          ? DateTime.parse(json['date_facture'] as String)
          : DateTime.now(),
      dateEcheance: json['date_echeance'] != null
          ? DateTime.parse(json['date_echeance'] as String)
          : DateTime.now().add(const Duration(days: 45)),
      datePaiement: json['date_paiement'] != null
          ? DateTime.parse(json['date_paiement'] as String)
          : null,
      montantTotal: ((json['montant_total'] as num?) ?? 0).toDouble(),
      statut: (json['statut'] as String?) ?? 'OUVERTE',
      estModifiable: json['est_modifiable'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      client: json['client'] != null
          ? Client.fromJson(json['client'] as Map<String, dynamic>)
          : (json['client_nom'] != null
              ? Client(
                  id: json['client_id'] as int,
                  nom: json['client_nom'] as String,
                  adresse: json['client_adresse'] as String?,
                  telephone: json['client_telephone'] as String?,
                  culture: json['client_culture'] as String?,
                  createdAt: DateTime.now(),
                )
              : null),
      lignes: json['lignes'] != null
          ? (json['lignes'] as List)
              .map((e) => LigneFacture.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numero': numero,
      'client_id': clientId,
      'date_facture': dateFacture.toIso8601String(),
      'date_echeance': dateEcheance.toIso8601String(),
      'date_paiement': datePaiement?.toIso8601String(),
      'montant_total': montantTotal,
      'statut': statut,
      'est_modifiable': estModifiable,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'client': client?.toJson(),
      'lignes': lignes?.map((e) => e.toJson()).toList(),
    };
  }

  Facture copyWith({
    int? id,
    String? numero,
    int? clientId,
    DateTime? dateFacture,
    DateTime? dateEcheance,
    DateTime? datePaiement,
    double? montantTotal,
    String? statut,
    bool? estModifiable,
    DateTime? createdAt,
    DateTime? updatedAt,
    Client? client,
    List<LigneFacture>? lignes,
  }) {
    return Facture(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      clientId: clientId ?? this.clientId,
      dateFacture: dateFacture ?? this.dateFacture,
      dateEcheance: dateEcheance ?? this.dateEcheance,
      datePaiement: datePaiement ?? this.datePaiement,
      montantTotal: montantTotal ?? this.montantTotal,
      statut: statut ?? this.statut,
      estModifiable: estModifiable ?? this.estModifiable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      client: client ?? this.client,
      lignes: lignes ?? this.lignes,
    );
  }

  @override
  String toString() {
    return 'Facture(id: $id, numero: $numero, client: ${client?.nom}, montant: $montantTotal, statut: $statut)';
  }
}
