import 'package:cloud_firestore/cloud_firestore.dart';
import 'statistics_model.dart';

/// Service for fetching and calculating daily deeds statistics
class StatisticsService {
  final String userId;
  
  StatisticsService({required this.userId});
  
  /// Get statistics for a specific Hijri month
  Future<DailyDeedStatistics> getMonthlyStatistics(int hijriYear, int hijriMonth) async {
    // Get all daily deeds for the user
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('daily_deeds')
        .where('userId', isEqualTo: userId)
        .get();
    
    // Filter documents that match the Hijri month using hijriDate field
    final filteredDocs = snapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final hijriDate = data['hijriDate'] as String? ?? '';
      
      // Extract month name and year from hijriDate (e.g., "Ramadan 15, 1447 AH" or "Sha'ban 16, 1447 AH")
      final parts = hijriDate.trim().split(' ');
      if (parts.length >= 3) {
        // Format: "Month Day, Year AH" - parts[0] is month name, parts[2] is year
        // Or format: "16 Sha'ban 1447" - parts[1] is month name, parts[2] is year
        String monthName;
        int docYear;
        
        if (parts.length >= 4) {
          // New format: "Ramadan 15, 1447 AH"
          monthName = parts[0];
          // Remove comma from day (parts[1] is "15,")
          docYear = int.tryParse(parts[2]) ?? 0;
        } else {
          // Old format: "16 Sha'ban 1447"
          monthName = parts[1];
          docYear = int.tryParse(parts[2]) ?? 0;
        }
        
        // Convert month name to number
        final docMonth = _monthNameToNumber(monthName);
        
        return docMonth == hijriMonth && docYear == hijriYear;
      }
      
      return false;
    }).toList();
    
    // Get days in the Hijri month
    final daysInMonth = _getDaysInHijriMonth(hijriMonth, hijriYear);
    final isRamadan = hijriMonth == 9;
    
    // Initialize counters
    final prayerStats = <String, PrayerStat>{};
    final sunnahStats = <String, SunnahStat>{};
    final supplicationStats = <String, SupplicationStat>{};
    final naflPrayerStats = <String, NaflPrayerStat>{}; // For tahajjud, witr, taraweeh
    
    // Initialize regular prayer counters (5 mandatory prayers)
    final prayers = ['fajr', 'dhur', 'asr', 'maghrib', 'isa'];
    for (final prayer in prayers) {
      prayerStats[prayer] = PrayerStat(
        prayerName: prayer,
        notPrayed: 0,
        late: 0,
        onTime: 0,
        jamaAh: 0,
        notSelected: 0,
      );
    }
    
    // Initialize Nafl prayer counters (tahajjud, witr) - only missed/completed
    final naflPrayers = ['tahajjud', 'witr'];
    for (final prayer in naflPrayers) {
      naflPrayerStats[prayer] = NaflPrayerStat(
        prayerName: prayer,
        missed: 0,
        completed: 0,
        notSelected: 0,
      );
    }
    
    // Taraweeh only in Ramadan
    if (isRamadan) {
      naflPrayerStats['taraweeh'] = NaflPrayerStat(
        prayerName: 'taraweeh',
        missed: 0,
        completed: 0,
        notSelected: 0,
      );
    }
    
    // Initialize sunnah counters
    final sunnahs = ['fajr_sunnah', 'doha', 'dhur_sunnah', 'maghrib_sunnah', 'isa_sunnah'];
    for (final sunnah in sunnahs) {
      sunnahStats[sunnah] = SunnahStat(
        prayerName: sunnah,
        missed: 0,
        completed: 0,
        notSelected: 0,
      );
    }
    
    // Initialize supplication counters
    final supps = ['morning_supplications', 'evening_supplications', 'surah_al_kahf', 'eid_prayer'];
    for (final supp in supps) {
      supplicationStats[supp] = SupplicationStat(
        supplicationName: supp,
        missed: 0,
        completed: 0,
        notSelected: 0,
      );
    }
    
    // Initialize learning stats
    final chapterDistribution = <double, int>{};
    var totalChaptersRead = 0;
    var learningDays = 0;
    
    // Initialize fasting stats
    var fastingCompleted = 0;
    var fastingMissed = 0;
    
    // Process each daily deed
    for (final doc in filteredDocs) {
      final data = doc.data() as Map<String, dynamic>;
      
      // Process prayers (5 mandatory + tahajjud, witr)
      if (data['prayers'] != null) {
        final prayersData = data['prayers'] as Map<String, dynamic>;
        for (final entry in prayersData.entries) {
          final prayer = entry.key;
          final status = entry.value['status'] as String?;
          
          // Handle regular prayers (fajr, dhur, asr, maghrib, isa)
          if (prayerStats.containsKey(prayer)) {
            final current = prayerStats[prayer]!;
            switch (status) {
              case 'not_prayed':
                prayerStats[prayer] = PrayerStat(
                  prayerName: prayer,
                  notPrayed: current.notPrayed + 1,
                  late: current.late,
                  onTime: current.onTime,
                  jamaAh: current.jamaAh,
                  notSelected: current.notSelected,
                );
                break;
              case 'late':
                prayerStats[prayer] = PrayerStat(
                  prayerName: prayer,
                  notPrayed: current.notPrayed,
                  late: current.late + 1,
                  onTime: current.onTime,
                  jamaAh: current.jamaAh,
                  notSelected: current.notSelected,
                );
                break;
              case 'on_time':
                prayerStats[prayer] = PrayerStat(
                  prayerName: prayer,
                  notPrayed: current.notPrayed,
                  late: current.late,
                  onTime: current.onTime + 1,
                  jamaAh: current.jamaAh,
                  notSelected: current.notSelected,
                );
                break;
              case 'jamaah':
                prayerStats[prayer] = PrayerStat(
                  prayerName: prayer,
                  notPrayed: current.notPrayed,
                  late: current.late,
                  onTime: current.onTime,
                  jamaAh: current.jamaAh + 1,
                  notSelected: current.notSelected,
                );
                break;
            }
          }
          
          // Handle Nafl prayers (tahajjud, witr) - only missed/completed
          if (naflPrayerStats.containsKey(prayer)) {
            final current = naflPrayerStats[prayer]!;
            if (status == 'missed') {
              naflPrayerStats[prayer] = NaflPrayerStat(
                prayerName: prayer,
                missed: current.missed + 1,
                completed: current.completed,
                notSelected: current.notSelected,
              );
            } else if (status == 'completed') {
              naflPrayerStats[prayer] = NaflPrayerStat(
                prayerName: prayer,
                missed: current.missed,
                completed: current.completed + 1,
                notSelected: current.notSelected,
              );
            }
          }
        }
      }
      
      // Process sunnah prayers
      if (data['sunnahPrayers'] != null) {
        final sunnahsData = data['sunnahPrayers'] as Map<String, dynamic>;
        for (final entry in sunnahsData.entries) {
          final sunnah = entry.key;
          final status = entry.value['status'] as String?;
          
          if (sunnahStats.containsKey(sunnah)) {
            final current = sunnahStats[sunnah]!;
            if (status == 'missed') {
              sunnahStats[sunnah] = SunnahStat(
                prayerName: sunnah,
                missed: current.missed + 1,
                completed: current.completed,
                notSelected: current.notSelected,
              );
            } else if (status == 'completed') {
              sunnahStats[sunnah] = SunnahStat(
                prayerName: sunnah,
                missed: current.missed,
                completed: current.completed + 1,
                notSelected: current.notSelected,
              );
            }
          }
        }
      }
      
      // Process supplications
      if (data['supplications'] != null) {
        final suppsData = data['supplications'] as Map<String, dynamic>;
        for (final entry in suppsData.entries) {
          final supp = entry.key;
          final status = entry.value['status'] as String?;
          
          if (supplicationStats.containsKey(supp)) {
            final current = supplicationStats[supp]!;
            if (status == 'missed') {
              supplicationStats[supp] = SupplicationStat(
                supplicationName: supp,
                missed: current.missed + 1,
                completed: current.completed,
                notSelected: current.notSelected,
              );
            } else if (status == 'completed') {
              supplicationStats[supp] = SupplicationStat(
                supplicationName: supp,
                missed: current.missed,
                completed: current.completed + 1,
                notSelected: current.notSelected,
              );
            }
          }
        }
      }

      // Process Surah Al-Kahf (stored separately in the document)
      if (data['surah_al_kahf'] != null) {
        final surahData = data['surah_al_kahf'] as Map<String, dynamic>;
        final status = surahData['status'] as String?;
        final supp = 'surah_al_kahf';

        if (supplicationStats.containsKey(supp)) {
          final current = supplicationStats[supp]!;
          if (status == 'missed') {
            supplicationStats[supp] = SupplicationStat(
              supplicationName: supp,
              missed: current.missed + 1,
              completed: current.completed,
              notSelected: current.notSelected,
            );
          } else if (status == 'completed') {
            supplicationStats[supp] = SupplicationStat(
              supplicationName: supp,
              missed: current.missed,
              completed: current.completed + 1,
              notSelected: current.notSelected,
            );
          }
        }
      }

      // Process Eid Prayer (stored separately in the document)
      if (data['eidPrayer'] != null) {
        final eidData = data['eidPrayer'] as Map<String, dynamic>;
        final status = eidData['status'] as String?;
        final supp = 'eid_prayer';

        if (supplicationStats.containsKey(supp)) {
          final current = supplicationStats[supp]!;
          if (status == 'missed') {
            supplicationStats[supp] = SupplicationStat(
              supplicationName: supp,
              missed: current.missed + 1,
              completed: current.completed,
              notSelected: current.notSelected,
            );
          } else if (status == 'completed') {
            supplicationStats[supp] = SupplicationStat(
              supplicationName: supp,
              missed: current.missed,
              completed: current.completed + 1,
              notSelected: current.notSelected,
            );
          }
        }
      }
      
      // Process learning - correct data structure: learning.chapters
      if (data['learning'] != null) {
        final learningData = data['learning'] as Map<String, dynamic>;
        final chapters = learningData['chapters'] as double? ?? 0.0;
        if (chapters > 0) {
          totalChaptersRead += chapters.toInt();
          learningDays++;
          chapterDistribution[chapters] = (chapterDistribution[chapters] ?? 0) + 1;
        }
      }
      
      // Process fasting
      if (data['fasting'] != null) {
        final fastingData = data['fasting'] as Map<String, dynamic>;
        final status = fastingData['status'] as String?;
        if (status == 'completed') {
          fastingCompleted++;
        } else if (status == 'missed') {
          fastingMissed++;
        }
      }
    }
    
    // Calculate not selected for regular prayers
    for (final prayer in prayers) {
      final current = prayerStats[prayer]!;
      final selected = current.notPrayed + current.late + current.onTime + current.jamaAh;
      final notSelected = daysInMonth - selected;
      if (notSelected > 0) {
        prayerStats[prayer] = PrayerStat(
          prayerName: prayer,
          notPrayed: current.notPrayed,
          late: current.late,
          onTime: current.onTime,
          jamaAh: current.jamaAh,
          notSelected: notSelected,
        );
      }
    }
    
    // Calculate not selected for Nafl prayers
    for (final prayer in naflPrayerStats.keys) {
      final current = naflPrayerStats[prayer]!;
      final selected = current.missed + current.completed;
      final notSelected = daysInMonth - selected;
      if (notSelected > 0) {
        naflPrayerStats[prayer] = NaflPrayerStat(
          prayerName: prayer,
          missed: current.missed,
          completed: current.completed,
          notSelected: notSelected,
        );
      }
    }
    
    // Calculate not selected for sunnah
    for (final sunnah in sunnahs) {
      final current = sunnahStats[sunnah]!;
      final selected = current.missed + current.completed;
      final notSelected = daysInMonth - selected;
      if (notSelected > 0) {
        sunnahStats[sunnah] = SunnahStat(
          prayerName: sunnah,
          missed: current.missed,
          completed: current.completed,
          notSelected: notSelected,
        );
      }
    }
    
    // Calculate not selected for supplications
    for (final supp in supps) {
      final current = supplicationStats[supp]!;
      final selected = current.missed + current.completed;
      final notSelected = daysInMonth - selected;
      if (notSelected > 0) {
        supplicationStats[supp] = SupplicationStat(
          supplicationName: supp,
          missed: current.missed,
          completed: current.completed,
          notSelected: notSelected,
        );
      }
    }
    
    // Calculate learning not selected
    final learningNotSelected = (daysInMonth - learningDays).clamp(0, daysInMonth);
    
    // Calculate fasting not selected (for Ramadan or specific days)
    final showFasting = isRamadan;
    final fastingNotSelected = showFasting 
        ? (daysInMonth - fastingCompleted - fastingMissed).clamp(0, daysInMonth)
        : 0;
    
    return DailyDeedStatistics(
      userId: userId,
      hijriYear: hijriYear,
      hijriMonth: hijriMonth,
      monthName: getMonthName(hijriMonth),
      daysInMonth: daysInMonth,
      isRamadan: isRamadan,
      prayerStats: prayerStats,
      naflPrayerStats: naflPrayerStats,
      sunnahStats: sunnahStats,
      supplicationStats: supplicationStats,
      learningStat: LearningStat(
        chaptersRead: totalChaptersRead,
        chapterDistribution: chapterDistribution,
        daysWithReading: learningDays,
        notSelected: learningNotSelected,
      ),
      fastingStat: FastingStat(
        completed: fastingCompleted,
        missed: fastingMissed,
        notSelected: fastingNotSelected,
      ),
    );
  }
  
  int _monthNameToNumber(String monthName) {
    // Clean up the month name - remove any trailing punctuation
    final cleanedMonth = monthName.replaceAll(RegExp(r'[^a-zA-Zا-ي]'), '');
    
    // English month names
    final englishMonthMap = {
      'Muharram': 1,
      'Safar': 2,
      "Rabi' al-awwal": 3,
      "Rabi' al-thani": 4,
      'Rabi al-awwal': 3,
      'Rabi al-thani': 4,
      'Jumada al-awwal': 5,
      'Jumada al-thani': 6,
      'Rajab': 7,
      "Sha'ban": 8,
      'Shaban': 8,
      'Ramadan': 9,
      'Ramadhan': 9,
      'Shawwal': 10,
      'Dhu al-Qadah': 11,
      'Dhu al-Hijjah': 12,
      'Dhul Qadah': 11,
      'Dhul Hijjah': 12,
    };
    
    // Arabic month names
    final arabicMonthMap = {
      'محرم': 1,
      'صفر': 2,
      'ربيع الأول': 3,
      'ربيع الثاني': 4,
      'جمادى الأول': 5,
      'جمادى الثاني': 6,
      'رجب': 7,
      'شعبان': 8,
      'رمضان': 9,
      'شوال': 10,
      'ذو القعدة': 11,
      'ذو الحجة': 12,
    };
    
    // Try exact match first (case insensitive for English)
    final lowerMonth = cleanedMonth.toLowerCase();
    for (final entry in englishMonthMap.entries) {
      if (entry.key.toLowerCase() == lowerMonth) {
        return entry.value;
      }
    }
    
    // Try Arabic exact match
    for (final entry in arabicMonthMap.entries) {
      if (entry.key == cleanedMonth) {
        return entry.value;
      }
    }
    
    // Try partial match for English
    for (final entry in englishMonthMap.entries) {
      if (entry.key.toLowerCase().contains(lowerMonth) || 
          lowerMonth.contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    
    // Try partial match for Arabic
    for (final entry in arabicMonthMap.entries) {
      if (cleanedMonth.contains(entry.key) || entry.key.contains(cleanedMonth)) {
        return entry.value;
      }
    }
    
    return 0; // Return 0 for unknown months
  }
  
  int _getDaysInHijriMonth(int month, int year) {
    // Ensure month is between 1 and 12
    final validMonth = month.clamp(1, 12);
    final monthLengths = [30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 29];
    
    // Dhu al-Hijjah is 30 in leap years
    if (validMonth == 12) {
      // Leap year every ~30 years
      final isLeapYear = (year % 30 == 2 || year % 30 == 5 || year % 30 == 7 || 
                         year % 30 == 10 || year % 30 == 13 || year % 30 == 16 || 
                         year % 30 == 18 || year % 30 == 21 || year % 30 == 24 || 
                         year % 30 == 26 || year % 30 == 29);
      return isLeapYear ? 30 : 29;
    }
    
    return monthLengths[validMonth - 1];
  }
  
  String getMonthName(int month) {
    final monthNames = [
      'Muharram', 'Safar', "Rabi' al-awwal", "Rabi' al-thani",
      'Jumada al-awwal', 'Jumada al-thani', 'Rajab', "Sha'ban",
      'Ramadan', 'Shawwal', 'Dhu al-Qadah', 'Dhu al-Hijjah'
    ];
    // Ensure month is between 1 and 12
    final validMonth = month.clamp(1, 12);
    return monthNames[validMonth - 1];
  }
}
