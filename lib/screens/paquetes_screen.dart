import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/api_client.dart';
import '../data/cargar_catalogo.dart';
import '../models/catalogo.dart';
import '../models/paquete.dart';
import '../shared/theme.dart';
import '../state/cotizacion_model.dart';
import '../utils/filtros.dart';
import '../utils/formato.dart';
import '../widgets/comunes.dart';
import '../widgets/tarjeta_paquete.dart';
import 'detalle_paquete_screen.dart';

// Explorar: lista de paquetes obtenida con GET (HTTPS), con búsqueda y filtros
class PaquetesScreen extends StatefulWidget {
  const PaquetesScreen({
    super.key,
    this.esPestana = false,
    this.desdeCotizacion = false,
    this.estiloInicial,
  });

  // true cuando vive en la barra inferior (sin flecha de regreso)
  final bool esPestana;

  // true cuando se abre desde "Cotiza tu deco": usa sus datos como filtros
  final bool desdeCotizacion;

  // Estilo preseleccionado (por ejemplo desde una búsqueda reciente)
  final String? estiloInicial;

  @override
  State<PaquetesScreen> createState() => _PaquetesScreenState();
}

class _PaquetesScreenState extends State<PaquetesScreen> {
  static const estilos = ['Glam', 'Boho', 'Minimal', 'Temática'];
  static const tipos = ['Cumpleaños', 'Bodas', 'Quince años', 'Baby shower', 'Graduación', 'Infantil'];

  final _buscadorCtrl = TextEditingController();
  late Future<Catalogo> _futuro;

  String? _estilo;
  String? _tipo;
  double? _precioMin;
  double? _precioMax;
  Orden _orden = Orden.recomendados;
  bool _usaCotizacion = false;

  @override
  void initState() {
    super.initState();
    _futuro = cargarCatalogo(context);
    _estilo = widget.estiloInicial;

    // Los datos de la cotización se convierten en filtros
    final cotizacion = context.read<CotizacionModel>();
    if (widget.desdeCotizacion && cotizacion.tieneCotizacion) {
      _usaCotizacion = true;
      _estilo = cotizacion.estilo;
      _tipo = cotizacion.tipoEvento;
      _precioMin = cotizacion.presupuestoMin;
      _precioMax = cotizacion.presupuestoMax;
    }
  }

  @override
  void dispose() {
    _buscadorCtrl.dispose();
    super.dispose();
  }

  Future<void> _recargar() {
    final futuro = cargarCatalogo(context);
    setState(() => _futuro = futuro);
    return futuro.then((_) {}, onError: (_) {});
  }

  void _quitarFiltros() {
    setState(() {
      _usaCotizacion = false;
      _estilo = null;
      _tipo = null;
      _precioMin = null;
      _precioMax = null;
      _orden = Orden.recomendados;
      _buscadorCtrl.clear();
    });
  }

  int get _filtrosActivos =>
      [_tipo, _precioMax, _orden == Orden.recomendados ? null : _orden].where((f) => f != null).length;

