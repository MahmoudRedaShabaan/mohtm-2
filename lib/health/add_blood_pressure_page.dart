import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/health/blood_pressure_model.dart';
import 'package:myapp/health/blood_pressure_service.dart';
import 'package:intl/intl.dart';

class AddBloodPressurePage extends StatefulWidget {
  final String userId;
  final BloodPressureMeasurement? measurement;

  const AddBloodPressurePage({
    super.key,
    required this.userId,
    this.measurement,
  });

  @override
  State<AddBloodPressurePage> createState() => _AddBloodPressurePageState();
}

class _AddBloodPressurePageState extends State<AddBloodPressurePage> {
  final _formKey = GlobalKey<FormState>();
  final _service = BloodPressureService();
  
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _systolicController;
  late TextEditingController _diastolicController;
  late TextEditingController _pulseController;
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedArm = 'left';
  String _selectedPosition = 'sitting';
  String _selectedCondition = 'resting';
  
  bool _isLoading = false;

  bool get _isEditing => widget.measurement != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.measurement?.name ?? '');
    _descriptionController = TextEditingController(text: widget.measurement?.description ?? '');
    _systolicController = TextEditingController(
      text: widget.measurement?.systolic.toString() ?? '',
    );
    _diastolicController = TextEditingController(
      text: widget.measurement?.diastolic.toString() ?? '',
    );
    _pulseController = TextEditingController(
      text: widget.measurement?.pulse.toString() ?? '',
    );
    
    if (widget.measurement != null) {
      _selectedDate = widget.measurement!.date;
      _selectedTime = TimeOfDay.fromDateTime(widget.measurement!.date);
      _selectedArm = widget.measurement!.arm;
      _selectedPosition = widget.measurement!.position;
      _selectedCondition = widget.measurement!.condition;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editMeasurement : l10n.addMeasurement),
        backgroundColor: const Color.fromARGB(255, 182, 142, 190),
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
                  Expanded(
                    child: _buildDateButton(l10n, isArabic),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTimeButton(l10n),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Blood Pressure Values
              _buildSectionTitle('${l10n.systolic} / ${l10n.diastolic}'),
              Row(
                children: [
                  Expanded(
                    child: _buildBloodPressureInput(
                      controller: _systolicController,
                      label: l10n.systolic,
                      hint: l10n.enterSystolic,
                      l10n: l10n,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '/',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildBloodPressureInput(
                      controller: _diastolicController,
                      label: l10n.diastolic,
                      hint: l10n.enterDiastolic,
                      l10n: l10n,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Pulse (optional)
              _buildBloodPressureInput(
                controller: _pulseController,
                label: l10n.pulse,
                hint: l10n.enterPulse,
                l10n: l10n,
                suffix: l10n.bpm,
                required: false,
              ),
              const SizedBox(height: 24),

              // Arm Selection
              _buildSectionTitle(l10n.arm),
              _buildSegmentedButton(
                options: [
                  {'value': 'left', 'label': l10n.leftArm},
                  {'value': 'right', 'label': l10n.rightArm},
                ],
                selectedValue: _selectedArm,
                onChanged: (value) => setState(() => _selectedArm = value),
              ),
              const SizedBox(height: 20),

              // Position Selection
              _buildSectionTitle(l10n.position),
              _buildSegmentedButton(
                options: [
                  {'value': 'sitting', 'label': l10n.sitting},
                  {'value': 'standing', 'label': l10n.standing},
                  {'value': 'lying', 'label': l10n.lyingDown},
                ],
                selectedValue: _selectedPosition,
                onChanged: (value) => setState(() => _selectedPosition = value),
              ),
              const SizedBox(height: 20),

              // Condition Selection
              _buildSectionTitle(l10n.condition),
              _buildConditionChips(l10n),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveMeasurement,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 182, 142, 190),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
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
            const Icon(Icons.calendar_today, color: Color.fromARGB(255, 182, 142, 190)),
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
            const Icon(Icons.access_time, color: Color.fromARGB(255, 182, 142, 190)),
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

  Widget _buildBloodPressureInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required AppLocalizations l10n,
    String? suffix,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 182, 142, 190),
            width: 2,
          ),
        ),
      ),
      validator: required ? (value) {
        if (value == null || value.isEmpty) {
          return l10n.enterSystolic;
        }
        final num = int.tryParse(value);
        if (num == null || num <= 0 || num > 300) {
          return l10n.enterSystolic;
        }
        return null;
      } : null,
    );
  }

  Widget _buildSegmentedButton({
    required List<Map<String, String>> options,
    required String selectedValue,
    required Function(String) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: options.map((option) {
          final isSelected = option['value'] == selectedValue;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(option['value']!),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color.fromARGB(255, 182, 142, 190)
                      : Colors.transparent,
                  borderRadius: BorderRadius.horizontal(
                    left: option == options.first
                        ? const Radius.circular(11)
                        : Radius.zero,
                    right: option == options.last
                        ? const Radius.circular(11)
                        : Radius.zero,
                  ),
                ),
                child: Center(
                  child: Text(
                    option['label']!,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildConditionChips(AppLocalizations l10n) {
    final conditions = [
      {'value': 'resting', 'label': l10n.atRest, 'icon': Icons.airline_seat_recline_normal},
      {'value': 'after_exercise', 'label': l10n.afterExercise, 'icon': Icons.directions_run},
      {'value': 'after_meal', 'label': l10n.afterMeal, 'icon': Icons.restaurant},
      {'value': 'stressed', 'label': l10n.stressed, 'icon': Icons.psychology},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: conditions.map((condition) {
        final isSelected = condition['value'] == _selectedCondition;
        return GestureDetector(
          onTap: () => setState(() => _selectedCondition = condition['value'] as String),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color.fromARGB(255, 182, 142, 190)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? const Color.fromARGB(255, 182, 142, 190)
                    : Colors.grey[300]!,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  condition['icon'] as IconData,
                  size: 18,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  condition['label'] as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
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

      final measurement = BloodPressureMeasurement(
        id: widget.measurement?.id,
        userId: widget.userId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        date: dateTime,
        systolic: int.parse(_systolicController.text),
        diastolic: int.parse(_diastolicController.text),
        pulse: _pulseController.text.isEmpty ? null : int.tryParse(_pulseController.text),
        arm: _selectedArm,
        position: _selectedPosition,
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
