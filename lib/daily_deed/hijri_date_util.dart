import 'package:intl/intl.dart';

/// Utility class for Hijri date conversions
/// Uses an accurate algorithm for Hijri date calculation
class HijriDateUtil {
  /// Hijri month names in English and Arabic
  static const Map<int, List<String>> _hijriMonths = {
    1: ['Muharram', 'محرّم'],
    2: ['Safar', 'صفر'],
    3: ['Rabi\' al-awwal', 'ربيع الأول'],
    4: ['Rabi\' al-thani', 'ربيع الثاني'],
    5: ['Jumada al-awwal', 'جمادى الأول'],
    6: ['Jumada al-thani', 'جمادى الثاني'],
    7: ['Rajab', 'رجب'],
    8: ['Sha\'ban', 'شعبان'],
    9: ['Ramadan', 'رمضان'],
    10: ['Shawwal', 'شوّال'],
    11: ['Dhu al-Qadah', 'ذو القعدة'],
    12: ['Dhu al-Hijjah', 'ذو الحجة'],
  };

  /// Hijri month lengths (Umm al-Qura calendar)
  static const List<int> _hijriMonthLengths = [30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 29];

  /// Reference: February 6, 2026 = 18 Sha'ban 1447 AH (corrected based on actual calendar)
  /// This means January 1, 2026 = approximately Rajab 12, 1447 AH
  static const int _refYear = 2026;
  static const int _refMonth = 2;  // February
  static const int _refDay = 6;    // 6
  static const int _refHijriYear = 1447;
  static const int _refHijriMonth = 8; // Sha'ban
  static const int _refHijriDay = 18;

  /// Calculate days from start of Hijri year to the reference date
  static int _getDaysToRefStart() {
    var days = _refHijriDay;
    for (var i = 1; i < _refHijriMonth; i++) {
      days += _hijriMonthLengths[i - 1];
    }
    return days;
  }

  /// Accurate Hijri date calculation
  static String getHijriDate(DateTime date, [String locale = 'ar']) {
    // Days since epoch (Hijri year 1447)
    final refDate = DateTime(_refYear, _refMonth, _refDay);
    final daysSinceRef = date.difference(refDate).inDays;
    
    // Days from start of Hijri 1447 to reference date
    final daysToRefStart = _getDaysToRefStart();
    
    // Total days from Hijri epoch (Muharram 1, 1447)
    var totalDaysFromEpoch = daysToRefStart + daysSinceRef;
    
    // Calculate Hijri year
    var hijriYear = _refHijriYear;
    if (totalDaysFromEpoch < 1) {
      // Before reference date
      while (totalDaysFromEpoch <= 0) {
        hijriYear--;
        totalDaysFromEpoch += 354; // Standard Hijri year
      }
    } else {
      // At or after reference date
      while (totalDaysFromEpoch > 354) {
        totalDaysFromEpoch -= 354;
        hijriYear++;
      }
    }
    
    // Find Hijri month and day
    var remainingDays = totalDaysFromEpoch.toInt();
    var hijriMonth = 1;
    var hijriDay = remainingDays;
    
    for (var i = 0; i < _hijriMonthLengths.length; i++) {
      if (hijriDay <= _hijriMonthLengths[i]) {
        hijriMonth = i + 1;
        break;
      }
      hijriDay -= _hijriMonthLengths[i];
    }
    
    final monthNames = _hijriMonths[hijriMonth]!;
    final monthName = locale == 'ar' ? monthNames[1] : monthNames[0];
    
    return '$monthName $hijriDay, $hijriYear AH';
  }

  /// Checks if a given date is a day to show fasting section
  /// Shows on:
  /// - Day 9 of Dhu al-Hijjah (Day of Arafah)
  /// - Days 13, 14, 15 of any Hijri month (Tashreeq days)
  static bool shouldShowFasting(DateTime date) {
    final hijriDate = getHijriDate(date, 'en');
    
    // Extract the day
    final dayMatch = RegExp(r'(\d+),\s*\d+').firstMatch(hijriDate);
    if (dayMatch == null) return false;
    final day = int.tryParse(dayMatch.group(1) ?? '') ?? 0;
    
    // Check for days 13, 14, 15 of any month
    if (day >= 13 && day <= 15) {
      return true;
    }
    
    // Check for day 9 of Dhu al-Hijjah (Arafah)
    if (hijriDate.contains('Dhu al-Hijjah') && day == 9) {
      return true;
    }
    
    return false;
  }

  /// Checks if a given date is Eid (Eid al-Fitr or Eid al-Adha)
  /// Returns true for:
  /// - 1 Shawwal (Eid al-Fitr)
  /// - 10 Dhu al-Hijjah (Eid al-Adha)
  static bool isEid(DateTime date) {
    final hijriDate = getHijriDate(date, 'en');
    
    // Extract the day
    final dayMatch = RegExp(r'(\d+),\s*\d+').firstMatch(hijriDate);
    if (dayMatch == null) return false;
    final day = int.tryParse(dayMatch.group(1) ?? '') ?? 0;
    
    // Check for Eid al-Fitr (1 Shawwal)
    if (hijriDate.contains('Shawwal') && day == 1) {
      return true;
    }
    
    // Check for Eid al-Adha (10 Dhu al-Hijjah)
    if (hijriDate.contains('Dhu al-Hijjah') && day == 10) {
      return true;
    }
    
    return false;
  }

