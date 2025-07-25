import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../localization/app_localizations.dart';
import '../service/firestore.dart';
import '../service/records.dart';

// --- NEW: Cohesive Color Palette ---
class AppColors {
  static const Color primary = Color(0xFF004D40); // Deep Teal
  static const Color accent = Color(0xFFD4AF37); // Gold
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final RecordFirestoreService _recordService = RecordFirestoreService();

  List<Record> _selectedRecords = [];
  bool _isLoading = false;

  bool get _areRemindersOn => _selectedRecords.isNotEmpty;

  // TODO: Persist _selectedRecords to SharedPreferences or Firestore to survive app restarts.

  Future<void> _manageReminders() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _showFeedback("Please log in to set reminders.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final records =
          await _recordService.getRecordsForUser(currentUser.uid).first;
      if (!mounted) return;

      if (records.isEmpty) {
        _showFeedback("You have no records. Please add a record first.");
        return;
      }

      final List<Record>? newSelections = await showDialog<List<Record>>(
        context: context,
        builder: (context) => _MultiSelectDialog(
          allRecords: records,
          initiallySelectedRecords: _selectedRecords,
        ),
      );

      if (newSelections != null) {
        setState(() {
          _selectedRecords = newSelections;
        });
        _showFeedback("${_selectedRecords.length} reminder(s) are now active.");

        // TODO: Save _selectedRecords persistently here
      }
    } catch (e) {
      _showFeedback("Error fetching records: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearAllReminders() {
    setState(() {
      _selectedRecords.clear();
    });
    _showFeedback("All reminders have been turned off.");
    // TODO: Clear saved reminders persistently here
  }

  void _showFeedback(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
          Text(message, style: const TextStyle(fontFamily: 'Metamorphous')),
      backgroundColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image:
                    AssetImage('assets/images/al-marhum/islamicbackground.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.5),
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.get(context, 'notifications',
                            fallback: 'Notifications') ??
                        'Notifications',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Metamorphous',
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.get(context, 'death_anniversary_reminder',
                            fallback: 'Death Notifications Reminder') ??
                        'Death Notifications Reminder',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      fontFamily: 'Metamorphous',
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildGlassmorphicContainer(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      leading: const Icon(Icons.notifications_active,
                          color: AppColors.accent, size: 32),
                      title: Text(
                        AppLocalizations.get(context, 'enable_reminders',
                                fallback: 'Enable Reminders') ??
                            'Enable Reminders',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5, color: AppColors.accent),
                              ),
                            ),
                          Switch(
                            value: _areRemindersOn,
                            onChanged: _isLoading
                                ? null
                                : (value) {
                                    if (value) {
                                      _manageReminders();
                                    } else {
                                      _clearAllReminders();
                                    }
                                  },
                            activeColor: AppColors.accent,
                            activeTrackColor: AppColors.accent.withOpacity(0.5),
                            inactiveThumbColor: Colors.grey.shade400,
                            inactiveTrackColor: Colors.white.withOpacity(0.2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_areRemindersOn)
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 8, right: 8, bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_selectedRecords.length} ${AppLocalizations.get(context, 'active_reminders', fallback: 'Active Reminders') ?? 'Active Reminders'}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Metamorphous',
                                fontSize: 16,
                                color: AppColors.textPrimary),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.edit, size: 16),
                            label: Text(AppLocalizations.get(context, 'edit',
                                    fallback: 'Edit') ??
                                'Edit'),
                            onPressed: _manageReminders,
                            style: TextButton.styleFrom(
                                foregroundColor: AppColors.accent),
                          )
                        ],
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _selectedRecords.length,
                      itemBuilder: (context, index) {
                        final record = _selectedRecords[index];
                        final dodFormatted = record.deceasedDod != null
                            ? DateFormat.yMMMd()
                                .format(record.deceasedDod!.toDate())
                            : 'No Date';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildGlassmorphicContainer(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: AppColors.accent,
                                child: Icon(Icons.calendar_month,
                                    size: 20, color: AppColors.primary),
                              ),
                              title: Text(record.deceasedName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary)),
                              subtitle: Text('Reminder on: $dodFormatted',
                                  style: const TextStyle(
                                      color: AppColors.textSecondary)),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassmorphicContainer(
      {required Widget child, EdgeInsets? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _MultiSelectDialog extends StatefulWidget {
  final List<Record> allRecords;
  final List<Record> initiallySelectedRecords;

  const _MultiSelectDialog({
    required this.allRecords,
    required this.initiallySelectedRecords,
  });

  @override
  State<_MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<_MultiSelectDialog> {
  late final List<Record> _tempSelectedRecords;

  @override
  void initState() {
    super.initState();
    _tempSelectedRecords = List.from(widget.initiallySelectedRecords);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        AppLocalizations.get(context, 'select_reminders',
                fallback: 'Select Reminders') ??
            'Select Reminders',
        style: const TextStyle(color: AppColors.textPrimary),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.allRecords.length,
          itemBuilder: (context, index) {
            final record = widget.allRecords[index];
            final isSelected =
                _tempSelectedRecords.any((r) => r.id == record.id);
            return CheckboxListTile(
              activeColor: AppColors.accent,
              checkColor: AppColors.primary,
              title: Text(record.deceasedName,
                  style: const TextStyle(color: AppColors.textPrimary)),
              subtitle: Text(
                record.deceasedDod != null
                    ? DateFormat.yMMMd().format(record.deceasedDod!.toDate())
                    : 'No Date',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              value: isSelected,
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _tempSelectedRecords.add(record);
                  } else {
                    _tempSelectedRecords.removeWhere((r) => r.id == record.id);
                  }
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
              AppLocalizations.get(context, 'cancel', fallback: 'Cancel') ??
                  'Cancel',
              style: const TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(_tempSelectedRecords);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.primary,
          ),
          child: Text(
              AppLocalizations.get(context, 'confirm', fallback: 'Confirm') ??
                  'Confirm'),
        ),
      ],
    );
  }
}
