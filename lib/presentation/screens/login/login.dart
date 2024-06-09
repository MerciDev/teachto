import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:cenec_app/presentation/screens/intro/intro.dart';
import 'package:cenec_app/presentation/screens/login/recover_password.dart';
import 'package:cenec_app/presentation/screens/login/register.dart';
import 'package:cenec_app/resources/functions/login_register.dart';
import 'package:cenec_app/resources/functions/navigation.dart';
import 'package:cenec_app/resources/widgets/basic.dart';
import 'package:cenec_app/resources/widgets/login_register.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final Size screenSize = MediaQuery.of(context).size;

    return SafeArea(
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            leading: const CustomBackButton(),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: LoginScreen(
              emailController: emailController,
              passwordController: passwordController,
              screenSize: screenSize,
            ),
          ),
        ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.screenSize,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final Size screenSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const BasicLabel(
          label: "Iniciar Sesión",
          isTitle: true,
        ),
        const BasicLabel(label: "Identifícate para iniciar sesión"),
        const SizedBox(height: 50),
        BasicTextField(
          label: "Correo electrónico",
          controller: emailController,
        ),
        BasicTextField(
          label: "Contraseña",
          controller: passwordController,
          isPassword: true,
        ),
        LoginButton(
          emailController: emailController,
          passwordController: passwordController,
        ),
        BasicLinkLabel(
          label: '¿Olvidaste tu contraseña?',
          onTap: () {
            navigateTo(context, const ForgotPasswordPage());
          },
        ),
        const SizedBox(height: 20),
        const BasicLabel(label: 'Otros métodos'),
        (!kIsWeb && Platform.isIOS
            ? const SignInAppleButton()
            : const SizedBox()),
        SignInGoogleButton(email: emailController),
        SizedBox(
          height: (!kIsWeb && Platform.isIOS
              ? screenSize.width * 0.3
              : screenSize.width * 0.45),
        ),
        const RegisterText(),
      ],
    );
  }
}

class RegisterText extends StatelessWidget {
  const RegisterText({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const BasicLabel(label: '¿No tienes cuenta?'),
        BasicLinkLabel(
          label: 'Regístrate',
          onTap: () {
            navigateToSlide(
                context,
                Durations.short4,
                const RegisterPage(),
                const Offset(0.0, 1.0),
                Offset.zero);
          },
        )
      ],
    );
  }
}

class LoginButton extends StatelessWidget {
  const LoginButton({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 50),
      child: BasicButton(
        text: 'Iniciar Sesión',
        onPressed: () => login(emailController, passwordController, context),
      ),
    );
  }
}

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(!kIsWeb && Platform.isIOS
          ? Icons.arrow_back_ios
          : Icons.arrow_back),
      onPressed: () => navigateToSlide(
          context,
          Durations.short4,
          const IntroPage(),
          const Offset(1.0, 0.0),
          Offset.zero),
    );
  }
}
