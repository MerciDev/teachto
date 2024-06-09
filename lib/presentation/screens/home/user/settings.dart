import 'package:cenec_app/presentation/screens/intro/intro.dart';
import 'package:cenec_app/resources/functions/navigation.dart';
import 'package:cenec_app/services/local_storage/local_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        titleTextStyle: Theme.of(context).textTheme.displayMedium,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(5.0),
        children: [
          const ToggleButton(label: "Avisar tareas pendientes", property: "pendingNotify"),
          const ToggleButton(label: "Avisar tareas sin entregar", property: "unsubmittedNotify"),
          _buildSettingButton(
            context,
            'Cerrar sesión',
            onPressed: () {
              FirebaseAuth.instance.signOut();
              LocalStorage.prefs.setBool("signed", false);
              navigateToSlide(context, Durations.medium2, const IntroPage(),
                  const Offset(1.0, 0.0), const Offset(0.0, 0.0));
            },
          ),
          // Agrega más botones aquí según sea necesario
        ],
      ),
    );
  }

  Widget _buildSettingButton(BuildContext context, String label,
      {VoidCallback? onPressed}) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context)
              .scaffoldBackgroundColor, // Color del texto del botón
          padding: const EdgeInsets.symmetric(
              vertical: 16, horizontal: 24), // Padding del botón
          shape: RoundedRectangleBorder(
            // Forma del botón
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Align(
          // Utilizamos Align para alinear el texto a la izquierda
          alignment: Alignment.centerLeft, // Alineamos el texto a la izquierda
          child: Text(
            label,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: const Color(0xFFC62828)), // Estilo del texto del botón
            textAlign: TextAlign.left, // Alineamos el texto a la izquierda
          ),
        ),
      ),
    );
  }

}

class ToggleButton extends StatefulWidget {
  final String label;
  final String property;

  const ToggleButton({super.key, required this.label, required this.property});

  @override
  ToggleButtonState createState() => ToggleButtonState();
}

class ToggleButtonState extends State<ToggleButton> {
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _loadActiveState(); 
  }

  void _loadActiveState() async {
    bool isActive = LocalStorage.prefs.getBool(widget.property) ?? false;
    setState(() {
      _isActive = isActive;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: ElevatedButton(
        onPressed: () async {
          LocalStorage.prefs.setBool(widget.property, !_isActive); // Guardar nuevo estado
          setState(() {
            _isActive = !_isActive;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Text(
                widget.label,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.black),
                textAlign: TextAlign.left,
              ),
            ),
            Icon(
              _isActive ? Icons.check : Icons.close,
              color: _isActive ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}


