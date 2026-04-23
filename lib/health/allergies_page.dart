import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/health/health_info_model.dart';
import 'package:myapp/health/health_info_service.dart';
import 'package:myapp/widgets/app_banner_ad.dart';
class AllergiesPage extends StatefulWidget {
  final String userId;

  const AllergiesPage({super.key, required this.userId});

  @override
  State<AllergiesPage> createState() => _AllergiesPageState();
}

class _AllergiesPageState extends State<AllergiesPage>
    with SingleTickerProviderStateMixin {
  final HealthInfoService _service = HealthInfoService();
  late TabController _tabController;

  List<Allergy> _medicationAllergies = [];
  List<Allergy> _foodAllergies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAllergies();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllergies() async {
    try {
      final allergies = await _service.getAllergies(widget.userId);
      if (!mounted) return;
      setState(() {
        _medicationAllergies =
            allergies.where((a) => a.type == 'medication').toList();
        _foodAllergies = allergies.where((a) => a.type == 'food').toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAllergy(Allergy allergy) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.confirmDelete),
            content: Text(AppLocalizations.of(context)!.deleteAllergyConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(AppLocalizations.of(context)!.delete),
              ),
            ],
          ),
    );

    if (confirmed == true && allergy.id != null) {
      await _service.deleteAllergy(allergy.id!);
      _loadAllergies();
    }
  }

  void _showAddAllergyDialog(String type) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final predefinedList =
        type == 'medication'
            ? PredefinedData.getMedications(isArabic ? 'ar' : 'en')
            : PredefinedData.getFoods(isArabic ? 'ar' : 'en');

    final customController = TextEditingController();
    final selectedItems = <String>{}.toSet();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder: (context, setModalState) {
              final l10n = AppLocalizations.of(context)!;
              return DraggableScrollableSheet(
                initialChildSize: 0.7,
                maxChildSize: 0.9,
                minChildSize: 0.5,
                expand: false,
                builder: (context, scrollController) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          type == 'medication'
                              ? l10n.addMedicationAllergy
                              : l10n.addFoodAllergy,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Custom entry
                        Text(
                          l10n.addCustom,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: customController,
                                decoration: InputDecoration(
                                  hintText: l10n.enterCustomAllergy,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () async {
                                if (customController.text.trim().isNotEmpty) {
                                  final allergy = Allergy(
                                    userId: widget.userId,
                                    type: type,
                                    name: customController.text.trim(),
                                    isCustom: true,
                                    createdAt: DateTime.now(),
                                  );
                                  await _service.addAllergy(allergy);
                                  customController.clear();
                                  Navigator.pop(context);
                                  _loadAllergies();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF673AB7),
                                foregroundColor: Colors.white,
                              ),
                              child: Text(l10n.add),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n.selectFromList,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView(
                            controller: scrollController,
                            children:
                                predefinedList.map((item) {
                                  final isSelected = selectedItems.contains(
                                    item,
                                  );
                                  return CheckboxListTile(
                                    title: Text(item),
                                    value: isSelected,
                                    onChanged: (value) {
                                      setModalState(() {
                                        if (value == true) {
                                          selectedItems.add(item);
                                        } else {
                                          selectedItems.remove(item);
                                        }
                                      });
                                    },
                                    activeColor: const Color(0xFF673AB7),
                                  );
                                }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                selectedItems.isEmpty
                                    ? null
                                    : () async {
                                      for (final item in selectedItems) {
                                        final allergy = Allergy(
                                          userId: widget.userId,
                                          type: type,
                                          name: item,
                                          isCustom: false,
                                          createdAt: DateTime.now(),
                                        );
                                        await _service.addAllergy(allergy);
                                      }
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        _loadAllergies();
                                      }
                                    },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF673AB7),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(l10n.saveSelected),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.allergies),
        backgroundColor: const Color(0xFF673AB7),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.medication), text: l10n.medications),
            Tab(icon: const Icon(Icons.restaurant), text: l10n.food),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildAllergyList(_medicationAllergies, 'medication'),
                  _buildAllergyList(_foodAllergies, 'food'),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddAllergyDialog(
            _tabController.index == 0 ? 'medication' : 'food',
          );
        },
        backgroundColor: const Color(0xFF673AB7),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const AppBannerAd(),
    );
  }

  Widget _buildAllergyList(List<Allergy> allergies, String type) {
    final l10n = AppLocalizations.of(context)!;

    if (allergies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'medication' ? Icons.medication : Icons.restaurant,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noAllergies,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.addAllergyHint,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allergies.length,
      itemBuilder: (context, index) {
        final allergy = allergies[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.warning_amber, color: Colors.orange),
            ),
            title: Text(allergy.name),
            subtitle:
                allergy.isCustom
                    ? Text(
                      l10n.custom,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    )
                    : null,
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deleteAllergy(allergy),
            ),
          ),
        );
      },
    );
  }
}
