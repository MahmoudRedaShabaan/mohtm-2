import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'constants.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _taskNameController = TextEditingController();
  DateTime? _selectedDueDate;
  String? _selectedCategoryId;
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('userTaskCategory')
              .where('userId', isEqualTo: user.uid)
              .get();

      setState(() {
        _categories =
            snapshot.docs
                .map(
                  (doc) => {'id': doc.id, 'name': doc['name'], ...doc.data()},
                )
                .toList();
      });
    } catch (e) {
      print('Error loading categories: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.errorloadingcategories + e.toString(),
          ),
        ),
      );
    }
  }

  Future<void> _addCategory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final TextEditingController controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.addCategory),
          content: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction, // <-- Add this line
            child: TextFormField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.categoryName,
                border: OutlineInputBorder(),
              ),
              maxLength: 50,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(context)!.namecategoryRequired;
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context, controller.text.trim());
                }
              },
              child: Text(AppLocalizations.of(context)!.add),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('userTaskCategory')
            .add({
              'name': result,
              'userId': user.uid,
              'createdAt': FieldValue.serverTimestamp(),
            });
        await _loadCategories();
        if (mounted) {
          setState(() {
            _selectedCategoryId = doc.id;
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.erroraddingcategory + e.toString(),
            ),
          ),
        );
      }
    }
  }

  Future<void> _manageCategories() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLocalizations.of(context)!.manageCategories2,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final String name = category['name']?.toString() ?? '';
                    return ListTile(
                      title: Text(name),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                        onPressed: () async {
                          final lower = name.toLowerCase();
                          if (lower == 'default') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.defaultcategorycannotberemoved,
                                ),
                              ),
                            );
                            return;
                          }
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:
                                (_) => AlertDialog(
                                  title: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.removeCategory,
                                  ),
                                  content: Text(
                                    AppLocalizations.of(context)!.removing +
                                        name +
                                        AppLocalizations.of(
                                          context,
                                        )!.removingcatmessage,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, false),
                                      child: const Text('No'),
                                    ),
                                    ElevatedButton(
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                      child: const Text('Yes'),
                                    ),
                                  ],
                                ),
                          );
                          if (confirm != true) return;
                          try {
                            // Delete all tasks for this category (user scoped) in batches
                            final String categoryId = category['id'] as String;
                            final user = FirebaseAuth.instance.currentUser;
                            if (user == null) return;
                            const int batchLimit = 450;
                            while (true) {
                              final qs =
                                  await FirebaseFirestore.instance
                                      .collection('tasks')
                                      .where('userId', isEqualTo: user.uid)
                                      .where(
                                        'categoryId',
                                        isEqualTo: categoryId,
                                      )
                                      .limit(batchLimit)
                                      .get();
                              if (qs.docs.isEmpty) break;
                              final batch = FirebaseFirestore.instance.batch();
                              for (final d in qs.docs) {
                                batch.delete(d.reference);
                              }
                              await batch.commit();
                              if (qs.docs.length < batchLimit) break;
                            }
                            await FirebaseFirestore.instance
                                .collection('userTaskCategory')
                                .doc(categoryId)
                                .delete();
                            await _loadCategories();
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.categoryanditstasksremoved,
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(
                                        context,
                                      )!.errorremovingcategory +
                                      e.toString(),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: AppLocalizations.of(context)!.selectDueDate,
    );
    if (picked != null) {
      if (picked.year >= DateTime.now().year &&
          picked.month >= DateTime.now().month &&
          picked.day >= DateTime.now().day) {
        setState(() {
          _selectedDueDate = picked;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.selectfuturedatetime),
          ),
        );
      }
      // if (picked != null && picked != _selectedDueDate) {
      //   setState(() {
      //     _selectedDueDate = picked;
      //   });
      // }
    }
  }

  Future<String> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return AppLocalizations.of(context)!.error+' : '+AppLocalizations.of(context)!.pleasefillinallrequiredfields;
    }

    if (_selectedCategoryId == null) {
      return AppLocalizations.of(context)!.error+' : '+AppLocalizations.of(context)!.pleaseselectacategory;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return AppLocalizations.of(context)!.error+' : '+AppLocalizations.of(context)!.usernotauthenticated;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final taskData = {
        'taskname': _taskNameController.text.trim(),
        'duedate':
            _selectedDueDate != null
                ? Timestamp.fromDate(_selectedDueDate!)
                : null,
        'categoryId': _selectedCategoryId,
        'userId': user.uid,
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('tasks').add(taskData);

      return AppLocalizations.of(context)!.tasksavedSuccessfully;
    } catch (e) {
      print('Error saving task: $e');
      return AppLocalizations.of(context)!.error+' : '+AppLocalizations.of(context)!.errorsavingtask + e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          Localizations.localeOf(context).languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.addTask,
            style: TextStyle(
              fontFamily: 'Pacifico',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 80, 40, 120),
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 182, 142, 190),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction, // <-- Add this line
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Task Name Field
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.taskName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _taskNameController,
                          decoration: InputDecoration(
                            hintText:
                                AppLocalizations.of(context)!.enterTaskName,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          maxLength: 100,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return AppLocalizations.of(
                                context,
                              )!.tasknameisrequired;
                            }
                            if (value.trim().length > 100) {
                              return AppLocalizations.of(
                                context,
                              )!.tasknamemustbe100charactersorless;
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Due Date Field
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.dueDate,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _selectDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[400]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedDueDate != null
                                      ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                                      : AppLocalizations.of(
                                        context,
                                      )!.selectDueDate,
                                  style: TextStyle(
                                    color:
                                        _selectedDueDate != null
                                            ? Colors.black87
                                            : Colors.grey[600],
                                  ),
                                ),
                                const Spacer(),
                                if (_selectedDueDate != null)
                                  IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      setState(() {
                                        _selectedDueDate = null;
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.nonotificationifdatenotset,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Category Field
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.category1,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String?>(
                          isDense: true,
                          isExpanded: true,
                          value: _selectedCategoryId,
                          decoration: InputDecoration(
                            hintText:
                                AppLocalizations.of(context)!.selectcategory,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          items: <DropdownMenuItem<String?>>[
                            ..._categories.map(
                              (category) => DropdownMenuItem<String?>(
                                value: category['id'] as String,
                                child: Text(category['name']?.toString() ?? ''),
                              ),
                            ),
                            DropdownMenuItem<String?>(
                              value: '__add__',
                              child: Text(
                                AppLocalizations.of(context)!.addNewCategory,
                              ),
                            ),
                            DropdownMenuItem<String?>(
                              value: '__manage__',
                              child: Text(
                                AppLocalizations.of(context)!.manageCategories,
                              ),
                            ),
                          ],
                          onChanged: (value) async {
                            if (value == '__add__') {
                              await _addCategory();
                              return;
                            }
                            if (value == '__manage__') {
                              await _manageCategories();
                              return;
                            }
                            setState(() {
                              _selectedCategoryId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(
                                context,
                              )!.pleaseselectacategory;
                            }
                            return null;
                          },
                        ),
                        if (_categories.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              AppLocalizations.of(context)!.nocategoryfound,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[700],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Save Button
                ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () async {
                            final result = await _saveTask();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result),
                                  backgroundColor:
                                      result.contains('Error')
                                          ? Colors.red
                                          : Colors.green,
                                ),
                              );
                              if (!result.contains('Error')) {
                                Navigator.pop(context);
                              }
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Text(
                            AppLocalizations.of(context)!.saveTask,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
