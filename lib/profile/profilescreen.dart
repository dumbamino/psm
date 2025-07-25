import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psm/profile/viewprofile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localization/app_localizations.dart';
import '../localization/locale_provider.dart';
import '../pages/notificationpage.dart';
import '../screens/homescreen.dart';
import '../service/auth.dart' as app_auth_service;
import '../talqin_doa/talqin_doa.dart';
import 'change_password.dart';
import 'yassin.dart';

const String _kImageKey = 'profile_image_path';

class AppColors {
  static const Color primary = Color(0xFF004D40);
  static const Color accent = Color(0xFFD4AF37);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color accountCategory = Color(0xFF1976D2);
  static const Color practiceCategory = Color(0xFF388E3C);
  static const Color settingsCategory = Color(0xFF616161);
  static const Color destructiveCategory = Color(0xFFD32F2F);
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = "Loading...";
  String _userEmail = "Loading...";
  String _userInitial = "";
  File? _profileImageFile;

  StreamSubscription<User?>? _authStateSubscription;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _authStateSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (!mounted) return;
      _loadProfileData();
    });
  }

  Future<void> _loadProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString(_kImageKey);

    if (!mounted) return;

    if (user == null) {
      setState(() {
        _userName = "Not Logged In";
        _userEmail = "";
        _userInitial = "?";
        _profileImageFile = null;
      });
    } else {
      setState(() {
        _userName = user.displayName ?? "No Name Set";
        _userEmail = user.email ?? "No Email Found";
        _profileImageFile = (imagePath != null && imagePath.isNotEmpty)
            ? File(imagePath)
            : null;

        if (_userName.isNotEmpty && _userName != "No Name Set") {
          _userInitial = _userName.trim().substring(0, 1).toUpperCase();
        } else if (_userEmail.isNotEmpty) {
          _userInitial = _userEmail.trim().substring(0, 1).toUpperCase();
        } else {
          _userInitial = "?";
        }
      });
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _showLogoutDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            AppLocalizations.get(dialogContext, 'logoutConfirmationTitle',
                    fallback: 'Confirm Logout') ??
                'Confirm Logout',
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          content: Text(
            AppLocalizations.get(dialogContext, 'logoutConfirmationBody',
                    fallback: 'Are you sure you want to log out?') ??
                'Are you sure you want to log out?',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                  AppLocalizations.get(dialogContext, 'no', fallback: 'No') ??
                      'No',
                  style: const TextStyle(color: Colors.white70)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text(
                  AppLocalizations.get(dialogContext, 'yes', fallback: 'Yes') ??
                      'Yes',
                  style: const TextStyle(
                      color: AppColors.destructiveCategory,
                      fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _performLogout();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    if (!mounted) return;
    setState(() => _isLoggingOut = true);
    try {
      final authService =
          Provider.of<app_auth_service.AuthService>(context, listen: false);
      await authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) =>
                  HomeScreen(onLanguageChange: (langCode) {})),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Logout failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  void _navigateToChangePassword() => Navigator.push(context,
      MaterialPageRoute(builder: (context) => const ChangePasswordScreen()));

  void _navigateToViewProfile() async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const ViewProfileScreen()));
    _loadProfileData();
  }

  void _navigateToTalqinPractices() => Navigator.push(
      context, MaterialPageRoute(builder: (context) => const MainMenuScreen()));
  void _navigateToYaasinReading() => Navigator.push(context,
      MaterialPageRoute(builder: (context) => const YaasinReadingScreen()));
  void _navigateToNotificationPage() => Navigator.push(context,
      MaterialPageRoute(builder: (context) => const NotificationPage()));
  void _navigateToSettings() {
    AppLocalizations.showLanguageDialog(context, (langCode) {
      Provider.of<LocaleProvider>(context, listen: false)
          .setLocale(Locale(langCode));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                centerTitle: true,
                // MODIFICATION: Increased expanded height to prevent overflow
                expandedHeight: 250.0,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: AppColors.textPrimary),
                    onPressed: _navigateToNotificationPage,
                    tooltip: 'Notifications',
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  titlePadding: const EdgeInsets.only(bottom: 16),
                  title: Text(
                      AppLocalizations.get(context, 'account',
                              fallback: 'Account') ??
                          'Account',
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Metamorphous')),
                  background: SafeArea(
                    child: Padding(
                      // MODIFICATION: Adjusted padding for better fit
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 45),
                      child: _buildProfileHeader(),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.25,
                  children: _buildGridItems(),
                ),
              ),
            ],
          ),
          if (_isLoggingOut)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.get(context, 'logging_out',
                              fallback: 'Logging out...') ??
                          'Logging out...',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final bool hasPhoto =
        _profileImageFile != null && _profileImageFile!.existsSync();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.primary.withOpacity(0.8),
          backgroundImage:
              hasPhoto ? FileImage(_profileImageFile!) as ImageProvider : null,
          child: !hasPhoto
              ? Text(
                  _userInitial,
                  style: const TextStyle(
                      fontSize: 32,
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold),
                )
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          _userName,
          style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              shadows: [Shadow(blurRadius: 2, color: Colors.black54)]),
          textAlign: TextAlign.center,
        ),
        if (_userEmail.isNotEmpty && _userEmail != "No Email Found")
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              _userEmail,
              style:
                  const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  List<Widget> _buildGridItems() {
    return [
      _buildOptionCard(
        titleKey: 'myProfile',
        icon: Icons.person_search_outlined,
        onTap: _navigateToViewProfile,
        color: AppColors.accountCategory,
      ),
      _buildOptionCard(
        titleKey: 'password',
        icon: Icons.lock_person_outlined,
        onTap: _navigateToChangePassword,
        color: AppColors.accountCategory,
      ),
      _buildOptionCard(
        titleKey: 'Talqin & Du\'a',
        icon: Icons.book_outlined,
        onTap: _navigateToTalqinPractices,
        color: AppColors.practiceCategory,
      ),
      _buildOptionCard(
        // MODIFICATION: Updated key to match screenshot
        titleKey: 'Surah Yaasin',
        icon: Icons.menu_book_outlined,
        onTap: _navigateToYaasinReading,
        color: AppColors.practiceCategory,
      ),
      _buildOptionCard(
        titleKey: 'settings',
        icon: Icons.translate_outlined,
        onTap: _navigateToSettings,
        color: AppColors.settingsCategory,
      ),
      _buildOptionCard(
        titleKey: 'logout',
        icon: Icons.logout,
        onTap: _showLogoutDialog,
        color: AppColors.destructiveCategory,
        isDestructive: true,
      ),
    ];
  }

  Widget _buildOptionCard({
    required String titleKey,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    bool isDestructive = false,
  }) {
    final String titleText =
        AppLocalizations.get(context, titleKey, fallback: titleKey) ?? titleKey;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: InkWell(
          onTap: onTap,
          splashColor: color.withOpacity(0.2),
          highlightColor: color.withOpacity(0.1),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: Colors.white.withOpacity(isDestructive ? 0.4 : 0.2),
                width: isDestructive ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      isDestructive ? color.withOpacity(0.8) : color,
                  child: Icon(icon, size: 26, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  titleText,
                  style: const TextStyle(
                    // MODIFICATION: Set text color to always be white
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    fontFamily: 'Metamorphous',
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
