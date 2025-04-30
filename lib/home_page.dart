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

class HomePage extends StatelessWidget {
  HomePage({super.key});

  // Static list of anniversaries (replace with actual data fetching later)
  final List<Anniversary> todayAnniversaries = [
    // TODO: Filter anniversaries to show only today's
    Anniversary(
      date: DateTime(2024, 5, 15),
      name: "John Doe's Birthday",
      description: "Celebrating John's Birthday",
      type: "Birthday",
    ),
    Anniversary(
      date: DateTime(2024, 6, 20),
      name: "Jane Smith's Wedding",
      description: "Celebrating Jane and her Spouse's Wedding",
      type: "Wedding",
    ),
    Anniversary(
      date: DateTime(2024, 3, 10),
      name: "Michael Brown's Death Anniversary",
      description: "Remembering Michael",
      type: "Death",
    ),Anniversary(
      date: DateTime(2024, 3, 10),
      name: "Michael Brown's Death Anniversary",
      description: "Remembering Michael",
      type: "Death",
    ),Anniversary(
      date: DateTime(2024, 3, 10),
      name: "Michael Brown's Death Anniversary",
      description: "Remembering Michael",
      type: "Death",
    ),Anniversary(
      date: DateTime(2024, 3, 10),
      name: "Michael Brown's Death Anniversary",
      description: "Remembering Michael",
      type: "Death",
    ),Anniversary(
      date: DateTime(2024, 3, 10),
      name: "Michael Brown's Death Anniversary",
      description: "Remembering Michael",
      type: "Death",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            // Example leading icon (you can change this)
            icon: const Icon(Icons.menu),
            onPressed: () {
              // TODO: Implement leading action
            },
          ),
          title: const Text('mohtm -مهتم'),
          backgroundColor: primaryColor,
          actions: <Widget>[
            IconButton(
              // Profile icon
              icon: const Icon(Icons.person),
              onPressed: () {
                // TODO: Implement profile action
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
        body: TabBarView(
          children: [
            // Content for Today's Anniversaries tab
            ListView.builder(
              itemCount: todayAnniversaries.length,
              itemBuilder: (context, index) {
                final anniversary = todayAnniversaries[index];
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
            Center(
              child: Text('Content for Filter Anniversaries'),
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
}
