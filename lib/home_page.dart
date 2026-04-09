import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/anniversary_info_page.dart';
import 'package:myapp/appfeedback.dart';
import 'package:myapp/important_ann.dart';
import 'package:myapp/login_page.dart';
// import 'package:flutter_share/flutter_share.dart';
import 'package:share_plus/share_plus.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'l10n/app_localizations.dart';

import 'package:myapp/lookup.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:myapp/daily_deed/daily_deed_page.dart';
import 'package:myapp/daily_deed/daily_deed_statistics_page.dart';
import 'package:myapp/health/blood_pressure_page.dart';
import 'package:myapp/health/blood_sugar_page.dart';
import 'package:myapp/health/health_info_page.dart';
import 'anniversary_streams.dart';
class Anniversary {
  final DateTime date;
  final String name;
  final String description;
  final String type; // e.g., "Birthday", "Death", "Wedding"

  Anniversary({
    required this.date,
    required this.name,
    required this.description,
    required this.type,
  });
}

class HomePage extends StatefulWidget {
  // HomePage({super.key, required Null Function(String lang) onLanguageChanged});
  final void Function(String lang) onLanguageChanged;
  final String currentLanguage;
  final int initialTabIndex;

  HomePage({
    super.key,
    required this.onLanguageChanged,
    required this.currentLanguage,
    this.initialTabIndex = 0,
  });
  // Static list of anniversaries (replace with actual data fetching later)
  final List<Anniversary> todayAnniversaries = <Anniversary>[];

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _appVersion = '';
  late int _currentIndex;
  int _currentTabIndex = 0; // Track main tab index for FAB visibility
  static const MethodChannel _widgetChannel = MethodChannel('com.reda.mohtm2/widget');

  @override
  void initState() {
    super.initState();
    filteredAnniversaries = widget.todayAnniversaries;
    _loadAppVersion();
    _currentIndex = widget.initialTabIndex;
    _currentTabIndex = 1; // Default to Daily Deeds tab
  }

