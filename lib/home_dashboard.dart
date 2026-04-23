import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/widgets/app_banner_ad.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/anniversary_streams.dart';
import 'package:intl/intl.dart';
import 'package:myapp/health/add_blood_pressure_page.dart';
import 'package:myapp/health/add_blood_sugar_page.dart';
import 'package:myapp/health/blood_pressure_page.dart';
import 'package:myapp/health/blood_sugar_page.dart';
import 'package:myapp/health/health_info_page.dart';
import 'package:myapp/daily_deed/daily_deed_page.dart';
import 'package:myapp/daily_deed/daily_deed_statistics_page.dart';
import 'package:myapp/daily_deed/hijri_date_util.dart';
import 'package:myapp/tasks.dart';
import 'package:myapp/add_task.dart';
import 'package:myapp/reminders.dart';
import 'package:myapp/add_reminder.dart';
import 'package:myapp/add_anniversary_page.dart';
import 'occasions_page.dart';
import 'package:myapp/important_ann.dart';
import 'package:myapp/general_deeds_page.dart';
import 'package:myapp/appfeedback.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:myapp/login_page.dart';
import 'package:myapp/occasion_filter_page.dart';

class HomeDashboard extends StatefulWidget {
  final void Function(String lang) onLanguageChanged;
  final String currentLanguage;

