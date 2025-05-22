import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/anniversary_info_page.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/login_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  DateTime? startDate;
  DateTime? endDate;
  // String _currentLanguage = "en"; // 'en' for English, 'ar' for Arabic
  List<Anniversary> filteredAnniversaries = [];

  DateTime? filterStartDate;
  DateTime? filterEndDate;
  List<QueryDocumentSnapshot> filteredDocs = [];
  bool isFiltering = false;

  @override
  void initState() {
    super.initState();
    // Initially show all anniversaries in the filter tab
    filteredAnniversaries = widget.todayAnniversaries;
  }

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
            title: Text(AppLocalizations.of(context)!.title),
            backgroundColor: primaryColor,
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.language),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Column(
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
                              widget.onLanguageChanged('en');
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
                            onTap: () {
                              widget.onLanguageChanged('ar');
                              Navigator.pop(context);
                            },
                          ),
                        ],
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
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: const BoxDecoration(color: primaryColor),
                  child: Text(
                    AppLocalizations.of(context)!.mohtmMenu, // You can change this to your app name or a relevant title
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.star),
                  title:  Text(AppLocalizations.of(context)!.rateUs),
                  onTap: () {
                    // TODO: Implement rate us functionality
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share),
                  title:  Text(AppLocalizations.of(context)!.shareApp),
                  onTap: () {
                    // TODO: Implement share app functionality
                  },
                ),
                ExpansionTile(
                  leading: const Icon(Icons.settings),
                  title:  Text(AppLocalizations.of(context)!.settings),
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.lock_reset),
                      title:  Text(AppLocalizations.of(context)!.changePassword),
                      onTap: () {
                        Navigator.pop(context); // Close the drawer first
                        Navigator.pushNamed(context, '/change_password');
                      },
                    ),
                  ],
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title:  Text(AppLocalizations.of(context)!.logout),
                  onTap: () {
                    // TODO: Implement share app functionality
                    signOut(context);
                  },
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // Content for Today's Anniversaries tab
              StreamBuilder<List<QueryDocumentSnapshot>>(
                stream: getTodaysAnniversariesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return  Center(child: Text(AppLocalizations.of(context)!.noAnniversariesToday));
                  }

                  final todayAnniversaries = snapshot.data!;

                  return ListView.builder(
                    itemCount: todayAnniversaries.length,
                    itemBuilder: (context, index) {
                      final doc = todayAnniversaries[index];
                      final date = (doc['date'] as Timestamp).toDate();
                      final title = doc['title'] ?? '';
                      final type = doc['type'] ?? '';
                      final priority = doc['priority'] ?? '';
                      Color priorityColor;
                      switch (priority) {
                        case 'High':
                          priorityColor = const Color.fromARGB(255, 4, 91, 1);
                          break;
                        case 'Medium':
                          priorityColor = const Color.fromARGB(255, 8, 193, 20);
                          break;
                        case 'Low':
                          priorityColor = const Color.fromARGB(255, 188, 246, 140)!;
                          break;
                        default:
                          priorityColor = Colors.grey;
                      }
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => AnniversaryInfoPage(
                                      anniversaryId: doc.id,
                                    ),
                              ),
                            );
                          },
                          leading: CircleAvatar(
                            child: Text(
                              '${date.day}/${date.month}\n${date.year}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                          title: Text(title),
                          subtitle: Text(AppLocalizations.of(context)!.typeLabel(type)),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: priorityColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              priority,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.date_range),
                                    label: Text(
                                      filterStartDate == null
                                          ? 'Start Date'
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
                                        helpText: 'Start Date',
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
                                // SizedBox(
                                //   width: MediaQuery.of(context).size.width * 0.4,
                                //   child: OutlinedButton.icon(
                                //     icon: const Icon(Icons.date_range),
                                //     label: Text(
                                //       filterStartDate == null
                                //           ? 'Start Date'
                                //           : 'Start: ${filterStartDate!.day}/${filterStartDate!.month}',
                                //     ),
                                //     onPressed:
                                //         () => _pickDayMonth(
                                //           context: context,
                                //           isStart: true,
                                //         ),
                                //   ),
                                // ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.date_range),
                                    label: Text(
                                      filterEndDate == null
                                          ? 'End Date'
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
                                        helpText: 'End Date',
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.6,
                                  child: ElevatedButton.icon(
                                    onPressed: filterAnniversariesByMonthDay,
                                    icon: const Icon(Icons.filter_alt),
                                    label: const Text('Filter'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        156,
                                        217,
                                        115,
                                      ),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
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
                                      color: Color.fromARGB(255, 172, 171, 170),
                                    ),
                                    tooltip: 'Clear Filter',
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
                              ? const Center(child: CircularProgressIndicator())
                              : filteredDocs.isEmpty
                              ? const Center(
                                child: Text('No anniversaries found.'),
                              )
                              : ListView.builder(
                                itemCount: filteredDocs.length,
                                itemBuilder: (context, index) {
                                  final doc = filteredDocs[index];
                                  final date =
                                      (doc['date'] as Timestamp).toDate();
                                  final title = doc['title'] ?? '';
                                  final type = doc['type'] ?? '';
                                  final priority = doc['priority'] ?? '';
                                  Color priorityColor;
                                  switch (priority) {
                                    case 'High':
                                      priorityColor = Colors.red;
                                      break;
                                    case 'Medium':
                                      priorityColor = Colors.orange;
                                      break;
                                    case 'Low':
                                      priorityColor = Colors.yellow[700]!;
                                      break;
                                    default:
                                      priorityColor = Colors.grey;
                                  }
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 6,
                                    ),
                                    child: ListTile(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    AnniversaryInfoPage(
                                                      anniversaryId: doc.id,
                                                    ),
                                          ),
                                        );
                                      },
                                      leading: CircleAvatar(
                                        child: Text(
                                          '${date.day}/${date.month}\n${date.year}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ),
                                      title: Text(title),
                                      subtitle: Text('Type: $type'),
                                      trailing: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: priorityColor,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          priority,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
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
              ), // Content for second tab
            ],
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

  Widget _buildAnniversaryCard(Anniversary anniversary) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              anniversary.date.toLocal().toString().split(
                ' ',
              )[0], // Format date
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4.0),
            Text(anniversary.name, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4.0),
            Text(anniversary.description),
            const SizedBox(height: 4.0),
            Text(
              'Type: ${anniversary.type}',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
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
      await FirebaseAuth.instance.signOut();
      // No need to navigate! StreamBuilder in main.dart will handle it.
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

  Future<void> _pickDayMonth({
    required BuildContext context,
    required bool isStart,
  }) async {
    int selectedMonth = (isStart ? filterStartDate : filterEndDate)?.month ?? 1;
    int selectedDay = (isStart ? filterStartDate : filterEndDate)?.day ?? 1;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            isStart ? 'Select Start Day/Month' : 'Select End Day/Month',
          ),
          content: Row(
            children: [
              // Month picker
              DropdownButton<int>(
                value: selectedMonth,
                items:
                    List.generate(12, (i) => i + 1)
                        .map(
                          (m) => DropdownMenuItem(value: m, child: Text('$m')),
                        )
                        .toList(),
                onChanged: (val) {
                  if (val != null) {
                    selectedMonth = val;
                    // Update UI
                    (context as Element).markNeedsBuild();
                  }
                },
              ),
              const SizedBox(width: 16),
              // Day picker
              DropdownButton<int>(
                value: selectedDay,
                items:
                    List.generate(31, (i) => i + 1)
                        .map(
                          (d) => DropdownMenuItem(value: d, child: Text('$d')),
                        )
                        .toList(),
                onChanged: (val) {
                  if (val != null) {
                    selectedDay = val;
                    (context as Element).markNeedsBuild();
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  final date = DateTime(2000, selectedMonth, selectedDay);
                  if (isStart) {
                    filterStartDate = date;
                  } else {
                    filterEndDate = date;
                  }
                });
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
