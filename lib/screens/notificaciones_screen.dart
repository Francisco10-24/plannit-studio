import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../shared/theme.dart';
import '../state/solicitudes_model.dart';
import '../utils/formato.dart';
import '../widgets/comunes.dart';
import 'solicitudes_screen.dart';

// Avisos de cambios en las solicitudes (dentro de la app, sin push)
class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  // Se recuerda cuáles eran nuevas al abrir, para resaltarlas en la lista
  late final Set<Object> _nuevas;

  @override
  void initState() {
    super.initState();
    final solicitudes = context.read<SolicitudesModel>();
    _nuevas = solicitudes.notificaciones.where((n) => !n.leida).toSet();
    // Después del primer dibujo se marcan como leídas (se apaga el contador)
    WidgetsBinding.instance.addPostFrameCallback((_) => solicitudes.marcarLeidas());
  }

  @override
  Widget build(BuildContext context) {
    final notificaciones = context.watch<SolicitudesModel>().notificaciones;
    final ahora = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: notificaciones.isEmpty
          ? const EstadoVacio(
              icono: Icons.notifications_none,
              titulo: 'Sin notificaciones',
              mensaje: 'Aquí te avisaremos cuando un decorador revise o apruebe tu solicitud.',
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: notificaciones.length,
              separatorBuilder: (_, _) => const Divider(color: kBorde, height: 1),
              itemBuilder: (context, i) {
                final n = notificaciones[i];
                final nueva = _nuevas.contains(n) || !n.leida;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  leading: CircleAvatar(
                    backgroundColor: nueva ? kRosa : kBorde,
                    child: Icon(
                      n.titulo == 'Solicitud aprobada' ? Icons.verified_outlined : Icons.receipt_long_outlined,
                      color: kVino,
                    ),
                  ),
                  title: Text(n.titulo,
                      style: TextStyle(fontWeight: nueva ? FontWeight.w800 : FontWeight.w500)),
                  subtitle: Text('${n.mensaje}\n${haceCuanto(n.fecha, ahora)}',
                      style: const TextStyle(color: kMalva)),
                  isThreeLine: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SolicitudesScreen()),
                  ),
                );
              },
            ),
    );
  }
}
