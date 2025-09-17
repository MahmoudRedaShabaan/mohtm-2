import 'dart:convert';
import 'dart:ui';
import 'package:version/version.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/browser.dart';
//import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:myapp/anniversary_info_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:upgrader/upgrader.dart';
import 'home_page.dart';
import 'package:myapp/login_page.dart';
import 'add_anniversary_page.dart';
import 'reminders.dart';
import 'change_password_page.dart';
import 'profile_page.dart';
import 'register_page.dart';
import 'forget_password_page.dart';
import 'tasks.dart';
import 'add_task.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'lookup.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'tasks.dart';
import 'reminders.dart';
import 'package:upgrader/upgrader.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
const MethodChannel _widgetChannel = MethodChannel('com.reda.mohtm2/widget');
String minRequiredVersion='';
// Add this function at the top level, outside of any class
// Add this function at the top level, outside of any class
@pragma('vm:entry-point')
void onDidReceiveNotificationResponse(
  NotificationResponse notificationResponse,
) {
  print('onDidReceiveNotificationResponse: $notificationResponse');
  try {
    // Check for the action and navigate
    print('payload: ${notificationResponse.payload}');
    if (notificationResponse.payload == null ||
        notificationResponse.payload!.isEmpty) {
      print('Payload is null or empty, cannot proceed.');
      return;
    } else {
      if (notificationResponse.payload == 'reminder_channel_alarm') {
        print('Navigating to ReminderPage...');
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => const RemindersPage()),
        );
      }
    }
    // _handleMessageActionReminder(notificationResponse.payload);
  } catch (e) {
    print('Failed to parse notification payload: $e');
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, initialize them here.
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');

  // Update FCM token in background
  await _updateFCMTokenInBackground();
}

@pragma('vm:entry-point')
Future<void> _updateScreenWidgetsInBackground() async {
  _writeTasksWidgetSummary();
  _writeRemindersWidgetSummary();
  _writeOccasionWidgetSummary();
}
Future<String> _loadMinRequiredVersion() async {
    final doc = await FirebaseFirestore.instance.collection('appVersion').doc('1').get();
    if (doc.exists) {
       minRequiredVersion = doc['minRequiredVersion']?.toString() ?? '1.1.1';
      print('App version from Firestore: $minRequiredVersion');
    } else {
      print('No appVersion document found in Firestore.');
      minRequiredVersion= '1.1.1';  
    }
    return minRequiredVersion;
  }

Future<void> _writeOccasionWidgetSummary() async {
  try {
    Stream<List<QueryDocumentSnapshot>> todaysAnniversariesStream =
        getTodaysAnniversariesStream();
    final prefs = await SharedPreferences.getInstance();
    List<QueryDocumentSnapshot> docs = [];
    await for (List<QueryDocumentSnapshot> anniversaryList
        in todaysAnniversariesStream) {
      // Add all the documents from the stream event to our list.
      docs.addAll(anniversaryList);
    }
    // Build a compact JSON payload with items (up to 5) and total count
    final int totalCount = docs.length;
    final List<Map<String, dynamic>> items =
        docs.take(5).map((doc) {
          final date = (doc['date'] as Timestamp?)?.toDate();
          final String dateStr =
              date != null ? '${date.day}/${date.month}/${date.year}' : '';
          final String title = (doc['title'] ?? '').toString();
          final String typeId = (doc['type']?.toString() ?? '');
          //_locale
          final locale = 'en';
          final eventTypes = LookupService().eventTypes;
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
    // Ignore errors; widget update is best effort
  }
}

Stream<List<QueryDocumentSnapshot>> getTodaysAnniversariesStream() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    // Return an empty stream if not logged in
    return Stream.value([]);
  }
  final today = DateTime.now();
  return FirebaseFirestore.instance
      .collection('anniversaries')
      .where('createdBy', isEqualTo: user.uid)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.where((doc) {
              final Timestamp? ts = doc['date'];
              if (ts == null) return false;
              final date = ts.toDate();
              return date.month == today.month && date.day == today.day;
            }).toList(),
      );
}

