import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:psm/screens/NewRecord.dart';
import 'package:psm/screens/record_details.dart';
import 'package:psm/service/firestore.dart';
import 'package:psm/service/records.dart';

import '../profile/profilescreen.dart'; // For AppColors and theming

class MyRecordsScreen extends StatefulWidget {
  final List<Record>? initialSearchResults;

  const MyRecordsScreen({super.key, this.initialSearchResults});

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
          builder: (context) => RecordDetailScreen(record: record)),
    );
  }

  Future<void> _navigateToNewRecordScreen() async {
    if (_currentUser == null) {
      _showFeedbackSnackbar("Please log in to create a new record.",
          isError: true);
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewRecordScreen()),
    );
  }

  Future<void> _navigateToEditRecordScreen(Record record) async {
    if (_currentUser == null || record.userId != _currentUser!.uid) {
      _showFeedbackSnackbar("You can only edit your own records.",
          isError: true);
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

  Future<void> _confirmAndDeleteRecord(
      BuildContext dialogContext, Record record) async {
    Navigator.of(dialogContext).pop();
    if (_currentUser == null || record.userId != _currentUser!.uid) {
      _showFeedbackSnackbar("You can only delete your own records.",
          isError: true);
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
      _showFeedbackSnackbar('Failed to delete record: ${e.toString()}',
          isError: true);
    }
  }

  void _showDeleteConfirmationDialog(Record record) {
    if (record.id == null || record.id!.isEmpty) return;

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Confirm Deletion',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to delete this record? This action cannot be undone.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white70)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: AppColors.destructiveCategory,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold)),
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
        backgroundColor: isError
            ? AppColors.destructiveCategory
            : AppColors.practiceCategory,
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
        return _buildEmptyState(
            isLoggedIn: _currentUser != null, isSearch: true);
      }
      return ListView.builder(
        padding: const EdgeInsets.only(top: 10, bottom: 80),
        itemCount: _searchResultsList!.length,
        itemBuilder: (context, index) =>
            _buildRecordItem(_searchResultsList![index]),
      );
    } else {
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
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
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
    final appBarTitle =
        _isShowingSearchResults ? "Search Results" : "My Records";
    final showFab = _currentUser != null && !_isShowingSearchResults;

    return Scaffold(
      appBar: AppBar(
        leading: _isShowingSearchResults
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.of(context).pop(),
                color: AppColors.textPrimary,
              )
            : null,
        title: Text(
          appBarTitle,
          style: const TextStyle(
            fontFamily: 'Metamorphous',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            shadows: [Shadow(blurRadius: 3, color: Colors.black54)],
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        actions: <Widget>[
          if (_isShowingSearchResults)
            IconButton(
              icon: const Icon(Icons.clear_all_rounded, color: Colors.white70),
              tooltip: 'Clear Search & Go Back',
              onPressed: _clearSearch,
            ),
          const SizedBox(width: 8),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image:
                    AssetImage("assets/images/al-marhum/islamicbackground.png"),
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
            bottom: false,
            child: _buildContentArea(),
          ),
          if (showFab)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingActionButton.extended(
                  onPressed: _navigateToNewRecordScreen,
                  icon: const Icon(Icons.note_add_outlined),
                  label: const Text("Add New Record"),
                  backgroundColor: AppColors.practiceCategory,
                  foregroundColor: AppColors.textPrimary,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  extendedTextStyle: const TextStyle(
                    fontFamily: 'Metamorphous',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecordItem(Record record) {
    final bool isOwner = _currentUser?.uid == record.userId;
    String dateOfDeath = record.deceasedDod != null
        ? _dateFormat.format(record.deceasedDod!.toDate())
        : 'N/A';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: Colors.black.withOpacity(0.15),
      child: InkWell(
        onTap: () => _navigateToRecordDetails(record),
        splashColor: AppColors.practiceCategory.withOpacity(0.2),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.deceasedName,
                      style: const TextStyle(
                        fontFamily: 'Metamorphous',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black87,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
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
                    IconButton(
                      icon: Icon(Icons.edit_outlined,
                          color: Colors.blue.shade700),
                      tooltip: 'Edit Record',
                      onPressed: () => _navigateToEditRecordScreen(record),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline,
                          color: Colors.red.shade700),
                      tooltip: 'Delete Record',
                      onPressed: () => _showDeleteConfirmationDialog(record),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.grey.shade700,
              fontFamily: 'Metamorphous',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.3,
                fontFamily: 'Metamorphous',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({required bool isLoggedIn, bool isSearch = false}) {
    final String title = isLoggedIn
        ? (isSearch ? "No Matching Records" : "No Records Yet")
        : "Login Required";
    final String message = isLoggedIn
        ? (isSearch
            ? "Try searching with a different keyword."
            : "Tap the '+' button below to create your first record.")
        : "Please log in to view and manage your records.";
    final IconData iconData = isLoggedIn
        ? (isSearch ? Icons.search_off_rounded : Icons.note_add_outlined)
        : Icons.lock_person_outlined;
    final Color primaryColor =
        isLoggedIn ? AppColors.practiceCategory : Colors.orange.shade700;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData, size: 70, color: primaryColor.withOpacity(0.8)),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Metamorphous',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: primaryColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Metamorphous',
                fontSize: 16,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            if (isSearch) ...[
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text("Go Back to Search"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.practiceCategory,
                  foregroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  textStyle: const TextStyle(
                    fontFamily: 'Metamorphous',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 0.6,
                  ),
                ),
                onPressed: _clearSearch,
              )
            ],
          ],
        ),
      ),
    );
  }
}
