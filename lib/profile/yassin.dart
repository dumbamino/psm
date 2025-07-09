import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';

// 1. Converted the widget to a StatefulWidget
class YaasinReadingScreen extends StatefulWidget {
  const YaasinReadingScreen({Key? key}) : super(key: key);

  @override
  State<YaasinReadingScreen> createState() => _YaasinReadingScreenState();
}

class _YaasinReadingScreenState extends State<YaasinReadingScreen> {
  // Moved the list of pages into the state class
  final List<String> yaasinPages = const [
    "assets/images/yaasin/Surat Yasin - Sarkub_002.png",
    "assets/images/yaasin/Surat Yasin - Sarkub_003.png",
    "assets/images/yaasin/Surat Yasin - Sarkub_004.png",
    "assets/images/yaasin/Surat Yasin - Sarkub_005.png",
    "assets/images/yaasin/Surat Yasin - Sarkub_006.png",
    "assets/images/yaasin/Surat Yasin - Sarkub_007.png",
  ];

  // 2. Added a state variable to control PageView scrolling
  // Removed _isZooming state variable
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(AppLocalizations.get(context, 'yaasinReading', fallback: 'Yaasin Reading') ?? 'Yaasin Reading'),
        backgroundColor: Colors.green[100],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Metamorphous'),
      ),
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        // Removed conditional physics, always allow scrolling
        physics: const PageScrollPhysics(),
        itemCount: yaasinPages.length,
        itemBuilder: (context, index) {
          final imagePath = yaasinPages[index];
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
    );
  }
}