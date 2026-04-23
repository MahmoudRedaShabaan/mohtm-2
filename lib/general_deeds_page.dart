import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'general_deeds_model.dart';
import 'add_general_deed_page.dart';
import 'daily_deed/hijri_date_util.dart';
import 'daily_deed/components/date_header.dart';
import 'package:myapp/widgets/app_banner_ad.dart';


class GeneralDeedsPage extends StatefulWidget {
  final String userId;

  const GeneralDeedsPage({super.key, required this.userId});

  @override
  State<GeneralDeedsPage> createState() => _GeneralDeedsPageState();
}

class _GeneralDeedsPageState extends State<GeneralDeedsPage> {
  DateTime _currentDate = DateTime.now();
  List<GeneralDeed> _deeds = [];
  Map<String, GeneralDeedEntry> _todayStatus = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeeds();
  }

  Future<void> _loadDeeds() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final deeds = await GeneralDeedService.getUserGeneralDeeds(widget.userId);
      final statuses = await GeneralDeedService.getGeneralDeedStatusesForDate(
        userId: widget.userId,
        date: _currentDate,
      );
      if (!mounted) return;
      setState(() {
        _deeds = deeds;
        _todayStatus = statuses;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToDate(DateTime newDate) async {
    if (!HijriDateUtil.isDateValid(newDate)) {
      _showDateErrorDialog(context);
      return;
    }

    if (!mounted) return;
    setState(() {
      _currentDate = newDate;
      _isLoading = true;
    });

    final statuses = await GeneralDeedService.getGeneralDeedStatusesForDate(
      userId: widget.userId,
      date: _currentDate,
    );

    if (!mounted) return;
    setState(() {
      _todayStatus = statuses;
      _isLoading = false;
    });
  }

  void _showDateErrorDialog(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(localization.error),
            content: Text(localization.selectfuturedatetime),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(localization.confirm),
              ),
            ],
          ),
    );
  }

  Future<void> _updateStatus(String deedId, String status) async {
    try {
      await GeneralDeedService.updateGeneralDeedStatus(
        userId: widget.userId,
        date: _currentDate,
        deedId: deedId,
        status: status,
      );
      _loadDeeds();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  void _showStatusPopup(GeneralDeed deed) {
    final localization = AppLocalizations.of(context)!;
    final currentStatus = _todayStatus[deed.id]?.status;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(deed.name, textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildOption(
                  localization.missed,
                  Colors.red,
                  Icons.cancel,
                  'missed',
                  context,
                  deed.id!,
                  currentStatus,
                ),
                _buildOption(
                  localization.completed,
                  Colors.green,
                  Icons.check_circle,
                  'completed',
                  context,
                  deed.id!,
                  currentStatus,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(localization.cancel),
              ),
            ],
          ),
    );
  }

  Widget _buildOption(
    String label,
    Color color,
    IconData icon,
    String status,
    BuildContext context,
    String deedId,
    String? currentStatus,
  ) {
    final isSelected = currentStatus == status;

    return GestureDetector(
      onTap: () {
        _updateStatus(deedId, status);
        Navigator.of(context).pop();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected ? color.withValues(alpha: 0.2) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddDeed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddGeneralDeedPage()),
    ).then((_) => _loadDeeds());
  }

  void _navigateToEditDeed(GeneralDeed deed) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddGeneralDeedPage(deed: deed)),
    ).then((_) => _loadDeeds());
  }

  Future<void> _deleteDeed(GeneralDeed deed) async {
    final localization = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(localization.deleteDeed),
            content: Text(localization.deleteDeedConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(localization.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(localization.delete),
              ),
            ],
          ),
    );

    if (confirmed == true && deed.id != null) {
      await GeneralDeedService.deleteGeneralDeed(deed.id!);
      _loadDeeds();
    }
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey.shade300;
    switch (status) {
      case 'missed':
        return Colors.red;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey.shade300;
    }
  }

  Widget _getStatusIcon(String? status) {
    if (status == null) {
      return Icon(Icons.remove, color: Colors.grey.shade400, size: 20);
    }
    switch (status) {
      case 'missed':
        return Icon(Icons.cancel, color: Colors.red, size: 20);
      case 'completed':
        return Icon(Icons.check_circle, color: Colors.green, size: 20);
      default:
        return Icon(Icons.remove, color: Colors.grey.shade400, size: 20);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isToday = HijriDateUtil.isToday(_currentDate);
    final canGoNext =
        !HijriDateUtil.isFuture(_currentDate) &&
        _currentDate.isBefore(HijriDateUtil.getMaxDate());

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.dailyDeed),
        centerTitle: true,
        backgroundColor: const Color(0xFF4DB6AC),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DateHeader(
                      currentDate: _currentDate,
                      onPreviousDay:
                          () => _navigateToDate(
                            HijriDateUtil.navigateDate(_currentDate, -1),
                          ),
                      onNextDay:
                          () => _navigateToDate(
                            HijriDateUtil.navigateDate(_currentDate, 1),
                          ),
                      canGoPrevious:
                          !_currentDate.isBefore(HijriDateUtil.getMinDate()),
                      canGoNext: canGoNext,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.edit_note,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              localization.dailyDeed,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle),
                          color: const Color(0xFF4DB6AC),
                          onPressed: _navigateToAddDeed,
                          tooltip: localization.addCustomDeed,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_deeds.isEmpty)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.edit_note,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              localization.noCustomDeeds,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              localization.tapToAddDeed,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...(_deeds
                          .where((deed) => deed.isActiveOnDate(_currentDate))
                          .map((deed) {
                            final status = _todayStatus[deed.id]?.status;
                            final color = _getStatusColor(status);
                            return GestureDetector(
                              onTap: () => _showStatusPopup(deed),
                              onLongPress: () => _showDeedOptions(deed),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: color.withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: _getStatusIcon(status),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            deed.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (!deed.isForever &&
                                              deed.startDate != null &&
                                              deed.endDate != null)
                                            Text(
                                              '${deed.startDate!.day}/${deed.startDate!.month}/${deed.startDate!.year} - ${deed.endDate!.day}/${deed.endDate!.month}/${deed.endDate!.year}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                            size: 20,
                                          ),
                                          onPressed:
                                              () => _navigateToEditDeed(deed),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          onPressed: () => _deleteDeed(deed),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          })),
                  ],
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddDeed,
        backgroundColor: const Color(0xFF4DB6AC),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const AppBannerAd(),
    );
  }

  void _showDeedOptions(GeneralDeed deed) {
    final localization = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: Text(localization.edit),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToEditDeed(deed);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(localization.delete),
                onTap: () {
                  Navigator.pop(context);
                  _deleteDeed(deed);
                },
              ),
            ],
          ),
    );
  }
}
