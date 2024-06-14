import 'package:flutter/material.dart';

class CustomNotification {
  static void showNotification(
    BuildContext context,
    IconData iconData,
    Color iconColor,
    String message,
    VoidCallback? onPressed,
  ) {
    // ignore: unnecessary_null_comparison
    if (context == null) {
      return;
    }

    Size screenSize = MediaQuery.of(context).size;

    double notificationWidth = screenSize.width * 0.7;
    double notificationHeight = screenSize.height * 0.06;
    const double animationDurationSeconds = 2;

    final double initialX = MediaQuery.of(context).size.width;
    const double finalX = 1.25;

    final AnimationController controller = AnimationController(
      duration: Duration(seconds: animationDurationSeconds.toInt()),
      vsync: Navigator.of(context).overlay!,
    );

    final Animation<Offset> offsetAnimation = Tween<Offset>(
      begin: Offset(initialX, 0),
      end: const Offset(finalX, 0),
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ));

    controller.forward();

    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (BuildContext context) => Positioned(
        top: 40.0,
        right: initialX,
        child: SlideTransition(
          position: offsetAnimation,
          child: Material(
            color: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 4.0,
            child: GestureDetector(
              onTap: () {
                overlayEntry?.remove();
                controller.dispose();
                onPressed?.call();
              },
              child: Container(
                width: notificationWidth,
                height: notificationHeight,
                decoration: BoxDecoration(
                  color: Theme.of(context).hintColor,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        iconData,
                        color: iconColor,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          message,
                          style: const TextStyle(
                            fontSize: 17,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: () {
                        overlayEntry?.remove();
                        controller.dispose();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }
}
