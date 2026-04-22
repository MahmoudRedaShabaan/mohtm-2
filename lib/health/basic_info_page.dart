import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/health/health_info_model.dart';
import 'package:myapp/health/health_info_service.dart';
import 'package:intl/intl.dart';

class BasicInfoPage extends StatefulWidget {
  final String userId;

  const BasicInfoPage({super.key, required this.userId});

  @override
  State<BasicInfoPage> createState() => _BasicInfoPageState();
}

class _BasicInfoPageState extends State<BasicInfoPage> {
  final HealthInfoService _service = HealthInfoService();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  String? _selectedBloodType;
  DateTime? _dateOfBirth;
  int _heightUnitIndex = 0;
  int _weightUnitIndex = 0;

  bool _isLoading = true;
  bool _isSaving = false;
  BasicHealthInfo? _existingInfo;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingData() async {
    try {
      final info = await _service.getBasicHealthInfo(widget.userId);
      if (!mounted) return;
      if (info != null) {
        _existingInfo = info;
        _nameController.text = info.fullName;
        _selectedBloodType = info.bloodType;
        _dateOfBirth = info.dateOfBirth;
        if (info.height != null) {
          _heightController.text = info.height.toString();
        }
        _heightUnitIndex = info.heightUnitIndex;
        if (info.weight != null) {
          _weightController.text = info.weight.toString();
        }
        _weightUnitIndex = info.weightUnitIndex;
      }
    } catch (e) {
      print('Error loading basic info: $e');
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final locale = isArabic ? const Locale('ar') : const Locale('en');

    final picked = await showDatePicker(
      context: context,
      initialDate:
          _dateOfBirth ??
          DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  Future<void> _saveBasicInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final info = BasicHealthInfo(
        id: _existingInfo?.id,
        userId: widget.userId,
        fullName: _nameController.text.trim(),
        bloodType: _selectedBloodType,
        dateOfBirth: _dateOfBirth,
        height:
            _heightController.text.isNotEmpty
                ? double.tryParse(_heightController.text)
                : null,
        heightUnitIndex: _heightUnitIndex,
        weight:
            _weightController.text.isNotEmpty
                ? double.tryParse(_weightController.text)
                : null,
        weightUnitIndex: _weightUnitIndex,
        createdAt: _existingInfo?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _service.saveBasicHealthInfo(info);

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
        title: Text(l10n.basicInfo),
        backgroundColor: const Color(0xFF673AB7),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Full Name
                      _buildSectionTitle(l10n.fullName),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: l10n.enterFullName,
                          prefixIcon: const Icon(Icons.person),
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

                      // Blood Type
                      _buildSectionTitle(l10n.bloodType),
                      DropdownButtonFormField<String>(
                        value: _selectedBloodType,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.bloodtype),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        hint: Text(l10n.selectBloodType),
                        items:
                            BloodType.values.map((type) {
                              return DropdownMenuItem(
                                value: type.displayName,
                                child: Text(type.displayName),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedBloodType = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // Date of Birth
                      _buildSectionTitle(l10n.dateOfBirth),
                      InkWell(
                        onTap: _selectDate,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon:
                                _dateOfBirth != null
                                    ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() {
                                          _dateOfBirth = null;
                                        });
                                      },
                                    )
                                    : null,
                          ),
                          child: Text(
                            _dateOfBirth != null
                                ? DateFormat.yMMMd(
                                  isArabic ? 'ar' : 'en',
                                ).format(_dateOfBirth!)
                                : l10n.selectDate,
                            style: TextStyle(
                              color:
                                  _dateOfBirth != null
                                      ? Colors.black
                                      : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Height
                      _buildSectionTitle(l10n.height),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _heightController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: l10n.enterHeight,
                                prefixIcon: const Icon(Icons.height),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _heightUnitIndex,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items:
                                  HeightUnit.values.map((unit) {
                                    return DropdownMenuItem(
                                      value: unit.index,
                                      child: Text(unit.displayName),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _heightUnitIndex = value ?? 0;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Weight
                      _buildSectionTitle(l10n.weight),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _weightController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: l10n.enterWeight,
                                prefixIcon: const Icon(Icons.monitor_weight),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _weightUnitIndex,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items:
                                  WeightUnit.values.map((unit) {
                                    return DropdownMenuItem(
                                      value: unit.index,
                                      child: Text(unit.displayName),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _weightUnitIndex = value ?? 0;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveBasicInfo,
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
