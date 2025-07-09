// lib/signup.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:psm/screens/homescreen.dart';
import 'login.dart'; // Path to LoginPage

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email'],
  // forceAccountSelection: true is not available in the stable API,
  // so we sign out before signIn to always show the account picker.
);
  bool _isLoadingEmail = false;
  bool _isLoadingGoogle = false;
  bool _isPasswordObscured = true; // Added for password visibility

  Future<void> _signUpWithEmail(BuildContext context) async {
    final displayName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (displayName.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All fields are required.')));
      return;
    }
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]+$').hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password must be alphanumeric (letters and numbers only).')));
      return;
    }


    setState(() {
      _isLoadingEmail = true;
    });

    try {
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
User? user = _auth.currentUser;
if (user != null) {
  await user.updateDisplayName(displayName);
  await user.reload();
}
      await _firestore.collection('users').doc(userCred.user!.uid).set({
        'fullName': displayName,
        'email': email,
        'uid': userCred.user!.uid,
        'createdAt': Timestamp.now(),
        'role': 'user',
        'lastLogin': Timestamp.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign up successful. Please login.')));
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String message = 'Sign Up Error: ${e.message ?? e.code}';
        if (e.code == 'email-already-in-use') {
          message = 'This email is already registered. Please login or use a different email.';
        } else if (e.code == 'weak-password') {
          message = 'The password provided is too weak.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingEmail = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    setState(() {
      _isLoadingGoogle = true;
    });
    try {
      // Always sign out first to force account picker
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        if (mounted) setState(() => _isLoadingGoogle = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCred = await _auth.signInWithCredential(credential);
      final user = userCred.user!;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        await _firestore.collection('users').doc(user.uid).set({
          'fullName': user.displayName ?? user.email?.split('@').first ?? 'Google User',
          'email': user.email!,
          'uid': user.uid,
          'createdAt': Timestamp.now(),
          'role': 'user',
          'lastLogin': Timestamp.now(),
        });
      } else {
        await _firestore.collection('users').doc(user.uid).update({
          'lastLogin': Timestamp.now(),
          'fullName': user.displayName ?? doc.data()?['fullName'],
          'email': user.email ?? doc.data()?['email'],
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signed in with Google successfully.')));
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-In Error: ${e.message ?? e.code}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected Google Sign-In error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingGoogle = false;
        });
      }
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen(onLanguageChange: (langCode) {})),
            );
          },
        ),
        title: const Text(
          'Sign Up',
          style: TextStyle(color: Colors.black87, fontFamily: 'Metamorphous'),
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
            image: AssetImage("assets/images/al-marhum/islamicbackground.png"),
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
                  'assets/images/al-marhum/Al-Marhum icon.png',
                  height: 100,
                ),
                const SizedBox(height: 20),
                Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Metamorphous',
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 30),
                _buildTextField(
                  controller: fullNameController,
                  labelText: 'Full Name',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: emailController,
                  labelText: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: passwordController,
                  labelText: 'Password (Aa,0-9)',
                  icon: Icons.lock_outline,
                  obscureText: _isPasswordObscured, // Use state variable
                  suffixIcon: IconButton(       // Add suffix icon
                    icon: Icon(
                      _isPasswordObscured ? Icons.visibility_off : Icons.visibility,
                      color: Colors.green.shade700,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordObscured = !_isPasswordObscured;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 30),
                if (_isLoadingEmail)
                  const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.green))
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(fontSize: 16, fontFamily: 'Metamorphous'),
                    ),
                    onPressed: () => _signUpWithEmail(context),
                    child: const Text('Sign Up with Email'),
                  ),
                const SizedBox(height: 20),
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
                if (_isLoadingGoogle)
                  const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue))
                else
                  ElevatedButton.icon(
                    icon: Image.asset(
                      'assets/images/al-marhum/google icon.png',
                      height: 24,
                      width: 24,
                    ),
                    label: const Text(
                      'Sign Up with Google',
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
                    onPressed: () => _signInWithGoogle(context),
                  ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: (_isLoadingEmail || _isLoadingGoogle)
                      ? null
                      : () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginPage()));
                  },
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: const TextStyle(
                      color: Colors.black,
                      fontFamily: 'Metamorphous',
                      ),
                      children: [
                        TextSpan(
                          text: 'Login',
                        style: TextStyle(
                          color: Colors.green,
                          fontFamily: 'Metamorphous',
                        ),
                      ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon, // Added suffixIcon parameter
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.green.shade700, fontFamily: 'Metamorphous'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.green.shade600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.green.shade800, width: 2),
        ),
        prefixIcon: Icon(icon, color: Colors.green.shade700),
        suffixIcon: suffixIcon, // Use suffixIcon
        filled: true,
        fillColor: Colors.white.withOpacity(0.85),
      ),
    );
  }
}