
import 'package:cenec_app/presentation/screens/intro/logo.dart';
import 'package:cenec_app/resources/themes/app_theme.dart';
import 'package:cenec_app/services/local_storage/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.configurePrefs();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const MyApp(), // Your main application widget
    
  );
}

final class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      theme: CustomThemes.lightTheme,
      darkTheme: CustomThemes.darkTheme,
      initialRoute: 'logo',
      routes: {
        'logo': (_) => (const LogoPage()),
      },
    );
  }
}