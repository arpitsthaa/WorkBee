import 'package:flutter/material.dart';
import 'views/auth/login_page.dart';
import 'services/backend_warmup_service.dart';

void main() {
  runApp(const MyApp());

  // Wake Render in the background so it does not delay the app startup.
  BackendWarmUpService.start();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // Set LoginPage as the starting screen
      home: LoginPage(),
    );
  }
}