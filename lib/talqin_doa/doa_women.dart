import 'package:flutter/material.dart';
import '../localization/app_localizations.dart'; // Make sure this path is correct

class DoaForWomenScreen extends StatefulWidget {
  const DoaForWomenScreen({Key? key}) : super(key: key);

  @override
  State<DoaForWomenScreen> createState() => _DoaForWomenScreenState();
}

class _DoaForWomenScreenState extends State<DoaForWomenScreen> {
  // --- CHANGE THIS LIST ---
  // The list of images for the women's prayer.
  // Replace these with the actual file paths for your images.
  final List<String> doaPages = const [
    "assets/images/talqin/doawomen3.png",
    "assets/images/talqin/doawomen4.png",
    // Add more images here if you have them
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(AppLocalizations.get(context, 'doaForWomen', fallback: 'Doa Selepas Talqin (Perempuan)') ?? 'Doa Selepas Talqin (Perempuan)'),
        backgroundColor: Colors.green[100],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Metamorphous'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/al-marhum/islamicbackground.png', // Replace with your background image path
            fit: BoxFit.cover,
          ),
          PageView.builder(
        scrollDirection: Axis.vertical,
        physics: const PageScrollPhysics(),
        itemCount: doaPages.length,
        itemBuilder: (context, index) {
          final imagePath = doaPages[index];
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