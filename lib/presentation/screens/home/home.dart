import 'package:cenec_app/presentation/screens/home/courses/courses.dart';
import 'package:cenec_app/presentation/screens/home/promotions/promotions.dart';
import 'package:cenec_app/presentation/screens/home/user/userprofile.dart';
import 'package:cenec_app/resources/classes/courses.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    const PromotionsPage(), // Puedes reemplazar esto por páginas reales
    const CoursesPage(),
    UserProfilePage(courses: coursesList), // Página de perfil del usuario
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          PageView(
            controller: _pageController,
            children: _pages,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                });
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.discount), label: 'Ofertas'),
                BottomNavigationBarItem(icon: Icon(Icons.book_online), label: 'Cursos'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Usuario'), // Ícono y etiqueta para la página del usuario
              ],
            ),
          ),
        ],
      ),
    );
  }
}
