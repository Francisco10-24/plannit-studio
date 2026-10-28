import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/api_client.dart';
import '../data/cargar_catalogo.dart';
import '../models/catalogo.dart';
import '../models/paquete.dart';
import '../shared/theme.dart';
import '../state/carrito_model.dart';
import '../state/cotizacion_model.dart';
import '../state/navegacion_model.dart';
import '../state/sesion_model.dart';
import '../utils/formato.dart';
import '../widgets/comunes.dart';
import '../widgets/tarjeta_paquete.dart';
import 'cotiza_screen.dart';
import 'decorador_screen.dart';
import 'detalle_paquete_screen.dart';
import 'notificaciones_screen.dart';

// Primera pantalla al abrir la app, estilo Airbnb (no pide cuenta)
class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  static const categorias = [
    ('Cumpleaños', Icons.cake_outlined),
    ('Bodas', Icons.favorite_border),
    ('Quince años', Icons.auto_awesome_outlined),
    ('Baby shower', Icons.child_friendly_outlined),
    ('Graduación', Icons.school_outlined),
    ('Infantil', Icons.toys_outlined),
  ];

  late Future<Catalogo> _futuro;
  String _categoria = 'Cumpleaños';

  @override
  void initState() {
    super.initState();
    // El GET se crea una sola vez, no en cada build
    _futuro = cargarCatalogo(context);
  }

  // Deslizar hacia abajo vuelve a pedir el catálogo
  Future<void> _recargar() {
    final futuro = cargarCatalogo(context);
    setState(() => _futuro = futuro);
    return futuro.then((_) {}, onError: (_) {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<Catalogo>(
        future: _futuro,
        builder: (context, snapshot) {
          final cotizacion = context.watch<CotizacionModel>();
          Catalogo? catalogo;
          Widget? aviso;

          if (snapshot.connectionState == ConnectionState.waiting) {
            catalogo = null; // se muestran tarjetas grises
          } else if (snapshot.hasError) {
            catalogo = cotizacion.ultimoCatalogo;
            final offline = esSinConexion(snapshot.error!) && catalogo != null;
            aviso = BannerEstado(
              tipo: offline ? TipoBanner.aviso : TipoBanner.error,
              mensaje: offline ? textoSinConexion(cotizacion.consultadoEn) : mensajeDeError(snapshot.error!),
              accion: 'Reintentar',
              onAccion: _recargar,
            );
          } else {
            catalogo = snapshot.data;
          }

          final paquetes = catalogo == null
              ? <Paquete>[]
              : catalogo.paquetes.where((p) => p.eventos.contains(_categoria)).toList();

          final encabezado = <Widget>[
            const _Encabezado(),
            _BarraBusqueda(
              onBuscar: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CotizaScreen()),
              ),
              onFiltros: () => context.read<NavegacionModel>().ir(NavegacionModel.explorar),
            ),
            _Categorias(
              seleccionada: _categoria,
              onSeleccion: (c) => setState(() => _categoria = c),
            ),
            const _AvisoCarrito(),
            if (aviso != null) Padding(padding: const EdgeInsets.only(bottom: 16), child: aviso),
            if (catalogo == null && aviso == null) ...[
              const SkeletonTarjeta(),
              const SkeletonTarjeta(),
            ],
            if (catalogo != null && paquetes.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text('Aún no hay paquetes para esta categoría.',
                    textAlign: TextAlign.center, style: TextStyle(color: kMalva)),
              ),
          ];

          // Después del primer paquete va la sección de decoradores
          final conDecoradores = paquetes.isNotEmpty && catalogo!.decoradores.isNotEmpty;

          return RefreshIndicator(
            color: kVino,
            onRefresh: _recargar,
            // ListView.builder: solo construye lo visible
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: encabezado.length + paquetes.length + (conDecoradores ? 1 : 0),
              itemBuilder: (context, i) {
                if (i < encabezado.length) return encabezado[i];
                var posicion = i - encabezado.length;
                if (conDecoradores && posicion == 1) {
                  return _Decoradores(decoradores: catalogo!.decoradores);
                }
                if (conDecoradores && posicion > 1) posicion--;
                final paquete = paquetes[posicion];
                return TarjetaPaquete(
                  paquete: paquete,
                  onTap: () => abrirDetalle(context, paquete),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado();

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<SesionModel>().usuario;
    final noLeidas = context.watch<CarritoModel>().noLeidas;
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      child: Row(
        children: [
          const Text('Plannit',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: kVino)),
          const SizedBox(width: 4),
          const Text('Studio', style: TextStyle(fontSize: 14, color: kMalva)),
          const Spacer(),
          IconButton(
            tooltip: 'Notificaciones',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificacionesScreen()),
            ),
            icon: IconoConContador(icono: Icons.notifications_none, cantidad: noLeidas),
          ),
          InkWell(
            customBorder: const CircleBorder(),
            onTap: () => context.read<NavegacionModel>().ir(NavegacionModel.perfil),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: kVino,
              child: usuario == null
                  ? const Icon(Icons.person, size: 18, color: Colors.white)
                  : Text(usuario.nombre[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarraBusqueda extends StatelessWidget {
  const _BarraBusqueda({required this.onBuscar, required this.onFiltros});

  final VoidCallback onBuscar;
  final VoidCallback onFiltros;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: kSuperficie,
        elevation: 3,
        shadowColor: kVino.withValues(alpha: 0.25),
        shape: const StadiumBorder(side: BorderSide(color: kBorde)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onBuscar,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 8, 10),
            child: Row(
              children: [
                const Icon(Icons.search, color: kTinta),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('¿Qué evento vas a decorar?',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      Text('Cualquier fecha · Cualquier estilo',
                          style: TextStyle(color: kMalva, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Filtros',
                  onPressed: onFiltros,
                  style: IconButton.styleFrom(side: const BorderSide(color: kBorde)),
                  icon: const Icon(Icons.tune, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Categorias extends StatelessWidget {
  const _Categorias({required this.seleccionada, required this.onSeleccion});

  final String seleccionada;
  final ValueChanged<String> onSeleccion;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _InicioScreenState.categorias.map((c) {
          final activa = c.$1 == seleccionada;
          return InkWell(
            onTap: () => onSeleccion(c.$1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: activa ? kVino : Colors.transparent, width: 2),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(c.$2, color: activa ? kVino : kMalva),
                  const SizedBox(height: 4),
                  Text(
                    c.$1,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: activa ? FontWeight.w700 : FontWeight.w500,
                      color: activa ? kTinta : kMalva,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Recordatorio cuando hay eventos esperando en el carrito
class _AvisoCarrito extends StatelessWidget {
  const _AvisoCarrito();

  @override
  Widget build(BuildContext context) {
    final carrito = context.watch<CarritoModel>();
    if (carrito.cantidad == 0) return const SizedBox(height: 12);
    final texto = carrito.cantidad == 1 ? '1 evento' : '${carrito.cantidad} eventos';
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      child: Material(
        color: kTinta,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.read<NavegacionModel>().ir(NavegacionModel.carrito),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Tienes $texto en tu carrito · ${formatoPrecio(carrito.total)}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Decoradores extends StatelessWidget {
  const _Decoradores({required this.decoradores});

  final List<Decorador> decoradores;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 28),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: kRosa, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Decoradores cerca de ti',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          SizedBox(
            height: 128,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: decoradores.length,
              separatorBuilder: (_, _) => const SizedBox(width: 16),
              itemBuilder: (context, i) {
                final d = decoradores[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DecoradorScreen(decorador: d)),
                  ),
                  child: SizedBox(
                    width: 92,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 72,
                          height: 72,
                          child: FotoRed(url: d.imagen, radio: 36, alto: 72),
                        ),
                        const SizedBox(height: 6),
                        Text(d.nombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star_rounded, size: 13, color: kVino),
                            Flexible(
                              child: Text(' ${d.rating} · ${d.zona}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: kMalva, fontSize: 11)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
