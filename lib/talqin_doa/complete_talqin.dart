// lib/screens/complete_talqin_screen.dart
import 'package:flutter/material.dart';
import '../localization/app_localizations.dart'; // Assuming this path is correct

class CompleteTalqinScreen extends StatefulWidget {
  const CompleteTalqinScreen({Key? key}) : super(key: key);

  @override
  State<CompleteTalqinScreen> createState() => _CompleteTalqinScreenState();
}

class _CompleteTalqinScreenState extends State<CompleteTalqinScreen> {
  // --- CHANGE THIS LIST ---
  // Replace these example paths with the actual paths to your Talqin images.
  final List<String> talqinPages = const [
    "assets/images/talqin/Talkin-1.png",
    "assets/images/talqin/Talkin-2.png",
    "assets/images/talqin/Talkin-3.png",
    "assets/images/talqin/Talkin-4.png",
    // Add as many pages as you need
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(AppLocalizations.get(context, 'completeTalqin', fallback: 'Complete Talqin') ?? 'Complete Talqin'),
        backgroundColor: Colors.green[100],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Metamorphous'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/al-marhum/islamicbackground.png', // Change to your background image path
            fit: BoxFit.cover,
          ),
          PageView.builder(
        scrollDirection: Axis.vertical,
        physics: const PageScrollPhysics(),
        itemCount: talqinPages.length,
        itemBuilder: (context, index) {
          final imagePath = talqinPages[index];
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: child,
              );
            },
            child: Image.asset(
              imagePath,
                  fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Unable to load asset:\n$imagePath\n\n- Check the path in your code.\n- Ensure the file exists in that exact folder.\n- Verify the folder is listed in pubspec.yaml.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
        ],
      ),
    );
  }
}