import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yalapay/constants/constants.dart';
import 'package:yalapay/screens/common_screens/login_screen.dart';
import 'package:yalapay/services/auth_service.dart';
import 'package:yalapay/styling/frosted_glass.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  late TextEditingController txtFirstNameController;
  late TextEditingController txtLastNameController;
  late TextEditingController txtEmailController;
  late TextEditingController txtPasswordController;
  bool notVisible = true;

  @override
  void initState() {
    super.initState();
    txtFirstNameController = TextEditingController();
    txtLastNameController = TextEditingController();
    txtEmailController = TextEditingController();
    txtPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    txtFirstNameController.dispose();
    txtLastNameController.dispose();
    txtEmailController.dispose();
    txtPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/bg2.jpeg",
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: screenHeight(context) * 0.04,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: screenWidth(context) * 0.40,
                        child: Image.asset(
                          "assets/images/yalapay_text_logo_dark.png",
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: screenHeight(context) * 0.64,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: FrostedGlassBox(
                        boxWidth: double.infinity,
                        boxChild: buildRegisterForm(context),
                        isCurved: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRegisterForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                "Create an account here.",
                style: getTextStyle('largeBold', color: Colors.white),
              ),
            ),
            // First Name Field
            FrostedGlassTextField(
              controller: txtFirstNameController,
              keyboardType: TextInputType.name,
              hintText: "First Name",
              prefixIcon: const Icon(Icons.person, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            // Last Name Field
            FrostedGlassTextField(
              controller: txtLastNameController,
              keyboardType: TextInputType.name,
              hintText: "Last Name",
              prefixIcon: const Icon(Icons.person, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            // Email Field
            EmailTextField(controller: txtEmailController),
            const SizedBox(height: 20),
            // Password Field
            PasswordTextField(
              controller: txtPasswordController,
              isVisible: notVisible,
              hintText: "Password",
              prefixIcon: const Icon(Icons.lock_outlined, color: Colors.grey),
              toggleVisibility: () {
                setState(() {
                  notVisible = !notVisible;
                });
              },
            ),
            const SizedBox(height: 20),
            // Register Button
            RegisterButton(onRegisterPressed: () => handleRegister(context)),
            const SizedBox(height: 20),
            // Login Redirect
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Already have an account? ",
                    style: getTextStyle('small', color: Colors.grey),
                  ),
                  TextSpan(
                    text: "Login",
                    style: getTextStyle('small', color: lightSecondary),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        context.pop();
                      },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void handleRegister(BuildContext context) async {
    if (txtFirstNameController.text.isEmpty ||
        txtLastNameController.text.isEmpty ||
        txtEmailController.text.isEmpty ||
        txtPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(fillAllFormsSnackBar);
      return;
    }

    try {
      await AuthService().signup(
        email: txtEmailController.text,
        password: txtPasswordController.text,
        firstName: txtFirstNameController.text,
        lastName: txtLastNameController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(registerSuccessSnackBar);
      context.pop(); // Go back to login screen
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'email-already-in-use') {
        message = 'The provided email already exists in the database.';
      } else if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else {
        message = 'An error occurred: $e';
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          message,
          style: getTextStyle('small', color: Colors.white),
        ),
        backgroundColor: lightSecondary,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Registration failed: $e',
          style: getTextStyle('small', color: Colors.white),
        ),
        backgroundColor: lightSecondary,
      ));
    }
  }
}

class RegisterButton extends StatelessWidget {
  final VoidCallback onRegisterPressed;

  const RegisterButton({super.key, required this.onRegisterPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: onRegisterPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: lightSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
        child: Text(
          "Register",
          style: getTextStyle('mediumBold', color: Colors.white),
        ),
      ),
    );
  }
}

final SnackBar fillAllFormsSnackBar = SnackBar(
  content: Text(
    'Please fill all forms.',
    style: getTextStyle('small', color: Colors.white),
  ),
  backgroundColor: lightSecondary,
);

final SnackBar registerSuccessSnackBar = SnackBar(
  content: Text(
    'Registration successful!',
    style: getTextStyle('small', color: Colors.white),
  ),
  backgroundColor: lightSecondary,
);
