import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../daily_deed_model.dart';
import '../constants.dart';

/// Fasting section for Ramadan fasting status
class FastingSection extends StatelessWidget {
  final FastingEntry? fasting;
  final Function(String status) onFastingStatusChanged;

  const FastingSection({
    super.key,
    required this.fasting,
    required this.onFastingStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(
                Icons.restaurant,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 8),
              Text(
                localization.fasting,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        
        // Fasting card
        GestureDetector(
          onTap: () => _showFastingPopup(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DeedColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getStatusColor(fasting?.status).withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getStatusColor(fasting?.status).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getStatusIcon(fasting?.status),
                        color: _getStatusColor(fasting?.status),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localization.ramadanFasting,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getStatusText(fasting?.status, localization),
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey.shade300;
    
    switch (status) {
      case 'completed':
        return DeedColors.completed;
      case 'missed':
        return DeedColors.missed;
      default:
        return Colors.grey.shade300;
    }
  }

  IconData _getStatusIcon(String? status) {
    if (status == null) return Icons.remove_circle_outline;
    
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'missed':
        return Icons.cancel;
      default:
        return Icons.remove_circle_outline;
    }
  }

  String _getStatusText(String? status, AppLocalizations localization) {
    if (status == null) return localization.choose;
    
    switch (status) {
      case 'completed':
        return localization.completed;
      case 'missed':
        return localization.missed;
      default:
        return '';
    }
  }

  void _showFastingPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => FastingPopup(
        currentStatus: fasting?.status,
        onStatusSelected: (status) {
          onFastingStatusChanged(status);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

/// Popup dialog for selecting fasting status
class FastingPopup extends StatelessWidget {
  final String? currentStatus;
  final Function(String status) onStatusSelected;

  const FastingPopup({
    super.key,
    required this.currentStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(
        localization.ramadanFasting,
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOption(
            localization.completed,
            DeedColors.completed,
            Icons.check_circle,
            'completed',
            localization,
          ),
          _buildOption(
            localization.missed,
            DeedColors.missed,
            Icons.cancel,
            'missed',
            localization,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localization.cancel),
        ),
      ],
    );
  }

  Widget _buildOption(
    String label,
    Color color,
    IconData icon,
    String status,
    AppLocalizations localization,
  ) {
    final isSelected = currentStatus == status;

    return GestureDetector(
      onTap: () => onStatusSelected(status),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
