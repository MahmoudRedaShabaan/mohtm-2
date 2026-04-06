import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'blood_sugar_model.dart';

class BloodSugarService {
  static const String _collectionName = 'blood_sugar_measurements';
  static const String _settingsCollectionName = 'blood_sugar_settings';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add a new blood sugar measurement
  Future<String> addMeasurement(BloodSugarMeasurement measurement) async {
    try {
      print('Adding blood sugar measurement for user: ${measurement.userId}');
      print('Measurement data: ${measurement.toMap()}');
      final docRef = await _firestore
          .collection(_collectionName)
          .add(measurement.toMap());
      print('Measurement added with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error adding measurement: $e');
      throw Exception('Failed to add measurement: $e');
    }
  }

  /// Update an existing blood sugar measurement
  Future<void> updateMeasurement(BloodSugarMeasurement measurement) async {
    if (measurement.id == null) {
      throw Exception('Measurement ID is required for update');
    }
    try {
      await _firestore
          .collection(_collectionName)
          .doc(measurement.id)
          .update(measurement.copyWith(updatedAt: DateTime.now()).toMap());
    } catch (e) {
      throw Exception('Failed to update measurement: $e');
    }
  }

  /// Delete a blood sugar measurement
  Future<void> deleteMeasurement(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete measurement: $e');
    }
  }

  /// Get all measurements for a user
  Future<List<BloodSugarMeasurement>> getAllMeasurements(String userId) async {
    try {
      print('Fetching blood sugar measurements for userId: $userId');
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      print('Found ${querySnapshot.docs.length} documents');

      return querySnapshot.docs
          .map((doc) => BloodSugarMeasurement.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting measurements: $e');
      throw Exception('Failed to get measurements: $e');
    }
  }

  /// Get measurements for a specific date
  Future<List<BloodSugarMeasurement>> getMeasurementsByDate(
    String userId,
    DateTime date,
  ) async {
    try {
      final allMeasurements = await getAllMeasurements(userId);
      
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      return allMeasurements.where((m) {
        return m.date.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
               m.date.isBefore(endOfDay);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get measurements by date: $e');
    }
  }

  /// Get measurements for a date range
  Future<List<BloodSugarMeasurement>> getMeasurementsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final allMeasurements = await getAllMeasurements(userId);
      
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day).add(const Duration(days: 1));
      
      return allMeasurements.where((m) {
        return m.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
               m.date.isBefore(end);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get measurements by date range: $e');
    }
  }

  /// Get measurements for the last 7 days (week)
  Future<List<BloodSugarMeasurement>> getWeeklyMeasurements(String userId) async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return getMeasurementsByDateRange(userId, weekAgo, now);
  }

  /// Get measurements for the last 30 days (month)
  Future<List<BloodSugarMeasurement>> getMonthlyMeasurements(String userId) async {
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));
    return getMeasurementsByDateRange(userId, monthAgo, now);
  }

  /// Get measurements for the last 365 days (year)
  Future<List<BloodSugarMeasurement>> getYearlyMeasurements(String userId) async {
    final now = DateTime.now();
    final yearAgo = now.subtract(const Duration(days: 365));
    return getMeasurementsByDateRange(userId, yearAgo, now);
  }

  /// Get today's measurements
  Future<List<BloodSugarMeasurement>> getTodayMeasurements(String userId) async {
    return getMeasurementsByDate(userId, DateTime.now());
  }

  /// Get statistics for today's measurements
  Future<BloodSugarStatistics> getTodayStatistics(String userId) async {
    final measurements = await getTodayMeasurements(userId);
    return BloodSugarStatistics.fromMeasurements(measurements);
  }

  /// Get statistics for a specific period
  Future<BloodSugarStatistics> getStatistics(String userId, String period) async {
    List<BloodSugarMeasurement> measurements;
    
    switch (period) {
      case 'week':
        measurements = await getWeeklyMeasurements(userId);
        break;
      case 'month':
        measurements = await getMonthlyMeasurements(userId);
        break;
      case 'year':
        measurements = await getYearlyMeasurements(userId);
        break;
      default:
        measurements = await getAllMeasurements(userId);
    }
    
    return BloodSugarStatistics.fromMeasurements(measurements);
  }

  /// Get measurements grouped by day (for week view)
  Future<Map<DateTime, List<BloodSugarMeasurement>>> getMeasurementsGroupedByDay(
    String userId,
    int days,
  ) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    final measurements = await getMeasurementsByDateRange(userId, startDate, now);

    final Map<DateTime, List<BloodSugarMeasurement>> grouped = {};
    for (final m in measurements) {
      final dateKey = DateTime(m.date.year, m.date.month, m.date.day);
      if (grouped.containsKey(dateKey)) {
        grouped[dateKey]!.add(m);
      } else {
        grouped[dateKey] = [m];
      }
    }

    return grouped;
  }

  /// Get measurements grouped by week (for month view)
  Future<Map<int, List<BloodSugarMeasurement>>> getMeasurementsGroupedByWeek(
    String userId,
    int days,
  ) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    final measurements = await getMeasurementsByDateRange(userId, startDate, now);

    final Map<int, List<BloodSugarMeasurement>> grouped = {};
    for (final m in measurements) {
      final weekNumber = _getWeekNumber(m.date);
      if (grouped.containsKey(weekNumber)) {
        grouped[weekNumber]!.add(m);
      } else {
        grouped[weekNumber] = [m];
      }
    }

    return grouped;
  }

  /// Get measurements grouped by month (for year view)
  Future<Map<String, List<BloodSugarMeasurement>>> getMeasurementsGroupedByMonth(
    String userId,
    int days,
  ) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    final measurements = await getMeasurementsByDateRange(userId, startDate, now);

    final Map<String, List<BloodSugarMeasurement>> grouped = {};
    for (final m in measurements) {
      final monthKey = '${m.date.year}-${m.date.month.toString().padLeft(2, '0')}';
      if (grouped.containsKey(monthKey)) {
        grouped[monthKey]!.add(m);
      } else {
        grouped[monthKey] = [m];
      }
    }

    return grouped;
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return ((daysSinceFirstDay + firstDayOfYear.weekday - 1) / 7).ceil();
  }

  /// Save user blood sugar settings (custom ranges)
  Future<void> saveUserSettings(String userId, Map<String, List<SugarRange>> ranges) async {
    try {
      final settingsData = <String, dynamic>{
        'userId': userId,
        'ranges': ranges.map((key, value) => MapEntry(key, value.map((r) => r.toMap()).toList())),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      // Check if settings exist
      final existing = await _firestore
          .collection(_settingsCollectionName)
          .where('userId', isEqualTo: userId)
          .get();
      
      if (existing.docs.isNotEmpty) {
        await _firestore
            .collection(_settingsCollectionName)
            .doc(existing.docs.first.id)
            .update(settingsData);
      } else {
        await _firestore
            .collection(_settingsCollectionName)
            .add(settingsData);
      }
    } catch (e) {
      throw Exception('Failed to save settings: $e');
    }
  }

  /// Get user blood sugar settings
  Future<Map<String, List<SugarRange>>?> getUserSettings(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_settingsCollectionName)
          .where('userId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final data = querySnapshot.docs.first.data();
      final rangesMap = <String, List<SugarRange>>{};
      
      if (data['ranges'] != null) {
        final ranges = data['ranges'] as Map<String, dynamic>;
        ranges.forEach((key, value) {
          final list = value as List;
          rangesMap[key] = list.map((r) => SugarRange.fromMap(r as Map<String, dynamic>)).toList();
        });
      }

      return rangesMap;
    } catch (e) {
      print('Error getting settings: $e');
      return null;
    }
  }

  /// Export measurements to CSV format
  Uint8List exportToCsv(List<BloodSugarMeasurement> measurements, {bool isArabic = false}) {
    final List<String> rows = [];
    
    // Check if data contains Arabic characters
    bool hasArabicData = false;
    for (final m in measurements) {
      if (_containsNonAscii(m.name) || _containsNonAscii(m.description ?? '')) {
        hasArabicData = true;
        break;
      }
    }
    
    bool useArabicLabels = isArabic || hasArabicData;
    
    // Header
    if (useArabicLabels) {
      rows.add('التاريخ,الوقت,الاسم,الوصف,القيمة,الوحدة,الحالة,التصنيف');
    } else {
      rows.add('Date,Time,Name,Description,Value,Unit,Condition,Category');
    }
    
    // Data rows
    for (final m in measurements) {
      final name = _escapeCsvValue(m.name);
      final description = _escapeCsvValue(m.description ?? '');
      
      bool rowHasArabic = _containsNonAscii(name) || _containsNonAscii(description);
      bool rowUseArabic = isArabic || rowHasArabic;
      
      final parts = <String>[
        '${m.date.year}-${m.date.month.toString().padLeft(2, '0')}-${m.date.day.toString().padLeft(2, '0')}',
        '${m.date.hour.toString().padLeft(2, '0')}:${m.date.minute.toString().padLeft(2, '0')}',
        name,
        description,
        m.unit == 'mmoll' ? m.value.toStringAsFixed(1) : m.value.toStringAsFixed(0),
        rowUseArabic ? (m.unit == 'mmoll' ? 'ملي مول/لتر' : 'ملجم/ديسيليتر') : (m.unit == 'mmoll' ? 'mmol/L' : 'mg/dL'),
        rowUseArabic ? _getConditionArabic(m.condition) : _getConditionEnglish(m.condition),
        rowUseArabic ? _getCategoryArabic(m.category) : _getCategoryEnglish(m.category),
      ];
      
      rows.add(parts.join(','));
    }
    
    final csvContent = rows.join('\r\n');
    final utf8Bytes = utf8.encode(csvContent);
    final BOM = <int>[0xEF, 0xBB, 0xBF];
    return Uint8List.fromList([...BOM, ...utf8Bytes]);
  }

  String _escapeCsvValue(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n') || value.contains('\r')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  bool _containsNonAscii(String value) {
    for (int i = 0; i < value.length; i++) {
      final codeUnit = value.codeUnitAt(i);
      if (codeUnit > 127) {
        return true;
      }
    }
    return false;
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
}
