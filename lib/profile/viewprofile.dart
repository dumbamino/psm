// lib/profile/viewprofile.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:shared_preferences/shared_preferences.dart';
// import '../localization/app_localizations.dart'; // Assuming this path is correct

// --- CONSTANTS FOR SHARED PREFERENCES ---
const String _kNameKey = 'profile_name';
const String _kDobKey = 'profile_dob';
const String _kGenderKey = 'profile_gender';
const String _kAddressKey = 'profile_address';
const String _kBioKey = 'profile_bio';
const String _kImageKey = 'profile_image_path';

// --- STYLING CONSTANTS ---
const String _kFontFamily = 'Metamorphous';
const double _kAvatarRadius = 80.0;
const double _kVerticalSpacing = 16.0;

// =========================================================================
// 1. VIEW PROFILE SCREEN (Read-Only View)
// =========================================================================
class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({Key? key}) : super(key: key);

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  // State variables for profile data
  String _name = '';
  String _dob = '';
  String _gender = '';
  String _address = '';
  String _bio = '';
  File? _profileImageFile;

  // Future to handle the initial loading state
  late Future<void> _initProfileFuture;

  @override
  void initState() {
    super.initState();
    _initProfileFuture = _loadProfileData();
  }

  /// Loads all profile data from SharedPreferences
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _name = prefs.getString(_kNameKey) ?? 'Add your name';
      _dob = prefs.getString(_kDobKey) ?? 'Add your date of birth';
      _gender = prefs.getString(_kGenderKey) ?? 'Add your gender';
      _address = prefs.getString(_kAddressKey) ?? 'Add your address';
      _bio = prefs.getString(_kBioKey) ?? 'Add your bio';

      final imagePath = prefs.getString(_kImageKey);
      if (imagePath != null && imagePath.isNotEmpty) {
        _profileImageFile = File(imagePath);
      } else {
        _profileImageFile = null;
      }
    });
  }

  /// Navigates to the edit screen and reloads data upon return.
  Future<void> _navigateToEditScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );
    // Reload data when returning from the edit screen
    _loadProfileData();
  }

  /// Handles picking an image from the gallery and saving its path.
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kImageKey, pickedFile.path);
      // Reload data to show the new image
      _loadProfileData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontFamily: _kFontFamily, color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        // --- CHANGE: Removed the edit button from the AppBar ---
        actions: const [],
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/images/al-marhum/islamicbackground.png", // Your background image
              fit: BoxFit.cover,
            ),
          ),
          // Content
          FutureBuilder(
            future: _initProfileFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              return _buildProfileContent();
            },
          ),
        ],
      ),
    );
  }

  // --- CHANGE: This entire method is updated to fix the layout ---
  Widget _buildProfileContent() {
    // LayoutBuilder gives us the screen's constraints (like height).
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          // We constrain the scrollable area to be at least as tall as the screen.
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          // IntrinsicHeight helps the Column and Spacer work correctly together.
          child: IntrinsicHeight(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight), // Space for AppBar
                  const SizedBox(height: 20),
                  // Profile Picture
                  _Avatar(
                    imageFile: _profileImageFile,
                    onTap: _pickImage,
                  ),
                  const SizedBox(height: _kVerticalSpacing),
                  // Full Name
                  Text(
                    _name,
                    style: const TextStyle(
                      fontFamily: _kFontFamily,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: _kVerticalSpacing * 2),
                  // Profile Details
                  _buildProfileInfoRow(icon: Icons.cake_outlined, label: 'Date of Birth', value: _dob),
                  _buildProfileInfoRow(icon: Icons.person_outline, label: 'Gender', value: _gender),
                  _buildProfileInfoRow(icon: Icons.location_on_outlined, label: 'Address', value: _address),
                  _buildProfileInfoRow(icon: Icons.article_outlined, label: 'Bio', value: _bio),

                  // The Spacer expands to fill all available space, pushing the button down.
                  const Spacer(),

                  // The new button at the bottom.
                  _buildEditButton(),
                  const SizedBox(height: 16), // Some padding at the very bottom
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  // --- CHANGE: Added a new method to build the bottom button ---
  Widget _buildEditButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.edit),
        label: const Text(
          'Edit Profile',
          style: TextStyle(
            fontFamily: _kFontFamily,
            fontSize: 18,
          ),
        ),
        onPressed: _navigateToEditScreen,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfoRow({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: _kVerticalSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: _kFontFamily,
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.grey.shade800, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontFamily: _kFontFamily,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.grey.shade300),
        ],
      ),
    );
  }
}

