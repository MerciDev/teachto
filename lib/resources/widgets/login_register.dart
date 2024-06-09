import 'dart:io';

import 'package:cenec_app/presentation/screens/home/home.dart';
import 'package:cenec_app/resources/functions/login_register.dart';
import 'package:cenec_app/resources/functions/navigation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';

class SignInAppleButton extends StatelessWidget {
  const SignInAppleButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      child: SignInButton(Buttons.AppleDark,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          onPressed: () => {},
          text: "Iniciar sesión con Apple"),
    );
  }
}

class SignInGoogleButton extends StatelessWidget {
  final TextEditingController email;
  const SignInGoogleButton({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      child: SignInButton(Buttons.Google,
          padding: const EdgeInsets.symmetric(vertical: 7),
          shape: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular((!kIsWeb && Platform.isIOS ? 30 : 15))),
          onPressed: () => {
                loginGl(() {
                  navigateToFade(
                      context, Durations.short4, const HomePage(), 0.0, 1.0);
                })
              },
          text: "Iniciar sesión con Google"),
    );
  }
}
