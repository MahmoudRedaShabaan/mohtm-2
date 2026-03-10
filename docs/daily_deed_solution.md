# Daily Deed Feature - Solution Architecture

## Overview
This document outlines the recommended architecture for implementing the Daily Deed feature in the Mohtm app.

## 1. Firebase Firestore Structure

### Collection Structure
```
daily_deeds/{deedId}
```

### Document Structure for Each Day
```json
{
  "userId": "user123",
  "date": "2026-02-05",
  "gregorianDate": "Thursday, February 5, 2026",
  "hijriDate": "16 Sha'ban 1447",
  "isRamadan": false,
  "prayers": {
    "fajr": {
      "status": "not_prayed",
      "updatedAt": Timestamp
    },
    "dhur": {
      "status": "not_prayed",
      "updatedAt": Timestamp
    },
    "asr": {
      "status": "not_prayed",
      "updatedAt": Timestamp
    },
    "maghrib": {
      "status": "not_prayed",
      "updatedAt": Timestamp
    },
    "isa": {
      "status": "missed",
      "updatedAt": Timestamp
    },
    "tahajjud": {
      "status": "missed",
      "updatedAt": Timestamp
    },
    "witr": {
      "status": "missed",
      "updatedAt": Timestamp
    },
    "taraweeh": {
      "status": null,
      "updatedAt": Timestamp
    }
  },
  "learning": {
    "readQuran": {
      "chapters": 0.0,
      "updatedAt": Timestamp
    }
  },
  "fasting": {
    "ramadanFasting": {
      "status": null,
      "updatedAt": Timestamp
    }
  },
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

### Document ID Format
- Format: `{userId}_{date}` (e.g., `abc123_2026-02-05`)
- This allows easy querying by user and date

### Firestore Indexes (Recommended)
```json
{
  "collectionGroup": "daily_deeds",
  "queryScope": "COLLECTION",
  "fields": [
    { "fieldPath": "userId", "order": "ASCENDING" },
    { "fieldPath": "date", "order": "DESCENDING" }
  ]
}
```

## 2. Data Models

### Prayer Status Enum
```dart
// For Fajr, Dhur, Asr, Maghrib, Isa
enum PrayerStatus {
  notPrayed,
  late,
  onTime,
  jamaAh,
}

