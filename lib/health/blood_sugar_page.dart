import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/health/blood_sugar_model.dart';
import 'package:myapp/health/blood_sugar_service.dart';
import 'package:myapp/health/add_blood_sugar_page.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:myapp/health/arabic_font_helper.dart';

class BloodSugarPage extends StatefulWidget {
  const BloodSugarPage({super.key});

  @override
  State<BloodSugarPage> createState() => _BloodSugarPageState();
}

class _BloodSugarPageState extends State<BloodSugarPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BloodSugarService _service = BloodSugarService();
  String? _userId;
  bool _isLoading = true;
  List<BloodSugarMeasurement> _todayMeasurements = [];
  BloodSugarStatistics _todayStats = BloodSugarStatistics.empty();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
      try {
        // Load user settings for ranges
        final userSettings = await _service.getUserSettings(_userId!);
        if (userSettings != null) {
          SugarRange.userRanges = userSettings;
        }

        final measurements = await _service.getTodayMeasurements(_userId!);
        final stats = await _service.getTodayStatistics(_userId!);
        if (!mounted) return;
        setState(() {
          _todayMeasurements = measurements;
          _todayStats = stats;
          _isLoading = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bloodSugar),
        backgroundColor: const Color(0xFF81C784),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.track_changes), text: l10n.track),
            Tab(icon: const Icon(Icons.history), text: l10n.history),
            Tab(icon: const Icon(Icons.settings), text: l10n.settings),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTrackTab(l10n, isArabic),
          _buildHistoryTab(l10n, isArabic),
          _buildSettingsTab(l10n, isArabic),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddMeasurement(context),
        backgroundColor: const Color(0xFF81C784),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTrackTab(AppLocalizations l10n, bool isArabic) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Card
            _buildStatisticsCard(l10n),
            const SizedBox(height: 20),

            // Today's Measurements Header
            Text(
              l10n.todayMeasurements,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Measurements List
            if (_todayMeasurements.isEmpty)
              _buildEmptyState(l10n)
            else
              _buildMeasurementsList(l10n, isArabic),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(AppLocalizations l10n) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF81C784), Color(0xFFA5D6A7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.white, size: 28),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    l10n.dailyBloodSugarStatistics,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  l10n.average,
                  _todayStats.averageValue.toStringAsFixed(0),
                  'mg/dL',
                ),
                _buildStatItem(
                  l10n.totalMeasurements,
                  _todayStats.totalMeasurements.toString(),
                  '',
                ),
                _buildStatItem(
                  l10n.min,
                  _todayStats.minValue.toStringAsFixed(0),
                  'mg/dL',
                ),
                _buildStatItem(
                  l10n.max,
                  _todayStats.maxValue.toStringAsFixed(0),
                  'mg/dL',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Category counts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCategoryCount(
                  l10n.lowBloodSugar,
                  _todayStats.lowCount,
                  Colors.blue,
                ),
                _buildCategoryCount(
                  l10n.normalBloodSugar,
                  _todayStats.normalCount,
                  Colors.green,
                ),
                _buildCategoryCount(
                  l10n.preDiabetesBloodSugar,
                  _todayStats.preDiabetesCount,
                  Colors.yellow[700]!,
                ),
                _buildCategoryCount(
                  l10n.diabetesBloodSugar,
                  _todayStats.diabetesCount,
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (unit.isNotEmpty)
          Text(
            unit,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
      ],
    );
  }

  Widget _buildCategoryCount(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.water_drop_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            l10n.noMeasurementsToday,
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tapToAddMeasurement,
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementsList(AppLocalizations l10n, bool isArabic) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _todayMeasurements.length,
      itemBuilder: (context, index) {
        final measurement = _todayMeasurements[index];
        return _buildMeasurementCard(measurement, l10n, isArabic);
      },
    );
  }

  Widget _buildMeasurementCard(
    BloodSugarMeasurement measurement,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    final color = _getCategoryColor(measurement.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color, width: 2),
      ),
      child: InkWell(
        onTap: () => _showMeasurementDetails(measurement, l10n),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    measurement.unit == 'mmoll'
                        ? measurement.value.toStringAsFixed(1)
                        : measurement.value.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      measurement.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getConditionLabel(measurement.condition, l10n),
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('h:mm a').format(measurement.date),
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getCategoryLabel(measurement.category, l10n),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    measurement.unit == 'mmoll' ? 'mmol/L' : 'mg/dL',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'low':
        return Colors.blue;
      case 'normal':
        return Colors.green;
      case 'pre_diabetes':
        return Colors.yellow[700]!;
      case 'diabetes':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryLabel(String category, AppLocalizations l10n) {
    switch (category) {
      case 'low':
        return l10n.lowBloodSugar;
      case 'normal':
        return l10n.normalBloodSugar;
      case 'pre_diabetes':
        return l10n.preDiabetesBloodSugar;
      case 'diabetes':
        return l10n.diabetesBloodSugar;
      default:
        return category;
    }
  }

  String _getConditionLabel(String condition, AppLocalizations l10n) {
    switch (condition) {
      case 'default_condition':
        return l10n.defaultCondition;
      case 'fasting':
        return l10n.fasting;
      case 'before_meal':
        return l10n.beforeMeal;
      case 'after_meal_1h':
        return l10n.afterMeal1h;
      case 'after_meal_2h':
        return l10n.afterMeal2h;
      case 'sleep':
        return l10n.sleep;
      case 'before_exercise':
        return l10n.beforeExercise;
      case 'after_exercise':
        return l10n.afterExercise;
      default:
        return condition;
    }
  }

  void _navigateToAddMeasurement(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBloodSugarPage(userId: _userId!),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }

  void _navigateToEditMeasurement(BloodSugarMeasurement measurement) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                AddBloodSugarPage(userId: _userId!, measurement: measurement),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }

  void _showMeasurementDetails(
    BloodSugarMeasurement measurement,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildDetailsSheet(measurement, l10n),
    );
  }

  Widget _buildDetailsSheet(
    BloodSugarMeasurement measurement,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                measurement.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToEditMeasurement(measurement);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                  _confirmDelete(measurement, l10n);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow(l10n.bloodSugarValue, measurement.formattedValue),
          _buildDetailRow(
            l10n.unit,
            measurement.unit == 'mmoll' ? 'mmol/L' : 'mg/dL',
          ),
          _buildDetailRow(
            l10n.condition,
            _getConditionLabel(measurement.condition, l10n),
          ),
          _buildDetailRow(
            l10n.date,
            DateFormat('MMM d, yyyy - h:mm a').format(measurement.date),
          ),
          if (measurement.description != null &&
              measurement.description!.isNotEmpty)
            _buildDetailRow(l10n.description, measurement.description!),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _confirmDelete(
    BloodSugarMeasurement measurement,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.delete),
            content: Text(l10n.deleteMeasurementConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await _service.deleteMeasurement(measurement.id!);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.measurementDeleted)),
                      );
                      _loadData();
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.errorDeletingMeasurement)),
                      );
                    }
                  }
                },
                child: Text(
                  l10n.delete,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  /// History Tab Widget
  Widget _buildHistoryTab(AppLocalizations l10n, bool isArabic) {
    return BloodSugarHistoryTab(
      userId: _userId!,
      service: _service,
      isArabic: isArabic,
    );
  }

  /// Settings Tab Widget
  Widget _buildSettingsTab(AppLocalizations l10n, bool isArabic) {
    return BloodSugarSettingsTab(
      userId: _userId!,
      service: _service,
      isArabic: isArabic,
      onSettingsSaved: _loadData,
    );
  }
}

