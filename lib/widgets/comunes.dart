import 'package:flutter/material.dart';

import '../shared/theme.dart';
import '../utils/formato.dart';

// Foto desde internet con fondo mientras carga y ícono si falla (sin conexión)
class FotoRed extends StatelessWidget {
  const FotoRed({super.key, required this.url, this.radio = 20, this.alto});

  final String url;
  final double radio;
  final double? alto;

  @override
  Widget build(BuildContext context) {
    final vacio = Container(
      height: alto,
      color: kRosa,
      alignment: Alignment.center,
      child: const Icon(Icons.celebration_outlined, color: kVino, size: 32),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(radio),
      child: url.isEmpty
          ? vacio
          : Image.network(
              url,
              height: alto,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progreso) =>
                  progreso == null ? child : Container(height: alto, color: kBorde),
              errorBuilder: (context, error, stack) => vacio,
            ),
    );
  }
}

// Fila de círculos con la paleta de la decoración
class PuntosColor extends StatelessWidget {
  const PuntosColor({super.key, required this.colores, this.tamano = 14});

  final List<String> colores;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: colores
          .map(
            (hex) => Container(
              width: tamano,
              height: tamano,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: colorDesdeHex(hex),
                shape: BoxShape.circle,
                border: Border.all(color: kBorde),
              ),
            ),
          )
          .toList(),
    );
  }
}

// Pantalla vacía con ícono, explicación y una acción para salir de ahí
class EstadoVacio extends StatelessWidget {
  const EstadoVacio({
    super.key,
    required this.icono,
    required this.titulo,
    required this.mensaje,
    this.accion,
    this.onAccion,
  });

  final IconData icono;
  final String titulo;
  final String mensaje;
  final String? accion;
  final VoidCallback? onAccion;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: kRosa, shape: BoxShape.circle),
              child: Icon(icono, size: 40, color: kVino),
            ),
            const SizedBox(height: 16),
            Text(titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(mensaje, textAlign: TextAlign.center, style: const TextStyle(color: kMalva)),
            if (accion != null) ...[
              const SizedBox(height: 20),
              FilledButton(onPressed: onAccion, child: Text(accion!)),
            ],
          ],
        ),
      ),
    );
  }
}

// Ícono con un circulito rojo y el número (carrito, notificaciones)
class IconoConContador extends StatelessWidget {
  const IconoConContador({super.key, required this.icono, required this.cantidad});

  final IconData icono;
  final int cantidad;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: cantidad > 0,
      label: Text('$cantidad'),
      backgroundColor: kVino,
      child: Icon(icono),
    );
  }
}

enum TipoBanner { error, aviso, exito }

// Banner de estado: errores de validación, sin conexión, etc.
class BannerEstado extends StatelessWidget {
  const BannerEstado({
    super.key,
    required this.tipo,
    required this.mensaje,
    this.accion,
    this.onAccion,
  });

  final TipoBanner tipo;
  final String mensaje;
  final String? accion;
  final VoidCallback? onAccion;

  @override
  Widget build(BuildContext context) {
    final color = switch (tipo) {
      TipoBanner.error => kError,
      TipoBanner.aviso => kAviso,
      TipoBanner.exito => kExito,
    };
    final icono = switch (tipo) {
      TipoBanner.error => Icons.error_outline,
      TipoBanner.aviso => Icons.wifi_off_rounded,
      TipoBanner.exito => Icons.check_circle_outline,
    };
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icono, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(mensaje, style: TextStyle(color: color, fontWeight: FontWeight.w500))),
          if (accion != null)
            OutlinedButton(
              onPressed: onAccion,
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color),
                shape: const StadiumBorder(),
              ),
              child: Text(accion!),
            ),
        ],
      ),
    );
  }
}

// Tarjeta gris del mismo tamaño que la real, mientras llega la respuesta
class SkeletonTarjeta extends StatelessWidget {
  const SkeletonTarjeta({super.key});

  @override
  Widget build(BuildContext context) {
    Widget barra(double ancho) => Container(
          width: ancho,
          height: 14,
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(color: kBorde, borderRadius: BorderRadius.circular(7)),
        );
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(color: kBorde, borderRadius: BorderRadius.circular(20)),
          ),
          barra(200),
          barra(140),
          barra(90),
        ],
      ),
    );
  }
}

// Etiqueta pequeña en mayúsculas sobre los campos y secciones
class EtiquetaSeccion extends StatelessWidget {
  const EtiquetaSeccion(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        texto.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: kMalva,
        ),
      ),
    );
  }
}
