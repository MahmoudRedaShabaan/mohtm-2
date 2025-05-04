import 'package:flutter/material.dart';
import 'package:myapp/constants.dart';

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
  HomePage({super.key});

  // Static list of anniversaries (replace with actual data fetching later)
  final List<Anniversary> todayAnniversaries = <Anniversary>[
    // TODO: Filter anniversaries to show only today's
    Anniversary(
      date: DateTime(2024, 5, 15),
      name: "John Doe's Birthday",
      description: "Celebrating John's Birthday",

      type: "Birthday",
    ),
    Anniversary(
      date: DateTime(2024, 5, 15),
      name: "Another Birthday",
      description: "Wishing someone a happy birthday today!",
      type: "Birthday",
    ),
    Anniversary(
      date: DateTime(2024, 5, 15),
      name: "Wedding Anniversary",
      description: "Celebrating a special couple's anniversary.",
      type: "Wedding",
    ),
  ];

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? startDate;
  DateTime? endDate;
  String _currentLanguage = "en"; // 'en' for English, 'ar' for Arabic
  List<Anniversary> filteredAnniversaries = [];

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
 return DefaultTabController(
 length: 2, // Number of tabs
 child: Scaffold(
 appBar: AppBar(
 leading: Builder( // Wrap IconButton with Builder
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
 title: const Text('mohtm -مهتم'),
 backgroundColor: primaryColor,
 actions: <Widget>[
 PopupMenuButton<String>(
 icon: const Icon(Icons.language), // Corrected
 onSelected: (String result) {
 setState(() {
 _currentLanguage = result;
 });
 // TODO: Implement actual language change logic
 // This would involve updating localized strings in your app
 },
 itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
 PopupMenuItem<String>(
 value: 'en',
 child: Row(
 children: [
 Icon(
 Icons.check,
 color: _currentLanguage == 'en'
 ? Colors.green
 : Colors.transparent,
 ),
 SizedBox(width: 8),
 Text('English'),
 ],
 ),
 ),
                PopupMenuItem<String>(
                  value: 'ar',
                  child: Row(
                    children: [
                      Icon(
 Icons.check,
 color:
 _currentLanguage == 'ar'
 ? Colors.green
                                    : Colors.transparent,
                          ),
                          SizedBox(width: 8),
                          Text('العربية'),
                        ],
                      ),
                    ),
                  ],
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
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: primaryColor,
                ),
                child: Text(
                  'mohtm Menu', // You can change this to your app name or a relevant title
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Rate Us'),
                onTap: () {
                  // TODO: Implement rate us functionality
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share App'),
                onTap: () {
                  // TODO: Implement share app functionality
                },
              ),
              ExpansionTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.lock_reset),
                    title: const Text('Change Password'),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer first
                      Navigator.pushNamed(context, '/change_password');

                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Content for Today's Anniversaries tab
            ListView.builder(
              itemCount: widget.todayAnniversaries.length,
              itemBuilder: (context, index) {
                final anniversary = widget.todayAnniversaries[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          anniversary.date.toLocal().toString().split(
                            ' ',
                          )[0], // Format date
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          anniversary.name,
                          style: const TextStyle(fontSize: 18),
                        ),
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
              },
            ),
            // Content for Filter Anniversaries tab
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: startDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              startDate = pickedDate;
                            });
                          }
                        },
                        child: Text(
                          startDate == null
                              ? 'Select Start Date'
                              : 'Start Date: ${startDate!.toLocal().toString().split(' ')[0]}',
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: endDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              endDate = pickedDate;
                            });
                          }
                        },
                        child: Text(
                          endDate == null
                              ? 'Select End Date'
                              : 'End Date: ${endDate!.toLocal().toString().split(' ')[0]}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: filterAnniversaries,
                    child: const Text('Filter'),
                  ),
                  const SizedBox(height: 16.0),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredAnniversaries.length,
                      itemBuilder: (context, index) {
                        return _buildAnniversaryCard(
                          filteredAnniversaries[index],
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
}
