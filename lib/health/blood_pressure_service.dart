import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'blood_pressure_model.dart';

class BloodPressureService {
  static const String _collectionName = 'blood_pressure_measurements';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add a new blood pressure measurement
  Future<String> addMeasurement(BloodPressureMeasurement measurement) async {
    try {
      print('Adding measurement for user: ${measurement.userId}');
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

  /// Update an existing blood pressure measurement
  Future<void> updateMeasurement(BloodPressureMeasurement measurement) async {
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

  /// Delete a blood pressure measurement
  Future<void> deleteMeasurement(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete measurement: $e');
    }
  }

  /// Get all measurements for a user
  Future<List<BloodPressureMeasurement>> getAllMeasurements(String userId) async {
    try {
      print('Fetching measurements for userId: $userId');
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      print('Found ${querySnapshot.docs.length} documents');

      return querySnapshot.docs
          .map((doc) => BloodPressureMeasurement.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting measurements: $e');
      throw Exception('Failed to get measurements: $e');
    }
  }

  /// Get measurements for a specific date
  Future<List<BloodPressureMeasurement>> getMeasurementsByDate(
    String userId,
    DateTime date,
  ) async {
    try {
      // Get all measurements for user first, then filter by date
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
  Future<List<BloodPressureMeasurement>> getMeasurementsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Get all measurements for user first, then filter by date range
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
  Future<List<BloodPressureMeasurement>> getWeeklyMeasurements(String userId) async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return getMeasurementsByDateRange(userId, weekAgo, now);
  }

  /// Get measurements for the last 30 days (month)
  Future<List<BloodPressureMeasurement>> getMonthlyMeasurements(String userId) async {
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));
    return getMeasurementsByDateRange(userId, monthAgo, now);
  }

  /// Get measurements for the last 365 days (year)
  Future<List<BloodPressureMeasurement>> getYearlyMeasurements(String userId) async {
    final now = DateTime.now();
    final yearAgo = now.subtract(const Duration(days: 365));
    return getMeasurementsByDateRange(userId, yearAgo, now);
  }

  /// Get today's measurements
  Future<List<BloodPressureMeasurement>> getTodayMeasurements(String userId) async {
    return getMeasurementsByDate(userId, DateTime.now());
  }

  /// Get statistics for today's measurements
  Future<BloodPressureStatistics> getTodayStatistics(String userId) async {
    final measurements = await getTodayMeasurements(userId);
    return BloodPressureStatistics.fromMeasurements(measurements);
  }

  /// Get statistics for a specific period
  Future<BloodPressureStatistics> getStatistics(String userId, String period) async {
    List<BloodPressureMeasurement> measurements;
    
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
    
    return BloodPressureStatistics.fromMeasurements(measurements);
  }

  /// Get measurements grouped by day (for week view)
  Future<Map<DateTime, List<BloodPressureMeasurement>>> getMeasurementsGroupedByDay(
    String userId,
    int days,
  ) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    final measurements = await getMeasurementsByDateRange(userId, startDate, now);

    final Map<DateTime, List<BloodPressureMeasurement>> grouped = {};
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
  Future<Map<int, List<BloodPressureMeasurement>>> getMeasurementsGroupedByWeek(
    String userId,
    int days,
  ) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    final measurements = await getMeasurementsByDateRange(userId, startDate, now);

    final Map<int, List<BloodPressureMeasurement>> grouped = {};
    for (final m in measurements) {
      // Calculate week number since start of year
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
  Future<Map<String, List<BloodPressureMeasurement>>> getMeasurementsGroupedByMonth(
    String userId,
    int days,
  ) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    final measurements = await getMeasurementsByDateRange(userId, startDate, now);

    final Map<String, List<BloodPressureMeasurement>> grouped = {};
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

  /// Export measurements to CSV format
  /// Now detects Arabic content in data and uses Arabic labels accordingly
  Uint8List exportToCsv(List<BloodPressureMeasurement> measurements, {bool isArabic = false}) {
    final List<String> rows = [];
    
    // Check if data contains Arabic characters - if so, use Arabic headers
    bool hasArabicData = false;
    for (final m in measurements) {
      if (_containsNonAscii(m.name) || _containsNonAscii(m.description ?? '')) {
        hasArabicData = true;
        break;
      }
    }
    
    // Use Arabic headers if UI is Arabic OR data has Arabic content
    bool useArabicLabels = isArabic || hasArabicData;
    
    // Header (localized)
    if (useArabicLabels) {
      rows.add('التاريخ,الوقت,الاسم,الوصف,الانقباضي (مملمغ),الانبساطي (مملمغ),النبض (نبضة/دقيقة),الذراع,الموقع,الحالة,التصنيف');
    } else {
      rows.add('Date,Time,Name,Description,Systolic (mmHg),Diastolic (mmHg),Pulse (bpm),Arm,Position,Condition,Category');
    }
    
    // Data rows - build row carefully
    for (final m in measurements) {
      final name = _escapeCsvValue(m.name);
      final description = _escapeCsvValue(m.description ?? '');
      
      // Check if this measurement has non-ASCII (Arabic) content
      bool rowHasArabic = _containsNonAscii(name) || _containsNonAscii(description);
      // Use Arabic labels if UI is Arabic OR this row has Arabic content
      bool rowUseArabic = isArabic || rowHasArabic;
      
      final parts = <String>[
        '${m.date.year}-${m.date.month.toString().padLeft(2, '0')}-${m.date.day.toString().padLeft(2, '0')}',
        '${m.date.hour.toString().padLeft(2, '0')}:${m.date.minute.toString().padLeft(2, '0')}',
        name,
        description,
        '${m.systolic}',
        '${m.diastolic}',
        m.pulse?.toString() ?? '',
        rowUseArabic ? (m.arm == 'left' ? 'يسار' : 'يمين') : (m.arm == 'left' ? 'Left' : 'Right'),
        rowUseArabic ? _getPositionArabic(m.position) : _getPositionEnglish(m.position),
        rowUseArabic ? _getConditionArabic(m.condition) : _getConditionEnglish(m.condition),
        rowUseArabic ? _getCategoryArabic(m.category) : _getCategoryEnglish(m.category),
      ];
      
      rows.add(parts.join(','));
    }
    
    // Join with CRLF (Windows-style line endings for Excel compatibility)
    final csvContent = rows.join('\r\n');
    
    // Encode the content to UTF-8
    final utf8Bytes = utf8.encode(csvContent);
    
    // Prepend UTF-8 BOM for Excel compatibility
    final BOM = <int>[0xEF, 0xBB, 0xBF];
    return Uint8List.fromList([...BOM, ...utf8Bytes]);
  }

  String _escapeCsvValue(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n') || value.contains('\r')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Check if string contains non-ASCII characters (Arabic, Hebrew, etc.)
  bool _containsNonAscii(String value) {
    for (int i = 0; i < value.length; i++) {
      final codeUnit = value.codeUnitAt(i);
      // Check for non-ASCII characters (code unit > 127)
      if (codeUnit > 127) {
        return true;
      }
    }
    return false;
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
        return 'High Stage 1';
      case 'high_stage2':
        return 'High Stage 2';
      case 'crisis':
        return 'Crisis';
      default:
        return category;
    }
  }

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
