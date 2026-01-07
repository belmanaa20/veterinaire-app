import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/facture.dart';
import '../config/app_constants.dart';

class FactureCard extends StatelessWidget {
  final Facture facture;
  final VoidCallback? onTap;
  final VoidCallback? onPrint;
  final VoidCallback? onPay;

  const FactureCard({
    super.key,
    required this.facture,
    this.onTap,
    this.onPrint,
    this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat(AppConstants.dateFormat);
    
    Color statutColor;
    IconData statutIcon;
    
    switch (facture.statut) {
      case AppConstants.statutOuverte:
        statutColor = Colors.blue;
        statutIcon = Icons.edit_document;
        break;
      case AppConstants.statutFermee:
        statutColor = Colors.orange;
        statutIcon = Icons.pending;
        break;
      case AppConstants.statutPayee:
        statutColor = Colors.green;
        statutIcon = Icons.check_circle;
        break;
      default:
        statutColor = Colors.red;
        statutIcon = Icons.warning;
    }

    final bool showAlert = facture.procheEcheance || facture.estEnRetard;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      facture.numero,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statutColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statutColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statutIcon, size: 16, color: statutColor),
                        const SizedBox(width: 4),
                        Text(
                          facture.statut,
                          style: TextStyle(
                            color: statutColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Client info
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      facture.client?.nom ?? 'Client inconnu',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Date info
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Date: ${dateFormat.format(facture.dateFacture)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Text(
                    'Échéance: ${dateFormat.format(facture.dateEcheance)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Amount
              Row(
                children: [
                  const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Total: ${facture.montantTotal.toStringAsFixed(2)} ${AppConstants.currency}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              // Alert message
              if (showAlert) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: facture.estEnRetard
                        ? Colors.red.shade50
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: facture.estEnRetard ? Colors.red : Colors.orange,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning,
                        size: 16,
                        color: facture.estEnRetard ? Colors.red : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        facture.estEnRetard
                            ? 'Facture en retard!'
                            : 'Proche de l\'échéance (${facture.joursRestants} jours)',
                        style: TextStyle(
                          color: facture.estEnRetard ? Colors.red : Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // Actions
              if (onPrint != null || onPay != null) ...[
                const SizedBox(height: 12),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onPrint != null)
                      TextButton.icon(
                        onPressed: onPrint,
                        icon: const Icon(Icons.print),
                        label: const Text('Imprimer'),
                      ),
                    if (onPay != null && facture.statut != AppConstants.statutPayee)
                      TextButton.icon(
                        onPressed: onPay,
                        icon: const Icon(Icons.payment),
                        label: const Text('Payer'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
