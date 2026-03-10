import 'package:cloud_firestore/cloud_firestore.dart';
import 'hijri_date_util.dart';

/// Enum for Fard (obligatory) prayer statuses
enum PrayerStatus {
  notPrayed('not_prayed'),
  late('late'),
  onTime('on_time'),
  jamaAh('jamaah');

  final String value;
  const PrayerStatus(this.value);
}

/// Enum for Nafl (voluntary) prayer statuses
enum NaflPrayerStatus {
  missed('missed'),
  completed('completed');

  final String value;
  const NaflPrayerStatus(this.value);
}

/// Represents a single prayer entry with its status and update timestamp
class PrayerEntry {
  final String? status;
  final DateTime? updatedAt;

  PrayerEntry({
    this.status,
    this.updatedAt,
  });

  factory PrayerEntry.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return PrayerEntry();
    }
    return PrayerEntry(
      status: map['status'] as String?,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'updatedAt': updatedAt,
    };
  }
}

/// Represents Quran learning progress
class QuranEntry {
  final double chapters;
  final DateTime? updatedAt;

  QuranEntry({
    required this.chapters,
    this.updatedAt,
  });

  factory QuranEntry.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return QuranEntry(chapters: 0.0);
    }
    return QuranEntry(
      chapters: (map['chapters'] as num?)?.toDouble() ?? 0.0,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chapters': chapters,
      'updatedAt': updatedAt,
    };
  }
}

/// Represents fasting status
class FastingEntry {
  final String? status;
  final DateTime? updatedAt;

  FastingEntry({
    this.status,
    this.updatedAt,
  });

  factory FastingEntry.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return FastingEntry();
    }
    return FastingEntry(
      status: map['status'] as String?,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'updatedAt': updatedAt,
    };
  }
}

/// Main Daily Deed model representing a user's daily religious activities
class DailyDeed {
  final String id;
  final String userId;
  final DateTime date;
  final String gregorianDate;
  final String hijriDate;
  final bool isRamadan;
  final Map<String, PrayerEntry> prayers;
  final Map<String, PrayerEntry> sunnahPrayers;
  final Map<String, PrayerEntry> supplications;
  final PrayerEntry? surahAlKahf;
  final PrayerEntry? eidPrayer;
  final QuranEntry learning;
  final FastingEntry? fasting;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DailyDeed({
    required this.id,
    required this.userId,
    required this.date,
    required this.gregorianDate,
    required this.hijriDate,
    required this.isRamadan,
    required this.prayers,
    required this.sunnahPrayers,
    required this.supplications,
    this.surahAlKahf,
    this.eidPrayer,
    required this.learning,
    this.fasting,
    this.createdAt,
    this.updatedAt,
  });

  /// Generates a unique document ID based on user ID and date
  static String generateId(String userId, String date) {
    return '${userId}_$date';
  }

  /// Creates a new DailyDeed with default values for a given date
  static DailyDeed createNew({
    required String userId,
    required DateTime date,
    required String gregorianDate,
    required String hijriDate,
    required bool isRamadan,
  }) {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    
    final Map<String, PrayerEntry> defaultPrayers = {
      'fajr': PrayerEntry(status: PrayerStatus.notPrayed.value),
      'dhur': PrayerEntry(status: PrayerStatus.notPrayed.value),
      'asr': PrayerEntry(status: PrayerStatus.notPrayed.value),
      'maghrib': PrayerEntry(status: PrayerStatus.notPrayed.value),
      'isa': PrayerEntry(status: PrayerStatus.notPrayed.value),
      'tahajjud': PrayerEntry(status: NaflPrayerStatus.missed.value),
      'witr': PrayerEntry(status: NaflPrayerStatus.missed.value),
      'taraweeh': PrayerEntry(),
    };

    // Default sunnah prayers (all null - user will update)
    final Map<String, PrayerEntry> defaultSunnahPrayers = {
      'fajr_sunnah': PrayerEntry(),
      'doha': PrayerEntry(),
      'dhur_sunnah': PrayerEntry(),
      'maghrib_sunnah': PrayerEntry(),
      'isa_sunnah': PrayerEntry(),
    };

    // Default supplications (all null - user will update)
    final Map<String, PrayerEntry> defaultSupplications = {
      'morning_supplications': PrayerEntry(),
      'evening_supplications': PrayerEntry(),
    };

    final shouldHaveFasting = isRamadan;
    
    // Check if it's Eid day
    final isEid = HijriDateUtil.isEid(date);

    return DailyDeed(
      id: generateId(userId, dateStr),
      userId: userId,
      date: date,
      gregorianDate: gregorianDate,
      hijriDate: hijriDate,
      isRamadan: isRamadan,
      prayers: defaultPrayers,
      sunnahPrayers: defaultSunnahPrayers,
      supplications: defaultSupplications,
      surahAlKahf: null,
      eidPrayer: isEid ? PrayerEntry() : null,
      learning: QuranEntry(chapters: 0.0),
      fasting: shouldHaveFasting ? FastingEntry() : null,
    );
  }

