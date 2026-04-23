import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/health/health_info_model.dart';
import 'package:myapp/health/health_info_service.dart';
import 'package:intl/intl.dart';
import 'package:myapp/widgets/app_banner_ad.dart';


class MedicationsPage extends StatefulWidget {
  final String userId;

  const MedicationsPage({super.key, required this.userId});

  @override
  State<MedicationsPage> createState() => _MedicationsPageState();
}

class _MedicationsPageState extends State<MedicationsPage> {
  final HealthInfoService _service = HealthInfoService();
  List<Medication> _medications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    try {
      final medications = await _service.getMedications(widget.userId);
      if (!mounted) return;
      setState(() {
        _medications = medications;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteMedication(Medication medication) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.confirmDelete),
            content: Text(
              AppLocalizations.of(context)!.deleteMedicationConfirm,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(AppLocalizations.of(context)!.delete),
              ),
            ],
          ),
    );

    if (confirmed == true && medication.id != null) {
      await _service.deleteMedication(medication.id!);
      await _service.cancelMedicationReminders(medication.id!);
      _loadMedications();
    }
  }

  void _showAddMedicationDialog({Medication? existingMedication}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => AddMedicationPage(
              userId: widget.userId,
              existingMedication: existingMedication,
            ),
      ),
    ).then((_) => _loadMedications());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.medications),
        backgroundColor: const Color(0xFF673AB7),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _medications.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.medication, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noMedications,
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.addMedicationHint,
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _medications.length,
                itemBuilder: (context, index) {
                  final medication = _medications[index];
                  return _MedicationCard(
                    medication: medication,
                    onEdit:
                        () => _showAddMedicationDialog(
                          existingMedication: medication,
                        ),
                    onDelete: () => _deleteMedication(medication),
                    onToggleActive: () async {
                      final updated = medication.copyWith(
                        isActive: !medication.isActive,
                      );
                      await _service.updateMedication(updated);
                      _loadMedications();
                    },
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMedicationDialog(),
        backgroundColor: const Color(0xFF673AB7),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const AppBannerAd(),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  final Medication medication;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;

  const _MedicationCard({
    required this.medication,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        medication.isActive
                            ? Colors.purple.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.medication,
                    color: medication.isActive ? Colors.purple : Colors.grey,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: medication.isActive ? null : Colors.grey,
                        ),
                      ),
                      Text(
                        '${medication.dosage} ${medication.dosageUnit} - ${PredefinedData.getFrequencyDisplay(medication.frequency, isArabic ? 'ar' : 'en')}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: medication.isActive,
                  onChanged: (_) => onToggleActive(),
                  activeColor: const Color(0xFF673AB7),
                ),
              ],
            ),
            if (medication.startDate != null || medication.endDate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (medication.startDate != null)
                    Text(
                      '${l10n.startDate}: ${DateFormat.yMMMd(isArabic ? 'ar' : 'en').format(medication.startDate!)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  if (medication.startDate != null &&
                      medication.endDate != null)
                    const Text(' | ', style: TextStyle(color: Colors.grey)),
                  if (medication.endDate != null)
                    Text(
                      '${l10n.endDate}: ${DateFormat.yMMMd(isArabic ? 'ar' : 'en').format(medication.endDate!)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                ],
              ),
            ],
            if (medication.reminderTimes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children:
                    medication.reminderTimes.map((time) {
                      return Chip(
                        label: Text(
                          DateFormat.Hm(isArabic ? 'ar' : 'en').format(time),
                          style: const TextStyle(fontSize: 12),
                        ),
                        avatar: const Icon(Icons.alarm, size: 16),
                        backgroundColor: Colors.purple.withOpacity(0.1),
                      );
                    }).toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18),
                  label: Text(l10n.edit),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  label: Text(
                    l10n.delete,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddMedicationPage extends StatefulWidget {
  final String userId;
  final Medication? existingMedication;

  const AddMedicationPage({
    super.key,
    required this.userId,
    this.existingMedication,
  });

  @override
  State<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  final HealthInfoService _service = HealthInfoService();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  String _selectedFrequency = MedicationFrequency.onceDaily.name;
  int? _customFrequencyHours;
  DateTime? _startDate;
  DateTime? _endDate;
  List<DateTime> _reminderTimes = [];
  bool _isActive = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingMedication != null) {
      _nameController.text = widget.existingMedication!.name;
      _dosageController.text = widget.existingMedication!.dosage.toString();
      _selectedFrequency = widget.existingMedication!.frequency;
      _customFrequencyHours = widget.existingMedication!.customFrequencyHours;
      _startDate = widget.existingMedication!.startDate;
      _endDate = widget.existingMedication!.endDate;
      _reminderTimes = List.from(widget.existingMedication!.reminderTimes);
      _isActive = widget.existingMedication!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isStartDate) async {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final locale = isArabic ? const Locale('ar') : const Locale('en');

    final picked = await showDatePicker(
      context: context,
      initialDate:
          isStartDate
              ? (_startDate ?? DateTime.now())
              : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _addReminderTime() async {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final locale = isArabic ? const Locale('ar') : const Locale('en');

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final now = DateTime.now();
      final reminderTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );
      setState(() {
        _reminderTimes.add(reminderTime);
        _reminderTimes.sort();
      });
    }
  }

  void _removeReminderTime(int index) {
    setState(() {
      _reminderTimes.removeAt(index);
    });
  }

  Future<void> _saveMedication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final medication = Medication(
        id: widget.existingMedication?.id,
        userId: widget.userId,
        name: _nameController.text.trim(),
        dosage: double.parse(_dosageController.text),
        dosageUnit: 'mg',
        frequency: _selectedFrequency,
        customFrequencyHours: _customFrequencyHours,
        startDate: _startDate,
        endDate: _endDate,
        reminderTimes: _reminderTimes,
        isActive: _isActive,
        createdAt: widget.existingMedication?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      String medicationId;
      if (widget.existingMedication != null) {
        await _service.updateMedication(medication);
        medicationId = widget.existingMedication!.id!;
      } else {
        medicationId = await _service.addMedication(medication);
      }

      // Schedule reminders
      if (_reminderTimes.isNotEmpty) {
        final locale = Localizations.localeOf(context).languageCode;
        await _service.scheduleMedicationReminders(
          medicationId,
          medication.name,
          '${medication.dosage} ${medication.dosageUnit}',
          _reminderTimes,
          locale: locale,
        );
      } else {
        await _service.cancelMedicationReminders(medicationId);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.savedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorSaving),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingMedication != null
              ? l10n.editMedication
              : l10n.addMedication,
        ),
        backgroundColor: const Color(0xFF673AB7),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Medication Name
              _buildSectionTitle(l10n.medicationName),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: l10n.enterMedicationName,
                  prefixIcon: const Icon(Icons.medication),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.pleaseEnterValue;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Dosage
              _buildSectionTitle(l10n.dosage),
              TextFormField(
                controller: _dosageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: l10n.enterDosage,
                  prefixIcon: const Icon(Icons.science),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterValue;
                  }
                  if (double.tryParse(value) == null) {
                    return l10n.enterValidNumber;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Frequency
              _buildSectionTitle(l10n.frequency),
              DropdownButtonFormField<String>(
                value: _selectedFrequency,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.schedule),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items:
                    MedicationFrequency.values.map((freq) {
                      return DropdownMenuItem(
                        value: freq.name,
                        child: Text(
                          PredefinedData.getFrequencyDisplay(
                            freq.name,
                            isArabic ? 'ar' : 'en',
                          ),
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFrequency =
                        value ?? MedicationFrequency.onceDaily.name;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Start/End Dates
              _buildSectionTitle('${l10n.startDate} / ${l10n.endDate}'),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(true),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _startDate != null
                              ? DateFormat.yMMMd(
                                isArabic ? 'ar' : 'en',
                              ).format(_startDate!)
                              : l10n.startDate,
                          style: TextStyle(
                            color:
                                _startDate != null ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(false),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.event),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _endDate != null
                              ? DateFormat.yMMMd(
                                isArabic ? 'ar' : 'en',
                              ).format(_endDate!)
                              : l10n.endDate,
                          style: TextStyle(
                            color:
                                _endDate != null ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Reminder Times
              _buildSectionTitle(l10n.reminderTimes),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ..._reminderTimes.asMap().entries.map((entry) {
                            return Chip(
                              label: Text(
                                DateFormat.Hm(
                                  isArabic ? 'ar' : 'en',
                                ).format(entry.value),
                              ),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () => _removeReminderTime(entry.key),
                            );
                          }),
                          ActionChip(
                            avatar: const Icon(Icons.add, size: 18),
                            label: Text(l10n.addTime),
                            onPressed: _addReminderTime,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveMedication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF673AB7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isSaving
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Text(
                            l10n.save,
                            style: const TextStyle(fontSize: 16),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBannerAd(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF673AB7),
        ),
      ),
    );
  }
}
