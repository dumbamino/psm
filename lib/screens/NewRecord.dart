// lib/screens/NewRecord.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:psm/pages/map_page.dart';
import 'package:psm/service/firestore.dart';
import 'package:psm/service/records.dart';
import 'package:share_plus/share_plus.dart';

class NewRecordScreen extends StatefulWidget {
  final String? recordId;
  final Map<String, dynamic>? initialData;

  const NewRecordScreen({
    super.key,
    this.recordId,
    this.initialData,
  });

  @override
  State<NewRecordScreen> createState() => _NewRecordScreenState();
}

class _NewRecordScreenState extends State<NewRecordScreen> {
  // All state variables, controllers, and initState methods are correct.
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RecordFirestoreService _recordService = RecordFirestoreService();
  User? _currentUser;
  bool _isLoadingUser = true;
  bool _isProcessing = false;
  final _deceasedNameController = TextEditingController();
  final _deceasedDodController = TextEditingController();
  final _latLngController = TextEditingController();
  final _areaController = TextEditingController();
  final _deceasedDobController = TextEditingController();
  final _graveLotController = TextEditingController();
  final _graveAddressController = TextEditingController();
  final _cemeteryNameController = TextEditingController();
  final _relationshipToDeceasedController = TextEditingController();
  String? _selectedStateDropdown;
  String? _selectedCategory;
  LatLng? _selectedGraveLocation;
  final List<String> _malaysianStates = const ["Johor", "Kedah", "Kelantan", "Melaka", "Negeri Sembilan", "Pahang", "Perak", "Perlis", "Pulau Pinang", "Sabah", "Sarawak", "Selangor", "Terengganu", "W.P. Kuala Lumpur", "W.P. Labuan", "W.P. Putrajaya"];
  final List<String> _categories = const ['Citizen', 'Child', 'Infant', 'Senior Citizen'];
  final DateFormat _commonDateFormat = DateFormat('dd/MM/yyyy');
  final Color _primaryGreen = Colors.green.shade700;
  final Color _inputFieldBackgroundColor = Colors.white;
  bool get _isEditing => widget.recordId != null;

  @override
  void initState() { super.initState(); _initializeScreen(); }

