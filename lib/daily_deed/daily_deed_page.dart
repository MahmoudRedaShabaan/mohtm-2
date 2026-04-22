import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../l10n/app_localizations.dart';
import 'daily_deed_model.dart';
import 'daily_deed_service.dart';
import 'custom_daily_deed_service.dart';
import 'custom_daily_deed_model.dart';
import 'daily_deed_statistics_page.dart';
import 'hijri_date_util.dart';
import 'components/date_header.dart';
import 'components/prayer_section.dart';
import 'components/learning_section.dart';
import 'components/fasting_section.dart';
import 'components/sunnah_section.dart';
import 'components/custom_deeds_section.dart';
import '../../add_custom_daily_deed_page.dart';
import 'constants.dart';

/// Main Daily Deed page displaying user's daily religious activities
class DailyDeedPage extends StatefulWidget {
  final String userId;
  final bool showAppBar;

  const DailyDeedPage({
    super.key,
    required this.userId,
    this.showAppBar = true,
  });

  @override
  State<DailyDeedPage> createState() => _DailyDeedPageState();
}

class _DailyDeedPageState extends State<DailyDeedPage> {
  DateTime _currentDate = DateTime.now();
  DailyDeed? _dailyDeed;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDailyDeed();
  }

  @override
  void didUpdateWidget(DailyDeedPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _loadDailyDeed();
    }
  }

  Future<void> _loadDailyDeed() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final deed = await DailyDeedService.getDailyDeed(
        widget.userId,
        _currentDate,
      );
      if (!mounted) return;
      setState(() {
        _dailyDeed = deed;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _getConnectionErrorMessage(e);
        _isLoading = false;
      });
    }
  }

  String _getConnectionErrorMessage(dynamic error) {
    if (error is FirebaseException) {
      return 'connection Issue';
    }
    return error.toString();
  }

  Future<void> _navigateToDate(DateTime newDate) async {
    if (!HijriDateUtil.isDateValid(newDate)) {
      _showDateErrorDialog(context);
      return;
    }

    if (!mounted) return;
    setState(() {
      _currentDate = newDate;
      _isLoading = true;
    });
    await _loadDailyDeed();
  }

  void _showDateErrorDialog(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(localization.error),
            content: Text(
              'Date is out of range. Please select a date between ${HijriDateUtil.getMinDate().year}-${HijriDateUtil.getMinDate().month}-${HijriDateUtil.getMinDate().day} and ${HijriDateUtil.getMaxDate().year}-${HijriDateUtil.getMaxDate().month}-${HijriDateUtil.getMaxDate().day}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(localization.confirm),
              ),
            ],
          ),
    );
  }

  Future<void> _updatePrayerStatus(String prayerName, String status) async {
    try {
      await DailyDeedService.updatePrayerStatus(
        userId: widget.userId,
        date: _currentDate,
        prayerName: prayerName,
        status: status,
      );
      await _loadDailyDeed();
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _updateQuranProgress(double chapters) async {
    try {
      await DailyDeedService.updateQuranProgress(
        userId: widget.userId,
        date: _currentDate,
        chapters: chapters,
      );
      await _loadDailyDeed();
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _updateFastingStatus(String status) async {
    try {
      await DailyDeedService.updateFastingStatus(
        userId: widget.userId,
        date: _currentDate,
        status: status,
      );
      await _loadDailyDeed();
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _updateSunnahPrayerStatus(
    String prayerName,
    String status,
  ) async {
    try {
      await DailyDeedService.updateSunnahPrayerStatus(
        userId: widget.userId,
        date: _currentDate,
        prayerName: prayerName,
        status: status,
      );
      await _loadDailyDeed();
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _updateSupplicationStatus(
    String supplicationName,
    String status,
  ) async {
    try {
      await DailyDeedService.updateSupplicationStatus(
        userId: widget.userId,
        date: _currentDate,
        supplicationName: supplicationName,
        status: status,
      );
      await _loadDailyDeed();
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _updateSurahAlKahfStatus(String status) async {
    try {
      await DailyDeedService.updateSurahAlKahfStatus(
        userId: widget.userId,
        date: _currentDate,
        status: status,
      );
      await _loadDailyDeed();
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _updateEidPrayerStatus(String status) async {
    try {
      await DailyDeedService.updateEidPrayerStatus(
        userId: widget.userId,
        date: _currentDate,
        status: status,
      );
      await _loadDailyDeed();
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _updateCustomDeedStatus(String deedId, String status) async {
    try {
      await CustomDailyDeedService.updateCustomDeedStatus(
        userId: widget.userId,
        date: _currentDate,
        deedId: deedId,
        status: status,
      );
      setState(() {}); // Refresh to update the UI
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _navigateToAddCustomDeed() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AddCustomDailyDeedPage()),
    );
    if (result == true) {
      setState(() {}); // Refresh to show new deed
    }
  }

  Future<void> _navigateToEditCustomDeed(CustomDailyDeed deed) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddCustomDailyDeedPage(deed: deed),
      ),
    );
    if (result == true) {
      setState(() {}); // Refresh to show updated deed
    }
  }

  void _showErrorDialog(String message) {
    final localization = AppLocalizations.of(context)!;
    final isConnectionError = message == 'firebase_exception';
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              isConnectionError
                  ? localization.connectionIssue
                  : localization.errorOccurred,
            ),
            content: Text(
              isConnectionError ? localization.connectionIssue : message,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(localization.confirm),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isToday = HijriDateUtil.isToday(_currentDate);
    final canGoNext =
        !HijriDateUtil.isFuture(_currentDate) &&
        _currentDate.isBefore(HijriDateUtil.getMaxDate());

    return Scaffold(
      appBar:
          widget.showAppBar
              ? AppBar(
                title: Text(localization.religiousDeed),
                centerTitle: true,
                backgroundColor: const Color(0xFF4DB6AC),
                actions: [
                  if (isToday)
                    Container(
                      margin: const EdgeInsets.only(
                        right: 16,
                        top: 8,
                        bottom: 8,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          'Today',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(
                      Icons.bar_chart,
                      color: DeedColors.primary,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => DailyDeedStatisticsPage(
                                userId: widget.userId,
                                showAppBar: true,
                              ),
                        ),
                      );
                    },
                  ),
                ],
              )
              : null,
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_error!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadDailyDeed,
                      child: Text(localization.retry),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date header
                    DateHeader(
                      currentDate: _currentDate,
                      onPreviousDay:
                          () => _navigateToDate(
                            HijriDateUtil.navigateDate(_currentDate, -1),
                          ),
                      onNextDay:
                          () => _navigateToDate(
                            HijriDateUtil.navigateDate(_currentDate, 1),
                          ),
                      canGoPrevious:
                          !_currentDate.isBefore(HijriDateUtil.getMinDate()),
                      canGoNext: canGoNext,
                    ),

                    const SizedBox(height: 24),

                    // Prayer section
                    PrayerSection(
                      prayers: _dailyDeed?.prayers ?? {},
                      isRamadan: _dailyDeed?.isRamadan ?? false,
                      isEid: HijriDateUtil.isEid(_currentDate),
                      eidPrayer: _dailyDeed?.eidPrayer,
                      onPrayerStatusChanged: _updatePrayerStatus,
                      onEidStatusChanged: _updateEidPrayerStatus,
                    ),

                    const SizedBox(height: 24),

                    // Sunnah Prayers section
                    SunnahSection(
                      sunnahPrayers: _dailyDeed?.sunnahPrayers ?? {},
                      onPrayerStatusChanged: _updateSunnahPrayerStatus,
                    ),

                    const SizedBox(height: 24),

                    // Learning section
                    LearningSection(
                      learning:
                          _dailyDeed?.learning ?? QuranEntry(chapters: 0.0),
                      supplications: _dailyDeed?.supplications ?? {},
                      surahAlKahf: _dailyDeed?.surahAlKahf,
                      isFriday: _currentDate.weekday == DateTime.friday,
                      onChaptersChanged: _updateQuranProgress,
                      onSupplicationStatusChanged: _updateSupplicationStatus,
                      onSurahAlKahfStatusChanged: _updateSurahAlKahfStatus,
                    ),

                    // Fasting section (shown during Ramadan or days 13-15 of any month, or day 9 of Dhu al-Hijjah)
                    if ((_dailyDeed?.isRamadan ?? false) ||
                        HijriDateUtil.shouldShowFasting(_currentDate)) ...[
                      const SizedBox(height: 24),
                      FastingSection(
                        fasting: _dailyDeed?.fasting,
                        onFastingStatusChanged: _updateFastingStatus,
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Custom Daily Deeds section
                    CustomDeedsSection(
                      userId: widget.userId,
                      currentDate: _currentDate,
                      onStatusChanged: _updateCustomDeedStatus,
                      onAddPressed: _navigateToAddCustomDeed,
                      onEditPressed: _navigateToEditCustomDeed,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
    );
  }
}
