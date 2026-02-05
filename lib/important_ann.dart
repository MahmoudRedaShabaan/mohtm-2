import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'l10n/app_localizations.dart';

import 'package:myapp/anniversary_info_page.dart';
import 'package:myapp/lookup.dart';

class ImportantAnnPage extends StatefulWidget {
  const ImportantAnnPage({super.key});

  @override
  State<ImportantAnnPage> createState() => _ImportantAnnPageState();
}

class _ImportantAnnPageState extends State<ImportantAnnPage> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Localizations.localeOf(context).languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.importantOccasions,
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
        body: StreamBuilder<List<QueryDocumentSnapshot>>(
          stream: getImportantOccasionsStream(),
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
                      Icons.priority_high,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.noImportantOccasions,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.noImportantOccasionsMessage,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            final importantOccasions = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: importantOccasions.length,
              itemBuilder: (context, index) {
                final doc = importantOccasions[index];
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
                
                // Priority 1 is always high priority (red color)
                const priorityColor = Colors.red;
                
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
      ),
    );
  }

  Stream<List<QueryDocumentSnapshot>> getImportantOccasionsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value([]);
    }
    
    return FirebaseFirestore.instance
        .collection('anniversaries')
        .where('createdBy', isEqualTo: user.uid)
        .where('priority', isEqualTo: '1') // Filter for priority 1 (high priority)
        .orderBy('date', descending: false) // Order by date ascending
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.toList(),
        );
  }
}
