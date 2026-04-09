import 'package:cloud_firestore/cloud_firestore.dart';

class PredefinedData {
  static List<String> getMedications(String locale) {
    if (locale == 'ar') {
      return [
        'البنسلين',
        'الأسبرين',
        'الإيبوبروفين',
        'السلفا',
        'التتراسيكلين',
        'السبروفلوكساسين',
        'الليدوكايين',
        'الكودايين',
        'المورفين',
        'اللتكس',
        'الصبغة',
      ];
    }
    return [
      'Penicillin',
      'Aspirin',
      'Ibuprofen',
      'Sulfa drugs',
      'Tetracycline',
      'Ciprofloxacin',
      'Lidocaine',
      'Codeine',
      'Morphine',
      'Latex',
      'Contrast dye',
    ];
  }

  static List<String> getFoods(String locale) {
    if (locale == 'ar') {
      return [
        'الفول السوداني',
        'المكسرات',
        'الحليب',
        'البيض',
        'القمح',
        'الصويا',
        'السمك',
        'المحار',
        'السمسم',
        'الغلوتين',
        'اللاكتوز',
      ];
    }
    return [
      'Peanuts',
      'Tree nuts',
      'Milk',
      'Eggs',
      'Wheat',
      'Soy',
      'Fish',
      'Shellfish',
      'Sesame',
      'Gluten',
      'Lactose',
    ];
  }

  static List<String> getChronicDiseases(String locale) {
    if (locale == 'ar') {
      return [
        'السكري النوع الأول',
        'السكري النوع الثاني',
        'ارتفاع ضغط الدم',
        'أمراض القلب',
        'الربو',
        'مرض الرئة المزمن',
        'مرض الكلى المزمن',
        'أمراض الكبد',
        'اضطراب الغدة الدرقية',
        'التهاب المفاصل',
        'السرطان',
        'الصرع',
        'الإيدز',
        'أنيميا الخلايا المنجلية',
        'الاكتئاب',
        'القلق',
        'الاضطراب ثنائي القطب',
      ];
    }
    return [
      'Diabetes Type 1',
      'Diabetes Type 2',
      'Hypertension',
      'Heart Disease',
      'Asthma',
      'COPD',
      'Chronic Kidney Disease',
      'Liver Disease',
      'Thyroid Disorder',
      'Arthritis',
      'Cancer',
      'Epilepsy',
      'HIV/AIDS',
      'Sickle Cell Disease',
      'Depression',
      'Anxiety',
      'Bipolar Disorder',
    ];
  }

  static String getFrequencyDisplay(String frequency, String locale) {
    if (locale == 'ar') {
      switch (frequency) {
        case 'onceDaily':
          return 'مرة واحدة يومياً';
        case 'twiceDaily':
          return 'مرتين يومياً';
        case 'threeTimesDaily':
          return 'ثلاث مرات يومياً';
        case 'every8Hours':
          return 'كل 8 ساعات';
        case 'every12Hours':
          return 'كل 12 ساعة';
        case 'asNeeded':
          return 'عند الحاجة';
        case 'custom':
          return 'مخصص';
        default:
          return frequency;
      }
    }
    switch (frequency) {
      case 'onceDaily':
        return 'Once daily';
      case 'twiceDaily':
        return 'Twice daily';
      case 'threeTimesDaily':
        return 'Three times daily';
      case 'every8Hours':
        return 'Every 8 hours';
      case 'every12Hours':
        return 'Every 12 hours';
      case 'asNeeded':
        return 'As needed';
      case 'custom':
        return 'Custom';
      default:
        return frequency;
    }
  }
}

/// Blood types available for selection
enum BloodType {
  aPositive('A+'),
  aNegative('A-'),
  bPositive('B+'),
  bNegative('B-'),
  oPositive('O+'),
  oNegative('O-'),
  abPositive('AB+'),
  abNegative('AB-');

  final String displayName;
  const BloodType(this.displayName);

  static BloodType fromString(String value) {
    return BloodType.values.firstWhere(
      (e) => e.displayName == value || e.name == value,
      orElse: () => BloodType.aPositive,
    );
  }
}

/// Unit for height measurement
enum HeightUnit {
  cm('cm'),
  ft('ft'),
  inches('in');

  final String displayName;
  const HeightUnit(this.displayName);
}

/// Unit for weight measurement
enum WeightUnit {
  kg('kg'),
  lbs('lbs');

  final String displayName;
  const WeightUnit(this.displayName);
}

/// Allergy type - medication or food
enum AllergyType {
  medication('Medication'),
  food('Food');

