import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/anniversary_info_page.dart';
import 'package:myapp/lookup.dart';
import 'package:myapp/l10n/app_localizations.dart';

class OccasionFilterPage extends StatefulWidget {
  const OccasionFilterPage({super.key});

  @override
  State<OccasionFilterPage> createState() => _OccasionFilterPageState();
}

class _OccasionFilterPageState extends State<OccasionFilterPage> {
  DateTime? filterStartDate;
  DateTime? filterEndDate;
  List<QueryDocumentSnapshot> filteredDocs = [];
  bool isFiltering = false;

  Future<void> filterAnniversariesByMonthDay() async {
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
          final normalized = DateTime(2000, date.month, date.day);
          if (start.isBefore(end) || start.isAtSameMomentAs(end)) {
            return (normalized.isAfter(start) ||
                    normalized.isAtSameMomentAs(start)) &&
                (normalized.isBefore(end) || normalized.isAtSameMomentAs(end));
          } else {
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

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                            final initialDate =
                                filterStartDate != null
                                    ? DateTime(
                                      currentYear,
                                      filterStartDate!.month,
                                      filterStartDate!.day,
                                    )
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
                            final initialDate =
                                filterEndDate != null
                                    ? DateTime(
                                      currentYear,
                                      filterEndDate!.month,
                                      filterEndDate!.day,
                                    )
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
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: ElevatedButton.icon(
                          onPressed: filterAnniversariesByMonthDay,
                          icon: const Icon(Icons.filter_alt),
                          label: Text(AppLocalizations.of(context)!.filter),
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
            child:
                isFiltering
                    ? const Center(child: CircularProgressIndicator())
                    : filteredDocs.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 64,
                            color: Colors.grey[400],
                          ),
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
                        return _buildAnniversaryCard(doc);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnniversaryCard(QueryDocumentSnapshot doc) {
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
        typeName =
            locale == 'ar'
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
      priorityName =
          locale == 'ar'
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
                  style: const TextStyle(
                    fontSize: 11,
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
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
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
  }
}
