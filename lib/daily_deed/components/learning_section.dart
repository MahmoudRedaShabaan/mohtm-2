import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../daily_deed_model.dart';
import '../constants.dart';

/// Learning section for Quran reading progress and Supplications
class LearningSection extends StatelessWidget {
  final QuranEntry learning;
  final Map<String, PrayerEntry> supplications;
  final PrayerEntry? surahAlKahf;
  final bool isFriday;
  final Function(double chapters) onChaptersChanged;
  final Function(String supplicationName, String status) onSupplicationStatusChanged;
  final Function(String status)? onSurahAlKahfStatusChanged;

  const LearningSection({
    super.key,
    required this.learning,
    required this.supplications,
    this.surahAlKahf,
    this.isFriday = false,
    required this.onChaptersChanged,
    required this.onSupplicationStatusChanged,
    this.onSurahAlKahfStatusChanged,
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
                Icons.menu_book,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                localization.learning,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        
        // Learning card
        GestureDetector(
          onTap: () => _showQuranPopup(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DeedColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getCompletionColor().withOpacity(0.3),
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
                        color: _getCompletionColor().withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getCompletionIcon(),
                        color: _getCompletionColor(),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localization.readQuran,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getChaptersText(learning.chapters, localization),
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

        const SizedBox(height: 16),

        // Supplications cards (Morning and Evening)
        Column(
          children: [
            // Row 1: Morning Supplications
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _supplicationCard(
                    context: context,
                    supplicationName: PrayerNames.morningSupplications,
                    status: supplications[PrayerNames.morningSupplications]?.status,
                    onTap: () => _showSupplicationPopup(context, PrayerNames.morningSupplications),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _supplicationCard(
                    context: context,
                    supplicationName: PrayerNames.eveningSupplications,
                    status: supplications[PrayerNames.eveningSupplications]?.status,
                    onTap: () => _showSupplicationPopup(context, PrayerNames.eveningSupplications),
                  ),
                ),
              ],
            ),
          ],
        ),

        // Surah Al-Kahf (only on Fridays)
        if (isFriday) ...[
          const SizedBox(height: 16),
          _surahAlKahfCard(context),
        ],
      ],
    );
  }

  Widget _surahAlKahfCard(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final status = surahAlKahf?.status;
    final color = _getSupplicationStatusColor(status);

    return GestureDetector(
      onTap: () => _showSurahAlKahfPopup(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: _getSupplicationStatusIcon(status),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localization.surahAlKahf,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status == null 
                          ? localization.selectChapters
                          : (status == 'completed' ? localization.completed : localization.missed),
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
    );
  }

  void _showSurahAlKahfPopup(BuildContext context) {
    if (onSurahAlKahfStatusChanged == null) return;
    
    showDialog(
      context: context,
      builder: (context) => SupplicationPopup(
        supplicationName: PrayerNames.surahAlKahf,
        currentStatus: surahAlKahf?.status,
        onStatusSelected: (status) {
          onSurahAlKahfStatusChanged!(status);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _supplicationCard({
    required BuildContext context,
    required String supplicationName,
    required String? status,
    required VoidCallback onTap,
  }) {
    final color = _getSupplicationStatusColor(status);
    final localization = AppLocalizations.of(context)!;

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
            // Supplication icon/indicator
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: _getSupplicationStatusIcon(status),
            ),
            const SizedBox(height: 6),
            // Supplication name
            Text(
              _getSupplicationDisplayName(supplicationName, localization),
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

  Color _getSupplicationStatusColor(String? status) {
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

  Widget _getSupplicationStatusIcon(String? status) {
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

  String _getSupplicationDisplayName(String supplicationName, AppLocalizations localization) {
    switch (supplicationName) {
      case PrayerNames.morningSupplications:
        return localization.morningSupplications;
      case PrayerNames.eveningSupplications:
        return localization.eveningSupplications;
      default:
        return supplicationName;
    }
  }

  void _showSupplicationPopup(BuildContext context, String supplicationName) {
    showDialog(
      context: context,
      builder: (context) => SupplicationPopup(
        supplicationName: supplicationName,
        currentStatus: supplications[supplicationName]?.status,
        onStatusSelected: (status) {
          onSupplicationStatusChanged(supplicationName, status);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Color _getCompletionColor() {
    if (learning.chapters == 0) {
      return Colors.grey;
    } else if (learning.chapters < 1) {
      return DeedColors.late;
    } else {
      return DeedColors.completed;
    }
  }

  IconData _getCompletionIcon() {
    if (learning.chapters == 0) {
      return Icons.book_outlined;
    } else if (learning.chapters < 1) {
      return Icons.access_time;
    } else {
      return Icons.check_circle;
    }
  }

  String _getChaptersText(double chapters, AppLocalizations localization) {
    if (chapters == 0) {
      return localization.selectChapters;
    } else if (chapters == chapters.roundToDouble()) {
      return '${chapters.round()} ${localization.chapters}';
    } else {
      return '${chapters} ${localization.chapters}';
    }
  }

  void _showQuranPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => QuranProgressPopup(
        currentChapters: learning.chapters,
        onChaptersSelected: (chapters) {
          onChaptersChanged(chapters);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

/// Popup dialog for selecting Quran chapters
class QuranProgressPopup extends StatelessWidget {
  final double currentChapters;
  final Function(double chapters) onChaptersSelected;

  const QuranProgressPopup({
    super.key,
    required this.currentChapters,
    required this.onChaptersSelected,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(
        localization.readQuran,
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            localization.selectChapters,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 200,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: quranChapterOptions.map((chapters) {
                final isSelected = currentChapters == chapters;
                return GestureDetector(
                  onTap: () => onChaptersSelected(chapters),
                  child: Container(
                    width: 90,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected 
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        chapters == chapters.roundToDouble()
                            ? '${chapters.round()}'
                            : '$chapters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected 
                              ? Theme.of(context).colorScheme.primary
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
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
}

/// Popup dialog for selecting supplication status
class SupplicationPopup extends StatelessWidget {
  final String supplicationName;
  final String? currentStatus;
  final Function(String status) onStatusSelected;

  const SupplicationPopup({
    super.key,
    required this.supplicationName,
    required this.currentStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(
        _getSupplicationDisplayName(supplicationName, localization),
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

  String _getSupplicationDisplayName(String supplicationName, AppLocalizations localization) {
    switch (supplicationName) {
      case PrayerNames.morningSupplications:
        return localization.morningSupplications;
      case PrayerNames.eveningSupplications:
        return localization.eveningSupplications;
      default:
        return supplicationName;
    }
  }
}
