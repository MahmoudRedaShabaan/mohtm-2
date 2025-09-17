import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'constants.dart';
// import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
//import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> _openExactAlarmSettings(BuildContext context) async {
  final intent = const AndroidIntent(
    action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
    flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
  );
  await intent.launch();
}

Future<bool> _shouldShowExactAlarmDialog() async {
  final deviceInfo = DeviceInfoPlugin();
  final androidInfo = await deviceInfo.androidInfo;
  return androidInfo.version.sdkInt >= 31;
}

class AddReminderPage extends StatefulWidget {
  const AddReminderPage({Key? key}) : super(key: key);

  @override
  State<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  DateTime? _selectedDateTime;
  String _repeat = "Don't repeat";
  String _durationType = 'forever';
  int? _repeatCount;
  DateTime? _untilDate;
  int _repeatInterval = 1;
  List<int> _selectedWeekdays = [];

  //final List<String> _repeatOptions = ["Don't repeat", 'Every x unit'];
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
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
                            //title: Text('$unit'),
                            //title: Text(AppLocalizations.of(context)!.unit($unit)),
                            // title: Text(AppLocalizations.of(context)!.getUnitText(unit)),
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
                                        // <<-- Changed this line
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
                                  )!.validNumberbetween, //
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
                label: Text(AppLocalizations.of(context)!.forever),
                selected: _durationType == 'forever',
                onSelected: (selected) {
                  setState(() {
                    _durationType = 'forever';
                    _repeatCount = null;
                    _untilDate = null;
                  });
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text(AppLocalizations.of(context)!.count),
                selected: _durationType == 'count',
                onSelected: (selected) {
                  setState(() {
                    _durationType = 'count';
                    _repeatCount = 1;
                    _untilDate = null;
                  });
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text(AppLocalizations.of(context)!.untilDate),
                selected: _durationType == 'until',
                onSelected: (selected) {
                  setState(() {
                    _durationType = 'until';
                    _repeatCount = null;
                  });
                },
              ),
            ],
          ),
        ),
        if (_durationType == 'count')
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.repeatCount,
              ),
              keyboardType: TextInputType.number,
              initialValue: _repeatCount?.toString(),
              validator: (value) {
                if (value == null || value.isEmpty)
                  return AppLocalizations.of(context)!.repeatCountRequired;
                final n = int.tryParse(value);
                if (n == null || n < 1)
                  return AppLocalizations.of(context)!.repeatCountvalidation;
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _repeatCount = int.tryParse(value);
                });
              },
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
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
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

  Future<void> _saveReminder() async {
    List<String> notificationIds = [];
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseselecydatetime),
        ), //Text('Please select date & time.')),
      );
      return;
    } else if (_selectedDateTime?.isBefore(DateTime.now()) ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.selectfuturedatetime),
        ), //Text('Please select a future date and time.')),
      );
      return;
    }
    if (_durationType == 'until' && _untilDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseselectanuntildate),
        ), //Text('Please select an until date.')),
      );
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
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
    DocumentReference docRef = await FirebaseFirestore.instance
        .collection('reminders')
        .add(reminder);
    // Prompt for exact alarm permission if needed
    // await _requestExactAlarmPermission();
    // Schedule local notification
    try {
      notificationIds = await scheduleReminderNotification(
        id: DateTime.now().millisecondsSinceEpoch % 1000000, // simple unique id
        title: _titleController.text.trim(),
        dateTime: _selectedDateTime!,
        repeatUnit: _repeat == "Don't repeat" ? null : _selectedRepeatUnit,
        repeatInterval: _repeat == "Don't repeat" ? null : _repeatInterval,
        repeatCount: _durationType == 'count' ? _repeatCount : null,
        untilDate: _durationType == 'until' ? _untilDate : null,
        weekdays: _selectedRepeatUnit == 'week' ? _selectedWeekdays : null,
        timeOfReminder: AppLocalizations.of(context)!.timeOfReminder,
      );
      docRef.update({'notificationIds': notificationIds});
    } catch (e) {
      if (await _shouldShowExactAlarmDialog()) {
        showDialog(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: Text(AppLocalizations.of(context)!.permissionRequired),
                content: Text(
                  AppLocalizations.of(context)!.exactAlarmPermissionMessage,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      await _openExactAlarmSettings(context);
                    },
                    child: Text(AppLocalizations.of(context)!.open_sertings),
                  ),
                ],
              ),
        );
      }
      rethrow;
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.addReminder,
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
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
                        AppLocalizations.of(
                          context,
                        )!.fixNotificationsPermission,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => _openExactAlarmSettings(context),
                        icon: const Icon(Icons.settings),
                        label: Text(
                          AppLocalizations.of(
                            context,
                          )!.fixNotificationsPermission,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.reminderTitle,
                ),
                maxLength: 100,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context)!.reminderTitleRequired;
                  }
                  if (value.length > 100) {
                    return AppLocalizations.of(context)!.reminderTitleTooLong;
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
                        : _selectedDateTime!.toString(),
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
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveReminder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.saveReminder),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<List<String>> scheduleReminderNotification({
  required int id,
  required String title,
  required DateTime dateTime,
  String? repeatUnit, // 'minute', 'hour', etc.
  int? repeatInterval, // e.g. 5 for every 5 minutes
  int? repeatCount, // for specific number of times
  DateTime? untilDate, // for until a date
  List<int>? weekdays, // only for weekly
  required String timeOfReminder,
}) async {
  List<String> notificationIds = [];
  try {
    print("i am here before .");
    var androidDetails = const AndroidNotificationDetails(
      'reminder_channel_alarm',
      'Reminders',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('reminder'),
    );
    var notificationDetails = NotificationDetails(android: androidDetails);

    if (repeatUnit == null) {
      // One-time
      print("i am here repeated null before .");
      // final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      //final location = tz.getLocation(timeZoneName);
     // print(tz.TZDateTime.from(dateTime, location));
      // print(TZDateTime.from(dateTime));
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        timeOfReminder,
        tz.TZDateTime.from(dateTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        // payload: tz.TZDateTime.from(dateTime, location).toIso8601String(),
        payload: 'reminder_channel_alarm',
      );
      print("i am here repeated null after .");
      notificationIds.add(id.toString());
    } else {
      // Repeated
      print("i am here not repeated null before .");
      final bool isForever = (repeatCount == null && untilDate == null);
      if (isForever) {
        // schedule-on-fire: only next occurrence
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          timeOfReminder,
          tz.TZDateTime.from(dateTime, tz.local),
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: 'reminder_channel_alarm',
        );
        notificationIds.add(id.toString());
      } else {
        // pre-schedule occurrences for count or until
        Duration interval;
        switch (repeatUnit) {
          case 'minute':
            interval = Duration(minutes: repeatInterval ?? 1);
            break;
          case 'hour':
            interval = Duration(hours: repeatInterval ?? 1);
            break;
          case 'day':
            interval = Duration(days: repeatInterval ?? 1);
            break;
          case 'week':
            interval = Duration(days: 7 * (repeatInterval ?? 1));
            break;
          case 'month':
            interval = Duration(days: 30 * (repeatInterval ?? 1));
            break;
          case 'year':
            interval = Duration(days: 365 * (repeatInterval ?? 1));
            break;
          default:
            interval = const Duration(minutes: 1);
        }
        if (repeatUnit == 'week' && (weekdays != null && weekdays.isNotEmpty)) {
          // schedule for selected weekdays
          // Map Flutter weekday (Mon=1..Sun=7) to DateTime.weekday (Mon=1..Sun=7)
          int scheduled = 0;
          DateTime cursor = dateTime;
          while (true) {
            if (untilDate != null && cursor.isAfter(untilDate)) break;
            if (repeatCount != null && scheduled >= repeatCount) break;
            for (final wd in weekdays) {
              // compute the date in the week of cursor matching wd
              final int delta = (wd - cursor.weekday) % 7;
              final DateTime occurrence = DateTime(
                cursor.year,
                cursor.month,
                cursor.day,
                dateTime.hour,
                dateTime.minute,
              ).add(Duration(days: delta));
              if (occurrence.isBefore(dateTime))
                continue; // don't schedule before start
              if (untilDate != null && occurrence.isAfter(untilDate)) continue;
              if (repeatCount != null && scheduled >= repeatCount) break;
              final int updatedId = id + scheduled;
              notificationIds.add(updatedId.toString());
              await flutterLocalNotificationsPlugin.zonedSchedule(
                updatedId,
                title,
                timeOfReminder,
                tz.TZDateTime.from(occurrence, tz.local),
                notificationDetails,
                androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
                payload: 'reminder_channel_alarm',
              );
              scheduled++;
            }
            // move to next week block
            cursor = cursor.add(Duration(days: 7 * (repeatInterval ?? 1)));
            if (repeatCount == null && untilDate == null && scheduled > 500)
              break; // guard
          }
        } else {
          int count = 0;
          DateTime next = dateTime;
          while (true) {
            if (untilDate != null && next.isAfter(untilDate)) break;
            if (repeatCount != null && count >= repeatCount) break;
            final int updatedId = id + count;
            notificationIds.add(updatedId.toString());
            await flutterLocalNotificationsPlugin.zonedSchedule(
              updatedId,
              title,
              timeOfReminder,
              tz.TZDateTime.from(next, tz.local),
              notificationDetails,
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              payload: 'reminder_channel_alarm',
            );
            next = next.add(interval);
            count++;
          }
        }
      }
      print("i am here not repeated null after .");
    }
  } catch (e) {
    print("Error scheduling notification: $e");
  }
  return notificationIds;
}
