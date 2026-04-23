import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/health/health_info_model.dart';
import 'package:myapp/health/health_info_service.dart';
import 'package:myapp/widgets/app_banner_ad.dart';

class ChronicDiseasesPage extends StatefulWidget {
  final String userId;

  const ChronicDiseasesPage({super.key, required this.userId});

  @override
  State<ChronicDiseasesPage> createState() => _ChronicDiseasesPageState();
}

class _ChronicDiseasesPageState extends State<ChronicDiseasesPage> {
  final HealthInfoService _service = HealthInfoService();
  List<ChronicDisease> _diseases = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDiseases();
  }

  Future<void> _loadDiseases() async {
    try {
      final diseases = await _service.getChronicDiseases(widget.userId);
      if (!mounted) return;
      setState(() {
        _diseases = diseases;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteDisease(ChronicDisease disease) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.confirmDelete),
            content: Text(AppLocalizations.of(context)!.deleteDiseaseConfirm),
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

    if (confirmed == true && disease.id != null) {
      await _service.deleteChronicDisease(disease.id!);
      _loadDiseases();
    }
  }

  void _showAddDiseaseDialog() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
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
                          l10n.addChronicDisease,
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
                                  hintText: l10n.enterCustomDisease,
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
                                  final disease = ChronicDisease(
                                    userId: widget.userId,
                                    name: customController.text.trim(),
                                    isCustom: true,
                                    createdAt: DateTime.now(),
                                  );
                                  await _service.addChronicDisease(disease);
                                  customController.clear();
                                  Navigator.pop(context);
                                  _loadDiseases();
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
                                PredefinedData.getChronicDiseases(
                                  isArabic ? 'ar' : 'en',
                                ).map((item) {
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
                                        final disease = ChronicDisease(
                                          userId: widget.userId,
                                          name: item,
                                          isCustom: false,
                                          createdAt: DateTime.now(),
                                        );
                                        await _service.addChronicDisease(
                                          disease,
                                        );
                                      }
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        _loadDiseases();
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
        title: Text(l10n.chronicDiseases),
        backgroundColor: const Color(0xFF673AB7),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _diseases.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.medical_information,
                      size: 64,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noChronicDiseases,
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.addDiseaseHint,
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _diseases.length,
                itemBuilder: (context, index) {
                  final disease = _diseases[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.medical_information,
                          color: Colors.red,
                        ),
                      ),
                      title: Text(disease.name),
                      subtitle:
                          disease.isCustom
                              ? Text(
                                l10n.custom,
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              )
                              : null,
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => _deleteDisease(disease),
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDiseaseDialog,
        backgroundColor: const Color(0xFF673AB7),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const AppBannerAd(),
    );
  }
}