  /// Checks if a given date falls during Ramadan
  static bool isRamadan(DateTime date) {
    final hijriDate = getHijriDate(date, 'en');
    return hijriDate.contains('Ramadan');
  }

  /// Gets the current Hijri year
  static int getCurrentHijriYear() {
    final now = DateTime.now();
    final hijriDate = getHijriDate(now, 'en');
    final yearMatch = RegExp(r'(\d+)\s*AH').firstMatch(hijriDate);
    return int.parse(yearMatch?.group(1) ?? '1447');
  }

  /// Gets the current Hijri month (1-12)
  static int getCurrentHijriMonth() {
    final now = DateTime.now();
    return _calculateHijriMonth(now.year, now.month, now.day);
  }

  /// Gets the current Hijri day (1-30)
  static int getCurrentHijriDay() {
    final now = DateTime.now();
    return _calculateHijriDay(now.year, now.month, now.day);
  }

  static int _calculateHijriMonth(int year, int month, int day) {
    final refDate = DateTime(_refYear, _refMonth, _refDay);
    final currentDate = DateTime(year, month, day);
    final daysSinceRef = currentDate.difference(refDate).inDays;
    
    final daysToRefStart = _getDaysToRefStart();
    var totalDaysFromEpoch = daysToRefStart + daysSinceRef;
    
    var hijriYear = _refHijriYear;
    if (totalDaysFromEpoch < 1) {
      while (totalDaysFromEpoch <= 0) {
        hijriYear--;
        totalDaysFromEpoch += 354;
      }
    } else {
      while (totalDaysFromEpoch > 354) {
        totalDaysFromEpoch -= 354;
        hijriYear++;
      }
    }
    
    var hijriDay = totalDaysFromEpoch.toInt();
    
    for (var i = 0; i < _hijriMonthLengths.length; i++) {
      if (hijriDay <= _hijriMonthLengths[i]) {
        return i + 1;
      }
      hijriDay -= _hijriMonthLengths[i];
    }
    return 12;
  }

  static int _calculateHijriDay(int year, int month, int day) {
    final refDate = DateTime(_refYear, _refMonth, _refDay);
    final currentDate = DateTime(year, month, day);
    final daysSinceRef = currentDate.difference(refDate).inDays;
    
    final daysToRefStart = _getDaysToRefStart();
    var totalDaysFromEpoch = daysToRefStart + daysSinceRef;
    
    var hijriYear = _refHijriYear;
    if (totalDaysFromEpoch < 1) {
      while (totalDaysFromEpoch <= 0) {
        hijriYear--;
        totalDaysFromEpoch += 354;
      }
    } else {
      while (totalDaysFromEpoch > 354) {
        totalDaysFromEpoch -= 354;
        hijriYear++;
      }
    }
    
    var hijriDay = totalDaysFromEpoch.toInt();
    
    for (var i = 0; i < _hijriMonthLengths.length; i++) {
      if (hijriDay <= _hijriMonthLengths[i]) {
        return hijriDay;
      }
      hijriDay -= _hijriMonthLengths[i];
    }
    return 30;
  }

  /// Gets a formatted Gregorian date string
  static String getGregorianDate(DateTime date, [String locale = 'ar']) {
    final days = {
      'en': ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
      'ar': ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'],
    };
    final months = {
      'en': ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
      'ar': ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'],
    };
    
    final dayNames = days[locale] ?? days['en']!;
    final monthNames = months[locale] ?? months['en']!;
    
    return '${dayNames[date.weekday - 1]}, ${monthNames[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Navigates to a specific date
  static DateTime navigateDate(DateTime currentDate, int days) {
    return currentDate.add(Duration(days: days));
  }

  /// Gets 3 days from now as the maximum date
  static DateTime getMaxDate() {
    return DateTime.now().add(const Duration(days: 3));
  }

  /// Checks if a date is in the future (beyond 3 days)
  static bool isFuture(DateTime date) {
    final now = DateTime.now();
    final maxDate = getMaxDate();
    return date.isAfter(maxDate);
  }

  /// Checks if a date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// Gets the minimum allowed date (January 1, 2026 as per spec)
  static DateTime getMinDate() {
    return DateTime(2026, 1, 1);
  }

  /// Validates if a date is within allowed range
  static bool isDateValid(DateTime date) {
    final minDate = getMinDate();
    final maxDate = getMaxDate();
    return date.isAfter(minDate.subtract(const Duration(days: 1))) && 
           date.isBefore(maxDate.add(const Duration(days: 1)));
  }
}
