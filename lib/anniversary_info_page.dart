import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:myapp/lookup.dart';

class AnniversaryInfoPage extends StatefulWidget {
  final String anniversaryId;

  const AnniversaryInfoPage({super.key, required this.anniversaryId});

  @override
  State<AnniversaryInfoPage> createState() => _AnniversaryInfoPageState();
}

class _AnniversaryInfoPageState extends State<AnniversaryInfoPage> {
  DocumentSnapshot? anniversaryDoc;
  bool isLoading = true;
  bool _isEditing = false;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _relationshipController;
  late TextEditingController _priorityController;
  late TextEditingController _addTypeController;
  DateTime? _selectedDate;
  String? _selectedPriority;

  // For multi-selection display
  List<Map<String, dynamic>> get _rememberMeList => LookupService().rememberMe;
  List<String> get _rememberBeforeOptions {
    final locale = Localizations.localeOf(context).languageCode;
    return _rememberMeList.map<String>((option) {
      return locale == 'ar'
          ? (option['valueAr'] ?? '')
          : (option['valueEn'] ?? '');
    }).toList();
  }

  String? _selectedRememberBefore;

  @override
  void initState() {
    super.initState();
    fetchAnniversary();
  }

  Future<void> fetchAnniversary() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('anniversaries')
            .doc(widget.anniversaryId)
            .get();
    setState(() {
      anniversaryDoc = doc;
      isLoading = false;
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final rememberBeforeId = data['rememberBefore']?.toString();
        if (rememberBeforeId != null) {
          final locale = Localizations.localeOf(context).languageCode;
          final option = _rememberMeList.firstWhere(
            (opt) => opt['id'].toString() == rememberBeforeId,
            orElse: () => <String, dynamic>{},
          );
          _selectedRememberBefore =
              locale == 'ar'
                  ? (option['valueAr'] ?? '')
                  : (option['valueEn'] ?? '');
        } else {
          _selectedRememberBefore = null;
        }

        _titleController = TextEditingController(text: data['title'] ?? '');
        _descriptionController = TextEditingController(
          text: data['description'] ?? '',
        );
        _relationshipController = TextEditingController(
          text: data['relationship'] ?? '',
        );
        _priorityController = TextEditingController(
          text: data['priority'] ?? '',
        );
        _selectedPriority = data['priority'] ?? '';
        _selectedDate = (data['date'] as Timestamp).toDate();
        _selectedTypeId = data['type']?.toString();
        _addTypeController = TextEditingController(text: data['addType'] ?? '');
      }
    });
  }

  String? _selectedTypeId;

  void _editAnniversary() {
    // TODO: Implement navigation to edit page or inline editing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit functionality not implemented yet.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (anniversaryDoc == null || !anniversaryDoc!.exists) {
      return const Scaffold(
        body: Center(child: Text('Anniversary not found.')),
      );
    }
    final data = anniversaryDoc!.data() as Map<String, dynamic>;
    final date = (data['date'] as Timestamp).toDate();
    final title = data['title'] ?? '';
    final description = data['description'] ?? '';
    final typeId = data['type'];
    final locale = Localizations.localeOf(context).languageCode;
    final eventTypes = LookupService().eventTypes;
    String typeName = '';
    if (_selectedTypeId != null) {
      final typeObj = eventTypes.firstWhere(
        (type) => type['id'].toString() == _selectedTypeId,
        orElse: () => <String, dynamic>{},
      );
      typeName =
          locale == 'ar'
              ? (typeObj['arabicName'] ?? '')
              : (typeObj['englishName'] ?? '');
    }
    final relationship = data['relationship'] ?? '';
    final priorityId = data['priority']?.toString() ?? '';
    final annPriorities = LookupService().annPriorities;
    String priorityName = priorityId;
    if (priorityId.isNotEmpty) {
      final priorityObj = annPriorities.firstWhere(
        (p) => p['id'].toString() == priorityId,
        orElse: () => <String, dynamic>{},
      );
      priorityName =
          locale == 'ar'
              ? (priorityObj['priorityAr'] ?? priorityId)
              : (priorityObj['priorityEn'] ?? priorityId);
    }
    final rememberBefore = data['rememberBefore'] ?? '';

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
            AppLocalizations.of(context)!.occasionDetails,
            style: const TextStyle(
              fontFamily: 'Pacifico',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 80, 40, 120),
            ),
          ),
          //title:  Text(AppLocalizations.of(context)!.occasionDetails),
          actions: [
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              onPressed: () {
                if (_isEditing) {
                  _saveChanges();
                } else {
                  _toggleEdit();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _showDeleteConfirmation,
            ),
          ],
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
                child: ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.anntitle,
                        filled: true,
                        fillColor: const Color(0xFFE9D7F7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(
                            color: Color(0xFF502878),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(
                            color: Color(0xFFB365C1),
                          ),
                        ),
                      ),
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.description,
                        filled: true,
                        fillColor: const Color(0xFFE9D7F7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(
                            color: Color(0xFF502878),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(
                            color: Color(0xFFB365C1),
                          ),
                        ),
                      ),
                      enabled: _isEditing,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap:
                          _isEditing
                              ? () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate ?? DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _selectedDate = picked;
                                  });
                                }
                              }
                              : null,
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.date,
                            filled: true,
                            fillColor: const Color(0xFFE9D7F7),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                color: Color(0xFF502878),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                color: Color(0xFFB365C1),
                              ),
                            ),
                          ),
                          enabled: _isEditing,
                          controller: TextEditingController(
                            text:
                                _selectedDate != null
                                    ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                    : '',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedTypeId,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.type,
                        filled: true,
                        fillColor: const Color(0xFFE9D7F7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(
                            color: Color(0xFF502878),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(
                            color: Color(0xFFB365C1),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      dropdownColor: const Color(0xFFE9D7F7),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Color(0xFF502878),
                      ),
                      style: const TextStyle(
                        color: Color(0xFF502878),
                        fontWeight: FontWeight.w500,
                      ),
                      items:
                          eventTypes.map<DropdownMenuItem<String>>((type) {
                            final id = type['id'].toString();
                            final name =
                                locale == 'ar'
                                    ? (type['arabicName'] ?? '')
                                    : (type['englishName'] ?? '');
                            return DropdownMenuItem<String>(
                              value: id,
                              child: Text(
                                name,
                                style: const TextStyle(
                                  color: Color(0xFF502878),
                                ),
                              ),
                            );
                          }).toList(),
                      onChanged:
                          _isEditing
                              ? (String? newId) {
                                setState(() {
                                  _selectedTypeId = newId;
                                  final selectedType = eventTypes.firstWhere(
                                    (type) => type['id'].toString() == newId,
                                    orElse: () => <String, dynamic>{},
                                  );
                                  final isOther =
                                      selectedType['englishName'] == 'Other' ||
                                      selectedType['arabicName'] == 'اخرى' ||
                                      newId == '4';
                                  if (!isOther) {
                                    _addTypeController.text = '';
                                  }
                                });
                              }
                              : null,
                      disabledHint: Text(
                        typeName,
                        style: const TextStyle(color: Color(0xFF502878)),
                      ),
                    ),
                    if (_selectedTypeId == '4' && _isEditing) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addTypeController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.specifyType,
                          filled: true,
                          fillColor: const Color(0xFFE9D7F7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(
                              color: Color(0xFF502878),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(
                              color: Color(0xFFB365C1),
                            ),
                          ),
                        ),
                        enabled: _isEditing,
                      ),
                    ] else if (!_isEditing &&
                        typeId != null &&
                        typeId.toString() == '4') ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addTypeController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.specifyType,
                          filled: true,
                          fillColor: const Color(0xFFE9D7F7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(
                              color: Color(0xFF502878),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(
                              color: Color(0xFFB365C1),
                            ),
                          ),
                        ),
                        enabled: false,
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _relationshipController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.relationship,
                        filled: true,
                        fillColor: const Color(0xFFE9D7F7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(
                            color: Color(0xFF502878),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(
                            color: Color(0xFFB365C1),
                          ),
                        ),
                      ),
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedPriority,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.priority,
                        filled: true,
                        fillColor: const Color(0xFFE9D7F7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(
                            color: Color(0xFF502878),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(
                            color: Color(0xFFB365C1),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      dropdownColor: const Color(0xFFE9D7F7),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Color(0xFF502878),
                      ),
                      style: const TextStyle(
                        color: Color(0xFF502878),
                        fontWeight: FontWeight.w500,
                      ),
                      items:
                          annPriorities.map<DropdownMenuItem<String>>((
                            priority,
                          ) {
                            final value = priority['id'].toString();
                            final name =
                                locale == 'ar'
                                    ? (priority['priorityAr'] ?? '')
                                    : (priority['priorityEn'] ?? '');
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                name,
                                style: const TextStyle(
                                  color: Color(0xFF502878),
                                ),
                              ),
                            );
                          }).toList(),
                      onChanged:
                          _isEditing
                              ? (val) => setState(() => _selectedPriority = val)
                              : null,
                      disabledHint: Text(
                        priorityName,
                        style: const TextStyle(color: Color(0xFF502878)),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                                style: const TextStyle(
                                  color: Color(0xFF502878),
                                ),
                              ),
                              value: option,
                              groupValue: _selectedRememberBefore,
                              onChanged:
                                  _isEditing
                                      ? (String? value) {
                                        setState(() {
                                          _selectedRememberBefore = value;
                                        });
                                      }
                                      : null,
                              activeColor: const Color(0xFFB365C1),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveChanges() async {
    // Validation for mandatory fields
    String? errorMsg;
    if (_titleController.text.trim().isEmpty) {
      errorMsg = AppLocalizations.of(context)!.anniversaryNameValidation;
    } else if (_selectedDate == null) {
      errorMsg = AppLocalizations.of(context)!.dateValidation;
    } else if (_selectedTypeId == null || _selectedTypeId!.isEmpty) {
      errorMsg = AppLocalizations.of(context)!.anniversarytypeValidation;
    } else if (_selectedPriority == null || _selectedPriority!.isEmpty) {
      errorMsg = AppLocalizations.of(context)!.priorityValidation;
    }
    if (errorMsg != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMsg)));
      return;
    }
    if (anniversaryDoc == null) return;
    setState(() => isLoading = true);
    // Calculate rememberBeforeDate and id
    final locale = Localizations.localeOf(context).languageCode;
    String? rememberBeforeId;
    DateTime? rememberBeforeDate;
    if (_selectedDate != null && _selectedRememberBefore != null) {
      final selectedOption = _rememberMeList.firstWhere(
        (option) =>
            (locale == 'ar' ? option['valueAr'] : option['valueEn']) ==
            _selectedRememberBefore,
        orElse: () => <String, dynamic>{},
      );
      rememberBeforeId = selectedOption['id']?.toString();
      switch (rememberBeforeId) {
        case '1': // Month
          rememberBeforeDate = _selectedDate!.subtract(
            const Duration(days: 30),
          );
          break;
        case '2': // Week
          rememberBeforeDate = _selectedDate!.subtract(const Duration(days: 7));
          break;
        case '3': // Day
          rememberBeforeDate = _selectedDate!.subtract(const Duration(days: 1));
          break;
        case '4': // At time of event
        default:
          rememberBeforeDate = _selectedDate;
      }
    }
    final updateData = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'type': _selectedTypeId,
      'relationship': _relationshipController.text,
      'priority': _selectedPriority,
      'date': _selectedDate,
      'rememberBefore': rememberBeforeId,
      'rememberBeforeDate': rememberBeforeDate,
    };
    if (_selectedTypeId == '4') {
      updateData['addType'] = _addTypeController.text;
    } else {
      updateData['addType'] = null;
    }
    try {
      await FirebaseFirestore.instance
          .collection('anniversaries')
          .doc(widget.anniversaryId)
          .update(updateData);
      setState(() {
        _isEditing = false;
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.annUpdateSuccessfully),
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.failtoUpdateAnniversary),
        ),
      );
      print('Error updating anniversary: $e');
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.deleteAnniversary),
            content: Text(
              AppLocalizations.of(context)!.deleteAnniversaryConfirmation,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Close the dialog
                  // Now delete and immediately pop the page if still mounted
                  await _deleteAnniversaryAndPop();
                },
                child: Text(
                  AppLocalizations.of(context)!.delete,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteAnniversaryAndPop() async {
    if (anniversaryDoc == null) return;
    await FirebaseFirestore.instance
        .collection('anniversaries')
        .doc(widget.anniversaryId)
        .delete();
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pop();
      // Optionally show a snackbar here if you have access to the previous context
    });
  }
}
