import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../daily_deed_model.dart';
import '../constants.dart';

/// Prayer section displaying all prayers with their status
class PrayerSection extends StatelessWidget {
  final Map<String, PrayerEntry> prayers;
  final bool isRamadan;
  final bool isEid;
  final PrayerEntry? eidPrayer;
  final Function(String prayerName, String status) onPrayerStatusChanged;
  final Function(String status)? onEidStatusChanged;

  const PrayerSection({
    super.key,
    required this.prayers,
    required this.isRamadan,
    this.isEid = false,
    this.eidPrayer,
    required this.onPrayerStatusChanged,
    this.onEidStatusChanged,
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
                Icons.person_pin_circle_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                localization.prayers,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        
        // Fard prayers row
        _buildPrayerRow(
          context: context,
          prayers: fardPrayers,
          isFard: true,
        ),
        
        const SizedBox(height: 12),
        
        // Nafl prayers row
        _buildPrayerRow(
          context: context,
          prayers: naflPrayers.where((p) => isRamadan || p != PrayerNames.taraweeh).toList(),
          isFard: false,
        ),
        
        // Eid Prayer (only on Eid days)
        if (isEid) ...[
          const SizedBox(height: 12),
          _buildEidPrayerCard(context),
        ],
      ],
    );
  }

  Widget _buildEidPrayerCard(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final status = eidPrayer?.status;
    final color = _getEidStatusColor(status);
    
    return GestureDetector(
      onTap: () => _showEidPrayerPopup(context),
      child: Container(
        decoration: BoxDecoration(
          color: DeedColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: _getEidStatusIcon(status),
            ),
            const SizedBox(width: 12),
            Text(
              localization.eidPrayer,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Color _getEidStatusColor(String? status) {
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

  Widget _getEidStatusIcon(String? status) {
    if (status == null) {
      return Icon(Icons.remove, color: Colors.grey.shade400);
    }
    switch (status) {
      case 'missed':
        return DeedIcons.missed;
      case 'completed':
        return DeedIcons.completed;
      default:
        return Icon(Icons.remove, color: Colors.grey.shade400);
    }
  }

  void _showEidPrayerPopup(BuildContext ctx) {
    if (onEidStatusChanged == null) return;
    
    showDialog(
      context: ctx,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          AppLocalizations.of(dialogContext)!.eidPrayer,
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildEidOption(
              AppLocalizations.of(dialogContext)!.missed,
              DeedColors.missed,
              Icons.cancel,
              'missed',
              dialogContext,
            ),
            _buildEidOption(
              AppLocalizations.of(dialogContext)!.completed,
              DeedColors.completed,
              Icons.check_circle,
              'completed',
              dialogContext,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppLocalizations.of(dialogContext)!.cancel),
          ),
        ],
      ),
    );
  }

  Widget _buildEidOption(
    String label,
    Color color,
    IconData icon,
    String status,
    BuildContext dialogContext,
  ) {
    final isSelected = eidPrayer?.status == status;
    return GestureDetector(
      onTap: () {
        onEidStatusChanged!(status);
        Navigator.of(dialogContext).pop();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
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
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerRow({
    required BuildContext context,
    required List<String> prayers,
    required bool isFard,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: prayers.map((prayerName) {
        final prayer = this.prayers[prayerName] ?? PrayerEntry();
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _PrayerCard(
              prayerName: prayerName,
              status: prayer.status,
              isFard: isFard,
              onTap: () => _showPrayerPopup(context, prayerName, isFard),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showPrayerPopup(BuildContext context, String prayerName, bool isFard) {
    showDialog(
      context: context,
      builder: (context) => PrayerPopup(
        prayerName: prayerName,
        currentStatus: prayers[prayerName]?.status,
        isFard: isFard,
        onStatusSelected: (status) {
          onPrayerStatusChanged(prayerName, status);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

/// Individual prayer card widget
class _PrayerCard extends StatelessWidget {
  final String prayerName;
  final String? status;
  final bool isFard;
  final VoidCallback onTap;

  const _PrayerCard({
    required this.prayerName,
    required this.status,
    required this.isFard,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);
    final icon = _getStatusIcon(status);
    final localization = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: DeedColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Prayer icon/indicator
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: icon,
            ),
            const SizedBox(height: 6),
            // Prayer name
            Text(
              _getPrayerDisplayName(prayerName, localization),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey.shade300;
    
    if (isFard) {
      switch (status) {
        case 'not_prayed':
          return DeedColors.notPrayed;
        case 'late':
          return DeedColors.late;
        case 'on_time':
          return DeedColors.onTime;
        case 'jamaah':
          return DeedColors.jamaAh;
        default:
          return DeedColors.notPrayed;
      }
    } else {
      switch (status) {
        case 'missed':
          return DeedColors.missed;
        case 'completed':
          return DeedColors.completed;
        default:
          return Colors.grey.shade300;
      }
    }
  }

  Widget _getStatusIcon(String? status) {
    if (status == null) {
      return Icon(Icons.remove, color: Colors.grey.shade400);
    }
    
    if (isFard) {
      switch (status) {
        case 'not_prayed':
          return DeedIcons.notPrayed;
        case 'late':
          return DeedIcons.late;
        case 'on_time':
          return DeedIcons.onTime;
        case 'jamaah':
          return DeedIcons.jamaAh;
        default:
          return DeedIcons.notPrayed;
      }
    } else {
      switch (status) {
        case 'missed':
          return DeedIcons.missed;
        case 'completed':
          return DeedIcons.completed;
        default:
          return Icon(Icons.remove, color: Colors.grey.shade400);
      }
    }
  }

  String _getPrayerDisplayName(String prayerName, AppLocalizations localization) {
    switch (prayerName) {
      case PrayerNames.fajr:
        return localization.fajr;
      case PrayerNames.dhur:
        return localization.dhur;
      case PrayerNames.asr:
        return localization.asr;
      case PrayerNames.maghrib:
        return localization.maghrib;
      case PrayerNames.isa:
        return localization.isa;
      case PrayerNames.tahajjud:
        return localization.tahajjud;
      case PrayerNames.witr:
        return localization.witr;
      case PrayerNames.taraweeh:
        return localization.taraweeh;
      default:
        return prayerName;
    }
  }
}

/// Popup dialog for selecting prayer status
class PrayerPopup extends StatelessWidget {
  final String prayerName;
  final String? currentStatus;
  final bool isFard;
  final Function(String status) onStatusSelected;

  const PrayerPopup({
    super.key,
    required this.prayerName,
    required this.currentStatus,
    required this.isFard,
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
        children: isFard ? _buildFardOptions(localization) : _buildNaflOptions(localization),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localization.cancel),
        ),
      ],
    );
  }

  List<Widget> _buildFardOptions(AppLocalizations localization) {
    return [
      _buildOption(
        localization.notPrayed,
        DeedColors.notPrayed,
        Icons.close,
        'not_prayed',
      ),
      _buildOption(
        localization.late,
        DeedColors.late,
        Icons.access_time,
        'late',
      ),
      _buildOption(
        localization.onTime,
        DeedColors.onTime,
        Icons.check_circle,
        'on_time',
      ),
      _buildOption(
        localization.inJamaah,
        DeedColors.jamaAh,
        Icons.people,
        'jamaah',
      ),
    ];
  }

  List<Widget> _buildNaflOptions(AppLocalizations localization) {
    return [
      _buildOption(
        localization.missed,
        DeedColors.missed,
        Icons.cancel,
        'missed',
      ),
      _buildOption(
        localization.completed,
        DeedColors.completed,
        Icons.check_circle,
        'completed',
      ),
    ];
  }

  Widget _buildOption(
    String label,
    Color color,
    IconData icon,
    String status,
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

  String _getPrayerDisplayName(String prayerName, AppLocalizations localization) {
    switch (prayerName) {
      case PrayerNames.fajr:
        return localization.fajr;
      case PrayerNames.dhur:
        return localization.dhur;
      case PrayerNames.asr:
        return localization.asr;
      case PrayerNames.maghrib:
        return localization.maghrib;
      case PrayerNames.isa:
        return localization.isa;
      case PrayerNames.tahajjud:
        return localization.tahajjud;
      case PrayerNames.witr:
        return localization.witr;
      case PrayerNames.taraweeh:
        return localization.taraweeh;
      default:
        return prayerName;
    }
  }
}