  void _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _appVersion = info.version;
    });
  }

  Future<void> _updateUserLang(String lang) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'lang': lang},
      );
    }
  }

  DateTime? startDate;
  DateTime? endDate;
  // String _currentLanguage = "en"; // 'en' for English, 'ar' for Arabic
  List<Anniversary> filteredAnniversaries = [];

  DateTime? filterStartDate;
  DateTime? filterEndDate;
  List<QueryDocumentSnapshot> filteredDocs = [];
  bool isFiltering = false;
  
  Future<void> _writeOccasionWidgetSummary(List<QueryDocumentSnapshot> docs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Build a compact JSON payload with items (up to 5) and total count
      final int totalCount = docs.length;
      final List<Map<String, dynamic>> items = docs.take(5).map((doc) {
        final date = (doc['date'] as Timestamp?)?.toDate();
        final String dateStr = date != null ? '${date.day}/${date.month}/${date.year}' : '';
        final String title = (doc['title'] ?? '').toString();
        final String typeId = (doc['type']?.toString() ?? '');
        final locale = Localizations.localeOf(context).languageCode;
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
            typeName = locale == 'ar' ? (typeObj['arabicName'] ?? typeId) : (typeObj['englishName'] ?? typeId);
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
      final payload = {
        'items': items,
        'total': totalCount,
      };
      await prefs.setString('widget_occasion_items', jsonEncode(payload));
      await _widgetChannel.invokeMethod('updateOccasionWidget');
    } catch (_) {
      // Ignore errors; widget update is best effort
    }
  }
Future<void> share() async {
    await Share.share( 'https://play.google.com/store/apps/details?id=com.reda.mohtm2',
        subject: 'Example Chooser Title');
  }
Future<void> rateApp() async {
  final Uri playStoreUrl = Uri.parse('https://play.google.com/store/apps/details?id=com.reda.mohtm2');
  if (await canLaunch(playStoreUrl.toString())) {
    await launch(playStoreUrl.toString());
  } else {
    throw 'Could not launch $playStoreUrl';
  }
}
  void filterAnniversaries() {
    if (startDate == null || endDate == null) {
      return;
    }
    if (!mounted) return;
    setState(() {
      filteredAnniversaries =
          widget.todayAnniversaries.where((anniversary) {
            return anniversary.date.isAfter(
                  startDate!.subtract(const Duration(days: 1)),
                ) &&
                anniversary.date.isBefore(
                  endDate!.add(const Duration(days: 1)),
                );
          }).toList();
    });
  }
void filterAnniversariesByMonthDay() async {
    if (filterStartDate == null || filterEndDate == null) return;
    if (!mounted) return;
    setState(() {
      isFiltering = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('anniversaries')
            .where('createdBy', isEqualTo: user.uid)
            .get();

    final start = filterStartDate!;
    final end = filterEndDate!;

    List<QueryDocumentSnapshot> docs =
        snapshot.docs.where((doc) {
          final Timestamp? ts = doc['date'];
          if (ts == null) return false;
          final date = ts.toDate();
          // Convert all dates to year 2000 for comparison
          final normalized = DateTime(2000, date.month, date.day);
          if (start.isBefore(end) || start.isAtSameMomentAs(end)) {
            return (normalized.isAfter(start) ||
                    normalized.isAtSameMomentAs(start)) &&
                (normalized.isBefore(end) || normalized.isAtSameMomentAs(end));
          } else {
            // If range wraps around the year (e.g., Nov to Feb)
            return (normalized.isAfter(start) ||
                    normalized.isAtSameMomentAs(start)) ||
                (normalized.isBefore(end) || normalized.isAtSameMomentAs(end));
          }
        }).toList();

    if (!mounted) return;
    setState(() {
      filteredDocs = docs;
      isFiltering = false;
    });
  }
  // void filterAnniversariesByMonthDay() {
  //   if (filterStartDate == null || filterEndDate == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Please select both start and end dates'),
  //       ),
  //     );
  //     return;
  //   }

  //   final userId = FirebaseAuth.instance.currentUser?.uid;
  //   print('Current user ID: $userId');
    
  //   if (userId == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Please login first'),
  //       ),
  //     );
  //     return;
  //   }

  //   setState(() {
  //     isFiltering = true;
  //   });

  //   FirebaseFirestore.instance
  //       .collection('anniversaries')
  //       .where('userId', isEqualTo: userId)
  //       .get()
  //       .then((querySnapshot) {
  //     if (!mounted) return;

  //     print('Found ${querySnapshot.docs.length} total anniversaries for user $userId');
      
  //     final filtered = querySnapshot.docs.where((doc) {
  //       final Timestamp dateTimestamp = doc['date'] as Timestamp;
  //       final DateTime date = dateTimestamp.toDate();
  //       final int month = date.month;
  //       final int day = date.day;

  //       final int startMonth = filterStartDate!.month;
  //       final int startDay = filterStartDate!.day;
  //       final int endMonth = filterEndDate!.month;
  //       final int endDay = filterEndDate!.day;

  //       // Create comparable integers for month-day pairs
  //       final int currentMd = month * 100 + day;
  //       final int startMd = startMonth * 100 + startDay;
  //       final int endMd = endMonth * 100 + endDay;

  //       print('Anniversary: ${date.day}/${date.month}, Start: ${filterStartDate!.day}/${filterStartDate!.month}, End: ${filterEndDate!.day}/${filterEndDate!.month}');
        
  //       if (startMd <= endMd) {
  //         // Normal range (e.g., 3/1 to 5/1)
  //         return currentMd >= startMd && currentMd <= endMd;
  //       } else {
  //         // Wrap-around range (e.g., 12/1 to 2/1)
  //         return currentMd >= startMd || currentMd <= endMd;
  //       }
  //     }).toList();

  //     print('Filtered to ${filtered.length} anniversaries');

  //     if (!mounted) return;

  //     setState(() {
  //       filteredDocs = filtered;
  //       isFiltering = false;
  //     });
  //   }).catchError((error) {
  //     if (!mounted) return;
  //     setState(() {
  //       isFiltering = false;
  //     });
  //     print('Error filtering anniversaries: $error');
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          widget.currentLanguage == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
      child: DefaultTabController(
        length: 3, // Number of tabs: Occasions, Daily Deeds, Filter
        initialIndex: 1, // Default to Daily Deeds tab
        child: Scaffold(
          appBar: AppBar(
            leading: Builder(
              // Wrap IconButton with Builder
              builder: (BuildContext context) {
                return IconButton(
                  // Example leading icon (you can change this)
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.title,
                  style: const TextStyle(
                    fontFamily: 'Pacifico',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 80, 40, 120),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.favorite,
                  color: Color.fromARGB(255, 80, 40, 120),
                  size: 28,
                ),
              ],
            ),
            // title: Image.asset(
            //   'assets/images/title.png',
            //   height: 44,
            //   fit: BoxFit.contain,
            // ),
            backgroundColor: const Color.fromARGB(255, 182, 142, 190),
            actions: <Widget>[
              // IconButton(
              //   icon: const Icon(Icons.add_circle_outline),
              //   tooltip: 'Add',
              //   onPressed: () {
              //     Navigator.pushNamed(context, "/add_anniversary");
              //   },
              // ),
              IconButton(
                icon: const Icon(Icons.language),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    useSafeArea: true,
                    builder: (context) {
                      return SafeArea(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(
                                  Icons.check,
                                  color:
                                      widget.currentLanguage == 'en'
                                          ? Colors.green
                                          : Colors.transparent,
                                ),
                                title: const Text('English'),
                                  onTap: () async {
                                    widget.onLanguageChanged('en');
                                    await _updateUserLang('en');
                                    if (!mounted) return;
                                    Navigator.pop(context);
                                  },
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.check,
                                  color:
                                      widget.currentLanguage == 'ar'
                                          ? Colors.green
                                          : Colors.transparent,
                                ),
                                title: const Text('العربية'),
                                onTap: () async {
                                  widget.onLanguageChanged('ar');
                                  await _updateUserLang('ar');
                                  if (!mounted) return;
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {
                  Navigator.pushNamed(context, "/profile");
                },

              ),
            ],
            bottom: TabBar(
              onTap: (index) {
                setState(() {
                  _currentTabIndex = index;
                });
              },
              tabs: [
                Tab(
                  icon: Icon(Icons.event),
                  text: AppLocalizations.of(context)!.occasions,
                ),
                Tab(
                  icon: Icon(Icons.self_improvement),
                  text: AppLocalizations.of(context)!.dailyDeed,
                ),
                Tab(
                  icon: Icon(Icons.filter_list),
                  text: AppLocalizations.of(context)!.filter,
                ),
              ],
            ),
          ),
          drawer: Drawer(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      DrawerHeader(
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 211, 154, 223),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundImage: AssetImage(
                                'assets/images/icon.png',
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              AppLocalizations.of(context)!.mohtmMenu,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.alarm),
                        title: Text(AppLocalizations.of(context)!.reminders),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/reminders');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.task_alt),
                        title: Text(AppLocalizations.of(context)!.tasks),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/tasks');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.self_improvement),
                        title: Text(AppLocalizations.of(context)!.dailyDeed),
                        onTap: () {
                          Navigator.pop(context);
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DailyDeedPage(userId: user.uid),
                              ),
                            );
                          }
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.bar_chart),
                        title: Text(AppLocalizations.of(context)!.statistics),
                        onTap: () {
                          Navigator.pop(context);
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DailyDeedStatisticsPage(userId: user.uid),
                              ),
                            );
                          }
                        },
                      ),
                      ExpansionTile(
                        leading: const Icon(Icons.favorite),
                        title: Text(AppLocalizations.of(context)!.health),
                        children: <Widget>[  
                          ListTile(
                            leading: const Icon(Icons.monitor_heart),
                            title: Text(AppLocalizations.of(context)!.bloodPressure),
                            onTap: () {
                              Navigator.pop(context);
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const BloodPressurePage(),
                                  ),
                                );
                              }
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.water_drop),
                            title: Text(AppLocalizations.of(context)!.bloodSugar),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const BloodSugarPage(),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.info_outline),
                            title: Text(AppLocalizations.of(context)!.healthInfo),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HealthInfoPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      ListTile(
                        leading: const Icon(Icons.priority_high),
                        title: Text(
                          AppLocalizations.of(context)!.importantOccasions,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ImportantAnnPage(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.star),
                        title: Text(AppLocalizations.of(context)!.rateUs),
                        onTap: () {
                          rateApp();
                          },
                      ),
                      ListTile(
                        leading: const Icon(Icons.share),
                        title: Text(AppLocalizations.of(context)!.shareApp),
                        onTap: () {
                          share();
                        },
                      ),
                      ExpansionTile(
                        leading: const Icon(Icons.settings),
                        title: Text(AppLocalizations.of(context)!.settings),
                        children: <Widget>[
                          ListTile(
                            leading: const Icon(Icons.lock_reset),
                            title: Text(
                              AppLocalizations.of(context)!.changePassword,
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, '/change_password');
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.feedback),
                            title: Text(AppLocalizations.of(context)!.feedback),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AppFeedbackPage(),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.logout),
                            title: Text(AppLocalizations.of(context)!.logout),
                            onTap: () async {
                              await FirebaseAuth.instance.signOut();
                              if (!mounted) return;
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                                (Route<dynamic> route) => false,
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Text(
                              _appVersion.isNotEmpty ? 'Version: $_appVersion' : '',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Color(0xFF888888),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          body: TabBarView(
            children: [
              // Tab 1: Occasions with nested tabs (Today, Coming)
              DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      tabs: [
                        Tab(text: AppLocalizations.of(context)!.todaysOccasions),
                        Tab(text: AppLocalizations.of(context)!.notifiedOccasions),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Sub-tab 1: Today's Occasions
                          StreamBuilder<List<QueryDocumentSnapshot>>(
                            stream: getTodaysAnniversariesStream(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              final List<QueryDocumentSnapshot> todayAnniversaries =
                                  snapshot.hasData ? snapshot.data! : <QueryDocumentSnapshot>[];

                              _writeOccasionWidgetSummary(todayAnniversaries);

                              if (todayAnniversaries.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        AppLocalizations.of(context)!.noAnniversariesToday,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: todayAnniversaries.length,
                                itemBuilder: (context, index) {
                                  final doc = todayAnniversaries[index];
                                  final date = (doc['date'] as Timestamp).toDate();
                                  final title = doc['title'] ?? '';
                                  final typeId = doc['type']?.toString() ?? '';
                                  final locale = Localizations.localeOf(context).languageCode;
                                  final eventTypes = LookupService().eventTypes;
                                  String typeName = typeId;
                                  if (typeId.isNotEmpty) {
                                    if (typeId == "4") {
                                      typeName = doc['addType']?.toString() ?? '';
                                    } else {
                                      final typeObj = eventTypes.firstWhere(
                                        (type) => type['id'].toString() == typeId,
                                        orElse: () => <String, dynamic>{},
                                      );
                                      typeName = locale == 'ar'
                                          ? (typeObj['arabicName'] ?? typeId)
                                          : (typeObj['englishName'] ?? typeId);
                                    }
                                  }
                                  final priorityId = doc['priority']?.toString() ?? '';
                                  final annPriorities = LookupService().annPriorities;
                                  String priorityName = priorityId;
                                  if (priorityId.isNotEmpty) {
                                    final priorityObj = annPriorities.firstWhere(
                                      (p) => p['id'].toString() == priorityId,
                                      orElse: () => <String, dynamic>{},
                                    );
                                    priorityName = locale == 'ar'
                                        ? (priorityObj['priorityAr'] ?? priorityId)
                                        : (priorityObj['priorityEn'] ?? priorityId);
                                  }
                                  Color priorityColor;
                                  switch (priorityId) {
                                    case '1':
                                      priorityColor = Colors.red;
                                      break;
                                    case '2':
                                      priorityColor = Colors.orange;
                                      break;
                                    case '3':
                                      priorityColor = Colors.yellow[700]!;
                                      break;
                                    default:
                                      priorityColor = Colors.grey;
                                  }
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AnniversaryInfoPage(
                                              anniversaryId: doc.id,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 28,
                                              backgroundColor: priorityColor.withValues(alpha: 0.15),
                                              child: Text(
                                                '${date.day}/${date.month}\n${date.year}',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        typeName == 'Birthday' || typeName == 'عيد ميلاد'
                                                            ? Icons.cake
                                                            : typeName == 'Wedding' || typeName == 'زواج'
                                                                ? Icons.favorite
                                                                : typeName == 'Death' || typeName == 'وفاة'
                                                                    ? Icons.sentiment_very_dissatisfied
                                                                    : Icons.event,
                                                        color: Colors.deepPurple,
                                                        size: 20,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Expanded(
                                                        child: Text(
                                                          title,
                                                          style: const TextStyle(
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    AppLocalizations.of(context)!.typeLabel(typeName),
                                                    style: TextStyle(
                                                      color: Colors.grey[700],
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  if (doc['relationship'] != null &&
                                                      doc['relationship'].toString().isNotEmpty)
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 2.0),
                                                      child: Text(
                                                        doc['relationship'],
                                                        style: TextStyle(
                                                          color: Colors.grey[600],
                                                          fontSize: 13,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Chip(
                                              label: Text(
                                                priorityName,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              backgroundColor: priorityColor,
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
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
                          // Sub-tab 2: Coming Occasions
                          StreamBuilder<List<QueryDocumentSnapshot>>(
                            stream: getNotifiedOccasionsStream(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.notifications_active,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        AppLocalizations.of(context)!.noNotifiedOccasions,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              final notifiedOccasions = snapshot.data!;
                              return ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: notifiedOccasions.length,
                                itemBuilder: (context, index) {
                                  final doc = notifiedOccasions[index];
                                  final date = (doc['date'] as Timestamp).toDate();
                                  final title = doc['title'] ?? '';
                                  final typeId = doc['type']?.toString() ?? '';
                                  final locale = Localizations.localeOf(context).languageCode;
                                  final eventTypes = LookupService().eventTypes;
                                  String typeName = typeId;
                                  if (typeId.isNotEmpty) {
                                    if (typeId == "4") {
                                      typeName = doc['addType']?.toString() ?? '';
                                    } else {
                                      final typeObj = eventTypes.firstWhere(
                                        (type) => type['id'].toString() == typeId,
                                        orElse: () => <String, dynamic>{},
                                      );
                                      typeName = locale == 'ar'
                                          ? (typeObj['arabicName'] ?? typeId)
                                          : (typeObj['englishName'] ?? typeId);
                                    }
                                  }
                                  final priorityId = doc['priority']?.toString() ?? '';
                                  final annPriorities = LookupService().annPriorities;
                                  String priorityName = priorityId;
                                  if (priorityId.isNotEmpty) {
                                    final priorityObj = annPriorities.firstWhere(
                                      (p) => p['id'].toString() == priorityId,
                                      orElse: () => <String, dynamic>{},
                                    );
                                    priorityName = locale == 'ar'
                                        ? (priorityObj['priorityAr'] ?? priorityId)
                                        : (priorityObj['priorityEn'] ?? priorityId);
                                  }
                                  Color priorityColor;
                                  switch (priorityId) {
                                    case '1':
                                      priorityColor = Colors.red;
                                      break;
                                    case '2':
                                      priorityColor = Colors.orange;
                                      break;
                                    case '3':
                                      priorityColor = Colors.yellow[700]!;
                                      break;
                                    default:
                                      priorityColor = Colors.grey;
                                  }
                                  return Card(
                                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AnniversaryInfoPage(anniversaryId: doc.id),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 28,
                                              backgroundColor: priorityColor.withValues(alpha: 0.15),
                                              child: Text(
                                                '${date.day}/${date.month}\n${date.year}',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        typeName == 'Birthday' || typeName == 'عيد ميلاد'
                                                            ? Icons.cake
                                                            : typeName == 'Wedding' || typeName == 'زواج'
                                                                ? Icons.favorite
                                                                : typeName == 'Death' || typeName == 'وفاة'
                                                                    ? Icons.sentiment_very_dissatisfied
                                                                    : Icons.event,
                                                        color: Colors.deepPurple,
                                                        size: 20,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Expanded(
                                                        child: Text(
                                                          title,
                                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    AppLocalizations.of(context)!.typeLabel(typeName),
                                                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                                                  ),
                                                  if (doc['relationship'] != null && doc['relationship'].toString().isNotEmpty)
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 2.0),
                                                      child: Text(
                                                        doc['relationship'],
                                                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Chip(
                                              label: Text(
                                                priorityName,
                                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                              ),
                                              backgroundColor: priorityColor,
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Tab 2: Daily Deeds
              DailyDeedPage(userId: FirebaseAuth.instance.currentUser?.uid ?? '', showAppBar: false),
              // Tab 3: Filter
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.4,
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.date_range),
                                    label: Text(
                                      filterStartDate == null
                                          ? AppLocalizations.of(context)!.startDate
                                          : 'Start: ${filterStartDate!.day}/${filterStartDate!.month}',
                                    ),
                                    onPressed: () async {
                                      final currentYear = DateTime.now().year;
                                      final initialDate = filterStartDate != null
                                          ? DateTime(currentYear, filterStartDate!.month, filterStartDate!.day)
                                          : DateTime(currentYear, 1, 1);

                                      final pickedDate = await showDatePicker(
                                        context: context,
                                        initialDate: initialDate,
                                        firstDate: DateTime(currentYear, 1, 1),
                                        lastDate: DateTime(currentYear, 12, 31),
                                        helpText: AppLocalizations.of(context)!.startDate,
                                        fieldHintText: "MM/DD",
                                      );
                                      if (pickedDate != null) {
                                        setState(() {
                                          filterStartDate = DateTime(2000, pickedDate.month, pickedDate.day);
                                        });
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.4,
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.date_range),
                                    label: Text(
                                      filterEndDate == null
                                          ? AppLocalizations.of(context)!.endDate
                                          : 'End: ${filterEndDate!.day}/${filterEndDate!.month}',
                                    ),
                                    onPressed: () async {
                                      final currentYear = DateTime.now().year;
                                      final initialDate = filterEndDate != null
                                          ? DateTime(currentYear, filterEndDate!.month, filterEndDate!.day)
                                          : DateTime(currentYear, 12, 31);

                                      final pickedDate = await showDatePicker(
                                        context: context,
                                        initialDate: initialDate,
                                        firstDate: DateTime(currentYear, 1, 1),
                                        lastDate: DateTime(currentYear, 12, 31),
                                        helpText: AppLocalizations.of(context)!.endDate,
                                        fieldHintText: "MM/DD",
                                      );
                                      if (pickedDate != null) {
                                        setState(() {
                                          filterEndDate = DateTime(2000, pickedDate.month, pickedDate.day);
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.6,
                                  child: ElevatedButton.icon(
                                    onPressed: filterAnniversariesByMonthDay,
                                    icon: const Icon(Icons.filter_alt),
                                    label: Text(AppLocalizations.of(context)!.filter),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(255, 156, 217, 115),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.2,
                                  child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        filterStartDate = null;
                                        filterEndDate = null;
                                        filteredDocs = [];
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Color.fromARGB(255, 172, 171, 170),
                                    ),
                                    tooltip: AppLocalizations.of(context)!.clearFilter,
                                    iconSize: 28,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Expanded(
                      child: isFiltering
                          ? const Center(child: CircularProgressIndicator())
                          : filteredDocs.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.calendar_today, size: 64, color: Colors.grey[400]),
                                      const SizedBox(height: 16),
                                      Text(
                                        AppLocalizations.of(context)!.noAnniversariesFound,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: filteredDocs.length,
                                  itemBuilder: (context, index) {
                                    final doc = filteredDocs[index];
                                    final date = (doc['date'] as Timestamp).toDate();
                                    final title = doc['title'] ?? '';
                                    final String typeId = doc['type']?.toString() ?? '';
                                    final locale = Localizations.localeOf(context).languageCode;
                                    final eventTypes = LookupService().eventTypes;
                                    String typeName = typeId;
                                    if (typeId.isNotEmpty) {
                                      if (typeId == "4") {
                                        typeName = doc['addType']?.toString() ?? '';
                                      } else {
                                        final typeObj = eventTypes.firstWhere(
                                          (type) => type['id'].toString() == typeId,
                                          orElse: () => <String, dynamic>{},
                                        );
                                        typeName = locale == 'ar'
                                            ? (typeObj['arabicName'] ?? typeId)
                                            : (typeObj['englishName'] ?? typeId);
                                      }
                                    }
                                    final priorityId = doc['priority']?.toString() ?? '';
                                    final annPriorities = LookupService().annPriorities;
                                    String priorityName = priorityId;
                                    if (priorityId.isNotEmpty) {
                                      final priorityObj = annPriorities.firstWhere(
                                        (p) => p['id'].toString() == priorityId,
                                        orElse: () => <String, dynamic>{},
                                      );
                                      priorityName = locale == 'ar'
                                          ? (priorityObj['priorityAr'] ?? priorityId)
                                          : (priorityObj['priorityEn'] ?? priorityId);
                                    }
                                    Color priorityColor;
                                    switch (priorityId) {
                                      case '1':
                                        priorityColor = Colors.red;
                                        break;
                                      case '2':
                                        priorityColor = Colors.orange;
                                        break;
                                      case '3':
                                        priorityColor = Colors.yellow[700]!;
                                        break;
                                      default:
                                        priorityColor = Colors.grey;
                                    }
                                    return Card(
                                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(16),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AnniversaryInfoPage(anniversaryId: doc.id),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 28,
                                                backgroundColor: priorityColor.withValues(alpha: 0.15),
                                                child: Text(
                                                  '${date.day}/${date.month}/${date.year}',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          typeName == 'Birthday' || typeName == 'عيد ميلاد'
                                                              ? Icons.cake
                                                              : typeName == 'Wedding' || typeName == 'زواج'
                                                                  ? Icons.favorite
                                                                  : typeName == 'Death' || typeName == 'وفاة'
                                                                      ? Icons.sentiment_very_dissatisfied
                                                                      : Icons.event,
                                                          color: Colors.deepPurple,
                                                          size: 20,
                                                        ),
                                                        const SizedBox(width: 6),
                                                        Expanded(
                                                          child: Text(
                                                            title,
                                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      AppLocalizations.of(context)!.typeLabel(typeName),
                                                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                                                    ),
                                                    if (doc['relationship'] != null && doc['relationship'].toString().isNotEmpty)
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 2.0),
                                                        child: Text(
                                                          doc['relationship'],
                                                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Chip(
                                                label: Text(
                                                  priorityName,
                                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                ),
                                                backgroundColor: priorityColor,
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                              ),
                                            ],
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
            ],
          ),
          floatingActionButton: _currentTabIndex == 0
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/add_anniversary");
                  },
                  child: const Icon(Icons.add),
                  backgroundColor: const Color.fromARGB(255, 150, 100, 200),
                )
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        ),
      ),
    );
  }
}