/// Blood Sugar History Tab
class BloodSugarHistoryTab extends StatefulWidget {
  final String userId;
  final BloodSugarService service;
  final bool isArabic;

  const BloodSugarHistoryTab({
    super.key,
    required this.userId,
    required this.service,
    required this.isArabic,
  });

  @override
  State<BloodSugarHistoryTab> createState() => _BloodSugarHistoryTabState();
}

class _BloodSugarHistoryTabState extends State<BloodSugarHistoryTab>
    with SingleTickerProviderStateMixin {
  late TabController _historyTabController;
  bool _isLoading = true;
  Map<String, List<BloodSugarMeasurement>> _groupedMeasurements = {};
  String _selectedPeriod = 'week';

  @override
  void initState() {
    super.initState();
    _historyTabController = TabController(length: 3, vsync: this);
    _historyTabController.addListener(_onTabChanged);
    _loadHistoryData();
  }

  @override
  void dispose() {
    _historyTabController.removeListener(_onTabChanged);
    _historyTabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_historyTabController.indexIsChanging) {
      if (!mounted) return;
      setState(() {
        switch (_historyTabController.index) {
          case 0:
            _selectedPeriod = 'week';
            break;
          case 1:
            _selectedPeriod = 'month';
            break;
          case 2:
            _selectedPeriod = 'year';
            break;
        }
      });
      _loadHistoryData();
    }
  }

  Future<void> _loadHistoryData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      int days;
      switch (_selectedPeriod) {
        case 'week':
          days = 7;
          break;
        case 'month':
          days = 30;
          break;
        case 'year':
          days = 365;
          break;
        default:
          days = 7;
      }

      final measurements = await widget.service.getMeasurementsByDateRange(
        widget.userId,
        DateTime.now().subtract(Duration(days: days)),
        DateTime.now(),
      );

      if (!mounted) return;

      final Map<String, List<BloodSugarMeasurement>> grouped = {};
      for (final m in measurements) {
        String key;
        if (_selectedPeriod == 'week' || _selectedPeriod == 'month') {
          key =
              '${m.date.year}-${m.date.month.toString().padLeft(2, '0')}-${m.date.day.toString().padLeft(2, '0')}';
        } else {
          key = '${m.date.year}-${m.date.month.toString().padLeft(2, '0')}';
        }

        if (grouped.containsKey(key)) {
          grouped[key]!.add(m);
        } else {
          grouped[key] = [m];
        }
      }

      if (!mounted) return;

      setState(() {
        _groupedMeasurements = grouped;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Container(
          color: const Color(0xFF81C784),
          child: TabBar(
            controller: _historyTabController,
            tabs: [
              Tab(text: l10n.week),
              Tab(text: l10n.month),
              Tab(text: l10n.year),
            ],
          ),
        ),
        Expanded(
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _groupedMeasurements.isEmpty
                  ? Center(child: Text(l10n.noHistoryData))
                  : _buildHistoryList(l10n),
        ),
      ],
    );
  }

  Widget _buildHistoryList(AppLocalizations l10n) {
    final sortedKeys =
        _groupedMeasurements.keys.toList()..sort((a, b) => b.compareTo(a));

    return RefreshIndicator(
      onRefresh: _loadHistoryData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedKeys.length,
        itemBuilder: (context, index) {
          final key = sortedKeys[index];
          final measurements = _groupedMeasurements[key]!;
          return _buildDayCard(key, measurements, l10n);
        },
      ),
    );
  }

  Widget _buildDayCard(
    String dateKey,
    List<BloodSugarMeasurement> measurements,
    AppLocalizations l10n,
  ) {
    DateTime date;
    if (_selectedPeriod == 'year') {
      final parts = dateKey.split('-');
      date = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    } else {
      final parts = dateKey.split('-');
      date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    }

    final avgValue =
        measurements.map((m) => m.valueInMgDl).reduce((a, b) => a + b) ~/
        measurements.length;
    final avgColor = _getAverageCategoryColor(measurements);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: avgColor, width: 2),
      ),
      child: ExpansionTile(
        leading: Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: avgColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(
          _formatDateHeader(date, l10n),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${measurements.length} ${l10n.totalMeasurements.toLowerCase()} - $avgValue mg/dL',
          style: TextStyle(color: avgColor, fontWeight: FontWeight.w500),
        ),
        children:
            measurements.map((m) => _buildMeasurementItem(m, l10n)).toList(),
      ),
    );
  }

  String _formatDateHeader(DateTime date, AppLocalizations l10n) {
    if (_selectedPeriod == 'year') {
      return DateFormat('MMMM yyyy').format(date);
    } else if (_selectedPeriod == 'month') {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final dateOnly = DateTime(date.year, date.month, date.day);

      if (dateOnly == today) return l10n.today;
      if (dateOnly == yesterday) return l10n.yesterday;
      return DateFormat('EEEE, MMM d').format(date);
    }
    return DateFormat('EEEE, MMM d').format(date);
  }

  Color _getCategoryColor(BloodSugarMeasurement measurement) {
    switch (measurement.category) {
      case 'low':
        return Colors.blue;
      case 'normal':
        return Colors.green;
      case 'pre_diabetes':
        return Colors.yellow[700]!;
      case 'diabetes':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getAverageCategoryColor(List<BloodSugarMeasurement> measurements) {
    if (measurements.isEmpty) return Colors.grey;

    bool hasDiabetes = measurements.any((m) => m.category == 'diabetes');
    bool hasPreDiabetes = measurements.any((m) => m.category == 'pre_diabetes');
    bool hasNormal = measurements.any((m) => m.category == 'normal');
    bool hasLow = measurements.any((m) => m.category == 'low');

    if (hasDiabetes) return Colors.red;
    if (hasPreDiabetes) return Colors.yellow[700]!;
    if (hasNormal) return Colors.green;
    if (hasLow) return Colors.blue;
    return Colors.grey;
  }

  Widget _buildMeasurementItem(
    BloodSugarMeasurement measurement,
    AppLocalizations l10n,
  ) {
    final color = _getCategoryColor(measurement);
    return ListTile(
      title: Text(measurement.name),
      subtitle: Text(DateFormat('h:mm a').format(measurement.date)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            measurement.formattedValue,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            _getConditionLabel(measurement.condition, l10n),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  String _getConditionLabel(String condition, AppLocalizations l10n) {
    switch (condition) {
      case 'default_condition':
        return l10n.defaultCondition;
      case 'fasting':
        return l10n.fasting;
      case 'before_meal':
        return l10n.beforeMeal;
      case 'after_meal_1h':
        return l10n.afterMeal1h;
      case 'after_meal_2h':
        return l10n.afterMeal2h;
      case 'sleep':
        return l10n.sleep;
      case 'before_exercise':
        return l10n.beforeExercise;
      case 'after_exercise':
        return l10n.afterExercise;
      default:
        return condition;
    }
  }
}

/// Blood Sugar Settings Tab
class BloodSugarSettingsTab extends StatefulWidget {
  final String userId;
  final BloodSugarService service;
  final bool isArabic;
  final VoidCallback? onSettingsSaved;

  const BloodSugarSettingsTab({
    super.key,
    required this.userId,
    required this.service,
    required this.isArabic,
    this.onSettingsSaved,
  });

  @override
  State<BloodSugarSettingsTab> createState() => _BloodSugarSettingsTabState();
}

class _BloodSugarSettingsTabState extends State<BloodSugarSettingsTab> {
  bool _isLoading = false;
  String? _selectedUnit;
  Map<String, List<SugarRange>>? _userRanges;
  bool _isEditingRanges = false;

  // Date range for export
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    setState(() => _isLoading = true);
    try {
      final settings = await widget.service.getUserSettings(widget.userId);
      if (!mounted) return;
      if (settings != null && settings.isNotEmpty) {
        setState(() {
          _userRanges = settings;
          _isEditingRanges = true;
        });
      }
    } catch (e) {
      // Handle error silently
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveUserRanges() async {
    if (_userRanges == null) return;
    setState(() => _isLoading = true);
    try {
      await widget.service.saveUserSettings(widget.userId, _userRanges!);
      // Update the static user ranges so it takes effect immediately
      SugarRange.userRanges = _userRanges;

      // Notify parent to reload data
      widget.onSettingsSaved?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully')),
        );
        setState(() => _isEditingRanges = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save settings')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showEditRangesDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder:
                (context, scrollController) => _EditRangesSheet(
                  userId: widget.userId,
                  service: widget.service,
                  isArabic: widget.isArabic,
                  userRanges: _userRanges,
                  onSave: (newRanges) {
                    setState(() => _userRanges = newRanges);
                    _saveUserRanges();
                  },
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Target Ranges Section
          _buildSectionTitle(l10n.targetRanges),
          _buildTargetRangesCard(l10n),
          const SizedBox(height: 24),

          // Export Section with Date Range (in Card)
          _buildSectionTitle(l10n.export),
          _buildExportSection(l10n),
        ],
      ),
    );
  }

  Widget _buildExportSection(AppLocalizations l10n) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.file_download, color: const Color(0xFF81C784)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.exportData,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Date Range Selection
            Text(
              '${l10n.startDate} - ${l10n.endDate}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDateButton(
                    l10n.startDate,
                    _startDate,
                    () => _selectDate(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateButton(
                    l10n.endDate,
                    _endDate,
                    () => _selectDate(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Export Buttons - Share
            Text(
              l10n.share,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 8),
            _buildExportButtons(l10n, share: true),
            const SizedBox(height: 16),
            // Export Buttons - Download
            Text(
              l10n.download,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 8),
            _buildExportButtons(l10n, share: false),
            if (_isExporting)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateButton(String label, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                date != null ? DateFormat('MMM d, yyyy').format(date) : label,
                style: TextStyle(
                  color: date != null ? Colors.black : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final initialDate =
        isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Widget _buildExportButtons(AppLocalizations l10n, {required bool share}) {
    final isEnabled =
        _startDate != null && _endDate != null && !_isExporting && !_isLoading;

    return Row(
      children: [
        Expanded(
          child:
              share
                  ? ElevatedButton.icon(
                    onPressed:
                        isEnabled
                            ? () => _exportData('csv', l10n, share: true)
                            : null,
                    icon: const Icon(Icons.table_chart, size: 20),
                    label: Text(
                      '${l10n.share} CSV',
                      style: const TextStyle(fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF81C784),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  )
                  : OutlinedButton.icon(
                    onPressed:
                        isEnabled
                            ? () => _exportData('csv', l10n, share: false)
                            : null,
                    icon: const Icon(Icons.table_chart_outlined, size: 20),
                    label: Text(
                      '${l10n.download} CSV',
                      style: const TextStyle(fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF81C784),
                      side: const BorderSide(color: Color(0xFF81C784)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              share
                  ? ElevatedButton.icon(
                    onPressed:
                        isEnabled
                            ? () => _exportData('html', l10n, share: true)
                            : null,
                    icon: const Icon(Icons.picture_as_pdf, size: 20),
                    label: Text(
                      '${l10n.share} PDF',
                      style: const TextStyle(fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF81C784),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  )
                  : OutlinedButton.icon(
                    onPressed:
                        isEnabled
                            ? () => _exportData('html', l10n, share: false)
                            : null,
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
                    label: Text(
                      '${l10n.download} PDF',
                      style: const TextStyle(fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF81C784),
                      side: const BorderSide(color: Color(0xFF81C784)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTargetRangesCard(AppLocalizations l10n) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tune, color: const Color(0xFF81C784)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.editTargetRanges,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _isEditingRanges
                  ? l10n.customRangesActive
                  : l10n.defaultRangesInfo,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    _isLoading ? null : () => _showEditRangesDialog(context),
                icon: const Icon(Icons.edit),
                label: Text(l10n.editRanges),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF81C784),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            if (_isEditingRanges) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed:
                      _isLoading
                          ? null
                          : () {
                            setState(() {
                              _userRanges = null;
                              _isEditingRanges = false;
                            });
                          },
                  icon: const Icon(Icons.restore),
                  label: Text(l10n.resetToDefault),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUnitSelector(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children:
            SugarUnitOption.options.map((unit) {
              final isSelected = unit.value == _selectedUnit;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedUnit = unit.value);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color(0xFF4CAF50)
                              : Colors.transparent,
                      borderRadius: BorderRadius.horizontal(
                        left:
                            unit == SugarUnitOption.options.first
                                ? const Radius.circular(11)
                                : Radius.zero,
                        right:
                            unit == SugarUnitOption.options.last
                                ? const Radius.circular(11)
                                : Radius.zero,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        unit.labelEn,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildShareButtons(AppLocalizations l10n) {
    return const SizedBox.shrink(); // Share is now integrated in export section
  }

  Future<void> _exportData(
    String format,
    AppLocalizations l10n, {
    bool share = true,
  }) async {
    if (_startDate == null || _endDate == null) return;

    setState(() => _isExporting = true);
    try {
      // Get measurements by date range
      final measurements = await widget.service.getMeasurementsByDateRange(
        widget.userId,
        _startDate!,
        _endDate!,
      );

      if (measurements.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.noHistoryData)));
        }
        setState(() => _isExporting = false);
        return;
      }

      final directory = await getApplicationDocumentsDirectory();

      if (format == 'csv') {
        final csvData = widget.service.exportToCsv(
          measurements,
          isArabic: widget.isArabic,
        );

        final fileName =
            widget.isArabic
                ? 'تقرير_السكر_${DateTime.now().millisecondsSinceEpoch}.csv'
                : 'blood_sugar_report_${DateTime.now().millisecondsSinceEpoch}.csv';
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(csvData);

        if (share) {
          await Share.shareXFiles(
            [XFile(file.path)],
            subject:
                widget.isArabic ? 'تقرير قياس السكر' : 'Blood Sugar Report CSV',
          );
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.exportSuccess)));
          }
        } else {
          // Download to external Downloads folder
          String savePath;
          try {
            final externalDir = Directory('/storage/emulated/0/Download');
            if (await externalDir.exists()) {
              savePath = '${externalDir.path}/$fileName';
            } else {
              final dir = await getApplicationDocumentsDirectory();
              savePath = '${dir.path}/$fileName';
            }
          } catch (e) {
            final dir = await getApplicationDocumentsDirectory();
            savePath = '${dir.path}/$fileName';
          }

          final newFile = File(savePath);
          await newFile.writeAsBytes(csvData);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${l10n.download}: $savePath'),
                duration: const Duration(seconds: 6),
              ),
            );
          }
        }
      } else if (format == 'html') {
        // Generate HTML report
        final htmlContent = await _generateHtmlReport(
          measurements,
          isArabic: widget.isArabic,
          l10n: l10n,
        );
        final htmlBytes = utf8.encode(htmlContent);

        final fileName =
            widget.isArabic
                ? 'تقرير_السكر_${DateTime.now().millisecondsSinceEpoch}.html'
                : 'blood_sugar_report_${DateTime.now().millisecondsSinceEpoch}.html';
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(htmlBytes);

        if (share) {
          await Share.shareXFiles(
            [XFile(file.path)],
            subject:
                widget.isArabic ? 'تقرير قياس السكر' : 'Blood Sugar Report',
          );
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.exportSuccess)));
          }
        } else {
          String savePath;
          try {
            final externalDir = Directory('/storage/emulated/0/Download');
            if (await externalDir.exists()) {
              savePath = '${externalDir.path}/$fileName';
            } else {
              final dir = await getApplicationDocumentsDirectory();
              savePath = '${dir.path}/$fileName';
            }
          } catch (e) {
            final dir = await getApplicationDocumentsDirectory();
            savePath = '${dir.path}/$fileName';
          }

          final newFile = File(savePath);
          await newFile.writeAsBytes(htmlBytes);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${l10n.download}: $savePath'),
                duration: const Duration(seconds: 6),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.exportError)));
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  // Share functionality is now integrated in export section
  // Keeping placeholder to avoid breaking other code that might reference it

  Future<void> _saveFile(
    Uint8List data,
    String fileName,
    String mimeType,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(data);
  }

  Future<void> _shareFile(Uint8List data, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(data);
    await Share.shareXFiles([XFile(file.path)]);
  }

  Future<void> _exportPdf(List<BloodSugarMeasurement> measurements) async {
    final pdfData = await _generatePdf(measurements);
    await _saveFile(pdfData, 'blood_sugar_measurements.pdf', 'application/pdf');
  }

  Future<Uint8List> _generatePdf(
    List<BloodSugarMeasurement> measurements,
  ) async {
    final pdf = pw.Document();

    // Add Arabic font support
    final arabicFont = await rootBundle.load(
      'assets/fonts/NotoNaskhArabic-Regular.ttf',
    );
    final regularFont = pw.Font.ttf(arabicFont);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build:
            (context) => [
              pw.Header(
                level: 0,
                child: pw.Text(
                  widget.isArabic ? 'تقرير قياس السكر' : 'Blood Sugar Report',
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers:
                    widget.isArabic
                        ? [
                          'التاريخ',
                          'الوقت',
                          'القيمة',
                          'الوحدة',
                          'الحالة',
                          'التصنيف',
                        ]
                        : [
                          'Date',
                          'Time',
                          'Value',
                          'Unit',
                          'Condition',
                          'Category',
                        ],
                data:
                    measurements
                        .map(
                          (m) => [
                            DateFormat('MMM d, yyyy').format(m.date),
                            DateFormat('h:mm a').format(m.date),
                            m.formattedValue,
                            m.unit == 'mmoll' ? 'mmol/L' : 'mg/dL',
                            _getConditionLabel(m.condition),
                            _getCategoryLabel(m.category),
                          ],
                        )
                        .toList(),
              ),
            ],
      ),
    );

    return pdf.save();
  }

  String _getConditionLabel(String condition) {
    switch (condition) {
      case 'default':
        return 'Default';
      case 'fasting':
        return 'Fasting';
      case 'before_meal':
        return 'Before a Meal';
      case 'after_meal_1h':
        return 'After a Meal (1h)';
      case 'after_meal_2h':
        return 'After a Meal (2h)';
      case 'sleep':
        return 'Sleep';
      case 'before_exercise':
        return 'Before Exercise';
      case 'after_exercise':
        return 'After Exercise';
      default:
        return condition;
    }
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'low':
        return 'Low';
      case 'normal':
        return 'Normal';
      case 'pre_diabetes':
        return 'Pre-Diabetes';
      case 'diabetes':
        return 'Diabetes';
      default:
        return category;
    }
  }

  /// Generate HTML report for blood sugar measurements
  Future<String> _generateHtmlReport(
    List<BloodSugarMeasurement> measurements, {
    bool isArabic = false,
    AppLocalizations? l10n,
  }) async {
    final direction = isArabic ? 'rtl' : 'ltr';

    // Column headers based on language
    final headers =
        isArabic
            ? [
              'التاريخ',
              'الوقت',
              'الاسم',
              'الوصف',
              'القيمة',
              'الوحدة',
              'الحالة',
              'الفئة',
            ]
            : [
              'Date',
              'Time',
              'Name',
              'Description',
              'Value',
              'Unit',
              'Condition',
              'Category',
            ];

    final title = isArabic ? 'تقرير قياس السكر' : 'Blood Sugar Report';
    final appName = isArabic ? 'MOHTM | مهتم' : 'MOHTM | مهتم';
    final fromLabel = isArabic ? 'من' : 'From';
    final toLabel = isArabic ? 'إلى' : 'To';
    final dateRange =
        '$fromLabel: ${_startDate!.day}/${_startDate!.month}/${_startDate!.year} $toLabel: ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}';

    // Generate table rows
    final rows = StringBuffer();
    for (int i = 0; i < measurements.length; i++) {
      final m = measurements[i];
      final categoryText =
          isArabic
              ? _getCategoryArabic(m.category)
              : _getCategoryEnglish(m.category);
      final conditionText =
          isArabic
              ? _getConditionArabic(m.condition)
              : _getConditionEnglish(m.condition);

      final bgColor = i % 2 == 0 ? '#FFFFFF' : '#F3E5F5';
      rows.writeln('<tr style="background-color: $bgColor;">');
      rows.writeln(
        '<td style="padding: 8px; border: 1px solid #ddd;">${m.date.day}/${m.date.month}/${m.date.year}</td>',
      );
      rows.writeln(
        '<td style="padding: 8px; border: 1px solid #ddd;">${m.date.hour.toString().padLeft(2, '0')}:${m.date.minute.toString().padLeft(2, '0')}</td>',
      );
      rows.writeln(
        '<td style="padding: 8px; border: 1px solid #ddd;">${m.name}</td>',
      );
      rows.writeln(
        '<td style="padding: 8px; border: 1px solid #ddd;">${m.description ?? ''}</td>',
      );
      rows.writeln(
        '<td style="padding: 8px; border: 1px solid #ddd;">${m.formattedValue}</td>',
      );
      rows.writeln(
        '<td style="padding: 8px; border: 1px solid #ddd;">${m.unit == 'mmoll' ? 'mmol/L' : 'mg/dL'}</td>',
      );
      rows.writeln(
        '<td style="padding: 8px; border: 1px solid #ddd;">$conditionText</td>',
      );
      rows.writeln(
        '<td style="padding: 8px; border: 1px solid #ddd;">$categoryText</td>',
      );
      rows.writeln('</tr>');
    }

    // Build header cells
    final headerCells = StringBuffer();
    for (final header in headers) {
      headerCells.writeln(
        '<th style="padding: 10px; background-color: #B68EBE; color: white; border: 1px solid #ddd; text-align: center;">$header</th>',
      );
    }

    // Read image from assets and encode to base64
    String logoIcon = '❤️'; // fallback emoji
    try {
      final ByteData imageData = await rootBundle.load(
        'assets/images/iconremovebg.png',
      );
      final List<int> imageBytes = imageData.buffer.asUint8List();
      final String base64Image = base64Encode(imageBytes);
      logoIcon =
          '<img src="data:image/png;base64,$base64Image" alt="Logo" style="width: 60px; height: 60px; object-fit: contain;">';
    } catch (e) {
      logoIcon = '❤️';
    }

    // Build the complete HTML
    return '''
<!DOCTYPE html>
<html lang="${isArabic ? 'ar' : 'en'}" dir="$direction">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$title</title>
  <style>
    body { font-family: Tahoma, Arial, sans-serif; margin: 20px; }
    .header { text-align: center; margin-bottom: 20px; padding-bottom: 15px; border-bottom: 2px solid #B68EBE; }
    .logo-icon { font-size: 40px; display: block; margin-bottom: 5px; }
    .app-name { font-size: 22px; font-weight: bold; color: #800080; margin-bottom: 5px; }
    .app-tagline { font-size: 14px; color: #666; margin-bottom: 15px; }
    h1 { color: #800080; text-align: center; margin: 10px 0; }
    .date-range { text-align: center; margin-bottom: 20px; font-size: 14px; }
    table { width: 100%; border-collapse: collapse; }
    @media print {
      button { display: none; }
      .no-print { display: none; }
      .header { border-bottom: 1px solid #B68EBE; }
    }
  </style>
</head>
<body>
  <div class="header">
    <span class="logo-icon">$logoIcon</span>
    <div class="app-name">$appName</div>
    <div class="app-tagline">${isArabic ? 'تطبيق العناية بصحتك' : 'Your Health Care App'}</div>
  </div>
  <h1>$title</h1>
  <p class="date-range">$dateRange</p>
  <table>
    <thead>
      <tr>$headerCells</tr>
    </thead>
    <tbody>
      $rows
    </tbody>
  </table>
  <div class="no-print" style="margin-top: 20px; text-align: center;">
    <button onclick="window.print()" style="padding: 10px 20px; background-color: #800080; color: white; border: none; cursor: pointer; border-radius: 5px;">
      ${isArabic ? 'طباعة PDF' : 'Print / Save as PDF'}
    </button>
  </div>
</body>
</html>
''';
  }

  String _getCategoryArabic(String category) {
    switch (category) {
      case 'low':
        return 'منخفض';
      case 'normal':
        return 'طبيعي';
      case 'pre_diabetes':
        return 'ما قبل السكري';
      case 'diabetes':
        return 'سكري';
      default:
        return category;
    }
  }

  String _getCategoryEnglish(String category) {
    switch (category) {
      case 'low':
        return 'Low';
      case 'normal':
        return 'Normal';
      case 'pre_diabetes':
        return 'Pre-Diabetes';
      case 'diabetes':
        return 'Diabetes';
      default:
        return category;
    }
  }

  String _getConditionArabic(String condition) {
    switch (condition) {
      case 'default':
      case 'default_condition':
        return 'افتراضي';
      case 'fasting':
        return 'صائم';
      case 'before_meal':
        return 'قبل الوجبة';
      case 'after_meal_1h':
        return 'بعد الوجبة (ساعة)';
      case 'after_meal_2h':
        return 'بعد الوجبة (ساعتان)';
      case 'sleep':
        return 'النوم';
      case 'before_exercise':
        return 'قبل التمرين';
      case 'after_exercise':
        return 'بعد التمرين';
      default:
        return condition;
    }
  }

  String _getConditionEnglish(String condition) {
    switch (condition) {
      case 'default':
      case 'default_condition':
        return 'Default';
      case 'fasting':
        return 'Fasting';
      case 'before_meal':
        return 'Before Meal';
      case 'after_meal_1h':
        return 'After Meal (1h)';
      case 'after_meal_2h':
        return 'After Meal (2h)';
      case 'sleep':
        return 'Sleep';
      case 'before_exercise':
        return 'Before Exercise';
      case 'after_exercise':
        return 'After Exercise';
      default:
        return condition;
    }
  }
}

/// Edit Ranges Bottom Sheet Widget
class _EditRangesSheet extends StatefulWidget {
  final String userId;
  final BloodSugarService service;
  final bool isArabic;
  final Map<String, List<SugarRange>>? userRanges;
  final Function(Map<String, List<SugarRange>>) onSave;

  const _EditRangesSheet({
    required this.userId,
    required this.service,
    required this.isArabic,
    this.userRanges,
    required this.onSave,
  });

  @override
  State<_EditRangesSheet> createState() => _EditRangesSheetState();
}

class _EditRangesSheetState extends State<_EditRangesSheet> {
  late String _selectedUnit;
  late Map<String, SugarRange> _editedRanges;
  bool _isLoading = false;

  // Controllers for text fields - key format: "condition_field"
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _selectedUnit = 'mgdl';
    _initializeRanges();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeRanges() {
    _editedRanges = {};
    final conditions = [
      'default_condition',
      'fasting',
      'before_meal',
      'after_meal_1h',
      'after_meal_2h',
      'sleep',
      'before_exercise',
      'after_exercise',
    ];

    // Clear old controllers
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();

    for (final condition in conditions) {
      SugarRange range;
      if (widget.userRanges != null &&
          widget.userRanges!.containsKey(_selectedUnit)) {
        final ranges = widget.userRanges![_selectedUnit]!;
        final existingRange =
            ranges.where((r) => r.condition == condition).firstOrNull;
        if (existingRange != null) {
          range = existingRange;
        } else {
          range = SugarRange.getRangesForCondition(condition, _selectedUnit);
        }
      } else {
        range = SugarRange.getRangesForCondition(condition, _selectedUnit);
      }
      _editedRanges[condition] = range;

      // Create controllers for each field
      _controllers['${condition}_lowMax'] = TextEditingController(
        text: range.lowMax.toString(),
      );
      _controllers['${condition}_normalMin'] = TextEditingController(
        text: range.normalMin.toString(),
      );
      _controllers['${condition}_normalMax'] = TextEditingController(
        text: range.normalMax.toString(),
      );
      _controllers['${condition}_preDiabetesMin'] = TextEditingController(
        text: range.preDiabetesMin.toString(),
      );
      _controllers['${condition}_preDiabetesMax'] = TextEditingController(
        text: range.preDiabetesMax.toString(),
      );
      _controllers['${condition}_diabetesMin'] = TextEditingController(
        text: range.diabetesMin.toString(),
      );
    }
  }

  void _updateRangeForCondition(String condition, String field, double value) {
    setState(() {
      final currentRange = _editedRanges[condition]!;
      switch (field) {
        case 'lowMax':
          _editedRanges[condition] = currentRange.copyWith(lowMax: value);
          break;
        case 'normalMin':
          _editedRanges[condition] = currentRange.copyWith(normalMin: value);
          break;
        case 'normalMax':
          _editedRanges[condition] = currentRange.copyWith(normalMax: value);
          break;
        case 'preDiabetesMin':
          _editedRanges[condition] = currentRange.copyWith(
            preDiabetesMin: value,
          );
          break;
        case 'preDiabetesMax':
          _editedRanges[condition] = currentRange.copyWith(
            preDiabetesMax: value,
          );
          break;
        case 'diabetesMin':
          _editedRanges[condition] = currentRange.copyWith(diabetesMin: value);
          break;
      }
    });
  }

  void _onTextChanged(String condition, String field, String text) {
    final parsed = double.tryParse(text);
    if (parsed != null) {
      _updateRangeForCondition(condition, field, parsed);
    }
  }

  Future<void> _saveRanges() async {
    setState(() => _isLoading = true);
    try {
      final rangesList = _editedRanges.values.toList();
      final rangesMap = <String, List<SugarRange>>{_selectedUnit: rangesList};
      await widget.service.saveUserSettings(widget.userId, rangesMap);
      widget.onSave(rangesMap);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to save ranges')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.editTargetRanges,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Unit selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildUnitSelector(l10n),
          ),
          const SizedBox(height: 16),
          // Ranges list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _editedRanges.length,
              itemBuilder: (context, index) {
                final condition = _editedRanges.keys.elementAt(index);
                final range = _editedRanges[condition]!;
                return _buildRangeCard(condition, range, l10n);
              },
            ),
          ),
          // Save button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveRanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF81C784),
                  foregroundColor: Colors.white,
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(l10n.saveRanges),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitSelector(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildUnitOption('mgdl', 'mg/dL'),
          _buildUnitOption('mmoll', 'mmol/L'),
        ],
      ),
    );
  }

  Widget _buildUnitOption(String unit, String label) {
    final isSelected = unit == _selectedUnit;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedUnit = unit;
            _initializeRanges();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
            borderRadius: BorderRadius.horizontal(
              left: unit == 'mgdl' ? const Radius.circular(11) : Radius.zero,
              right: unit == 'mmoll' ? const Radius.circular(11) : Radius.zero,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRangeCard(
    String condition,
    SugarRange range,
    AppLocalizations l10n,
  ) {
    final conditionLabel = _getConditionLabel(condition, l10n);
    final unit = _selectedUnit == 'mgdl' ? 'mg/dL' : 'mmol/L';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              conditionLabel,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Low range: value < lowMax
            _buildRangeRowWithMinMax(
              condition: condition,
              label: l10n.lowBloodSugar,
              minValue: null, // No min for low
              maxValue: range.lowMax,
              color: Colors.blue,
              unit: unit,
              onMinChanged: null, // Low has no min
              onMaxChanged:
                  (value) =>
                      _updateRangeForCondition(condition, 'lowMax', value),
              l10n: l10n,
            ),
            const SizedBox(height: 8),
            // Normal range: value >= normalMin AND < normalMax
            _buildRangeRowWithMinMax(
              condition: condition,
              label: l10n.normalBloodSugar,
              minValue: range.normalMin,
              maxValue: range.normalMax,
              color: Colors.green,
              unit: unit,
              onMinChanged:
                  (value) =>
                      _updateRangeForCondition(condition, 'normalMin', value),
              onMaxChanged:
                  (value) =>
                      _updateRangeForCondition(condition, 'normalMax', value),
              l10n: l10n,
            ),
            const SizedBox(height: 8),
            // Pre-Diabetes range: value >= preDiabetesMin AND < preDiabetesMax
            _buildRangeRowWithMinMax(
              condition: condition,
              label: l10n.preDiabetesBloodSugar,
              minValue: range.preDiabetesMin,
              maxValue: range.preDiabetesMax,
              color: Colors.yellow[700]!,
              unit: unit,
              onMinChanged:
                  (value) => _updateRangeForCondition(
                    condition,
                    'preDiabetesMin',
                    value,
                  ),
              onMaxChanged:
                  (value) => _updateRangeForCondition(
                    condition,
                    'preDiabetesMax',
                    value,
                  ),
              l10n: l10n,
            ),
            const SizedBox(height: 8),
            // Diabetes range: value >= diabetesMin
            _buildRangeRowWithMinMax(
              condition: condition,
              label: l10n.diabetesBloodSugar,
              minValue: range.diabetesMin,
              maxValue: null, // No max for diabetes
              color: Colors.red,
              unit: unit,
              onMinChanged:
                  (value) =>
                      _updateRangeForCondition(condition, 'diabetesMin', value),
              onMaxChanged: null, // Diabetes has no max
              l10n: l10n,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeRowWithMinMax({
    required String condition,
    required String label,
    required double? minValue,
    required double? maxValue,
    required Color color,
    required String unit,
    required Function(double)? onMinChanged,
    required Function(double)? onMaxChanged,
    required AppLocalizations l10n,
  }) {
    // Get the field name based on the context
    String getMinFieldName() {
      if (label == l10n.normalBloodSugar) return 'normalMin';
      if (label == l10n.preDiabetesBloodSugar) return 'preDiabetesMin';
      if (label == l10n.diabetesBloodSugar) return 'diabetesMin';
      return '';
    }

    String getMaxFieldName() {
      if (label == l10n.lowBloodSugar) return 'lowMax';
      if (label == l10n.normalBloodSugar) return 'normalMax';
      if (label == l10n.preDiabetesBloodSugar) return 'preDiabetesMax';
      return '';
    }

    final minFieldName = getMinFieldName();
    final maxFieldName = getMaxFieldName();

    final minController =
        minFieldName.isNotEmpty
            ? _controllers['${condition}_$minFieldName']
            : null;
    final maxController =
        maxFieldName.isNotEmpty
            ? _controllers['${condition}_$maxFieldName']
            : null;

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
        // Min value field (greater than or equal)
        if (minValue != null &&
            onMinChanged != null &&
            minController != null) ...[
          Text(
            '≥',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 60,
            child: TextField(
              controller: minController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 6,
                ),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onChanged: (text) {
                final parsed = double.tryParse(text);
                if (parsed != null) {
                  onMinChanged(parsed);
                }
              },
            ),
          ),
          const SizedBox(width: 4),
        ],
        if (minValue != null && maxValue != null)
          Text(
            l10n.and,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        if (minValue != null && maxValue != null) const SizedBox(width: 4),
        // Max value field (less than)
        if (maxValue != null &&
            onMaxChanged != null &&
            maxController != null) ...[
          Text(
            '<',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 60,
            child: TextField(
              controller: maxController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 6,
                ),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onChanged: (text) {
                final parsed = double.tryParse(text);
                if (parsed != null) {
                  onMaxChanged(parsed);
                }
              },
            ),
          ),
        ],
      ],
    );
  }

  String _getFieldName(double value, String condition) {
    final range = _editedRanges[condition];
    if (range == null) return '';

    if (value == range.lowMax) return 'lowMax';
    if (value == range.normalMin) return 'normalMin';
    if (value == range.normalMax) return 'normalMax';
    if (value == range.preDiabetesMin) return 'preDiabetesMin';
    if (value == range.preDiabetesMax) return 'preDiabetesMax';
    if (value == range.diabetesMin) return 'diabetesMin';
    return '';
  }

  String _getConditionLabel(String condition, AppLocalizations l10n) {
    switch (condition) {
      case 'default_condition':
        return l10n.defaultCondition;
      case 'fasting':
        return l10n.fasting;
      case 'before_meal':
        return l10n.beforeMeal;
      case 'after_meal_1h':
        return l10n.afterMeal1h;
      case 'after_meal_2h':
        return l10n.afterMeal2h;
      case 'sleep':
        return l10n.sleep;
      case 'before_exercise':
        return l10n.beforeExercise;
      case 'after_exercise':
        return l10n.afterExercise;
      default:
        return condition;
    }
  }
}
