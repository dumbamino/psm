// lib/screens/dashboardscreen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';

import 'package:psm/screens/MyRecords.dart';
import 'package:psm/screens/NewRecord.dart';
import 'package:psm/localization/locale_provider.dart';
import 'package:psm/localization/app_localizations.dart';

import '../login.dart';
import '../profile/profilescreen.dart';
import '../searchscreen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final PageController _pageController = PageController(initialPage: 1);
  int _selectedIndex = 1;

  // REMOVED: late List<Widget> _pages;
  // REMOVED: bool _isPagesInitialized = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;

    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
        if (_currentUser == null) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
          );
        }
      }
    });
  }

  // REMOVED: The entire didChangeDependencies method is no longer needed for this.

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If user is null, show a loading indicator until the auth listener redirects.
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // **SOLUTION**: Define the pages list here, inside the build method.
    // This ensures they are recreated with the latest context on every rebuild.
    final List<Widget> pages = [
      SearchScreen(locale: Provider.of<LocaleProvider>(context).currentLocale!),
      _buildDashboardContent(context),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          if (_selectedIndex != index) {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        children: pages, // Use the fresh list of pages
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 60.0,
        color: Colors.yellow.shade50,
        buttonBackgroundColor: Colors.green.shade100,
        backgroundColor: Colors.green.shade500,
        animationDuration: const Duration(milliseconds: 350),
        animationCurve: Curves.easeOutQuint,
        onTap: _onItemTapped,
        items: [
          CurvedNavigationBarItem(
            child: const Icon(Icons.search, size: 30, color: Colors.black),
            label: AppLocalizations.getSync(context, 'search') ?? 'Search',
            labelStyle: const TextStyle(
                color: Colors.black, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          CurvedNavigationBarItem(
            child: const Icon(Icons.home_filled, size: 30, color: Colors.black),
            label: AppLocalizations.getSync(context, 'dashboard') ?? 'Dashboard',
            labelStyle: const TextStyle(
                color: Colors.black, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          CurvedNavigationBarItem(
            child: const Icon(Icons.person, size: 30, color: Colors.black),
            label: AppLocalizations.getSync(context, 'profile') ?? 'Profile',
            labelStyle: const TextStyle(
                color: Colors.black, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/al-marhum/islamicbackground.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                // This line will now work correctly because this widget is rebuilt
                // with the new context every time the language changes.
                AppLocalizations.getSync(context, 'welcome') ??
                    'Welcome to Al-Marhum',
                style: TextStyle(
                  fontFamily: 'Metamorphous',
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  shadows: [
                    Shadow(
                        offset: const Offset(1.0, 1.0),
                        blurRadius: 2.0,
                        color: Colors.black.withOpacity(0.7)),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _DashboardCard(
                      icon: Icons.add_circle_outline,
                      label: AppLocalizations.getSync(context, 'newRecords') ??
                          'New Record',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NewRecordScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _DashboardCard(
                      icon: Icons.list_alt,
                      label: AppLocalizations.getSync(context, 'myRecords') ??
                          'My Records',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyRecordsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        color: Colors.green.shade600.withOpacity(0.85),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Metamorphous',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}