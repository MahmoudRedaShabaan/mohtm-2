import 'package:cloud_firestore/cloud_firestore.dart';

/// Blood Sugar Measurement Model
class BloodSugarMeasurement {
  final String? id;
  final String userId;
  final String name;
  final String? description;
  final DateTime date;
  final double value;
  final String unit; // 'mgdl' or 'mmoll'
  final String condition; // 'default', 'fasting', 'before_meal', 'after_meal_1h', 'after_meal_2h', 'sleep', 'before_exercise', 'after_exercise'
  final DateTime createdAt;
  final DateTime? updatedAt;

  BloodSugarMeasurement({
    this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.date,
    required this.value,
    this.unit = 'mgdl',
    required this.condition,
    required this.createdAt,
    this.updatedAt,
  });

  factory BloodSugarMeasurement.fromMap(Map<String, dynamic> map, String docId) {
    return BloodSugarMeasurement(
      id: docId,
      userId: map['userId'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      date: (map['date'] as Timestamp).toDate(),
      value: (map['value'] as num).toDouble(),
      unit: map['unit'] as String? ?? 'mgdl',
      condition: map['condition'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null ? (map['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'date': Timestamp.fromDate(date),
      'value': value,
      'unit': unit,
      'condition': condition,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  BloodSugarMeasurement copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    DateTime? date,
    double? value,
    String? unit,
    String? condition,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BloodSugarMeasurement(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      date: date ?? this.date,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      condition: condition ?? this.condition,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get value in mg/dl
  double get valueInMgDl {
    if (unit == 'mmoll') {
      return value * 18.0182; // Convert mmol/L to mg/dl
    }
    return value;
  }

  /// Get value in mmol/l
  double get valueInMmoll {
    if (unit == 'mgdl') {
      return value / 18.0182; // Convert mg/dl to mmol/L
    }
    return value;
  }

  /// Get formatted value string
  String get formattedValue {
    if (unit == 'mmoll') {
      return '${value.toStringAsFixed(1)} mmol/L';
    }
    return '${value.toStringAsFixed(0)} mg/dL';
  }

  /// Get category based on value and condition
  String get category {
    // Get ranges based on condition
    final ranges = SugarRange.getRangesForCondition(condition, unit);
    final val = valueInMgDl;

    // Low: value < lowMax
    if (val < ranges.lowMax) {
      return 'low';
    } 
    // Normal: value >= normalMin AND value < normalMax
    else if (val >= ranges.normalMin && val < ranges.normalMax) {
      return 'normal';
    } 
    // Pre-Diabetes: value >= preDiabetesMin AND value < preDiabetesMax
    else if (val >= ranges.preDiabetesMin && val < ranges.preDiabetesMax) {
      return 'pre_diabetes';
    } 
    // Diabetes: value >= diabetesMin
    else {
      return 'diabetes';
    }
  }
}

/// Condition options for blood sugar
class SugarConditionOption {
  final String value;
  final String labelEn;
  final String labelAr;

  const SugarConditionOption({
    required this.value,
    required this.labelEn,
    required this.labelAr,
  });

  static const List<SugarConditionOption> options = [
    SugarConditionOption(value: 'default_condition', labelEn: 'Default', labelAr: 'افتراضي'),
    SugarConditionOption(value: 'fasting', labelEn: 'Fasting', labelAr: 'صائم'),
    SugarConditionOption(value: 'before_meal', labelEn: 'Before a Meal', labelAr: 'قبل الوجبة'),
    SugarConditionOption(value: 'after_meal_1h', labelEn: 'After a Meal (1h)', labelAr: 'بعد الوجبة (ساعة)'),
    SugarConditionOption(value: 'after_meal_2h', labelEn: 'After a Meal (2h)', labelAr: 'بعد الوجبة (ساعتان)'),
    SugarConditionOption(value: 'sleep', labelEn: 'Sleep', labelAr: 'النوم'),
    SugarConditionOption(value: 'before_exercise', labelEn: 'Before Exercise', labelAr: 'قبل التمرين'),
    SugarConditionOption(value: 'after_exercise', labelEn: 'After Exercise', labelAr: 'بعد التمرين'),
  ];
}

/// Unit options for blood sugar
class SugarUnitOption {
  final String value;
  final String labelEn;
  final String labelAr;
  final String symbol;

  const SugarUnitOption({
    required this.value,
    required this.labelEn,
    required this.labelAr,
    required this.symbol,
  });

  static const List<SugarUnitOption> options = [
    SugarUnitOption(value: 'mgdl', labelEn: 'mg/dL', labelAr: 'ملجم/ديسيليتر', symbol: 'mg/dL'),
    SugarUnitOption(value: 'mmoll', labelEn: 'mmol/L', labelAr: 'ملي مول/لتر', symbol: 'mmol/L'),
  ];
}

/// Sugar range model for storing editable ranges
class SugarRange {
  final String condition;
  final String unit;
  // Low category: values < lowMax
  final double lowMax;
  // Normal category: values >= normalMin AND < normalMax
  final double normalMin;
  final double normalMax;
  // Pre-Diabetes category: values >= preDiabetesMin AND < preDiabetesMax
  final double preDiabetesMin;
  final double preDiabetesMax;
  // Diabetes category: values >= diabetesMin
  final double diabetesMin;

  // Static property to store user-defined ranges (loaded from Firestore)
  static Map<String, List<SugarRange>>? userRanges;

  SugarRange({
    required this.condition,
    required this.unit,
    required this.lowMax,
    required this.normalMin,
    required this.normalMax,
    required this.preDiabetesMin,
    required this.preDiabetesMax,
    required this.diabetesMin,
  });

  factory SugarRange.fromMap(Map<String, dynamic> map) {
    return SugarRange(
      condition: map['condition'] as String,
      unit: map['unit'] as String,
      lowMax: (map['lowMax'] as num).toDouble(),
      normalMin: (map['normalMin'] as num).toDouble(),
      normalMax: (map['normalMax'] as num).toDouble(),
      preDiabetesMin: (map['preDiabetesMin'] as num).toDouble(),
      preDiabetesMax: (map['preDiabetesMax'] as num).toDouble(),
      diabetesMin: (map['diabetesMin'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'condition': condition,
      'unit': unit,
      'lowMax': lowMax,
      'normalMin': normalMin,
      'normalMax': normalMax,
      'preDiabetesMin': preDiabetesMin,
      'preDiabetesMax': preDiabetesMax,
      'diabetesMin': diabetesMin,
    };
  }

  SugarRange copyWith({
    String? condition,
    String? unit,
    double? lowMax,
    double? normalMin,
    double? normalMax,
    double? preDiabetesMin,
    double? preDiabetesMax,
    double? diabetesMin,
  }) {
    return SugarRange(
      condition: condition ?? this.condition,
      unit: unit ?? this.unit,
      lowMax: lowMax ?? this.lowMax,
      normalMin: normalMin ?? this.normalMin,
      normalMax: normalMax ?? this.normalMax,
      preDiabetesMin: preDiabetesMin ?? this.preDiabetesMin,
      preDiabetesMax: preDiabetesMax ?? this.preDiabetesMax,
      diabetesMin: diabetesMin ?? this.diabetesMin,
    );
  }

  /// Get default ranges for a condition and unit
  static SugarRange getRangesForCondition(String condition, String unit) {
    // If user has custom ranges, use them
    if (userRanges != null && userRanges!.containsKey(unit)) {
      final ranges = userRanges![unit]!;
      final customRange = ranges.where((r) => r.condition == condition).firstOrNull;
      if (customRange != null) {
        return customRange;
      }
    }
    
    // Default ranges for mg/dl (user specified values)
    // Low <72 (blue), Normal >=72 and <99 (green), Pre-Diabetes >=99 and <126 (yellow), Diabetes >=126 (red)
    final mgDlDefaults = {
      'default_condition': SugarRange(condition: 'default_condition', unit: 'mgdl', lowMax: 72, normalMin: 72, normalMax: 99, preDiabetesMin: 99, preDiabetesMax: 126, diabetesMin: 126),
      'fasting': SugarRange(condition: 'fasting', unit: 'mgdl', lowMax: 72, normalMin: 72, normalMax: 99, preDiabetesMin: 99, preDiabetesMax: 126, diabetesMin: 126),
      'before_meal': SugarRange(condition: 'before_meal', unit: 'mgdl', lowMax: 72, normalMin: 72, normalMax: 99, preDiabetesMin: 99, preDiabetesMax: 126, diabetesMin: 126),
      'after_meal_1h': SugarRange(condition: 'after_meal_1h', unit: 'mgdl', lowMax: 72, normalMin: 72, normalMax: 99, preDiabetesMin: 99, preDiabetesMax: 126, diabetesMin: 126),
      'after_meal_2h': SugarRange(condition: 'after_meal_2h', unit: 'mgdl', lowMax: 72, normalMin: 72, normalMax: 99, preDiabetesMin: 99, preDiabetesMax: 126, diabetesMin: 126),
      'sleep': SugarRange(condition: 'sleep', unit: 'mgdl', lowMax: 72, normalMin: 72, normalMax: 99, preDiabetesMin: 99, preDiabetesMax: 126, diabetesMin: 126),
      'before_exercise': SugarRange(condition: 'before_exercise', unit: 'mgdl', lowMax: 72, normalMin: 72, normalMax: 99, preDiabetesMin: 99, preDiabetesMax: 126, diabetesMin: 126),
      'after_exercise': SugarRange(condition: 'after_exercise', unit: 'mgdl', lowMax: 72, normalMin: 72, normalMax: 99, preDiabetesMin: 99, preDiabetesMax: 126, diabetesMin: 126),
    };

    // Default ranges for mmol/l (user specified values)
    // Low <4.0 (blue), Normal >=4.0 and <5.5 (green), Pre-Diabetes >=5.5 and <7.0 (yellow), Diabetes >=7.0 (red)
    final mmollDefaults = {
      'default_condition': SugarRange(condition: 'default_condition', unit: 'mmoll', lowMax: 4.0, normalMin: 4.0, normalMax: 5.5, preDiabetesMin: 5.5, preDiabetesMax: 7.0, diabetesMin: 7.0),
      'fasting': SugarRange(condition: 'fasting', unit: 'mmoll', lowMax: 4.0, normalMin: 4.0, normalMax: 5.5, preDiabetesMin: 5.5, preDiabetesMax: 7.0, diabetesMin: 7.0),
      'before_meal': SugarRange(condition: 'before_meal', unit: 'mmoll', lowMax: 4.0, normalMin: 4.0, normalMax: 5.5, preDiabetesMin: 5.5, preDiabetesMax: 7.0, diabetesMin: 7.0),
      'after_meal_1h': SugarRange(condition: 'after_meal_1h', unit: 'mmoll', lowMax: 4.0, normalMin: 4.0, normalMax: 5.5, preDiabetesMin: 5.5, preDiabetesMax: 7.0, diabetesMin: 7.0),
      'after_meal_2h': SugarRange(condition: 'after_meal_2h', unit: 'mmoll', lowMax: 4.0, normalMin: 4.0, normalMax: 5.5, preDiabetesMin: 5.5, preDiabetesMax: 7.0, diabetesMin: 7.0),
      'sleep': SugarRange(condition: 'sleep', unit: 'mmoll', lowMax: 4.0, normalMin: 4.0, normalMax: 5.5, preDiabetesMin: 5.5, preDiabetesMax: 7.0, diabetesMin: 7.0),
      'before_exercise': SugarRange(condition: 'before_exercise', unit: 'mmoll', lowMax: 4.0, normalMin: 4.0, normalMax: 5.5, preDiabetesMin: 5.5, preDiabetesMax: 7.0, diabetesMin: 7.0),
      'after_exercise': SugarRange(condition: 'after_exercise', unit: 'mmoll', lowMax: 4.0, normalMin: 4.0, normalMax: 5.5, preDiabetesMin: 5.5, preDiabetesMax: 7.0, diabetesMin: 7.0),
    };

    if (unit == 'mmoll') {
      return mmollDefaults[condition] ?? mmollDefaults['default_condition']!;
    }
    return mgDlDefaults[condition] ?? mgDlDefaults['default_condition']!;
  }
}

/// Blood Sugar Statistics
class BloodSugarStatistics {
  final int totalMeasurements;
  final double averageValue;
  final double minValue;
  final double maxValue;
  final int lowCount;
  final int normalCount;
  final int preDiabetesCount;
  final int diabetesCount;

  BloodSugarStatistics({
    required this.totalMeasurements,
    required this.averageValue,
    required this.minValue,
    required this.maxValue,
    required this.lowCount,
    required this.normalCount,
    required this.preDiabetesCount,
    required this.diabetesCount,
  });

  factory BloodSugarStatistics.empty() {
    return BloodSugarStatistics(
      totalMeasurements: 0,
      averageValue: 0,
      minValue: 0,
      maxValue: 0,
      lowCount: 0,
      normalCount: 0,
      preDiabetesCount: 0,
      diabetesCount: 0,
    );
  }

  factory BloodSugarStatistics.fromMeasurements(List<BloodSugarMeasurement> measurements) {
    if (measurements.isEmpty) {
      return BloodSugarStatistics.empty();
    }

    // Get values in mg/dl for consistent statistics
    final values = measurements.map((m) => m.valueInMgDl).toList();

    int lowCount = 0;
    int normalCount = 0;
    int preDiabetesCount = 0;
    int diabetesCount = 0;

    for (final m in measurements) {
      switch (m.category) {
        case 'low':
          lowCount++;
          break;
        case 'normal':
          normalCount++;
          break;
        case 'pre_diabetes':
          preDiabetesCount++;
          break;
        case 'diabetes':
          diabetesCount++;
          break;
      }
    }

    return BloodSugarStatistics(
      totalMeasurements: measurements.length,
      averageValue: values.reduce((a, b) => a + b) / measurements.length,
      minValue: values.reduce((a, b) => a < b ? a : b),
      maxValue: values.reduce((a, b) => a > b ? a : b),
      lowCount: lowCount,
      normalCount: normalCount,
      preDiabetesCount: preDiabetesCount,
      diabetesCount: diabetesCount,
    );
  }
}
