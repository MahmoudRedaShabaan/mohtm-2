import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'general_deeds_model.dart';
import 'package:myapp/widgets/app_banner_ad.dart';


class AddGeneralDeedPage extends StatefulWidget {
  final GeneralDeed? deed;

  const AddGeneralDeedPage({super.key, this.deed});

  @override
  State<AddGeneralDeedPage> createState() => _AddGeneralDeedPageState();
}

class _AddGeneralDeedPageState extends State<AddGeneralDeedPage> {
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
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveDeed() async {
    final localization = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      return;
    }

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
        final updatedDeed = widget.deed!.copyWith(
          name: _deedNameController.text.trim(),
          isForever: _isForever,
          startDate: _startDate,
          endDate: _endDate,
        );
        await GeneralDeedService.updateGeneralDeed(updatedDeed);
      } else {
        final newDeed = GeneralDeed.create(
          userId: user.uid,
          name: _deedNameController.text.trim(),
          isForever: _isForever,
          startDate: _startDate,
          endDate: _endDate,
        );
        await GeneralDeedService.createGeneralDeed(newDeed);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
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

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? localization.editCustomDeed : localization.addCustomDeed,
        ),
        backgroundColor: const Color(0xFF4DB6AC),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localization.deedName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _deedNameController,
                decoration: InputDecoration(
                  hintText: localization.enterDeedName,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.edit),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return localization.enterDeedName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                title: Text(localization.forever),
                value: _isForever,
                onChanged: (value) {
                  setState(() {
                    _isForever = value;
                    if (value) {
                      _startDate = null;
                      _endDate = null;
                    }
                  });
                },
                activeColor: const Color(0xFF4DB6AC),
              ),
              if (!_isForever) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, true),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: localization.startDate,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _startDate != null
                                ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                : localization.selectStartDate,
                            style: TextStyle(
                              color:
                                  _startDate != null
                                      ? Colors.black
                                      : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, false),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: localization.endDate,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.event),
                          ),
                          child: Text(
                            _endDate != null
                                ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                : localization.selectEndDate,
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
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveDeed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4DB6AC),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Text(
                            localization.save,
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
}
