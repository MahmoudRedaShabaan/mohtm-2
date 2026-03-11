import 'package:cloud_firestore/cloud_firestore.dart';
import 'custom_daily_deed_model.dart';

/// Service class for managing Custom Daily Deeds in Firebase Firestore
class CustomDailyDeedService {
  static const String collectionName = 'custom_daily_deeds';
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Gets the collection reference for custom daily deeds
  static CollectionReference get collection {
    return _firestore.collection(collectionName);
  }

  /// Formats date as YYYY-MM-DD
  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Creates a new custom daily deed
  ///
  /// [deed] The CustomDailyDeed to create
  /// Returns the created deed
  static Future<CustomDailyDeed> createCustomDeed(CustomDailyDeed deed) async {
    final docRef = collection.doc(deed.id);
    await docRef.set(deed.toMap());
    return deed;
  }

  /// Gets a single custom daily deed by ID
  ///
  /// [deedId] The deed's document ID
  /// Returns the CustomDailyDeed if found, or null
  static Future<CustomDailyDeed?> getCustomDeed(String deedId) async {
    final docSnapshot = await collection.doc(deedId).get();
    
    if (docSnapshot.exists && docSnapshot.data() != null) {
      final data = docSnapshot.data()! as Map<String, dynamic>;
      return CustomDailyDeed.fromMap(data);
    }
    
    return null;
  }

  /// Gets all custom daily deeds for a user
  ///
  /// [userId] The user's ID
  /// Returns a list of CustomDailyDeed
  static Future<List<CustomDailyDeed>> getUserCustomDeeds(String userId) async {
    final querySnapshot = await collection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => CustomDailyDeed.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Gets all active custom daily deeds for a user on a specific date
  ///
  /// [userId] The user's ID
  /// [date] The date to check
  /// Returns a list of active CustomDailyDeed
  static Future<List<CustomDailyDeed>> getActiveDeedsForDate(
    String userId,
    DateTime date,
  ) async {
    final deeds = await getUserCustomDeeds(userId);
    return deeds.where((deed) => deed.isActiveOnDate(date)).toList();
  }

  /// Streams all custom daily deeds for a user
  ///
  /// [userId] The user's ID
  /// Returns a stream of query snapshots
  static Stream<QuerySnapshot> streamUserCustomDeeds(String userId) {
    return collection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Updates an existing custom daily deed
  ///
  /// [deed] The CustomDailyDeed to update
  /// Returns the updated deed
  static Future<CustomDailyDeed> updateCustomDeed(CustomDailyDeed deed) async {
    final docRef = collection.doc(deed.id);
    final updatedDeed = deed.copyWith(updatedAt: DateTime.now());
    
    await docRef.update(updatedDeed.toMap()..remove('id')..remove('userId')..remove('createdAt'));
    return updatedDeed;
  }

  /// Deletes a custom daily deed
  ///
  /// [deedId] The deed's document ID
  static Future<void> deleteCustomDeed(String deedId) async {
    await collection.doc(deedId).delete();
  }

  /// Updates the status of a custom deed for a specific date
  ///
  /// [userId] The user's ID
  /// [date] The date
  /// [deedId] The deed's ID
  /// [status] The new status ('completed' or 'missed')
  static Future<void> updateCustomDeedStatus({
    required String userId,
    required DateTime date,
    required String deedId,
    required String status,
  }) async {
    final dateStr = _formatDate(date);
    final dailyDeedId = '${userId}_$dateStr';
    
    // Reference to the daily_deeds collection
    final dailyDeedRef = FirebaseFirestore.instance
        .collection('daily_deeds')
        .doc(dailyDeedId);

    final updateData = {
      'customDeeds.$deedId': {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final doc = await dailyDeedRef.get();
    
    if (doc.exists) {
      await dailyDeedRef.update(updateData);
    } else {
      // Create the document first with minimal data
      await dailyDeedRef.set({
        'userId': userId,
        'date': dateStr,
        'customDeeds': {
          deedId: {
            'status': status,
            'updatedAt': FieldValue.serverTimestamp(),
          }
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Gets the status of a custom deed for a specific date
  ///
  /// [userId] The user's ID
  /// [date] The date
  /// [deedId] The deed's ID
  /// Returns the status or null if not set
  static Future<CustomDeedEntry?> getCustomDeedStatus({
    required String userId,
    required DateTime date,
    required String deedId,
  }) async {
    final dateStr = _formatDate(date);
    final dailyDeedId = '${userId}_$dateStr';
    
    final docSnapshot = await FirebaseFirestore.instance
        .collection('daily_deeds')
        .doc(dailyDeedId)
        .get();

    if (docSnapshot.exists && docSnapshot.data() != null) {
      final data = docSnapshot.data()!;
      final customDeeds = data['customDeeds'] as Map<String, dynamic>?;
      
      if (customDeeds != null && customDeeds.containsKey(deedId)) {
        return CustomDeedEntry.fromMap(customDeeds[deedId] as Map<String, dynamic>?);
      }
    }
    
    return null;
  }

  /// Gets all custom deed statuses for a specific date
  ///
  /// [userId] The user's ID
  /// [date] The date
  /// Returns a map of deedId to CustomDeedEntry
  static Future<Map<String, CustomDeedEntry>> getCustomDeedStatusesForDate({
    required String userId,
    required DateTime date,
  }) async {
    final dateStr = _formatDate(date);
    final dailyDeedId = '${userId}_$dateStr';
    
    final docSnapshot = await FirebaseFirestore.instance
        .collection('daily_deeds')
        .doc(dailyDeedId)
        .get();

    final result = <String, CustomDeedEntry>{};
    
    if (docSnapshot.exists && docSnapshot.data() != null) {
      final data = docSnapshot.data()!;
      final customDeeds = data['customDeeds'] as Map<String, dynamic>?;
      
      if (customDeeds != null) {
        customDeeds.forEach((key, value) {
          result[key] = CustomDeedEntry.fromMap(value as Map<String, dynamic>?);
        });
      }
    }
    
    return result;
  }
}
