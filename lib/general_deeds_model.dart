import 'package:cloud_firestore/cloud_firestore.dart';

class GeneralDeed {
  final String? id;
  final String userId;
  final String name;
  final bool isForever;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  GeneralDeed({
    this.id,
    required this.userId,
    required this.name,
    this.isForever = true,
    this.startDate,
    this.endDate,
    required this.createdAt,
    this.updatedAt,
  });

  factory GeneralDeed.create({
    required String userId,
    required String name,
    bool isForever = true,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return GeneralDeed(
      id: null,
      userId: userId,
      name: name,
      isForever: isForever,
      startDate: startDate,
      endDate: endDate,
      createdAt: DateTime.now(),
    );
  }

  factory GeneralDeed.fromMap(Map<String, dynamic> map, String docId) {
    return GeneralDeed(
      id: docId,
      userId: map['userId'] as String,
      name: map['name'] as String,
      isForever: map['isForever'] as bool? ?? true,
      startDate:
          map['startDate'] != null
              ? (map['startDate'] as Timestamp).toDate()
              : null,
      endDate:
          map['endDate'] != null
              ? (map['endDate'] as Timestamp).toDate()
              : null,
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
      'isForever': isForever,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  GeneralDeed copyWith({
    String? id,
    String? userId,
    String? name,
    bool? isForever,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GeneralDeed(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      isForever: isForever ?? this.isForever,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool isActiveOnDate(DateTime date) {
    if (isForever) return true;
    if (startDate == null && endDate == null) return true;
    if (startDate != null && date.isBefore(startDate!)) return false;
    if (endDate != null && date.isAfter(endDate!)) return false;
    return true;
  }
}

class GeneralDeedEntry {
  final String status;
  final DateTime? updatedAt;

  GeneralDeedEntry({required this.status, this.updatedAt});

  factory GeneralDeedEntry.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return GeneralDeedEntry(status: 'not_completed', updatedAt: null);
    }
    return GeneralDeedEntry(
      status: map['status'] as String? ?? 'not_completed',
      updatedAt:
          map['updatedAt'] != null
              ? (map['updatedAt'] as Timestamp).toDate()
              : null,
    );
  }
}

class GeneralDeedService {
  static const String collectionName = 'general_deeds';
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static CollectionReference get collection {
    return _firestore.collection(collectionName);
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static Future<GeneralDeed> createGeneralDeed(GeneralDeed deed) async {
    final docRef = collection.doc();
    final newDeed = deed.copyWith(id: docRef.id);
    await docRef.set(newDeed.toMap());
    return newDeed;
  }

  static Future<GeneralDeed?> getGeneralDeed(String deedId) async {
    final docSnapshot = await collection.doc(deedId).get();
    if (docSnapshot.exists && docSnapshot.data() != null) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      return GeneralDeed.fromMap(data, docSnapshot.id);
    }
    return null;
  }

  static Future<List<GeneralDeed>> getUserGeneralDeeds(String userId) async {
    final querySnapshot =
        await collection
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .get();
    return querySnapshot.docs
        .map(
          (doc) =>
              GeneralDeed.fromMap(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();
  }

  static Stream<QuerySnapshot> streamUserGeneralDeeds(String userId) {
    return collection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<GeneralDeed> updateGeneralDeed(GeneralDeed deed) async {
    final docRef = collection.doc(deed.id);
    final updatedDeed = deed.copyWith(updatedAt: DateTime.now());
    final map = updatedDeed.toMap();
    map.remove('id');
    map.remove('userId');
    map.remove('createdAt');
    await docRef.update(map);
    return updatedDeed;
  }

  static Future<void> deleteGeneralDeed(String deedId) async {
    await collection.doc(deedId).delete();
  }

  static Future<void> updateGeneralDeedStatus({
    required String userId,
    required DateTime date,
    required String deedId,
    required String status,
  }) async {
    final dateStr = _formatDate(date);
    final dailyDeedId = '${userId}_$dateStr';

    final dailyDeedRef = FirebaseFirestore.instance
        .collection('general_deeds_daily')
        .doc(dailyDeedId);

    final updateData = {
      'generalDeeds.$deedId': {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final doc = await dailyDeedRef.get();
    if (doc.exists) {
      await dailyDeedRef.update(updateData);
    } else {
      await dailyDeedRef.set({
        'userId': userId,
        'date': dateStr,
        'generalDeeds': {
          deedId: {'status': status, 'updatedAt': FieldValue.serverTimestamp()},
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  static Future<GeneralDeedEntry?> getGeneralDeedStatus({
    required String userId,
    required DateTime date,
    required String deedId,
  }) async {
    final dateStr = _formatDate(date);
    final dailyDeedId = '${userId}_$dateStr';

    final docSnapshot =
        await FirebaseFirestore.instance
            .collection('general_deeds_daily')
            .doc(dailyDeedId)
            .get();

    if (docSnapshot.exists && docSnapshot.data() != null) {
      final data = docSnapshot.data()!;
      final generalDeeds = data['generalDeeds'] as Map<String, dynamic>?;
      if (generalDeeds != null && generalDeeds.containsKey(deedId)) {
        return GeneralDeedEntry.fromMap(
          generalDeeds[deedId] as Map<String, dynamic>?,
        );
      }
    }
    return null;
  }

  static Future<Map<String, GeneralDeedEntry>> getGeneralDeedStatusesForDate({
    required String userId,
    required DateTime date,
  }) async {
    final dateStr = _formatDate(date);
    final dailyDeedId = '${userId}_$dateStr';

    final docSnapshot =
        await FirebaseFirestore.instance
            .collection('general_deeds_daily')
            .doc(dailyDeedId)
            .get();

    final result = <String, GeneralDeedEntry>{};
    if (docSnapshot.exists && docSnapshot.data() != null) {
      final data = docSnapshot.data()!;
      final generalDeeds = data['generalDeeds'] as Map<String, dynamic>?;
      if (generalDeeds != null) {
        generalDeeds.forEach((key, value) {
          result[key] = GeneralDeedEntry.fromMap(
            value as Map<String, dynamic>?,
          );
        });
      }
    }
    return result;
  }
}
