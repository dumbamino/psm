// lib/localization/app_localizations.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'locale_provider.dart'; // Ensure this path is correct

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': <String, String>{
      //View Profile
        "Account": "Account",
        "MyProfile": "My Profile",
        "editProfile": "Edit Profile",
        "cancel": "Cancel",
        "save": "Save",
        "ok": "OK",
        "placeholderName": "User Name",
        "placeholderEmail": "user@email.com",
        "placeholderAddress": "123 Main Street, City, Country",
        "placeholderPhone": "+1234567890",
        "labelName": "Name",
        "labelEmail": "Email",
        "labelAddress": "Address",
        "labelPhone": "Phone Number",
        "validatorEnterName": "Please enter a name",
        "validatorEnterEmail": "Please enter an email",
        "profileUpdatedTitle": "Profile Updated",
      "profileUpdatedMessage": "Your profile has been updated successfully.",

      // HomeScreen
      'ReadYaasin': 'Surah Yaasin',
      'login': 'Login',
      'register': 'Register',
      'selectLanguage': 'Select Language',

      // SearchScreen
      'searchScreenTitle': 'Search Grave Location',
      'title': 'Search Grave Records',
      'stateHint': 'State',
      'areaHint': 'Area',
      'nameHint': 'Deceased Name',
      'deceasedDodHint': 'Deceased Date of Death (DD/MM/YYYY)',
      'categoryHint': 'Category',
      'lotHint': 'Grave Lot Number',
      'graveAddressHint': 'Grave Address',
      'searchBtn': 'Search Records',
      'searchingBtn': 'Searching...',
      'noResults': 'No matching records found.',
      'resultsFound': 'Results found.',
      'errorEnterCriteria': 'Please enter at least one search criterion.',
      'errorInvalidDateFormat': 'Invalid Date of Death format. Please use DD/MM/YYYY.',
      'errorDuringSearch': 'Error during search',

      // ProfileScreen
      'account': 'Account',
      'password': 'Password',
      'changePassword': 'Change Password',
      'myProfile': 'My Profile',
      'viewProfile': 'View Profile',
      'Talqin & Du\'a': 'Talqin & Du\'a',
      'Islam Practices': 'Islamic Practices',
      'Yaasin Reading': 'Surah Yaasin',
      'Read Yaasin': 'Read',
      'settings': 'Settings',
      'changeSettings': 'Change Language',
      'logout': 'Logout',
      'seeYouAgain': 'See you again',

      // English
      'oldPassword': 'Old Password',
      'newPassword': 'New Password',
      'reenterPassword': 'Re-enter Password',
      'pleaseEnterOldPassword': 'Please enter your old password',
      'passwordMinLength': 'Password must be Alphanumeric',
      'passwordsDoNotMatch': 'Passwords do not match',
      'changePasswordSuccess': 'Password changed successfully!',
      'change Password': 'Change Password',

      // DashboardScreen
      'dashboard':'Dashboard',
      'search': 'Search',
      'profile': 'Profile',
      'welcome': 'Welcome to Al-Marhum',
      'newRecord': 'New Record',
      'myRecords': 'My Records',
    },

    'ms': <String, String>{
      // View Profile
      "Account": "Akaun",
      "MyProfile": "Profil Saya",
      "editProfile": "Tukar Profil",
      "cancel": "Batal",
      "save": "Simpan",
      "ok": "OK",
      "placeholderName": "Nama Pengguna",
      "placeholderEmail": "pengguna@emel.com",
      "placeholderAddress": "123 Jalan Utama, Bandar, Negara",
      "placeholderPhone": "+1234567890",
      "labelName": "Nama",
      "labelEmail": "E-mel",
      "labelAddress": "Alamat",
      "labelPhone": "Nombor Telefon",
      "validatorEnterName": "Sila masukkan nama",
      "validatorEnterEmail": "Sila masukkan e-mel",
      "profileUpdatedTitle": "Profil Dikemaskini",
      "profileUpdatedMessage": "Profil anda telah berjaya dikemaskini.",

      // HomeScreen
      'ReadYaasin': 'Surah Yaasin',
      'login': 'Log Masuk',
      'register': 'Daftar',
      'selectLanguage': 'Pilih Bahasa',

      // SearchScreen
      'searchScreenTitle': 'Cari Lokasi Kubur',
      'title': 'Cari Rekod Kubur',
      'stateHint': 'Negeri',
      'areaHint': 'Kawasan',
      'nameHint': 'Nama Al-Marhum',
      'deceasedDodHint': 'Tarikh Kematian Al-Marhum (HH/BB/TTTT)',
      'categoryHint': 'Kategori ',
      'lotHint': 'Nombor Lot Kubur ',
      'graveAddressHint': 'Alamat Kubur ',
      'searchBtn': 'Cari Rekod',
      'searchingBtn': 'Mencari...',
      'noResults': 'Tiada rekod yang sepadan ditemui.',
      'resultsFound': 'Keputusan ditemui.',
      'errorEnterCriteria': 'Sila masukkan sekurang-kurangnya satu kriteria carian.',
      'errorInvalidDateFormat': 'Format Tarikh Kematian tidak sah. Sila guna HH/BB/TTTT.',
      'errorDuringSearch': 'Masalah semasa mencari',

      // ProfileScreen
      'account': 'Akaun',
      'password': 'Kata Laluan',
      'changePassword': 'Tukar Kata Laluan',
      'myProfile': 'Profil Saya',
      'viewProfile': 'Lihat Profil',
      'Talqin & Du\'a': 'Talqin & Do\'a',
      'Islam Practices': 'Tatacara Islam',
      'Yaasin Reading': 'Surah Yaasin',
      'Read Yaasin': 'Baca',
      'settings': 'Tetapan',
      'changeSettings': 'Tukar Bahasa',
      'logout': 'Log Keluar',
      'seeYouAgain': 'Jumpa lagi',

      // Bahasa Melayu
      'oldPassword': 'Kata Laluan Lama',
      'newPassword': 'Kata Laluan Baharu',
      'reenterPassword': 'Masukkan Semula Kata Laluan',
      'pleaseEnterOldPassword': 'Sila masukkan kata laluan lama anda',
      'passwordMinLength': 'Kata laluan mesti Alphanumerik',
      'passwordsDoNotMatch': 'Kata laluan tidak sepadan',
      'changePasswordSuccess': 'Kata laluan berjaya ditukar!',
      'change Password': 'Tukar Kata Laluan',

      // DashboardScreen
      'dashboard': 'Papan Pemuka',
      'search': 'Cari',
      'profile': 'Profil',
      'welcome': 'Selamat Datang ke Al-Marhum',
      'newRecord': 'Rekod Baharu',
      'myRecords': 'Rekod Simpanan',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? '$key NOT_FOUND_INSTANCE';
  }

  static String getLocalizedValue(String key, Locale targetLocale) {
    return _localizedValues[targetLocale.languageCode]?[key] ?? '$key NOT_FOUND_STATIC';
  }

  static void showLanguageDialog(BuildContext context, void Function(dynamic langCode) onLanguageChange) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final String dialogTitle = AppLocalizations.of(context)?.translate('selectLanguage') ?? 'Select Language';

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(dialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: const Text('English'),
              onTap: () {
                localeProvider.changeLocale(const Locale('en'));
                Navigator.of(dialogContext).pop();
              },
            ),
            ListTile(
              title: const Text('Bahasa Melayu'),
              onTap: () {
                localeProvider.changeLocale(const Locale('ms'));
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  static String? getSync(BuildContext context, String key) {
    final AppLocalizations? localizations = AppLocalizations.of(context);
    if (localizations == null) {
      print('Error: AppLocalizations.of(context) returned null. Key: $key. Ensure MaterialApp.localizationsDelegates and MaterialApp.supportedLocales are correctly set.');
      return null;
    }
    return _localizedValues[localizations.locale.languageCode]?[key];
  }

  static String? get(BuildContext context, String key, {required String fallback}) {
    return getSync(context, key);
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ms'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}