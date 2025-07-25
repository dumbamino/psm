import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemChrome
import '../localization/app_localizations.dart'; // Make sure this path is correct

class DoaForWomenScreen extends StatefulWidget {
  const DoaForWomenScreen({Key? key}) : super(key: key);

  @override
  State<DoaForWomenScreen> createState() => _DoaForWomenScreenState();
}

class _DoaForWomenScreenState extends State<DoaForWomenScreen> with TickerProviderStateMixin {
  // --- Configuration ---
  // The list of images for the women's prayer.
  final List<String> doaPages = const [
    "assets/images/talqin/doawomen3.png",
    "assets/images/talqin/doawomen4.png",
    // Add more images here if you have them
  ];
  static const double minScale = 1.0;
  static const double maxScale = 4.0;

  // --- State ---
  late final List<TransformationController> _transformationControllers;
  late final PageController _pageController;
  int _currentPage = 0;
  bool _isInteracting = false;
  bool _isUiVisible = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _transformationControllers = List.generate(doaPages.length, (_) => TransformationController());

    _pageController.addListener(() {
      final newPage = _pageController.page?.round() ?? 0;
      if (newPage != _currentPage) {
        _transformationControllers[_currentPage].value = Matrix4.identity();
        setState(() => _currentPage = newPage);
      }
    });

    _startHideControlsTimer();
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _transformationControllers) {
      controller.dispose();
    }
    _hideControlsTimer?.cancel();
    // Ensure system UI is visible when leaving the screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  // --- UI Visibility Logic ---

  void _toggleUiVisibility() {
    setState(() {
      _isUiVisible = !_isUiVisible;
      if (_isUiVisible) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        _startHideControlsTimer();
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        _hideControlsTimer?.cancel();
      }
    });
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (_isUiVisible) {
        _toggleUiVisibility();
      }
    });
  }

  void _resetHideControlsTimer() {
    if (_isUiVisible) {
      _startHideControlsTimer();
    }
  }

  // --- Zoom Logic ---

  void _zoom(double zoomFactor) {
    final controller = _transformationControllers[_currentPage];
    final currentScale = controller.value.getMaxScaleOnAxis();
    final newScale = (currentScale * zoomFactor).clamp(minScale, maxScale);
    _animateScale(controller, newScale);
    _resetHideControlsTimer();
  }

  void _resetZoom() {
    final controller = _transformationControllers[_currentPage];
    _animateScale(controller, minScale);
    _resetHideControlsTimer();
  }

  void _animateScale(TransformationController controller, double newScale) {
    final currentMatrix = controller.value;
    final animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));

    final sceneSize = context.size ?? const Size(400, 800);
    final focalPoint = sceneSize.center(Offset.zero);

    final animation = Matrix4Tween(
      begin: currentMatrix,
      end: Matrix4.identity()
        ..translate(focalPoint.dx, focalPoint.dy)
        ..scale(newScale)
        ..translate(-focalPoint.dx, -focalPoint.dy),
    ).animate(CurvedAnimation(parent: animationController, curve: Curves.easeOut));

    animation.addListener(() => controller.value = animation.value);
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) animationController.dispose();
    });
    animationController.forward();
  }

  // --- Build Method ---

  @override
  Widget build(BuildContext context) {
    const paperColor = Color(0xFFFAF8F5);
    const primaryColor = Color(0xFF00695C); // A deep, elegant teal

    return Scaffold(
      backgroundColor: paperColor,
      body: GestureDetector(
        onTap: _toggleUiVisibility,
        child: Stack(
          children: [
            // --- Page Viewer ---
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              physics: _isInteracting ? const NeverScrollableScrollPhysics() : const PageScrollPhysics(),
              itemCount: doaPages.length,
              onPageChanged: (page) => _resetHideControlsTimer(),
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  transformationController: _transformationControllers[index],
                  minScale: minScale,
                  maxScale: maxScale,
                  onInteractionStart: (_) {
                    setState(() => _isInteracting = true);
                    _resetHideControlsTimer();
                  },
                  onInteractionEnd: (_) => setState(() => _isInteracting = false),
                  child: Image.asset(
                    doaPages[index],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Unable to load asset:\n${doaPages[index]}\n\n- Check the path in your code.\n- Ensure the file exists in that exact folder.\n- Verify the folder is listed in pubspec.yaml.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            // --- UI Overlay ---
            _buildAppBar(primaryColor),
            _buildPageIndicator(),
            _buildZoomControls(primaryColor),
          ],
        ),
      ),
    );
  }

  // --- UI Components ---

  Widget _buildAppBar(Color primaryColor) {
    return AnimatedOpacity(
      opacity: _isUiVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      child: IgnorePointer(
        ignoring: !_isUiVisible,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withOpacity(0.5), Colors.transparent],
            ),
          ),
          child: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(AppLocalizations.get(context, 'doaForWomen', fallback: 'Doa Selepas Talqin (Perempuan)') ?? 'Doa Selepas Talqin (Perempuan)'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.white,
            titleTextStyle: const TextStyle(
                fontFamily: 'Metamorphous',
                fontWeight: FontWeight.bold,
                fontSize: 20,
                shadows: [Shadow(blurRadius: 2, color: Colors.black38)]),
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return AnimatedOpacity(
      opacity: _isUiVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "Page ${_currentPage + 1} of ${doaPages.length}",
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ),
    );
  }

  Widget _buildZoomControls(Color primaryColor) {
    return AnimatedOpacity(
      opacity: _isUiVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.add, color: primaryColor),
                onPressed: () => _zoom(1.5),
                tooltip: 'Zoom In',
              ),
              IconButton(
                icon: Icon(Icons.remove, color: primaryColor),
                onPressed: () => _zoom(0.75),
                tooltip: 'Zoom Out',
              ),
              IconButton(
                icon: Icon(Icons.fullscreen, color: primaryColor),
                onPressed: _resetZoom,
                tooltip: 'Reset Zoom',
              ),
            ],
          ),
        ),
      ),
    );
  }
}