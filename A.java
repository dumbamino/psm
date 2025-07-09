import 'package:flutter/material.dart';
import 'package:psm/login.dart';
import 'package:psm/searchscreen.dart';
import 'package:psm/signup.dart';

class HomeScreen extends StatefulWidget {
  final Function(String) onLanguageChange;

  const HomeScreen({Key? key, required this.onLanguageChange}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Locale _currentLocale = const Locale('en');
  bool _showButtons = false;

  @override
  void initState() {
    super.initState();
    // Delay the appearance of the buttons by 5 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) { // Check if the widget is still in the tree
        setState(() {
          _showButtons = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: _body(context),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.green.shade100, // Set appbar background to white
      elevation: 0,
      title: Center( // Wrap the logo in a Center widget
        child: Image.asset(
          'assets/images/al-marhum/Al-Marhum icon.png', // Replace with your logo's path
          height: 60, // Adjust the height as needed
          fit: BoxFit.contain, // Ensure the logo fits within the specified height
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.language, color: Colors.black),
          onPressed: () => _showLanguageDialog(context),
        ),
      ],
    );
  }

  Widget _body(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("images/islamicbackground.jpg"), // Replace with your image asset
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.getLocalizedValue('greeting', _currentLocale),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Metamorphous', // Use your custom font
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.getLocalizedValue('welcomeMessage', _currentLocale),
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontFamily: 'Metamorphous', // Use your custom font
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            if (_showButtons) // Conditionally show the buttons
              Column(
                children: [
                  _searchButton(context),
                  const SizedBox(height: 20),
                  _navigationButtons(context),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _searchButton(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.search),
      label: Text(
        AppLocalizations.getLocalizedValue('searchGrave', _currentLocale),
        style: const TextStyle(fontFamily: 'Metamorphous'), // Apply font here
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () {
        // Navigate to search page (create this page separately)
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchScreen()),
        );
      },
    );
  }

  Widget _navigationButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _button(
          context,
          title: AppLocalizations.getLocalizedValue('login', _currentLocale),
          icon: Icons.login,
          color: Colors.yellow.shade100,
          fontFamily: 'Metamorphous', //Add Font Here
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          ),
        ),
        const SizedBox(width: 10),
        _button(
          context,
          title: AppLocalizations.getLocalizedValue('register', _currentLocale),
          icon: Icons.person_add,
          color: Colors.yellow.shade100,
          fontFamily: 'Metamorphous',  //Add Font Here
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SignUp()),
          ),
        ),
      ],
    );
  }

  Widget _button(BuildContext context,
      {required String title, required IconData icon, required Color color, required Function() onTap, required String fontFamily}) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 24),
      label: Text(
        title,
        style: TextStyle(fontFamily: fontFamily),  // Apply font here
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onTap,
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.getLocalizedValue('selectLanguage', _currentLocale),
            style: const TextStyle(fontFamily: 'Metamorphous'), // Apply font here
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English', style: TextStyle(fontFamily: 'Metamorphous')), // Apply font here
                onTap: () {
                  _changeLanguage('en');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Bahasa Melayu',  style: TextStyle(fontFamily: 'Metamorphous')), // Apply font here
                onTap: () {
                  _changeLanguage('ms');
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _changeLanguage(String languageCode) {
    setState(() {
      _currentLocale = Locale(languageCode);
    });
    widget.onLanguageChange(languageCode);
  }
}

class AppLocalizations {
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'greeting': 'Hello',
      'welcomeMessage': 'Welcome to eNisan',
      'appName': 'eNisan',
      'newReservation': 'New Reservation',
      'myReservations': 'My Reservations',
      'searchGrave': 'Search Grave',
      'login': 'Log In',
      'register': 'Register',
      'selectLanguage': 'Select Language',
    },
    'ms': {
      'greeting': 'Salam Sejahtera',
      'welcomeMessage': 'Selamat datang ke eNisan',
      'appName': 'eNisan',
      'newReservation': 'Tempahan Baru',
      'myReservations': 'Tempahan Saya',
      'searchGrave': 'Cari Kubur',
      'login': 'Log Masuk',
      'register': 'Daftar Akaun',
      'selectLanguage': 'Pilih Bahasa',
    },
  };

  static String getLocalizedValue(String key, Locale locale) {
    return _localizedValues[locale.languageCode]?[key] ?? 'default_value';
  }
}