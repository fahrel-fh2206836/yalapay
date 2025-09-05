import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yalapay/constants/constants.dart';
import 'package:yalapay/model/user.dart';
import 'package:yalapay/providers/logged_in_user_provider.dart';
import 'package:yalapay/providers/show_nav_bar_provider.dart';
import 'package:yalapay/providers/user_provider.dart';
import 'package:yalapay/routes/app_router.dart';
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
    txtPasswordController = TextEditingController(text: user.password);
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
    ref.watch(userNotifierProvider);
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
              top: screenHeight(context) * 0.08,
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
              "Enter your login information",
              style: getTextStyle('medium', color: Colors.grey),
            ),
          ),
          const SizedBox(height: 12),
          EmailTextField(controller: txtEmailController),
          const SizedBox(height: 30),
          PasswordTextField(
            controller: txtPasswordController,
            isVisible: notVisible,
            toggleVisibility: () {
              setState(() {
                notVisible = !notVisible;
              });
            },
          ),
          const SizedBox(height: 30),
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
        ],
      ),
    );
  }

  void handleLogin(BuildContext context) {
    if (txtEmailController.text.isEmpty || txtPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(fillAllFormsSnackBar);
      return;
    }

    final userNotifier = ref.read(userNotifierProvider.notifier);
    bool verified = userNotifier.verifyUser(
      txtEmailController.text,
      txtPasswordController.text,
    );

    if (verified) {
      User user = userNotifier.getUser(txtEmailController.text);
      ref.read(loggedInUserNotifierProvider.notifier).setUser(
            user,
            rememberMe: isRememberMeChecked,
          );

      context.pushReplacementNamed(AppRouter.dashboard.name);
      ref.read(showNavBarNotifierProvider.notifier).showBottomNavBar(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(loginFailSnackBar);

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

  const PasswordTextField({
    super.key,
    required this.controller,
    required this.isVisible,
    required this.toggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return FrostedGlassTextField(
      controller: controller,
      obscureText: isVisible,
      hintText: "Password",
      prefixIcon: const Icon(Icons.lock_outlined, color: Colors.grey),
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
          style: getTextStyle('medium', color: Colors.white),
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
      height: 60,
      child: ElevatedButton(
        onPressed: onLoginPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
        child: Text(
          "LOGIN",
          style: getTextStyle('largeBold', color: Colors.white),
        ),
      ),
    );
  }
}

final SnackBar loginFailSnackBar = SnackBar(
  content: Text(
    'Incorrect credentials! Please try again...',
    style: getTextStyle('medium', color: Colors.white),
  ),
  backgroundColor: lightSecondary,
);

final SnackBar fillAllFormsSnackBar = SnackBar(
  content: Text(
    'Please fill all forms.',
    style: getTextStyle('medium', color: Colors.white),
  ),
  backgroundColor: lightSecondary,
);
