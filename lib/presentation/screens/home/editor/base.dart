import 'package:cenec_app/presentation/screens/home/editor/see/promotions.dart';
import 'package:cenec_app/presentation/screens/home/editor/see/subjects.dart';
import 'package:cenec_app/presentation/screens/home/editor/see/users.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const BaseEditorPage());
}

class BaseEditorPage extends StatelessWidget {
  const BaseEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey,
          title: const Text("App Editor"),
        ),
        body: Container(
          color: Colors.blueGrey,
          child: Column(
            children: [
              Expanded( // Aquí se utiliza Expanded para asegurar que GridView tenga una altura definida.
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ButtonsGrid()
                ),
              )
            ],
          ),
        ),
      );
  }
}

class ButtonsGrid extends StatelessWidget {
  ButtonsGrid({super.key});
  final List<ButtonData> buttons = [
    ButtonData("See Promotions", Icons.local_offer, const PromotionsListPage(), "promotions"),
    ButtonData("See Subjects", Icons.subject, const SubjectsListPage(), "subjects"),
    ButtonData("See Users", Icons.person, const UsersListPage(), "users"),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 600 ? 4 : 2;
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount, // Número de columnas
        childAspectRatio: 3, // Relación entre el ancho y alto de cada elemento
        crossAxisSpacing: 10, // Espacio horizontal entre elementos
        mainAxisSpacing: 10, // Espacio vertical entre elementos
      ),
      itemCount: buttons.length,
      itemBuilder: (context, index) {
        return FloatingActionButton.extended(
          heroTag: buttons[index].tag,
          onPressed: () {
            navigateTo(context, buttons[index].page);
          },
          label: Text(buttons[index].label),
          icon: Icon(buttons[index].icon),
          backgroundColor: Colors.blue, // Color de fondo del botón
        );
      },
    );
  }

  void navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}

class ButtonData {
  final String label;
  final IconData icon;
  final Widget page;
  final String tag;

  ButtonData(this.label, this.icon, this.page, this.tag);
}
