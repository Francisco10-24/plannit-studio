import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/catalogo.dart';
import '../shared/theme.dart';
import '../state/cotizacion_model.dart';
import '../utils/filtros.dart';
import '../widgets/comunes.dart';
import '../widgets/tarjeta_paquete.dart';
import 'detalle_paquete_screen.dart';

// Perfil de un decorador con todos sus paquetes
class DecoradorScreen extends StatelessWidget {
  const DecoradorScreen({super.key, required this.decorador});

  final Decorador decorador;

  @override
  Widget build(BuildContext context) {
    final catalogo = context.watch<CotizacionModel>().ultimoCatalogo;
    final paquetes = catalogo == null
        ? const []
        : filtrarPaquetes(catalogo.paquetes, decorador: decorador.nombre);

    return Scaffold(
      appBar: AppBar(title: Text(decorador.nombre)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Row(
            children: [
              SizedBox(width: 84, height: 84, child: FotoRed(url: decorador.imagen, radio: 42, alto: 84)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(decorador.nombre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: kVino, size: 18),
                        Text(' ${decorador.rating} · ${decorador.zona}', style: const TextStyle(color: kMalva)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (decorador.descripcion.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(decorador.descripcion, style: const TextStyle(fontSize: 16, height: 1.5)),
          ],
          const SizedBox(height: 24),
          Text(
            paquetes.length == 1 ? '1 paquete' : '${paquetes.length} paquetes',
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...paquetes.map((p) => TarjetaPaquete(paquete: p, onTap: () => abrirDetalle(context, p))),
        ],
      ),
    );
  }
}
