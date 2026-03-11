import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../custom_daily_deed_model.dart';
import '../custom_daily_deed_service.dart';
import '../constants.dart';

/// Custom Daily Deeds section displaying user-created daily deeds with status
class CustomDeedsSection extends StatelessWidget {
  final String userId;
  final DateTime currentDate;
  final Function(String deedId, String status) onStatusChanged;
  final VoidCallback onAddPressed;
  final Function(CustomDailyDeed deed) onEditPressed;

  const CustomDeedsSection({
    super.key,
    required this.userId,
    required this.currentDate,
    required this.onStatusChanged,
    required this.onAddPressed,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return StreamBuilder(
      stream: CustomDailyDeedService.streamUserCustomDeeds(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final allDeeds = snapshot.data?.docs
                .map((doc) => CustomDailyDeed.fromMap(
                    doc.data() as Map<String, dynamic>))
                .toList() ??
            [];

        // Filter active deeds for current date
        final activeDeeds =
            allDeeds.where((deed) => deed.isActiveOnDate(currentDate)).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.task_alt,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        localization.customDailyDeeds,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    color: DeedColors.primary,
                    onPressed: onAddPressed,
                    tooltip: localization.addCustomDeed,
                  ),
                ],
              ),
            ),

            // Custom deeds list
            if (activeDeeds.isEmpty)
              _buildEmptyState(context, localization)
            else
              _buildDeedsList(context, activeDeeds, localization),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations localization) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DeedColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            localization.noCustomDeeds,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            localization.tapToAddDeed,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeedsList(
    BuildContext context,
    List<CustomDailyDeed> deeds,
    AppLocalizations localization,
  ) {
    return Column(
      children: deeds.map((deed) {
        return FutureBuilder<CustomDeedEntry?>(
          future: CustomDailyDeedService.getCustomDeedStatus(
            userId: userId,
            date: currentDate,
            deedId: deed.id,
          ),
          builder: (context, snapshot) {
            final entry = snapshot.data;
            return _CustomDeedCard(
              deed: deed,
              entry: entry,
              onTap: () => _showStatusPopup(context, deed, entry?.status),
              onLongPress: () => onEditPressed(deed),
            );
          },
        );
      }).toList(),
    );
  }

  void _showStatusPopup(
    BuildContext context,
    CustomDailyDeed deed,
    String? currentStatus,
  ) {
    final localization = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          deed.name,
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
              deed.id,
              currentStatus,
            ),
            _buildOption(
              localization.completed,
              DeedColors.completed,
              Icons.check_circle,
              'completed',
              context,
              deed.id,
              currentStatus,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localization.cancel),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    String label,
    Color color,
    IconData icon,
    String status,
    BuildContext context,
    String deedId,
    String? currentStatus,
  ) {
    final isSelected = currentStatus == status;

    return GestureDetector(
      onTap: () {
        onStatusChanged(deedId, status);
        Navigator.of(context).pop();
      },
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
}

/// Card widget for a single custom deed
class _CustomDeedCard extends StatelessWidget {
  final CustomDailyDeed deed;
  final CustomDeedEntry? entry;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _CustomDeedCard({
    required this.deed,
    this.entry,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(entry?.status);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
        child: Row(
          children: [
            // Status icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: _getStatusIcon(entry?.status),
            ),
            const SizedBox(width: 12),
            // Deed name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deed.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (!deed.isForever && deed.startDate != null && deed.endDate != null)
                    Text(
                      '${_formatDate(deed.startDate!)} - ${_formatDate(deed.endDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
            // Edit indicator
            Icon(
              Icons.more_vert,
              color: Colors.grey.shade400,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
