import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:yalapay/constants/constants.dart';
import 'package:yalapay/firebase_options.dart';

import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      title: 'YalaPay',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: lightSecondary),
        primaryColor: darkPrimary,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: darkTertiary,
          surfaceTintColor: darkTertiary,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
