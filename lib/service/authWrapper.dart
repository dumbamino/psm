// lib/service/auth_wrapper.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:psm/screens/homescreen.dart';
import 'package:psm/screens/dashboardscreen.dart';
import 'package:psm/localization/locale_provider.dart';

/// AuthWrapper acts as the main gatekeeper for the app.
///
/// It listens to the Firebase authentication state and shows the appropriate
/// screen:
/// - [DashboardScreen] if the user is logged in.
/// - [HomeScreen] (which contains login options) if the user is logged out.
///
/// This single point of control is why you don't need to manually navigate
/// after logging out; this widget handles it automatically.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  // --- HELPER METHOD MOVED OUTSIDE OF BUILD ---
  // This is more efficient as the function is not recreated on every build.
  // It now takes `context` as a parameter.
  void _handleLanguageChange(BuildContext context, dynamic langCode) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    if (langCode is Locale) {
      localeProvider.setLocale(langCode);
    } else if (langCode is String) {
      localeProvider.setLocale(Locale(langCode));
    }
    print("[AuthWrapper] Language change handled for code: $langCode");
  }

  @override
  Widget build(BuildContext context) {
    print("[AuthWrapper] Building AuthWrapper widget...");

    return StreamBuilder<User?>(
      // This stream is the single source of truth for auth state
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        print("[AuthWrapper] StreamBuilder triggered. ConnectionState: ${snapshot.connectionState}");

        // While waiting for the initial auth state, show a loading indicator.
        if (snapshot.connectionState == ConnectionState.waiting) {
          print("[AuthWrapper] Auth state is WAITING. Showing loading indicator.");
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(key: Key("AuthWrapperLoadingIndicator"))),
          );
        }

        // If the stream itself has an error (e.g., network issue).
        if (snapshot.hasError) {
          print("[AuthWrapper] Auth stream has an ERROR: ${snapshot.error}");
          return Scaffold(
            body: Center(child: Text("Authentication Error: ${snapshot.error}")),
          );
        }

        // --- User is LOGGED IN ---
        if (snapshot.hasData) {
          print("[AuthWrapper] User IS LOGGED IN. UID: ${snapshot.data!.uid}. Showing DashboardScreen.");
          // The user is authenticated, so we show the main part of the app.
          return const DashboardScreen();
        }
        // --- User is LOGGED OUT ---
        else {
          print("[AuthWrapper] User is NOT LOGGED IN. Showing HomeScreen.");
          // The user is not authenticated, so we show the public home/login screen.
          // We pass our helper method to handle language changes from that screen.
          return HomeScreen(onLanguageChange: (code) => _handleLanguageChange(context, code));
        }
      },
    );
  }
}
