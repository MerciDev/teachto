import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BasicButton extends StatelessWidget {
  final String text;
  final Color? backgroundColorFi;
  final Color? textColorFi;
  final VoidCallback? onPressed;
  const BasicButton({
    super.key,
    this.text = '',
    this.backgroundColorFi,
    this.textColorFi,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).primaryColor;
    Color textColor = Theme.of(context).cardColor;
    if (backgroundColorFi != null) backgroundColor = backgroundColorFi!;
    if (textColorFi != null) textColor = textColorFi!;

    var textWidget =
        Text(text, style: TextStyle(color: textColor, fontSize: 20));
    var iosButton = CupertinoButton(
      onPressed: onPressed,
      color: backgroundColor,
      borderRadius: BorderRadius.circular(30),
      child: textWidget,
    );
    var andButton = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        minimumSize: const Size(300, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
      ),
      child: textWidget,
    );
    if (!kIsWeb && Platform.isIOS) {
      return Container(margin: const EdgeInsets.all(5), child: iosButton);
    }
    return Container(margin: const EdgeInsets.all(5), child: andButton);
  }
}

class BasicOutlinedButton extends StatelessWidget {
  final String text;
  final Color? backgroundColorFi;
  final Color? outlineColorFi;
  final Color? textColorFi;
  final VoidCallback? onPressed;
  const BasicOutlinedButton({
    super.key,
    this.text = '',
    this.backgroundColorFi,
    this.outlineColorFi,
    this.textColorFi,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).cardColor;
    Color outlineColor = Theme.of(context).primaryColor;
    Color textColor = Theme.of(context).hintColor;
    if (backgroundColorFi != null) backgroundColor = backgroundColorFi!;
    if (outlineColorFi != null) outlineColor = outlineColorFi!;
    if (textColorFi != null) textColor = textColorFi!;

    var textWidget =
        Text(text, style: TextStyle(color: textColor, fontSize: 20));
    var andButton = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor,
        side: BorderSide(color: outlineColor),
        minimumSize: const Size(300, 50),
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(!kIsWeb && Platform.isIOS ? 30 : 15)),
        elevation: 5,
      ),
      child: textWidget,
    );
    return Container(margin: const EdgeInsets.all(5), child: andButton);
  }
}

class BasicLabel extends StatelessWidget {
  final String label;
  final bool isTitle;
  const BasicLabel({
    super.key,
    required this.label,
    this.isTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    const titleStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 32);
    const style = TextStyle(fontSize: 16, color: Colors.grey);
    return Container(
      margin: const EdgeInsets.all(5),
      child: Text(
        label,
        style: (isTitle ? titleStyle : style),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class BasicLinkLabel extends StatelessWidget {
  final String label;
  final Function()? onTap;
  const BasicLinkLabel({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    var style = TextStyle(
      fontSize: 16,
      color: Theme.of(context).hintColor,
      fontWeight: FontWeight.bold,
    );
    return Container(
      margin: const EdgeInsets.all(5),
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          label,
          style: (style),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class BasicTextField extends StatelessWidget {
  final String label;
  final Color borderColor;
  final Color backgroundColor;
  final double borderOpacity;
  final double labelOpacity; // Opacidad específica para el label
  final EdgeInsetsGeometry margin;
  final TextEditingController? controller;
  final bool isPassword;

  const BasicTextField({
    super.key,
    required this.label,
    this.borderColor = Colors.transparent,
    this.backgroundColor = const Color.fromARGB(255, 214, 214, 214),
    this.borderOpacity = 0.0,
    this.labelOpacity = 0.5, // Ajusta esto para la opacidad del label
    this.margin = const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
    this.controller,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    Color labelColor = Colors.black
        .withOpacity(labelOpacity); // Usa un color gris para el ejemplo

    var androidTextField = TextFormField(
      obscureText: isPassword,
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color:
              labelColor, // Aplica directamente el color con opacidad al label
        ),
        floatingLabelStyle: TextStyle(
          color:
              labelColor, // Asegura que el label flotante tenga la misma opacidad y color
        ),
        filled: true,
        fillColor: backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
    var iosTextField = CupertinoTextField(
      obscureText: isPassword,
      controller: controller,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30.0),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      placeholder: label,
      placeholderStyle: TextStyle(
        color: labelColor,
      ),
    );

    return Container(
      margin: margin,
      child: (!kIsWeb && Platform.isIOS ? iosTextField : androidTextField),
    );
  }
}

class NavigationButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget page;

  const NavigationButton(this.icon, this.label, this.page, {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 30, color: Colors.white),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}