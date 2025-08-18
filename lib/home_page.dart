import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/anniversary_info_page.dart';
import 'package:myapp/appfeedback.dart';
import 'package:myapp/login_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:myapp/lookup.dart';
import 'package:package_info_plus/package_info_plus.dart';

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

  HomePage({
    super.key,
    required this.onLanguageChanged,
    required this.currentLanguage,
  });
  // Static list of anniversaries (replace with actual data fetching later)
  final List<Anniversary> todayAnniversaries = <Anniversary>[];

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    filteredAnniversaries = widget.todayAnniversaries;
    _loadAppVersion();
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
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'lang': lang});
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



  void filterAnniversaries() {
    if (startDate == null || endDate == null) {
      return;
    }
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          widget.currentLanguage == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
      child: DefaultTabController(
        length: 2, // Number of tabs
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
                const Icon(Icons.favorite, color: Color.fromARGB(255, 80, 40, 120), size: 28),
              ],
            ),
            // title: Image.asset(
            //   'assets/images/title.png',
            //   height: 44,
            //   fit: BoxFit.contain,
            // ),
            backgroundColor: const Color.fromARGB(255, 182, 142, 190),
            actions: <Widget>[
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
            bottom: const TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.calendar_today),
                ), // Today's Anniversaries icon// Today's Anniversaries icon
                Tab(
                  icon: Icon(Icons.filter_list),
                ), // Filter Anniversaries icon// Filter Anniversaries icon
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
                        decoration: const BoxDecoration(color: Color.fromARGB(255, 211, 154, 223)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundImage:
                                  AssetImage('assets/images/icon.png'),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              AppLocalizations.of(context)!.mohtmMenu,
                              style: const TextStyle(color: Colors.white, fontSize: 24),
                            ),
                          ],
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.star),
                        title: Text(AppLocalizations.of(context)!.rateUs),
                        onTap: () {
                          // TODO: Implement rate us functionality
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.share),
                        title: Text(AppLocalizations.of(context)!.shareApp),
                        onTap: () {
                          // TODO: Implement share app functionality
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
                              Navigator.pop(context); // Close the drawer first
                              Navigator.pushNamed(context, '/change_password');
                            },
                          ),
                        ],
                      ),
                      ListTile(
                        leading: const Icon(Icons.contact_mail),
                        title: Text(AppLocalizations.of(context)!.contactUs),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AppFeedbackPage()),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: Text(AppLocalizations.of(context)!.logout),
                        onTap: () {
                          signOut(context);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

          body: SafeArea(
            child: TabBarView(
              children: [
                // Content for Today's Anniversaries tab
                StreamBuilder<List<QueryDocumentSnapshot>>(
                  stream: getTodaysAnniversariesStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          AppLocalizations.of(context)!.noAnniversariesToday,
                        ),
                      );
                    }

                    final todayAnniversaries = snapshot.data!;

                    return ListView.builder(
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
                          if(typeId=="4") {
                            typeName=doc['addType']?.toString() ?? '';
                          } else {
                          final typeObj = eventTypes.firstWhere(
                            (type) => type['id'].toString() == typeId,
                            orElse: () => <String, dynamic>{},
                          );
                          typeName = locale == 'ar' ? (typeObj['arabicName'] ?? typeId) : (typeObj['englishName'] ?? typeId);
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
                          priorityName = locale == 'ar' ? (priorityObj['priorityAr'] ?? priorityId) : (priorityObj['priorityEn'] ?? priorityId);
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
                                  builder: (context) => AnniversaryInfoPage(
                                    anniversaryId: doc.id,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: priorityColor.withOpacity(0.15),
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
                                              typeName == 'Birthday' || typeName == 'عيد ميلاد' ? Icons.cake :
                                              typeName == 'Wedding' || typeName == 'زواج' ? Icons.favorite :
                                              typeName == 'Death' || typeName == 'وفاة' ? Icons.sentiment_very_dissatisfied :
                                              Icons.event,
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
                                    label: Text(priorityName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                // Content for Filter Anniversaries tab
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.date_range),
                                      label: Text(
                                        filterStartDate == null
                                            ? AppLocalizations.of(context)!.startDate
                                            : 'Start: ${filterStartDate!.day}/${filterStartDate!.month}',
                                      ),
                                      onPressed: () async {
                                        final pickedDate = await showDatePicker(
                                          context: context,
                                          initialDate:
                                              filterStartDate ??
                                              DateTime(2000, 1, 1),
                                          firstDate: DateTime(2000, 1, 1),
                                          lastDate: DateTime(2000, 12, 31),
                                          helpText: AppLocalizations.of(context)!.startDate,
                                        );
                                        if (pickedDate != null) {
                                          setState(() {
                                            filterStartDate = DateTime(
                                              2000,
                                              pickedDate.month,
                                              pickedDate.day,
                                            );
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.date_range),
                                      label: Text(
                                        filterEndDate == null
                                            ? AppLocalizations.of(context)!.endDate
                                            : 'End: ${filterEndDate!.day}/${filterEndDate!.month}',
                                      ),
                                      onPressed: () async {
                                        final pickedDate = await showDatePicker(
                                          context: context,
                                          initialDate:
                                              filterEndDate ??
                                              DateTime(2000, 12, 31),
                                          firstDate: DateTime(2000, 1, 1),
                                          lastDate: DateTime(2000, 12, 31),
                                          helpText: AppLocalizations.of(context)!.endDate,
                                        );
                                        if (pickedDate != null) {
                                          setState(() {
                                            filterEndDate = DateTime(
                                              2000,
                                              pickedDate.month,
                                              pickedDate.day,
                                            );
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                    child: ElevatedButton.icon(
                                      onPressed: filterAnniversariesByMonthDay,
                                      icon: const Icon(Icons.filter_alt),
                                      label:  Text(AppLocalizations.of(context)!.filter),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                          255,
                                          156,
                                          217,
                                          115,
                                        ),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.2,
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
                                        color: Color.fromARGB(
                                          255,
                                          172,
                                          171,
                                          170,
                                        ),
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
                        child:
                            isFiltering
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : filteredDocs.isEmpty
                                ?  Center(
                                  child: Text(AppLocalizations.of(context)!.noAnniversariesFound),
                                )
                                : ListView.builder(
                                  itemCount: filteredDocs.length,
                                  itemBuilder: (context, index) {
                                    final doc = filteredDocs[index];
                                    final date =
                                        (doc['date'] as Timestamp).toDate();
                                    final title = doc['title'] ?? '';
                                    final String typeId = doc['type']?.toString() ?? '';
                                    final locale = Localizations.localeOf(context).languageCode;
                                    final eventTypes = LookupService().eventTypes;
                                    String typeName = typeId;
                                    if (typeId.isNotEmpty) {
                                      if (typeId=="4") {
                                        typeName=doc['addType']?.toString() ?? '';
                                      } else {
                                      final typeObj = eventTypes.firstWhere(
                                        (type) => type['id'].toString() == typeId,
                                        orElse: () => <String, dynamic>{},
                                      );
                                      typeName = locale == 'ar' ? (typeObj['arabicName'] ?? typeId) : (typeObj['englishName'] ?? typeId);
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
                                      priorityName = locale == 'ar' ? (priorityObj['priorityAr'] ?? priorityId) : (priorityObj['priorityEn'] ?? priorityId);
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
                                              builder: (context) => AnniversaryInfoPage(
                                                anniversaryId: doc.id,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 28,
                                                backgroundColor: priorityColor.withOpacity(0.15),
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
                                                          typeName == 'Birthday' || typeName == 'عيد ميلاد' ? Icons.cake :
                                                          typeName == 'Wedding' || typeName == 'زواج' ? Icons.favorite :
                                                          typeName == 'Death' || typeName == 'وفاة' ? Icons.sentiment_very_dissatisfied :
                                                          Icons.event,
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
                                                label: Text(priorityName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                ), // Content for second tab
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, "/add_anniversary");
            },
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        ),
      ),
    );
  }


  // Future<void> signOut(BuildContext context) async {
  //   try {
  //     await FirebaseAuth.instance.signOut().then((value) {
  //       // Optional: Navigate the user to the login screen or any other desired screen
  //       WidgetsBinding.instance.addPostFrameCallback((_) {
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => const LoginPage(),
  //           ), // Replace LoginPage with your actual login screen
  //         );
  //       });
  //     });
  //   } catch (e) {
  //     // Handle any errors that might occur during sign-out
  //     print("Error signing out: $e");
  //     // Optionally show an error message to the user
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
  //   }
  // }
  Future<void> signOut(BuildContext context) async {

    try {
      print('Signing out...');
      await FirebaseAuth.instance.signOut();
      print('Signing out end...');
      // Force navigation to login page after sign out
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(
              onLanguageChanged: widget.onLanguageChanged,
              currentLanguage: widget.currentLanguage,
            ),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      print("Error signing out: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
      }
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

  void filterAnniversariesByMonthDay() async {
    if (filterStartDate == null || filterEndDate == null) return;
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

    setState(() {
      filteredDocs = docs;
      isFiltering = false;
    });
  }

}
