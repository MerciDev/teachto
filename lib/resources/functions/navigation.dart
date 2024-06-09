import "package:flutter/material.dart";

void navigateTo(BuildContext context, Widget page) {
  Navigator.push(context, PageRouteBuilder(pageBuilder: (_, __, ___) => page));
}

void navigateToReplace(BuildContext context, Widget page) {
  Navigator.pushReplacement(
      context, PageRouteBuilder(pageBuilder: (_, __, ___) => page));
}

void navigateToFade(BuildContext context, Duration duration, Widget page,
    double begin, double end) {
  Navigator.pushReplacement(
    context,
    PageRouteBuilder(
      transitionDuration: duration,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: Tween<double>(
            begin: begin,
            end: end,
          ).animate(animation),
          child: child,
        );
      },
    ),
  );
}

void navigateToFadeReplace(BuildContext context, Duration duration, Widget page,
    double begin, double end) {
  Navigator.pushReplacement(
    context,
    PageRouteBuilder(
      transitionDuration: duration,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: Tween<double>(
            begin: begin,
            end: end,
          ).animate(animation),
          child: child,
        );
      },
    ),
  );
}

void navigateToSlide(BuildContext context, Duration duration, Widget page,
    Offset begin, Offset end) {
  Navigator.push(
    context,
    PageRouteBuilder(
      transitionDuration: duration,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: begin,
            end: end,
          ).animate(animation),
          child: child,
        );
      },
    ),
  );
}

void navigateToSlideReplace(BuildContext context, Duration duration,
    Widget page, Offset begin, Offset end) {
  Navigator.pushReplacement(
    context,
    PageRouteBuilder(
      transitionDuration: duration,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: begin,
            end: end,
          ).animate(animation),
          child: child,
        );
      },
    ),
  );
}

void popBack(BuildContext context) {
  Navigator.pop(context);
}
