import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../shared/theme.dart';
import '../state/carrito_model.dart';
import '../state/navegacion_model.dart';
import '../state/solicitudes_model.dart';
import '../widgets/comunes.dart';
import 'carrito_screen.dart';
import 'inicio_screen.dart';
import 'paquetes_screen.dart';
import 'perfil_screen.dart';

// Contenedor con la barra de navegación inferior
class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final navegacion = context.watch<NavegacionModel>();
    final enCarrito = context.watch<CarritoModel>().cantidad;
    // Para decoradores: solicitudes que todavía no aprueban
    final pendientes = context.watch<SolicitudesModel>().pendientes;

    return Scaffold(
      // IndexedStack conserva cada pestaña viva: no se repite el GET al cambiar
      body: IndexedStack(
        index: navegacion.pestana,
        children: [
          for (final (i, pantalla) in const [
            InicioScreen(),
            PaquetesScreen(esPestana: true),
            CarritoScreen(),
            PerfilScreen(),
          ].indexed)
            // Solo la pestaña visible anima la foto (Hero): evita tags repetidos
            HeroMode(enabled: i == navegacion.pestana, child: pantalla),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navegacion.pestana,
        onTap: navegacion.ir,
        type: BottomNavigationBarType.fixed,
        backgroundColor: kSuperficie,
        selectedItemColor: kVino,
        unselectedItemColor: kMalva,
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Inicio'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: 'Explorar'),
          BottomNavigationBarItem(
            icon: IconoConContador(icono: Icons.shopping_bag_outlined, cantidad: enCarrito),
            activeIcon: IconoConContador(icono: Icons.shopping_bag, cantidad: enCarrito),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(
            icon: IconoConContador(icono: Icons.person_outline, cantidad: pendientes),
            activeIcon: IconoConContador(icono: Icons.person, cantidad: pendientes),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
