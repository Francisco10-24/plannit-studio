import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/solicitud.dart';
import '../shared/theme.dart';
import '../state/solicitudes_model.dart';
import '../utils/formato.dart';
import '../widgets/comunes.dart';
import '../widgets/seguimiento.dart';
import '../widgets/tarjeta_paquete.dart';
import 'detalle_paquete_screen.dart';

// Solicitudes enviadas por el cliente. El estado llega en tiempo real desde Firestore.
class SolicitudesScreen extends StatelessWidget {
  const SolicitudesScreen({super.key, this.recienEnviadas = false});

  final bool recienEnviadas;

  @override
  Widget build(BuildContext context) {
    final solicitudes = context.watch<SolicitudesModel>().mias;

    return Scaffold(
      appBar: AppBar(title: const Text('Mis solicitudes')),
      body: solicitudes.isEmpty
          ? const EstadoVacio(
              icono: Icons.receipt_long_outlined,
              titulo: 'Aún no has enviado solicitudes',
              mensaje: 'Cuando envíes tu carrito, aquí verás si el decorador la revisó y la aprobó.',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                if (recienEnviadas) ...[
                  const BannerEstado(
                    tipo: TipoBanner.exito,
                    mensaje: '¡Listo! Tus solicitudes llegaron a los decoradores. Te avisaremos cuando respondan.',
                  ),
                  const SizedBox(height: 16),
                ],
                ...solicitudes.map((s) => TarjetaSolicitud(solicitud: s)),
              ],
            ),
    );
  }
}

// Tarjeta de una solicitud. La usan el cliente y el panel del decorador.
class TarjetaSolicitud extends StatelessWidget {
  const TarjetaSolicitud({super.key, required this.solicitud, this.acciones});

  final Solicitud solicitud;

  // Botones extra (solo en el panel del decorador)
  final Widget? acciones;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSuperficie,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kBorde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(solicitud.evento, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              Text('#${solicitud.numero}', style: const TextStyle(color: kMalva, fontWeight: FontWeight.w600)),
            ],
          ),
          Text('${solicitud.tipo} · ${formatoFecha(solicitud.fecha)} · ${formatoHora(solicitud.hora)}',
              style: const TextStyle(color: kMalva)),
          const SizedBox(height: 8),
          FilaPaquete(paquete: solicitud.paquete, onTap: () => abrirDetalle(context, solicitud.paquete)),
          if (solicitud.extras.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Extras: ${solicitud.extras.join(', ')}', style: const TextStyle(color: kMalva, fontSize: 13)),
            ),
          const SizedBox(height: 12),
          Seguimiento(estado: solicitud.estado),
          const Divider(height: 28, color: kBorde),
          Row(
            children: [
              Expanded(
                child: Text('Enviada ${formatoFechaHora(solicitud.enviadaEn)}',
                    style: const TextStyle(color: kMalva, fontSize: 12)),
              ),
              Text(formatoPrecio(solicitud.total), style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          ?acciones,
        ],
      ),
    );
  }
}
