// lib/profile/profile_screen.dart

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psm/profile/viewprofile.dart';
import '../localization/app_localizations.dart';
import '../localization/locale_provider.dart';
import '../pages/notificationpage.dart';
import '../screens/homescreen.dart';
import '../talqin_doa/talqin_doa.dart';
import 'change_password.dart';
import '../service/auth.dart' as app_auth_service;
import 'yassin.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = "Loading...";
  String _email = "Loading...";
  final TextEditingController fullNameController = TextEditingController();

  StreamSubscription<User?>? _authStateSubscription;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    print("ProfileScreen: initState called.");

    _authStateSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
          print(
              "ProfileScreen: authStateChanges triggered. User is ${user == null ? 'null' : 'not null (UID: ${user?.uid})'}");
          if (!mounted) return;

          if (user == null) {
            setState(() {
              _userName = "Not Logged In";
              _email = "";
            });
          } else {
            setState(() {
              _userName = user.displayName ?? "No Name Set";
              _email = user.email ?? "No Email Found";
              print(
                  "ProfileScreen: User data set - Name: $_userName, Email: $_email");
            });
          }
        });
  }

  @override
  void dispose() {
    print("ProfileScreen: dispose called, cancelling auth subscription.");
    _authStateSubscription?.cancel();
    fullNameController.dispose();
    super.dispose();
  }

  Future<void> _showLogoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            AppLocalizations.get(dialogContext, 'logoutConfirmationTitle',
                fallback: 'Confirm Logout') ??
                'Confirm Logout',
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                AppLocalizations.get(dialogContext, 'no', fallback: 'No') ??
                    'No',
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
                child: Text(
                  AppLocalizations.get(dialogContext, 'yes', fallback: 'Yes') ??
                      'Yes',
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _performLogout(); // Call the logout function
                }),
          ],
        );
      },
    );
  }

  // --- THIS FUNCTION IS NOW CORRECTED ---
  Future<void> _performLogout() async {
    if (!mounted) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      final authService =
      Provider.of<app_auth_service.AuthService>(context, listen: false);
      await authService.signOut();

      // This is the single, reliable point of navigation after logout.
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => HomeScreen(onLanguageChange: (langCode) {}),
          ),
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      print("ProfileScreen: Logout failed: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.get(context, 'logout_failed',
                  fallback: 'Logout failed: ${e.toString()}') ??
                  'Logout failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  void _navigateToChangePassword() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const ChangePasswordScreen()));
  }

  void _navigateToViewProfile() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const ViewProfileScreen()));
  }

  void _navigateToTalqinPractices() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const MainMenuScreen()));
  }

  void _navigateToYaasinReading() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const YaasinReadingScreen()));
  }

  void _navigateToNotificationPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationPage()),
    );
  }

  void _navigateToSettings() {
    AppLocalizations.showLanguageDialog(context, (langCode) {
      Provider.of<LocaleProvider>(context, listen: false)
          .setLocale(Locale(langCode));
    });
  }

  @override
  Widget build(BuildContext context) {
    print(
        "ProfileScreen: build called. User: $_userName. Email: $_email. IsLoggingOut: $_isLoggingOut");

    bool showInitialLoading =
        (_userName == "Loading..." && _email == "Loading...") &&
            FirebaseAuth.instance.currentUser != null &&
            !_isLoggingOut;
    bool showRedirectingToLogin =
        (_userName == "Not Logged In" ||
            FirebaseAuth.instance.currentUser == null) &&
            !_isLoggingOut;

    if (showInitialLoading || showRedirectingToLogin) {
      return Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "assets/images/al-marhum/islamicbackground.png",
                fit: BoxFit.cover,
              ),
            ),
            const Center(child: CircularProgressIndicator()),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
            AppLocalizations.get(context, 'account', fallback: 'Account') ??
                'Account',
            style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                fontFamily: 'Metamorphous')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: _navigateToNotificationPage,
            tooltip: 'Notifications',
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              "assets/images/al-marhum/islamicbackground.png",
              fit: BoxFit.cover,
            ),
          ),
          if (_isLoggingOut)
            Container(
              color: Colors.black.withOpacity(0.5),
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
                  )),
            )
          else
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: kToolbarHeight +
                            MediaQuery.of(context).padding.top +
                            20),
                    const SizedBox(height: 20),
                    Text(
                      _userName,
                      style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'Metamorphous'),
                      textAlign: TextAlign.center,
                    ),
                    if (_email.isNotEmpty &&
                        _email != "No Email Found" &&
                        _userName != _email &&
                        _userName != "Not Logged In" &&
                        _userName != "Loading...")
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          _email,
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey.shade700),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 30),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12.0,
                      mainAxisSpacing: 12.0,
                      childAspectRatio: 1.3,
                      children: <Widget>[
                        _buildOptionCard(
                          context: context,
                          titleKey: 'myProfile',
                          subtitleKey: 'viewProfile',
                          icon: Icons.person_outline,
                          onTap: _navigateToViewProfile,
                        ),
                        _buildOptionCard(
                          context: context,
                          titleKey: 'password',
                          subtitleKey: 'changePassword',
                          icon: Icons.lock_outline,
                          onTap: _navigateToChangePassword,
                        ),
                        _buildOptionCard(
                          context: context,
                          titleKey: 'Talqin & Du\'a',
                          subtitleKey: 'Islam Practices',
                          icon: Icons.book_outlined,
                          onTap: _navigateToTalqinPractices,
                        ),
                        _buildOptionCard(
                          context: context,
                          titleKey: 'Yaasin Reading',
                          subtitleKey: 'Read Yaasin',
                          icon: Icons.menu_book_outlined,
                          onTap: _navigateToYaasinReading,
                        ),
                        _buildOptionCard(
                          context: context,
                          titleKey: 'settings',
                          subtitleKey: 'changeSettings',
                          icon: Icons.settings_outlined,
                          onTap: _navigateToSettings,
                        ),
                        _buildOptionCard(
                          context: context,
                          titleKey: 'logout',
                          subtitleKey: 'seeYouAgain',
                          icon: Icons.logout,
                          onTap: _showLogoutDialog,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required String titleKey,
    required String subtitleKey,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    const titleStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 17,
      color: Colors.black87,
      fontFamily: 'Metamorphous',
    );
    final subtitleStyle = TextStyle(
      fontSize: 15,
      color: Colors.grey[700],
      fontFamily: 'Metamorphous',
    );

    final String titleText =
        AppLocalizations.get(context, titleKey, fallback: titleKey) ?? titleKey;
    final String subtitleText =
        AppLocalizations.get(context, subtitleKey, fallback: subtitleKey) ??
            subtitleKey;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Card(
        elevation: 1.0,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        color: Colors.yellow.shade100.withOpacity(0.8),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.15,
                child: Icon(
                  icon,
                  size: 110,
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    titleText,
                    style: titleStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitleText,
                    style: subtitleStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}