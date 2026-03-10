import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Stream for today's anniversaries
Stream<List<QueryDocumentSnapshot>> getTodaysAnniversariesStream() {
      final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Return an empty stream if not logged in
      return Stream.value([]);
    }
    final today = DateTime.now();
    return FirebaseFirestore.instance
        .collection('anniversaries')
        .where('createdBy', isEqualTo: user.uid)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.where((doc) {
                final Timestamp? ts = doc['date'];
                if (ts == null) return false;
                final date = ts.toDate();
                return date.month == today.month && date.day == today.day;
              }).toList(),
        );
  // try {
  //   return FirebaseFirestore.instance
  //       .collection('anniversaries')
  //       .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
  //       .snapshots()
  //       .map((querySnapshot) {
  //     final today = DateTime.now();
  //     final todayDay = today.day;
  //     final todayMonth = today.month;

  //     return querySnapshot.docs.where((doc) {
  //       final Timestamp dateTimestamp = doc['date'] as Timestamp;
  //       final DateTime date = dateTimestamp.toDate();
  //       return date.day == todayDay && date.month == todayMonth;
  //     }).toList();
  //   });
  // } catch (e) {
  //   print('Error in getTodaysAnniversariesStream: $e');
  //   return const Stream.empty();
  // }
}

/// Stream for upcoming anniversaries (not today)
Stream<List<QueryDocumentSnapshot>> getNotifiedOccasionsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    final today = DateTime.now();
    print('🔍 DEBUG: Current date: ${today.day}/${today.month}/${today.year}');

    return FirebaseFirestore.instance
        .collection('anniversaries')
        .where('createdBy', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          print('🔍 DEBUG: Found ${snapshot.docs.length} total documents');

          final filteredDocs =
              snapshot.docs.where((doc) {
                print('🔍 DEBUG: Document ${doc.id}:');
                print('🔍 DEBUG: date ${doc['date']}:');
                print('🔍 DEBUG: rememberBefore ${doc['rememberBeforeDate']}:');
                final Timestamp? eventDateTs = doc['date'];
                final Timestamp? rememberBeforeTs = doc['rememberBeforeDate'];

                print('🔍 DEBUG: Document ${doc.id}:');
                print('  - Title: ${doc['title']}');
                print('  - Event Date: $eventDateTs');
                print('  - Remember Before Date: $rememberBeforeTs');

                if (eventDateTs == null || rememberBeforeTs == null) {
                  print(
                    '  - ❌ Skipped: Missing event date or remember before date',
                  );
                  return false;
                }

                final eventDate = eventDateTs.toDate();
                final rememberBeforeDate = rememberBeforeTs.toDate();
                final currentDate = DateTime(2000, today.month, today.day);
                final eventDateNormalized = DateTime(
                  2000,
                  eventDate.month,
                  eventDate.day,
                );
                final rememberBeforeDateNormalized = DateTime(
                  2000,
                  rememberBeforeDate.month,
                  rememberBeforeDate.day,
                );

                print(
                  '  - Event Date: ${eventDate.day}/${eventDate.month}/${eventDate.year}',
                );
                print(
                  '  - Remember Before Date: ${rememberBeforeDate.day}/${rememberBeforeDate.month}/${rememberBeforeDate.year}',
                );
                print(
                  '  - Current Date: ${currentDate.day}/${currentDate.month}',
                );

                // Validation: current date >= remember before date AND current date < event date
                // (comparing only day and month, ignoring year)
                final condition1 =
                    currentDate.isAtSameMomentAs(
                      rememberBeforeDateNormalized,
                    ) ||
                    currentDate.isAfter(rememberBeforeDateNormalized);
                final condition2 = currentDate.isBefore(eventDateNormalized);

                print(
                  '  - Condition 1 (current >= remember before): $condition1',
                );
                print('  - Condition 2 (current < event): $condition2');
                print('  - Final result: ${condition1 && condition2}');
                print('  ---');

                return condition1 && condition2;
              }).toList();

          print('🔍 DEBUG: Filtered to ${filteredDocs.length} documents');
          return filteredDocs;
        });
  // try {
  //   return FirebaseFirestore.instance
  //       .collection('anniversaries')
  //       .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
  //       .snapshots()
  //       .map((querySnapshot) {
  //     final today = DateTime.now();
  //     final todayDay = today.day;
  //     final todayMonth = today.month;

  //     return querySnapshot.docs.where((doc) {
  //       final Timestamp dateTimestamp = doc['date'] as Timestamp;
  //       final DateTime date = dateTimestamp.toDate();
  //       return !(date.day == todayDay && date.month == todayMonth);
  //     }).toList();
  //   });
  // } catch (e) {
  //   print('Error in getNotifiedOccasionsStream: $e');
  //   return const Stream.empty();
  // }
}