  // All helper functions like _initializeScreen, _loadInitialData, dispose, _parseDate, etc., are correct and can remain unchanged.
  List<String> _generateSearchKeywords({ required String deceasedName, required String graveLot, String? area, String? category, }) { final Set<String> keywords = {}; void addKeyword(String word) { if (word.isNotEmpty) { keywords.add(word.toLowerCase()); } } deceasedName.split(RegExp(r'[\s/,-]+')).forEach(addKeyword); graveLot.split(RegExp(r'[\s/,-]+')).forEach(addKeyword); area?.split(RegExp(r'[\s/,-]+')).forEach(addKeyword); category?.split(RegExp(r'[\s/,-]+')).forEach(addKeyword); return keywords.toList(); }
  Future<void> _initializeScreen() async { setState(() => _isLoadingUser = true); _currentUser = _auth.currentUser; if (_currentUser == null) { if (mounted) { _showSnackbar('User session not found. Please log in again.', isError: true); setState(() => _isLoadingUser = false); } return; } if (_isEditing && widget.initialData != null) { _loadInitialData(widget.initialData!); } if (mounted) setState(() => _isLoadingUser = false); }
  void _loadInitialData(Map<String, dynamic> data) { _deceasedNameController.text = data[kDeceasedNameField] as String? ?? ''; if (data[kDeceasedDodField] is Timestamp) { _deceasedDodController.text = _commonDateFormat.format((data[kDeceasedDodField] as Timestamp).toDate()); } if (data[kDeceasedDobField] is Timestamp) { _deceasedDobController.text = _commonDateFormat.format((data[kDeceasedDobField] as Timestamp).toDate()); } final positionData = data[kPositionField]; if (positionData is GeoPoint) { _selectedGraveLocation = LatLng(positionData.latitude, positionData.longitude); _latLngController.text = "${_selectedGraveLocation!.latitude.toStringAsFixed(6)},${_selectedGraveLocation!.longitude.toStringAsFixed(6)}"; } _selectedStateDropdown = data[kStateField] as String?; if (_selectedStateDropdown != null && !_malaysianStates.contains(_selectedStateDropdown)) { _selectedStateDropdown = null; } _areaController.text = data[kAreaField] as String? ?? ''; _selectedCategory = data[kCategoryField] as String?; if (_selectedCategory != null && !_categories.contains(_selectedCategory)) { _selectedCategory = null; } _graveLotController.text = data[kGraveLotField] as String? ?? ''; _graveAddressController.text = data[kGraveAddressField] as String? ?? ''; _cemeteryNameController.text = data[kCemeteryNameField] as String? ?? ''; _relationshipToDeceasedController.text = data[kRelationshipToDeceasedField] as String? ?? ''; }
  @override void dispose() { _deceasedNameController.dispose(); _deceasedDodController.dispose(); _latLngController.dispose(); _areaController.dispose(); _deceasedDobController.dispose(); _graveLotController.dispose(); _graveAddressController.dispose(); _cemeteryNameController.dispose(); _relationshipToDeceasedController.dispose(); super.dispose(); }
  String? _trimmedOrNull(TextEditingController controller) { final text = controller.text.trim(); return text.isEmpty ? null : text; }
  Timestamp? _parseDateToTimestamp(String? dateString) { if (dateString == null || dateString.trim().isEmpty) return null; try { final date = _commonDateFormat.parseStrict(dateString.trim()); return Timestamp.fromDate(date); } catch (_) { return null; } }
  LatLng? _parseLatLngFromString(String latLngString) { try { final parts = latLngString.split(','); if (parts.length != 2) return null; final lat = double.parse(parts[0].trim()); final lng = double.parse(parts[1].trim()); return LatLng(lat, lng); } catch (_) { return null; } }
  void _showSnackbar(String message, {bool isError = true}) { if (!mounted) return; ScaffoldMessenger.of(context).removeCurrentSnackBar(); final snackBar = SnackBar( content: Text(message), backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade700, duration: const Duration(seconds: 3), behavior: SnackBarBehavior.floating, ); ScaffoldMessenger.of(context).showSnackBar(snackBar); }
  Future<void> _selectDate(BuildContext context, TextEditingController controller, {bool allowFutureDates = false}) async { DateTime? initialDate; try { initialDate = _commonDateFormat.parseStrict(controller.text.trim()); } catch (_) { initialDate = DateTime.now(); } final DateTime? picked = await showDatePicker( context: context, initialDate: initialDate, firstDate: DateTime(1800), lastDate: allowFutureDates ? DateTime(2100) : DateTime.now(), ); if (picked != null) { controller.text = _commonDateFormat.format(picked); } }
  Future<void> _pickLocationOnMap() async { final LatLng? result = await Navigator.push( context, MaterialPageRoute(builder: (context) => GoogleMapPage(initialSelectedLocation: _selectedGraveLocation)), ); if (result != null) { setState(() { _selectedGraveLocation = result; _latLngController.text = "${result.latitude.toStringAsFixed(6)},${result.longitude.toStringAsFixed(6)}"; }); } }
  bool _validateFormAndParseData() { if (_currentUser == null) { _showSnackbar('You must be logged in to submit a record.', isError: true); return false; } if (!(_formKey.currentState?.validate() ?? false)) { _showSnackbar('Please correct the errors in the form.', isError: true); return false; } if (_selectedGraveLocation == null) { _showSnackbar('Grave location coordinates are required. Please pin a location.', isError: true); return false; } return true; }


