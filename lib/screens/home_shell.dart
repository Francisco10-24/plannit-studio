import 'package:flutter/material.dart';

import '../shared/theme.dart';
import 'inicio_screen.dart';
import 'mi_deco_screen.dart';
import 'paquetes_screen.dart';
import 'registro_screen.dart';

// Contenedor con la barra de navegación inferior
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _indice = 0;

  @override
  Widget build(BuildContext context) {
    final pantallas = [
      const InicioScreen(),
      const PaquetesScreen(mostrarAtras: false),
      MiDecoScreen(onExplorar: () => setState(() => _indice = 1)),
      const RegistroScreen(),
    ];

    return Scaffold(
      body: pantallas[_indice],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indice,
        onTap: (i) => setState(() => _indice = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: kSuperficie,
        selectedItemColor: kVino,
        unselectedItemColor: kMalva,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: 'Explorar'),
          BottomNavigationBarItem(icon: Icon(Icons.celebration_outlined), activeIcon: Icon(Icons.celebration), label: 'Mi deco'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
