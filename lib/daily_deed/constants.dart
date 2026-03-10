import 'package:flutter/material.dart';

/// Color constants for Daily Deed statuses
class DeedColors {
  static const Color notPrayed = Colors.grey;
  static const Color late = Color(0xFFFFA000);
  static const Color onTime = Color(0xFF4CAF50);
  static const Color jamaAh = Color(0xFF2196F3);
  static const Color missed = Color(0xFFF44336);
  static const Color completed = Color(0xFF4CAF50);
  static const Color primary = Color.fromARGB(255, 80, 40, 120);
  
  // Section colors
  static const Color prayerSection = Color(0xFFE3F2FD);
  static const Color learningSection = Color(0xFFFFF3E0);
  static const Color fastingSection = Color(0xFFE8F5E9);
  
  // Background colors
  static const Color cardBackground = Colors.white;
  static const Color pageBackground = Color(0xFFF5F5F5);
}

/// Icon constants for Daily Deed statuses
class DeedIcons {
  static const Icon notPrayed = Icon(Icons.close, color: Colors.grey);
  static const Icon late = Icon(Icons.access_time, color: Color(0xFFFFA000));
  static const Icon onTime = Icon(Icons.check_circle, color: Color(0xFF4CAF50));
  static const Icon jamaAh = Icon(Icons.people, color: Color(0xFF2196F3));
  static const Icon missed = Icon(Icons.cancel, color: Color(0xFFF44336));
  static const Icon completed = Icon(Icons.check_circle, color: Color(0xFF4CAF50));
}

/// Prayer name keys
class PrayerNames {
  static const String fajr = 'fajr';
  static const String dhur = 'dhur';
  static const String asr = 'asr';
  static const String maghrib = 'maghrib';
  static const String isa = 'isa';
  static const String tahajjud = 'tahajjud';
  static const String witr = 'witr';
  static const String taraweeh = 'taraweeh';
  
  // Sunnah prayers
  static const String fajrSunnah = 'fajr_sunnah';
  static const String doha = 'doha';
  static const String dhurSunnah = 'dhur_sunnah';
  static const String maghribSunnah = 'maghrib_sunnah';
  static const String isaSunnah = 'isa_sunnah';
  // Supplications
  static const String morningSupplications = 'morning_supplications';
  static const String eveningSupplications = 'evening_supplications';
  
  // Surah Al-Kahf (only on Fridays)
  static const String surahAlKahf = 'surah_al_kahf';
  
  // Eid Prayer (only on Eid days)
  static const String eidPrayer = 'eid_prayer';
}

/// List of all Fard prayers
const List<String> fardPrayers = [
  PrayerNames.fajr,
  PrayerNames.dhur,
  PrayerNames.asr,
  PrayerNames.maghrib,
  PrayerNames.isa,
];

/// List of all Nafl prayers
const List<String> naflPrayers = [
  PrayerNames.tahajjud,
  PrayerNames.witr,
  PrayerNames.taraweeh,
];

/// List of all Sunnah prayers
const List<String> sunnahPrayers = [
  PrayerNames.fajrSunnah,
  PrayerNames.doha,
  PrayerNames.dhurSunnah,
  PrayerNames.maghribSunnah,
  PrayerNames.isaSunnah,
];

/// List of all Supplications
const List<String> supplications = [
  PrayerNames.morningSupplications,
  PrayerNames.eveningSupplications,
];

/// All prayers list
const List<String> allPrayers = [
  PrayerNames.fajr,
  PrayerNames.dhur,
  PrayerNames.asr,
  PrayerNames.maghrib,
  PrayerNames.isa,
  PrayerNames.tahajjud,
  PrayerNames.witr,
  PrayerNames.taraweeh,
];

/// Quran chapter options for the dropdown
const List<double> quranChapterOptions = [
  0.25,
  0.5,
  0.75,
  1.0,
  2.0,
  3.0,
  4.0,
  5.0,
];
