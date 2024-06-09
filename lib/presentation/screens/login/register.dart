import 'dart:io';

import 'package:flutter/material.dart';

import 'package:cenec_app/presentation/screens/intro/intro.dart';
import 'package:cenec_app/presentation/screens/login/login.dart';
import 'package:cenec_app/resources/functions/login_register.dart';
import 'package:cenec_app/resources/functions/navigation.dart';
import 'package:cenec_app/resources/widgets/basic.dart';

void main() => runApp(const RegisterPage());

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();

    return SafeArea(
      child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            leading: const BackButton(),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: RegisterForm(
            nameController: nameController,
            emailController: emailController,
            passwordController: passwordController,
            confirmPasswordController: confirmPasswordController,
          ),
      ),
    );
  }
}

class RegisterForm extends StatelessWidget {
  const RegisterForm({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          const BasicLabel(
            label: "Registrarse",
            isTitle: true,
          ),
          const SizedBox(height: 10),
          const BasicLabel(label: "Rellene la información para registrarse"),
          const SizedBox(height: 20),
          BasicTextField(label: "Nombre", controller: nameController),
          const SizedBox(height: 10),
          BasicTextField(label: "Correo electrónico", controller: emailController),
          const SizedBox(height: 10),
          BasicTextField(
            label: "Contraseña",
            controller: passwordController,
            isPassword: true,
          ),
          const SizedBox(height: 10),
          BasicTextField(
            label: "Confirmar contraseña",
            controller: confirmPasswordController,
            isPassword: true,
          ),
          const SizedBox(height: 20),
          RegisterButton(
            nameController: nameController,
            emailController: emailController,
            passwordController: passwordController,
            confirmPasswordController: confirmPasswordController,
          ),
          const SizedBox(height: 20),
          const LoginText(),
        ],
      ),
    );
  }
}

class LoginText extends StatelessWidget {
  const LoginText({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const BasicLabel(label: '¿Tienes una cuenta?'),
        BasicLinkLabel(
          label: 'Inicia sesión',
          onTap: () {
            navigateToSlide(
              context,
              Durations.short4,
              const LoginPage(),
              const Offset(0.0, 1.0),
              Offset.zero,
            );
          },
        ),
      ],
    );
  }
}

class RegisterButton extends StatelessWidget {
  const RegisterButton({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 50),
      child: BasicButton(
        onPressed: () {
          register(
            nameController,
            emailController,
            passwordController,
            confirmPasswordController,
            context,
          );
        },
        text: 'Registrarse',
      ),
    );
  }
}

class BackButton extends StatelessWidget {
  const BackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
      ),
      onPressed: () {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (_, __, ___) => const IntroPage(),
            transitionsBuilder: (_, animation, __, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          ),
        );
      },
    );
  }
}
