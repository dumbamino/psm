import 'package:flutter/material.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';

// Import the actual screen widgets
import 'package:psm/screens/dashboardscreen.dart';
import 'package:psm/searchscreen.dart';
import 'package:psm/profile/profilescreen.dart';
import 'package:psm/localization/app_localizations.dart'; // For labels

class NavBarPage extends StatefulWidget {
  const NavBarPage({super.key});

  @override
  State<NavBarPage> createState() => _NavBarPageState();
}

class _NavBarPageState extends State<NavBarPage> {
  final PageController _pageController = PageController(initialPage: 1);
  int _selectedIndex = 1;

  // The list of pages to be displayed by the PageView
  // Notice we are now using the actual screen widgets
  final List<Widget> _pages = [
    const SearchScreen(locale: Locale('en')), // Provide a default or get from provider
    const DashboardScreen(), // This is the simplified DashboardScreen
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return; // Avoid unnecessary rebuilds

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
    return Scaffold(
      // Use SafeArea to prevent the system navigation bar from blocking your UI
      body: SafeArea(
        top: false, // Important for pages with backgrounds behind the app bar
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: _pages,
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 65.0, // A bit more height for comfort
        color: Colors.green.shade700, // Example: A darker green background
        buttonBackgroundColor: Colors.green.shade100,
        backgroundColor: Colors.transparent, // Make it transparent to see the page behind

        animationDuration: const Duration(milliseconds: 350),
        animationCurve: Curves.easeOutQuint,
        onTap: _onItemTapped,
        items: [
          CurvedNavigationBarItem(
            // *** YOU CAN NOW CHANGE THE ICON COLOR HERE ***
            child: Icon(Icons.search, size: 30, color: _selectedIndex == 0 ? Colors.green.shade900 : Colors.white),
            label: AppLocalizations.getSync(context, 'search') ?? 'Search',
            labelStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          CurvedNavigationBarItem(
            // *** AND HERE ***
            child: Icon(Icons.home_filled, size: 30, color: _selectedIndex == 1 ? Colors.green.shade900 : Colors.white),
            label: AppLocalizations.getSync(context, 'dashboard') ?? 'Dashboard',
            labelStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          CurvedNavigationBarItem(
            // *** AND HERE ***
            child: Icon(Icons.person, size: 30, color: _selectedIndex == 2 ? Colors.green.shade900 : Colors.white),
            label: AppLocalizations.getSync(context, 'profile') ?? 'Profile',
            labelStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}