  const HomeDashboard({
    super.key,
    required this.onLanguageChanged,
    required this.currentLanguage,
  });

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  String _userName = '';
  String? _lastBloodPressure;
  DateTime? _lastBloodPressureDate;
  String? _lastBloodSugar;
  DateTime? _lastBloodSugarDate;
  int _todayTasksCount = 0;
  int _todayRemindersCount = 0;
  double _dailyProgress = 0;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadHealthData();
    _loadTasksRemindersCount();
    _loadDailyProgress();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _appVersion = info.version;
      });
    } catch (_) {
      // Ignore errors
    }
  }

  Future<void> _updateUserLang(String lang) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'lang': lang});
      }
    } catch (_) {
      // Ignore errors
    }
  }

  Future<void> rateApp() async {
    final Uri playStoreUrl = Uri.parse(
      'https://play.google.com/store/apps/details?id=com.reda.mohtm2',
    );
    if (await canLaunchUrl(playStoreUrl)) {
      await launchUrl(playStoreUrl);
    }
  }

  @override
  void didUpdateWidget(covariant HomeDashboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (mounted) {
      _loadDailyProgress();
      _loadTasksRemindersCount();
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return AppLocalizations.of(context)!.goodMorning;
    } else if (hour < 17) {
      return AppLocalizations.of(context)!.goodAfternoon;
    } else {
      return AppLocalizations.of(context)!.goodEvening;
    }
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();
        if (!mounted) return;
        if (doc.exists && doc.data() != null) {
          final firstName = doc.data()!['firstName'] ?? '';
          setState(() {
            _userName = firstName;
          });
        }
      }
    } catch (_) {
      // Ignore errors
    }
  }

  Future<void> _loadHealthData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          final bpSnapshot =
              await FirebaseFirestore.instance
                  .collection('blood_pressure_measurements')
                  .where('userId', isEqualTo: user.uid)
                  .orderBy('date', descending: true)
                  .limit(1)
                  .get();

          if (!mounted) return;
          if (bpSnapshot.docs.isNotEmpty) {
            final bp = bpSnapshot.docs.first;
            setState(() {
              _lastBloodPressure = '${bp['systolic']}/${bp['diastolic']}';
              _lastBloodPressureDate = (bp['date'] as Timestamp?)?.toDate();
            });
          }
        } catch (_) {}

        try {
          final bsSnapshot =
              await FirebaseFirestore.instance
                  .collection('blood_sugar_measurements')
                  .where('userId', isEqualTo: user.uid)
                  .orderBy('date', descending: true)
                  .limit(1)
                  .get();

          if (!mounted) return;
          if (bsSnapshot.docs.isNotEmpty) {
            final bs = bsSnapshot.docs.first;
            setState(() {
              _lastBloodSugar = '${bs['value']}';
              _lastBloodSugarDate = (bs['date'] as Timestamp?)?.toDate();
            });
          }
        } catch (_) {}
      }
    } catch (_) {
      // Ignore errors
    }
  }

  Future<void> _loadTasksRemindersCount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          final tasksSnapshot =
              await FirebaseFirestore.instance
                  .collection('tasks')
                  .where('userId', isEqualTo: user.uid)
                  .where('status', isEqualTo: 'open')
                  .get();

          if (!mounted) return;
          setState(() {
            _todayTasksCount = tasksSnapshot.docs.length;
          });

          final remindersSnapshot =
              await FirebaseFirestore.instance
                  .collection('reminders')
                  .where('userId', isEqualTo: user.uid)
                  .get();

          if (!mounted) return;
          int upcomingCount = 0;
          for (final doc in remindersSnapshot.docs) {
            final data = doc.data();
            final ts = data['dateTime'] as Timestamp?;
            if (ts == null) {
              continue;
            }
            final dateTime = ts.toDate();
            if (!_isReminderOutdated(data, dateTime)) {
              upcomingCount++;
            }
          }

          setState(() {
            _todayRemindersCount = upcomingCount;
          });
        } catch (_) {}
      }
    } catch (_) {
      // Ignore errors
    }
  }

  static bool _isReminderOutdated(
    Map<String, dynamic> data,
    DateTime dateTime,
  ) {
    final currentDate = DateTime.now();
    final repeat = data['repeat'] ?? 'Don\'t repeat';
    final durationType = data['durationType'];

    if (repeat == 'Don\'t repeat' && dateTime.isBefore(currentDate)) {
      return true;
    }

    if (repeat != 'Don\'t repeat' && dateTime.isBefore(currentDate)) {
      switch (durationType) {
        case 'until':
          final untilDate = data['untilDate'] as Timestamp?;
          if (untilDate != null && untilDate.toDate().isBefore(currentDate)) {
            return true;
          }
          break;
        case 'forever':
          return false;
        case 'count':
          final repeatCount = data['repeatCount'] as int?;
          if (repeatCount != null && repeatCount <= 0) {
            return true;
          }
          break;
        default:
          final untilDate = data['untilDate'] as Timestamp?;
          if (untilDate != null && untilDate.toDate().isBefore(currentDate)) {
            return true;
          }
      }
    }
    return false;
  }

  Future<void> _loadDailyProgress() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final today = DateTime.now();
        final dateStr =
            "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

        int totalItems = 0;
        double completedValue = 0;

        // Load general deeds for today from general_deeds_daily
        final generalDailyDoc =
            await FirebaseFirestore.instance
                .collection('general_deeds_daily')
                .doc('${user.uid}_$dateStr')
                .get();

        if (!mounted) return;
        if (generalDailyDoc.exists && generalDailyDoc.data() != null) {
          final data = generalDailyDoc.data()!;
          final generalDeeds = data['generalDeeds'] as Map<String, dynamic>?;

          if (generalDeeds != null) {
            totalItems += generalDeeds.length;
            for (final entry in generalDeeds.values) {
              final status = entry['status'] as String?;
              if (status == 'completed') {
                completedValue += 1;
              }
            }
          }
        }

        // Load religious/custom deeds for today from daily_deeds
        final dailyDeedsDoc =
            await FirebaseFirestore.instance
                .collection('daily_deeds')
                .doc('${user.uid}_$dateStr')
                .get();

        if (!mounted) return;
        if (dailyDeedsDoc.exists && dailyDeedsDoc.data() != null) {
          final data = dailyDeedsDoc.data()!;
          final customDeeds = data['customDeeds'] as Map<String, dynamic>?;

          // Count custom deeds
          if (customDeeds != null) {
            totalItems += customDeeds.length;
            for (final entry in customDeeds.values) {
              final status = entry['status'] as String?;
              if (status == 'completed') {
                completedValue += 1;
              }
            }
          }

          // Count prayers (5 daily prayers)
          final prayers = data['prayers'] as Map<String, dynamic>?;
          if (prayers != null) {
            totalItems += prayers.length;
            for (final prayerStatus in prayers.values) {
              final prayerMap = prayerStatus as Map?;
              final status = prayerMap?['status'] as String?;
              if (status != null &&
                  status != 'not_prayed' &&
                  status != 'missing') {
                completedValue += 1;
              }
            }
          }

          // Count sunnah prayers
          final sunnahPrayers = data['sunnahPrayers'] as Map<String, dynamic>?;
          if (sunnahPrayers != null) {
            totalItems += sunnahPrayers.length;
            for (final status in sunnahPrayers.values) {
              final statusMap = status as Map?;
              if (statusMap?['status'] == 'completed') {
                completedValue += 1;
              }
            }
          }

          // Count learning (based on chapters, not status)
          final learning = data['learning'] as Map<String, dynamic>?;
          if (learning != null) {
            totalItems += 1;
            final chapters = learning['chapters'] as double?;
            if (chapters != null && chapters > 0) {
              completedValue += 1;
            }
          }

          // Count supplications
          final supplications = data['supplications'] as Map<String, dynamic>?;
          if (supplications != null) {
            totalItems += supplications.length;
            for (final entry in supplications.values) {
              final status = entry['status'] as String?;
              if (status == 'completed') {
                completedValue += 1;
              }
            }
          }

          // Count fasting (only in Ramadan or specific days 13-15, or day 9 of Dhu al-Hijjah)
          final fasting = data['fasting'] as Map<String, dynamic>?;
          final showFasting =
              HijriDateUtil.isRamadan(today) ||
              HijriDateUtil.shouldShowFasting(today);
          if (showFasting && fasting != null) {
            totalItems += 1;
            final status = fasting['status'] as String?;
            if (status == 'completed') {
              completedValue += 1;
            }
          }

          // Surah Al-Kahf (only on Fridays)
          final surahAlKahf = data['surahAlKahf'] as Map<String, dynamic>?;
          if (today.weekday == DateTime.friday && surahAlKahf != null) {
            totalItems += 1;
            final status = surahAlKahf['status'] as String?;
            if (status == 'completed') {
              completedValue += 1;
            }
          }

          // Eid prayer (only on Eid days)
          final eidPrayer = data['eidPrayer'] as Map<String, dynamic>?;
          if (HijriDateUtil.isEid(today) && eidPrayer != null) {
            totalItems += 1;
            final status = eidPrayer['status'] as String?;
            if (status == 'completed') {
              completedValue += 1;
            }
          }
        }

        if (!mounted) return;
        setState(() {
          _dailyProgress =
              totalItems > 0 ? (completedValue / totalItems) * 100 : 0;
        });
      }
    } catch (_) {
      // Ignore errors
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final isRtl = locale == 'ar';

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        drawer: _buildDrawer(),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 140,
              floating: false,
              pinned: true,
              leading: Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
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
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.favorite, color: Colors.white, size: 22),
                ],
              ),
              backgroundColor: const Color.fromARGB(255, 182, 142, 190),
              actions: [
                IconButton(
                  icon: const Icon(Icons.language, color: Colors.white),
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
                                  onTap: () {
                                    final navigator = Navigator.of(context);
                                    widget.onLanguageChanged('en');
                                    _updateUserLang('en');
                                    if (!mounted) return;
                                    navigator.pop();
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
                                  onTap: () {
                                    final navigator = Navigator.of(context);
                                    widget.onLanguageChanged('ar');
                                    _updateUserLang('ar');
                                    if (!mounted) return;
                                    navigator.pop();
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
                  icon: const Icon(Icons.person, color: Colors.white),
                  onPressed: () {
                    Navigator.pushNamed(context, "/profile");
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromARGB(255, 160, 100, 190),
                        Color.fromARGB(255, 182, 142, 190),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${_getGreeting()}${_userName.isNotEmpty ? ", $_userName" : ""}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat.yMMMMd(locale).format(DateTime.now()),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(
                      AppLocalizations.of(context)!.todayOverview,
                    ),
                    const SizedBox(height: 12),
                    _buildTodayOverviewCards(),
                    const SizedBox(height: 24),
                    _buildSectionTitle(
                      AppLocalizations.of(context)!.occasionsToday,
                    ),
                    const SizedBox(height: 12),
                    _buildOccasionsCard(),
                    const SizedBox(height: 24),
                    _buildSectionTitle(
                      AppLocalizations.of(context)!.healthInfo,
                    ),
                    const SizedBox(height: 12),
                    _buildHealthCards(),
                    const SizedBox(height: 12),
                    _buildHealthInfoCard(),
                    const SizedBox(height: 24),
                    _buildSectionTitle(
                      AppLocalizations.of(context)!.dailyDeeds,
                    ),
                    const SizedBox(height: 12),
                    _buildDailyDeedsCard(),
                    const SizedBox(height: 24),
                    _buildQuickActions(),
                  ],
                ),
              ),
            ),
          ],
        ),
         bottomNavigationBar: const AppBannerAd(),

      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(255, 80, 40, 120),
      ),
    );
  }

  Widget _buildTodayOverviewCards() {
    return Row(
      children: [
        Expanded(
          child: _buildOverviewCard(
            icon: Icons.event,
            title: AppLocalizations.of(context)!.occasionsToday,
            subtitle: AppLocalizations.of(context)!.viewAll,
            color: const Color(0xFFBA68EC),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OccasionsPage()),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOverviewCard(
            icon: Icons.task_alt,
            title:
                '$_todayTasksCount ${AppLocalizations.of(context)!.tasksToday}',
            subtitle: AppLocalizations.of(context)!.viewAll,
            color: const Color(0xFF64B5F6),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TasksPage()),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOverviewCard(
            icon: Icons.alarm,
            title:
                '$_todayRemindersCount ${AppLocalizations.of(context)!.remindersToday}',
            subtitle: AppLocalizations.of(context)!.viewAll,
            color: const Color(0xFFFFB74D),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RemindersPage()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOccasionsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          StreamBuilder<List<QueryDocumentSnapshot>>(
            stream: getTodaysAnniversariesStream(),
            builder: (context, snapshot) {
              final hasData = snapshot.hasData && snapshot.data!.isNotEmpty;
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      hasData
                          ? const Color(0xFFBA68EC).withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.celebration,
                      color: hasData ? const Color(0xFFBA68EC) : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        hasData
                            ? '${snapshot.data!.length} ${AppLocalizations.of(context)!.occasionsToday}'
                            : AppLocalizations.of(context)!.noOccasionsToday,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.filter_list, size: 20),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => const OccasionsPage(
                                  showAppBar: true,
                                  initialTabIndex: 2,
                                ),
                          ),
                        );
                      },
                      tooltip: AppLocalizations.of(context)!.filter,
                    ),
                    if (hasData)
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      const OccasionsPage(showAppBar: true),
                            ),
                          );
                        },
                        child: Text(AppLocalizations.of(context)!.viewAll),
                      ),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOccasionQuickAction(
                  icon: Icons.notifications_active,
                  label: AppLocalizations.of(context)!.upcomingOccasions,
                  color: const Color(0xFF64B5F6),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => const OccasionsPage(
                              showAppBar: true,
                              initialTabIndex: 1,
                            ),
                      ),
                    );
                  },
                ),
                _buildOccasionQuickAction(
                  icon: Icons.star,
                  label: AppLocalizations.of(context)!.importantOccasions,
                  color: const Color(0xFFFFB74D),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ImportantAnnPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOccasionQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthCards() {
    return Row(
      children: [
        Expanded(
          child: _buildHealthCard(
            title: AppLocalizations.of(context)!.bloodPressure,
            value: _lastBloodPressure ?? '--/--',
            date: _lastBloodPressureDate,
            icon: Icons.monitor_heart,
            color: const Color(0xFFF48FB1),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BloodPressurePage(),
                ),
              );
            },
            onAdd: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => AddBloodPressurePage(userId: user.uid),
                  ),
                );
                _loadHealthData();
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildHealthCard(
            title: AppLocalizations.of(context)!.bloodSugar,
            value: _lastBloodSugar ?? '--',
            date: _lastBloodSugarDate,
            icon: Icons.water_drop,
            color: const Color(0xFF81C784),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BloodSugarPage()),
              );
            },
            onAdd: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddBloodSugarPage(userId: user.uid),
                  ),
                );
                _loadHealthData();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHealthCard({
    required String title,
    required String value,
    required DateTime? date,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required VoidCallback onAdd,
  }) {
    final locale = Localizations.localeOf(context).languageCode;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
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
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (date != null) ...[
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(
                    context,
                  )!.lastReading(DateFormat.MMMd(locale).format(date)),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onAdd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)!.addReading),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HealthInfoPage()),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF9575CD).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.medical_information,
                  color: Color(0xFF9575CD),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.healthInfo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.viewAll,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyDeedsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4DB6AC).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.self_improvement, color: Color(0xFF4DB6AC)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.progressToday,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4DB6AC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_dailyProgress.toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDeedQuickAction(
                  icon: Icons.edit_note,
                  label: AppLocalizations.of(context)!.generalDeeds,
                  onTap: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => GeneralDeedsPage(userId: user.uid),
                        ),
                      );
                      _loadDailyProgress();
                    }
                  },
                ),
                _buildDeedQuickAction(
                  icon: Icons.mosque,
                  label: AppLocalizations.of(context)!.religiousDeeds,
                  onTap: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DailyDeedPage(userId: user.uid),
                        ),
                      );
                      _loadDailyProgress();
                    }
                  },
                ),
                _buildDeedQuickAction(
                  icon: Icons.bar_chart,
                  label: AppLocalizations.of(context)!.statistics,
                  onTap: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  DailyDeedStatisticsPage(userId: user.uid),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeedQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4DB6AC).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF4DB6AC)),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(AppLocalizations.of(context)!.quickActions),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.celebration,
                label: AppLocalizations.of(context)!.addOccasion,
                color: const Color(0xFFBA68EC),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddAnniversaryPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.task_alt,
                label: AppLocalizations.of(context)!.addTask,
                color: const Color(0xFF64B5F6),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddTaskPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.alarm,
                label: AppLocalizations.of(context)!.addReminder,
                color: const Color(0xFFFFB74D),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddReminderPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.rate_review,
                label: AppLocalizations.of(context)!.feedback,
                color: const Color(0xFF795548),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AppFeedbackPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.share,
                label: AppLocalizations.of(context)!.shareApp,
                color: const Color(0xFF03A9F4),
                onTap: () async {
                  await Share.share(
                    'https://play.google.com/store/apps/details?id=com.reda.mohtm2',
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.contact_mail,
                label: AppLocalizations.of(context)!.contactUs,
                color: const Color(0xFF607D8B),
                onTap: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text(AppLocalizations.of(context)!.contactUs),
                          content: const Text(
                            'Email: mohtmapp.supp0rt@gmail.com',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(AppLocalizations.of(context)!.cancel),
                            ),
                          ],
                        ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSocialMediaSection(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.followUs,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF888888),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.facebook, color: Color(0xFF1877F2)),
              iconSize: 28,
              onPressed: () async {
                final Uri webUri = Uri.parse(
                  'https://www.facebook.com/mohtmapp/',
                );
                if (await canLaunchUrl(webUri)) {
                  await launchUrl(webUri, mode: LaunchMode.externalApplication);
                }
              },
            ),
            const SizedBox(width: 24),
            IconButton(
              icon: const Icon(Icons.camera_alt, color: Color(0xFFE4405F)),
              iconSize: 28,
              onPressed: () async {
                final Uri webUri = Uri.parse(
                  'https://www.instagram.com/mohtmapp/',
                );
                await launchUrl(webUri, mode: LaunchMode.externalApplication);
              },
            ),
            const SizedBox(width: 24),
            IconButton(
              icon: const Icon(
                Icons.play_circle_fill,
                color: Color(0xFFFF0000),
              ),
              iconSize: 28,
              onPressed: () async {
                final Uri webUri = Uri.parse(
                  'https://www.youtube.com/@Mohtmapp',
                );
                await launchUrl(webUri, mode: LaunchMode.externalApplication);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
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
                        backgroundImage: AssetImage('assets/images/icon.png'),
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
                  leading: const Icon(Icons.event),
                  title: Text(AppLocalizations.of(context)!.occasions),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OccasionsPage(),
                      ),
                    );
                  },
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
                ExpansionTile(
                  leading: const Icon(Icons.self_improvement),
                  title: Text(AppLocalizations.of(context)!.dailyDeed),
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.edit_note),
                      title: Text(AppLocalizations.of(context)!.dailyDeed),
                      onTap: () {
                        Navigator.pop(context);
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      GeneralDeedsPage(userId: user.uid),
                            ),
                          );
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.self_improvement),
                      title: Text(AppLocalizations.of(context)!.religiousDeed),
                      onTap: () {
                        Navigator.pop(context);
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => DailyDeedPage(userId: user.uid),
                            ),
                          );
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.bar_chart),
                      title: Text(
                        AppLocalizations.of(context)!.statisticsreligiousDeed,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      DailyDeedStatisticsPage(userId: user.uid),
                            ),
                          );
                        }
                      },
                    ),
                  ],
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BloodPressurePage(),
                          ),
                        );
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
                  title: Text(AppLocalizations.of(context)!.importantOccasions),
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
                // ListTile(
                //   leading: const Icon(Icons.filter_list),
                //   title: Text(AppLocalizations.of(context)!.filter),
                //   onTap: () {
                //     Navigator.pop(context);
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => const OccasionFilterPage(),
                //       ),
                //     );
                //   },
                // ),
                ListTile(
                  leading: const Icon(Icons.star),
                  title: Text(AppLocalizations.of(context)!.rateUs),
                  onTap: () {
                    Navigator.pop(context);
                    rateApp();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share),
                  title: Text(AppLocalizations.of(context)!.shareApp),
                  onTap: () {
                    Navigator.pop(context);
                    Share.share(
                      'https://play.google.com/store/apps/details?id=com.reda.mohtm2',
                    );
                  },
                ),
                ExpansionTile(
                  leading: const Icon(Icons.settings),
                  title: Text(AppLocalizations.of(context)!.settings),
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.lock_reset),
                      title: Text(AppLocalizations.of(context)!.changePassword),
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
                const SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.link,
                        size: 20,
                        color: Color(0xFF888888),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.followUs,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.facebook,
                        color: Color(0xFF1877F2),
                      ),
                      iconSize: 32,
                      onPressed: () async {
                        final Uri webUri = Uri.parse(
                          'https://www.facebook.com/mohtmapp/',
                        );
                        await launchUrl(
                          webUri,
                          mode: LaunchMode.externalApplication,
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Color(0xFFE4405F),
                      ),
                      iconSize: 32,
                      onPressed: () async {
                        final Uri webUri = Uri.parse(
                          'https://www.instagram.com/mohtmapp/',
                        );
                        await launchUrl(
                          webUri,
                          mode: LaunchMode.externalApplication,
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(
                        Icons.play_circle_fill,
                        color: Color(0xFFFF0000),
                      ),
                      iconSize: 32,
                      onPressed: () async {
                        final uri = Uri.parse(
                          'https://www.youtube.com/@Mohtmapp',
                        );
                        await launchUrl(uri, mode: LaunchMode.inAppWebView);
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
          const AppBannerAd(),
        ],
      ),
    );
  }
}
