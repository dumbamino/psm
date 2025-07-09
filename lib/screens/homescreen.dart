// lib/screens/homescreen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:psm/login.dart'; // Ensure correct path
import 'package:psm/signup.dart'; // Ensure correct path

import 'package:psm/localization/locale_provider.dart';
import 'package:psm/localization/app_localizations.dart';
import 'package:psm/profile/yassin.dart'; // Ensure correct path

class HomeScreen extends StatefulWidget {
  final void Function(dynamic langCode) onLanguageChange;

  const HomeScreen({Key? key, required this.onLanguageChange}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: _buildMainContent(context),
    );
  }
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.language, color: Colors.black),
          onPressed: () => AppLocalizations.showLanguageDialog(context, widget.onLanguageChange),
        ),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/al-marhum/islamicbackground.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Image.asset(
              'assets/images/al-marhum/Al-Marhum icon.png',
              height: 300,
            ),
            const SizedBox(height: 30),
            _buildYaasinButton(context),
            const SizedBox(height: 20),
            _buildLoginRegisterButtons(context), // This contains the login button
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildYaasinButton(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.menu_book_outlined, color: Colors.white),
      label: Text(
        AppLocalizations.get(context, 'ReadYaasin', fallback: 'Read Yaasin') ?? 'Read Yaasin',
        style: const TextStyle(
          fontFamily: 'Metamorphous',
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 16),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const YaasinReadingScreen()),
        );
      },
    );
  }

  Widget _buildLoginRegisterButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildButton(
          title: AppLocalizations.get(context, 'login', fallback: 'Login') ?? 'Login',
          icon: Icons.login,
          color: Colors.yellow.shade100,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())),
        ),
        const SizedBox(width: 10),
        _buildButton(
          title: AppLocalizations.get(context, 'register', fallback: 'Register') ?? 'Register',
          icon: Icons.person_add,
          color: Colors.yellow.shade100,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpPage())),
        ),
      ],
    );
  }

  Widget _buildButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 20, color: Colors.black),
      label: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Metamorphous',
          fontSize: 14,
          color: Colors.black,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onTap,
    );
  }
}