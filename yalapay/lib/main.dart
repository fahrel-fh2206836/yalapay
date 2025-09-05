import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/constants/constants.dart';

import 'routes/app_router.dart';

void main() {
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
