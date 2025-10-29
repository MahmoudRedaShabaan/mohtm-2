import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:myapp/lookup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class AddAnniversaryPage extends StatelessWidget {
  const AddAnniversaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF3E6F9),
            Color(0xFFE9D7F7),
            Color(0xFFD6B4F7),
            Color(0xFFC7A1E6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          title: Text(
            AppLocalizations.of(context)!.addAnniversaryTitle,
            style: const TextStyle(
              fontFamily: 'Pacifico',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 80, 40, 120),
            ),
          ),
          // title: Text(AppLocalizations.of(context)!.addAnniversaryTitle),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              color: const Color(0xFFF3E6F9),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: AddAnniversaryForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AddAnniversaryForm extends StatefulWidget {
  const AddAnniversaryForm({super.key});

  @override
  _AddAnniversaryFormState createState() => _AddAnniversaryFormState();
}

class _AddAnniversaryFormState extends State<AddAnniversaryForm> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _relationshipController =
      TextEditingController(); // NEW
  String? _selectedType;
  String? _selectedPriority; // NEW
  String? _dateError; // Track date error state
  final TextEditingController _otherTypeController = TextEditingController();
  // Use eventTypes from LookupService instead of static list

  // Priority options from LookupService
  List<String> get _priorityOptions {
    final locale = Localizations.localeOf(context).languageCode;
    return LookupService().annPriorities.map<String>((priority) {
      return locale == 'ar'
          ? (priority['priorityAr'] ?? '')
          : (priority['priorityEn'] ?? '');
    }).toList();
  }

  // Remember Before options from LookupService
  List<String> get _rememberBeforeOptions {
    final locale = Localizations.localeOf(context).languageCode;
    return LookupService().rememberMe.map<String>((option) {
      return locale == 'ar'
          ? (option['valueAr'] ?? '')
          : (option['valueEn'] ?? '');
    }).toList();
  }

  String _selectedRememberBefore = '';
  static const MethodChannel _widgetChannel = MethodChannel(
    'com.reda.mohtm2/widget',
  );

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set default selection if not set
    if (_selectedRememberBefore.isEmpty && _rememberBeforeOptions.isNotEmpty) {
      _selectedRememberBefore = _rememberBeforeOptions.last;
    }
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction, // <-- Add this line
      child: Column(
        children: <Widget>[
          const SizedBox(height: 7.0),
          GestureDetector(
            onTap: () {
              _selectDate(context).then((_) {
                setState(() {
                  if (_selectedDate != null) _dateError = null;
                });
              });
            },
            child: InputDecorator(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xFF502878)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xFFB365C1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xFF502878)),
                ),
                filled: true,
                fillColor: const Color(0xFFE9D7F7),
                errorText: _dateError,
              ),
              child: Text(
                _selectedDate == null
                    ? AppLocalizations.of(context)!.selectDateLabel
                    : '${_selectedDate!.toLocal()}'.split(' ')[0],
                style: TextStyle(
                  color: _selectedDate == null ? Colors.grey[700] : null,
                ),
              ),
            ),
          ),
          const SizedBox(height: 7.0),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.anniversaryNameLabel,
              hintText: AppLocalizations.of(context)!.anniversaryNameHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(color: Color(0xFF502878)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(color: Color(0xFFB365C1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(color: Color(0xFF502878)),
              ),
              filled: true,
              fillColor: const Color(0xFFE9D7F7),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context)!.anniversaryNameValidation;
              }
              return null;
            },
          ),
          const SizedBox(height: 7.0),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText:
                  AppLocalizations.of(context)!.anniversaryDescriptionLabel,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(color: Color(0xFF502878)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(color: Color(0xFFB365C1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(color: Color(0xFF502878)),
              ),
              filled: true,
              fillColor: const Color(0xFFE9D7F7),
            ),
            maxLines: 3,
            maxLength: 200,
          ),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.type,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(color: Color(0xFF502878)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(color: Color(0xFFB365C1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(color: Color(0xFF502878)),
              ),
              filled: true,
              fillColor: const Color(0xFFE9D7F7),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            dropdownColor: const Color(0xFFE9D7F7),
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF502878)),
            style: const TextStyle(
              color: Color(0xFF502878),
              fontWeight: FontWeight.w500,
            ),
            value: _selectedType,
            onChanged: (String? newValue) {
              setState(() {
                _selectedType = newValue;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context)!.anniversarytypeValidation;
              }
              return null;
            },
            items:
                LookupService().eventTypes.map<DropdownMenuItem<String>>((
                  type,
                ) {
                  final locale = Localizations.localeOf(context).languageCode;
                  final value =
                      locale == 'ar'
                          ? (type['arabicName'] ?? '')
                          : (type['englishName'] ?? '');
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(color: Color(0xFF502878)),
                    ),
                  );
                }).toList(),
          ),
          if (_selectedType == 'Other' || _selectedType == 'اخرى') ...[
            const SizedBox(height: 7.0),
            TextFormField(
              controller: _otherTypeController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.specifyType,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xFF502878)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xFFB365C1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xFF502878)),
                ),
                filled: true,
                fillColor: const Color(0xFFE9D7F7),
              ),
              validator: (value) {
                if ((_selectedType == 'Other' || _selectedType == 'اخرى') &&
                    (value == null || value.isEmpty)) {
                  return AppLocalizations.of(
                    context,
                  )!.anniversaryOtherTypeValidation;
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: 7.0),
          TextFormField(
            controller: _relationshipController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.relationship,
              hintText: AppLocalizations.of(context)!.relationshipHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(color: Color(0xFF502878)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(color: Color(0xFFB365C1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(color: Color(0xFF502878)),
              ),
              filled: true,
              fillColor: const Color(0xFFE9D7F7),
            ),
          ),
          const SizedBox(height: 7.0),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.priority,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(color: Color(0xFF502878)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(color: Color(0xFFB365C1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(color: Color(0xFF502878)),
              ),
              filled: true,
              fillColor: const Color(0xFFE9D7F7),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            dropdownColor: const Color(0xFFE9D7F7),
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF502878)),
            style: const TextStyle(
              color: Color(0xFF502878),
              fontWeight: FontWeight.w500,
            ),
            value: _selectedPriority,
            onChanged: (String? newValue) {
              setState(() {
                _selectedPriority = newValue;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context)!.priorityValidation;
              }
              return null;
            },
            items:
                _priorityOptions
                    .map(
                      (priority) => DropdownMenuItem<String>(
                        value: priority,
                        child: Text(
                          priority,
                          style: const TextStyle(color: Color(0xFF502878)),
                        ),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 7.0),
          Text(
            AppLocalizations.of(context)!.rememberBefore,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF502878),
            ),
          ),
          Column(
            children:
                _rememberBeforeOptions.map((option) {
                  return RadioListTile<String>(
                    title: Text(
                      option,
                      style: const TextStyle(color: Color(0xFF502878)),
                    ),
                    value: option,
                    groupValue: _selectedRememberBefore,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedRememberBefore = value!;
                      });
                    },
                    activeColor: const Color(0xFFB365C1),
                  );
                }).toList(),
          ),
          const SizedBox(height: 24.0),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  _isLoading
                      ? null
                      : () async {
                        setState(() {
                          _isLoading = true;
                          _dateError =
                              _selectedDate == null
                                  ? AppLocalizations.of(context)!.dateValidation
                                  : null;
                        });
                        if (_formKey.currentState!.validate() &&
                            _selectedDate != null) {
                          String res = await uploadTask();
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(res)));
                          // Always try to refresh the widget after an add attempt
                          await _updateOccasionWidgetFromToday();
                          if (res ==
                              AppLocalizations.of(
                                context,
                              )!.annAddSuccessfully) {
                            // After successful add, refresh widget from today's data
                            await Future.delayed(
                              const Duration(milliseconds: 200),
                            );
                            Navigator.pop(context);
                            if (mounted) {
                              Navigator.of(
                                context,
                              ).popUntil((route) => route.isFirst);
                            }
                          }
                        }
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD6B4F7),
                foregroundColor: const Color(0xFF502878),
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: Color(0xFFB365C1)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child:
                  _isLoading
                      ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Color(0xFF502878),
                          strokeWidth: 3,
                        ),
                      )
                      : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          AppLocalizations.of(context)!.save,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String> uploadTask() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return AppLocalizations.of(context)!.userNotLogin;
      } else {
        // Get rememberMe option by localized value
        final locale = Localizations.localeOf(context).languageCode;
        final rememberMeList = LookupService().rememberMe;
        final selectedOption = rememberMeList.firstWhere(
          (option) =>
              (locale == 'ar' ? option['valueAr'] : option['valueEn']) ==
              _selectedRememberBefore,
          orElse: () => <String, dynamic>{},
        );
        final rememberBeforeId = selectedOption['id'];
        // Calculate rememberBeforeDate based on id
        DateTime? rememberBeforeDate;
        if (_selectedDate != null && rememberBeforeId != null) {
          switch (rememberBeforeId.toString()) {
            case '1': // Month
              rememberBeforeDate = _selectedDate!.subtract(
                const Duration(days: 30),
              );
              break;
            case '2': // Week
              rememberBeforeDate = _selectedDate!.subtract(
                const Duration(days: 7),
              );
              break;
            case '3': // Day
              rememberBeforeDate = _selectedDate!.subtract(
                const Duration(days: 1),
              );
              break;
            case '4': // At time of event
            default:
              rememberBeforeDate = _selectedDate;
          }
        }
        await FirebaseFirestore.instance.collection("anniversaries").add({
          "title": _nameController.text,
          "description": _descriptionController.text,
          "date": _selectedDate, // Firestore will store as Timestamp
          "type":
              (() {
                if (locale == 'ar') {
                  final typeObj = LookupService().eventTypes.firstWhere(
                    (type) =>
                        type['arabicName']?.toString().trim() ==
                        _selectedType?.toString().trim(),
                    orElse: () => <String, dynamic>{},
                  );
                  return typeObj.containsKey('id') ? typeObj['id'] : null;
                } else {
                  final typeObj = LookupService().eventTypes.firstWhere(
                    (type) =>
                        type['englishName']?.toString().trim() ==
                        _selectedType?.toString().trim(),
                    orElse: () => <String, dynamic>{},
                  );
                  return typeObj.containsKey('id') ? typeObj['id'] : null;
                }
              })(),
          if (_selectedType == 'Other' || _selectedType == 'اخرى')
            "addType": _otherTypeController.text,
          "relationship": _relationshipController.text,
          "priority":
              (() {
                final priorityObj = LookupService().annPriorities.firstWhere(
                  (priority) =>
                      (locale == 'ar'
                          ? priority['priorityAr']
                          : priority['priorityEn']) ==
                      _selectedPriority,
                  orElse: () => <String, dynamic>{},
                );
                return priorityObj.containsKey('id')
                    ? priorityObj['id']
                    : _selectedPriority;
              })(),
          "rememberBefore": rememberBeforeId,
          "rememberBeforeDate": rememberBeforeDate,
          "color": 0xFF000000, // Example color code
          "createdBy": user.uid,
          "createdAt": FieldValue.serverTimestamp(),
        });
        return AppLocalizations.of(context)!.annAddSuccessfully;
      }
    } catch (e) {
      print(e);
      return AppLocalizations.of(context)!.failtoAddAnniversary;
    }
  }

  Future<void> _updateOccasionWidgetFromToday() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final today = DateTime.now();
      final snap =
          await FirebaseFirestore.instance
              .collection('anniversaries')
              .where('createdBy', isEqualTo: user.uid)
              .get();
      final docs =
          snap.docs.where((doc) {
            final Timestamp? ts = doc['date'];
            if (ts == null) return false;
            final d = ts.toDate();
            return d.month == today.month && d.day == today.day;
          }).toList();

      final prefs = await SharedPreferences.getInstance();
      final locale = Localizations.localeOf(context).languageCode;
      final eventTypes = LookupService().eventTypes;
      final int totalCount = docs.length;
      final List<Map<String, dynamic>> items =
          docs.take(5).map((doc) {
            final date = (doc['date'] as Timestamp?)?.toDate();
            final String dateStr =
                date != null ? '${date.day}/${date.month}/${date.year}' : '';
            final String title = (doc['title'] ?? '').toString();
            final String typeId = (doc['type']?.toString() ?? '');
            String typeName = typeId;
            if (typeId.isNotEmpty) {
              if (typeId == '4') {
                typeName = doc['addType']?.toString() ?? '';
              } else {
                final typeObj = eventTypes.firstWhere(
                  (type) => type['id'].toString() == typeId,
                  orElse: () => <String, dynamic>{},
                );
                typeName =
                    locale == 'ar'
                        ? (typeObj['arabicName'] ?? typeId)
                        : (typeObj['englishName'] ?? typeId);
              }
            }
            final relationship = (doc['relationship'] ?? '').toString();
            return {
              'title': title,
              'date': dateStr,
              'type': typeName,
              'relationship': relationship,
            };
          }).toList();
      final payload = {'items': items, 'total': totalCount};
      await prefs.setString('widget_occasion_items', jsonEncode(payload));
      await _widgetChannel.invokeMethod('updateOccasionWidget');
    } catch (_) {
      // ignore
    }
  }
}
