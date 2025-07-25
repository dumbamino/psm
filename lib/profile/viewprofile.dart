// lib/profile/viewprofile.dart

import 'dart:io';
import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- CONSTANTS ---
const String _kNameKey = 'profile_name';
const String _kDobKey = 'profile_dob';
const String _kGenderKey = 'profile_gender';
const String _kAddressKey = 'profile_address';
const String _kBioKey = 'profile_bio';
const String _kImageKey = 'profile_image_path';

const String _kFontFamily = 'Metamorphous';
const double _kAvatarRadius = 60.0;
const double _kFieldSpacing = 18.0;
final BorderRadius _kCardBorderRadius = BorderRadius.circular(24.0);
final Color _kCardBackgroundColor = Colors.white.withOpacity(0.60);
final Color _kTextColor = const Color(0xFF333333);
final Color _kPrimaryColor = const Color(0xFF6A1B9A);

//==============================================================================
// PROFILE SCREEN (VIEW + EDIT)
//==============================================================================

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  // State for display
  late Future<void> _initProfileFuture;
  String _name = '';
  String _dob = '';
  String _gender = '';
  String _address = '';
  String _bio = '';
  File? _profileImageFile;

  // State for editing
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _bioController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedGender;
  final List<String> _genderOptions = ['Male', 'Female', 'Other', 'Prefer not to say'];


  @override
  void initState() {
    super.initState();
    _initProfileFuture = _loadProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // --- DATA HANDLING ---

  Future<void> _loadProfileData() async {
    if (_isEditing) return; // Don't reload if in the middle of editing
    await Future.delayed(const Duration(milliseconds: 1500)); // Shimmer delay
    final prefs = await SharedPreferences.getInstance();

    // --- Load name from Firestore ---
    String? firestoreName;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          firestoreName = doc.data()?['fullName'] as String?;
        }
      } catch (_) {}
    }

    if (!mounted) return;

    setState(() {
      _name = firestoreName ?? prefs.getString(_kNameKey) ?? 'Add Your Name';
      _dob = prefs.getString(_kDobKey) ?? '—';
      _gender = prefs.getString(_kGenderKey) ?? '—';
      _address = prefs.getString(_kAddressKey) ?? '—';
      _bio = prefs.getString(_kBioKey) ?? 'Add a bio to tell others about yourself.';
      final imagePath = prefs.getString(_kImageKey);
      _profileImageFile = (imagePath != null && imagePath.isNotEmpty) ? File(imagePath) : null;
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kNameKey, _nameController.text.trim());
      await prefs.setString(_kAddressKey, _addressController.text.trim());
      await prefs.setString(_kBioKey, _bioController.text.trim());
      await prefs.setString(
          _kDobKey, _selectedDate != null ? DateFormat('dd MMMM yyyy').format(_selectedDate!) : '—');
      await prefs.setString(_kGenderKey, _selectedGender ?? '—');

      // Persist the name to Firestore as well
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'fullName': _nameController.text.trim()});
        } catch (_) {}
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile saved!'), backgroundColor: Colors.green));
        _toggleEditMode(); // Exit edit mode
        await _loadProfileData(); // Reload to display new data
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (pickedFile != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kImageKey, pickedFile.path);
      setState(() {
        _profileImageFile = File(pickedFile.path);
      });
    }
  }

  // --- EDIT MODE & UI LOGIC ---

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        // Entering edit mode: populate controllers with current data
        _nameController.text = _name.replaceAll('Add Your Name', '');
        _addressController.text = _address.replaceAll('—', '');
        _bioController.text = _bio.replaceAll('Add a bio to tell others about yourself.', '');

        if (_dob != '—') {
          try { _selectedDate = DateFormat('dd MMMM yyyy').parse(_dob); } catch (e) { _selectedDate = null; }
        } else {
          _selectedDate = null;
        }

        if (_gender != '—') {
          _selectedGender = _gender;
        } else {
          _selectedGender = null;
        }
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? DateTime.now(),
        firstDate: DateTime(1920),
        lastDate: DateTime.now(),
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(primary: _kPrimaryColor, onPrimary: Colors.white, onSurface: _kTextColor),
              textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: _kPrimaryColor))),
          child: child!,
        ));
    if (picked != null) setState(() => _selectedDate = picked);
  }


  // --- WIDGET BUILDERS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _initProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !_isEditing) {
            return const _ProfileShimmerLoader();
          }
          return _buildProfileContent();
        },
      ),
    );
  }

  Widget _buildProfileContent() {
    return Stack(
      children: [
        Positioned.fill(child: Image.asset("assets/images/al-marhum/islamicbackground.png", fit: BoxFit.cover)),
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildInfoCard(),
                      const SizedBox(height: 24),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 280.0,
      pinned: true,
      stretch: true,
      backgroundColor: _kPrimaryColor.withOpacity(0.7),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(_isEditing ? 'Editing Profile' : _name, style: const TextStyle(fontFamily: _kFontFamily, fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        background: Stack(fit: StackFit.expand, children: [
          ClipRect(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), child: Container(color: Colors.black.withOpacity(0.2)))),
          Center(child: Padding(padding: const EdgeInsets.only(bottom: 40.0), child: _Avatar(imageFile: _profileImageFile, onTap: _pickImage))),
        ]),
      ),
    );
  }

  Widget _buildInfoCard() {
    return _FrostedGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _isEditing ? _buildEditFields() : _buildViewFields(),
      ),
    );
  }

  List<Widget> _buildViewFields() {
    return [
      Text('About Me', style: TextStyle(fontFamily: _kFontFamily, fontWeight: FontWeight.bold, fontSize: 18, color: _kTextColor)),
      const SizedBox(height: 8),
      Text(_bio, style: TextStyle(fontFamily: 'sans-serif', fontSize: 15, color: _kTextColor.withOpacity(0.8), height: 1.5)),
      const Divider(height: 30),
      _InfoTile(icon: Icons.cake_outlined, label: 'Born on', value: _dob),
      _InfoTile(icon: Icons.person_outline, label: 'Gender', value: _gender),
      _InfoTile(icon: Icons.location_on_outlined, label: 'Lives in', value: _address),
    ];
  }

  List<Widget> _buildEditFields() {
    return [
      _buildTextFormField(controller: _nameController, label: 'Full Name', icon: Icons.person_rounded),
      _buildTextFormField(controller: _bioController, label: 'Bio', icon: Icons.article_rounded, maxLines: 4, isOptional: true),
      _buildDatePicker(),
      _buildGenderDropdown(),
      _buildTextFormField(controller: _addressController, label: 'Address', icon: Icons.location_on_rounded, isOptional: true),
    ];
  }

  Widget _buildActionButtons() {
    if (_isEditing) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _toggleEditMode,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                foregroundColor: _kPrimaryColor,
                side: BorderSide(color: _kPrimaryColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                foregroundColor: Colors.white,
                backgroundColor: _kPrimaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Save'),
            ),
          ),
        ],
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.edit, size: 20),
          label: const Text('Edit Profile'),
          onPressed: _toggleEditMode,
          style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: _kPrimaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontFamily: _kFontFamily, fontSize: 18, fontWeight: FontWeight.w600),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        ),
      );
    }
  }

  // --- FORM FIELD BUILDERS (FOR EDIT MODE) ---

  Widget _buildTextFormField({required TextEditingController controller, required String label, required IconData icon, int maxLines = 1, bool isOptional = false}) {
    return Padding(padding: const EdgeInsets.only(bottom: _kFieldSpacing), child: TextFormField(
        controller: controller, maxLines: maxLines, style: TextStyle(fontFamily: 'sans-serif', fontSize: 16, color: _kTextColor),
        decoration: _inputDecoration(label, icon),
        validator: (value) => (!isOptional && (value == null || value.trim().isEmpty)) ? 'Please enter your $label' : null));
  }

  Widget _buildDatePicker() {
    return Padding(padding: const EdgeInsets.only(bottom: _kFieldSpacing), child: TextFormField(
        readOnly: true,
        onTap: () => _selectDate(context),
        controller: TextEditingController(text: _selectedDate != null ? DateFormat('dd MMMM yyyy').format(_selectedDate!) : ''),
        decoration: _inputDecoration('Date of Birth', Icons.calendar_today_rounded, hintText: 'Select your date of birth')));
  }

  Widget _buildGenderDropdown() {
    return Padding(padding: const EdgeInsets.only(bottom: _kFieldSpacing), child: DropdownButtonFormField<String>(
        value: _selectedGender,
        decoration: _inputDecoration('Gender', Icons.wc_rounded),
        items: _genderOptions.map((g) => DropdownMenuItem<String>(value: g, child: Text(g, style: const TextStyle(fontFamily: 'sans-serif')))).toList(),
        onChanged: (newValue) => setState(() => _selectedGender = newValue),
        validator: (v) => v == null ? 'Please select a gender' : null));
  }

  InputDecoration _inputDecoration(String label, IconData icon, {String? hintText}) {
    return InputDecoration(
        labelText: label, hintText: hintText,
        prefixIcon: Icon(icon, color: _kTextColor.withOpacity(0.6)),
        labelStyle: TextStyle(fontFamily: 'sans-serif', fontSize: 16, fontWeight: FontWeight.w600, color: _kTextColor.withOpacity(0.8)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _kPrimaryColor, width: 2)),
        filled: true, fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16));
  }
}


