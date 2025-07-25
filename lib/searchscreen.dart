import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:psm/screens/MyRecords.dart';
import 'package:psm/service/firestore.dart';
import 'package:psm/service/records.dart';

import '../profile/profilescreen.dart'; // Reuse colors and styles
import 'localization/app_localizations.dart';

class SearchScreen extends StatefulWidget {
  final Locale locale;

  const SearchScreen({
    super.key,
    required this.locale,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _deceasedDodController = TextEditingController();

  final RecordFirestoreService _recordService = RecordFirestoreService();

  Record? _selectedRecord;
  bool _isSearching = false;
  final DateFormat _inputOutputDateFormat = DateFormat('dd/MM/yyyy');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _deceasedDodController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    FocusScope.of(context).unfocus();
    DateTime initialDate = DateTime.now();
    if (_deceasedDodController.text.isNotEmpty) {
      try {
        initialDate = _inputOutputDateFormat.parse(_deceasedDodController.text);
      } catch (_) {}
    }
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.practiceCategory,
            onPrimary: Colors.white,
            onSurface: Colors.black87,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.practiceCategory,
            ),
          ),
        ),
        child: child!,
      ),
    );
    if (pickedDate != null && mounted) {
      setState(() {
        _deceasedDodController.text = _inputOutputDateFormat.format(pickedDate);
      });
    }
  }

  Stream<QuerySnapshot> _getRecordsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection(kCollectionRecords)
        .where(kUserIdField, isEqualTo: user.uid)
        .orderBy(kDeceasedNameField)
        .snapshots();
  }

  Future<void> _performDateSearch() async {
    FocusScope.of(context).unfocus();

    final String deceasedDodString = _deceasedDodController.text;

    if (deceasedDodString.isEmpty) {
      _showErrorSnackBar(
        AppLocalizations.getSync(context, 'errorSelectDate') ??
            'Please select a date to filter by.',
      );
      return;
    }

    setState(() => _isSearching = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorSnackBar(
          AppLocalizations.getSync(context, 'noResults') ??
              'No matching records found.',
        );
        setState(() => _isSearching = false);
        return;
      }

      DateTime searchDate;
      try {
        searchDate = _inputOutputDateFormat.parseStrict(deceasedDodString);
      } catch (e) {
        _showErrorSnackBar(
          AppLocalizations.getSync(context, 'errorInvalidDateFormat') ??
              'Invalid Date of Death format. Please use DD/MM/YYYY.',
        );
        setState(() => _isSearching = false);
        return;
      }

      final List<Record> foundRecords =
          await _recordService.searchRecordsByDateForUser(user.uid, searchDate);

      if (mounted) {
        if (foundRecords.isEmpty) {
          _showErrorSnackBar(
            AppLocalizations.getSync(context, 'noResults') ??
                'No matching records found.',
          );
        } else {
          _navigateToResults(foundRecords);
        }
      }
    } catch (e) {
      print("Error during date search: $e");
      _showErrorSnackBar(
        '${AppLocalizations.getSync(context, 'errorDuringSearch') ?? 'Error during search'}: ${e.toString()}',
      );
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _navigateToResults(List<Record> records) {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyRecordsScreen(initialSearchResults: records),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.destructiveCategory,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appBarTitle =
        AppLocalizations.getSync(context, 'title') ?? 'Search Grave Records';
    final selectRecordHint =
        AppLocalizations.getSync(context, 'selectRecordHint') ??
            'Browse and select a record...';
    final deceasedDodHint =
        AppLocalizations.getSync(context, 'deceasedDodHint') ??
            'Deceased Date of Death (DD/MM/YYYY)';
    final searchBtnText =
        AppLocalizations.getSync(context, 'searchBtn') ?? 'Search Records';

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/al-marhum/islamicbackground.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
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
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.white.withOpacity(0.95),
            elevation: 1,
            centerTitle: true,
            title: Text(
              appBarTitle,
              style: const TextStyle(
                fontFamily: 'Metamorphous',
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.black87,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.black87),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    _buildRecordsDropdownStream(selectRecordHint),
                    const SizedBox(height: 16),
                    _buildTextField(
                      hintText: deceasedDodHint,
                      controller: _deceasedDodController,
                      prefixIcon: Icons.calendar_today,
                      readOnly: true,
                      onTap: _selectDate,
                    ),
                    const SizedBox(height: 32),
                    _buildSearchButton(
                      isSearching: _isSearching,
                      searchText: searchBtnText,
                      onPressed: _performDateSearch,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordsDropdownStream(String hintText) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getRecordsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print("!!! STREAM ERROR: ${snapshot.error}");
          return const Text('Error loading records. Check Debug Console.');
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('No records found in the database.');
        }

        final List<Record> records = snapshot.data!.docs
            .map<Record?>((doc) {
              try {
                return Record.fromSnapshot(doc);
              } catch (e) {
                print("!!! FAILED to parse document ${doc.id}. Error: $e");
                return null;
              }
            })
            .whereType<Record>()
            .toList();

        return DropdownButtonFormField<Record>(
          value: _selectedRecord,
          isExpanded: true,
          hint: Text(
            hintText,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Metamorphous',
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.95),
            prefixIcon:
                Icon(Icons.person_search, color: AppColors.practiceCategory),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide:
                  BorderSide(color: AppColors.practiceCategory, width: 2.0),
            ),
          ),
          items: records.map((Record record) {
            return DropdownMenuItem<Record>(
              value: record,
              child: Text(
                '${record.deceasedName} (Lot: ${record.lotNumber ?? 'N/A'})',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Metamorphous',
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            );
          }).toList(),
          onChanged: snapshot.data!.docs.isEmpty
              ? null
              : (Record? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedRecord = newValue;
                    });
                    _navigateToResults([newValue]);
                  }
                },
          validator: (value) => null,
        );
      },
    );
  }

  Widget _buildTextField({
    required String hintText,
    required TextEditingController controller,
    IconData? prefixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(
        fontFamily: 'Metamorphous',
        fontSize: 16,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey.shade600,
          fontFamily: 'Metamorphous',
          fontSize: 16,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.95),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.practiceCategory)
            : null,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: AppColors.practiceCategory, width: 2.0),
        ),
      ),
    );
  }

  Widget _buildSearchButton({
    required bool isSearching,
    required String searchText,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        icon: isSearching
            ? Container()
            : const Icon(Icons.filter_alt, color: Colors.white),
        label: isSearching
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              )
            : Text(
                searchText,
                style: const TextStyle(
                  fontFamily: 'Metamorphous',
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.practiceCategory,
          disabledBackgroundColor: Colors.grey.shade500,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 5,
        ),
        onPressed: isSearching ? null : onPressed,
      ),
    );
  }
}
