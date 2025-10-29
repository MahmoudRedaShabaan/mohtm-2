import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class UpdateTaskPage extends StatefulWidget {
  final String taskId;
  const UpdateTaskPage({super.key, required this.taskId});

  @override
  State<UpdateTaskPage> createState() => _UpdateTaskPageState();
}

class _UpdateTaskPageState extends State<UpdateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _taskNameController = TextEditingController();
  DateTime? _selectedDueDate;
  String? _selectedCategoryId;
  String _status = 'open';
  bool _isEditing = false;
  bool _loading = true;
  bool _saving = false;
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    await Future.wait([_loadCategories(), _loadTask()]);
    if (!mounted) return;
    setState(() {
      _loading = false;
    });
  }

  Future<void> _loadCategories() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('userTaskCategory')
        .where('userId', isEqualTo: user.uid)
        .get();
    setState(() {
      _categories = snapshot.docs.map((d) => {
        'id': d.id,
        'name': d['name'],
        ...d.data(),
      }).toList();
    });
  }

  Future<void> _loadTask() async {
    final doc = await FirebaseFirestore.instance.collection('tasks').doc(widget.taskId).get();
    if (!doc.exists) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text(AppLocalizations.of(context)!.taskNotFound)));
        Navigator.pop(context);
      }
      return;
    }
    final data = doc.data()!;
    _taskNameController.text = data['taskname'] ?? '';
    final ts = data['duedate'] as Timestamp?;
    _selectedDueDate = ts?.toDate();
    _selectedCategoryId = data['categoryId'];
    _status = (data['status'] ?? 'open').toString();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2100, 12, 31),
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
   }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
    });
    try {
      await FirebaseFirestore.instance.collection('tasks').doc(widget.taskId).update({
        'taskname': _taskNameController.text.trim(),
        'duedate': _selectedDueDate != null ? Timestamp.fromDate(_selectedDueDate!) : null,
        'categoryId': _selectedCategoryId,
        'status': _status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text(AppLocalizations.of(context)!.taskUpdated)));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.errorUpdating+e.toString())));
    } finally {
      if (!mounted) return;
      setState(() {
        _saving = false;
      });
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title:  Text(AppLocalizations.of(context)!.removeTask),
        content:  Text(AppLocalizations.of(context)!.areYouSureYouWantToRemoveThisTask),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child:  Text(AppLocalizations.of(context)!.no)),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child:  Text(AppLocalizations.of(context)!.yes )),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await FirebaseFirestore.instance.collection('tasks').doc(widget.taskId).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text(AppLocalizations.of(context)!.taskRemoved)));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.errorRemovingTask+e.toString())));
    }
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Localizations.localeOf(context).languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title:  Text(
            AppLocalizations.of(context)!.taskDetails,
            style: TextStyle(
              fontFamily: 'Pacifico',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 80, 40, 120),
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 182, 142, 190),
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
          actions: [
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              onPressed: () async {
                if (_isEditing) {
                  await _save();
                } else {
                  setState(() {
                    _isEditing = true;
                  });
                }
              },
              tooltip: _isEditing ? 'Save' : 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
              tooltip: 'Remove',
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction, // <-- Add this line
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                             Text(AppLocalizations.of(context)!.taskName),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _taskNameController,
                              maxLength: 100,
                              readOnly: !_isEditing,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return AppLocalizations.of(context)!.tasknameisrequired ;
                                if (v.trim().length > 100)  return AppLocalizations.of(context)!.tasknamemustbe100charactersorless;
                                return null;
                              },
                              decoration: const InputDecoration(border: OutlineInputBorder()),
                            ),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                             Text(AppLocalizations.of(context)!.dueDate),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: _isEditing ? _selectDate : null,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[400]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(children: [
                                  Icon(Icons.calendar_today, color: Colors.grey[600], size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    _selectedDueDate != null ? _formatDate(_selectedDueDate!) : AppLocalizations.of(context)!.selectDueDate,
                                    style: TextStyle(color: _selectedDueDate != null ? Colors.black87 : Colors.grey[600]),
                                  ),
                                  const Spacer(),
                                  if (_isEditing && _selectedDueDate != null)
                                    IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () => setState(() => _selectedDueDate = null),
                                    ),
                                ]),
                              ),
                            ),
                            const SizedBox(height: 4),
                             Text(AppLocalizations.of(context)!.nonotificationifdatenotset, style: TextStyle(fontSize: 12)),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                             Text(AppLocalizations.of(context)!.category1),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedCategoryId,
                              items: _categories
                                  .map((c) => DropdownMenuItem<String>(value: c['id'], child: Text(c['name'])))
                                  .toList(),
                              onChanged: _isEditing
                                  ? (v) => setState(() {
                                        _selectedCategoryId = v;
                                      })
                                  : null,
                              validator: (v) => (v == null || v.isEmpty) ? AppLocalizations.of(context)!.pleaseselectacategory : null,
                            ),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                             Text(AppLocalizations.of(context)!.statusTask),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _status,
                              items:  [
                                DropdownMenuItem(value: 'open', child: Text(AppLocalizations.of(context)!.open)),
                                DropdownMenuItem(value: 'done', child: Text(AppLocalizations.of(context)!.done)),
                              ],
                              onChanged: _isEditing ? (v) => setState(() => _status = v ?? 'open') : null,
                            ),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_isEditing)
                        ElevatedButton(
                          onPressed: _saving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _saving
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                              :  Text(AppLocalizations.of(context)!.modify, style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}


