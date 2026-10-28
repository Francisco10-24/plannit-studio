import 'package:flutter/material.dart';

import '../models/solicitud.dart';
import '../shared/theme.dart';

// Seguimiento de la solicitud: Enviada -> En revisión -> Aprobada
class Seguimiento extends StatelessWidget {
  const Seguimiento({super.key, required this.estado});

  final EstadoSolicitud estado;

  @override
  Widget build(BuildContext context) {
    const pasos = [
      (EstadoSolicitud.enviada, 'Enviada', Icons.send_outlined),
      (EstadoSolicitud.enRevision, 'En revisión', Icons.hourglass_top),
      (EstadoSolicitud.aprobada, 'Aprobada', Icons.verified_outlined),
    ];
    return Row(
      children: pasos.map((paso) {
        // Un paso está hecho si ya se pasó, o si es el último estado alcanzado
        final hecho = estado.index > paso.$1.index ||
            (estado == paso.$1 && paso.$1 != EstadoSolicitud.enRevision);
        final actual = !hecho && estado == paso.$1;
        final color = hecho ? kExito : (actual ? kAviso : kBorde);
        return Expanded(
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(hecho ? Icons.check : paso.$3, color: Colors.white, size: 18),
              ),
              const SizedBox(height: 6),
              Text(
                paso.$2,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: actual ? FontWeight.w700 : FontWeight.w500,
                  color: hecho || actual ? kTinta : kMalva,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
