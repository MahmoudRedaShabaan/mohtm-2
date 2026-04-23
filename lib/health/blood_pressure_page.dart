import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/health/blood_pressure_model.dart';
import 'package:myapp/health/blood_pressure_service.dart';
import 'package:myapp/health/add_blood_pressure_page.dart';
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
import 'package:myapp/widgets/app_banner_ad.dart';


class BloodPressurePage extends StatefulWidget {
  const BloodPressurePage({super.key});

  @override
  State<BloodPressurePage> createState() => _BloodPressurePageState();
}

class _BloodPressurePageState extends State<BloodPressurePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BloodPressureService _service = BloodPressureService();
  String? _userId;
  bool _isLoading = true;
  List<BloodPressureMeasurement> _todayMeasurements = [];
  BloodPressureStatistics _todayStats = BloodPressureStatistics.empty();
  List<BloodPressureRange>? _customRanges;

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
        final measurements = await _service.getTodayMeasurements(_userId!);
        final stats = await _service.getTodayStatistics(_userId!);
        // Load custom ranges if available
        final customRanges = await _service.getUserSettings(_userId!);
        if (!mounted) return;
        setState(() {
          _todayMeasurements = measurements;
          _todayStats = stats;
          _customRanges = customRanges;
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

  /// Refresh custom ranges (called after saving ranges)
  Future<void> _refreshRanges() async {
    if (_userId == null) return;
    final customRanges = await _service.getUserSettings(_userId!);
    if (!mounted) return;
    setState(() {
      _customRanges = customRanges;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bloodPressure),
        backgroundColor: const Color(0xFFF48FB1),
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
        backgroundColor: const Color(0xFFF48FB1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const AppBannerAd(),
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
            colors: [Color(0xFFF48FB1), Color(0xFFF8BBD0)],
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
                    l10n.dailyBloodPressureStatistics,
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
                  '${_todayStats.averageSystolic.toStringAsFixed(0)}/${_todayStats.averageDiastolic.toStringAsFixed(0)}',
                  l10n.mmHg,
                ),
                _buildStatItem(
                  l10n.totalMeasurements,
                  _todayStats.totalMeasurements.toString(),
                  '',
                ),
                _buildStatItem(
                  l10n.pulse,
                  _todayStats.averagePulse.toStringAsFixed(0),
                  l10n.bpm,
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(color: Colors.white30),
            const SizedBox(height: 12),

            // Category distribution
            Text(
              l10n.category,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            _buildCategoryChips(l10n),
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (unit.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 2, bottom: 2),
                child: Text(
                  unit,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryChips(AppLocalizations l10n) {
    // Calculate category counts using custom ranges if available
    int normalCount = 0;
    int elevatedCount = 0;
    int highStage1Count = 0;
    int highStage2Count = 0;
    int crisisCount = 0;

    for (final m in _todayMeasurements) {
      final category =
          _customRanges != null ? m.getCategory(_customRanges) : m.category;
      switch (category) {
        case 'normal':
          normalCount++;
          break;
        case 'elevated':
          elevatedCount++;
          break;
        case 'high_stage1':
          highStage1Count++;
          break;
        case 'high_stage2':
          highStage2Count++;
          break;
        case 'crisis':
          crisisCount++;
          break;
      }
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (normalCount > 0)
          _buildCategoryChip(l10n.normal, normalCount, Colors.green),
        if (elevatedCount > 0)
          _buildCategoryChip(l10n.elevated, elevatedCount, Colors.blue),
        if (highStage1Count > 0)
          _buildCategoryChip(l10n.highStage1, highStage1Count, Colors.orange),
        if (highStage2Count > 0)
          _buildCategoryChip(l10n.highStage2, highStage2Count, Colors.red),
        if (crisisCount > 0)
          _buildCategoryChip(
            l10n.hypertensiveCrisis,
            crisisCount,
            Colors.purple,
          ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            l10n.noMeasurementsToday,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tapToAddMeasurement,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
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
        return _buildMeasurementCard(
          measurement,
          l10n,
          isArabic,
          customRanges: _customRanges,
        );
      },
    );
  }

  Widget _buildMeasurementCard(
    BloodPressureMeasurement measurement,
    AppLocalizations l10n,
    bool isArabic, {
    List<BloodPressureRange>? customRanges,
  }) {
    Color categoryColor;
    String categoryLabel;

    // Use custom ranges if available, otherwise use default
    final category =
        customRanges != null
            ? measurement.getCategory(customRanges)
            : measurement.category;

    switch (category) {
      case 'normal':
        categoryColor = Colors.green;
        categoryLabel = l10n.normal;
        break;
      case 'elevated':
        categoryColor = Colors.orange;
        categoryLabel = l10n.elevated;
        break;
      case 'high_stage1':
        categoryColor = Colors.deepOrange;
        categoryLabel = l10n.highStage1;
        break;
      case 'high_stage2':
        categoryColor = Colors.red;
        categoryLabel = l10n.highStage2;
        break;
      case 'crisis':
        categoryColor = Colors.purple;
        categoryLabel = l10n.hypertensiveCrisis;
        break;
      default:
        categoryColor = Colors.grey;
        categoryLabel = '';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showMeasurementDetails(measurement, l10n),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Blood Pressure Value
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '${measurement.systolic}/${measurement.diastolic}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                      ),
                    ),
                    Text(
                      l10n.mmHg,
                      style: TextStyle(fontSize: 10, color: categoryColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            measurement.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            categoryLabel,
                            style: TextStyle(
                              color: categoryColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      measurement.pulse != null
                          ? '${l10n.pulse}: ${measurement.pulse} ${l10n.bpm}'
                          : '${l10n.pulse}: -',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    Text(
                      _formatTime(measurement.date, isArabic),
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),

              // Actions
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _navigateToEditMeasurement(measurement);
                  } else if (value == 'delete') {
                    _confirmDelete(measurement, l10n);
                  }
                },
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit, size: 20),
                            const SizedBox(width: 8),
                            Text(l10n.update),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete,
                              size: 20,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.delete,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime date, bool isArabic) {
    final format = isArabic ? 'h:mm a' : 'h:mm a';
    return DateFormat(format).format(date);
  }

  Widget _buildHistoryTab(AppLocalizations l10n, bool isArabic) {
    return BloodPressureHistoryTab(
      userId: _userId!,
      service: _service,
      customRanges: _customRanges,
    );
  }

  Widget _buildSettingsTab(AppLocalizations l10n, bool isArabic) {
    return BloodPressureSettingsTab(
      userId: _userId!,
      service: _service,
      onRangesSaved: _refreshRanges,
      customRanges: _customRanges,
    );
  }

  void _navigateToAddMeasurement(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBloodPressurePage(userId: _userId!),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }

  void _navigateToEditMeasurement(BloodPressureMeasurement measurement) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddBloodPressurePage(
              userId: _userId!,
              measurement: measurement,
            ),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }

  void _showMeasurementDetails(
    BloodPressureMeasurement measurement,
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
    BloodPressureMeasurement measurement,
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
          Text(
            l10n.measurementDetails,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildDetailRow(
            l10n.systolic,
            '${measurement.systolic} ${l10n.mmHg}',
          ),
          _buildDetailRow(
            l10n.diastolic,
            '${measurement.diastolic} ${l10n.mmHg}',
          ),
          if (measurement.pulse != null)
            _buildDetailRow(l10n.pulse, '${measurement.pulse} ${l10n.bpm}'),
          _buildDetailRow(l10n.arm, _getArmLabel(measurement.arm, l10n)),
          _buildDetailRow(
            l10n.position,
            _getPositionLabel(measurement.position, l10n),
          ),
          _buildDetailRow(
            l10n.condition,
            _getConditionLabel(measurement.condition, l10n),
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

  String _getArmLabel(String arm, AppLocalizations l10n) {
    switch (arm) {
      case 'left':
        return l10n.leftArm;
      case 'right':
        return l10n.rightArm;
      default:
        return arm;
    }
  }

  String _getPositionLabel(String position, AppLocalizations l10n) {
    switch (position) {
      case 'sitting':
        return l10n.sitting;
      case 'standing':
        return l10n.standing;
      case 'lying':
        return l10n.lyingDown;
      default:
        return position;
    }
  }

  String _getConditionLabel(String condition, AppLocalizations l10n) {
    switch (condition) {
      case 'resting':
        return l10n.atRest;
      case 'after_exercise':
        return l10n.afterExercise;
      case 'after_meal':
        return l10n.afterMeal;
      case 'stressed':
        return l10n.stressed;
      default:
        return condition;
    }
  }

  void _confirmDelete(
    BloodPressureMeasurement measurement,
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
}

/// History Tab Widget
class BloodPressureHistoryTab extends StatefulWidget {
  final String userId;
  final BloodPressureService service;
  final List<BloodPressureRange>? customRanges;

  const BloodPressureHistoryTab({
    super.key,
    required this.userId,
    required this.service,
    this.customRanges,
  });

  @override
  State<BloodPressureHistoryTab> createState() =>
      _BloodPressureHistoryTabState();
}

class _BloodPressureHistoryTabState extends State<BloodPressureHistoryTab>
    with SingleTickerProviderStateMixin {
  late TabController _historyTabController;
  bool _isLoading = true;
  Map<String, List<BloodPressureMeasurement>> _groupedMeasurements = {};
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
    if (!_historyTabController.indexIsChanging && mounted) {
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

      final Map<String, List<BloodPressureMeasurement>> grouped = {};
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
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Container(
          color: const Color(0xFFF48FB1),
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
    List<BloodPressureMeasurement> measurements,
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

    final avgSystolic =
        measurements.map((m) => m.systolic).reduce((a, b) => a + b) ~/
        measurements.length;
    final avgDiastolic =
        measurements.map((m) => m.diastolic).reduce((a, b) => a + b) ~/
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
          '${measurements.length} ${l10n.totalMeasurements.toLowerCase()} - $avgSystolic/$avgDiastolic ${l10n.mmHg}',
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

  /// Get color based on blood pressure category
  Color _getCategoryColor(BloodPressureMeasurement measurement) {
    switch (measurement.category) {
      case 'normal':
        return Colors.green;
      case 'elevated':
        return Colors.orange;
      case 'high_stage1':
        return Colors.deepOrange;
      case 'high_stage2':
        return Colors.red;
      case 'crisis':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  /// Get average category color from a list of measurements
  /// Uses custom ranges if available
  Color _getAverageCategoryColor(List<BloodPressureMeasurement> measurements) {
    if (measurements.isEmpty) return Colors.grey;

    // Use custom ranges if available
    final customRanges = widget.customRanges;

    // Find the highest severity category using custom ranges
    bool hasCrisis = measurements.any(
      (m) => m.getCategory(customRanges) == 'crisis',
    );
    bool hasHighStage2 = measurements.any(
      (m) => m.getCategory(customRanges) == 'high_stage2',
    );
    bool hasHighStage1 = measurements.any(
      (m) => m.getCategory(customRanges) == 'high_stage1',
    );
    bool hasElevated = measurements.any(
      (m) => m.getCategory(customRanges) == 'elevated',
    );

    if (hasCrisis) return Colors.purple;
    if (hasHighStage2) return Colors.red;
    if (hasHighStage1) return Colors.orange;
    if (hasElevated) return Colors.blue;
    return Colors.green;
  }

  Widget _buildMeasurementItem(
    BloodPressureMeasurement measurement,
    AppLocalizations l10n,
  ) {
    // Use custom ranges if available
    final category =
        widget.customRanges != null
            ? measurement.getCategory(widget.customRanges)
            : measurement.category;
    final categoryColor = _getColorForCategory(category);

    return ListTile(
      leading: Container(
        width: 4,
        height: 40,
        decoration: BoxDecoration(
          color: categoryColor,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      title: Text(
        '${measurement.systolic}/${measurement.diastolic} ${l10n.mmHg}',
        style: TextStyle(color: categoryColor, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        measurement.pulse != null
            ? '${measurement.pulse} ${l10n.bpm} - ${measurement.name}'
            : measurement.name,
      ),
    );
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'normal':
        return Colors.green;
      case 'elevated':
        return Colors.blue;
      case 'high_stage1':
        return Colors.orange;
      case 'high_stage2':
        return Colors.red;
      case 'crisis':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

/// Settings Tab Widget
class BloodPressureSettingsTab extends StatefulWidget {
  final String userId;
  final BloodPressureService service;
  final VoidCallback? onRangesSaved;
  final List<BloodPressureRange>? customRanges;

  const BloodPressureSettingsTab({
    super.key,
    required this.userId,
    required this.service,
    this.onRangesSaved,
    this.customRanges,
  });

  @override
  State<BloodPressureSettingsTab> createState() =>
      _BloodPressureSettingsTabState();
}

class _BloodPressureSettingsTabState extends State<BloodPressureSettingsTab> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isExporting = false;

  List<BloodPressureRange>? get customRanges => widget.customRanges;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Export Section
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.file_download, color: Color(0xFFF48FB1)),
                      const SizedBox(width: 12),
                      Text(
                        l10n.exportData,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
                          () => _selectDate(true, isArabic),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateButton(
                          l10n.endDate,
                          _endDate,
                          () => _selectDate(false, isArabic),
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
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              _startDate != null &&
                                      _endDate != null &&
                                      !_isExporting
                                  ? () => _exportData('csv', l10n, share: true)
                                  : null,
                          icon: const Icon(Icons.table_chart, size: 20),
                          label: Text(
                            '${l10n.share} CSV',
                            style: const TextStyle(fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF48FB1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              _startDate != null &&
                                      _endDate != null &&
                                      !_isExporting
                                  ? () => _exportData('pdf', l10n, share: true)
                                  : null,
                          icon: const Icon(Icons.picture_as_pdf, size: 20),
                          label: Text(
                            '${l10n.share} PDF',
                            style: const TextStyle(fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF48FB1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Export Buttons - Download
                  Text(
                    l10n.download,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                              _startDate != null &&
                                      _endDate != null &&
                                      !_isExporting
                                  ? () => _exportData('csv', l10n, share: false)
                                  : null,
                          icon: const Icon(
                            Icons.table_chart_outlined,
                            size: 20,
                          ),
                          label: Text(
                            '${l10n.download} CSV',
                            style: const TextStyle(fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFF48FB1),
                            side: const BorderSide(color: Color(0xFFF48FB1)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                              _startDate != null &&
                                      _endDate != null &&
                                      !_isExporting
                                  ? () => _exportData('pdf', l10n, share: false)
                                  : null,
                          icon: const Icon(
                            Icons.picture_as_pdf_outlined,
                            size: 20,
                          ),
                          label: Text(
                            '${l10n.download} PDF',
                            style: const TextStyle(fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFF48FB1),
                            side: const BorderSide(color: Color(0xFFF48FB1)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (_isExporting)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Blood Pressure Ranges Edit Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tune, color: Color(0xFFF48FB1)),
                      const SizedBox(width: 12),
                      Text(
                        l10n.bloodPressureRanges,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.rangesSettingsNote,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 16),

                  // Range info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.defaultRangesInfo,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Edit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          () => _showEditRangesDialog(context, l10n, isArabic),
                      icon: const Icon(Icons.edit, size: 20),
                      label: Text(l10n.editBloodPressureRanges),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF48FB1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditRangesDialog(
    BuildContext context,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => BloodPressureRangesDialog(
            userId: widget.userId,
            service: widget.service,
            l10n: l10n,
            isArabic: isArabic,
            onSaved: widget.onRangesSaved,
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

  Future<void> _selectDate(bool isStart, bool isArabic) async {
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

  Future<void> _exportData(
    String format,
    AppLocalizations l10n, {
    bool share = true,
  }) async {
    if (_startDate == null || _endDate == null) return;

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    setState(() => _isExporting = true);

    try {
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
        final csv = widget.service.exportToCsv(
          measurements,
          isArabic: isArabic,
          customRanges: widget.customRanges,
        );

        final fileName =
            isArabic
                ? 'تقرير_ضغط_الدم_${DateTime.now().millisecondsSinceEpoch}.csv'
                : 'blood_pressure_report_${DateTime.now().millisecondsSinceEpoch}.csv';
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(csv);

        if (share) {
          await Share.shareXFiles(
            [XFile(file.path)],
            subject: isArabic ? 'تقرير ضغط الدم' : 'Blood Pressure Report CSV',
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
              // Fallback to app documents directory
              final dir = await getApplicationDocumentsDirectory();
              savePath = '${dir.path}/$fileName';
            }
          } catch (e) {
            // Fallback
            final dir = await getApplicationDocumentsDirectory();
            savePath = '${dir.path}/$fileName';
          }

          final newFile = File(savePath);
          await newFile.writeAsBytes(csv);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${l10n.download}: $savePath'),
                duration: const Duration(seconds: 6),
              ),
            );
          }
        }
      } else if (format == 'pdf') {
        // Generate HTML report instead of PDF for better Arabic support
        final htmlContent = await _generateHtmlReport(
          measurements,
          isArabic: isArabic,
          l10n: l10n,
          customRanges: widget.customRanges,
        );
        final fileName =
            isArabic
                ? 'تقرير_ضغط_الدم_${DateTime.now().millisecondsSinceEpoch}.html'
                : 'blood_pressure_report_${DateTime.now().millisecondsSinceEpoch}.html';

        String savePath;
        try {
          final externalDir = Directory('/storage/emulated/0/Download');
          if (!await externalDir.exists()) {
            final dir = await getApplicationDocumentsDirectory();
            savePath = '${dir.path}/$fileName';
          } else {
            savePath = '${externalDir.path}/$fileName';
          }
        } catch (e) {
          final dir = await getApplicationDocumentsDirectory();
          savePath = '${dir.path}/$fileName';
        }

        final file = File(savePath);
        await file.writeAsString(htmlContent);

        if (share) {
          await Share.shareXFiles([
            XFile(file.path),
          ], subject: isArabic ? 'تقرير ضغط الدم' : 'Blood Pressure Report');
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.exportSuccess)));
          }
        } else {
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

  Future<Uint8List> _generatePdfReport(
    List<BloodPressureMeasurement> measurements, {
    bool isArabic = false,
    AppLocalizations? l10n,
  }) async {
    // Ensure Arabic fonts are loaded before generating PDF
    if (isArabic) {
      await ArabicFontHelper.ensureLoaded();
    }

    // Use printing package
    final doc = pw.Document();

    // Get Arabic fonts if available
    final arabicFont = ArabicFontHelper.regular;
    final arabicBoldFont = ArabicFontHelper.bold;

    // Column headers based on language
    final headers =
        isArabic
            ? [
              'التاريخ',
              'الوقت',
              'الاسم',
              'الوصف',
              'الانقباضي',
              'الانبساضي',
              'النبض',
              'الذراع',
              'الموقع',
              'الحالة',
              'الفئة',
            ]
            : [
              'Date',
              'Time',
              'Name',
              'Description',
              'Systolic',
              'Diastolic',
              'Pulse',
              'Arm',
              'Position',
              'Condition',
              'Category',
            ];

    final title = isArabic ? 'تقرير ضغط الدم' : 'Blood Pressure Report';
    final fromLabel = isArabic ? 'من' : 'From';
    final toLabel = isArabic ? 'إلى' : 'To';
    final dateRange =
        '$fromLabel: ${_startDate!.day}/${_startDate!.month}/${_startDate!.year} $toLabel: ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}';

    // Helper function to get text style
    pw.TextStyle getTextStyle({
      double? fontSize,
      pw.FontWeight? fontWeight,
      PdfColor? color,
    }) {
      return pw.TextStyle(
        fontSize: fontSize ?? 10,
        fontWeight: fontWeight,
        color: color,
        font: isArabic && arabicFont != null ? arabicFont : null,
        fontBold: isArabic && arabicBoldFont != null ? arabicBoldFont : null,
      );
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build:
            (context) => [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      title,
                      style: getTextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.purple,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(dateRange, style: getTextStyle(fontSize: 12)),
                    pw.SizedBox(height: 16),
                  ],
                ),
              ),
              pw.TableHelper.fromTextArray(
                context: context,
                headerStyle: getTextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  fontSize: 10,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFB68EBE),
                ),
                cellStyle: getTextStyle(fontSize: 9),
                cellPadding: const pw.EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 6,
                ),
                cellAlignment:
                    isArabic
                        ? pw.Alignment.centerRight
                        : pw.Alignment.centerLeft,
                headerAlignment:
                    isArabic
                        ? pw.Alignment.centerRight
                        : pw.Alignment.centerLeft,
                headers: headers,
                data:
                    measurements.map((m) {
                      final category =
                          customRanges != null
                              ? m.getCategory(customRanges)
                              : m.category;
                      final categoryText =
                          isArabic
                              ? _getCategoryArabic(category)
                              : _getCategoryEnglish(category);
                      final armText =
                          isArabic
                              ? (m.arm == 'left' ? 'يسار' : 'يمين')
                              : (m.arm == 'left' ? 'Left' : 'Right');
                      final positionText =
                          isArabic
                              ? _getPositionArabic(m.position)
                              : _getPositionEnglish(m.position);
                      final conditionText =
                          isArabic
                              ? _getConditionArabic(m.condition)
                              : _getConditionEnglish(m.condition);
                      return [
                        '${m.date.day}/${m.date.month}/${m.date.year}',
                        '${m.date.hour.toString().padLeft(2, '0')}:${m.date.minute.toString().padLeft(2, '0')}',
                        m.name,
                        m.description ?? '',
                        m.systolic.toString(),
                        m.diastolic.toString(),
                        m.pulse?.toString() ?? '-',
                        armText,
                        positionText,
                        conditionText,
                        categoryText,
                      ];
                    }).toList(),
              ),
            ],
      ),
    );

    return doc.save();
  }

  /// Generate HTML report for blood pressure measurements
  /// Accepts optional custom ranges to calculate category
  Future<String> _generateHtmlReport(
    List<BloodPressureMeasurement> measurements, {
    bool isArabic = false,
    AppLocalizations? l10n,
    List<BloodPressureRange>? customRanges,
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
              'الانقباضي',
              'الانبساضي',
              'النبض',
              'الذراع',
              'الموقع',
              'الحالة',
              'الفئة',
            ]
            : [
              'Date',
              'Time',
              'Name',
              'Description',
              'Systolic',
              'Diastolic',
              'Pulse',
              'Arm',
              'Position',
              'Condition',
              'Category',
            ];

    final title = isArabic ? 'تقرير ضغط الدم' : 'Blood Pressure Report';
    final appName = isArabic ? 'MOHTM | مهتم' : 'MOHTM | مهتم';
    final fromLabel = isArabic ? 'من' : 'From';
    final toLabel = isArabic ? 'إلى' : 'To';
    final dateRange =
        '$fromLabel: ${_startDate!.day}/${_startDate!.month}/${_startDate!.year} $toLabel: ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}';

    // Generate table rows
    final rows = StringBuffer();
    for (int i = 0; i < measurements.length; i++) {
      final m = measurements[i];
      final category =
          customRanges != null ? m.getCategory(customRanges) : m.category;
      final categoryText =
          isArabic
              ? _getCategoryArabic(category)
              : _getCategoryEnglish(category);
      final armText =
          isArabic
              ? (m.arm == 'left' ? 'يسار' : 'يمين')
              : (m.arm == 'left' ? 'Left' : 'Right');
      final positionText =
          isArabic
              ? _getPositionArabic(m.position)
              : _getPositionEnglish(m.position);
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
        '<td style="padding: 8px; border: 1px solid #ddd;">${m.systolic}</td>',
      );
      rows.writeln(
        '<td style="padding: 8px; border: 1px solid #ddd;">${m.diastolic}</td>',
      );
      rows.writeln(
        '<td style="padding: 8px; border: 1px solid #ddd;">${m.pulse?.toString() ?? '-'}</td>',
      );
      rows.writeln(
        '<td style="padding: 8px; border: 1px solid #ddd;">$armText</td>',
      );
      rows.writeln(
        '<td style="padding: 8px; border: 1px solid #ddd;">$positionText</td>',
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
      // Use emoji as fallback if image fails to load
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
      case 'normal':
        return 'طبيعي';
      case 'elevated':
        return 'مرتفع';
      case 'high_stage1':
        return 'مرتفع المرحلة الأولى';
      case 'high_stage2':
        return 'مرتفع المرحلة الثانية';
      case 'crisis':
        return 'أزمة';
      default:
        return category;
    }
  }

  String _getCategoryEnglish(String category) {
    switch (category) {
      case 'normal':
        return 'Normal';
      case 'elevated':
        return 'Elevated';
      case 'high_stage1':
        return 'High (Stage 1)';
      case 'high_stage2':
        return 'High (Stage 2)';
      case 'crisis':
        return 'Crisis';
      default:
        return category;
    }
  }

  // Duplicate removed - the next methods are at lines 1404 onwards
  String _getPositionArabic(String position) {
    switch (position) {
      case 'sitting':
        return 'جلوس';
      case 'standing':
        return 'وقوف';
      case 'lying':
        return 'استلقاء';
      default:
        return position;
    }
  }

  String _getConditionArabic(String condition) {
    switch (condition) {
      case 'resting':
      case 'at_rest':
        return 'في الراحة';
      case 'after_exercise':
        return 'بعد التمرين';
      case 'after_meal':
        return 'بعد الأكل';
      case 'stressed':
        return 'متوتر';
      default:
        return condition;
    }
  }

  String _getPositionEnglish(String position) {
    switch (position) {
      case 'sitting':
        return 'Sitting';
      case 'standing':
        return 'Standing';
      case 'lying':
        return 'Lying';
      default:
        return position;
    }
  }

  String _getConditionEnglish(String condition) {
    switch (condition) {
      case 'resting':
      case 'at_rest':
        return 'At Rest';
      case 'after_exercise':
        return 'After Exercise';
      case 'after_meal':
        return 'After Meal';
      case 'stressed':
        return 'Stressed';
      default:
        return condition;
    }
  }
}

/// Blood Pressure Ranges Edit Dialog
class BloodPressureRangesDialog extends StatefulWidget {
  final String userId;
  final BloodPressureService service;
  final AppLocalizations l10n;
  final bool isArabic;
  final VoidCallback? onSaved;

  const BloodPressureRangesDialog({
    super.key,
    required this.userId,
    required this.service,
    required this.l10n,
    required this.isArabic,
    this.onSaved,
  });

  @override
  State<BloodPressureRangesDialog> createState() =>
      _BloodPressureRangesDialogState();
}

class _BloodPressureRangesDialogState extends State<BloodPressureRangesDialog> {
  late List<BloodPressureRange> _ranges;
  bool _isLoading = true;
  bool _isSaving = false;

  // Controllers for each range field
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _ranges = List.from(BloodPressureRange.defaultRanges);
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    final userRanges = await widget.service.getUserSettings(widget.userId);
    if (userRanges != null && userRanges.isNotEmpty) {
      setState(() {
        _ranges = userRanges;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }

    // Initialize controllers
    for (var range in _ranges) {
      _controllers['${range.category}_systolicMin'] = TextEditingController(
        text: range.systolicMin.toString(),
      );
      _controllers['${range.category}_systolicMax'] = TextEditingController(
        text: range.systolicMax == 999 ? '' : range.systolicMax.toString(),
      );
      _controllers['${range.category}_diastolicMin'] = TextEditingController(
        text: range.diastolicMin.toString(),
      );
      _controllers['${range.category}_diastolicMax'] = TextEditingController(
        text: range.diastolicMax == 999 ? '' : range.diastolicMax.toString(),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'normal':
        return widget.l10n.normalBP;
      case 'elevated':
        return widget.l10n.elevatedBP;
      case 'high_stage1':
        return widget.l10n.highStage1BP;
      case 'high_stage2':
        return widget.l10n.highStage2BP;
      case 'crisis':
        return widget.l10n.crisisBP;
      default:
        return category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'normal':
        return Colors.green;
      case 'elevated':
        return Colors.blue;
      case 'high_stage1':
        return Colors.orange;
      case 'high_stage2':
        return Colors.red;
      case 'crisis':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);

    try {
      // Update ranges from controllers
      final updatedRanges = <BloodPressureRange>[];
      for (var range in _ranges) {
        final systolicMin =
            int.tryParse(
              _controllers['${range.category}_systolicMin']?.text ?? '0',
            ) ??
            0;
        final systolicMaxText =
            _controllers['${range.category}_systolicMax']?.text ?? '';
        final systolicMax =
            systolicMaxText.isEmpty
                ? 999
                : (int.tryParse(systolicMaxText) ?? 999);
        final diastolicMin =
            int.tryParse(
              _controllers['${range.category}_diastolicMin']?.text ?? '0',
            ) ??
            0;
        final diastolicMaxText =
            _controllers['${range.category}_diastolicMax']?.text ?? '';
        final diastolicMax =
            diastolicMaxText.isEmpty
                ? 999
                : (int.tryParse(diastolicMaxText) ?? 999);

        updatedRanges.add(
          BloodPressureRange(
            category: range.category,
            systolicMin: systolicMin,
            systolicMax: systolicMax,
            diastolicMin: diastolicMin,
            diastolicMax: diastolicMax,
            color: range.color,
          ),
        );
      }

      await widget.service.saveUserSettings(widget.userId, updatedRanges);

      if (mounted) {
        // Call the onSaved callback if provided
        widget.onSaved?.call();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(widget.l10n.rangesSaved)));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _resetToDefault() async {
    setState(() {
      _ranges = List.from(BloodPressureRange.defaultRanges);
      _controllers.clear();
      for (var range in _ranges) {
        _controllers['${range.category}_systolicMin'] = TextEditingController(
          text: range.systolicMin.toString(),
        );
        _controllers['${range.category}_systolicMax'] = TextEditingController(
          text: range.systolicMax == 999 ? '' : range.systolicMax.toString(),
        );
        _controllers['${range.category}_diastolicMin'] = TextEditingController(
          text: range.diastolicMin.toString(),
        );
        _controllers['${range.category}_diastolicMax'] = TextEditingController(
          text: range.diastolicMax == 999 ? '' : range.diastolicMax.toString(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tune, color: Color(0xFFF48FB1)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.l10n.editBloodPressureRanges,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _ranges.length,
                  itemBuilder: (context, index) {
                    final range = _ranges[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(range.category),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _getCategoryLabel(range.category),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _getCategoryColor(range.category),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Systolic Row
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller:
                                        _controllers['${range.category}_systolicMin'],
                                    decoration: InputDecoration(
                                      labelText: widget.l10n.systolicMin,
                                      isDense: true,
                                      border: const OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text('-'),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller:
                                        _controllers['${range.category}_systolicMax'],
                                    decoration: InputDecoration(
                                      labelText: widget.l10n.systolicMax,
                                      isDense: true,
                                      border: const OutlineInputBorder(),
                                      hintText: '∞',
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Diastolic Row
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller:
                                        _controllers['${range.category}_diastolicMin'],
                                    decoration: InputDecoration(
                                      labelText: widget.l10n.diastolicMin,
                                      isDense: true,
                                      border: const OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text('-'),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller:
                                        _controllers['${range.category}_diastolicMax'],
                                    decoration: InputDecoration(
                                      labelText: widget.l10n.diastolicMax,
                                      isDense: true,
                                      border: const OutlineInputBorder(),
                                      hintText: '∞',
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 16),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetToDefault,
                    child: Text(widget.l10n.resetToDefault),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF48FB1),
                      foregroundColor: Colors.white,
                    ),
                    child:
                        _isSaving
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : Text(widget.l10n.saveRanges),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
