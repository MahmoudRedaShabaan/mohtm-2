import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'add_reminder.dart';

Future<void> _openExactAlarmSettings(BuildContext context) async {
  final intent = const AndroidIntent(
    action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
    flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
  );
  await intent.launch();
}

class UpdateReminderPage extends StatefulWidget {
  final String reminderId;
  final Map<String, dynamic> reminderData;

  const UpdateReminderPage({
    Key? key,
    required this.reminderId,
    required this.reminderData,
  }) : super(key: key);

  @override
  State<UpdateReminderPage> createState() => _UpdateReminderPageState();
}

class _UpdateReminderPageState extends State<UpdateReminderPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  DateTime? _selectedDateTime;
  bool _isUpdating = false;
  String _repeat = "Don't repeat";
  String _durationType = 'until';
  int? _repeatCount;
  DateTime? _untilDate;
  int _repeatInterval = 1;
  List<int> _selectedWeekdays = [];
  bool _isEditing = false;
  List<String> _notificationIds = [];

  final List<String> _repeatUnits = [
    'minute',
    'hour',
    'day',
    'week',
    'month',
    'year',
  ];
  String _selectedRepeatUnit = 'minute';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final data = widget.reminderData;
    _titleController.text = data['title'] ?? '';
    _selectedDateTime = (data['dateTime'] as Timestamp).toDate();
    _repeat = data['repeat'] ?? "Don't repeat";
    _durationType = data['durationType'] ?? 'forever';
    _repeatCount = data['repeatCount'];
    _untilDate =
        data['untilDate'] != null
            ? (data['untilDate'] as Timestamp).toDate()
            : null;
    _repeatInterval = data['repeatInterval'] ?? 1;
    _selectedWeekdays = List<int>.from(data['weekdays'] ?? []);
    _selectedRepeatUnit = data['repeatUnit'] ?? 'minute';
    _notificationIds = List<String>.from(data['notificationIds'] ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String getUnitText(String unit) {
    switch (unit) {
      case 'minute':
        return 'unit_minute';
      case 'hour':
        return 'unit_hour';
      case 'day':
        return 'unit_day';
      case 'week':
        return 'unit_week';
      case 'month':
        return 'unit_month';
      case 'year':
        return 'unit_year';
      default:
        return '';
    }
  }

  Future<void> _pickDateTime() async {
    if (!_isEditing) return;

    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime:
          _selectedDateTime != null
              ? TimeOfDay.fromDateTime(_selectedDateTime!)
              : TimeOfDay.now(),
    );
    if (time == null) return;
    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _showRepeatOptions() async {
    if (!_isEditing) return;

    String? selected;
    int tempInterval = _repeatInterval;
    String tempUnit = _selectedRepeatUnit;
    List<int> tempWeekdays = [];
    final TextEditingController intervalController = TextEditingController(
      text: tempInterval.toString(),
    );
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<String>(
                      title: Text(AppLocalizations.of(context)!.dontrepeat),
                      value: "Don't repeat",
                      groupValue:
                          selected ??
                          (_repeat == 'Every x unit'
                              ? 'Every x unit'
                              : _repeat),
                      onChanged: (val) {
                        setModalState(() {
                          selected = val;
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Text(AppLocalizations.of(context)!.every),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 60,
                            child: TextField(
                              controller: intervalController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 8,
                                ),
                                hintText: '1-99',
                              ),
                              onChanged: (val) {
                                final n = int.tryParse(val);
                                if (n != null && n >= 1 && n <= 99) {
                                  setModalState(() {
                                    tempInterval = n;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    ..._repeatUnits.map(
                      (unit) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RadioListTile<String>(
                            title: Text(
                              unit == 'minute'
                                  ? AppLocalizations.of(context)!.unit_minute
                                  : unit == 'hour'
                                  ? AppLocalizations.of(context)!.unit_hour
                                  : unit == 'day'
                                  ? AppLocalizations.of(context)!.unit_day
                                  : unit == 'week'
                                  ? AppLocalizations.of(context)!.unit_week
                                  : unit == 'month'
                                  ? AppLocalizations.of(context)!.unit_month
                                  : unit == 'year'
                                  ? AppLocalizations.of(context)!.unit_year
                                  : unit,
                            ),
                            value: unit,
                            groupValue:
                                selected == 'Every x unit' ? tempUnit : null,
                            onChanged: (val) {
                              setModalState(() {
                                selected = 'Every x unit';
                                tempUnit = val!;
                              });
                            },
                            secondary:
                                selected == 'Every x unit' && tempUnit == unit
                                    ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    )
                                    : null,
                          ),
                          if (unit == 'week' &&
                              selected == 'Every x unit' &&
                              tempUnit == 'week')
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 32.0,
                                bottom: 8.0,
                              ),
                              child: StatefulBuilder(
                                builder: (context, setDayState) {
                                  final dayLabels = [
                                    'M',
                                    'T',
                                    'W',
                                    'T',
                                    'F',
                                    'S',
                                    'S',
                                  ];
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: List.generate(
                                      7,
                                      (i) => Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 2.0,
                                          ),
                                          child: ChoiceChip(
                                            label: Text(dayLabels[i]),
                                            selected: tempWeekdays.contains(
                                              i + 1,
                                            ),
                                            onSelected: (selected) {
                                              setDayState(() {
                                                if (selected) {
                                                  tempWeekdays.add(i + 1);
                                                } else {
                                                  tempWeekdays.remove(i + 1);
                                                }
                                              });
                                              setModalState(() {});
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (selected == null) return;
                          if (selected == "Don't repeat") {
                            Navigator.pop(context, "Don't repeat");
                            return;
                          }
                          final n = int.tryParse(intervalController.text);
                          if (n == null || n < 1 || n > 99) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.validNumberbetween,
                                ),
                              ),
                            );
                            return;
                          }
                          tempInterval = n;
                          if (tempUnit == 'week' && tempWeekdays.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.pleaseselectAtLeastOneWeekday,
                                ),
                              ),
                            );
                            return;
                          }
                          Navigator.pop(context, {
                            'repeat':
                                'Every ' +
                                intervalController.text +
                                ' ' +
                                tempUnit,
                            'interval': tempInterval,
                            'unit': tempUnit,
                            if (tempUnit == 'week')
                              'weekdays': List<int>.from(tempWeekdays),
                          });
                        },
                        child: Text(AppLocalizations.of(context)!.confirm),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
    if (result is String && result == "Don't repeat") {
      setState(() {
        _repeat = "Don't repeat";
        _durationType = 'forever';
        _repeatCount = null;
        _untilDate = null;
      });
    } else if (result is Map) {
      setState(() {
        _repeat = result['repeat'];
        _repeatInterval = result['interval'];
        _selectedRepeatUnit = result['unit'];
        _selectedWeekdays = List<int>.from(result['weekdays'] ?? []);
      });
    }
  }

  Widget _buildDurationOptions() {
    if (_repeat == "Don't repeat") return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(AppLocalizations.of(context)!.duration + ':'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ChoiceChip(
                label: Text(AppLocalizations.of(context)!.untilDate),
                selected: _durationType == 'until',
                onSelected:
                    _isEditing
                        ? (selected) {
                          setState(() {
                            _durationType = 'until';
                            _repeatCount = null;
                          });
                        }
                        : null,
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text(AppLocalizations.of(context)!.count),
                selected: _durationType == 'count',
                onSelected:
                    _isEditing
                        ? (selected) {
                          setState(() {
                            _durationType = 'count';
                            _repeatCount = 1;
                            _untilDate = null;
                          });
                        }
                        : null,
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text(AppLocalizations.of(context)!.forever),
                selected: _durationType == 'forever',
                onSelected:
                    _isEditing
                        ? (selected) {
                          setState(() {
                            _durationType = 'forever';
                            _repeatCount = null;
                            _untilDate = null;
                          });
                        }
                        : null,
              ),
              
            ],
          ),
        ),
        if (_durationType == 'count')
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextFormField(
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.repeatCount,
              ),
              keyboardType: TextInputType.number,
              initialValue: _repeatCount?.toString(),
              validator: (value) {
                if (_isEditing) {
                  if (value == null || value.isEmpty)
                    return AppLocalizations.of(context)!.repeatCountRequired;
                  final n = int.tryParse(value);
                  if (n == null || n < 1)
                    return AppLocalizations.of(context)!.repeatCountvalidation;
                }
                return null;
              },
              onChanged:
                  _isEditing
                      ? (value) {
                        setState(() {
                          _repeatCount = int.tryParse(value);
                        });
                      }
                      : null,
            ),
          ),
        if (_durationType == 'until')
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Text(AppLocalizations.of(context)!.untilDate2 + ': '),
                Text(
                  _untilDate == null
                      ? AppLocalizations.of(context)!.notSet
                      : _untilDate!.toString().split(' ')[0],
                ),
                if (_isEditing)
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _untilDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _untilDate = picked;
                        });
                      }
                    },
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _updateReminder() async {
    if (_isUpdating) return; // prevent double-press
    setState(() {
      _isUpdating = true;
    });
    if (!_formKey.currentState!.validate()) {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
      return;
    }
    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseselecydatetime),
        ),
      );
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
      return;
    } else if (_selectedDateTime?.isBefore(DateTime.now()) ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.selectfuturedatetime),
        ), //Text('Please select a future date and time.')),
      );
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
      return;
    }
    if(_repeat!='Don\'t repeat'){
    if (_durationType == 'until' && _untilDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseselectanuntildate),
        ), //Text('Please select an until date.')),
      );
      setState(() {
        _isUpdating = false;
      });
      return;
    }
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Cancel existing notifications
      for (String notificationId in _notificationIds) {
        int notifInt = int.tryParse(notificationId) ?? 0;
        await flutterLocalNotificationsPlugin.cancel(notifInt);
      }

      // Delete old reminder from Firebase
      await FirebaseFirestore.instance
          .collection('reminders')
          .doc(widget.reminderId)
          .delete();

  // Create new reminder data
      final reminder = {
        'userId': user.uid,
        'title': _titleController.text.trim(),
        'dateTime': _selectedDateTime,
        'repeat': _repeat,
        'repeatInterval': _repeat == "Don't repeat" ? null : _repeatInterval,
        'repeatUnit': _repeat == "Don't repeat" ? null : _selectedRepeatUnit,
        'durationType': _repeat == "Don't repeat" ? null : _durationType,
        'repeatCount': _durationType == 'count' ? _repeatCount : null,
        'untilDate': _durationType == 'until' ? _untilDate : null,
        'weekdays': _selectedRepeatUnit == 'week' ? _selectedWeekdays : null,
        'createdAt': FieldValue.serverTimestamp(),
        'notificationIds': [],
      };

      // Add new reminder to Firebase
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('reminders')
          .add(reminder);

      // Schedule new notifications
      //newNotificationIds
      var result = await scheduleReminderNotification(
        id: DateTime.now().millisecondsSinceEpoch % 1000000,
        title: _titleController.text.trim(),
        dateTime: _selectedDateTime!,
        repeatUnit: _repeat == "Don't repeat" ? null : _selectedRepeatUnit,
        repeatInterval: _repeat == "Don't repeat" ? null : _repeatInterval,
        repeatCount: _durationType == 'count' ? _repeatCount : null,
        untilDate: _durationType == 'until' ? _untilDate : null,
        weekdays: _selectedRepeatUnit == 'week' ? _selectedWeekdays : null,
        timeOfReminder: AppLocalizations.of(context)!.timeOfReminder,
      );

      // Update with notification IDs
      await docRef.update({
        'notificationIds': result.$1,
        'notificationTimes': result.$2,
      });
      // await docRef.update({'notificationTimes': result.$2});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.reminderUpdatedSuccessfully,
            ),
          ),
        );
        Navigator.pop(context);
      }
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorUpdatingReminder +
                  e.toString(),
            ),
          ),
        );
      }
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  // Future<void> _deleteReminder() async {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text(AppLocalizations.of(context)!.reminderDelete),
  //         content: Text(
  //           AppLocalizations.of(context)!.reminderDeleteConfirmation,
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text(AppLocalizations.of(context)!.cancel),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: Text(AppLocalizations.of(context)!.delete),
  //             onPressed: () async {
  //              // Navigator.of(context).pop();
  //               bool success = false;
  //               String? errorMsg;
  //               try {
  //                 // Cancel notifications
  //                 for (String notificationId in _notificationIds) {
  //                   int notifInt = int.tryParse(notificationId) ?? 0;
  //                   await flutterLocalNotificationsPlugin.cancel(notifInt);
  //                 }
  //                 // Delete from Firebase
  //                 await FirebaseFirestore.instance
  //                     .collection('reminders')
  //                     .doc(widget.reminderId)
  //                     .delete();
  //                 success = true;
  //                 if (!mounted) return;
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   SnackBar(
  //                     content: Text(
  //                       AppLocalizations.of(
  //                         context,
  //                       )!.reminderDeletedSuccessfully,
  //                     ),
  //                   ),
  //                 );
  //                 Navigator.pop(context);
  //               } catch (e) {
  //                 errorMsg =
  //                     AppLocalizations.of(context)!.errorDeletingReminder +
  //                     e.toString();
  //                 if (!mounted) return;
  //                 ScaffoldMessenger.of(
  //                   context,
  //                 ).showSnackBar(SnackBar(content: Text(errorMsg)));
  //               }

  //               // Navigate first, then show snackbar using root messenger
  //               // if (mounted) {
  //               //   Navigator.of(context).pop();
  //               //   await Future.delayed(const Duration(milliseconds: 100));
  //               //   final messenger =
  //               //       ScaffoldMessenger.maybeOf(context) ??
  //               //       ScaffoldMessenger.maybeOf(Navigator.of(context).context);
  //               //   if (messenger != null) {
  //               //     messenger.showSnackBar(
  //               //       SnackBar(
  //               //         content: Text(
  //               //           success
  //               //               ? AppLocalizations.of(
  //               //                 context,
  //               //               )!.reminderDeletedSuccessfully
  //               //               : errorMsg ??
  //               //                   AppLocalizations.of(
  //               //                     context,
  //               //                   )!.errorDeletingReminder,
  //               //         ),
  //               //       ),
  //               //     );
  //               //   }
  //               // }
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  Future<void> _deleteReminder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.reminderDelete),
            content: Text(
              AppLocalizations.of(context)!.reminderDeleteConfirmation,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(AppLocalizations.of(context)!.delete),
              ),
            ],
          ),
    );
    if (confirm != true) return;
    try {
      String id = widget.reminderId;
      List<String> notificationIds;
      print('Deleting reminder with ID: $id');
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('No user logged in. Cannot delete reminder.');
        return;
      }
      final ref = FirebaseFirestore.instance.collection('reminders').doc(id);
      final doc = await ref.get();
      if (ref.id.isNotEmpty) {
        notificationIds = List<String>.from(doc['notificationIds'] ?? []);
        print(notificationIds.length);
        print(notificationIds);
        print(ref.id);

        for (String notificationId in notificationIds) {
          print(notificationId);
          int notifInt = int.tryParse(notificationId) ?? 0;
          await flutterLocalNotificationsPlugin.cancel(notifInt);

          debugPrint('Canceled local notification with ID: $notificationId');
        }
        await ref.delete();
      }

      // await FirebaseFirestore.instance
      //     .collection('reminders')
      //     .doc(widget.reminderId)
      //     .delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.reminderDeletedSuccessfully,
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error deleting reminder: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.errorDeletingReminder + e.toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update Reminder',
          style: const TextStyle(
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
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteReminder,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode:
              AutovalidateMode.onUserInteraction, // <-- Add this line
          child: ListView(
            children: [
              // if (_isEditing)
              //   Card(
              //     elevation: 2,
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //     child: Padding(
              //       padding: const EdgeInsets.all(16),
              //       child: Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           Text(
              //             AppLocalizations.of(
              //               context,
              //             )!.fixNotificationsPermission,
              //             style: TextStyle(
              //               fontWeight: FontWeight.w600,
              //               color: Colors.grey[800],
              //             ),
              //           ),
              //           const SizedBox(height: 8),
              //           ElevatedButton.icon(
              //             onPressed: () => _openExactAlarmSettings(context),
              //             icon: const Icon(Icons.settings),
              //             label: Text(
              //               AppLocalizations.of(
              //                 context,
              //               )!.fixNotificationsPermission,
              //             ),
              //             style: ElevatedButton.styleFrom(
              //               backgroundColor: secondaryColor,
              //               foregroundColor: Colors.white,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              TextFormField(
                controller: _titleController,
                enabled: _isEditing,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.reminderTitle,
                ),
                maxLength: 100,
                validator: (value) {
                  if (_isEditing) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(
                        context,
                      )!.reminderTitleRequired;
                    }
                    if (value.length > 100) {
                      return AppLocalizations.of(context)!.reminderTitleTooLong;
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.calendar_today,
                    color: Colors.deepPurple,
                  ),
                  title: Text(
                    _selectedDateTime == null
                        ? AppLocalizations.of(context)!.selecydatetime
                        : DateFormat(
                          'dd-MM-yyyy hh:mm a',
                        ).format(_selectedDateTime!),
                  ),
                  onTap: _pickDateTime,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.repeat, color: Colors.deepPurple),
                  title: Text(
                    AppLocalizations.of(context)!.repeat +
                        ': ' +
                        (_repeat == 'Every x unit'
                            ? 'Every $_repeatInterval $_selectedRepeatUnit'
                            : _repeat),
                  ),
                  onTap: _showRepeatOptions,
                ),
              ),
              _buildDurationOptions(),
              if (_isEditing) ...[
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: !_isUpdating ? _updateReminder : null,
                  //onPressed: _updateReminder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isUpdating
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Text(AppLocalizations.of(context)!.modify),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
