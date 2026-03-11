import 'package:cloud_firestore/cloud_firestore.dart';

/// Status for custom daily deeds
enum CustomDeedStatus {
  missed('missed'),
  completed('completed');

  final String value;
  const CustomDeedStatus(this.value);

  static CustomDeedStatus? fromString(String? value) {
    if (value == null) return null;
    return CustomDeedStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CustomDeedStatus.missed,
    );
  }
}

/// Represents a custom daily deed created by a user
class CustomDailyDeed {
  final String id;
  final String userId;
  final String name;
  final bool isForever;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CustomDailyDeed({
    required this.id,
    required this.userId,
    required this.name,
    required this.isForever,
    this.startDate,
    this.endDate,
    required this.createdAt,
    this.updatedAt,
  });

  /// Generates a unique document ID
  static String generateId(String userId) {
    return '${userId}_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Creates a new CustomDailyDeed
  static CustomDailyDeed create({
    required String userId,
    required String name,
    required bool isForever,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final now = DateTime.now();
    return CustomDailyDeed(
      id: generateId(userId),
      userId: userId,
      name: name,
      isForever: isForever,
      startDate: isForever ? null : startDate,
      endDate: isForever ? null : endDate,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Check if this deed should be active on a given date
  bool isActiveOnDate(DateTime date) {
    if (isForever) return true;
    if (startDate == null || endDate == null) return false;
    
    final dateOnly = DateTime(date.year, date.month, date.day);
    final startOnly = DateTime(startDate!.year, startDate!.month, startDate!.day);
    final endOnly = DateTime(endDate!.year, endDate!.month, endDate!.day);
    
    return !dateOnly.isBefore(startOnly) && !dateOnly.isAfter(endOnly);
  }

  factory CustomDailyDeed.fromMap(Map<String, dynamic> map) {
    return CustomDailyDeed(
      id: map['id'] as String,
      userId: map['userId'] as String,
      name: map['name'] as String,
      isForever: map['isForever'] as bool? ?? true,
      startDate: (map['startDate'] as Timestamp?)?.toDate(),
      endDate: (map['endDate'] as Timestamp?)?.toDate(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'isForever': isForever,
      'startDate': startDate,
      'endDate': endDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Creates a copy with optional updated fields
  CustomDailyDeed copyWith({
    String? name,
    bool? isForever,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? updatedAt,
  }) {
    return CustomDailyDeed(
      id: id,
      userId: userId,
      name: name ?? this.name,
      isForever: isForever ?? this.isForever,
      startDate: isForever == true ? null : (startDate ?? this.startDate),
      endDate: isForever == true ? null : (endDate ?? this.endDate),
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

/// Represents the completion status of a custom deed for a specific date
class CustomDeedEntry {
  final String? status;
  final DateTime? updatedAt;

  CustomDeedEntry({
    this.status,
    this.updatedAt,
  });

  factory CustomDeedEntry.fromMap(Map<String, dynamic>? map) {
    if (map == null) return CustomDeedEntry();
    return CustomDeedEntry(
      status: map['status'] as String?,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'updatedAt': updatedAt,
    };
  }
}
