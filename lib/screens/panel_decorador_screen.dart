import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/servicios/monitoreo.dart';
import '../models/solicitud.dart';
import '../shared/theme.dart';
import '../state/sesion_model.dart';
import '../state/solicitudes_model.dart';
import '../widgets/comunes.dart';
import 'solicitudes_screen.dart';

// Panel del decorador (alcance de la ficha): solicitudes recibidas en tiempo real.
// Al cambiar el estado aquí, el cliente lo ve al instante en "Mis solicitudes".
class PanelDecoradorScreen extends StatelessWidget {
  const PanelDecoradorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recibidas = context.watch<SolicitudesModel>().recibidas;
    final negocio = context.watch<SesionModel>().usuario?.decorador ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Solicitudes recibidas')),
      body: recibidas.isEmpty
          ? EstadoVacio(
              icono: Icons.inbox_outlined,
              titulo: 'Aún no te llegan solicitudes',
              mensaje: 'Cuando un cliente envíe un paquete de $negocio, aparecerá aquí.',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: recibidas
                  .map((s) => TarjetaSolicitud(
                        solicitud: s,
                        acciones: _Acciones(solicitud: s),
                      ))
                  .toList(),
            ),
    );
  }
}

class _Acciones extends StatefulWidget {
  const _Acciones({required this.solicitud});

  final Solicitud solicitud;

  @override
  State<_Acciones> createState() => _AccionesState();
}

class _AccionesState extends State<_Acciones> {
  bool _guardando = false;

  Future<void> _cambiar(EstadoSolicitud nuevo) async {
    setState(() => _guardando = true);
    try {
      await context.read<SolicitudesModel>().cambiarEstado(widget.solicitud, nuevo);
      await Analitica.evento('cambiar_estado_solicitud', {'estado': nuevo.name});
    } on FirebaseException catch (e, pila) {
      await Reportes.errorNoFatal(e, pila, donde: 'panel_decorador');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('No se pudo actualizar. Intenta de nuevo.')));
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado = widget.solicitud.estado;
    if (estado == EstadoSolicitud.aprobada) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text('Cliente: ${widget.solicitud.clienteNombre} · Aprobada',
            style: const TextStyle(color: kExito, fontWeight: FontWeight.w700)),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Expanded(
            child: Text('Cliente: ${widget.solicitud.clienteNombre}', style: const TextStyle(color: kMalva)),
          ),
          if (_guardando)
            const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
          else if (estado == EstadoSolicitud.enviada)
            OutlinedButton(
              onPressed: () => _cambiar(EstadoSolicitud.enRevision),
              style: OutlinedButton.styleFrom(foregroundColor: kAviso, side: const BorderSide(color: kAviso)),
              child: const Text('Revisar'),
            )
          else
            FilledButton(
              onPressed: () => _cambiar(EstadoSolicitud.aprobada),
              style: FilledButton.styleFrom(minimumSize: const Size(0, 40), backgroundColor: kExito),
              child: const Text('Aprobar'),
            ),
        ],
      ),
    );
  }
}
