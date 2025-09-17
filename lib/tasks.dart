import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_task.dart';
import 'update_task.dart';
import 'constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  String? _selectedCategoryId;
  String _selectedStatus = 'all'; // 'all', 'open', 'done'
  List<Map<String, dynamic>> _categories = [];
  static const MethodChannel _widgetChannel = MethodChannel(
    'com.reda.mohtm2/widget',
  );
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(TasksPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('didUpdateWidget called');
    print('_scrollController: $_scrollController');
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
    print('initState called');
    print('_scrollController: $_scrollController');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController != null) {
        _scrollController.addListener(_onScroll);
      }
    });
  }

  /*************  ✨ Windsurf Command ⭐  *************/
  /// Called when the user scrolls the page. If the user has scrolled to the
  /// bottom, reload the page. This is a workaround for a Flutter bug that
  /// prevents the ListView from updating when the user scrolls to the bottom.
  ///
  /// See https://github.com/flutter/flutter/issues/101432 for more details.
  /*******  12e5014c-40ff-40da-93ce-dcf4722e8b64  *******/
  void _onScroll() {
    print('Scroll position: ${_scrollController.offset}');
    print(
      'Scroll position max extent: ${_scrollController.position.maxScrollExtent}',
    );
    print(
      'Scroll position out of range: ${_scrollController.position.outOfRange}',
    );
    print('Scroll position: ${_scrollController.offset}');
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      print('Scrolled to the bottom');
      setState(() {}); // Reload the page
    }
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
            final locale = Localizations.localeOf(context).languageCode;

            return {'taskname': taskname, 'date': duedate, 'status': status};
          }).toList();
      final payload = {'items': items, 'total': totalCount};
      await prefs.setString('widget_task_items', jsonEncode(payload));
      await _widgetChannel.invokeMethod('updateTaskWidget');
    } catch (_) {
      // Ignore errors; widget update is best effort
    }
  }

  Future<void> _loadCategories() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('userTaskCategory')
              .where('userId', isEqualTo: user.uid)
              .get();

      setState(() {
        _categories =
            snapshot.docs
                .map(
                  (doc) => {'id': doc.id, 'name': doc['name'], ...doc.data()},
                )
                .toList();
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> _addCategory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final TextEditingController controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.addCategory),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.categoryName,
                border: OutlineInputBorder(),
              ),
              maxLength: 50,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(context)!.namecategoryRequired;
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context, controller.text.trim());
                }
              },
              child: Text(AppLocalizations.of(context)!.add),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('userTaskCategory')
            .add({
              'name': result,
              'userId': user.uid,
              'createdAt': FieldValue.serverTimestamp(),
            });
        await _loadCategories();
        setState(() {
          _selectedCategoryId = doc.id;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.erroraddingcategory + e.toString(),
            ),
          ),
        );
      }
    }
  }

  void _loadTasks() async {
    // Reload tasks data here
    setState(() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TasksPage()),
      );
    });
  }

  Future<void> _manageCategories() async {
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLocalizations.of(context)!.manageCategories2,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  physics: AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  shrinkWrap: true,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final String name = category['name']?.toString() ?? '';
                    return ListTile(
                      title: Text(name),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                        onPressed: () async {
                          final lower = name.toLowerCase();
                          if (lower == 'default') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.defaultcategorycannotberemoved,
                                ),
                              ),
                            );
                            return;
                          }
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:
                                (_) => AlertDialog(
                                  title: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.removeCategory,
                                  ),
                                  content: Text(
                                    AppLocalizations.of(context)!.removing +
                                        name +
                                        AppLocalizations.of(
                                          context,
                                        )!.removingcatmessage,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, false),
                                      child: const Text('No'),
                                    ),
                                    ElevatedButton(
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                      child: const Text('Yes'),
                                    ),
                                  ],
                                ),
                          );
                          if (confirm != true) return;
                          try {
                            // Delete all tasks under this category in batches
                            final String categoryId = category['id'] as String;
                            final user = FirebaseAuth.instance.currentUser;
                            if (user == null) return;
                            const int batchLimit = 450;
                            while (true) {
                              final qs =
                                  await FirebaseFirestore.instance
                                      .collection('tasks')
                                      .where('userId', isEqualTo: user.uid)
                                      .where(
                                        'categoryId',
                                        isEqualTo: categoryId,
                                      )
                                      .limit(batchLimit)
                                      .get();
                              if (qs.docs.isEmpty) break;
                              final batch = FirebaseFirestore.instance.batch();
                              for (final d in qs.docs) {
                                batch.delete(d.reference);
                              }
                              await batch.commit();
                              if (qs.docs.length < batchLimit) break;
                            }
                            // Delete the category
                            await FirebaseFirestore.instance
                                .collection('userTaskCategory')
                                .doc(categoryId)
                                .delete();
                            await _loadCategories();
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.categoryanditstasksremoved,
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(
                                        context,
                                      )!.errorremovingcategory +
                                      e.toString(),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Stream<QuerySnapshot> getTasksStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    Query query = FirebaseFirestore.instance
        .collection('tasks')
        .where('userId', isEqualTo: user.uid);

    // Apply category filter
    if (_selectedCategoryId != null) {
      query = query.where('categoryId', isEqualTo: _selectedCategoryId);
    }

    // Apply status filter
    if (_selectedStatus != 'all') {
      query = query.where('status', isEqualTo: _selectedStatus);
    }

    return query.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> _toggleTaskStatus(String taskId, bool isDone) async {
    try {
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
        'status': isDone ? 'done' : 'open',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating task status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.errorupdatingtask + e.toString(),
          ),
        ),
      );
    }
  }

  String _getCategoryName(String categoryId) {
    final category = _categories.firstWhere(
      (cat) => cat['id'] == categoryId,
      orElse: () => {'name': 'Unknown'},
    );
    return category['name'] ?? 'Unknown';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'done':
        return Colors.green;
      case 'open':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Directionality(
      textDirection:
          Localizations.localeOf(context).languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(
              context,
            )!.tasks, // You can add this to localization files later
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
                setState(() {
                  _loadTasks(); // Call the function to reload tasks
                });
              },
            ),
          ],
          backgroundColor: const Color.fromARGB(255, 182, 142, 190),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            // Filters Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Category Filter
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          isDense: true,
                          isExpanded: true,
                          value: _selectedCategoryId,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.category,
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: <DropdownMenuItem<String?>>[
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text(
                                AppLocalizations.of(context)!.allCategories,
                              ),
                            ),
                            ..._categories.map(
                              (category) => DropdownMenuItem<String?>(
                                value: category['id'] as String,
                                child: Text(category['name']?.toString() ?? ''),
                              ),
                            ),
                            DropdownMenuItem<String?>(
                              value: '__add__',
                              child: Text(
                                AppLocalizations.of(context)!.addNewCategory,
                              ),
                            ),
                            DropdownMenuItem<String?>(
                              value: '__manage__',
                              child: Text(
                                AppLocalizations.of(context)!.manageCategories,
                              ),
                            ),
                          ],
                          onChanged: (value) async {
                            if (value == '__add__') {
                              await _addCategory();
                              return;
                            }
                            if (value == '__manage__') {
                              await _manageCategories();
                              return;
                            }
                            setState(() {
                              _selectedCategoryId = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Status Filter
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.status,
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: [
                            DropdownMenuItem<String>(
                              value: 'all',
                              child: Text(
                                AppLocalizations.of(context)!.allTasks,
                              ),
                            ),
                            DropdownMenuItem<String>(
                              value: 'open',
                              child: Text(AppLocalizations.of(context)!.open),
                            ),
                            DropdownMenuItem<String>(
                              value: 'done',
                              child: Text(AppLocalizations.of(context)!.done),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedStatus = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Tasks List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getTasksStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  _writeTasksWidgetSummary();
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.task_alt,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)!.noTasksFound,
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
                            )!.addYourFirstTaskToGetStarted,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      final taskName = doc['taskname'] ?? '';
                      final dueDate = doc['duedate'] as Timestamp?;
                      final categoryId = doc['categoryId'] ?? '';
                      final status = doc['status'] ?? 'open';
                      final isDone = status == 'done';
                      String statusView = AppLocalizations.of(context)!.open;
                      if (status == 'done') {
                        statusView = AppLocalizations.of(context)!.done;
                      }

                      // Check if task is outdated (due date < current date and not done)
                      final isOutdated =
                          dueDate != null &&
                          !isDone &&
                          dueDate.toDate().isBefore(
                            DateTime.now().subtract(const Duration(days: 1)),
                          );

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: isOutdated ? 4 : 2,
                        color: isOutdated ? Colors.red[50] : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side:
                              isOutdated
                                  ? BorderSide(
                                    color: Colors.red[300]!,
                                    width: 2,
                                  )
                                  : BorderSide.none,
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UpdateTaskPage(taskId: doc.id),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Checkbox
                                Checkbox(
                                  value: isDone,
                                  onChanged: (value) {
                                    _toggleTaskStatus(doc.id, value ?? false);
                                  },
                                  activeColor: Colors.green,
                                ),
                                const SizedBox(width: 12),
                                // Task Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Task Name
                                      Text(
                                        taskName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          decoration:
                                              isDone
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                          color:
                                              isDone
                                                  ? Colors.grey[600]
                                                  : (isOutdated
                                                      ? Colors.red[700]
                                                      : Colors.black87),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Category
                                      if (categoryId.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: primaryColor.withOpacity(
                                              0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            _getCategoryName(categoryId),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: primaryColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 4),
                                      // Due Date
                                      if (dueDate != null)
                                        Row(
                                          children: [
                                            Icon(
                                              isOutdated
                                                  ? Icons.warning
                                                  : Icons.calendar_today,
                                              size: 14,
                                              color:
                                                  isOutdated
                                                      ? Colors.red[600]
                                                      : Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              isOutdated
                                                  ? '${AppLocalizations.of(context)!.overdue} ${_formatDate(dueDate.toDate()).toString().trim()}'
                                                  : AppLocalizations.of(
                                                    context,
                                                  )!.due(
                                                    _formatDate(
                                                      dueDate.toDate(),
                                                    ).toString().trim(),
                                                  ),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    isOutdated
                                                        ? Colors.red[600]
                                                        : Colors.grey[600],
                                                fontWeight:
                                                    isOutdated
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                                // Status Indicator
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isOutdated
                                            ? Colors.red.withOpacity(0.1)
                                            : _getStatusColor(
                                              status,
                                            ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          isOutdated
                                              ? Colors.red.withOpacity(0.3)
                                              : _getStatusColor(
                                                status,
                                              ).withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    isOutdated
                                        ? 'OVERDUE'
                                        : statusView.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color:
                                          isOutdated
                                              ? Colors.red
                                              : _getStatusColor(status),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddTaskPage()),
            ).then((_) {
              // Refresh categories when returning from add task page
              _loadCategories();
            });
          },
          backgroundColor: primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
