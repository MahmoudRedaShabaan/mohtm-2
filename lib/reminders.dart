import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
// import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
// import 'package:timezone/timezone.dart' as tz;
import 'add_reminder.dart';
import 'update_reminder.dart';
import 'main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class RemindersPage extends StatelessWidget {
  static bool _dialogShown = false;
  static const MethodChannel _widgetChannel = MethodChannel(
    'com.reda.mohtm2/widget',
  );

  Future<void> _showExactAlarmDialogIfNeeded(BuildContext context) async {
    if (_dialogShown) return;
    _dialogShown = true;
    if (Theme.of(context).platform == TargetPlatform.android) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      // if (androidInfo.version.sdkInt >= 31) {
      //   // Show dialog
      //   showDialog(
      //     context: context,
      //     builder:
      //         (ctx) => AlertDialog(
      //           title: Text(
      //             AppLocalizations.of(context)!.exactAlarmPermissionTitle,
      //           ),
      //           content: Text(
      //             AppLocalizations.of(context)!.exactAlarmPermissionMessage,
      //             //  'To ensure reminders work reliably, please allow "Schedule exact alarms" permission in system settings.',
      //           ),
      //           actions: [
      //             TextButton(
      //               onPressed: () {
      //                 Navigator.of(ctx).pop();
      //               },
      //               child: Text(AppLocalizations.of(context)!.cancel),
      //             ),
      //             TextButton(
      //               onPressed: () async {
      //                 Navigator.of(ctx).pop();
      //                 final intent = const AndroidIntent(
      //                   action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
      //                   flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      //                 );
      //                 await intent.launch();
      //               },
      //               child: Text(AppLocalizations.of(context)!.open_sertings),
      //             ),
      //           ],
      //         ),
      //   );
      // }
    }
  }

  Future<void> _openExactAlarmSettings() async {
    final intent = const AndroidIntent(
      action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    await intent.launch();
  }

  Future<void> _writeRemindersWidgetSummary(
    AsyncSnapshot<QuerySnapshot> snapshot,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // final user = FirebaseAuth.instance.currentUser;
      // if (user == null) return;
      // Query query = FirebaseFirestore.instance
      //     .collection('tasks')
      //     .where('userId', isEqualTo: user.uid)
      //     .where('status', isEqualTo: 'open')
      //     .orderBy('createdAt', descending: true);
      final List<DocumentSnapshot> documents = snapshot.data!.docs;
      final List<DocumentSnapshot> nonOutdatedDocs = [];
      for (var doc in documents) {
        print(doc.data());
        final data = doc.data() as Map<String, dynamic>;
        final dateTime = (data['dateTime'] as Timestamp).toDate();
        final isOutdated = _isReminderOutdated(data, dateTime);
        if(! isOutdated) {
          print('Not outdated');
          print(data['title']);
          nonOutdatedDocs.add(doc);
        }
      }
      // Build a compact JSON payload with items (up to 5) and total count
      final int totalCount = await nonOutdatedDocs.length;
      final List<Map<String, dynamic>> items =
          nonOutdatedDocs.take(5).map((doc) {
            final date = (doc['dateTime'] as Timestamp?)?.toDate();
            final String duedate =
                date != null ? '${date.day}/${date.month}/${date.year}' : '';
            final String title = (doc['title'] ?? '').toString();
            final String repeat = (doc['repeat']?.toString() ?? 'Don\'t repeat');

            return {'title': title, 'date': duedate, 'repeat': repeat};
          }).toList();
      final payload = {'items': items, 'total': totalCount};
      await prefs.setString('widget_reminder_items', jsonEncode(payload));
      await _widgetChannel.invokeMethod('updateReminderWidget');
    } catch (_) {
      // Ignore errors; widget update is best effort
    }
  }

  // Future<void> _printDeviceTimeZone() async {
  //   final String timeZone = await FlutterTimezone.getLocalTimezone();
  //   print('Device timezone: ' + timeZone);
  // }

  const RemindersPage({Key? key}) : super(key: key);

  Stream<QuerySnapshot> getRemindersStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('reminders')
        .where('userId', isEqualTo: user.uid)
        .orderBy('dateTime', descending: true)
        .snapshots();
  }

  // static Future<void> showImmediateNotification({
  //   required int id,
  //   required String title,
  //   String? body,
  // }) async {
  //   try {
  //     var androidDetails = const AndroidNotificationDetails(
  //       'reminder_channel_Alarm',
  //       'Reminders',
  //       importance: Importance.max,
  //       priority: Priority.high,
  //       sound: RawResourceAndroidNotificationSound('reminder'),
  //     );
  //     var notificationDetails = NotificationDetails(android: androidDetails);
  //     await flutterLocalNotificationsPlugin.show(
  //       id,
  //       title,
  //       body ?? 'Immediate notification',
  //       notificationDetails,
  //     );
  //     print('Immediate notification shown');
  //   } catch (e) {
  //     print('Error showing immediate notification: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showExactAlarmDialogIfNeeded(context);
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.reminders,
          style: const TextStyle(
            fontFamily: 'Pacifico',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 80, 40, 120),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              // Reload the entire page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => RemindersPage()),
              );
            },
          ),
        ],
        backgroundColor: const Color.fromARGB(255, 182, 142, 190),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getRemindersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          _writeRemindersWidgetSummary(
            snapshot,
          ); // Update widget summary whenever the list rebuilds
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noReminders,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.addYourFirstRemnederToGetStarted,
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }
          final reminders = snapshot.data!.docs;
          return ListView.builder(
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final doc = reminders[index];
              final data = doc.data() as Map<String, dynamic>;
              final title = data['title'] ?? '';
              final dateTime = (data['dateTime'] as Timestamp).toDate();
              final repeat = data['repeat'] ?? 'Don\'t repeat';
              final id = doc.id;

              // Check if reminder is overdue based on the specified scenarios
              final isOutdated = _isReminderOutdated(data, dateTime);
              List<String> notificationIds = [];
              if (data['notificationIds'] != null) {
                notificationIds = List<String>.from(
                  data['notificationIds'] ?? [],
                );
              }
              // final reminderIds = data['notificationId'] ?? 0;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: isOutdated ? 4 : 3,
                color: isOutdated ? Colors.red[50] : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side:
                      isOutdated
                          ? BorderSide(color: Colors.red[300]!, width: 2)
                          : BorderSide.none,
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => UpdateReminderPage(
                              reminderId: id,
                              reminderData: data,
                            ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: ListTile(
                    leading: Icon(
                      isOutdated ? Icons.warning : Icons.notifications_active,
                      color: isOutdated ? Colors.red[600] : Colors.deepPurple,
                    ),
                    title: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isOutdated ? Colors.red[700] : Colors.black87,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          '${AppLocalizations.of(context)!.date}: ${DateFormat('dd-MM-yyyy hh:mm a').format(dateTime)}',
                          style: TextStyle(
                            color:
                                isOutdated ? Colors.red[600] : Colors.black87,
                            fontWeight:
                                isOutdated
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                        Text(
                          '${AppLocalizations.of(context)!.repeat}: $repeat',
                          style: TextStyle(
                            color:
                                isOutdated ? Colors.red[600] : Colors.black87,
                          ),
                        ),
                        if (isOutdated)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              AppLocalizations.of(context)!.overdue,
                              style: TextStyle(
                                color: Colors.red[600],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Color.fromARGB(255, 149, 148, 148),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => UpdateReminderPage(
                                      reminderId: id,
                                      reminderData: data,
                                    ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Color.fromARGB(255, 149, 148, 148),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.reminderDelete,
                                  ),
                                  content: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.reminderDeleteConfirmation,
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text(
                                        AppLocalizations.of(context)!.cancel,
                                      ),
                                      onPressed: () {
                                        Navigator.of(
                                          context,
                                        ).pop(); // Dismiss the dialog
                                      },
                                    ),
                                    TextButton(
                                      child: Text(
                                        AppLocalizations.of(context)!.delete,
                                      ),
                                      onPressed: () {
                                        // Put your logic to delete the reminder here.
                                        // For example, calling the function from our previous conversation:
                                        // await cancelReminderNotifications(id: reminderId);
                                        deleteReminderById(id, notificationIds);
                                        // Then, dismiss the dialog
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddReminderPage(),
                ),
              );
            },
            backgroundColor: primaryColor,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'fix_alarm_perm',
            backgroundColor: secondaryColor,
            onPressed: _openExactAlarmSettings,
            child: const Icon(Icons.settings, color: Colors.white),
            tooltip: 'Fix Notification Permission',
          ),
          // const SizedBox(height: 12),
          // FloatingActionButton(
          //   heroTag: 'timezone',
          //   backgroundColor: Colors.blueGrey,
          //   onPressed: () async {
          //     await _printDeviceTimeZone();
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(
          //         content: Text('Device timezone printed to console'),
          //       ),
          //     );
          //   },
          //   child: const Icon(Icons.language),
          //   tooltip: 'Print Device Timezone',
          // ),
          //const SizedBox(height: 12),
          // FloatingActionButton(
          //   heroTag: 'test',
          //   backgroundColor: Colors.orange,
          //   onPressed: () async {
          //     // Minimal test: schedule notification in 3 minutes using device timezone
          //     final String timeZoneName =
          //         await FlutterTimezone.getLocalTimezone();
          //     final location = tz.getLocation(timeZoneName);
          //     final now = tz.TZDateTime.now(
          //       location,
          //     ).add(const Duration(minutes: 2));
          //     final scheduled = now;
          //     final current = tz.TZDateTime.now(location);
          //     print('Scheduling notification for: ' + scheduled.toString());
          //     print('Current time: ' + current.toString());
          //     print(
          //       'Difference (seconds): ' +
          //           (scheduled.difference(current).inSeconds).toString(),
          //     );
          //     try {
          //       print('Calling scheduleReminderNotification...');
          //       await scheduleReminderNotification(
          //         id: DateTime.now().millisecondsSinceEpoch % 1000000,
          //         title: 'Test Notification',
          //         dateTime: scheduled,
          //       );
          //       print('scheduleReminderNotification completed without error.');
          //       ScaffoldMessenger.of(context).showSnackBar(
          //         SnackBar(
          //           content: Text(
          //             'Test notification scheduled for \\${now.hour}:\\${now.minute.toString().padLeft(2, '0')}',
          //           ),
          //         ),
          //       );
          //     } catch (e, stack) {
          //       print('Error calling scheduleReminderNotification: $e');
          //       print(stack);
          //       ScaffoldMessenger.of(context).showSnackBar(
          //         SnackBar(content: Text('Error scheduling notification: $e')),
          //       );
          //     }
          //   },
          //   child: const Icon(Icons.notifications),
          //   tooltip: 'Test Notification',
          // ),
          // const SizedBox(height: 12),
          // FloatingActionButton(
          //   heroTag: 'immediate',
          //   backgroundColor: Colors.red,
          //   onPressed: () async {
          //     await RemindersPage.showImmediateNotification(
          //       id: DateTime.now().millisecondsSinceEpoch % 1000000,
          //       title: 'Immediate Notification',
          //       body: 'This is a test immediate notification',
          //     );
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(
          //         content: Text('Immediate notification triggered'),
          //       ),
          //     );
          //   },
          //   child: const Icon(Icons.flash_on),
          //   tooltip: 'Immediate Notification',
          // ),
        ],
      ),
    );
  }

  Future<void> deleteReminderById(
    String id,
    List<String> notificationIds,
  ) async {
    //FirebaseFirestore.instance.collection('reminders').doc(id).delete();
    try {
      print('Deleting reminder with ID: $id');
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('No user logged in. Cannot delete reminder.');
        return;
      }
      final ref = FirebaseFirestore.instance.collection('reminders').doc(id);
      if (ref.id.isNotEmpty) {
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
    } catch (e) {
      debugPrint('Error deleting reminder: $e');
    }
  }

  // Method to check if a reminder is overdue based on the specified scenarios
  static bool _isReminderOutdated(
    Map<String, dynamic> data,
    DateTime dateTime,
  ) {
    final currentDate = DateTime.now();
    final repeat = data['repeat'] ?? 'Don\'t repeat';
    final durationType = data['durationType'];

    // Scenario 1: If date of reminder < current date and repeat = "Don't repeat" -> outdated
    if (repeat == 'Don\'t repeat' && dateTime.isBefore(currentDate)) {
      return true;
    }

    // Scenario 2: If date of reminder < current date and repeat != "Don't repeat" -> check duration type
    if (repeat != 'Don\'t repeat' && dateTime.isBefore(currentDate)) {
      switch (durationType) {
        case 'until':
          // Check if untilDate < current date
          final untilDate = data['untilDate'] as Timestamp?;
          if (untilDate != null && untilDate.toDate().isBefore(currentDate)) {
            return true;
          }
          break;

        case 'forever':
          // Never outdated
          return false;

        case 'count':
          // Calculate overdue date based on repeatCount * repeatInterval
          final repeatCount = data['repeatCount'] as int?;
          final repeatInterval = data['repeatInterval'] as int?;
          final repeatUnit = data['repeatUnit'] as String?;

          if (repeatCount != null &&
              repeatInterval != null &&
              repeatUnit != null) {
            final x = (repeatCount - 1) * repeatInterval;
            DateTime overdueDate = dateTime;

            // Calculate overdue date based on repeat unit
            switch (repeatUnit) {
              case 'minute':
                overdueDate = dateTime.add(Duration(minutes: x));
                break;
              case 'hour':
                overdueDate = dateTime.add(Duration(hours: x));
                break;
              case 'day':
                overdueDate = dateTime.add(Duration(days: x));
                break;
              case 'week':
                overdueDate = dateTime.add(Duration(days: x * 7));
                break;
              case 'month':
                overdueDate = DateTime(
                  dateTime.year,
                  dateTime.month + x,
                  dateTime.day,
                );
                break;
              case 'year':
                overdueDate = DateTime(
                  dateTime.year + x,
                  dateTime.month,
                  dateTime.day,
                );
                break;
            }

            // Check if overdue date < current date
            print("overdueDate:");
            print(overdueDate.toString());
            if (overdueDate.isBefore(currentDate)) {
              return true;
            }
          }
          break;
      }
    }

    return false;
  }
}