Future<void> _writeRemindersWidgetSummary() async {
  try {
    print("_writeRemindersWidgetSummary called");
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Query query = FirebaseFirestore.instance
          .collection('reminders')
          .where('userId', isEqualTo: user.uid)
          .orderBy('dateTime', descending: true);

      final QuerySnapshot querySnapshot = await query.get();
      final documents = querySnapshot.docs;

      // Stream<QuerySnapshot> snapshot =
      //     FirebaseFirestore.instance
      //         .collection('reminders')
      //         .where('userId', isEqualTo: user.uid)
      //         .orderBy('dateTime', descending: true)
      //         .snapshots();
      // List<DocumentSnapshot> documents = [];
      // snapshot.listen((QuerySnapshot snapshot) {
      //   documents = snapshot.docs;
      // });
      final List<DocumentSnapshot> nonOutdatedDocs = [];
      for (var doc in documents) {
        print("_writeRemindersWidgetSummary processing doc:");
        print(doc.data());
        final data = doc.data() as Map<String, dynamic>;
        final dateTime = (data['dateTime'] as Timestamp).toDate();
        final isOutdated = _isReminderOutdated(data, dateTime);
        if (!isOutdated) {
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
            final String repeat =
                (doc['repeat']?.toString() ?? 'Don\'t repeat');

            return {'title': title, 'date': duedate, 'repeat': repeat};
          }).toList();
      final payload = {'items': items, 'total': totalCount};
      await prefs.setString('widget_reminder_items', jsonEncode(payload));
      await _widgetChannel.invokeMethod('updateReminderWidget');
    }
  } catch (e) {
    print('Error in _writeRemindersWidgetSummary: $e');
    // Ignore errors; widget update is best effort
  }
}

bool _isReminderOutdated(Map<String, dynamic> data, DateTime dateTime) {
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

Future<void> _writeTasksWidgetSummary() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    Query query = FirebaseFirestore.instance
        .collection('tasks')
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'open')
        .orderBy('createdAt', descending: true);

    final QuerySnapshot querySnapshot = await query.get();
    final docs = querySnapshot.docs;
    // Build a compact JSON payload with items (up to 5) and total count
    final int totalCount = await docs.length;
    final List<Map<String, dynamic>> items =
        docs.take(5).map((doc) {
          final date = (doc['duedate'] as Timestamp?)?.toDate();
          final String duedate =
              date != null ? '${date.day}/${date.month}/${date.year}' : '';
          final String taskname = (doc['taskname'] ?? '').toString();
          final String status = (doc['status']?.toString() ?? '');
          //final locale = Localizations.localeOf(context).languageCode;

          return {'taskname': taskname, 'date': duedate, 'status': status};
        }).toList();
    final payload = {'items': items, 'total': totalCount};
    await prefs.setString('widget_task_items', jsonEncode(payload));
    await _widgetChannel.invokeMethod('updateTaskWidget');
  } catch (_) {
    // Ignore errors; widget update is best effort
  }
}

