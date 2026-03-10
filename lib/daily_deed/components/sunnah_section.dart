import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../daily_deed_model.dart';
import '../constants.dart' hide sunnahPrayers;
import '../constants.dart' as deed_constants show sunnahPrayers;

/// Sunnah Prayers section displaying voluntary prayers with status
class SunnahSection extends StatelessWidget {
  final Map<String, PrayerEntry> sunnahPrayers;
  final Function(String prayerName, String status) onPrayerStatusChanged;

  const SunnahSection({
    super.key,
    required this.sunnahPrayers,
    required this.onPrayerStatusChanged,
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
                Icons.self_improvement,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              const SizedBox(width: 8),
              Text(
                localization.sunnahPrayers,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        
        // Sunnah prayers (2 rows, like prayer section)
        Column(
          children: [
            // Row 1: Fajr Sunnah, Doha, Dhur Sunnah
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: deed_constants.sunnahPrayers.take(3).map((prayerName) {
                final prayer = sunnahPrayers[prayerName] ?? PrayerEntry();
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _sunnahPrayerCard(
                      context: context,
                      prayerName: prayerName,
                      status: prayer.status,
                      onTap: () => _showPrayerPopup(context, prayerName),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            // Row 2: Maghrib Sunnah, Isa Sunnah (keep 3rd slot for alignment)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ...deed_constants.sunnahPrayers.skip(3).map((prayerName) {
                  final prayer = sunnahPrayers[prayerName] ?? PrayerEntry();
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _sunnahPrayerCard(
                        context: context,
                        prayerName: prayerName,
                        status: prayer.status,
                        onTap: () => _showPrayerPopup(context, prayerName),
                      ),
                    ),
                  );
                }),
                // Empty Expanded for 3rd slot to maintain spacing alignment
                const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _sunnahPrayerCard({
    required BuildContext context,
    required String prayerName,
    required String? status,
    required VoidCallback onTap,
  }) {
    final color = _getStatusColor(status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: DeedColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Prayer icon/indicator
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: _getStatusIcon(status),
            ),
            const SizedBox(height: 6),
            // Prayer name
            Text(
              _getPrayerDisplayName(prayerName, AppLocalizations.of(context)!),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey.shade300;
    
    switch (status) {
      case 'missed':
        return DeedColors.missed;
      case 'completed':
        return DeedColors.completed;
      default:
        return Colors.grey.shade300;
    }
  }

  Widget _getStatusIcon(String? status) {
    if (status == null) {
      return Icon(Icons.remove, color: Colors.grey.shade400, size: 20);
    }
    
    switch (status) {
      case 'missed':
        return DeedIcons.missed;
      case 'completed':
        return DeedIcons.completed;
      default:
        return Icon(Icons.remove, color: Colors.grey.shade400, size: 20);
    }
  }

  String _getPrayerDisplayName(String prayerName, AppLocalizations localization) {
    switch (prayerName) {
      case PrayerNames.fajrSunnah:
        return localization.fajrSunnah;
      case PrayerNames.doha:
        return localization.doha;
      case PrayerNames.dhurSunnah:
        return localization.dhurSunnah;
      case PrayerNames.maghribSunnah:
        return localization.maghribSunnah;
      case PrayerNames.isaSunnah:
        return localization.isaSunnah;
      default:
        return prayerName;
    }
  }

  void _showPrayerPopup(BuildContext context, String prayerName) {
    showDialog(
      context: context,
      builder: (context) => SunnahPrayerPopup(
        prayerName: prayerName,
        currentStatus: sunnahPrayers[prayerName]?.status,
        onStatusSelected: (status) {
          onPrayerStatusChanged(prayerName, status);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

/// Popup dialog for selecting sunnah prayer status
class SunnahPrayerPopup extends StatelessWidget {
  final String prayerName;
  final String? currentStatus;
  final Function(String status) onStatusSelected;

  const SunnahPrayerPopup({
    super.key,
    required this.prayerName,
    required this.currentStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(
        _getPrayerDisplayName(prayerName, localization),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOption(
            localization.missed,
            DeedColors.missed,
            Icons.cancel,
            'missed',
            context,
          ),
          _buildOption(
            localization.completed,
            DeedColors.completed,
            Icons.check_circle,
            'completed',
            context,
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
    BuildContext context,
  ) {
    final isSelected = currentStatus == status;

    return GestureDetector(
      onTap: () => onStatusSelected(status),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.grey.shade100,
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

  String _getPrayerDisplayName(String prayerName, AppLocalizations localization) {
    switch (prayerName) {
      case PrayerNames.fajrSunnah:
        return localization.fajrSunnah;
      case PrayerNames.doha:
        return localization.doha;
      case PrayerNames.dhurSunnah:
        return localization.dhurSunnah;
      case PrayerNames.maghribSunnah:
        return localization.maghribSunnah;
      case PrayerNames.isaSunnah:
        return localization.isaSunnah;
      default:
        return prayerName;
    }
  }
}
