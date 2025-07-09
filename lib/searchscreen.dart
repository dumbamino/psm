// lib/screens/search_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:psm/screens/MyRecords.dart';
import 'package:psm/service/records.dart';
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
    );
    if (pickedDate != null && mounted) {
      setState(() {
        _deceasedDodController.text = _inputOutputDateFormat.format(pickedDate);
      });
    }
  }

  Stream<QuerySnapshot> _getRecordsStream() {
    return FirebaseFirestore.instance.collection('records').orderBy('deceasedName').snapshots();
  }

  Future<void> _performDateSearch() async {
    FocusScope.of(context).unfocus();

    final String deceasedDodString = _deceasedDodController.text;

    if (deceasedDodString.isEmpty) {
      // Use a specific error key for this case
      _showErrorSnackBar(AppLocalizations.getSync(context, 'errorSelectDate') ?? 'Please select a date to filter by.');
      return;
    }

    setState(() => _isSearching = true);

    try {
      Query query = FirebaseFirestore.instance.collection('records');

      try {
        final DateTime searchDate = _inputOutputDateFormat.parseStrict(deceasedDodString);
        DateTime startOfDay = DateTime(searchDate.year, searchDate.month, searchDate.day);
        DateTime endOfDay = DateTime(searchDate.year, searchDate.month, searchDate.day, 23, 59, 59, 999);
        query = query
            .where('deceasedDod', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .where('deceasedDod', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay));
      } catch (e) {
        _showErrorSnackBar(AppLocalizations.getSync(context, 'errorInvalidDateFormat') ?? 'Invalid Date of Death format. Please use DD/MM/YYYY.');
        setState(() => _isSearching = false);
        return;
      }

      final QuerySnapshot snapshot = await query.limit(20).get();
      final List<Record> foundRecords = snapshot.docs.map<Record?>((doc) {
        try {
          return Record.fromSnapshot(doc);
        } catch (e) {
          print("Skipping search result document ${doc.id} due to parsing error: $e");
          return null;
        }
      }).whereType<Record>().toList();

      if (mounted) {
        if (foundRecords.isEmpty) {
          _showErrorSnackBar(AppLocalizations.getSync(context, 'noResults') ?? 'No matching records found.');
        } else {
          _navigateToResults(foundRecords);
        }
      }
    } catch (e) {
      print("Error during date search: $e");
      _showErrorSnackBar('${AppLocalizations.getSync(context, 'errorDuringSearch') ?? 'Error during search'}: ${e.toString()}');
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    // --- LOCALIZATION: Fetch all strings at the start of the build method ---
    final appBarTitle = AppLocalizations.getSync(context, 'title') ?? 'Search Grave Records';
    final selectRecordHint = AppLocalizations.getSync(context, 'selectRecordHint') ?? 'Browse and select a record...';
    final deceasedDodHint = AppLocalizations.getSync(context, 'deceasedDodHint') ?? 'Deceased Date of Death (DD/MM/YYYY)';
    final searchBtnText = AppLocalizations.getSync(context, 'searchBtn') ?? 'Search Records';


    return Scaffold(
      appBar: AppBar(
        // Use the localized title
        title: Text(
          appBarTitle,
          style: const TextStyle(
            fontFamily: 'Metamorphous',
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black87,
          ),
        ),
        // --- FIX: Use a solid white background for readability ---
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/al-marhum/islamicbackground.png'),
            fit: BoxFit.cover,
          ),
        ),
        // --- FIX: Removed redundant nested SafeArea ---
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  // Pass the localized hint to the dropdown builder
                  _buildRecordsDropdownStream(selectRecordHint),
                  const SizedBox(height: 16),
                  _buildTextField(
                    // Use the localized hint
                    hintText: deceasedDodHint,
                    controller: _deceasedDodController,
                    prefixIcon: Icons.calendar_today,
                    readOnly: true,
                    onTap: _selectDate,
                  ),
                  const SizedBox(height: 32),
                  _buildSearchButton(
                    isSearching: _isSearching,
                    // Use the localized button text
                    searchText: searchBtnText,
                    onPressed: _performDateSearch,
                  ),
                ],
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
          return Text('Error loading records. Check Debug Console.');
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('No records found in the database.');
        }

        final List<Record> records = snapshot.data!.docs.map<Record?>((doc) {
          try {
            return Record.fromSnapshot(doc);
          } catch (e) {
            print("!!! FAILED to parse document ${doc.id}. Error: $e");
            return null;
          }
        }).whereType<Record>().toList();

        return DropdownButtonFormField<Record>(
          value: _selectedRecord,
          isExpanded: true,
          hint: Text(hintText, overflow: TextOverflow.ellipsis),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.95),
            prefixIcon: Icon(Icons.person_search, color: Colors.green.shade800),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: Colors.green.shade700, width: 2.0)),
          ),
          items: records.map((Record record) {
            return DropdownMenuItem<Record>(
              value: record,
              // --- FIX: Show both name and lot number for clarity ---
              child: Text(
                '${record.deceasedName} (Lot: ${record.lotNumber ?? 'N/A'})',
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: records.isEmpty ? null : (Record? newValue) {
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

  Widget _buildTextField({ required String hintText, required TextEditingController controller, IconData? prefixIcon, bool readOnly = false, VoidCallback? onTap, }) { return TextFormField( controller: controller, readOnly: readOnly, onTap: onTap, style: const TextStyle(fontSize: 16, color: Colors.black87), decoration: InputDecoration( hintText: hintText, hintStyle: TextStyle(color: Colors.grey.shade600), filled: true, fillColor: Colors.white.withOpacity(0.95), prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.green.shade800) : null, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: Colors.grey.shade300)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: Colors.green.shade700, width: 2.0)), ), ); }

  Widget _buildSearchButton({ required bool isSearching, required String searchText, required VoidCallback onPressed, }) { return SizedBox( height: 52, child: ElevatedButton.icon( icon: isSearching ? Container() : const Icon(Icons.filter_alt, color: Colors.white), label: isSearching ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white)) : Text(searchText, style: const TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom( backgroundColor: Colors.green.shade700, disabledBackgroundColor: Colors.grey.shade500, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 5, ), onPressed: isSearching ? null : onPressed, ), ); }
}