// Top-level function to update FCM token in background
@pragma('vm:entry-point')
Future<void> _updateFCMTokenInBackground() async {
  try {
    print('Updating FCM token in background...');

    // Get the current FCM token
    final messaging = FirebaseMessaging.instance;
    final token = await messaging.getToken();

    if (token != null) {
      print('Background FCM Token: $token');

      // Get current user (if any)
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Update the user's FCM token in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'fcmToken': token});
        print('FCM token updated in Firestore for user: ${user.uid}');
      }

      // Store token locally for when app resumes
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
      await prefs.setInt(
        'fcm_token_timestamp',
        DateTime.now().millisecondsSinceEpoch,
      );
      print('FCM token stored locally');
    }
  } catch (e) {
    print('Error updating FCM token in background: $e');
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _rescheduleRepeatingReminders() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final qs =
        await FirebaseFirestore.instance
            .collection('reminders')
            .where('userId', isEqualTo: user.uid)
            .get();
    for (final doc in qs.docs) {
      final data = doc.data();
      final String repeat = (data['repeat'] ?? "Don't repeat").toString();
      if (repeat == "Don't repeat") continue;
      final Timestamp? ts = data['dateTime'];
      if (ts == null) continue;
      DateTime base = ts.toDate();
      final String? unit = data['repeatUnit']?.toString();
      final List<dynamic> weekdaysDyn =
          (data['weekdays'] as List?) ?? <dynamic>[];
      final List<int> weekdays =
          weekdaysDyn
              .map((e) => int.tryParse(e.toString()) ?? 0)
              .where((e) => e >= 1 && e <= 7)
              .toList();
      final int interval =
          (data['repeatInterval'] is int) ? data['repeatInterval'] as int : 1;
      final String? durationType = data['durationType']?.toString();
      final int? repeatCount =
          data['repeatCount'] is int ? data['repeatCount'] as int : null;
      final Timestamp? untilTs = data['untilDate'];
      final DateTime? untilDate = untilTs?.toDate();
      final List<dynamic> notifIdsDyn =
          (data['notificationIds'] as List?) ?? <dynamic>[];
      final List<String> scheduledIds =
          notifIdsDyn.map((e) => e.toString()).toList();

      int alreadyScheduled = scheduledIds.length;
      if (durationType == 'count' &&
          repeatCount != null &&
          alreadyScheduled >= repeatCount) {
        continue;
      }

      // Only reschedule for forever case; skip for count/until which are fully scheduled already
      if (!(durationType == null ||
          (durationType != 'count' && durationType != 'until'))) {
        continue;
      }

      Duration step;
      switch (unit) {
        case 'minute':
          step = Duration(minutes: interval);
          break;
        case 'hour':
          step = Duration(hours: interval);
          break;
        case 'day':
          step = Duration(days: interval);
          break;
        case 'week':
          step = Duration(days: 7 * interval);
          break;
        case 'month':
          step = Duration(days: 30 * interval);
          break;
        case 'year':
          step = Duration(days: 365 * interval);
          break;
        default:
          step = const Duration(minutes: 1);
      }

      final now = DateTime.now();
      DateTime? next;
      if (unit == 'week' && weekdays.isNotEmpty) {
        // find the next weekday occurrence after now
        DateTime cursor = now.isBefore(base) ? base : now;
        int guard = 0;
        while (next == null && guard < 500) {
          for (final wd in weekdays) {
            final int delta = (wd - cursor.weekday) % 7;
            final DateTime candidate = DateTime(
              cursor.year,
              cursor.month,
              cursor.day,
              base.hour,
              base.minute,
            ).add(Duration(days: delta));
            if (candidate.isBefore(now) || candidate.isBefore(base)) continue;
            if (untilDate != null && candidate.isAfter(untilDate)) continue;
            next = candidate;
            break;
          }
          if (next == null) {
            cursor = cursor.add(Duration(days: 7 * interval));
          }
          guard++;
        }
      } else {
        // Advance to the next occurrence after now considering how many were scheduled
        DateTime candidate = base.add(step * alreadyScheduled);
        while (candidate.isBefore(now)) {
          candidate = candidate.add(step);
          if (durationType == 'count' && repeatCount != null) {
            alreadyScheduled++;
            if (alreadyScheduled >= repeatCount) break;
          }
          if (durationType == 'until' &&
              untilDate != null &&
              candidate.isAfter(untilDate))
            break;
        }
        next = candidate;
      }
      if (durationType == 'count' &&
          repeatCount != null &&
          alreadyScheduled >= repeatCount) {
        continue;
      }
      if (durationType == 'until' &&
          untilDate != null &&
          next!.isAfter(untilDate)) {
        continue;
      }

      final String title = (data['title'] ?? '').toString();
      final String body = (data['body'] ?? '').toString();
      final int newId = DateTime.now().millisecondsSinceEpoch % 1000000;

      try {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          newId,
          title,
          body,
          tz.TZDateTime.from(next!, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'reminder_channel_alarm',
              'Reminders',
              importance: Importance.max,
              priority: Priority.high,
              sound: RawResourceAndroidNotificationSound('reminder'),
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
        await doc.reference.update({
          'notificationIds': FieldValue.arrayUnion([newId.toString()]),
        });
      } catch (e) {
        // ignore scheduling errors to avoid blocking app start
        // print('Reschedule error: $e');
      }
    }
  } catch (e) {
    // print('Rescheduler failed: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  //  initializeTimeZones();
  final String timeZoneName = await FlutterTimezone.getLocalTimezone();
  // final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();

  tz.setLocalLocation(tz.getLocation(timeZoneName));
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LookupService().initialize();
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
    onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
  );

  // Create notification channel for Android
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);
  await _rescheduleRepeatingReminders();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await Upgrader.clearSavedSettings();
  //  typedef WillDisplayUpgradeCallback = Future<UpgraderDisplay> Function(UpgraderDisplay display);
  runApp(const MyApp());
}

