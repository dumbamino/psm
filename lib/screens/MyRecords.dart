// lib/screens/MyRecords.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:psm/screens/record_details.dart';
import 'package:psm/service/firestore.dart';
import 'package:psm/service/records.dart';
import 'package:psm/screens/NewRecord.dart';

class MyRecordsScreen extends StatefulWidget {
  final List<Record>? initialSearchResults;

  const MyRecordsScreen({
    super.key,
    this.initialSearchResults,
  });

  @override
  State<MyRecordsScreen> createState() => _MyRecordsScreenState();
}

class _MyRecordsScreenState extends State<MyRecordsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RecordFirestoreService _recordService = RecordFirestoreService();

  User? _currentUser;
  bool _isLoadingUser = true;
  StreamSubscription<User?>? _authStateSubscription;

  List<Record>? _searchResultsList;
  bool _isShowingSearchResults = false;

  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  BoxDecoration get _screenBackgroundDecoration {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.green.shade100, Colors.white],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialSearchResults != null) {
      _searchResultsList = widget.initialSearchResults;
      _isShowingSearchResults = true;
    }

    _isLoadingUser = true;
    _authStateSubscription = _auth.authStateChanges().listen((User? user) {
      if (!mounted) return;
      setState(() {
        _currentUser = user;
        _isLoadingUser = false;
      });
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  void _clearSearch() {
    if (_isShowingSearchResults) {
      Navigator.of(context).pop();
    }
  }

  void _navigateToRecordDetails(Record record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecordDetailScreen(record: record),
      ),
    );
  }

  Future<void> _navigateToNewRecordScreen() async {
    if (_currentUser == null) {
      _showFeedbackSnackbar("Please log in to create a new record.", isError: true);
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewRecordScreen()),
    );
  }

  Future<void> _navigateToEditRecordScreen(Record record) async {
    if (_currentUser == null || record.userId != _currentUser!.uid) {
      _showFeedbackSnackbar("You can only edit your own records.", isError: true);
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewRecordScreen(
          recordId: record.id!,
          initialData: record.toJson(),
        ),
      ),
    );
  }

  Future<void> _confirmAndDeleteRecord(BuildContext dialogContext, Record record) async {
    Navigator.of(dialogContext).pop();
    if (_currentUser == null || record.userId != _currentUser!.uid) {
      _showFeedbackSnackbar("You can only delete your own records.", isError: true);
      return;
    }

    if (_isShowingSearchResults && _searchResultsList != null) {
      setState(() {
        _searchResultsList!.removeWhere((rec) => rec.id == record.id);
      });
    }

    try {
      await _recordService.deleteRecord(record.id!);
      _showFeedbackSnackbar('Record deleted successfully!');
      if (_isShowingSearchResults && (_searchResultsList?.isEmpty ?? true)) {
        _clearSearch();
      }
    } catch (e) {
      _showFeedbackSnackbar('Failed to delete record: ${e.toString()}', isError: true);
    }
  }

  void _showDeleteConfirmationDialog(Record record) {
    if (record.id == null || record.id!.isEmpty) return;

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this record? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
              child: const Text('Delete'),
              onPressed: () => _confirmAndDeleteRecord(dialogContext, record),
            ),
          ],
        );
      },
    );
  }

  void _showFeedbackSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildContentArea() {
    if (_isLoadingUser) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isShowingSearchResults) {
      if (_searchResultsList == null || _searchResultsList!.isEmpty) {
        return _buildEmptyState(isLoggedIn: _currentUser != null, isSearch: true);
      }
      return ListView.builder(
        padding: const EdgeInsets.only(top: 10, bottom: 80),
        itemCount: _searchResultsList!.length,
        itemBuilder: (context, index) => _buildRecordItem(_searchResultsList![index]),
      );
    }
    else {
      if (_currentUser == null) {
        return _buildEmptyState(isLoggedIn: false);
      }
      return StreamBuilder<List<Record>>(
        stream: _recordService.getRecordsForUser(_currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final records = snapshot.data ?? [];
          if (records.isEmpty) {
            return _buildEmptyState(isLoggedIn: true, isSearch: false);
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 10, bottom: 80),
            itemCount: records.length,
            itemBuilder: (context, index) => _buildRecordItem(records[index]),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBarTitle = _isShowingSearchResults ? "Search Results" : "My Records";
    final showFab = _currentUser != null && !_isShowingSearchResults;

    return Scaffold(
      appBar: AppBar(
        leading: _isShowingSearchResults ? IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.of(context).pop()) : null,
        title: Text(appBarTitle),
        backgroundColor: Colors.transparent, elevation: 0, foregroundColor: Colors.black87, centerTitle: true,
        titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        actions: <Widget>[
          if (_isShowingSearchResults)
            IconButton(
              icon: const Icon(Icons.clear_all_rounded),
              tooltip: 'Clear Search & Go Back',
              onPressed: _clearSearch,
            ),
          const SizedBox(width: 8),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity, height: double.infinity, decoration: _screenBackgroundDecoration,
        child: SafeArea(
          bottom: false,
          child: _buildContentArea(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: showFab
          ? FloatingActionButton.extended(
        onPressed: _navigateToNewRecordScreen,
        icon: const Icon(Icons.note_add_outlined), label: const Text("Add New Record"),
        backgroundColor: Colors.green.shade700, foregroundColor: Colors.white,
      )
          : null,
    );
  }

  Widget _buildRecordItem(Record record) {
    final bool isOwner = _currentUser?.uid == record.userId;
    String dateOfDeath = record.deceasedDod != null ? _dateFormat.format(record.deceasedDod!.toDate()) : 'N/A';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToRecordDetails(record),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(record.deceasedName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
                    const SizedBox(height: 8),
                    _buildInfoRow('Date of Death:', dateOfDeath),
                    _buildInfoRow('Area:', record.area),
                    _buildInfoRow('Lot:', record.graveLot ?? 'N/A'),
                  ],
                ),
              ),
              if (isOwner)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: Icon(Icons.edit_outlined, color: Colors.blue.shade700), onPressed: () => _navigateToEditRecordScreen(record), tooltip: 'Edit Record'),
                    IconButton(icon: Icon(Icons.delete_outline, color: Colors.red.shade700), onPressed: () => _showDeleteConfirmationDialog(record), tooltip: 'Delete Record'),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) { return Padding( padding: const EdgeInsets.symmetric(vertical: 2.0), child: Row( crossAxisAlignment: CrossAxisAlignment.start, children: [ Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w500)), const SizedBox(width: 5), Expanded(child: Text(value, style: const TextStyle(fontSize: 14, color: Colors.black87))), ], ), ); }

  Widget _buildEmptyState({required bool isLoggedIn, bool isSearch = false}) { final String title = isLoggedIn ? (isSearch ? "No Matching Records" : "No Records Yet") : "Login Required"; final String message = isLoggedIn ? (isSearch ? "Try searching with a different keyword." : "Tap the '+' button below to create your first record.") : "Please log in to view and manage your records."; final IconData iconData = isLoggedIn ? (isSearch ? Icons.search_off_rounded : Icons.note_add_outlined) : Icons.lock_person_outlined; final Color primaryColor = isLoggedIn ? Colors.green.shade700 : Colors.orange.shade700; return Center( child: Padding( padding: const EdgeInsets.all(24.0), child: Column( mainAxisAlignment: MainAxisAlignment.center, children: [ Icon(iconData, size: 60, color: primaryColor.withOpacity(0.8)), const SizedBox(height: 20), Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: primaryColor, fontWeight: FontWeight.w600)), const SizedBox(height: 12), Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black54, height: 1.4)), if (isSearch) ...[ const SizedBox(height: 20), ElevatedButton.icon( icon: const Icon(Icons.arrow_back_rounded), label: const Text("Go Back to Search"), onPressed: _clearSearch, ) ] ], ), ), ); }
}