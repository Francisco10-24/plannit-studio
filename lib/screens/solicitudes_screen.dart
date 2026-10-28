import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/solicitud.dart';
import '../shared/theme.dart';
import '../state/carrito_model.dart';
import '../utils/formato.dart';
import '../widgets/comunes.dart';
import '../widgets/seguimiento.dart';
import '../widgets/tarjeta_paquete.dart';
import 'detalle_paquete_screen.dart';

// Historial de solicitudes enviadas y su estado en vivo
class SolicitudesScreen extends StatelessWidget {
  const SolicitudesScreen({super.key, this.recienEnviadas = false});

  final bool recienEnviadas;

  @override
  Widget build(BuildContext context) {
    final solicitudes = context.watch<CarritoModel>().solicitudes;

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
                ...solicitudes.map((s) => _TarjetaSolicitud(solicitud: s)),
              ],
            ),
    );
  }
}

class _TarjetaSolicitud extends StatelessWidget {
  const _TarjetaSolicitud({required this.solicitud});

  final Solicitud solicitud;

  @override
  Widget build(BuildContext context) {
    final evento = solicitud.evento;
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
                child: Text(evento.nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              Text('#SOL-${solicitud.numero}', style: const TextStyle(color: kMalva, fontWeight: FontWeight.w600)),
            ],
          ),
          Text('${evento.tipo} · ${formatoFecha(evento.fecha)} · ${formatoHora(evento.hora)}',
              style: const TextStyle(color: kMalva)),
          const SizedBox(height: 8),
          FilaPaquete(paquete: evento.paquete, onTap: () => abrirDetalle(context, evento.paquete)),
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
        ],
      ),
    );
  }
}
