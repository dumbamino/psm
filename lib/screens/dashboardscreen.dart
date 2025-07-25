import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:psm/screens/MyRecords.dart';
import 'package:psm/screens/NewRecord.dart';
import 'package:psm/localization/locale_provider.dart';
import 'package:psm/localization/app_localizations.dart';

import '../service/authWrapper.dart';
import '../profile/profilescreen.dart';
import '../searchscreen.dart';

// NEW: A dedicated class for a modern and cohesive color palette
class AppColors {
  static const Color primary = Color(0xFF004D40); // Deep Teal
  static const Color accent = Color(0xFFD4AF37); // Gold
  static const Color background = Color(0xFFF1F8E9); // Light Greenish White
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final PageController _pageController = PageController(initialPage: 1);
  int _selectedIndex = 1;
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
          // If user logs out, redirect to auth wrapper
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const AuthWrapper()),
                (route) => false,
          );
        }
      }
    });
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

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
        children: pages,
      ),
      // UPGRADE: Replaced CurvedNavigationBar with the cleaner Material 3 NavigationBar
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primary.withOpacity(0.1),
        height: 70,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        animationDuration: const Duration(milliseconds: 1000),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.search_outlined, color: AppColors.primary),
            selectedIcon: const Icon(Icons.search, color: AppColors.primary),
            label: AppLocalizations.getSync(context, 'search') ?? 'Search',
          ),
          NavigationDestination(
            icon: const Icon(Icons.home_outlined, color: AppColors.primary),
            selectedIcon: const Icon(Icons.home, color: AppColors.primary),
            label: AppLocalizations.getSync(context, 'dashboard') ?? 'Dashboard',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline, color: AppColors.primary),
            selectedIcon: const Icon(Icons.person, color: AppColors.primary),
            label: AppLocalizations.getSync(context, 'profile') ?? 'Profile',
          ),
        ],
      ),
    );
  }

  // --- UPGRADED: Dashboard Content Widget ---
  Widget _buildDashboardContent(BuildContext context) {
    // A friendly greeting for the user
    final String greeting = AppLocalizations.getSync(context, 'greeting') ?? 'Assalamu\'alaikum';
    final String userName = _currentUser?.displayName ?? '';

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/al-marhum/islamicbackground.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        // UPGRADE: Gradient overlay to ensure text readability over the background image
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.5),
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(24.0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // UPGRADE: Personalized greeting
                      Text(
                        greeting,
                        style: const TextStyle(
                          fontFamily: 'Metamorphous',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        userName,
                        style: TextStyle(
                          fontSize: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // UPGRADE: Using the new, redesigned dashboard cards
                      _DashboardCard(
                        icon: Icons.add_circle_outline,
                        title: AppLocalizations.getSync(context, 'newRecords') ?? 'New Record',
                        subtitle: AppLocalizations.getSync(context, 'newRecordsSub') ?? 'Create a new entry for the deceased',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NewRecordScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _DashboardCard(
                        icon: Icons.list_alt_outlined,
                        title: AppLocalizations.getSync(context, 'myRecords') ?? 'My Records',
                        subtitle: AppLocalizations.getSync(context, 'myRecordsSub') ?? 'View and manage all your entries',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const MyRecordsScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- UPGRADED: A completely redesigned, more visually appealing card ---
class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // UPGRADE: Softer, more modern shadow
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: AppColors.accent.withOpacity(0.1),
            highlightColor: AppColors.accent.withOpacity(0.05),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                // UPGRADE: Subtle gradient background
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.8),
                    AppColors.primary.withOpacity(0.95),
                  ],
                ),
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
              ),
              child: Stack(
                children: [
                  // UPGRADE: Decorative background icon for depth
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Icon(
                      icon,
                      size: 120,
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(icon, size: 40, color: AppColors.accent),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Metamorphous',
                              ),
                            ),
                            const SizedBox(height: 4),
                            // UPGRADE: Added a subtitle for more context
                            Text(
                              subtitle,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}