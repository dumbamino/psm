// lib/screens/main_menu_screen.dart

import 'package:flutter/material.dart';
import 'complete_talqin.dart';
import 'doa_men.dart';
import 'doa_women.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  // A reusable navigation method to keep the code DRY (Don't Repeat Yourself)
  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define the button text style once and reuse it
    const buttonTextStyle = TextStyle(
      fontFamily: 'Metamorphous',
      fontSize: 18, // Adjusted for better fit
      color: Colors.black,
      fontWeight: FontWeight.bold,
    );

    // This is a cleaner, data-driven way to build the menu
    final List<Map<String, dynamic>> menuItems = [
      {
        'label': 'Complete Talqin',
        'screen': const CompleteTalqinScreen(),
      },
      {
        'label': 'Do\'a for Men Deceased',
        'screen': const DoaForMenScreen(),
      },
      {
        'label': 'Do\'a for Women Deceased',
        'screen': const DoaForWomenScreen(),
      },
    ];

    return Scaffold(
      // This is crucial for a transparent AppBar to work correctly
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Talqin & Do'a",
          style: TextStyle(fontFamily: 'Metamorphous', color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black), // Makes back arrow black
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/al-marhum/islamicbackground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: kToolbarHeight), // Space for the AppBar
                Image.asset(
                  'assets/images/al-marhum/al-marhum_caligraphy.png',
                  height: 150,
                ),
                const SizedBox(height: 100),

                // Generate buttons from the list of menu items
                ...menuItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _MenuButton(
                      label: item['label'],
                      onPressed: () => _navigateToScreen(context, item['screen']),
                      style: buttonTextStyle,
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ** REPAIRED BUTTON WIDGET **
class _MenuButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final TextStyle style; // The style is now used correctly

  const _MenuButton({
    Key? key,
    required this.label,
    required this.onPressed,
    required this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.yellow.shade100.withOpacity(0.9), // Matching profile screen
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      // The style is applied directly to the Text widget for guaranteed results
      child: Text(label, style: style),
    );
  }
}