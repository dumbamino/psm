import 'package:flutter/material.dart';
import '../localization/app_localizations.dart'; // For AppBar title

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _reenterPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureReenter = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _reenterPasswordController.dispose();
    super.dispose();
  }

  void _changePassword() {
    if (_formKey.currentState!.validate()) {
      // Implement your password change logic here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password changed successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final customFont = 'Metamorphous';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          AppLocalizations.get(context, 'changePassword', fallback: '') ?? 'Change Password',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'Metamorphous',
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/al-marhum/islamicbackground.png'), // Update path as needed
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _oldPasswordController,
                    obscureText: _obscureOld,
                    style: const TextStyle(fontFamily: 'Metamorphous'),
                    decoration: InputDecoration(
                      labelText: 'Old Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureOld ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscureOld = !_obscureOld),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter your old password' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: _obscureNew,
                    style: const TextStyle(fontFamily: 'Metamorphous'),
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureNew ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscureNew = !_obscureNew),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) =>
                        value == null || value.length < 6 ? 'Password must be Alphanumeric' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _reenterPasswordController,
                    obscureText: _obscureReenter,
                    style: const TextStyle(fontFamily: 'Metamorphous'),
                    decoration: InputDecoration(
                      labelText: 'Re-enter Password',
                      prefixIcon: const Icon(Icons.lock_reset),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureReenter ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscureReenter = !_obscureReenter),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) =>
                        value != _newPasswordController.text ? 'Passwords do not match' : null,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF66BB6A),
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontFamily: 'Metamorphous', fontWeight: FontWeight.bold),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _changePassword,
                      child: const Text('Change Password'),
                    ),
      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}