  final String displayName;
  const AllergyType(this.displayName);

  static AllergyType fromString(String value) {
    return AllergyType.values.firstWhere(
      (e) => e.name == value || e.displayName == value,
      orElse: () => AllergyType.medication,
    );
  }
}

/// Medication frequency type
enum MedicationFrequency {
  onceDaily('Once daily'),
  twiceDaily('Twice daily'),
  threeTimesDaily('Three times daily'),
  every8Hours('Every 8 hours'),
  every12Hours('Every 12 hours'),
  asNeeded('As needed'),
  custom('Custom');

  final String displayName;
  const MedicationFrequency(this.displayName);

  static MedicationFrequency fromString(String value) {
    return MedicationFrequency.values.firstWhere(
      (e) => e.name == value || e.displayName == value,
      orElse: () => MedicationFrequency.onceDaily,
    );
  }
}

/// Basic personal health information
class BasicHealthInfo {
  final String? id;
  final String userId;
  final String fullName;
  final String? bloodType;
  final DateTime? dateOfBirth;
  final double? height;
  final int heightUnitIndex; // 0=cm, 1=ft, 2=inches
  final double? weight;
  final int weightUnitIndex; // 0=kg, 1=lbs
  final DateTime createdAt;
  final DateTime? updatedAt;

  BasicHealthInfo({
    this.id,
    required this.userId,
    required this.fullName,
    this.bloodType,
    this.dateOfBirth,
    this.height,
    this.heightUnitIndex = 0,
    this.weight,
    this.weightUnitIndex = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory BasicHealthInfo.fromMap(Map<String, dynamic> map, String docId) {
    return BasicHealthInfo(
      id: docId,
      userId: map['userId'] as String,
      fullName: map['fullName'] as String? ?? '',
      bloodType: map['bloodType'] as String?,
      dateOfBirth:
          map['dateOfBirth'] != null
              ? (map['dateOfBirth'] as Timestamp).toDate()
              : null,
      height: (map['height'] as num?)?.toDouble(),
      heightUnitIndex: map['heightUnitIndex'] as int? ?? 0,
      weight: (map['weight'] as num?)?.toDouble(),
      weightUnitIndex: map['weightUnitIndex'] as int? ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt:
          map['updatedAt'] != null
              ? (map['updatedAt'] as Timestamp).toDate()
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fullName': fullName,
      'bloodType': bloodType,
      'dateOfBirth':
          dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'height': height,
      'heightUnitIndex': heightUnitIndex,
      'weight': weight,
      'weightUnitIndex': weightUnitIndex,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  BasicHealthInfo copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? bloodType,
    DateTime? dateOfBirth,
    double? height,
    int? heightUnitIndex,
    double? weight,
    int? weightUnitIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BasicHealthInfo(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      bloodType: bloodType ?? this.bloodType,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      height: height ?? this.height,
      heightUnitIndex: heightUnitIndex ?? this.heightUnitIndex,
      weight: weight ?? this.weight,
      weightUnitIndex: weightUnitIndex ?? this.weightUnitIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Allergy entry
class Allergy {
  final String? id;
  final String userId;
  final String type; // 'medication' or 'food'
  final String name;
  final bool isCustom;
  final DateTime createdAt;

  Allergy({
    this.id,
    required this.userId,
    required this.type,
    required this.name,
    this.isCustom = false,
    required this.createdAt,
  });

  factory Allergy.fromMap(Map<String, dynamic> map, String docId) {
    return Allergy(
      id: docId,
      userId: map['userId'] as String,
      type: map['type'] as String,
      name: map['name'] as String,
      isCustom: map['isCustom'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'name': name,
      'isCustom': isCustom,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Allergy copyWith({
    String? id,
    String? userId,
    String? type,
    String? name,
    bool? isCustom,
    DateTime? createdAt,
  }) {
    return Allergy(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      name: name ?? this.name,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Chronic disease entry
class ChronicDisease {
  final String? id;
  final String userId;
  final String name;
  final bool isCustom;
  final DateTime createdAt;

  ChronicDisease({
    this.id,
    required this.userId,
    required this.name,
    this.isCustom = false,
    required this.createdAt,
  });

  factory ChronicDisease.fromMap(Map<String, dynamic> map, String docId) {
    return ChronicDisease(
      id: docId,
      userId: map['userId'] as String,
      name: map['name'] as String,
      isCustom: map['isCustom'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'isCustom': isCustom,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ChronicDisease copyWith({
    String? id,
    String? userId,
    String? name,
    bool? isCustom,
    DateTime? createdAt,
  }) {
    return ChronicDisease(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Medication with reminder times
class Medication {
  final String? id;
  final String userId;
  final String name;
  final double dosage;
  final String dosageUnit;
  final String frequency;
  final int? customFrequencyHours;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<DateTime> reminderTimes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Medication({
    this.id,
    required this.userId,
    required this.name,
    required this.dosage,
    required this.dosageUnit,
    required this.frequency,
    this.customFrequencyHours,
    this.startDate,
    this.endDate,
    required this.reminderTimes,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory Medication.fromMap(Map<String, dynamic> map, String docId) {
    final reminderTimesList =
        (map['reminderTimes'] as List<dynamic>?)
            ?.map((e) => (e as Timestamp).toDate())
            .toList() ??
        [];

    return Medication(
      id: docId,
      userId: map['userId'] as String,
      name: map['name'] as String,
      dosage: (map['dosage'] as num).toDouble(),
      dosageUnit: map['dosageUnit'] as String,
      frequency: map['frequency'] as String,
      customFrequencyHours: map['customFrequencyHours'] as int?,
      startDate:
          map['startDate'] != null
              ? (map['startDate'] as Timestamp).toDate()
              : null,
      endDate:
          map['endDate'] != null
              ? (map['endDate'] as Timestamp).toDate()
              : null,
      reminderTimes: reminderTimesList,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt:
          map['updatedAt'] != null
              ? (map['updatedAt'] as Timestamp).toDate()
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'dosage': dosage,
      'dosageUnit': dosageUnit,
      'frequency': frequency,
      'customFrequencyHours': customFrequencyHours,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'reminderTimes': reminderTimes.map((e) => Timestamp.fromDate(e)).toList(),
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  Medication copyWith({
    String? id,
    String? userId,
    String? name,
    double? dosage,
    String? dosageUnit,
    String? frequency,
    int? customFrequencyHours,
    DateTime? startDate,
    DateTime? endDate,
    List<DateTime>? reminderTimes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Medication(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      dosageUnit: dosageUnit ?? this.dosageUnit,
      frequency: frequency ?? this.frequency,
      customFrequencyHours: customFrequencyHours ?? this.customFrequencyHours,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Emergency contact information
class EmergencyContact {
  final String? id;
  final String userId;
  final String name;
  final String phone;
  final String? relationship;
  final DateTime createdAt;

  EmergencyContact({
    this.id,
    required this.userId,
    required this.name,
    required this.phone,
    this.relationship,
    required this.createdAt,
  });

  factory EmergencyContact.fromMap(Map<String, dynamic> map, String docId) {
    return EmergencyContact(
      id: docId,
      userId: map['userId'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      relationship: map['relationship'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'phone': phone,
      'relationship': relationship,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  EmergencyContact copyWith({
    String? id,
    String? userId,
    String? name,
    String? phone,
    String? relationship,
    DateTime? createdAt,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      relationship: relationship ?? this.relationship,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Medical note entry
class MedicalNote {
  final String? id;
  final String userId;
  final String content;
  final DateTime timestamp;
  final DateTime createdAt;

  MedicalNote({
    this.id,
    required this.userId,
    required this.content,
    required this.timestamp,
    required this.createdAt,
  });

  factory MedicalNote.fromMap(Map<String, dynamic> map, String docId) {
    return MedicalNote(
      id: docId,
      userId: map['userId'] as String,
      content: map['content'] as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  MedicalNote copyWith({
    String? id,
    String? userId,
    String? content,
    DateTime? timestamp,
    DateTime? createdAt,
  }) {
    return MedicalNote(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Combined Health Profile
class HealthProfile {
  final BasicHealthInfo? basicInfo;
  final List<Allergy> allergies;
  final List<ChronicDisease> chronicDiseases;
  final List<Medication> medications;
  final List<EmergencyContact> emergencyContacts;
  final List<MedicalNote> medicalNotes;

  HealthProfile({
    this.basicInfo,
    this.allergies = const [],
    this.chronicDiseases = const [],
    this.medications = const [],
    this.emergencyContacts = const [],
    this.medicalNotes = const [],
  });

  /// Get medication allergies
  List<Allergy> get medicationAllergies =>
      allergies.where((a) => a.type == 'medication').toList();

  /// Get food allergies
  List<Allergy> get foodAllergies =>
      allergies.where((a) => a.type == 'food').toList();

  /// Get active medications
  List<Medication> get activeMedications =>
      medications.where((m) => m.isActive).toList();
}
