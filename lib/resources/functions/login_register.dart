import 'package:cenec_app/presentation/screens/home/home.dart';
import 'package:cenec_app/resources/classes/user_management.dart';
import 'package:cenec_app/services/firebase/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

bool checkInfo(
    TextEditingController nameController,
    TextEditingController emailController,
    TextEditingController passwordController,
    TextEditingController confirmPasswordController) {
  return checkNoEmptyFields(nameController, emailController, passwordController,
          confirmPasswordController) &&
      checkPassword(passwordController, confirmPasswordController) &&
      checkValidEmail(emailController);
}

bool checkValidEmail(TextEditingController emailController) {
  // Expresión regular para validar un correo electrónico
  final RegExp regExp = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$",
      caseSensitive: false);

  // Comprobar si el correo coincide con la expresión regular
  if (!regExp.hasMatch(emailController.text)) {
    Fluttertoast.showToast(
        msg: "El correo no es válido",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
    return false;
  }
  return true;
}

bool checkNoEmptyFields(
    TextEditingController nameController,
    TextEditingController emailController,
    TextEditingController passwordController,
    TextEditingController confirmPasswordController) {
  if (nameController.text.isEmpty ||
      emailController.text.isEmpty ||
      passwordController.text.isEmpty ||
      confirmPasswordController.text.isEmpty) {
    Fluttertoast.showToast(
        msg: "Todos los campos son obligatorios",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
    return false;
  }
  return true;
}

bool checkPassword(TextEditingController passwordController,
    TextEditingController confirmPasswordController) {
  if (passwordController.text != confirmPasswordController.text) {
    Fluttertoast.showToast(
        msg: "Asegúrese de que las contraseñas coinciden.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
    return false;
  }
  return true;
}

class Background extends StatelessWidget {
  const Background({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/design/background1.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      height: double.infinity,
      alignment: Alignment.topCenter,
    );
  }
}

void register(
    TextEditingController nameCtrl,
    TextEditingController emailCtrl,
    TextEditingController pswdCtrl,
    TextEditingController cPswdCtrl,
    BuildContext context) {
  if (checkInfo(nameCtrl, emailCtrl, pswdCtrl, cPswdCtrl)) {
    UserApp user = UserApp(nameCtrl.text, emailCtrl.text, pswdCtrl.text);
    registerFB(
        user,
        emailCtrl,
        pswdCtrl,
        cPswdCtrl,
        () => {
              login(emailCtrl, pswdCtrl, context),
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
                (Route<dynamic> route) => false,
              )
            });
  }
}

void login(TextEditingController emailController,
    TextEditingController passwordController, BuildContext context) {
  loginFB(
      emailController,
      passwordController,
      () => {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
                (Route<dynamic> route) => false,
              )
          });
}

Future<void> loginGl(Function? onSuccess) async {
  await loginFBGl(onSuccess);
}
