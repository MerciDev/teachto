import "package:cenec_app/resources/classes/user_management.dart";
import "package:cenec_app/resources/functions/toasts.dart";
import "package:cenec_app/services/local_storage/local_storage.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:fluttertoast/fluttertoast.dart";
import "package:google_sign_in/google_sign_in.dart";

FirebaseFirestore db = FirebaseFirestore.instance;

Future<List> getUsers() async {
  List users = [];
  QuerySnapshot querySnapshot = await db.collection('users').get();
  for (var doc in querySnapshot.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final user = {
      'uid': doc.id,
      'name': data['name'],
      'email': data['email'],
      'tlf': data['tlf'],
      'direction': data['direction'],
      'password': data['password'],
    };

    users.add(user);
  }
  return users;
}

Future<String> getUserData(String uid, String dataName) async {
  final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
  final snapshot = await docRef.get();

  if (snapshot.exists) {
    if (snapshot.data()!.containsKey(dataName)) {
      return snapshot.data()?[dataName]
          as String; // Conversión explícita a String
    } else {
      return ""; // String vacío en caso de que el campo no exista
    }
  } else {
    return ""; // String vacío en caso de que el documento no exista
  }
}

Future<void> registerFB(
    UserApp user,
    TextEditingController email,
    TextEditingController password,
    TextEditingController confirmPassword,
    Function onSuccess) async {
  try {
    final userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: user.email,
      password: user.password,
    );

    final userUid = userCredential.user!.uid;

    await db.collection('users').doc(userUid).set({
      "name": user.name,
      "email": user.email,
    });
    onSuccess();
  } on FirebaseAuthException catch (e) {
    if (kDebugMode) {
      print(e.message);
      print(e.code);
    }
    if (e.code == 'email-already-in-use') {
      email.clear();
      Fluttertoast.showToast(
          msg: "Email en uso",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else if (e.code == 'weak-password') {
      password.clear();
      confirmPassword.clear();
      Fluttertoast.showToast(
          msg: "Mejora la seguridad de su contraseña",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}

Future<void> loginFB(TextEditingController email,
    TextEditingController password, Function onLogin) async {
  try {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email.text, password: password.text);
    onLogin();
    bool? signed = LocalStorage.prefs.getBool("signed");
    if (signed == null || !signed) {
      LocalStorage.prefs.setString("email", email.text);
      LocalStorage.prefs.setString("password", email.text);
      LocalStorage.prefs.setBool("signed", true);
      LocalStorage.prefs.setBool("firstSignIn", false);
    }
  } on FirebaseAuthException catch (e) {
    if (e.code == 'invalid-email') {
      errorToast("Correo inválido");
      email.clear();
      password.clear();
    } else if (e.code == 'invalid-credential') {
      errorToast("Contraseña incorrecta");
      password.clear();
    }
  }
}

Future<void> loginFBGl(Function? onSuccess) async {
  try {
    final userCredential = await signInWithGoogle();

    LocalStorage.prefs.setString("email", (userCredential?.user?.email ?? ""));
    LocalStorage.prefs.setBool("signed", true);
    LocalStorage.prefs.setBool("firstSignIn", false);
    if (onSuccess != null) {
      onSuccess();
    }
  } on PlatformException catch (e) {
    if (kDebugMode) {
      
      print(e.toString());
    }
    errorToast('Error al inciar sesión');
  }
}

Future<UserCredential?> signInWithGoogle() async {
  try {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      // El usuario canceló la autenticación con Google
      return null;
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  } catch (e) {
    if (kDebugMode) {
      print("Error en la autenticación con Google: $e");
    }
    return null;
  }
}