  factory DailyDeed.fromMap(Map<String, dynamic> map) {
    final dateStr = map['date'] as String;
    final userId = map['userId'] as String;
    
    final prayersMap = <String, PrayerEntry>{};
    if (map['prayers'] is Map) {
      (map['prayers'] as Map<String, dynamic>).forEach((key, value) {
        prayersMap[key] = PrayerEntry.fromMap(value as Map<String, dynamic>?);
      });
    }

    final sunnahPrayersMap = <String, PrayerEntry>{};
    if (map['sunnahPrayers'] is Map) {
      (map['sunnahPrayers'] as Map<String, dynamic>).forEach((key, value) {
        sunnahPrayersMap[key] = PrayerEntry.fromMap(value as Map<String, dynamic>?);
      });
    }

    final supplicationsMap = <String, PrayerEntry>{};
    if (map['supplications'] is Map) {
      (map['supplications'] as Map<String, dynamic>).forEach((key, value) {
        supplicationsMap[key] = PrayerEntry.fromMap(value as Map<String, dynamic>?);
      });
    }

    return DailyDeed(
      id: map['id'] ?? generateId(userId, dateStr),
      userId: userId,
      date: DateTime.parse(dateStr),
      gregorianDate: map['gregorianDate'] ?? '',
      hijriDate: map['hijriDate'] ?? '',
      isRamadan: map['isRamadan'] ?? false,
      prayers: prayersMap,
      sunnahPrayers: sunnahPrayersMap,
      supplications: supplicationsMap,
      surahAlKahf: map['surahAlKahf'] != null 
          ? PrayerEntry.fromMap(map['surahAlKahf'] as Map<String, dynamic>?)
          : null,
      eidPrayer: map['eidPrayer'] != null 
          ? PrayerEntry.fromMap(map['eidPrayer'] as Map<String, dynamic>?)
          : null,
      learning: QuranEntry.fromMap(map['learning'] as Map<String, dynamic>?),
      fasting: map['fasting'] != null 
          ? FastingEntry.fromMap(map['fasting'] as Map<String, dynamic>?)
          : null,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    final prayersMap = <String, dynamic>{};
    prayers.forEach((key, value) {
      prayersMap[key] = value.toMap();
    });

    return {
      'id': id,
      'userId': userId,
      'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'gregorianDate': gregorianDate,
      'hijriDate': hijriDate,
      'isRamadan': isRamadan,
      'prayers': prayersMap,
      'sunnahPrayers': sunnahPrayers.map((key, value) => MapEntry(key, value.toMap())),
      'supplications': supplications.map((key, value) => MapEntry(key, value.toMap())),
      'surahAlKahf': surahAlKahf?.toMap(),
      'eidPrayer': eidPrayer?.toMap(),
      'learning': learning.toMap(),
      'fasting': fasting?.toMap(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Creates a copy with optional updated fields
  DailyDeed copyWith({
    Map<String, PrayerEntry>? prayers,
    Map<String, PrayerEntry>? sunnahPrayers,
    Map<String, PrayerEntry>? supplications,
    PrayerEntry? surahAlKahf,
    PrayerEntry? eidPrayer,
    QuranEntry? learning,
    FastingEntry? fasting,
    DateTime? updatedAt,
  }) {
    return DailyDeed(
      id: id,
      userId: userId,
      date: date,
      gregorianDate: gregorianDate,
      hijriDate: hijriDate,
      isRamadan: isRamadan,
      prayers: prayers ?? this.prayers,
      sunnahPrayers: sunnahPrayers ?? this.sunnahPrayers,
      supplications: supplications ?? this.supplications,
      surahAlKahf: surahAlKahf ?? this.surahAlKahf,
      eidPrayer: eidPrayer ?? this.eidPrayer,
      learning: learning ?? this.learning,
      fasting: fasting ?? this.fasting,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
