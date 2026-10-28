import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/api_client.dart';
import '../data/paquetes_service.dart';
import '../models/solicitud.dart';
import '../shared/theme.dart';
import '../state/carrito_model.dart';
import '../state/navegacion_model.dart';
import '../state/sesion_model.dart';
import '../utils/formato.dart';
import '../widgets/comunes.dart';
import '../widgets/tarjeta_paquete.dart';
import 'detalle_paquete_screen.dart';
import 'registro_screen.dart';
import 'solicitudes_screen.dart';

// Carrito: varios eventos, cada uno con su paquete y sus extras
class CarritoScreen extends StatefulWidget {
  const CarritoScreen({super.key});

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  bool _enviando = false;

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  void _quitar(EventoCarrito evento) {
    final carrito = context.read<CarritoModel>();
    carrito.quitar(evento.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Quitaste "${evento.nombre}"'),
          action: SnackBarAction(label: 'Deshacer', onPressed: () => carrito.restaurar(evento)),
        ),
      );
  }

  Future<void> _enviar() async {
    final carrito = context.read<CarritoModel>();
    final sesion = context.read<SesionModel>();

    // La cuenta se pide solo al momento de enviar
    if (!sesion.conSesion) {
      final lista = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const RegistroScreen(desdeSolicitud: true)),
      );
      if (lista != true || !mounted) return;
    }

    setState(() => _enviando = true);
    var enviados = 0;
    try {
      // Un POST por evento. Se copia la lista porque el carrito cambia al enviar.
      for (final evento in List.of(carrito.eventos)) {
        final resultado = await paquetesService.enviarSolicitud(
          carrito.solicitudJson(evento, sesion.usuario!.nombre),
        );
        // No basta con que "no truene": se revisa el código 201 Created
        if (resultado.codigo != 201) {
          _mensaje('Respuesta inesperada del servidor (${resultado.codigo}).');
          break;
        }
        carrito.registrarEnviado(evento, resultado.numero);
        enviados++;

        // Simulación del decorador: revisa a los 4 s y aprueba a los 10 s
        Future.delayed(const Duration(seconds: 4), () => carrito.avanzarSolicitud(resultado.numero));
        Future.delayed(const Duration(seconds: 10), () => carrito.avanzarSolicitud(resultado.numero));
      }
    } on DioException catch (e) {
      _mensaje(mensajeDeError(e));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }

    if (enviados > 0 && mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SolicitudesScreen(recienEnviadas: true)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final carrito = context.watch<CarritoModel>();

    if (carrito.cantidad == 0) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Tu carrito'),
          actions: [_botonSolicitudes(context, carrito)],
        ),
        body: EstadoVacio(
          icono: Icons.shopping_bag_outlined,
          titulo: 'Tu carrito está vacío',
          mensaje: 'Agrega paquetes de decoración para uno o varios eventos y envíalos juntos.',
          accion: 'Explorar paquetes',
          onAccion: () => context.read<NavegacionModel>().ir(NavegacionModel.explorar),
        ),
      );
    }

    final texto = carrito.cantidad == 1 ? '1 evento' : '${carrito.cantidad} eventos';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Tu carrito'),
        actions: [_botonSolicitudes(context, carrito)],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Text(texto, style: const TextStyle(color: kMalva, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...carrito.eventos.map(
            (evento) => _TarjetaEvento(
              evento: evento,
              bloqueado: _enviando,
              onQuitar: () => _quitar(evento),
            ),
          ),
          _Resumen(carrito: carrito),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton.icon(
            onPressed: _enviando ? null : _enviar,
            icon: _enviando
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.send_outlined),
            label: Text(carrito.cantidad == 1
                ? 'Enviar solicitud · ${formatoPrecio(carrito.total)}'
                : 'Enviar ${carrito.cantidad} solicitudes · ${formatoPrecio(carrito.total)}'),
          ),
        ),
      ),
    );
  }

  Widget _botonSolicitudes(BuildContext context, CarritoModel carrito) {
    if (carrito.solicitudes.isEmpty) return const SizedBox.shrink();
    return TextButton.icon(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SolicitudesScreen()),
      ),
      icon: const Icon(Icons.receipt_long_outlined),
      label: const Text('Mis solicitudes'),
    );
  }
}

