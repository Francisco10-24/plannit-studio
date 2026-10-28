import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/cotizacion_model.dart';
import '../state/navegacion_model.dart';
import '../state/sesion_model.dart';
import '../widgets/comunes.dart';
import '../widgets/tarjeta_paquete.dart';
import 'detalle_paquete_screen.dart';

// Paquetes marcados con el corazón
class FavoritosScreen extends StatelessWidget {
  const FavoritosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ids = context.watch<SesionModel>().favoritos;
    final catalogo = context.watch<CotizacionModel>().ultimoCatalogo;
    final favoritos = catalogo == null
        ? const []
        : catalogo.paquetes.where((p) => ids.contains(p.id)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: favoritos.isEmpty
          ? EstadoVacio(
              icono: Icons.favorite_border,
              titulo: 'Aún no tienes favoritos',
              mensaje: 'Toca el corazón de un paquete para guardarlo aquí.',
              accion: 'Explorar paquetes',
              onAccion: () {
                context.read<NavegacionModel>().ir(NavegacionModel.explorar);
                Navigator.popUntil(context, (ruta) => ruta.isFirst);
              },
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: favoritos
                  .map((p) => TarjetaPaquete(paquete: p, onTap: () => abrirDetalle(context, p)))
                  .toList(),
            ),
    );
  }
}
