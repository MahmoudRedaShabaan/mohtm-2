import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'daily_deed/custom_daily_deed_model.dart';
import 'daily_deed/custom_daily_deed_service.dart';
import 'daily_deed/constants.dart';

class AddCustomDailyDeedPage extends StatefulWidget {
  final CustomDailyDeed? deed; // If provided, we're editing

  const AddCustomDailyDeedPage({super.key, this.deed});

  @override
  State<AddCustomDailyDeedPage> createState() => _AddCustomDailyDeedPageState();
}

class _AddCustomDailyDeedPageState extends State<AddCustomDailyDeedPage> {
  final _formKey = GlobalKey<FormState>();
  final _deedNameController = TextEditingController();
  bool _isForever = true;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  bool get _isEditing => widget.deed != null;

  @override
  void initState() {
    super.initState();
    if (widget.deed != null) {
      _deedNameController.text = widget.deed!.name;
      _isForever = widget.deed!.isForever;
      _startDate = widget.deed!.startDate;
      _endDate = widget.deed!.endDate;
    }
  }

  @override
  void dispose() {
    _deedNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate =
        isStartDate
            ? (_startDate ?? DateTime.now())
            : (_endDate ?? _startDate ?? DateTime.now());

    final firstDate =
        isStartDate ? DateTime(2020) : (_startDate ?? DateTime.now());

    final lastDate = DateTime(2100);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // If end date is before start date, reset it
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _saveDeed() async {
    final localization = AppLocalizations.of(context)!;

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate dates if not forever
    if (!_isForever) {
      if (_startDate == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(localization.selectStartDate)));
        return;
      }
      if (_endDate == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(localization.selectEndDate)));
        return;
      }
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isEditing) {
        // Update existing deed
        final updatedDeed = widget.deed!.copyWith(
          name: _deedNameController.text.trim(),
          isForever: _isForever,
          startDate: _startDate,
          endDate: _endDate,
        );
        await CustomDailyDeedService.updateCustomDeed(updatedDeed);
      } else {
        // Create new deed
        final newDeed = CustomDailyDeed.create(
          userId: user.uid,
          name: _deedNameController.text.trim(),
          isForever: _isForever,
          startDate: _startDate,
          endDate: _endDate,
        );
        await CustomDailyDeedService.createCustomDeed(newDeed);
      }

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteDeed() async {
    final localization = AppLocalizations.of(context)!;

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(localization.deleteDeed),
            content: Text(localization.deleteDeedConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(localization.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  localization.delete,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm == true && widget.deed != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        await CustomDailyDeedService.deleteCustomDeed(widget.deed!.id);
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? localization.editCustomDeed : localization.addCustomDeed,
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF4DB6AC),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _isLoading ? null : _deleteDeed,
            ),
        ],
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
                      // Deed
                      TextFormField(
                        controller: _deedNameController,
                        decoration: InputDecoration(
                          labelText: localization.deedName,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.edit_note),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return localization.enterDeedName;
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.done,
                      ),

                      const SizedBox(height: 24),

                      // Forever checkbox
                      Container(
                        decoration: BoxDecoration(
                          color: DeedColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: CheckboxListTile(
                          title: Text(
                            localization.forever,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            _isForever
                                ? 'This deed will appear every day'
                                : 'This deed will appear within selected dates',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          value: _isForever,
                          onChanged: (value) {
                            setState(() {
                              _isForever = value ?? true;
                              if (_isForever) {
                                _startDate = null;
                                _endDate = null;
                              }
                            });
                          },
                          activeColor: DeedColors.primary,
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),

                      // Date pickers (only if not forever)
                      if (!_isForever) ...[
                        const SizedBox(height: 16),

                        // Start Date
                        InkWell(
                          onTap: () => _selectDate(context, true),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: DeedColors.cardBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    _startDate == null
                                        ? Colors.orange.shade300
                                        : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color:
                                      _startDate == null
                                          ? Colors.orange
                                          : DeedColors.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        localization.startDate,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        _startDate != null
                                            ? _formatDate(_startDate!)
                                            : localization.selectStartDate,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              _startDate != null
                                                  ? Colors.black
                                                  : Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_startDate != null)
                                  IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _startDate = null;
                                        _endDate = null;
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // End Date
                        InkWell(
                          onTap:
                              _startDate != null
                                  ? () => _selectDate(context, false)
                                  : null,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: DeedColors.cardBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    _endDate == null
                                        ? Colors.orange.shade300
                                        : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color:
                                      _endDate == null
                                          ? Colors.orange
                                          : DeedColors.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        localization.endDate,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        _endDate != null
                                            ? _formatDate(_endDate!)
                                            : (_startDate != null
                                                ? localization.selectEndDate
                                                : localization.selectStartDate),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              _endDate != null
                                                  ? Colors.black
                                                  : Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_endDate != null)
                                  IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _endDate = null;
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveDeed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DeedColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _isEditing ? localization.save : localization.add,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
