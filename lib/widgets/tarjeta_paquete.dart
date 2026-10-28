import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/paquete.dart';
import '../shared/theme.dart';
import '../state/sesion_model.dart';
import '../utils/formato.dart';
import 'comunes.dart';

// Card grande estilo Airbnb para un paquete de decoración
class TarjetaPaquete extends StatefulWidget {
  const TarjetaPaquete({super.key, required this.paquete, required this.onTap});

  final Paquete paquete;
  final VoidCallback onTap;

  @override
  State<TarjetaPaquete> createState() => _TarjetaPaqueteState();
}

class _TarjetaPaqueteState extends State<TarjetaPaquete> {
  bool _presionada = false;

  @override
  Widget build(BuildContext context) {
    final paquete = widget.paquete;
    // Se encoge un poco mientras el dedo está encima: respuesta visual al tocar
    return GestureDetector(
      onTapDown: (_) => setState(() => _presionada = true),
      onTapCancel: () => setState(() => _presionada = false),
      onTapUp: (_) => setState(() => _presionada = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _presionada ? 0.97 : 1,
        duration: const Duration(milliseconds: 150),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  // Hero: la foto "vuela" hasta la pantalla de detalle
                  Hero(
                    tag: 'foto-paquete-${paquete.id}',
                    child: FotoRed(url: paquete.imagen, alto: 240),
                  ),
                  if (paquete.etiqueta.isNotEmpty)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: kSuperficie,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          paquete.etiqueta,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  Positioned(top: 4, right: 4, child: BotonFavorito(paqueteId: paquete.id)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      paquete.nombre,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Icon(Icons.star_rounded, color: kVino, size: 18),
                  Text(' ${paquete.rating} (${paquete.resenas})'),
                ],
              ),
              const SizedBox(height: 2),
              Text('${paquete.decorador} · ${paquete.zona}', style: const TextStyle(color: kMalva)),
              const SizedBox(height: 6),
              Row(
                children: [
                  PuntosColor(colores: paquete.colores),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      paquete.incluye,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: kMalva, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: formatoPrecio(paquete.precio),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    const TextSpan(text: ' por evento', style: TextStyle(color: kMalva)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Corazón de favorito: se guarda en SesionModel y se ve igual en todas las pantallas
class BotonFavorito extends StatelessWidget {
  const BotonFavorito({super.key, required this.paqueteId, this.colorVacio = Colors.white});

  final int paqueteId;
  final Color colorVacio;

  @override
  Widget build(BuildContext context) {
    final favorito = context.watch<SesionModel>().esFavorito(paqueteId);
    return IconButton(
      tooltip: favorito ? 'Quitar de favoritos' : 'Guardar en favoritos',
      onPressed: () => context.read<SesionModel>().alternarFavorito(paqueteId),
      icon: Icon(
        favorito ? Icons.favorite : Icons.favorite_border,
        color: favorito ? kVino : colorVacio,
        shadows: colorVacio == Colors.white
            ? const [Shadow(blurRadius: 6, color: Colors.black38)]
            : null,
      ),
    );
  }
}

// Fila compacta (foto pequeña + datos) para listas como Favoritos o Carrito
class FilaPaquete extends StatelessWidget {
  const FilaPaquete({super.key, required this.paquete, this.onTap, this.trailing});

  final Paquete paquete;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(width: 72, height: 72, child: FotoRed(url: paquete.imagen, radio: 14, alto: 72)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(paquete.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  Text(paquete.decorador, style: const TextStyle(color: kMalva, fontSize: 13)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      PuntosColor(colores: paquete.colores, tamano: 11),
                      const SizedBox(width: 4),
                      Text(formatoPrecio(paquete.precio),
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
            // "?" agrega el widget solo si no es null
            ?trailing,
          ],
        ),
      ),
    );
  }
}
