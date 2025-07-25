import 'package:flutter/material.dart';
import '../localization/app_localizations.dart'; // Make sure this path is correct

class DoaForMenScreen extends StatefulWidget {
  const DoaForMenScreen({Key? key}) : super(key: key);

  @override
  State<DoaForMenScreen> createState() => _DoaForMenScreenState();
}

class _DoaForMenScreenState extends State<DoaForMenScreen> {
  // The list of images for this specific prayer
  final List<String> doaPages = const [
    "assets/images/talqin/lelaki1.png",
    "assets/images/talqin/lelaki2.png",
  ];

  bool _isZooming = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(AppLocalizations.get(context, 'doaForMen', fallback: 'Doa Selepas Talqin (Lelaki)') ?? 'Doa Selepas Talqin (Lelaki)'),
        backgroundColor: Colors.green[100],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Metamorphous'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/al-marhum/islamicbackground.png', // Set your custom background image path here
            fit: BoxFit.cover,
          ),
          PageView.builder(
        scrollDirection: Axis.vertical,
        physics: _isZooming
            ? const NeverScrollableScrollPhysics()
            : const PageScrollPhysics(),
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
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 1.0,
              maxScale: 4.0,
              onInteractionStart: (_) => setState(() => _isZooming = true),
              onInteractionEnd: (_) => setState(() => _isZooming = false),
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
            ),
          );
        },
      ),
        ],
      ),
    );
  }
}