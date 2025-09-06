import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yalapay/constants/constants.dart';
import 'package:yalapay/model/user.dart';
import 'package:yalapay/providers/cheque_provider.dart';
import 'package:yalapay/providers/customer_provider.dart';
import 'package:yalapay/providers/invoice_provider.dart';
import 'package:yalapay/providers/logged_in_user_provider.dart';
import 'package:yalapay/providers/selected_invoice_provider.dart';
import 'package:yalapay/providers/show_nav_bar_provider.dart';
import 'package:yalapay/routes/app_router.dart';
import 'package:yalapay/services/auth_service.dart';
import 'package:yalapay/styling/frosted_glass.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool notVisible = true;
  bool isRememberMeChecked = false;
  late TextEditingController txtEmailController;
  late TextEditingController txtPasswordController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(loggedInUserNotifierProvider);
    txtEmailController = TextEditingController(text: user.email);
    txtPasswordController = TextEditingController();
    isRememberMeChecked =
        ref.read(loggedInUserNotifierProvider.notifier).isRememberMeChecked;
  }

  @override
  void dispose() {
    txtEmailController.dispose();
    txtPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(customerNotifierProvider);
    ref.watch(invoiceNotifierProvider);
    ref.watch(selectedInvoiceNotifierProvider);
    ref.watch(chequeNotifierProvider);
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
                  height: screenHeight(context) * 0.60,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: FrostedGlassBox(
                        boxWidth: double.infinity,
                        boxChild: buildLoginForm(context),
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

  Widget buildLoginForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0),
            child: Text(
              "Let's sign you in.",
              style: getTextStyle('largeBold', color: Colors.white),
            ),
          ),
          EmailTextField(controller: txtEmailController),
          const SizedBox(height: 20),
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
          RememberMeCheckbox(
            isChecked: isRememberMeChecked,
            onChanged: (value) {
              setState(() {
                isRememberMeChecked = value;
              });
            },
          ),
          const SizedBox(height: 30),
          LoginButton(onLoginPressed: () => handleLogin(context)),
          const SizedBox(height: 20),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Don't have an account? ",
                  style: getTextStyle('small', color: Colors.grey),
                ),
                TextSpan(
                  text: "Register",
                  style: getTextStyle('small', color: lightSecondary),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      context.pushNamed('register');
                    },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> handleLogin(BuildContext context) async {
    if (txtEmailController.text.isEmpty || txtPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(fillAllFormsSnackBar);
      return;
    }

    try {
      await AuthService().signin(
        email: txtEmailController.text,
        password: txtPasswordController.text,
      );

      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        throw Exception("Login failed: Invalid user or credentials.");
      } else {
        final user = User(
          email: firebaseUser.email ?? '',
          firstName: firebaseUser.displayName?.split(' ').first ?? '',
          lastName: firebaseUser.displayName?.split(' ').last ?? '',
          password: '', // Avoid storing the password
        );

        ref.read(loggedInUserNotifierProvider.notifier).setUser(
              user,
              rememberMe: isRememberMeChecked,
            );

        context.pushReplacementNamed(AppRouter.dashboard.name);
        ref.read(showNavBarNotifierProvider.notifier).showBottomNavBar(true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Login failed. Incorrect details were entered.",
          style: getTextStyle('small', color: Colors.white),
        ),
        backgroundColor: lightSecondary,
      ));
      if (!isRememberMeChecked) {
        txtEmailController.clear();
        txtPasswordController.clear();
      }
    }
  }
}

class EmailTextField extends StatelessWidget {
  final TextEditingController controller;

  const EmailTextField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return FrostedGlassTextField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      hintText: "Email",
      prefixIcon:
          const Icon(Icons.alternate_email_outlined, color: Colors.grey),
    );
  }
}

class PasswordTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool isVisible;
  final VoidCallback toggleVisibility;
  final String hintText;
  final Icon prefixIcon;

  const PasswordTextField({
    super.key,
    required this.controller,
    required this.isVisible,
    required this.toggleVisibility,
    required this.hintText,
    required this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return FrostedGlassTextField(
      controller: controller,
      obscureText: isVisible,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: IconButton(
        onPressed: toggleVisibility,
        icon: Icon(
          isVisible ? Icons.visibility_off : Icons.visibility,
          color: Colors.grey,
        ),
      ),
    );
  }
}

class RememberMeCheckbox extends StatelessWidget {
  final bool isChecked;
  final ValueChanged<bool> onChanged;

  const RememberMeCheckbox({
    super.key,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: isChecked,
          onChanged: (value) => onChanged(value ?? false),
          activeColor: lightSecondary,
        ),
        Text(
          "Remember me",
          style: getTextStyle('small', color: Colors.white),
        ),
      ],
    );
  }
}

class LoginButton extends StatelessWidget {
  final VoidCallback onLoginPressed;

  const LoginButton({super.key, required this.onLoginPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: onLoginPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: lightSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 5,
        ),
        child: Text(
          "Login",
          style: getTextStyle('mediumBold', color: Colors.white),
        ),
      ),
    );
  }
}

final SnackBar loginFailSnackBar = SnackBar(
  content: Text(
    'Incorrect credentials! Please try again...',
    style: getTextStyle('small', color: Colors.white),
  ),
  backgroundColor: lightSecondary,
);

final SnackBar fillAllFormsSnackBar = SnackBar(
  content: Text(
    'Please fill all forms.',
    style: getTextStyle('small', color: Colors.white),
  ),
  backgroundColor: lightSecondary,
);