//==============================================================================
// SHARED WIDGETS
//==============================================================================

class _Avatar extends StatelessWidget {
  final File? imageFile;
  final VoidCallback onTap;
  const _Avatar({required this.onTap, this.imageFile});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          CircleAvatar(
              radius: _kAvatarRadius,
              backgroundColor: Colors.white.withOpacity(0.7),
              backgroundImage: (imageFile != null && imageFile!.existsSync()) ? FileImage(imageFile!) as ImageProvider : null,
              child: (imageFile == null) ? Icon(Icons.person_rounded, size: _kAvatarRadius, color: Colors.grey.shade400) : null),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(radius: 20, backgroundColor: _kPrimaryColor, child: const Icon(Icons.camera_alt, color: Colors.white, size: 20)),
          ),
        ],
      ),
    );
  }
}

class _FrostedGlassCard extends StatelessWidget {
  const _FrostedGlassCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: _kCardBorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
                color: _kCardBackgroundColor,
                borderRadius: _kCardBorderRadius,
                border: Border.all(color: Colors.white.withOpacity(0.2))),
            child: child),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: _kTextColor.withOpacity(0.7)),
      title: Text(label, style: TextStyle(fontFamily: 'sans-serif', color: _kTextColor.withOpacity(0.7), fontSize: 13)),
      subtitle: Text(value,
          style: TextStyle(fontFamily: 'sans-serif', color: _kTextColor, fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}

class _ProfileShimmerLoader extends StatelessWidget {
  const _ProfileShimmerLoader();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: Image.asset("assets/images/al-marhum/islamicbackground.png", fit: BoxFit.cover)),
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(expandedHeight: 280.0, backgroundColor: Colors.black.withOpacity(0.1), flexibleSpace: FlexibleSpaceBar(
                background: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40.0),
                    child: CircleAvatar(radius: _kAvatarRadius, backgroundColor: Colors.white),
                  ),
                ),
              )),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    children: [
                      Container(height: 250, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: _kCardBorderRadius)),
                      const SizedBox(height: 24),
                      Container(height: 50, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}