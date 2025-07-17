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
  final List<String> _rememberBeforeOptions = [
    'Month',
    'Week',
    'Day',
    'At time of event',
  ];
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
        final rememberBefore = data['rememberBefore'];
        _selectedRememberBefore = rememberBefore is String ? rememberBefore : (rememberBefore is List && rememberBefore.isNotEmpty ? rememberBefore.first : null);

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
      typeName = locale == 'ar' ? (typeObj['arabicName'] ?? '') : (typeObj['englishName'] ?? '');
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
      priorityName = locale == 'ar' ? (priorityObj['priorityAr'] ?? priorityId) : (priorityObj['priorityEn'] ?? priorityId);
    }
    final rememberBefore = data['rememberBefore']  ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anniversary Info'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextFormField(
              controller: _titleController,
              decoration:  InputDecoration(labelText: AppLocalizations.of(context)!.anntitle),
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration:  InputDecoration(labelText: AppLocalizations.of(context)!.description),
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
                  decoration:  InputDecoration(labelText: AppLocalizations.of(context)!.date),
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
            // Type Dropdown
            DropdownButtonFormField<String>(
              value: _selectedTypeId,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.type),
              items: eventTypes.map<DropdownMenuItem<String>>((type) {
                final id = type['id'].toString();
                final name = locale == 'ar' ? (type['arabicName'] ?? '') : (type['englishName'] ?? '');
                return DropdownMenuItem<String>(
                  value: id,
                  child: Text(name),
                );
              }).toList(),
              onChanged: _isEditing
                  ? (String? newId) {
                      setState(() {
                        _selectedTypeId = newId;
                        // Optionally clear addType field if not Other
                        final selectedType = eventTypes.firstWhere(
                          (type) => type['id'].toString() == newId,
                          orElse: () => <String, dynamic>{},
                        );
                        final isOther = selectedType['englishName'] == 'Other' || selectedType['arabicName'] == 'اخرى' || newId == '4';
                        if (!isOther) {
                          _addTypeController.text = '';
                        }
                      });
                    }
                  : null,
              disabledHint: Text(typeName),
            ),
            
            // Show special name field if selected type is Other (id=4)
            if (_selectedTypeId == '4' && _isEditing) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _addTypeController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.specifyType),
                enabled: _isEditing,
              ),
            ]
            else if (!_isEditing && typeId != null && typeId.toString() == '4') ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _addTypeController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.specifyType),
                enabled: false,
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _relationshipController,
              decoration:  InputDecoration(labelText: AppLocalizations.of(context)!.relationship),
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            // Priority Dropdown
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration:  InputDecoration(labelText: AppLocalizations.of(context)!.priority),
              items: annPriorities.map<DropdownMenuItem<String>>((priority) {
                final value = priority['id'].toString();
                final name = locale == 'ar' ? (priority['priorityAr'] ?? '') : (priority['priorityEn'] ?? '');
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(name),
                );
              }).toList(),
              onChanged:
                  _isEditing
                      ? (val) => setState(() => _selectedPriority = val)
                      : null,
              disabledHint: Text(priorityName),
            ),
            const SizedBox(height: 16),
             Text(
              AppLocalizations.of(context)!.rememberBefore,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Column(
              children: _rememberBeforeOptions.map((option) {
                return RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: _selectedRememberBefore,
                  onChanged: _isEditing
                      ? (String? value) {
                          setState(() {
                            _selectedRememberBefore = value;
                          });
                        }
                      : null,
                );
              }).toList(),
            ),
          ],
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
    if (anniversaryDoc == null) return;
    setState(() => isLoading = true);
    // Calculate rememberBeforeDate
    DateTime? rememberBeforeDate;
    if (_selectedDate != null && _selectedRememberBefore != null) {
      switch (_selectedRememberBefore) {
        case 'Month':
          rememberBeforeDate = _selectedDate!.subtract(const Duration(days: 30));
          break;
        case 'Week':
          rememberBeforeDate = _selectedDate!.subtract(const Duration(days: 7));
          break;
        case 'Day':
          rememberBeforeDate = _selectedDate!.subtract(const Duration(days: 1));
          break;
        case 'At time of event':
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
      'rememberBefore': _selectedRememberBefore,
      'rememberBeforeDate': rememberBeforeDate,
    };
    if (_selectedTypeId == '4') {
      updateData['addType'] = _addTypeController.text;
    } else {
      updateData['addType'] = null;
    }
    await FirebaseFirestore.instance
        .collection('anniversaries')
        .doc(widget.anniversaryId)
        .update(updateData);
    setState(() {
      _isEditing = false;
      isLoading = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Anniversary updated!')));
  }
  void _showDeleteConfirmation() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title:  Text(AppLocalizations.of(context)!.deleteAnniversary),
      content:  Text(AppLocalizations.of(context)!.deleteAnniversaryConfirmation),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child:  Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop(); // Close the dialog
            // Now delete and immediately pop the page if still mounted
            await _deleteAnniversaryAndPop();
          },
          child:  Text(AppLocalizations.of(context)!.delete, style: TextStyle(color: Colors.red)),
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
