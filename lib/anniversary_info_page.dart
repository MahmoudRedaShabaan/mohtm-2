import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  late TextEditingController _typeController;
  late TextEditingController _relationshipController;
  late TextEditingController _priorityController;
  DateTime? _selectedDate;
  String? _selectedPriority;

  // For multi-selection display
  final List<String> _rememberBeforeOptions = [
    'Month',
    'Week',
    'Day',
    'Hour',
    'At time of event',
  ];
  List<String> _selectedRememberBefore = [];

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
        final rememberBefore = (data['rememberBefore'] as List?) ?? [];
        _selectedRememberBefore = List<String>.from(rememberBefore);

        _titleController = TextEditingController(text: data['title'] ?? '');
        _descriptionController = TextEditingController(
          text: data['description'] ?? '',
        );
        _typeController = TextEditingController(text: data['type'] ?? '');
        _relationshipController = TextEditingController(
          text: data['relationship'] ?? '',
        );
        _priorityController = TextEditingController(
          text: data['priority'] ?? '',
        );
        _selectedPriority = data['priority'] ?? '';
        _selectedDate = (data['date'] as Timestamp).toDate();
      }
    });
  }

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
    final type = data['type'] ?? '';
    final relationship = data['relationship'] ?? '';
    final priority = data['priority'] ?? '';
    final rememberBefore = (data['rememberBefore'] as List?) ?? [];

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
              decoration: const InputDecoration(labelText: 'Title'),
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
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
                  decoration: const InputDecoration(labelText: 'Date'),
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
            TextFormField(
              controller: _typeController,
              decoration: const InputDecoration(labelText: 'Type'),
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _relationshipController,
              decoration: const InputDecoration(labelText: 'Relationship'),
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            // Priority Dropdown
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: const InputDecoration(labelText: 'Priority'),
              items:
                  ['High', 'Medium', 'Low']
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
              onChanged:
                  _isEditing
                      ? (val) => setState(() => _selectedPriority = val)
                      : null,
              disabledHint: Text(_selectedPriority ?? ''),
            ),
            const SizedBox(height: 16),
            const Text(
              'Remember Before',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Column(
              children:
                  _rememberBeforeOptions.map((option) {
                    final isAtTime = option == 'At time of event';
                    return CheckboxListTile(
                      title: Text(option),
                      value: _selectedRememberBefore.contains(option),
                      onChanged:
                          _isEditing && !isAtTime
                              ? (checked) {
                                setState(() {
                                  if (checked == true) {
                                    _selectedRememberBefore.add(option);
                                  } else {
                                    _selectedRememberBefore.remove(option);
                                  }
                                });
                              }
                              : null,
                      controlAffinity: ListTileControlAffinity.leading,
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
    await FirebaseFirestore.instance
        .collection('anniversaries')
        .doc(widget.anniversaryId)
        .update({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'type': _typeController.text,
          'relationship': _relationshipController.text,
          'priority': _selectedPriority,
          'date': _selectedDate,
          'rememberBefore': _selectedRememberBefore,
        });
    setState(() {
      _isEditing = false;
      isLoading = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Anniversary updated!')));
  }

  // void _showDeleteConfirmation() {
  //   showDialog(
  //     context: context,
  //     builder:
  //         (context) => AlertDialog(
  //           title: const Text('Delete Anniversary'),
  //           content: const Text(
  //             'Are you sure you want to delete this anniversary?',
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.of(context).pop(),
  //               child: const Text('Cancel'),
  //             ),
  //             TextButton(
  //               onPressed: () async {
  //                 Navigator.of(context).pop();
  //                 await _deleteAnniversary();
                  
  //               },
  //               // if (mounted) {
  //               //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //               //       Navigator.of(context).pop();
  //               //       ScaffoldMessenger.of(context).showSnackBar(
  //               //         const SnackBar(content: Text('Anniversary deleted!')),
  //               //       );
  //               //     });
  //               //   }
  //               child: const Text(
  //                 'Delete',
  //                 style: TextStyle(color: Colors.red),
  //               ),
  //             ),
  //           ],
  //         ),
  //   );
  // }

  // Future<void> _deleteAnniversary() async {
  //   // if (anniversaryDoc == null) return;
  //   // await FirebaseFirestore.instance
  //   //     .collection('anniversaries')
  //   //     .doc(widget.anniversaryId)
  //   //     .delete();
  //   // if (mounted) {
  //   //   Navigator.of(context).pop(); // Go back after deletion
  //   //   ScaffoldMessenger.of(
  //   //     context,
  //   //   ).showSnackBar(const SnackBar(content: Text('Anniversary deleted!')));
  //   // }
  // //   if (anniversaryDoc == null) return;
  // // await FirebaseFirestore.instance
  // //     .collection('anniversaries')
  // //     .doc(widget.anniversaryId)
  // //     .delete();
  // // if (!mounted) return;
  // // // Use a post-frame callback to ensure context is valid
  // // WidgetsBinding.instance.addPostFrameCallback((_) {
  // //   Navigator.of(context).pop(); // Go back after deletion
  // //   ScaffoldMessenger.of(context).showSnackBar(
  // //     const SnackBar(content: Text('Anniversary deleted!')),
  // //   );
  // // });
  //  if (anniversaryDoc == null) return;
  // await FirebaseFirestore.instance
  //     .collection('anniversaries')
  //     .doc(widget.anniversaryId)
  //     .delete();
  // if (!mounted) return;
  // WidgetsBinding.instance.addPostFrameCallback((_) {
  //   if (!mounted) return; // <--- Extra safety check
  //   Navigator.of(context).pop(); // Go back after deletion
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('Anniversary deleted!')),
  //   );
  // });
  // }
  void _showDeleteConfirmation() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Anniversary'),
      content: const Text('Are you sure you want to delete this anniversary?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop(); // Close the dialog
            // Now delete and immediately pop the page if still mounted
            await _deleteAnniversaryAndPop();
          },
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