  Future<void> _abrirFiltros() async {
    final resultado = await showModalBottomSheet<_Filtros>(
      context: context,
      isScrollControlled: true,
      backgroundColor: kFondo,
      showDragHandle: true,
      builder: (_) => _HojaFiltros(
        inicial: _Filtros(tipo: _tipo, precioMax: _precioMax, orden: _orden),
      ),
    );
    if (resultado == null) return;
    setState(() {
      _tipo = resultado.tipo;
      _precioMax = resultado.precioMax;
      _orden = resultado.orden;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cotizacion = context.watch<CotizacionModel>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.esPestana,
        title: const Text('Explorar paquetes'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Buscador
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _buscadorCtrl,
                    onChanged: (_) => setState(() {}),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Buscar paquete, decorador o zona',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _buscadorCtrl.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Borrar búsqueda',
                              icon: const Icon(Icons.close),
                              onPressed: () => setState(_buscadorCtrl.clear),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: 'Filtros',
                  onPressed: _abrirFiltros,
                  style: IconButton.styleFrom(backgroundColor: kRosa, minimumSize: const Size(52, 52)),
                  icon: IconoConContador(icono: Icons.tune, cantidad: _filtrosActivos),
                ),
              ],
            ),
          ),
          // Chips de estilo
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [null, ...estilos].map((e) {
                final activo = _estilo == e;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(e ?? 'Todos'),
                    selected: activo,
                    onSelected: (_) => setState(() => _estilo = e),
                    labelStyle: TextStyle(color: activo ? Colors.white : kTinta),
                  ),
                );
              }).toList(),
            ),
          ),
          if (_usaCotizacion && cotizacion.tieneCotizacion)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: BannerEstado(
                tipo: TipoBanner.exito,
                mensaje: 'Según tu cotización: ${cotizacion.tipoEvento} · '
                    '${formatoPrecio(cotizacion.presupuestoMin ?? 0)}–${formatoPrecio(cotizacion.presupuestoMax ?? 0)}',
                accion: 'Quitar',
                onAccion: _quitarFiltros,
              ),
            ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<Catalogo>(
              future: _futuro,
              builder: (context, snapshot) {
                // 1) Esperando respuesta
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: const [SkeletonTarjeta(), SkeletonTarjeta()],
                  );
                }

                // 2) Error: se distingue el tipo de DioException
                if (snapshot.hasError) {
                  final guardado = cotizacion.ultimoCatalogo;
                  if (esSinConexion(snapshot.error!) && guardado != null) {
                    return _lista(
                      guardado.paquetes,
                      aviso: BannerEstado(
                        tipo: TipoBanner.aviso,
                        mensaje: textoSinConexion(cotizacion.consultadoEn),
                        accion: 'Reintentar',
                        onAccion: _recargar,
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: BannerEstado(
                      tipo: esSinConexion(snapshot.error!) ? TipoBanner.aviso : TipoBanner.error,
                      mensaje: mensajeDeError(snapshot.error!),
                      accion: 'Reintentar',
                      onAccion: _recargar,
                    ),
                  );
                }

                // 3) Datos recibidos
                return _lista(snapshot.data!.paquetes);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _lista(List<Paquete> todos, {Widget? aviso}) {
    final filtrados = filtrarPaquetes(
      todos,
      texto: _buscadorCtrl.text,
      estilo: _estilo,
      tipo: _tipo,
      precioMin: _precioMin,
      precioMax: _precioMax,
      orden: _orden,
    );

    return RefreshIndicator(
      color: kVino,
      onRefresh: _recargar,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filtrados.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (aviso != null) ...[aviso, const SizedBox(height: 12)],
                  Text(
                    filtrados.length == 1 ? '1 paquete' : '${filtrados.length} paquetes',
                    style: const TextStyle(color: kMalva, fontWeight: FontWeight.w600),
                  ),
                  if (filtrados.isEmpty)
                    SizedBox(
                      height: 320,
                      child: EstadoVacio(
                        icono: Icons.search_off,
                        titulo: 'No encontramos paquetes',
                        mensaje: 'Prueba con otra palabra o quita algunos filtros.',
                        accion: 'Quitar filtros',
                        onAccion: _quitarFiltros,
                      ),
                    ),
                ],
              ),
            );
          }
          final paquete = filtrados[i - 1];
          return TarjetaPaquete(paquete: paquete, onTap: () => abrirDetalle(context, paquete));
        },
      ),
    );
  }
}

// Valores que devuelve la hoja de filtros
class _Filtros {
  const _Filtros({this.tipo, this.precioMax, this.orden = Orden.recomendados});

  final String? tipo;
  final double? precioMax;
  final Orden orden;
}

class _HojaFiltros extends StatefulWidget {
  const _HojaFiltros({required this.inicial});

  final _Filtros inicial;

  @override
  State<_HojaFiltros> createState() => _HojaFiltrosState();
}

class _HojaFiltrosState extends State<_HojaFiltros> {
  static const precioTope = 500.0;

  late String? _tipo = widget.inicial.tipo;
  late double _precioMax = widget.inicial.precioMax ?? precioTope;
  late Orden _orden = widget.inicial.orden;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filtros', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            const EtiquetaSeccion('Tipo de evento'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [null, ..._PaquetesScreenState.tipos].map((t) {
                final activo = _tipo == t;
                return ChoiceChip(
                  label: Text(t ?? 'Todos'),
                  selected: activo,
                  onSelected: (_) => setState(() => _tipo = t),
                  labelStyle: TextStyle(color: activo ? Colors.white : kTinta),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            EtiquetaSeccion(
              _precioMax >= precioTope ? 'Precio máximo: sin límite' : 'Precio máximo: ${formatoPrecio(_precioMax)}',
            ),
            Slider(
              value: _precioMax,
              min: 100,
              max: precioTope,
              divisions: 16,
              activeColor: kVino,
              label: formatoPrecio(_precioMax),
              onChanged: (v) => setState(() => _precioMax = v),
            ),
            const SizedBox(height: 8),
            const EtiquetaSeccion('Ordenar por'),
            RadioGroup<Orden>(
              groupValue: _orden,
              onChanged: (o) => setState(() => _orden = o ?? Orden.recomendados),
              child: Column(
                children: Orden.values
                    .map((o) => RadioListTile<Orden>(
                          value: o,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          activeColor: kVino,
                          title: Text(nombresOrden[o]!),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () => Navigator.pop(context, const _Filtros()),
                    child: const Text('Limpiar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(
                      context,
                      _Filtros(
                        tipo: _tipo,
                        precioMax: _precioMax >= precioTope ? null : _precioMax,
                        orden: _orden,
                      ),
                    ),
                    child: const Text('Aplicar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
