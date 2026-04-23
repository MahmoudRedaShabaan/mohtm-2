import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/health/blood_sugar_model.dart';
import 'package:myapp/health/blood_sugar_service.dart';
import 'package:intl/intl.dart';

import 'package:myapp/widgets/app_banner_ad.dart';
class AddBloodSugarPage extends StatefulWidget {
  final String userId;
  final BloodSugarMeasurement? measurement;

  const AddBloodSugarPage({super.key, required this.userId, this.measurement});

  @override
  State<AddBloodSugarPage> createState() => _AddBloodSugarPageState();
}

class _AddBloodSugarPageState extends State<AddBloodSugarPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = BloodSugarService();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _valueController;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedCondition = 'default_condition';
  String _selectedUnit = 'mgdl';

  bool _isLoading = false;

  bool get _isEditing => widget.measurement != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.measurement?.name ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.measurement?.description ?? '',
    );
    _valueController = TextEditingController(
      text: widget.measurement?.value.toString() ?? '',
    );

    if (widget.measurement != null) {
      _selectedDate = widget.measurement!.date;
      _selectedTime = TimeOfDay.fromDateTime(widget.measurement!.date);
      _selectedCondition =
          widget.measurement!.condition == 'default'
              ? 'default_condition'
              : widget.measurement!.condition;
      _selectedUnit = widget.measurement!.unit;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editMeasurement : l10n.addMeasurement),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name Field
              _buildSectionTitle(l10n.measurementName),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: l10n.enterMeasurementName,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.measurementNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Description Field
              _buildSectionTitle(l10n.description),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: l10n.enterDescription,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 20),

              // Date & Time Selection
              _buildSectionTitle(l10n.date),
              Row(
                children: [
                  Expanded(child: _buildDateButton(l10n, isArabic)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTimeButton(l10n)),
                ],
              ),
              const SizedBox(height: 24),

              // Unit Selection
              _buildSectionTitle(l10n.unit),
              _buildUnitSelector(l10n),
              const SizedBox(height: 20),

              // Value Input
              _buildSectionTitle(l10n.bloodSugarValue),
              _buildValueInput(l10n),
              const SizedBox(height: 20),

              // Condition Selection
              _buildSectionTitle(l10n.condition),
              _buildConditionDropdown(l10n, isArabic),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveMeasurement,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                            _isEditing ? l10n.update : l10n.save,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 20),
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
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDateButton(AppLocalizations l10n, bool isArabic) {
    return InkWell(
      onTap: () => _selectDate(l10n),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFF4CAF50)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.date,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    DateFormat('MMM d, yyyy').format(_selectedDate),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeButton(AppLocalizations l10n) {
    return InkWell(
      onTap: () => _selectTime(l10n),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Color(0xFF4CAF50)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Time',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    _selectedTime.format(context),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitSelector(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children:
            SugarUnitOption.options.map((unit) {
              final isSelected = unit.value == _selectedUnit;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedUnit = unit.value;
                      // Reset value when changing unit
                      _valueController.clear();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color(0xFF4CAF50)
                              : Colors.transparent,
                      borderRadius: BorderRadius.horizontal(
                        left:
                            unit == SugarUnitOption.options.first
                                ? const Radius.circular(11)
                                : Radius.zero,
                        right:
                            unit == SugarUnitOption.options.last
                                ? const Radius.circular(11)
                                : Radius.zero,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        unit.labelEn,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildValueInput(AppLocalizations l10n) {
    final suffix = _selectedUnit == 'mmoll' ? 'mmol/L' : 'mg/dL';
    final hint = _selectedUnit == 'mmoll' ? 'e.g., 5.5' : 'e.g., 100';

    return TextFormField(
      controller: _valueController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: InputDecoration(
        labelText: l10n.bloodSugarValue,
        hintText: hint,
        suffixText: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.enterBloodSugarValue;
        }
        final num = double.tryParse(value);
        if (num == null || num <= 0) {
          return l10n.enterBloodSugarValue;
        }
        // Validate range based on unit
        if (_selectedUnit == 'mgdl') {
          if (num > 600) {
            return l10n.invalidBloodSugarValue;
          }
        } else {
          if (num > 33.3) {
            return l10n.invalidBloodSugarValue;
          }
        }
        return null;
      },
    );
  }

  Widget _buildConditionDropdown(AppLocalizations l10n, bool isArabic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCondition,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF4CAF50)),
          items:
              SugarConditionOption.options.map((condition) {
                return DropdownMenuItem<String>(
                  value: condition.value,
                  child: Text(
                    isArabic ? condition.labelAr : condition.labelEn,
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedCondition = value);
            }
          },
        ),
      ),
    );
  }

  Future<void> _selectDate(AppLocalizations l10n) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(AppLocalizations l10n) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _saveMeasurement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final measurement = BloodSugarMeasurement(
        id: widget.measurement?.id,
        userId: widget.userId,
        name: _nameController.text.trim(),
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        date: dateTime,
        value: double.parse(_valueController.text),
        unit: _selectedUnit,
        condition: _selectedCondition,
        createdAt: widget.measurement?.createdAt ?? DateTime.now(),
        updatedAt: _isEditing ? DateTime.now() : null,
      );

      if (_isEditing) {
        await _service.updateMeasurement(measurement);
      } else {
        await _service.addMeasurement(measurement);
      }

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? l10n.measurementUpdated : l10n.measurementAdded,
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? l10n.errorUpdatingMeasurement
                  : l10n.errorAddingMeasurement,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
