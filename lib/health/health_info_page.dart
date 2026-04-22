import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/health/health_info_model.dart';
import 'package:myapp/health/health_info_service.dart';
import 'package:myapp/health/basic_info_page.dart';
import 'package:myapp/health/allergies_page.dart';
import 'package:myapp/health/chronic_diseases_page.dart';
import 'package:myapp/health/medications_page.dart';
import 'package:myapp/health/emergency_info_page.dart';
import 'package:myapp/health/medical_notes_page.dart';

class HealthInfoPage extends StatefulWidget {
  const HealthInfoPage({super.key});

  @override
  State<HealthInfoPage> createState() => _HealthInfoPageState();
}

class _HealthInfoPageState extends State<HealthInfoPage> {
  final HealthInfoService _service = HealthInfoService();
  String? _userId;
  bool _isLoading = true;
  bool _isExporting = false;
  HealthProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
      try {
        final profile = await _service.getHealthProfile(_userId!);
        if (!mounted) return;
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToPage(Widget page, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    ).then((_) => _loadProfile());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.healthInfo),
        backgroundColor: const Color(0xFF9575CD),
        actions: [
          IconButton(
            icon:
                _isExporting
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Icon(Icons.download),
            onPressed:
                _isExporting ? null : () => _exportHealthInfo(share: false),
            tooltip: l10n.download,
          ),
          IconButton(
            icon:
                _isExporting
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Icon(Icons.share),
            onPressed:
                _isExporting ? null : () => _exportHealthInfo(share: true),
            tooltip: l10n.share,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadProfile,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Info Card
                      _buildDashboardCard(
                        icon: Icons.person,
                        title: l10n.basicInfo,
                        subtitle:
                            _profile?.basicInfo?.fullName.isNotEmpty == true
                                ? _profile!.basicInfo!.fullName
                                : l10n.addBasicInfo,
                        color: Colors.blue,
                        onTap:
                            () => _navigateToPage(
                              BasicInfoPage(userId: _userId!),
                              l10n.basicInfo,
                            ),
                      ),
                      const SizedBox(height: 12),

                      // Allergies Card
                      _buildDashboardCard(
                        icon: Icons.warning_amber,
                        title: l10n.allergies,
                        subtitle: _getAllergiesSubtitle(),
                        color: Colors.orange,
                        onTap:
                            () => _navigateToPage(
                              AllergiesPage(userId: _userId!),
                              l10n.allergies,
                            ),
                      ),
                      const SizedBox(height: 12),

                      // Chronic Diseases Card
                      _buildDashboardCard(
                        icon: Icons.medical_information,
                        title: l10n.chronicDiseases,
                        subtitle: _getChronicDiseasesSubtitle(),
                        color: Colors.red,
                        onTap:
                            () => _navigateToPage(
                              ChronicDiseasesPage(userId: _userId!),
                              l10n.chronicDiseases,
                            ),
                      ),
                      const SizedBox(height: 12),

                      // Medications Card
                      _buildDashboardCard(
                        icon: Icons.medication,
                        title: l10n.medications,
                        subtitle: _getMedicationsSubtitle(),
                        color: Colors.purple,
                        onTap:
                            () => _navigateToPage(
                              MedicationsPage(userId: _userId!),
                              l10n.medications,
                            ),
                      ),
                      const SizedBox(height: 12),

                      // Emergency Info Card (highlighted)
                      _buildDashboardCard(
                        icon: Icons.emergency,
                        title: l10n.emergencyInfo,
                        subtitle: _getEmergencySubtitle(),
                        color: Colors.red.shade700,
                        isEmergency: true,
                        onTap:
                            () => _navigateToPage(
                              EmergencyInfoPage(userId: _userId!),
                              l10n.emergencyInfo,
                            ),
                      ),
                      const SizedBox(height: 12),

                      // Medical Notes Card
                      _buildDashboardCard(
                        icon: Icons.note,
                        title: l10n.medicalNotes,
                        subtitle: _getMedicalNotesSubtitle(),
                        color: Colors.teal,
                        onTap:
                            () => _navigateToPage(
                              MedicalNotesPage(userId: _userId!),
                              l10n.medicalNotes,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isEmergency = false,
  }) {
    return Card(
      elevation: isEmergency ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            isEmergency ? BorderSide(color: color, width: 2) : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isEmergency ? color : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  String _getAllergiesSubtitle() {
    if (_profile == null || _profile!.allergies.isEmpty) {
      return AppLocalizations.of(context)!.noData;
    }
    final medicationCount =
        _profile!.allergies.where((a) => a.type == 'medication').length;
    final foodCount = _profile!.allergies.where((a) => a.type == 'food').length;
    final parts = <String>[];
    if (medicationCount > 0) {
      parts.add(
        '$medicationCount ${AppLocalizations.of(context)!.medications.toLowerCase()}',
      );
    }
    if (foodCount > 0) {
      parts.add(
        '$foodCount ${AppLocalizations.of(context)!.food.toLowerCase()}',
      );
    }
    return parts.isEmpty
        ? AppLocalizations.of(context)!.noData
        : parts.join(', ');
  }

  String _getChronicDiseasesSubtitle() {
    if (_profile == null || _profile!.chronicDiseases.isEmpty) {
      return AppLocalizations.of(context)!.noData;
    }
    final count = _profile!.chronicDiseases.length;
    if (count == 1) {
      return _profile!.chronicDiseases.first.name;
    }
    return '${_profile!.chronicDiseases.first.name} +${count - 1}';
  }

  String _getMedicationsSubtitle() {
    if (_profile == null || _profile!.medications.isEmpty) {
      return AppLocalizations.of(context)!.noData;
    }
    final active = _profile!.activeMedications.length;
    final total = _profile!.medications.length;
    return '$active / $total ${AppLocalizations.of(context)!.active.toLowerCase()}';
  }

  String _getEmergencySubtitle() {
    if (_profile == null || _profile!.emergencyContacts.isEmpty) {
      return AppLocalizations.of(context)!.noData;
    }
    return _profile!.emergencyContacts.first.name;
  }

  String _getMedicalNotesSubtitle() {
    if (_profile == null || _profile!.medicalNotes.isEmpty) {
      return AppLocalizations.of(context)!.noData;
    }
    final count = _profile!.medicalNotes.length;
    return '$count ${count == 1 ? 'note' : 'notes'}';
  }

  Future<void> _exportHealthInfo({bool share = false}) async {
    if (_profile == null) return;

    setState(() => _isExporting = true);

    try {
      final isArabic = Localizations.localeOf(context).languageCode == 'ar';
      final l10n = AppLocalizations.of(context)!;

      final htmlContent = _generateHtmlReport(isArabic: isArabic, l10n: l10n);

      final fileName =
          isArabic
              ? 'معلومات_صحية_${DateTime.now().millisecondsSinceEpoch}.html'
              : 'health_info_${DateTime.now().millisecondsSinceEpoch}.html';

      String savePath;
      try {
        final externalDir = Directory('/storage/emulated/0/Download');
        if (!await externalDir.exists()) {
          final dir = await getApplicationDocumentsDirectory();
          savePath = '${dir.path}/$fileName';
        } else {
          savePath = '${externalDir.path}/$fileName';
        }
      } catch (e) {
        final dir = await getApplicationDocumentsDirectory();
        savePath = '${dir.path}/$fileName';
      }

      final file = File(savePath);
      await file.writeAsString(htmlContent);

      if (share) {
        await Share.shareXFiles([
          XFile(file.path),
        ], subject: isArabic ? 'معلومات صحية' : 'Health Information');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.exportSuccess)));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.download}: $savePath'),
              duration: const Duration(seconds: 6),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.exportError)),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  String _generateHtmlReport({
    required bool isArabic,
    required AppLocalizations l10n,
  }) {
    final direction = isArabic ? 'rtl' : 'ltr';
    final profile = _profile!;

    final title = isArabic ? 'المعلومات الصحية' : 'Health Information';
    final appName = isArabic ? 'MOHTM | مهتم' : 'MOHTM | مهتم';

    final buffer = StringBuffer();

    buffer.writeln('''
<!DOCTYPE html>
<html lang="${isArabic ? 'ar' : 'en'}" dir="$direction">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$title</title>
  <style>
    body { font-family: Tahoma, Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
    .container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
    .header { text-align: center; margin-bottom: 20px; padding-bottom: 15px; border-bottom: 2px solid #B68EBE; }
    .app-name { font-size: 22px; font-weight: bold; color: #800080; margin-bottom: 5px; }
    h1 { color: #800080; text-align: center; margin: 10px 0; }
    h2 { color: #B68EBE; border-bottom: 1px solid #ddd; padding-bottom: 5px; margin-top: 20px; }
    table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
    th, td { padding: 10px; border: 1px solid #ddd; text-align: ${isArabic ? 'right' : 'left'}; }
    th { background-color: #B68EBE; color: white; }
    tr:nth-child(even) { background-color: #F3E5F5; }
    .section { margin-bottom: 20px; }
    .empty { color: #999; font-style: italic; }
    .badge { display: inline-block; padding: 3px 8px; border-radius: 12px; font-size: 12px; margin: 2px; }
    .badge-medications { background-color: #E1BEE7; color: #7B1FA2; }
    .badge-food { background-color: #FFE0B2; color: #E65100; }
    @media print {
      body { background: white; }
      .container { box-shadow: none; }
      button { display: none; }
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <div class="app-name">$appName</div>
      <h1>$title</h1>
      <p>${isArabic ? 'تاريخ التصدير' : 'Export Date'}: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}</p>
    </div>
''');

    // Basic Info Section
    buffer.writeln('<div class="section">');
    buffer.writeln(
      '<h2>${isArabic ? 'المعلومات الأساسية' : 'Basic Information'}</h2>',
    );
    if (profile.basicInfo != null) {
      final basic = profile.basicInfo!;
      buffer.writeln('<table>');
      if (basic.fullName.isNotEmpty) {
        buffer.writeln(
          '<tr><th>${isArabic ? 'الاسم' : 'Name'}</th><td>${basic.fullName}</td></tr>',
        );
      }
      if (basic.bloodType != null) {
        buffer.writeln(
          '<tr><th>${isArabic ? 'فصيلة الدم' : 'Blood Type'}</th><td>${basic.bloodType}</td></tr>',
        );
      }
      if (basic.height != null) {
        final heightUnit =
            basic.heightUnitIndex == 0
                ? (isArabic ? 'سم' : 'cm')
                : (isArabic ? 'قدم' : 'ft');
        buffer.writeln(
          '<tr><th>${isArabic ? 'الطول' : 'Height'}</th><td>${basic.height} $heightUnit</td></tr>',
        );
      }
      if (basic.weight != null) {
        final weightUnit =
            basic.weightUnitIndex == 0
                ? (isArabic ? 'كجم' : 'kg')
                : (isArabic ? 'رطل' : 'lbs');
        buffer.writeln(
          '<tr><th>${isArabic ? 'الوزن' : 'Weight'}</th><td>${basic.weight} $weightUnit</td></tr>',
        );
      }
      buffer.writeln('</table>');
    } else {
      buffer.writeln('<p class="empty">${l10n.noData}</p>');
    }
    buffer.writeln('</div>');

    // Allergies Section
    buffer.writeln('<div class="section">');
    buffer.writeln('<h2>${isArabic ? 'الحساسية' : 'Allergies'}</h2>');
    if (profile.allergies.isNotEmpty) {
      final medAllergies =
          profile.allergies.where((a) => a.type == 'medication').toList();
      final foodAllergies =
          profile.allergies.where((a) => a.type == 'food').toList();

      if (medAllergies.isNotEmpty) {
        buffer.writeln(
          '<p><strong>${isArabic ? 'حساسية الأدوية' : 'Medication Allergies'}:</strong></p>',
        );
        for (final allergy in medAllergies) {
          buffer.write(
            '<span class="badge badge-medications">${allergy.name}${allergy.isCustom ? " (${l10n.custom})" : ""}</span>',
          );
        }
        buffer.writeln('');
      }

      if (foodAllergies.isNotEmpty) {
        buffer.writeln(
          '<p><strong>${isArabic ? 'حساسية الطعام' : 'Food Allergies'}:</strong></p>',
        );
        for (final allergy in foodAllergies) {
          buffer.write(
            '<span class="badge badge-food">${allergy.name}${allergy.isCustom ? " (${l10n.custom})" : ""}</span>',
          );
        }
        buffer.writeln('');
      }
    } else {
      buffer.writeln('<p class="empty">${l10n.noData}</p>');
    }
    buffer.writeln('</div>');

    // Chronic Diseases Section
    buffer.writeln('<div class="section">');
    buffer.writeln(
      '<h2>${isArabic ? 'الأمراض المزمنة' : 'Chronic Diseases'}</h2>',
    );
    if (profile.chronicDiseases.isNotEmpty) {
      buffer.writeln(
        '<table><tr><th>${isArabic ? 'المرض' : 'Disease'}</th><th>${isArabic ? 'النوع' : 'Type'}</th></tr>',
      );
      for (final disease in profile.chronicDiseases) {
        buffer.writeln(
          '<tr><td>${disease.name}</td><td>${disease.isCustom ? l10n.custom : (isArabic ? 'محدد' : 'Predefined')}</td></tr>',
        );
      }
      buffer.writeln('</table>');
    } else {
      buffer.writeln('<p class="empty">${l10n.noData}</p>');
    }
    buffer.writeln('</div>');

    // Medications Section
    buffer.writeln('<div class="section">');
    buffer.writeln('<h2>${isArabic ? 'الأدوية' : 'Medications'}</h2>');
    if (profile.medications.isNotEmpty) {
      buffer.writeln(
        '<table><tr><th>${isArabic ? 'الاسم' : 'Name'}</th><th>${isArabic ? 'الجرعة' : 'Dosage'}</th><th>${isArabic ? 'التكرار' : 'Frequency'}</th><th>${isArabic ? 'الحالة' : 'Status'}</th></tr>',
      );
      for (final med in profile.medications) {
        final freqDisplay = PredefinedData.getFrequencyDisplay(
          med.frequency,
          isArabic ? 'ar' : 'en',
        );
        final status =
            isArabic
                ? (med.isActive ? 'نشط' : 'غير نشط')
                : (med.isActive ? 'Active' : 'Inactive');
        buffer.writeln(
          '<tr><td>${med.name}</td><td>${med.dosage} ${med.dosageUnit}</td><td>$freqDisplay</td><td>$status</td></tr>',
        );
      }
      buffer.writeln('</table>');
    } else {
      buffer.writeln('<p class="empty">${l10n.noData}</p>');
    }
    buffer.writeln('</div>');

    // Emergency Contacts Section
    buffer.writeln('<div class="section">');
    buffer.writeln(
      '<h2>${isArabic ? 'جهات الاتصال الطارئة' : 'Emergency Contacts'}</h2>',
    );
    if (profile.emergencyContacts.isNotEmpty) {
      buffer.writeln(
        '<table><tr><th>${isArabic ? 'الاسم' : 'Name'}</th><th>${isArabic ? 'رقم الهاتف' : 'Phone'}</th><th>${isArabic ? 'العلاقة' : 'Relationship'}</th></tr>',
      );
      for (final contact in profile.emergencyContacts) {
        buffer.writeln(
          '<tr><td>${contact.name}</td><td>${contact.phone}</td><td>${contact.relationship ?? '-'}</td></tr>',
        );
      }
      buffer.writeln('</table>');
    } else {
      buffer.writeln('<p class="empty">${l10n.noData}</p>');
    }
    buffer.writeln('</div>');

    // Medical Notes Section
    buffer.writeln('<div class="section">');
    buffer.writeln(
      '<h2>${isArabic ? 'الملاحظات الطبية' : 'Medical Notes'}</h2>',
    );
    if (profile.medicalNotes.isNotEmpty) {
      for (final note in profile.medicalNotes) {
        buffer.writeln(
          '<div style="margin-bottom: 10px; padding: 10px; background: #F5F5F5; border-radius: 5px;">',
        );
        buffer.writeln(
          '<p><strong>${note.timestamp.day}/${note.timestamp.month}/${note.timestamp.year}</strong></p>',
        );
        buffer.writeln('<p>${note.content}</p>');
        buffer.writeln('</div>');
      }
    } else {
      buffer.writeln('<p class="empty">${l10n.noData}</p>');
    }
    buffer.writeln('</div>');

    buffer.writeln('''
  <div style="margin-top: 20px; text-align: center;">
    <button onclick="window.print()" style="padding: 12px 24px; background-color: #800080; color: white; border: none; cursor: pointer; border-radius: 5px; font-size: 14px;">
      ${isArabic ? 'طباعة PDF' : 'Print / Save as PDF'}
    </button>
  </div>
  </div>
</body>
</html>
''');

    return buffer.toString();
  }
}