const bool isTesting = true;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Locale _locale = const Locale('en');
  String? _fcmToken;
  Timer? _reminderTopUpTimer;
  //String timeOfReminder='Time of Reminder';

  void setLocale(Locale locale) async {
    setState(() {
      _locale = locale;
    });
    // Save selected language
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', locale.languageCode);
    //   timeOfReminder=AppLocalizations.of(context)!.timeOfReminder;
  }

  @override
  void initState() {
    super.initState();
    _restoreLocale();
    _initFCM();
    _writeTasksWidgetSummary();
    _writeRemindersWidgetSummary();
    _writeOccasionWidgetSummary();
    _loadMinRequiredVersion();
    WidgetsBinding.instance.addObserver(this);
    _reminderTopUpTimer = Timer.periodic(const Duration(hours: 2), (_) {
      _rescheduleRepeatingReminders();
      _refreshFCMTokenIfNeeded();
      _writeTasksWidgetSummary();
      _writeRemindersWidgetSummary();
      _writeOccasionWidgetSummary();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _reminderTopUpTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _rescheduleRepeatingReminders();
      _refreshFCMTokenIfNeeded();
      _writeTasksWidgetSummary();
      _writeRemindersWidgetSummary();
      _writeOccasionWidgetSummary();
    }
  }

  // Method to refresh FCM token if needed
  Future<void> _refreshFCMTokenIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokenTimestamp = prefs.getInt('fcm_token_timestamp');
      final now = DateTime.now().millisecondsSinceEpoch;

      // If token is older than 6 hours, refresh it
      if (tokenTimestamp == null ||
          (now - tokenTimestamp) > (6 * 60 * 60 * 1000)) {
        print('Refreshing FCM token...');
        final messaging = FirebaseMessaging.instance;
        final token = await messaging.getToken();

        if (token != null) {
          setState(() {
            _fcmToken = token;
          });

          // Update in Firestore
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .update({'fcmToken': token});
          }

          // Store locally with new timestamp
          await prefs.setString('fcm_token', token);
          await prefs.setInt('fcm_token_timestamp', now);
          print('FCM token refreshed and updated');
        }
      } else {
        print('FCM token is still fresh, no refresh needed');
      }
    } catch (e) {
      print('Error refreshing FCM token: $e');
    }
  }

  void _restoreLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('selected_language');
    if (langCode != null &&
        langCode.isNotEmpty &&
        langCode != _locale.languageCode) {
      setState(() {
        _locale = Locale(langCode);
      });
    }
  }

  void _initFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permissions on iOS
    NotificationSettings settings = await messaging.requestPermission();
    print('User granted permission: ${settings.authorizationStatus}');

    // Always get a fresh token on app start
    final token = await messaging.getToken();
    setState(() {
      _fcmToken = token;
    });
    print("FCM Token: $_fcmToken");

    // Update the logged-in user's fcmToken in Firestore (initial set)
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && token != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'fcmToken': token},
      );

      // Store token locally with timestamp
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
      await prefs.setInt(
        'fcm_token_timestamp',
        DateTime.now().millisecondsSinceEpoch,
      );
    }

    // Listen for token refreshes - this is the key mechanism
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print("FCM Token Refreshed: $newToken");
      setState(() {
        _fcmToken = newToken;
      });

      // Update the logged-in user's fcmToken in Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'fcmToken': newToken});

        // Store updated token locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', newToken);
        await prefs.setInt(
          'fcm_token_timestamp',
          DateTime.now().millisecondsSinceEpoch,
        );
        print('FCM token updated in Firestore and local storage');
      }
    });
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print(
          'Message also contained a notification: ${message.notification!.title} - ${message.notification!.body}',
        );

        // Display local notification when app is in foreground
        _showLocalNotification(
          message.notification!.title ?? 'Notification',
          message.notification!.body ?? 'You have a new message',
          message.data,
        );
      }
    });

    // Handle interaction when the app is opened from a terminated state
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print(
        'App opened from terminated state with message: ${initialMessage.data}',
      );
      _handleMessageAction(initialMessage.data);
      // TODO: Handle navigation or data based on the initial message
    }

    // Handle interaction when the app is opened from a background state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from background state with message: ${message.data}');
      _handleMessageAction(message.data);
      // TODO: Handle navigation or data based on the message
    });
    // New method to handle message-based navigation

    // // Subscribe to topic for all users
    // await messaging.subscribeToTopic('all_users');
  }

  void _handleMessageAction(Map<String, dynamic> data) {
    if (data.containsKey('action')) {
      final action = data['action'];
      if (action == 'Send_specific_Notification_Task') {
        // Navigate to the special page
        print('here in task');
        try {
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (context) => const TasksPage()),
          );
        } catch (e) {
          print('Error navigating to RemindersPage: $e');
          print(e);
        }
      } else if (action == 'Send_specific_Notification') {
        print('here in Home');
        try {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder:
                  (context) => HomePage(
                    key: ValueKey('home_${_locale.languageCode}'),
                    onLanguageChanged: (lang) {
                      setLocale(Locale(lang));
                    },
                    currentLanguage: _locale.languageCode,
                    initialTabIndex: 1,
                  ),
            ),
          );
        } catch (e) {
          print('Error navigating to RemindersPage: $e');
          print(e);
        }
      } else {
        print('here in Home');
        try {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder:
                  (context) => HomePage(
                    key: ValueKey('home_${_locale.languageCode}'),
                    onLanguageChanged: (lang) {
                      setLocale(Locale(lang));
                    },
                    currentLanguage: _locale.languageCode,
                  ),
            ),
          );
        } catch (e) {
          print('Error navigating to RemindersPage: $e');
          print(e);
        }
      }
    } else {
      print('here in Home');
      try {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder:
                (context) => HomePage(
                  key: ValueKey('home_${_locale.languageCode}'),
                  onLanguageChanged: (lang) {
                    setLocale(Locale(lang));
                  },
                  currentLanguage: _locale.languageCode,
                ),
          ),
        );
      } catch (e) {
        print('Error navigating to RemindersPage: $e');
        print(e);
      }
    }
  }
  // Future<bool> _willDisplayUpgrade({
  //   required bool display,
  //   String? installedVersion,
  //   UpgraderVersionInfo? versionInfo,
  // }) async {
  //   if (versionInfo?.appStoreVersion == null) {
  //     // versionInfo?.appStoreVersion = '1.2.3';
  //     versionInfo = UpgraderVersionInfo(
  //     appStoreVersion: Version.parse('1.2.3'),
  //     );
  //   }
  //   // If the installed version is less than 1.0.9, force the upgrade
  //   if (installedVersion != null && installedVersion.compareTo('1.0.9') < 0) {
  //     return true; // Force the upgrade
  //   }

  //   // If the installed version is between 1.0.9 and 1.2.3, show the upgrade alert
  //   if (installedVersion != null && installedVersion.compareTo('1.0.9') >= 0 && installedVersion.compareTo('1.2.3') < 0) {
  //     return true; // Show the upgrade alert
  //   }
  //   return false;
  //   // ...
  // }

  // The function signature MUST match the required type.
  // It receives an UpgraderDisplay object and returns a Future of it.

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      dialogStyle: UpgradeDialogStyle.cupertino,
      upgrader: Upgrader(
        languageCode: _locale.languageCode,
        minAppVersion: minRequiredVersion, 
        messages : _locale.languageCode == 'ar' ? UpgraderMessages(code: 'ar') : UpgraderMessages(code: 'en'),
      ),
      child: MaterialApp(
        navigatorKey: navigatorKey, // Assign the key here
        title: 'Mohtm',
        locale: _locale,
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          AppLocalizations.delegate,
        ],
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              // User is logged in
              // _initFCM();
              return HomePage(
                key: ValueKey('home_${_locale.languageCode}'),
                onLanguageChanged: (lang) {
                  setLocale(Locale(lang));
                },
                currentLanguage: _locale.languageCode,
              );
            }
            // User is not logged in
            return LoginPage(
              key: ValueKey('login_${_locale.languageCode}'),
              onLanguageChanged: (lang) {
                setLocale(Locale(lang));
              },
              currentLanguage: _locale.languageCode,
            );
          },
        ),
        routes: <String, WidgetBuilder>{
          '/forget_password': (context) => const ForgetPasswordPage(),
          '/change_password': (context) => const ChangePasswordPage(),
          '/anniversary_info':
              (context) => const AnniversaryInfoPage(anniversaryId: ''),
          '/profile': (context) => ProfilePage(),
          '/register': (context) => const RegisterPage(),
          '/add_anniversary': (context) => const AddAnniversaryPage(),
          '/reminders': (context) => const RemindersPage(),
          '/tasks': (context) => const TasksPage(),
          '/add_task': (context) => const AddTaskPage(),
        },
      ),
    );
  }

  // Method to show local notification when app is in foreground
  Future<void> _showLocalNotification(
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications.',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformChannelSpecifics,
      payload: data.toString(),
    );
  }
}
