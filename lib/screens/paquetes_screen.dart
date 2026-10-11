import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/api_client.dart';
import '../data/paquetes_service.dart';
import '../models/catalogo.dart';
import '../models/paquete.dart';
import '../shared/theme.dart';
import '../state/evento_model.dart';
import '../utils/formato.dart';
import '../widgets/comunes.dart';
import '../widgets/tarjeta_paquete.dart';
import 'inicio_screen.dart' show textoGuardado;
import 'mi_deco_screen.dart';

// Pantalla 3: lista de paquetes obtenida con GET (HTTPS)
class PaquetesScreen extends StatefulWidget {
  const PaquetesScreen({super.key, this.estiloInicial, this.mostrarAtras = true});

  final String? estiloInicial;
  final bool mostrarAtras;

  @override
  State<PaquetesScreen> createState() => _PaquetesScreenState();
}

class _PaquetesScreenState extends State<PaquetesScreen> {
  static const _estilos = ['Todos', 'Glam', 'Boho', 'Minimal', 'Temática'];

  late Future<Catalogo> _futuro;
  late String _estilo;

  @override
  void initState() {
    super.initState();
    _estilo = widget.estiloInicial ?? 'Todos';
    _futuro = _cargar();
  }

  Future<Catalogo> _cargar() async {
    final catalogo = await paquetesService.obtenerCatalogo();
    if (mounted) context.read<EventoModel>().guardarCatalogo(catalogo, DateTime.now());
    return catalogo;
  }

  void _reintentar() => setState(() => _futuro = _cargar());

  void _abrir(Paquete paquete) {
    context.read<EventoModel>().elegirPaquete(paquete);
    Navigator.push(context, MaterialPageRoute(builder: (_) => const MiDecoScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final modelo = context.watch<EventoModel>();
    final resumen = modelo.fecha == null
        ? 'Todos los eventos · San Salvador'
        : '${modelo.tipoEvento} · ${modelo.estilo} · ${formatoFecha(modelo.fecha!)}'
            ' · ${formatoPrecio(modelo.presupuestoMin ?? 0)}–${formatoPrecio(modelo.presupuestoMax ?? 0)}';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.mostrarAtras,
        title: const Text('Paquetes de deco'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(resumen, style: estiloMono(color: kMalva)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: _estilos
                  .map((e) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(e),
                          selected: _estilo == e,
                          onSelected: (_) => setState(() => _estilo = e),
                          labelStyle: TextStyle(color: _estilo == e ? Colors.white : kTinta),
                        ),
                      ))
                  .toList(),
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
                  final guardado = modelo.ultimoCatalogo;
                  if (esSinConexion(snapshot.error!) && guardado != null) {
                    return _lista(
                      guardado.paquetes,
                      cabecera: BannerEstado(
                        tipo: TipoBanner.aviso,
                        mensaje: textoGuardado(modelo.consultadoEn),
                        accion: 'Reintentar',
                        onAccion: _reintentar,
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: BannerEstado(
                      tipo: esSinConexion(snapshot.error!) ? TipoBanner.aviso : TipoBanner.error,
                      mensaje: mensajeDeError(snapshot.error!),
                      accion: 'Reintentar',
                      onAccion: _reintentar,
                    ),
                  );
                }

                // 3) Datos recibidos
                final catalogo = snapshot.data!;
                return _lista(catalogo.paquetes, cabecera: FranjaHttp(texto: catalogo.infoHttp));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _lista(List<Paquete> todos, {required Widget cabecera}) {
    final filtrados =
        _estilo == 'Todos' ? todos : todos.where((p) => p.estilo == _estilo).toList();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filtrados.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                cabecera,
                if (filtrados.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Text('No hay paquetes con este estilo.', style: TextStyle(color: kMalva)),
                  ),
              ],
            ),
          );
        }
        final paquete = filtrados[i - 1];
        return TarjetaPaquete(paquete: paquete, onTap: () => _abrir(paquete));
      },
    );
  }
}