/// A custom widget for the profile avatar.
class _Avatar extends StatelessWidget {
  final File? imageFile;
  final VoidCallback onTap;

  const _Avatar({required this.onTap, this.imageFile, Key? key}) : super(key: key);

  ImageProvider get _imageProvider {
    if (imageFile != null && imageFile!.existsSync()) {
      return FileImage(imageFile!);
    }
    // Make sure you have this default avatar in your assets
    return const AssetImage('assets/images/al-marhum/default_avatar.png');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: _kAvatarRadius,
            backgroundImage: _imageProvider,
          ),
          // --- CHANGE: Changed the camera icon to be more visible ---
          Positioned(
            bottom: 4,
            right: 4,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Theme.of(context).primaryColor,
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.black54,
                child: Icon(Icons.camera_alt, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// 2. EDIT PROFILE SCREEN (Form for editing)
// =========================================================================
// (The EditProfileScreen code remains the same and does not need changes)

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _bioController = TextEditingController();

  // State variables for non-text fields
  DateTime? _selectedDate;
  String? _selectedGender;

  final List<String> _genderOptions = ['Male', 'Female', 'Other', 'Prefer not to say'];

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  /// Loads existing data into the form fields.
  Future<void> _loadCurrentData() async {
    final prefs = await SharedPreferences.getInstance();
    _nameController.text = prefs.getString(_kNameKey) ?? '';
    _addressController.text = prefs.getString(_kAddressKey) ?? '';
    _bioController.text = prefs.getString(_kBioKey) ?? '';

    final dobString = prefs.getString(_kDobKey);
    if (dobString != null && dobString.isNotEmpty) {
      try {
        _selectedDate = DateFormat('dd MMMM yyyy').parse(dobString);
      } catch (e) {
        _selectedDate = null;
      }
    }

    _selectedGender = prefs.getString(_kGenderKey);
    setState(() {}); // Refresh UI
  }

  /// Saves the form data to SharedPreferences.
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(_kNameKey, _nameController.text);
      await prefs.setString(_kAddressKey, _addressController.text);
      await prefs.setString(_kBioKey, _bioController.text);

      if (_selectedDate != null) {
        String formattedDate = DateFormat('dd MMMM yyyy').format(_selectedDate!);
        await prefs.setString(_kDobKey, formattedDate);
      }
      if (_selectedGender != null) {
        await prefs.setString(_kGenderKey, _selectedGender!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully!')),
        );
        Navigator.pop(context); // Go back to the view screen
      }
    }
  }

  /// Shows the date picker dialog.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontFamily: _kFontFamily, color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/al-marhum/islamicbackground.png", // Your background image
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    _buildTextFormField(controller: _nameController, label: 'Full Name'),
                    _buildDatePicker(),
                    _buildGenderDropdown(),
                    _buildTextFormField(controller: _addressController, label: 'Address'),
                    _buildTextFormField(controller: _bioController, label: 'Bio', maxLines: 4),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(fontFamily: _kFontFamily, fontSize: 16),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({required TextEditingController controller, required String label, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: _kVerticalSpacing),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontFamily: _kFontFamily),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontFamily: _kFontFamily),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.7),
        ),
        validator: (value) {
          if (label != 'Bio' && (value == null || value.isEmpty)) {
            return 'Please enter your $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDatePicker() {
    String formattedDate = _selectedDate != null
        ? DateFormat('dd MMMM yyyy').format(_selectedDate!)
        : 'Select your date of birth';

    return Padding(
      padding: const EdgeInsets.only(bottom: _kVerticalSpacing),
      child: InkWell(
        onTap: () => _selectDate(context),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Date of Birth',
            labelStyle: const TextStyle(fontFamily: _kFontFamily),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.7),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formattedDate, style: const TextStyle(fontFamily: _kFontFamily, fontSize: 16)),
              const Icon(Icons.calendar_today),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: _kVerticalSpacing),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        decoration: InputDecoration(
          labelText: 'Gender',
          labelStyle: const TextStyle(fontFamily: _kFontFamily),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.7),
        ),
        items: _genderOptions.map((String gender) {
          return DropdownMenuItem<String>(
            value: gender,
            child: Text(gender, style: const TextStyle(fontFamily: _kFontFamily)),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _selectedGender = newValue;
          });
        },
        validator: (value) => value == null ? 'Please select a gender' : null,
      ),
    );
  }
}