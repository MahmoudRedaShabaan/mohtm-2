import 'package:flutter/material.dart';
import '../hijri_date_util.dart';

/// Date header component displaying Gregorian and Hijri dates with navigation
class DateHeader extends StatelessWidget {
  final DateTime currentDate;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;
  final bool canGoNext;
  final bool canGoPrevious;

  const DateHeader({
    super.key,
    required this.currentDate,
    required this.onPreviousDay,
    required this.onNextDay,
    this.canGoPrevious = true,
    this.canGoNext = true,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = HijriDateUtil.isToday(currentDate);
    final gregorianDate = HijriDateUtil.getGregorianDate(currentDate);
    final hijriDate = HijriDateUtil.getHijriDate(currentDate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Today indicator
          if (isToday)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Today',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          
          const SizedBox(height: 8),
          
          // Date navigation row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous day button
              IconButton(
                onPressed: canGoPrevious ? onPreviousDay : null,
                icon: const Icon(Icons.chevron_left),
                disabledColor: Colors.grey.shade300,
              ),
              
              // Dates
              Expanded(
                child: Column(
                  children: [
                    // Gregorian date
                    Text(
                      gregorianDate,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    // Hijri date
                    Text(
                      hijriDate,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // Next day button
              IconButton(
                onPressed: canGoNext ? onNextDay : null,
                icon: const Icon(Icons.chevron_right),
                disabledColor: Colors.grey.shade300,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Compact date header for use in other components
class CompactDateHeader extends StatelessWidget {
  final DateTime date;

  const CompactDateHeader({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final gregorianDate = HijriDateUtil.getGregorianDate(date);
    final hijriDate = HijriDateUtil.getHijriDate(date);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          gregorianDate,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          hijriDate,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
