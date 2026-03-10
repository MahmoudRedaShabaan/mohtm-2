import 'package:cloud_firestore/cloud_firestore.dart';
import 'daily_deed_model.dart';
import 'hijri_date_util.dart';

/// Service class for managing Daily Deed data in Firebase Firestore
class DailyDeedService {
  static const String collectionName = 'daily_deeds';
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Gets the collection reference for daily deeds
  static CollectionReference get collection {
    return _firestore.collection(collectionName);
  }

  /// Formats date as YYYY-MM-DD
  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Formats Gregorian date for display
  static String _formatGregorianDate(DateTime date) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Helper method to create initial document with default values
  static Future<void> _createInitialDoc(
    DocumentReference docRef,
    String userId,
    DateTime date,
  ) async {
    final dateStr = _formatDate(date);
    final hijriDate = HijriDateUtil.getHijriDate(date, 'en'); // Use English for statistics
    final isRamadan = HijriDateUtil.isRamadan(date);
    final shouldShowFasting = HijriDateUtil.shouldShowFasting(date);
    final hijriYear = HijriDateUtil.getCurrentHijriYear();
    final hijriMonth = HijriDateUtil.getCurrentHijriMonth();
    
    // Create fasting entry for Ramadan or specific days
    final shouldHaveFasting = isRamadan || shouldShowFasting;
    
    await docRef.set({
      'userId': userId,
      'date': dateStr,
      'gregorianDate': _formatGregorianDate(date),
      'hijriDate': hijriDate,
      'hijriMonth': hijriMonth,
      'hijriYear': hijriYear,
      'isRamadan': isRamadan,
      'prayers': {},
      'sunnahPrayers': {},
      'supplications': {},
      'learning': {
        'chapters': 0.0,
      },
      'fasting': shouldHaveFasting ? {
        'status': null,
      } : null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Fetches a single daily deed document
  ///
  /// [userId] The user's ID
  /// [date] The date to fetch the deed for
  /// Returns the DailyDeed if found, or null
  static Future<DailyDeed?> getDailyDeed(String userId, DateTime date) async {
    final dateStr = _formatDate(date);
    final docId = DailyDeed.generateId(userId, dateStr);
    
    final docSnapshot = await collection.doc(docId).get();
    
    if (docSnapshot.exists && docSnapshot.data() != null) {
      final data = docSnapshot.data()! as Map<String, dynamic>;
      data['id'] = docId;
      return DailyDeed.fromMap(data);
    }
    
    return null;
  }

  /// Creates a new daily deed document
  ///
  /// [deed] The DailyDeed to create
  /// Returns the created deed
  static Future<DailyDeed> createDailyDeed(DailyDeed deed) async {
    final docRef = collection.doc(deed.id);
    
    await docRef.set(deed.toMap());
    return deed;
  }

  /// Updates an existing daily deed document
  ///
  /// [deed] The DailyDeed to update
  /// Returns the updated deed
  static Future<DailyDeed> updateDailyDeed(DailyDeed deed) async {
    final docRef = collection.doc(deed.id);
    
    await docRef.update(deed.toMap()..remove('id')..remove('userId'));
    return deed;
  }

  /// Updates a single prayer status
  ///
  /// [userId] The user's ID
  /// [date] The date of the prayer
  /// [prayerName] The name of the prayer (e.g., 'fajr', 'dhur')
  /// [status] The new status value
  static Future<void> updatePrayerStatus({
    required String userId,
    required DateTime date,
    required String prayerName,
    required String status,
  }) async {
    final dateStr = _formatDate(date);
    final docId = DailyDeed.generateId(userId, dateStr);
    final docRef = collection.doc(docId);
    
    final updateData = {
      'prayers.$prayerName': {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final doc = await docRef.get();
    
    if (doc.exists) {
      await docRef.update(updateData);
    } else {
      // Create the document first
      final hijriDate = HijriDateUtil.getHijriDate(date, 'en'); // Use English for statistics
      final isRamadan = HijriDateUtil.isRamadan(date);
      final hijriMonth = HijriDateUtil.getCurrentHijriMonth();
      final hijriYear = HijriDateUtil.getCurrentHijriYear();
      
      await docRef.set({
        'userId': userId,
        'date': dateStr,
        'gregorianDate': _formatGregorianDate(date),
        'hijriDate': hijriDate,
        'hijriMonth': hijriMonth,
        'hijriYear': hijriYear,
        'isRamadan': isRamadan,
        'prayers': {
          prayerName: {
            'status': status,
            'updatedAt': FieldValue.serverTimestamp(),
          }
        },
        'learning': {
          'chapters': 0.0,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Updates Quran reading progress
  ///
  /// [userId] The user's ID
  /// [date] The date
  /// [chapters] The number of chapters read
  static Future<void> updateQuranProgress({
    required String userId,
    required DateTime date,
    required double chapters,
  }) async {
    final dateStr = _formatDate(date);
    final docId = DailyDeed.generateId(userId, dateStr);
    final docRef = collection.doc(docId);
    
    final updateData = {
      'learning': {
        'chapters': chapters,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final doc = await docRef.get();
    
    if (doc.exists) {
      await docRef.update(updateData);
    } else {
      await _createInitialDoc(docRef, userId, date);
    }
  }

  /// Updates fasting status
  ///
  /// [userId] The user's ID
  /// [date] The date
  /// [status] The new status ('completed' or 'missed')
  static Future<void> updateFastingStatus({
    required String userId,
    required DateTime date,
    required String status,
  }) async {
    final dateStr = _formatDate(date);
    final docId = DailyDeed.generateId(userId, dateStr);
    final docRef = collection.doc(docId);
    
    final updateData = {
      'fasting': {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final doc = await docRef.get();
    
    if (doc.exists) {
      await docRef.update(updateData);
    } else {
      await _createInitialDoc(docRef, userId, date);
    }
  }

  /// Updates sunnah prayer status
  ///
  /// [userId] The user's ID
  /// [date] The date
  /// [prayerName] The name of the sunnah prayer
  /// [status] The new status ('completed' or 'missed')
  static Future<void> updateSunnahPrayerStatus({
    required String userId,
    required DateTime date,
    required String prayerName,
    required String status,
  }) async {
    final dateStr = _formatDate(date);
    final docId = DailyDeed.generateId(userId, dateStr);
    final docRef = collection.doc(docId);
    
    final updateData = {
      'sunnahPrayers.$prayerName': {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final doc = await docRef.get();
    
    if (doc.exists) {
      await docRef.update(updateData);
    } else {
      // Create the document first
      final hijriDate = HijriDateUtil.getHijriDate(date, 'en'); // Use English for statistics
      final isRamadan = HijriDateUtil.isRamadan(date);
      final hijriMonth = HijriDateUtil.getCurrentHijriMonth();
      final hijriYear = HijriDateUtil.getCurrentHijriYear();
      
      await docRef.set({
        'userId': userId,
        'date': dateStr,
        'gregorianDate': _formatGregorianDate(date),
        'hijriDate': hijriDate,
        'hijriMonth': hijriMonth,
        'hijriYear': hijriYear,
        'isRamadan': isRamadan,
        'prayers': {},
        'sunnahPrayers': {
          prayerName: {
            'status': status,
            'updatedAt': FieldValue.serverTimestamp(),
          }
        },
        'supplications': {},
        'learning': {
          'chapters': 0.0,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Updates Eid prayer status
  ///
  /// [userId] The user's ID
  /// [date] The date
  /// [status] The new status ('completed' or 'missed')
  static Future<void> updateEidPrayerStatus({
    required String userId,
    required DateTime date,
    required String status,
  }) async {
    final dateStr = _formatDate(date);
    final docId = DailyDeed.generateId(userId, dateStr);
    final docRef = collection.doc(docId);
    
    final updateData = {
      'eidPrayer': {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final doc = await docRef.get();
    
    if (doc.exists) {
      await docRef.update(updateData);
    } else {
      // Create the document first
      final hijriDate = HijriDateUtil.getHijriDate(date, 'en');
      final isRamadan = HijriDateUtil.isRamadan(date);
      final isEid = HijriDateUtil.isEid(date);
      
      await docRef.set({
        'userId': userId,
        'date': dateStr,
        'gregorianDate': _formatGregorianDate(date),
        'hijriDate': hijriDate,
        'hijriMonth': HijriDateUtil.getCurrentHijriMonth(),
        'hijriYear': HijriDateUtil.getCurrentHijriYear(),
        'isRamadan': isRamadan,
        'prayers': {},
        'sunnahPrayers': {},
        'supplications': {},
        if (isEid)
          'eidPrayer': {
            'status': status,
          },
        'learning': {
          'chapters': 0.0,
        },
        'fasting': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Updates supplication status
  ///
  /// [userId] The user's ID
  /// [date] The date
  /// [supplicationName] The name of the supplication
  /// [status] The new status ('completed' or 'missed')
  static Future<void> updateSupplicationStatus({
    required String userId,
    required DateTime date,
    required String supplicationName,
    required String status,
  }) async {
    final dateStr = _formatDate(date);
    final docId = DailyDeed.generateId(userId, dateStr);
    final docRef = collection.doc(docId);
    
    final updateData = {
      'supplications.$supplicationName': {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final doc = await docRef.get();
    
    if (doc.exists) {
      await docRef.update(updateData);
    } else {
      // Create the document first
      final hijriDate = HijriDateUtil.getHijriDate(date, 'en'); // Use English for statistics
      final isRamadan = HijriDateUtil.isRamadan(date);
      final hijriMonth = HijriDateUtil.getCurrentHijriMonth();
      final hijriYear = HijriDateUtil.getCurrentHijriYear();
      
      await docRef.set({
        'userId': userId,
        'date': dateStr,
        'gregorianDate': _formatGregorianDate(date),
        'hijriDate': hijriDate,
        'hijriMonth': hijriMonth,
        'hijriYear': hijriYear,
        'isRamadan': isRamadan,
        'prayers': {},
        'sunnahPrayers': {},
        'supplications': {
          supplicationName: {
            'status': status,
            'updatedAt': FieldValue.serverTimestamp(),
          }
        },
        'learning': {
          'chapters': 0.0,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Updates Surah Al-Kahf status
  ///
  /// [userId] The user's ID
  /// [date] The date
  /// [status] The new status ('completed' or 'missed')
  static Future<void> updateSurahAlKahfStatus({
    required String userId,
    required DateTime date,
    required String status,
  }) async {
    final dateStr = _formatDate(date);
    final docId = DailyDeed.generateId(userId, dateStr);
    final docRef = collection.doc(docId);
    
    final updateData = {
      'surahAlKahf': {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final doc = await docRef.get();
    
    if (doc.exists) {
      await docRef.update(updateData);
    } else {
      // Create the document first
      final hijriDate = HijriDateUtil.getHijriDate(date, 'en');
      final isRamadan = HijriDateUtil.isRamadan(date);
      final hijriMonth = HijriDateUtil.getCurrentHijriMonth();
      final hijriYear = HijriDateUtil.getCurrentHijriYear();
      
      await docRef.set({
        'userId': userId,
        'date': dateStr,
        'gregorianDate': _formatGregorianDate(date),
        'hijriDate': hijriDate,
        'hijriMonth': hijriMonth,
        'hijriYear': hijriYear,
        'isRamadan': isRamadan,
        'prayers': {},
        'sunnahPrayers': {},
        'supplications': {},
        'surahAlKahf': {
          'status': status,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        'learning': {
          'chapters': 0.0,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Streams all daily deeds for a user
  ///
  /// [userId] The user's ID
  /// Returns a stream of query snapshots ordered by date descending
  static Stream<QuerySnapshot> streamUserDailyDeeds(String userId) {
    return collection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots();
  }

  /// Deletes a daily deed document
  ///
  /// [userId] The user's ID
  /// [date] The date of the deed to delete
  static Future<void> deleteDailyDeed(String userId, DateTime date) async {
    final dateStr = _formatDate(date);
    final docId = DailyDeed.generateId(userId, dateStr);
    
    await collection.doc(docId).delete();
  }
}