// For Isa, Tahajjud, Witr, Taraweeh
enum NaflPrayerStatus {
  missed,
  completed,
}
```

### DailyDeed Model Class
```dart
class DailyDeed {
  final String id;
  final String userId;
  final DateTime date;
  final String gregorianDate;
  final String hijriDate;
  final bool isRamadan;
  final Map<String, PrayerEntry> prayers;
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
    required this.learning,
    this.fasting,
    this.createdAt,
    this.updatedAt,
  });

  static String generateId(String userId, String date) {
    return '${userId}_$date';
  }
}
```

## 3. Recommended File Structure

```
lib/
├── daily_deed/
│   ├── daily_deed_page.dart
│   ├── daily_deed_model.dart
│   ├── daily_deed_service.dart
│   ├── components/
│   │   ├── date_header.dart
│   │   ├── prayer_section.dart
│   │   ├── learning_section.dart
│   │   ├── fasting_section.dart
│   │   └── prayer_popup.dart
│   └── utils/
│       ├── hijri_date_util.dart
│       └── constants.dart
```

## 4. Page Flow

### Navigation Path
- Sidebar → Tasks → **Daily Deed** (new item)

### Default View
- Current date selected
- Date picker available to navigate between dates
- Range: 1-1-2026 to tomorrow

## 5. UI Components

### A. Date Header
- Current day highlighted
- Gregorian date display
- Hijri date display
- Arrow buttons for date navigation

### B. Prayer Section
```
Row 1: Fajr | Dhur | Asr | Maghrib | Isa
Row 2: Tahajjud | Witr | Taraweeh (Ramadan only)
```

Each prayer card shows:
- Prayer name (localized)
- Current status with color and icon
- Clickable to update

### C. Learning Section
- "Read Quran" card
- Dropdown with chapters: [0.25, 0.5, 0.75, 1, 2, 3, 4, 5]
- Visual indicator of completion

### D. Fasting Section (Ramadan only)
- "Ramadan Fasting" card
- Status: Missed / Completed

## 6. Popup Dialogs

### Prayer Update Popup (4 options)
- **Not Prayed** - Gray color, X icon
- **Late** - Yellow color, Clock icon
- **On Time** - Green color, Check icon
- **In Jamaah** - Blue color, People icon

### Nafl Prayer Update Popup (2 options)
- **Missed** - Red color, X icon
- **Completed** - Green color, Check icon

### Quran Progress Popup
- Dropdown with values
- Icon changes with selection
- Color indicator

### Fasting Popup (Ramadan)
- Missed / Completed options

## 7. Localization Keys to Add

### app_ar.arb
```json
{
  "dailyDeed": "العمل اليومي",
  "prayers": "الصلوات",
  "fajr": "الفجر",
  "dhur": "الظهر",
  "asr": "العصر",
  "maghrib": "المغرب",
  "isa": "العشاء",
  "tahajjud": "التهجد",
  "witr": "الوتر",
  "taraweeh": "التراويح",
  "learning": "التعلم",
  "readQuran": "قراءة القرآن",
  "fasting": "الصيام",
  "ramadanFasting": "صيام رمضان",
  "notPrayed": "لم يصل",
  "late": "متأخر",
  "onTime": "في الوقت",
  "inJamaah": "جماعة",
  "missed": "فائت",
  "completed": "تم",
  "chapters": "أجزاء",
  "selectChapters": "اختر الأجزاء"
}
```

### app_en.arb
```json
{
  "dailyDeed": "Daily Deed",
  "prayers": "Prayers",
  "fajr": "Fajr",
  "dhur": "Dhur",
  "asr": "Asr",
  "maghrib": "Maghrib",
  "isa": "Isha",
  "tahajjud": "Tahajjud",
  "witr": "Witr",
  "taraweeh": "Taraweeh",
  "learning": "Learning",
  "readQuran": "Read Quran",
  "fasting": "Fasting",
  "ramadanFasting": "Ramadan Fasting",
  "notPrayed": "Not Prayed",
  "late": "Late",
  "onTime": "On Time",
  "inJamaah": "In Jamaah",
  "missed": "Missed",
  "completed": "Completed",
  "chapters": "Chapters",
  "selectChapters": "Select Chapters"
}
```

## 8. Status Colors

```dart
class DeedColors {
  static const Color notPrayed = Colors.grey;
  static const Color late = Color(0xFFFFA000);
  static const Color onTime = Color(0xFF4CAF50);
  static const Color jamaAh = Color(0xFF2196F3);
  static const Color missed = Color(0xFFF44336);
  static const Color completed = Color(0xFF4CAF50);
}
```

## 9. Icons Recommendation

```dart
class DeedIcons {
  static const Icon notPrayed = Icon(Icons.close, color: Colors.grey);
  static const Icon late = Icon(Icons.access_time, color: Colors.amber);
  static const Icon onTime = Icon(Icons.check_circle, color: Colors.green);
  static const Icon jamaAh = Icon(Icons.people, color: Colors.blue);
  static const Icon missed = Icon(Icons.cancel, color: Colors.red);
  static const Icon completed = Icon(Icons.check_circle, color: Colors.green);
}
```

## 10. Implementation Steps

### Phase 1: Data Layer
1. Add localization keys
2. Create data models
3. Create Firebase service class
4. Add date utilities (Hijri conversion)

### Phase 2: UI Components
1. Create date header component
2. Create prayer section cards
3. Create learning section
4. Create fasting section (conditional)
5. Create popup dialogs

### Phase 3: Integration
1. Create main DailyDeedPage
2. Add navigation from sidebar
3. Connect to Firebase
4. Handle date navigation

### Phase 4: Testing & Refinement
1. Test with different dates
2. Test Ramadan mode
3. Test localization
4. Performance optimization

## 11. Dependencies

No new dependencies needed. Using existing:
- `cloud_firestore` for data storage
- `flutter_localizations` for RTL support
- Existing localization system

## 12. Sample Code Snippets

### Firebase Service Method
```dart
Future<void> updatePrayerStatus({
  required String userId,
  required String date,
  required String prayer,
  required String status,
}) async {
  final docId = DailyDeed.generateId(userId, date);
  final docRef = FirebaseFirestore.instance.collection('daily_deeds').doc(docId);

  final doc = await docRef.get();

  if (doc.exists) {
    await docRef.update({
      'prayers.$prayer': {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      'updatedAt': FieldValue.serverTimestamp(),
    });
  } else {
    await docRef.set({
      'userId': userId,
      'date': date,
      'prayers': {
        prayer: {
          'status': status,
          'updatedAt': FieldValue.serverTimestamp(),
        }
      },
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

Stream<QuerySnapshot> getUserDailyDeeds(String userId) {
  return FirebaseFirestore.instance
      .collection('daily_deeds')
      .where('userId', isEqualTo: userId)
      .orderBy('date', descending: true)
      .snapshots();
}
```

## 13. Benefits of This Structure

1. **Top-level collection** - No nesting under users, cleaner and more scalable
2. **Document ID format** - Easy to query by user and date
3. **Minimal data loading** - Only load the specific date's data
4. **Separation of concerns** - Daily deeds independent from user profile
5. **Query optimization** - Can efficiently query user's all deeds

## 14. Next Steps

1. Review this solution document
2. Confirm structure is acceptable
3. Begin implementation

---

**Document Version:** 1.1
**Updated:** February 5, 2026
