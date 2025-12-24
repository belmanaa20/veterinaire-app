import 'package:flutter/material.dart';
import '../config/theme_config.dart';
import '../utils/constants.dart';

class StatusBadge extends StatelessWidget {
  final String statut;

  const StatusBadge({
    super.key,
    required this.statut,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (statut) {
      case AppConstants.statutBrouillon:
        color = Colors.grey;
        label = 'Brouillon';
        break;
      case AppConstants.statutValidee:
        color = AppColors.infoBlue;
        label = 'Validée';
        break;
      case AppConstants.statutPayee:
        color = AppColors.successGreen;
        label = 'Payée';
        break;
      case AppConstants.statutAnnulee:
        color = AppColors.errorRed;
        label = 'Annulée';
        break;
      default:
        color = Colors.grey;
        label = statut;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