  // --- THIS IS THE CORRECTED SUBMISSION LOGIC ---
  Future<void> _submitRecord() async {
    if (!_validateFormAndParseData()) return;

    setState(() => _isProcessing = true);

    try {
      GeoPoint gravePositionForFirestore = GeoPoint(_selectedGraveLocation!.latitude, _selectedGraveLocation!.longitude);

      final deceasedNameTrimmed = _deceasedNameController.text.trim();
      final graveLotTrimmed = _graveLotController.text.trim();
      final areaTrimmed = _areaController.text.trim();
      final selectedCategoryValue = _selectedCategory;

      Map<String, dynamic> recordData = {
        kDeceasedNameField: deceasedNameTrimmed,
        kDeceasedDodField: _parseDateToTimestamp(_deceasedDodController.text.trim()),
        kPositionField: gravePositionForFirestore,
        kStateField: _selectedStateDropdown,
        kAreaField: areaTrimmed,
        kCategoryField: selectedCategoryValue,
        kDeceasedDobField: _parseDateToTimestamp(_deceasedDobController.text.trim()),
        kGraveLotField: _trimmedOrNull(_graveLotController),
        kGraveAddressField: _trimmedOrNull(_graveAddressController),
        kCemeteryNameField: _trimmedOrNull(_cemeteryNameController),
        kRelationshipToDeceasedField: _trimmedOrNull(_relationshipToDeceasedController),
        'searchKeywords': _generateSearchKeywords(
          deceasedName: deceasedNameTrimmed,
          graveLot: graveLotTrimmed,
          area: areaTrimmed,
          category: selectedCategoryValue,
        ),
      };

      if (_isEditing) {
        recordData[kUpdatedAtField] = FieldValue.serverTimestamp();
        await _recordService.updateRecord(widget.recordId!, recordData);
        _showSnackbar('Record updated successfully!', isError: false);
      } else {
        recordData[kUserIdField] = _currentUser!.uid;
        recordData[kUserEmailField] = _currentUser!.email;
        recordData[kCreatedAtField] = Timestamp.now();

        // --- THE FIX ---
        // The recordData map is already fully prepared.
        // There is no need to convert it to a Record object and back again.
        // Pass the map directly to the service method.
        await _recordService.addRecord(recordData);
        _showSnackbar('New record submitted successfully!', isError: false);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e, s) {
      print("[NewRecordScreen] Error in _submitRecord: $e\nStackTrace: $s");
      _showSnackbar('Failed to submit record. Please try again.', isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    // The build method and all its helpers are correct and unchanged.
    final String appBarTitleText = _isEditing ? 'Edit Record' : 'New Record';
    final String buttonText = _isEditing ? 'Submit Changes' : 'Submit Record';
    final bool canSubmit = !_isProcessing && !_isLoadingUser && _currentUser != null;

    return Scaffold(
      appBar: AppBar( leading: IconButton( icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black), onPressed: () => Navigator.of(context).pop(), ), title: Text(appBarTitleText, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20)), backgroundColor: Colors.transparent, elevation: 0, centerTitle: true, ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration( gradient: LinearGradient(colors: [Colors.green.shade100, Colors.white], begin: Alignment.topCenter, end: Alignment.bottomCenter), ),
        width: double.infinity, height: double.infinity,
        child: SafeArea(
          child: _isLoadingUser ? Center(child: CircularProgressIndicator(color: _primaryGreen)) : _currentUser == null ? Center(child: Text("Error: User not loaded. Please log in again.", style: TextStyle(color: Colors.red.shade700))) : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const SizedBox(height: 10),
                  _buildSectionTitle("Deceased Information", isRequired: true),
                  _buildTextField(controller: _deceasedNameController, label: 'Full Name*', validator: (v) => (v==null||v.trim().isEmpty) ? 'Full Name is required.' : null),
                  _buildTextField( controller: _deceasedDodController, label: 'Date of Death*', hintText: 'DD/MM/YYYY', readOnly: true, onTap: () => _selectDate(context, _deceasedDodController), validator: (v) => (v==null||v.trim().isEmpty) ? 'Date of Death is required.' : null, ),
                  const SizedBox(height: 20),
                  _buildLocationPickerTile(),
                  const SizedBox(height: 20),
                  _buildSectionTitle("Grave Lot Number", isRequired: true),
                  _buildTextField( controller: _graveLotController, label: 'Grave Lot Number*', validator: (v) => (v == null || v.trim().isEmpty) ? 'Grave Lot Number is required.' : null, ),
                  const SizedBox(height: 20),
                  _buildSectionTitle("Additional Information", isRequired: true),
                  _buildDropdown( items: _malaysianStates, value: _selectedStateDropdown, label: 'State', onChanged: (nv) => setState(() => _selectedStateDropdown = nv), ),
                  _buildTextField(
                    controller: _areaController,
                    label: 'Area / District',
                  ),
                  _buildDropdown(
                    items: _categories,
                    value: _selectedCategory,
                    label: 'Category',
                    onChanged: (nv) => setState(() => _selectedCategory = nv),
                  ),
                  _buildTextField( controller: _deceasedDobController, label: 'Date of Birth', hintText: 'DD/MM/YYYY', readOnly: true, onTap: () => _selectDate(context, _deceasedDobController), ),
                  _buildTextField(controller: _relationshipToDeceasedController, label: 'Relationship to Deceased'),
                  const SizedBox(height: 30),
                  _buildSubmitButton(buttonText, canSubmit),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // All other build helper methods can remain unchanged.
  Widget _buildLocationPickerTile() { String locationText = _latLngController.text.trim(); bool hasSelectedLocation = _selectedGraveLocation != null; if (hasSelectedLocation && locationText.isEmpty) { locationText = "${_selectedGraveLocation!.latitude.toStringAsFixed(6)}, ${_selectedGraveLocation!.longitude.toStringAsFixed(6)}"; } return ListTile( contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0), leading: Icon(Icons.map_outlined, color: _primaryGreen, size: 30), title: const Text('Pin Location on Map', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)), subtitle: Text( hasSelectedLocation ? 'Pinned: $locationText' : 'Tap to select or enter coordinates', style: TextStyle(color: hasSelectedLocation ? _primaryGreen : Colors.grey[700], fontSize: 13, fontWeight: hasSelectedLocation ? FontWeight.bold : FontWeight.normal), maxLines: 1, overflow: TextOverflow.ellipsis, ), trailing: Row( mainAxisSize: MainAxisSize.min, children: [ if (hasSelectedLocation) Builder(builder: (context) { return IconButton( icon: const Icon(Icons.share, size: 20, color: Colors.black54), tooltip: 'Share Coordinates', onPressed: () async { final box = context.findRenderObject() as RenderBox?; if (box == null) return; final coords = locationText; if (coords.isEmpty) { _showSnackbar("Location coordinates are not available.", isError: true); return; } final deceasedName = _deceasedNameController.text.trim(); final lotNumber = _graveLotController.text.trim(); String subjectText = deceasedName.isNotEmpty ? "Grave Location for $deceasedName" : "Grave Location"; String bodyText = "Location for ${deceasedName.isNotEmpty ? deceasedName : 'the grave'}"; if (lotNumber.isNotEmpty) bodyText += " (Lot: $lotNumber)"; bodyText += ":\n\nhttps://www.google.com/maps/search/?api=1&query=$coords"; await Share.share(bodyText, subject: subjectText, sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size); }, ); }), const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.black54), ], ), onTap: _pickLocationOnMap, tileColor: _inputFieldBackgroundColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0), side: BorderSide(color: Colors.grey.shade300)), ); }
  Widget _buildSectionTitle(String title, {required bool isRequired}) { String displayTitle = title; if (isRequired && !title.endsWith('*')) displayTitle += "*"; return Padding( padding: const EdgeInsets.only(bottom: 10.0, top: 15.0), child: Text(displayTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 18)), ); }
  Widget _buildDropdown({required List<String> items, String? value, required String label, required void Function(String?)? onChanged, String? Function(String?)? validator}) { String? currentValue = (items.isNotEmpty && value != null && items.contains(value)) ? value : null; return Padding( padding: const EdgeInsets.symmetric(vertical: 6.0), child: DropdownButtonFormField<String>( value: currentValue, items: items.map((item) => DropdownMenuItem<String>(value: item, child: Text(item, style: const TextStyle(fontSize: 14, color: Colors.black87)))).toList(), onChanged: onChanged, decoration: _inputDecoration(label), validator: validator, isExpanded: true, iconEnabledColor: Colors.black54, style: const TextStyle(fontSize: 14, color: Colors.black87), autovalidateMode: AutovalidateMode.onUserInteraction, ), ); }
  Widget _buildTextField({required TextEditingController controller, required String label, String? hintText, TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator, bool readOnly = false, VoidCallback? onTap, int? maxLines = 1}) { return Padding( padding: const EdgeInsets.symmetric(vertical: 6.0), child: TextFormField( controller: controller, decoration: _inputDecoration(label, hintText: hintText), keyboardType: keyboardType, validator: validator, readOnly: readOnly, onTap: onTap, style: const TextStyle(fontSize: 14, color: Colors.black87), autovalidateMode: AutovalidateMode.onUserInteraction, maxLines: maxLines, ), ); }
  InputDecoration _inputDecoration(String label, {String? hintText}) { return InputDecoration( labelText: label, hintText: hintText, labelStyle: const TextStyle(color: Colors.black54, fontSize: 14), hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13), filled: true, fillColor: _inputFieldBackgroundColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: Colors.grey.shade300)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: Colors.grey.shade300)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: _primaryGreen, width: 1.5)), errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: Colors.red.shade400, width: 1.0)), focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: Colors.red.shade600, width: 1.5)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14), ); }
  Widget _buildSubmitButton(String text, bool enabled) { return ElevatedButton( onPressed: enabled ? _submitRecord : null, style: ElevatedButton.styleFrom( padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: enabled ? 5 : 0, disabledBackgroundColor: Colors.grey.shade400.withOpacity(0.7), disabledForegroundColor: Colors.white.withOpacity(0.7), ), child: Ink( decoration: BoxDecoration( gradient: enabled ? LinearGradient(colors: [_primaryGreen, Colors.green.shade500], begin: Alignment.centerLeft, end: Alignment.centerRight) : null, borderRadius: BorderRadius.circular(8), color: enabled ? null : Colors.grey.shade400, ), child: Container( padding: const EdgeInsets.symmetric(vertical: 14.0), alignment: Alignment.center, child: _isProcessing ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) : Row( mainAxisAlignment: MainAxisAlignment.center, children: [ Icon(_isEditing ? Icons.save_alt_outlined : Icons.check_circle_outline, color: Colors.white), const SizedBox(width: 10), Text( _isLoadingUser ? "LOADING..." : (_currentUser == null ? "LOGIN REQUIRED" : text), style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold), ), ], ), ), ), ); }
}