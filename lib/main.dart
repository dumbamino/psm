// lib/main.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:psm/pages/splashpage.dart';
// We no longer need to import HomeScreen here directly.
// import 'package:psm/screens/homescreen.dart';
import 'package:psm/service/auth.dart' as app_auth_service;
import 'package:psm/service/authWrapper.dart';
import 'package:psm/service/firebase_options.dart';
import 'package:psm/service/firestore.dart' as app_record_service;
import 'package:psm/localization/locale_provider.dart';
import 'localization/app_localizations.dart';


// Import the new notification service
import 'package:psm/widgets/notifications.dart';

// Import your AuthWrapper



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  await NotificationService.initializeNotification();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<FirebaseAuth>(create: (_) => FirebaseAuth.instance),
        Provider<FirebaseFirestore>(create: (_) => FirebaseFirestore.instance),
        ChangeNotifierProvider<LocaleProvider>(create: (_) => LocaleProvider()..loadLocale()),
        Provider<app_auth_service.AuthService>(
          create: (context) => app_auth_service.AuthService(),
        ),
        Provider<app_record_service.RecordFirestoreService>(
          create: (context) => app_record_service.RecordFirestoreService(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // Listen for notification actions
    NotificationService.configureListeners();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        // This function can be removed from here as AuthWrapper will handle it
        // void handleLanguageChange(dynamic langCode) { ... }

        return MaterialApp(
          title: 'Al-Marhum', // I restored your app title
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.teal,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          locale: localeProvider.currentLocale,
          supportedLocales: const [Locale('en', ''), Locale('ms', '')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale == null) return supportedLocales.first;
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },
          // --- THIS IS THE ONLY LINE THAT NEEDED TO BE CHANGED ---
          // After the splash screen is done, go to the AuthWrapper.
          // The AuthWrapper will then decide which screen to show.
          home: SplashScreen(
            onInitializationComplete: () => const AuthWrapper(),
          ),
        );
      },
    );
  }
}