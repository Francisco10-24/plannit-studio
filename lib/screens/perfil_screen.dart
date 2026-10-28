import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../shared/theme.dart';
import '../state/carrito_model.dart';
import '../state/sesion_model.dart';
import 'favoritos_screen.dart';
import 'notificaciones_screen.dart';
import 'registro_screen.dart';
import 'solicitudes_screen.dart';

// Perfil: si no hay sesión muestra el registro; si hay, los datos y accesos
class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<SesionModel>();
    final carrito = context.watch<CarritoModel>();
    final usuario = sesion.usuario;

    if (usuario == null) return const RegistroScreen();

    void abrir(Widget pantalla) =>
        Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: kTinta, borderRadius: BorderRadius.circular(24)),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: kVino,
                  child: Text(usuario.nombre[0].toUpperCase(),
                      style: const TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(usuario.nombre,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                      Text(usuario.correo, style: const TextStyle(color: Colors.white70)),
                      Text('+503 ${usuario.telefono} · ${usuario.esDecorador ? 'Decorador' : 'Cliente'}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _Opcion(
            icono: Icons.receipt_long_outlined,
            titulo: 'Mis solicitudes',
            detalle: '${carrito.solicitudes.length}',
            onTap: () => abrir(const SolicitudesScreen()),
          ),
          _Opcion(
            icono: Icons.favorite_border,
            titulo: 'Favoritos',
            detalle: '${sesion.favoritos.length}',
            onTap: () => abrir(const FavoritosScreen()),
          ),
          _Opcion(
            icono: Icons.notifications_none,
            titulo: 'Notificaciones',
            detalle: carrito.noLeidas == 0 ? '' : '${carrito.noLeidas} nuevas',
            onTap: () => abrir(const NotificacionesScreen()),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: const StadiumBorder(),
              foregroundColor: kVino,
            ),
            onPressed: () => context.read<SesionModel>().cerrarSesion(),
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}

class _Opcion extends StatelessWidget {
  const _Opcion({required this.icono, required this.titulo, required this.detalle, required this.onTap});

  final IconData icono;
  final String titulo;
  final String detalle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: kSuperficie,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: kBorde),
        ),
        child: ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          leading: CircleAvatar(backgroundColor: kRosa, child: Icon(icono, color: kVino)),
          title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w700)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(detalle, style: const TextStyle(color: kMalva)),
              const Icon(Icons.chevron_right, color: kMalva),
            ],
          ),
        ),
      ),
    );
  }
}
