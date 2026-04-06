import 'package:cloud_firestore/cloud_firestore.dart';

/// Blood Pressure Measurement Model
class BloodPressureMeasurement {
  final String? id;
  final String userId;
  final String name;
  final String? description;
  final DateTime date;
  final int systolic;
  final int diastolic;
  final int? pulse;
  final String arm; // 'left' or 'right'
  final String position; // 'sitting', 'standing', 'lying'
  final String condition; // 'resting', 'after_exercise', 'after_meal', 'stressed'
  final DateTime createdAt;
  final DateTime? updatedAt;

  BloodPressureMeasurement({
    this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.date,
    required this.systolic,
    required this.diastolic,
    required this.pulse,
    required this.arm,
    required this.position,
    required this.condition,
    required this.createdAt,
    this.updatedAt,
  });

  factory BloodPressureMeasurement.fromMap(Map<String, dynamic> map, String docId) {
    return BloodPressureMeasurement(
      id: docId,
      userId: map['userId'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      date: (map['date'] as Timestamp).toDate(),
      systolic: map['systolic'] as int,
      diastolic: map['diastolic'] as int,
      pulse: map['pulse'] as int?,
      arm: map['arm'] as String,
      position: map['position'] as String,
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
      'systolic': systolic,
      'diastolic': diastolic,
      'pulse': pulse,
      'arm': arm,
      'position': position,
      'condition': condition,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  BloodPressureMeasurement copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    DateTime? date,
    int? systolic,
    int? diastolic,
    int? pulse,
    String? arm,
    String? position,
    String? condition,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BloodPressureMeasurement(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      date: date ?? this.date,
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      pulse: pulse ?? this.pulse,
      arm: arm ?? this.arm,
      position: position ?? this.position,
      condition: condition ?? this.condition,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get blood pressure category based on values
  /// Based on American Heart Association guidelines
  /// Accepts optional custom ranges from user settings
  String getCategory(List<BloodPressureRange>? customRanges) {
    final ranges = customRanges ?? BloodPressureRange.defaultRanges;
    
    // Sort ranges by priority (crisis first, then stage2, stage1, elevated, normal)
    // This ensures correct matching with OR logic for higher categories
    
    for (final range in ranges) {
      // Use OR logic for matching in each range
      // This matches AHA guidelines: Stage 1 and Stage 2 use OR, not AND
      bool systolicMatch = systolic >= range.systolicMin && 
          (range.systolicMax >= 999 || systolic <= range.systolicMax);
      
      bool diastolicMatch = diastolic >= range.diastolicMin && 
          (range.diastolicMax >= 999 || diastolic <= range.diastolicMax);
      
      // For Crisis: either systolic OR diastolic can trigger
      if (range.category == 'crisis') {
        if (systolicMatch || diastolicMatch) {
          return range.category;
        }
      }
      // For High Stage 2: either systolic OR diastolic can trigger
      else if (range.category == 'high_stage2') {
        if (systolicMatch || diastolicMatch) {
          return range.category;
        }
      }
      // For High Stage 1: either systolic OR diastolic can trigger
      else if (range.category == 'high_stage1') {
        if (systolicMatch || diastolicMatch) {
          return range.category;
        }
      }
      // For Elevated and Normal: both must match (AND logic)
      else {
        if (systolicMatch && diastolicMatch) {
          return range.category;
        }
      }
    }
    return 'unknown';
  }

  /// Get blood pressure category using default ranges
  String get category => getCategory(null);

  /// Get formatted blood pressure string
  String get formattedValue => '$systolic/$diastolic mmHg';
  
  /// Get formatted pulse string
  String get formattedPulse => '$pulse bpm';
}

/// Arm options
class ArmOption {
  final String value;
  final String labelEn;
  final String labelAr;

  const ArmOption({
    required this.value,
    required this.labelEn,
    required this.labelAr,
  });

  static const List<ArmOption> options = [
    ArmOption(value: 'left', labelEn: 'Left Arm', labelAr: 'الذراع اليسرى'),
    ArmOption(value: 'right', labelEn: 'Right Arm', labelAr: 'الذراع اليمنى'),
  ];
}

/// Position options
class PositionOption {
  final String value;
  final String labelEn;
  final String labelAr;

  const PositionOption({
    required this.value,
    required this.labelEn,
    required this.labelAr,
  });

  static const List<PositionOption> options = [
    PositionOption(value: 'sitting', labelEn: 'Sitting', labelAr: 'جالس'),
    PositionOption(value: 'standing', labelEn: 'Standing', labelAr: 'واقف'),
    PositionOption(value: 'lying', labelEn: 'Lying Down', labelAr: 'مستلقٍ'),
  ];
}

/// Condition options
class ConditionOption {
  final String value;
  final String labelEn;
  final String labelAr;

  const ConditionOption({
    required this.value,
    required this.labelEn,
    required this.labelAr,
  });

  static const List<ConditionOption> options = [
    ConditionOption(value: 'resting', labelEn: 'At Rest', labelAr: 'في الراحة'),
    ConditionOption(value: 'after_exercise', labelEn: 'After Exercise', labelAr: 'بعد التمرين'),
    ConditionOption(value: 'after_meal', labelEn: 'After Meal', labelAr: 'بعد الأكل'),
    ConditionOption(value: 'stressed', labelEn: 'Stressed', labelAr: 'تحت ضغط'),
  ];
}

/// Blood Pressure Statistics
class BloodPressureStatistics {
  final int totalMeasurements;
  final double averageSystolic;
  final double averageDiastolic;
  final double averagePulse;
  final int minSystolic;
  final int maxSystolic;
  final int minDiastolic;
  final int maxDiastolic;
  final int normalCount;
  final int elevatedCount;
  final int highStage1Count;
  final int highStage2Count;
  final int crisisCount;

  BloodPressureStatistics({
    required this.totalMeasurements,
    required this.averageSystolic,
    required this.averageDiastolic,
    required this.averagePulse,
    required this.minSystolic,
    required this.maxSystolic,
    required this.minDiastolic,
    required this.maxDiastolic,
    required this.normalCount,
    required this.elevatedCount,
    required this.highStage1Count,
    required this.highStage2Count,
    required this.crisisCount,
  });

  factory BloodPressureStatistics.empty() {
    return BloodPressureStatistics(
      totalMeasurements: 0,
      averageSystolic: 0,
      averageDiastolic: 0,
      averagePulse: 0,
      minSystolic: 0,
      maxSystolic: 0,
      minDiastolic: 0,
      maxDiastolic: 0,
      normalCount: 0,
      elevatedCount: 0,
      highStage1Count: 0,
      highStage2Count: 0,
      crisisCount: 0,
    );
  }

  factory BloodPressureStatistics.fromMeasurements(List<BloodPressureMeasurement> measurements) {
    if (measurements.isEmpty) {
      return BloodPressureStatistics.empty();
    }

    final systolicValues = measurements.map((m) => m.systolic).toList();
    final diastolicValues = measurements.map((m) => m.diastolic).toList();
    // Filter out null pulse values
    final pulseValues = measurements
        .map((m) => m.pulse)
        .where((p) => p != null)
        .cast<int>()
        .toList();

    int normalCount = 0;
    int elevatedCount = 0;
    int highStage1Count = 0;
    int highStage2Count = 0;
    int crisisCount = 0;

    for (final m in measurements) {
      switch (m.category) {
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

    return BloodPressureStatistics(
      totalMeasurements: measurements.length,
      averageSystolic: systolicValues.reduce((a, b) => a + b) / measurements.length,
      averageDiastolic: diastolicValues.reduce((a, b) => a + b) / measurements.length,
      averagePulse: pulseValues.isEmpty 
          ? 0.0 
          : pulseValues.reduce((a, b) => a + b) / pulseValues.length,
      minSystolic: systolicValues.reduce((a, b) => a < b ? a : b),
      maxSystolic: systolicValues.reduce((a, b) => a > b ? a : b),
      minDiastolic: diastolicValues.reduce((a, b) => a < b ? a : b),
      maxDiastolic: diastolicValues.reduce((a, b) => a > b ? a : b),
      normalCount: normalCount,
      elevatedCount: elevatedCount,
      highStage1Count: highStage1Count,
      highStage2Count: highStage2Count,
      crisisCount: crisisCount,
    );
  }
}

/// Blood Pressure Range model for user-editable target ranges
class BloodPressureRange {
  final String category;
  final int systolicMin;
  final int systolicMax;
  final int diastolicMin;
  final int diastolicMax;
  final String color;

  const BloodPressureRange({
    required this.category,
    required this.systolicMin,
    required this.systolicMax,
    required this.diastolicMin,
    required this.diastolicMax,
    required this.color,
  });

  factory BloodPressureRange.fromMap(Map<String, dynamic> map) {
    return BloodPressureRange(
      category: map['category'] as String,
      systolicMin: map['systolicMin'] as int,
      systolicMax: map['systolicMax'] as int,
      diastolicMin: map['diastolicMin'] as int,
      diastolicMax: map['diastolicMax'] as int,
      color: map['color'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'systolicMin': systolicMin,
      'systolicMax': systolicMax,
      'diastolicMin': diastolicMin,
      'diastolicMax': diastolicMax,
      'color': color,
    };
  }

  BloodPressureRange copyWith({
    String? category,
    int? systolicMin,
    int? systolicMax,
    int? diastolicMin,
    int? diastolicMax,
    String? color,
  }) {
    return BloodPressureRange(
      category: category ?? this.category,
      systolicMin: systolicMin ?? this.systolicMin,
      systolicMax: systolicMax ?? this.systolicMax,
      diastolicMin: diastolicMin ?? this.diastolicMin,
      diastolicMax: diastolicMax ?? this.diastolicMax,
      color: color ?? this.color,
    );
  }

  /// Default ranges based on American Heart Association guidelines
  static List<BloodPressureRange> get defaultRanges => [
    const BloodPressureRange(
      category: 'normal',
      systolicMin: 0,
      systolicMax: 119,
      diastolicMin: 0,
      diastolicMax: 79,
      color: 'green',
    ),
    const BloodPressureRange(
      category: 'elevated',
      systolicMin: 120,
      systolicMax: 129,
      diastolicMin: 0,
      diastolicMax: 79,
      color: 'blue',
    ),
    const BloodPressureRange(
      category: 'high_stage1',
      systolicMin: 130,
      systolicMax: 139,
      diastolicMin: 80,
      diastolicMax: 89,
      color: 'orange',
    ),
    const BloodPressureRange(
      category: 'high_stage2',
      systolicMin: 140,
      systolicMax: 180,
      diastolicMin: 90,
      diastolicMax: 120,
      color: 'red',
    ),
    const BloodPressureRange(
      category: 'crisis',
      systolicMin: 181,
      systolicMax: 999,
      diastolicMin: 121,
      diastolicMax: 999,
      color: 'darkred',
    ),
  ];
}
