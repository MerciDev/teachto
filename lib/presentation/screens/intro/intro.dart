import 'package:cenec_app/presentation/screens/login/login.dart';
import 'package:cenec_app/presentation/screens/login/register.dart';
import "package:cenec_app/resources/functions/navigation.dart";
import 'package:cenec_app/resources/widgets/basic.dart';
import 'package:flutter/material.dart';

void main() => runApp(const IntroPage());

/// The introductory screen for login and registration.
class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              Top(screenSize: screenSize),
              Logo(screenSize: screenSize),
              TitleWidget(screenSize: screenSize),
              IntroButton(screenSize: screenSize),
            ],
          ),
        ),
    );
  }
}

/// Widget for the introduction buttons.
class IntroButton extends StatelessWidget {
  const IntroButton({
    super.key,
    required this.screenSize,
  });

  final Size screenSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          BasicButton(
            text: 'Iniciar sesión',
            onPressed: () => {
              navigateToFade(
                  context, Durations.short4, const LoginPage(), 0.0, 1.0)
            },
          ),
          BasicOutlinedButton(
            text: 'Registrarse',
            onPressed: () => {
              navigateToFade(
                  context, Durations.short4, const RegisterPage(), 0.0, 1.0)
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

/// Widget for the title.
class TitleWidget extends StatelessWidget {
  const TitleWidget({
    super.key,
    required this.screenSize,
  });

  final Size screenSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: screenSize.height * 0.15),
      child: Center(
        child: Text(
          'Cenec App',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: screenSize.width * 0.09),
        ),
      ),
    );
  }
}

/// Widget for the logo.
class Logo extends StatelessWidget {
  const Logo({
    super.key,
    required this.screenSize,
  });

  final Size screenSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: screenSize.height * 0.05),
      child: Center(
        child: SizedBox(
          height: screenSize.width * 0.3,
          child: const Image(
            image: AssetImage('assets/design/logo.png'),
            fit: BoxFit.fitWidth,
          ),
        ),
      ),
    );
  }
}

/// Widget for the top decoration.
class Top extends StatelessWidget {
  const Top({
    super.key,
    required this.screenSize,
  });

  final Size screenSize;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -20,
      left: 0,
      right: 0,
      child: Container(
        height: screenSize.height * 0.5,
        width: screenSize.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/design/top.png'),
            fit: BoxFit.fitWidth,
          ),
        ),
      ),
    );
  }
}
