/// Model for daily deeds statistics
class DailyDeedStatistics {
  final String userId;
  final int hijriYear;
  final int hijriMonth;
  final String monthName;
  final int daysInMonth;
  final bool isRamadan;
  
  // Prayer statistics (5 mandatory prayers)
  final Map<String, PrayerStat> prayerStats;
  
  // Nafl prayer statistics (tahajjud, witr, taraweeh)
  final Map<String, NaflPrayerStat> naflPrayerStats;
  
  // Sunnah statistics
  final Map<String, SunnahStat> sunnahStats;
  
  // Supplications statistics
  final Map<String, SupplicationStat> supplicationStats;
  
  // Learning statistics
  final LearningStat learningStat;
  
  // Fasting statistics
  final FastingStat fastingStat;

  DailyDeedStatistics({
    required this.userId,
    required this.hijriYear,
    required this.hijriMonth,
    required this.monthName,
    required this.daysInMonth,
    required this.isRamadan,
    required this.prayerStats,
    required this.naflPrayerStats,
    required this.sunnahStats,
    required this.supplicationStats,
    required this.learningStat,
    required this.fastingStat,
  });
}

/// Statistics for a single prayer (5 mandatory prayers)
class PrayerStat {
  final String prayerName;
  final int notPrayed;
  final int late;
  final int onTime;
  final int jamaAh;
  final int notSelected;
  
  PrayerStat({
    required this.prayerName,
    required this.notPrayed,
    required this.late,
    required this.onTime,
    required this.jamaAh,
    required this.notSelected,
  });
  
  int get total => notPrayed + late + onTime + jamaAh + notSelected;
  
  double get notPrayedPercentage => total > 0 ? (notPrayed / total) * 100 : 0;
  double get latePercentage => total > 0 ? (late / total) * 100 : 0;
  double get onTimePercentage => total > 0 ? (onTime / total) * 100 : 0;
  double get jamaAhPercentage => total > 0 ? (jamaAh / total) * 100 : 0;
  double get notSelectedPercentage => total > 0 ? (notSelected / total) * 100 : 0;
}

/// Statistics for Nafl prayers (tahajjud, witr, taraweeh) - only missed/completed
class NaflPrayerStat {
  final String prayerName;
  final int missed;
  final int completed;
  final int notSelected;
  
  NaflPrayerStat({
    required this.prayerName,
    required this.missed,
    required this.completed,
    required this.notSelected,
  });
  
  int get total => missed + completed + notSelected;
  
  double get missedPercentage => total > 0 ? (missed / total) * 100 : 0;
  double get completedPercentage => total > 0 ? (completed / total) * 100 : 0;
  double get notSelectedPercentage => total > 0 ? (notSelected / total) * 100 : 0;
}

/// Statistics for a single sunnah prayer
class SunnahStat {
  final String prayerName;
  final int missed;
  final int completed;
  final int notSelected;
  
  SunnahStat({
    required this.prayerName,
    required this.missed,
    required this.completed,
    required this.notSelected,
  });
  
  int get total => missed + completed + notSelected;
  
  double get missedPercentage => total > 0 ? (missed / total) * 100 : 0;
  double get completedPercentage => total > 0 ? (completed / total) * 100 : 0;
  double get notSelectedPercentage => total > 0 ? (notSelected / total) * 100 : 0;
}

/// Statistics for a single supplication
class SupplicationStat {
  final String supplicationName;
  final int missed;
  final int completed;
  final int notSelected;
  
  SupplicationStat({
    required this.supplicationName,
    required this.missed,
    required this.completed,
    required this.notSelected,
  });
  
  int get total => missed + completed + notSelected;
  
  double get missedPercentage => total > 0 ? (missed / total) * 100 : 0;
  double get completedPercentage => total > 0 ? (completed / total) * 100 : 0;
  double get notSelectedPercentage => total > 0 ? (notSelected / total) * 100 : 0;
}

/// Statistics for learning (Quran reading)
class LearningStat {
  final int chaptersRead;
  final Map<double, int> chapterDistribution; // chapters: count of days
  final int daysWithReading;
  final int notSelected;
  
  LearningStat({
    required this.chaptersRead,
    required this.chapterDistribution,
    required this.daysWithReading,
    required this.notSelected,
  });
  
  int get totalDays => daysWithReading + notSelected;
  
  double get averageChapters => totalDays > 0 ? chaptersRead / totalDays : 0;
}

/// Statistics for fasting
class FastingStat {
  final int completed;
  final int missed;
  final int notSelected;
  
  FastingStat({
    required this.completed,
    required this.missed,
    required this.notSelected,
  });
  
  int get total => completed + missed + notSelected;
  
  double get completedPercentage => total > 0 ? (completed / total) * 100 : 0;
  double get missedPercentage => total > 0 ? (missed / total) * 100 : 0;
  double get notSelectedPercentage => total > 0 ? (notSelected / total) * 100 : 0;
}

/// Statistics summary for display
class StatisticsSummary {
  final String category;
  final String icon;
  final int completed;
  final int total;
  
  StatisticsSummary({
    required this.category,
    required this.icon,
    required this.completed,
    required this.total,
  });
  
  double get percentage => total > 0 ? (completed / total) * 100 : 0;
}
