import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../localization/app_localizations.dart';
import '../service/records.dart';
import '../service/firestore.dart';

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

  Future<void> _manageReminders() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _showFeedback("Please log in to set reminders.");
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final records = await _recordService.getRecordsForUser(currentUser.uid).first;
      if (!mounted) return;

      if (records.isEmpty) {
        _showFeedback("You have no records. Please add a record first.");
        return; // The 'finally' block will handle setting isLoading to false.
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
          // TODO: Sync with your notification service.
          _showFeedback("${_selectedRecords.length} reminder(s) are now active.");
        });
      }

    } catch (e) {
      _showFeedback("Error fetching records: $e");
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  void _clearAllReminders() {
    setState(() {
      _selectedRecords.clear();
      // TODO: Cancel all scheduled notifications for this user.
      _showFeedback("All reminders have been turned off.");
    });
  }

  void _showFeedback(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Stack(
        children: [
          // --- 1. CORRECT BACKGROUND WITH OPACITY OVERLAY ---
          // Layer 1: The background image.
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/al-marhum/islamicbackground.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Layer 2: The semi-transparent color overlay. This sits ON TOP of the image.
          Container(
            color: Colors.white.withOpacity(0.6),
          ),

          // Layer 3: The main content.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 2. CLEANED UP HEADER ---
                  Text(
                    AppLocalizations.get(context, 'notifications', fallback: 'Notifications') ?? 'Notifications',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Metamorphous',
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.get(context, 'death_anniversary_reminder', fallback: 'Death Notifications Reminder') ?? 'Death Notifications Reminder',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      fontFamily: 'Metamorphous',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- 3. CLEANED UP MAIN TOGGLE TILE ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(12)
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.notifications_active, color: Colors.teal, size: 32),
                      title: Text(
                        AppLocalizations.get(context, 'enable_reminders', fallback: 'Enable Reminders') ?? 'Enable Reminders',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14.0),
                              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.teal)),
                            ),
                          Switch(
                            value: _areRemindersOn,
                            onChanged: _isLoading ? null : (value) {
                              if (value) {
                                _manageReminders();
                              } else {
                                _clearAllReminders();
                              }
                            },
                            activeColor: Colors.teal,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- 4. CLEANED UP SELECTION HEADER ---
                  if (_areRemindersOn)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_selectedRecords.length} ${AppLocalizations.get(context, 'active_reminders', fallback: 'Active Reminders') ?? 'Active Reminders'}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Metamorphous', fontSize: 16),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.edit, size: 16),
                            label: Text(AppLocalizations.get(context, 'edit', fallback: 'Edit') ?? 'Edit'),
                            onPressed: _manageReminders,
                            style: TextButton.styleFrom(foregroundColor: Colors.teal.shade700),
                          )
                        ],
                      ),
                    ),

                  // --- 5. LIST OF SELECTED RECORDS (Styled for consistency) ---
                  Expanded(
                    child: ListView.builder(
                      itemCount: _selectedRecords.length,
                      itemBuilder: (context, index) {
                        final record = _selectedRecords[index];
                        final dodFormatted = record.deceasedDod != null
                            ? DateFormat.yMMMd().format(record.deceasedDod!.toDate())
                            : 'No Date';
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          color: Colors.teal.withOpacity(0.08),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.teal.withOpacity(0.3)),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.check_circle_outline, color: Colors.teal.shade700),
                            title: Text(record.deceasedName, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('Notifications: $dodFormatted'),
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
}

// --- Multi-Select Dialog (Unchanged, but now fits the new theme) ---
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
      title: Text(AppLocalizations.get(context, 'select_reminders', fallback: 'Select Reminders') ?? 'Select Reminders'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.allRecords.length,
          itemBuilder: (context, index) {
            final record = widget.allRecords[index];
            final isSelected = _tempSelectedRecords.any((r) => r.id == record.id);
            return CheckboxListTile(
              activeColor: Colors.teal,
              title: Text(record.deceasedName),
              subtitle: Text(record.deceasedDod != null ? DateFormat.yMMMd().format(record.deceasedDod!.toDate()) : 'No Date'),
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
          child: Text(AppLocalizations.get(context, 'cancel', fallback: 'Cancel') ?? 'Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(_tempSelectedRecords);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
          child: Text(AppLocalizations.get(context, 'confirm', fallback: 'Confirm') ?? 'Confirm'),
        ),
      ],
    );
  }
}