// Un evento del carrito: encabezado, paquete, extras y subtotal
class _TarjetaEvento extends StatelessWidget {
  const _TarjetaEvento({required this.evento, required this.bloqueado, required this.onQuitar});

  final EventoCarrito evento;
  final bool bloqueado;
  final VoidCallback onQuitar;

  @override
  Widget build(BuildContext context) {
    final carrito = context.watch<CarritoModel>();
    final activos = evento.extras.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: kSuperficie,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kBorde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado oscuro del evento
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 14, 8, 14),
            decoration: const BoxDecoration(
              color: kTinta,
              borderRadius: BorderRadius.vertical(top: Radius.circular(23)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(evento.nombre,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text('${evento.tipo} · ${formatoFecha(evento.fecha)} · ${formatoHora(evento.hora)}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Quitar del carrito',
                  onPressed: bloqueado ? null : onQuitar,
                  icon: const Icon(Icons.delete_outline, color: Colors.white70),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
            child: FilaPaquete(
              paquete: evento.paquete,
              onTap: () => abrirDetalle(context, evento.paquete),
            ),
          ),
          // Extras de este evento (se calculan aparte de los otros eventos)
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 18),
              iconColor: kVino,
              title: Text(activos == 0 ? 'Agregar extras' : 'Extras ($activos)',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(
                activos == 0 ? 'Luces, photo booth, mesa de postres...' : '+${formatoPrecio(carrito.subtotalExtras(evento))}',
                style: const TextStyle(color: kMalva, fontSize: 12),
              ),
              children: carrito.extrasCatalogo
                  .map(
                    (extra) => SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18),
                      secondary: SizedBox(
                        width: 44,
                        height: 44,
                        child: FotoRed(url: extra.imagen, radio: 10, alto: 44),
                      ),
                      title: Text(extra.nombre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text('${extra.detalle} · +${formatoPrecio(extra.precio)}',
                          style: const TextStyle(color: kMalva, fontSize: 12)),
                      value: evento.extras.contains(extra.id),
                      onChanged: bloqueado ? null : (_) => carrito.alternarExtra(evento.id, extra.id),
                    ),
                  )
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Subtotal del evento (incluye montaje)', style: TextStyle(color: kMalva)),
                ),
                Text(formatoPrecio(carrito.totalEvento(evento)),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Resumen extends StatelessWidget {
  const _Resumen({required this.carrito});

  final CarritoModel carrito;

  @override
  Widget build(BuildContext context) {
    Widget fila(String texto, double valor) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Expanded(child: Text(texto, style: const TextStyle(color: kMalva))),
              Text(formatoPrecio(valor)),
            ],
          ),
        );

    // Sumas por concepto con fold, igual que el total
    final paquetes = carrito.eventos.fold(0.0, (suma, e) => suma + e.paquete.precio);
    final extras = carrito.eventos.fold(0.0, (suma, e) => suma + carrito.subtotalExtras(e));
    final montaje = carrito.cantidad * CarritoModel.costoMontaje;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: kRosa, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          fila('Paquetes', paquetes),
          fila('Extras', extras),
          fila('Montaje y transporte', montaje),
          const Divider(color: kBorde, height: 22),
          Row(
            children: [
              const Expanded(
                child: Text('Total estimado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              Text(formatoPrecio(carrito.total),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: kVino)),
            ],
          ),
          const SizedBox(height: 6),
          const Text('El pago se confirma directamente con cada decorador.',
              style: TextStyle(color: kMalva, fontSize: 12)),
        ],
      ),
    );
  }
}
