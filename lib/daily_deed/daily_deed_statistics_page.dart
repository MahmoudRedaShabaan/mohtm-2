import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'hijri_date_util.dart';
import 'statistics_model.dart';
import 'statistics_service.dart';
import 'constants.dart';

/// Statistics page for daily deeds
class DailyDeedStatisticsPage extends StatefulWidget {
  final String userId;
  final bool showAppBar;

  const DailyDeedStatisticsPage({
    super.key,
    required this.userId,
    this.showAppBar = true,
  });

  @override
  State<DailyDeedStatisticsPage> createState() => _DailyDeedStatisticsPageState();
}

class _DailyDeedStatisticsPageState extends State<DailyDeedStatisticsPage> {
  late StatisticsService _statisticsService;
  int _selectedYear = 0;
  int _selectedMonth = 0;
  DailyDeedStatistics? _statistics;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _statisticsService = StatisticsService(userId: widget.userId);
    _initializeCurrentMonth();
  }

  void _initializeCurrentMonth() {
    final currentMonth = HijriDateUtil.getCurrentHijriMonth();
    final currentYear = HijriDateUtil.getCurrentHijriYear();
    _selectedYear = currentYear;
    _selectedMonth = currentMonth;
    _loadStatistics();
  }

  void _goToPreviousMonth() {
    setState(() {
      if (_selectedMonth == 1) {
        _selectedMonth = 12;
        _selectedYear--;
      } else {
        _selectedMonth--;
      }
    });
    _loadStatistics();
  }

  void _goToNextMonth() {
    setState(() {
      if (_selectedMonth == 12) {
        _selectedMonth = 1;
        _selectedYear++;
      } else {
        _selectedMonth++;
      }
    });
    _loadStatistics();
  }

  void _loadStatistics() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stats = await _statisticsService.getMonthlyStatistics(
        _selectedYear,
        _selectedMonth,
      );
      
      if (!mounted) return;
      
      setState(() {
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: Text(localization.statisticsreligiousDeed),
              backgroundColor: const Color.fromARGB(255, 117, 92, 142),
            )
          : null,
      body: _isLoading || _selectedMonth == 0
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _statistics == null
                  ? const Center(child: Text('No data available'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Month selector
                          _buildMonthSelector(localization),
                          const SizedBox(height: 16),
                          
                          // Month info
                          _buildMonthInfo(),
                          const SizedBox(height: 24),
                          
                          // Prayer statistics (5 mandatory)
                          _buildPrayerStatistics(localization),
                          const SizedBox(height: 16),
                          
                          // Nafl prayers statistics (tahajjud, witr, taraweeh)
                          _buildNaflPrayerStatistics(localization),
                          const SizedBox(height: 16),
                          
                          // Sunnah statistics
                          _buildSunnahStatistics(localization),
                          const SizedBox(height: 16),
                          
                          // Supplications statistics
                          _buildSupplicationsStatistics(localization),
                          const SizedBox(height: 16),
                          
                          // Learning statistics
                          _buildLearningStatistics(localization),
                          const SizedBox(height: 16),
                          
                          // Fasting statistics (only in Ramadan)
                          if (_statistics!.isRamadan)
                            _buildFastingStatistics(localization),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildMonthSelector(AppLocalizations localization) {
    final monthName = _statisticsService.getMonthName(_selectedMonth);
    final isCurrentMonth = _selectedMonth == HijriDateUtil.getCurrentHijriMonth() && 
                           _selectedYear == HijriDateUtil.getCurrentHijriYear();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Current month indicator
          if (isCurrentMonth)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: DeedColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                localization.currentMonth,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          
          const SizedBox(height: 8),
          
          // Month navigation row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous month button
              IconButton(
                onPressed: _goToPreviousMonth,
                icon: const Icon(Icons.chevron_left),
                color: DeedColors.primary,
              ),
              
              // Month name
              Expanded(
                child: Column(
                  children: [
                    Text(
                      monthName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: DeedColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_selectedYear AH',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // Next month button
              IconButton(
                onPressed: _goToNextMonth,
                icon: const Icon(Icons.chevron_right),
                color: DeedColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthInfo() {
    final stats = _statistics!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DeedColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '${stats.monthName} ${stats.hijriYear}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: DeedColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${stats.daysInMonth} ${AppLocalizations.of(context)!.daysInMonth}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerStatistics(AppLocalizations localization) {
    final stats = _statistics!;
    
    return ExpansionTile(
      title: Text(
        localization.prayers,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      children: [
        for (final entry in stats.prayerStats.entries)
          _buildPrayerStatItem(localization, entry.value),
      ],
    );
  }

  Widget _buildPrayerStatItem(AppLocalizations localization, PrayerStat stat) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getPrayerIcon(stat.prayerName), size: 24),
                const SizedBox(width: 8),
                Text(
                  _getPrayerLocalizedName(localization, stat.prayerName),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildPrayerStatBar(localization, stat),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerStatBar(AppLocalizations localization, PrayerStat stat) {
    final total = stat.total;
    if (total == 0) return const SizedBox.shrink();

    return Column(
      children: [
        // Progress bars
        Row(
          children: [
            _buildColoredBar(DeedColors.notPrayed, stat.notPrayed / total),
            _buildColoredBar(DeedColors.late, stat.late / total),
            _buildColoredBar(DeedColors.onTime, stat.onTime / total),
            _buildColoredBar(DeedColors.jamaAh, stat.jamaAh / total),
            _buildColoredBar(Colors.grey[300]!, stat.notSelected / total),
          ],
        ),
        const SizedBox(height: 8),
        // Legend
        Wrap(
          spacing: 16,
          children: [
            _buildLegendItem(DeedColors.notPrayed, localization.notPrayed, stat.notPrayed),
            _buildLegendItem(DeedColors.late, localization.late, stat.late),
            _buildLegendItem(DeedColors.onTime, localization.onTime, stat.onTime),
            _buildLegendItem(DeedColors.jamaAh, localization.inJamaah, stat.jamaAh),
            _buildLegendItem(Colors.grey[300]!, localization.notSelected, stat.notSelected),
          ],
        ),
      ],
    );
  }

  Widget _buildNaflPrayerStatistics(AppLocalizations localization) {
    final stats = _statistics!;
    
    // Only show if there are nafl prayers to display
    if (stats.naflPrayerStats.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return ExpansionTile(
      title: Text(
        localization.naflPrayers,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      children: [
        for (final entry in stats.naflPrayerStats.entries)
          _buildNaflPrayerStatItem(localization, entry.value),
      ],
    );
  }

  Widget _buildNaflPrayerStatItem(AppLocalizations localization, NaflPrayerStat stat) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getPrayerIcon(stat.prayerName), size: 24),
                const SizedBox(width: 8),
                Text(
                  _getPrayerLocalizedName(localization, stat.prayerName),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildNaflStatBar(localization, stat),
          ],
        ),
      ),
    );
  }

  Widget _buildNaflStatBar(AppLocalizations localization, NaflPrayerStat stat) {
    final total = stat.total;
    if (total == 0) return const SizedBox.shrink();

    return Column(
      children: [
        // Progress bars (only missed and completed)
        Row(
          children: [
            _buildColoredBar(DeedColors.missed, stat.missed / total),
            _buildColoredBar(DeedColors.completed, stat.completed / total),
            _buildColoredBar(Colors.grey[300]!, stat.notSelected / total),
          ],
        ),
        const SizedBox(height: 8),
        // Legend
        Wrap(
          spacing: 16,
          children: [
            _buildLegendItem(DeedColors.missed, localization.missed, stat.missed),
            _buildLegendItem(DeedColors.completed, localization.completed, stat.completed),
            _buildLegendItem(Colors.grey[300]!, localization.notSelected, stat.notSelected),
          ],
        ),
      ],
    );
  }

  Widget _buildSunnahStatistics(AppLocalizations localization) {
    final stats = _statistics!;
    
    return ExpansionTile(
      title: Text(
        localization.sunnahPrayers,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      children: [
        for (final entry in stats.sunnahStats.entries)
          _buildSunnahStatItem(localization, entry.value),
      ],
    );
  }

  Widget _buildSunnahStatItem(AppLocalizations localization, SunnahStat stat) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getSunnahIcon(stat.prayerName), size: 24),
                const SizedBox(width: 8),
                Text(
                  _getSunnahLocalizedName(localization, stat.prayerName),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSunnahStatBar(localization, stat),
          ],
        ),
      ),
    );
  }

  Widget _buildSunnahStatBar(AppLocalizations localization, SunnahStat stat) {
    final total = stat.total;
    if (total == 0) return const SizedBox.shrink();

    return Column(
      children: [
        Row(
          children: [
            _buildColoredBar(DeedColors.missed, stat.missed / total),
            _buildColoredBar(DeedColors.completed, stat.completed / total),
            _buildColoredBar(Colors.grey[300]!, stat.notSelected / total),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          children: [
            _buildLegendItem(DeedColors.missed, localization.missed, stat.missed),
            _buildLegendItem(DeedColors.completed, localization.completed, stat.completed),
            _buildLegendItem(Colors.grey[300]!, localization.notSelected, stat.notSelected),
          ],
        ),
      ],
    );
  }

  Widget _buildSupplicationsStatistics(AppLocalizations localization) {
    final stats = _statistics!;
    
    return ExpansionTile(
      title: Text(
        localization.supplications,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      children: [
        for (final entry in stats.supplicationStats.entries)
          _buildSupplicationStatItem(localization, entry.value),
      ],
    );
  }

  Widget _buildSupplicationStatItem(AppLocalizations localization, SupplicationStat stat) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getSupplicationIcon(stat.supplicationName), size: 24),
                const SizedBox(width: 8),
                Text(
                  _getSupplicationLocalizedName(localization, stat.supplicationName),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSupplicationStatBar(localization, stat),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplicationStatBar(AppLocalizations localization, SupplicationStat stat) {
    final total = stat.total;
    if (total == 0) return const SizedBox.shrink();

    return Column(
      children: [
        Row(
          children: [
            _buildColoredBar(DeedColors.missed, stat.missed / total),
            _buildColoredBar(DeedColors.completed, stat.completed / total),
            _buildColoredBar(Colors.grey[300]!, stat.notSelected / total),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          children: [
            _buildLegendItem(DeedColors.missed, localization.missed, stat.missed),
            _buildLegendItem(DeedColors.completed, localization.completed, stat.completed),
            _buildLegendItem(Colors.grey[300]!, localization.notSelected, stat.notSelected),
          ],
        ),
      ],
    );
  }

  IconData _getSupplicationIcon(String supplicationName) {
    switch (supplicationName) {
      case 'morning_supplications':
        return Icons.wb_sunny;
      case 'evening_supplications':
        return Icons.nights_stay;
      case 'surah_al_kahf':
        return Icons.menu_book;
      case 'eid_prayer':
        return Icons.celebration;
      default:
        return Icons.record_voice_over;
    }
  }

  String _getSupplicationLocalizedName(AppLocalizations localization, String supplicationName) {
    switch (supplicationName) {
      case 'morning_supplications':
        return localization.morningSupplications;
      case 'evening_supplications':
        return localization.eveningSupplications;
      case 'surah_al_kahf':
        return localization.surahAlKahf;
      case 'eid_prayer':
        return localization.eidPrayer;
      default:
        return supplicationName;
    }
  }

  Widget _buildLearningStatistics(AppLocalizations localization) {
    final stats = _statistics!;
    
    return ExpansionTile(
      title: Text(
        localization.learning,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      children: [
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.menu_book, size: 24),
                    const SizedBox(width: 8),
                    Text(localization.readQuran, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 16),
                Text('${localization.totalChaptersRead}: ${stats.learningStat.chaptersRead}'),
                Text('${localization.daysWithReading}: ${stats.learningStat.daysWithReading}'),
                Text('${localization.notSelected}: ${stats.learningStat.notSelected}'),
                const SizedBox(height: 12),
                if (stats.learningStat.chapterDistribution.isNotEmpty)
                  _buildChapterDistribution(localization),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChapterDistribution(AppLocalizations localization) {
    final distribution = _statistics!.learningStat.chapterDistribution;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(localization.distribution, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        ...distribution.entries.map((e) {
          final chapters = e.key;
          final count = e.value;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text('${chapters.toStringAsFixed(chapters.truncateToDouble() == chapters ? 0 : 2)} ${localization.parts}'),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: count / distribution.values.reduce((a, b) => a + b),
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(DeedColors.primary),
                  ),
                ),
                SizedBox(
                  width: 30,
                  child: Text('$count', textAlign: TextAlign.end),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFastingStatistics(AppLocalizations localization) {
    final stats = _statistics!;
    
    return ExpansionTile(
      title: Text(
        localization.fasting,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      children: [
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.wb_sunny, size: 24),
                    SizedBox(width: 8),
                    Text('Ramadan Fasting', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 16),
                // Progress bars
                Row(
                  children: [
                    _buildColoredBar(DeedColors.completed, stats.fastingStat.completed / stats.daysInMonth),
                    _buildColoredBar(DeedColors.missed, stats.fastingStat.missed / stats.daysInMonth),
                    _buildColoredBar(Colors.grey[300]!, stats.fastingStat.notSelected / stats.daysInMonth),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  children: [
                    _buildLegendItem(DeedColors.completed, localization.completed, stats.fastingStat.completed),
                    _buildLegendItem(DeedColors.missed, localization.missed, stats.fastingStat.missed),
                    _buildLegendItem(Colors.grey[300]!, localization.notSelected, stats.fastingStat.notSelected),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColoredBar(Color color, double ratio) {
    return Expanded(
      child: Container(
        height: 8,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text('$label ($count)'),
      ],
    );
  }

  IconData _getPrayerIcon(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return Icons.wb_sunny;
      case 'dhur':
        return Icons.wb_twighlight;
      case 'asr':
        return Icons.light_mode;
      case 'maghrib':
        return Icons.nights_stay;
      case 'isa':
        return Icons.dark_mode;
      case 'tahajjud':
        return Icons.bedtime;
      case 'witr':
        return Icons.wb_twighlight;
      case 'taraweeh':
        return Icons.mosque;
      default:
        return Icons.access_time;
    }
  }

  String _getPrayerLocalizedName(AppLocalizations localization, String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return localization.fajr;
      case 'dhur':
        return localization.dhur;
      case 'asr':
        return localization.asr;
      case 'maghrib':
        return localization.maghrib;
      case 'isa':
        return localization.isa;
      case 'tahajjud':
        return localization.tahajjud;
      case 'witr':
        return localization.witr;
      case 'taraweeh':
        return localization.taraweeh;
      default:
        return prayerName;
    }
  }

  IconData _getSunnahIcon(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajrsunnah':
        return Icons.wb_sunny;
      case 'doha':
        return Icons.wb_twighlight;
      case 'dhursunnah':
        return Icons.wb_twighlight;
      case 'maghribsunnah':
        return Icons.nights_stay;
      case 'is sunnah':
        return Icons.dark_mode;
      default:
        return Icons.access_time;
    }
  }

  String _getSunnahLocalizedName(AppLocalizations localization, String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajrsunnah':
        return localization.fajrSunnah;
      case 'doha':
        return localization.doha;
      case 'dhursunnah':
        return localization.dhurSunnah;
      case 'maghribsunnah':
        return localization.maghribSunnah;
      case 'isasunnah':
        return localization.isaSunnah;
      default:
        return prayerName;
    }
  }
}
