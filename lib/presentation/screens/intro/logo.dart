import 'dart:async';

import 'package:cenec_app/presentation/screens/home/home.dart';
import 'package:cenec_app/presentation/screens/intro/intro.dart';
import 'package:cenec_app/resources/functions/navigation.dart';
import 'package:cenec_app/services/local_storage/local_storage.dart';
import 'package:flutter/material.dart';

/// Widget representing the introductory logo page.
class LogoPage extends StatefulWidget {
  const LogoPage({super.key});

  @override
  LogoPageState createState() => LogoPageState();
}

/// State class for IntroLogoPage widget.
class LogoPageState extends State<LogoPage> {
  @override
  void initState() {
    super.initState();
    _redirectToScreen();
  }

  /// Redirects to the appropriate screen based on user sign-in status.
  Future<void> _redirectToScreen() async {
    final Widget screen = await isSigned();
    Timer(const Duration(seconds: 1), () {
      navigateToFadeReplace(context, Durations.short4, screen, 0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          image: const DecorationImage(
            image: AssetImage('assets/design/logo.png'),
          ),
        ),
        height: 250,
      ),
    );
  }
}

/// Checks if the user is signed in and returns the appropriate screen.
Future<Widget> isSigned() async {
  bool? signed = LocalStorage.prefs.getBool("signed");
  bool? firstSignIn = LocalStorage.prefs.getBool("firstSignIn");
  if (signed != null && signed) {
    return const HomePage();
  } else if (firstSignIn == null || firstSignIn) {
    return const IntroPage();
  }
  return const IntroPage();
}
