import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/health/health_info_model.dart';
import 'package:myapp/health/health_info_service.dart';
import 'package:intl/intl.dart';

class MedicalNotesPage extends StatefulWidget {
  final String userId;

  const MedicalNotesPage({super.key, required this.userId});

  @override
  State<MedicalNotesPage> createState() => _MedicalNotesPageState();
}

class _MedicalNotesPageState extends State<MedicalNotesPage> {
  final HealthInfoService _service = HealthInfoService();
  List<MedicalNote> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      final notes = await _service.getMedicalNotes(widget.userId);
      if (!mounted) return;
      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteNote(MedicalNote note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.confirmDelete),
            content: Text(AppLocalizations.of(context)!.deleteNoteConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(AppLocalizations.of(context)!.delete),
              ),
            ],
          ),
    );

    if (confirmed == true && note.id != null) {
      await _service.deleteMedicalNote(note.id!);
      _loadNotes();
    }
  }

  void _showAddNoteDialog({MedicalNote? existingNote}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => AddMedicalNotePage(
              userId: widget.userId,
              existingNote: existingNote,
            ),
      ),
    ).then((_) => _loadNotes());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.medicalNotes),
        backgroundColor: const Color(0xFF673AB7),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _notes.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.note_alt_outlined,
                      size: 64,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noMedicalNotes,
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.addMedicalNoteHint,
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  final note = _notes[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.teal.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.note,
                                  color: Colors.teal,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat.yMMMd(
                                        isArabic ? 'ar' : 'en',
                                      ).format(note.timestamp),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      DateFormat.jm(
                                        isArabic ? 'ar' : 'en',
                                      ).format(note.timestamp),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            note.content,
                            style: const TextStyle(fontSize: 15),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed:
                                    () =>
                                        _showAddNoteDialog(existingNote: note),
                                icon: const Icon(Icons.edit, size: 18),
                                label: Text(l10n.edit),
                              ),
                              TextButton.icon(
                                onPressed: () => _deleteNote(note),
                                icon: const Icon(
                                  Icons.delete,
                                  size: 18,
                                  color: Colors.red,
                                ),
                                label: Text(
                                  l10n.delete,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteDialog(),
        backgroundColor: const Color(0xFF673AB7),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class AddMedicalNotePage extends StatefulWidget {
  final String userId;
  final MedicalNote? existingNote;

  const AddMedicalNotePage({
    super.key,
    required this.userId,
    this.existingNote,
  });

  @override
  State<AddMedicalNotePage> createState() => _AddMedicalNotePageState();
}

class _AddMedicalNotePageState extends State<AddMedicalNotePage> {
  final HealthInfoService _service = HealthInfoService();
  final _formKey = GlobalKey<FormState>();

  final _contentController = TextEditingController();
  DateTime _timestamp = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingNote != null) {
      _contentController.text = widget.existingNote!.content;
      _timestamp = widget.existingNote!.timestamp;
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(bool isDate) async {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final locale = isArabic ? const Locale('ar') : const Locale('en');

    if (isDate) {
      final picked = await showDatePicker(
        context: context,
        initialDate: _timestamp,
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
      );
      if (picked != null) {
        setState(() {
          _timestamp = DateTime(
            picked.year,
            picked.month,
            picked.day,
            _timestamp.hour,
            _timestamp.minute,
          );
        });
      }
    } else {
      final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_timestamp),
      );
      if (picked != null) {
        setState(() {
          _timestamp = DateTime(
            _timestamp.year,
            _timestamp.month,
            _timestamp.day,
            picked.hour,
            picked.minute,
          );
        });
      }
    }
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final note = MedicalNote(
        id: widget.existingNote?.id,
        userId: widget.userId,
        content: _contentController.text.trim(),
        timestamp: _timestamp,
        createdAt: widget.existingNote?.createdAt ?? DateTime.now(),
      );

      if (widget.existingNote != null) {
        await _service.updateMedicalNote(note);
      } else {
        await _service.addMedicalNote(note);
      }

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
        title: Text(
          widget.existingNote != null
              ? l10n.editMedicalNote
              : l10n.addMedicalNote,
        ),
        backgroundColor: const Color(0xFF673AB7),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timestamp
              _buildSectionTitle(l10n.dateAndTime),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDateTime(true),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          DateFormat.yMMMd(
                            isArabic ? 'ar' : 'en',
                          ).format(_timestamp),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDateTime(false),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.access_time),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          DateFormat.jm(
                            isArabic ? 'ar' : 'en',
                          ).format(_timestamp),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Note Content
              _buildSectionTitle(l10n.noteContent),
              TextFormField(
                controller: _contentController,
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: l10n.enterNoteContent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.pleaseEnterValue;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveNote,
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
