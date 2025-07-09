// lib/login.dart
import 'package:flutter/material.dart';
import 'package:psm/screens/dashboardscreen.dart'; // For navigation after successful login
import 'package:psm/service/auth.dart';         // Your AuthService
import 'package:psm/signup.dart';             // For navigation to SignUpPage
import 'package:psm/forgot_password.dart';     // For navigation to ForgotPassword page
// Assuming AppLocalizations is used for text, if not, you can remove this and use hardcoded strings
import 'package:psm/localization/app_localizations.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controller for the "Username" field (which maps to fullName in the backend)
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService(); // Instance of your AuthService

  bool _isLoading = false;
  bool _isPasswordObscured = true;

  Future<void> _login(BuildContext context) async {
    // Get the value from the "Username" field, which is treated as a fullName
    final String enteredUsernameAsFullName = usernameController.text.trim();
    final String password = passwordController.text.trim(); // Also trim password

    // Basic validation
    if (enteredUsernameAsFullName.isEmpty || password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.get(context, 'username_password_required', fallback: 'Username and Password are required.') ?? 'Username and Password are required.'
            ),
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print("LoginPage: Calling AuthService.signInWithFullNameAndPassword for username (as fullName): '$enteredUsernameAsFullName'");
      // Call the primary method from AuthService
      await _authService.signInWithFullNameAndPassword(
        fullName: enteredUsernameAsFullName,
        password: password,
      );

      // If signInWithFullNameAndPassword completes without throwing an error, login was successful
      if (mounted) {
        print("LoginPage: Login successful, navigating to DashboardScreen.");
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
              (Route<dynamic> route) => false, // Remove all previous routes from the stack
        );
      }
    } catch (e) {
      print("LoginPage: Login failed. Error: ${e.toString()}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // Display the error message from AuthService (which should be user-friendly)
            content: Text(e.toString().replaceFirst("Exception: ", "")),
            backgroundColor: Colors.grey.shade800, // Dark background for better visibility
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Using AppLocalizations for text if available, otherwise fallback
    final String loginStr = AppLocalizations.get(context, 'login', fallback: 'Login') ?? 'Login';
    final String welcomeBackStr = AppLocalizations.get(context, 'welcome_back', fallback: 'Welcome Back') ?? 'Welcome Back';
    final String usernameStr = AppLocalizations.get(context, 'username', fallback: 'Username') ?? 'Username';
    final String passwordStr = AppLocalizations.get(context, 'password', fallback: 'Password') ?? 'Password';
    final String forgotPasswordStr = AppLocalizations.get(context, 'forgot_password_prompt', fallback: 'Forgot Password?') ?? 'Forgot Password?';
    final String noAccountStr = AppLocalizations.get(context, 'dont_have_account', fallback: "Don't have an account?") ?? "Don't have an account?";
    final String signUpStr = AppLocalizations.get(context, 'sign_up', fallback: 'Sign Up') ?? 'Sign Up';


    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            // Navigate back to the previous screen (likely HomeScreen)
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          loginStr,
          style: const TextStyle(color: Colors.black87, fontFamily: 'Metamorphous'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/al-marhum/islamicbackground.png"), // Ensure this asset exists
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/al-marhum/Al-Marhum icon.png', // Ensure this asset exists
                  height: 120,
                ),
                const SizedBox(height: 30),
                Text(
                  welcomeBackStr,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Metamorphous',
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 30),
                // Username (fullName) TextField
                TextField(
                  controller: usernameController,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    labelText: usernameStr,
                    labelStyle: TextStyle(color: Colors.green.shade700, fontFamily: 'Metamorphous'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.green.shade600),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.green.shade800, width: 2),
                    ),
                    prefixIcon: Icon(Icons.person_outline, color: Colors.green.shade700),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                  ),
                  keyboardType: TextInputType.text, // Appropriate for names/usernames
                ),
                const SizedBox(height: 16),
                // Password TextField
                TextField(
                  controller: passwordController,
                  obscureText: _isPasswordObscured,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    labelText: passwordStr,
                    labelStyle: TextStyle(color: Colors.green.shade700, fontFamily: 'Metamorphous'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.green.shade600),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.green.shade800, width: 2),
                    ),
                    prefixIcon: Icon(Icons.lock_outline, color: Colors.green.shade700),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.green.shade700,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordObscured = !_isPasswordObscured;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                  ),
                ),
                // Forgot Password
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, right: 4.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ForgotPassword()),
                        );
                      },
                      child: Text(
                        forgotPasswordStr,
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontFamily: 'Metamorphous',
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Login Button
                _isLoading
                    ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                )
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'Metamorphous',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () => _login(context), // Call the _login method
                  child: Text(loginStr),
                ),
                const SizedBox(height: 20),
                // Divider for OR
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.green.shade700)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'OR',
                        style: TextStyle(fontFamily: 'Metamorphous', color: Colors.green.shade800),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.green.shade700)),
                  ],
                ),
                const SizedBox(height: 20),
                // Google Sign-In Button
                ElevatedButton.icon(
                  icon: Image.asset(
                    'assets/images/al-marhum/google icon.png',
                    height: 24,
                    width: 24,
                  ),
                  label: const Text(
                    'Sign In with Google',
                    style: TextStyle(fontFamily: 'Metamorphous', fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      minimumSize: const Size(double.infinity, 50),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: BorderSide(color: Colors.grey.shade300)
                  ),
                  onPressed: _isLoading
                      ? null
                      : () async {
                    setState(() {
                      _isLoading = true;
                    });
                    try {
                      await _authService.signInWithGoogle(context);
                      if (mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const DashboardScreen()),
                              (Route<dynamic> route) => false,
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Google Sign-In Error: ${e.toString()}'),
                            backgroundColor: Colors.grey.shade800,
                          ),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  },
                ),
                const SizedBox(height: 20),
                // Sign Up Navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      noAccountStr,
                      style: TextStyle(
                        color: Colors.black87,
                        fontFamily: 'Metamorphous',
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                        // Replace LoginPage with SignUpPage so user can't go back to login
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const SignUpPage()),
                        );
                      },
                      child: Text(
                        signUpStr,
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontFamily: 'Metamorphous',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}