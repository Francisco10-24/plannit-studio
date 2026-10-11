import 'package:flutter/material.dart';

import '../models/paquete.dart';
import '../shared/theme.dart';
import '../utils/formato.dart';
import 'comunes.dart';

// Card grande estilo Airbnb para un paquete de decoración
class TarjetaPaquete extends StatelessWidget {
  const TarjetaPaquete({super.key, required this.paquete, required this.onTap});

  final Paquete paquete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                FotoRed(url: paquete.imagen, alto: 240),
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
                const Positioned(top: 4, right: 4, child: BotonFavorito()),
                // Puntos del carrusel de fotos
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (i) => Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: i == 0 ? 1 : 0.6),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
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
    );
  }
}

// Corazón de favorito: estado local con setState
class BotonFavorito extends StatefulWidget {
  const BotonFavorito({super.key});

  @override
  State<BotonFavorito> createState() => _BotonFavoritoState();
}

class _BotonFavoritoState extends State<BotonFavorito> {
  bool _favorito = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => setState(() => _favorito = !_favorito),
      icon: Icon(
        _favorito ? Icons.favorite : Icons.favorite_border,
        color: _favorito ? kVino : Colors.white,
        shadows: const [Shadow(blurRadius: 6, color: Colors.black38)],
      ),
    );
  }
}
