import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'health_info_model.dart';

class HealthInfoService {
  static const String _basicInfoCollection = 'basic_health_info';
  static const String _allergiesCollection = 'allergies';
  static const String _chronicDiseasesCollection = 'chronic_diseases';
  static const String _medicationsCollection = 'medications';
  static const String _emergencyContactsCollection = 'emergency_contacts';
  static const String _medicalNotesCollection = 'medical_notes';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // ============ Basic Health Info Methods ============

  /// Get basic health info for a user
  Future<BasicHealthInfo?> getBasicHealthInfo(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_basicInfoCollection)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return BasicHealthInfo.fromMap(
        snapshot.docs.first.data(),
        snapshot.docs.first.id,
      );
    } catch (e) {
      print('Error getting basic health info: $e');
      return null;
    }
  }

  /// Save or update basic health info
  Future<String> saveBasicHealthInfo(BasicHealthInfo info) async {
    try {
      final existing = await getBasicHealthInfo(info.userId);
      if (existing != null) {
        await _firestore
            .collection(_basicInfoCollection)
            .doc(existing.id)
            .update(info.copyWith(
              updatedAt: DateTime.now(),
            ).toMap());
        return existing.id!;
      } else {
        final docRef = await _firestore
            .collection(_basicInfoCollection)
            .add(info.toMap());
        return docRef.id;
      }
    } catch (e) {
      print('Error saving basic health info: $e');
      throw Exception('Failed to save basic health info: $e');
    }
  }

  // ============ Allergy Methods ============

  /// Get all allergies for a user
  Future<List<Allergy>> getAllergies(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_allergiesCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Allergy.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting allergies: $e');
      return [];
    }
  }

  /// Add a new allergy
  Future<String> addAllergy(Allergy allergy) async {
    try {
      final docRef = await _firestore
          .collection(_allergiesCollection)
          .add(allergy.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding allergy: $e');
      throw Exception('Failed to add allergy: $e');
    }
  }

  /// Delete an allergy
  Future<void> deleteAllergy(String id) async {
    try {
      await _firestore.collection(_allergiesCollection).doc(id).delete();
    } catch (e) {
      print('Error deleting allergy: $e');
      throw Exception('Failed to delete allergy: $e');
    }
  }

  // ============ Chronic Disease Methods ============

  /// Get all chronic diseases for a user
  Future<List<ChronicDisease>> getChronicDiseases(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_chronicDiseasesCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ChronicDisease.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting chronic diseases: $e');
      return [];
    }
  }

  /// Add a new chronic disease
  Future<String> addChronicDisease(ChronicDisease disease) async {
    try {
      final docRef = await _firestore
          .collection(_chronicDiseasesCollection)
          .add(disease.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding chronic disease: $e');
      throw Exception('Failed to add chronic disease: $e');
    }
  }

  /// Delete a chronic disease
  Future<void> deleteChronicDisease(String id) async {
    try {
      await _firestore
          .collection(_chronicDiseasesCollection)
          .doc(id)
          .delete();
    } catch (e) {
      print('Error deleting chronic disease: $e');
      throw Exception('Failed to delete chronic disease: $e');
    }
  }

  // ============ Medication Methods ============

  /// Get all medications for a user
  Future<List<Medication>> getMedications(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_medicationsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Medication.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting medications: $e');
      return [];
    }
  }

  /// Add a new medication
  Future<String> addMedication(Medication medication) async {
    try {
      final docRef = await _firestore
          .collection(_medicationsCollection)
          .add(medication.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding medication: $e');
      throw Exception('Failed to add medication: $e');
    }
  }

  /// Update a medication
  Future<void> updateMedication(Medication medication) async {
    if (medication.id == null) {
      throw Exception('Medication ID is required for update');
    }
    try {
      await _firestore
          .collection(_medicationsCollection)
          .doc(medication.id)
          .update(medication.copyWith(
            updatedAt: DateTime.now(),
          ).toMap());
    } catch (e) {
      print('Error updating medication: $e');
      throw Exception('Failed to update medication: $e');
    }
  }

  /// Delete a medication
  Future<void> deleteMedication(String id) async {
    try {
      await _firestore.collection(_medicationsCollection).doc(id).delete();
    } catch (e) {
      print('Error deleting medication: $e');
      throw Exception('Failed to delete medication: $e');
    }
  }

  // ============ Emergency Contact Methods ============

  /// Get all emergency contacts for a user
  Future<List<EmergencyContact>> getEmergencyContacts(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_emergencyContactsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => EmergencyContact.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting emergency contacts: $e');
      return [];
    }
  }

  /// Add a new emergency contact
  Future<String> addEmergencyContact(EmergencyContact contact) async {
    try {
      final docRef = await _firestore
          .collection(_emergencyContactsCollection)
          .add(contact.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding emergency contact: $e');
      throw Exception('Failed to add emergency contact: $e');
    }
  }

  /// Update an emergency contact
  Future<void> updateEmergencyContact(EmergencyContact contact) async {
    if (contact.id == null) {
      throw Exception('Emergency contact ID is required for update');
    }
    try {
      await _firestore
          .collection(_emergencyContactsCollection)
          .doc(contact.id)
          .update(contact.toMap());
    } catch (e) {
      print('Error updating emergency contact: $e');
      throw Exception('Failed to update emergency contact: $e');
    }
  }

  /// Delete an emergency contact
  Future<void> deleteEmergencyContact(String id) async {
    try {
      await _firestore
          .collection(_emergencyContactsCollection)
          .doc(id)
          .delete();
    } catch (e) {
      print('Error deleting emergency contact: $e');
      throw Exception('Failed to delete emergency contact: $e');
    }
  }

  // ============ Medical Note Methods ============

  /// Get all medical notes for a user
  Future<List<MedicalNote>> getMedicalNotes(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_medicalNotesCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => MedicalNote.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting medical notes: $e');
      return [];
    }
  }

  /// Add a new medical note
  Future<String> addMedicalNote(MedicalNote note) async {
    try {
      final docRef = await _firestore
          .collection(_medicalNotesCollection)
          .add(note.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding medical note: $e');
      throw Exception('Failed to add medical note: $e');
    }
  }

  /// Update a medical note
  Future<void> updateMedicalNote(MedicalNote note) async {
    if (note.id == null) {
      throw Exception('Medical note ID is required for update');
    }
    try {
      await _firestore
          .collection(_medicalNotesCollection)
          .doc(note.id)
          .update(note.toMap());
    } catch (e) {
      print('Error updating medical note: $e');
      throw Exception('Failed to update medical note: $e');
    }
  }

  /// Delete a medical note
  Future<void> deleteMedicalNote(String id) async {
    try {
      await _firestore.collection(_medicalNotesCollection).doc(id).delete();
    } catch (e) {
      print('Error deleting medical note: $e');
      throw Exception('Failed to delete medical note: $e');
    }
  }

  // ============ Full Profile Methods ============

  /// Get complete health profile for a user
  Future<HealthProfile> getHealthProfile(String userId) async {
    final basicInfo = await getBasicHealthInfo(userId);
    final allergies = await getAllergies(userId);
    final chronicDiseases = await getChronicDiseases(userId);
    final medications = await getMedications(userId);
    final emergencyContacts = await getEmergencyContacts(userId);
    final medicalNotes = await getMedicalNotes(userId);

    return HealthProfile(
      basicInfo: basicInfo,
      allergies: allergies,
      chronicDiseases: chronicDiseases,
      medications: medications,
      emergencyContacts: emergencyContacts,
      medicalNotes: medicalNotes,
    );
  }

  // ============ Notification Methods ============

  /// Schedule medication reminders
  Future<void> scheduleMedicationReminders(
    String medicationId,
    String medicationName,
    String dosage,
    List<DateTime> reminderTimes,
  ) async {
    try {
      // Initialize notifications if not already
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);
      await _notifications.initialize(initSettings);

      // Cancel any existing reminders for this medication
      await cancelMedicationReminders(medicationId);

      // Schedule new reminders
      for (int i = 0; i < reminderTimes.length; i++) {
        final notificationId = '${medicationId}_$i'.hashCode;
        final time = reminderTimes[i];

        await _notifications.zonedSchedule(
          notificationId,
          'Medication Reminder',
          'Time to take $medicationName ($dosage)',
          tz.TZDateTime.from(time, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'medication_reminders',
              'Medication Reminders',
              channelDescription: 'Reminders for your medications',
              importance: Importance.high,
              priority: Priority.high,
              playSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
    } catch (e) {
      print('Error scheduling medication reminders: $e');
    }
  }

  /// Cancel medication reminders
  Future<void> cancelMedicationReminders(String medicationId) async {
    try {
      // Cancel notifications based on medication ID prefix
      // Note: This is a simplified approach; in production you might want to store notification IDs
      for (int i = 0; i < 10; i++) {
        final notificationId = '${medicationId}_$i'.hashCode;
        await _notifications.cancel(notificationId);
      }
    } catch (e) {
      print('Error canceling medication reminders: $e');
    }
  }
}
