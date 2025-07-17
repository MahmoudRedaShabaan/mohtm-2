import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LookupService {
  List<Map<String, dynamic>> annPriorities = [];
  List<Map<String, dynamic>> gender = [{
    'id': '1',
    'genderEn': 'Male', 
    'genderAr': 'ذكر'
  },
  {
    'id': '2',
    'genderEn': 'Female', 
    'genderAr': 'انثى'
  }];
  Future<void> fetchAnnPriority() async {
    final snapshot = await FirebaseFirestore.instance.collection('annpriority').get();
    annPriorities = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
  static final LookupService _instance = LookupService._internal();
  factory LookupService() => _instance;
  LookupService._internal();

  List<Map<String, dynamic>> eventTypes = [];
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    await fetchEventTypes();
    await fetchAnnPriority();
    _initialized = true;
  }

  Future<void> fetchEventTypes() async {
    final snapshot = await FirebaseFirestore.instance.collection('eventtype').get();
    eventTypes = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
}

// Usage:
// await LookupService().initialize();
// LookupService().eventTypes
