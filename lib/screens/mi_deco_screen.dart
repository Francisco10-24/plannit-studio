import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/api_client.dart';
import '../data/paquetes_service.dart';
import '../shared/theme.dart';
import '../state/evento_model.dart';
import '../utils/formato.dart';
import '../widgets/comunes.dart';
import 'paquetes_screen.dart';
import 'registro_screen.dart';

// Pantalla 4: resumen del evento, total calculado y envío con POST
class MiDecoScreen extends StatefulWidget {
  const MiDecoScreen({super.key, this.onExplorar});

  // Desde la barra inferior cambia de pestaña; si es null, abre Paquetes
  final VoidCallback? onExplorar;

  @override
  State<MiDecoScreen> createState() => _MiDecoScreenState();
}

class _MiDecoScreenState extends State<MiDecoScreen> {
  bool _enviando = false;

  void _explorar() {
    if (widget.onExplorar != null) {
      widget.onExplorar!();
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const PaquetesScreen()));
    }
  }

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _enviar() async {
    final modelo = context.read<EventoModel>();

    // Se pide cuenta solo al momento de enviar
    if (modelo.usuario == null) {
      final creada = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const RegistroScreen(desdeSolicitud: true)),
      );
      if (creada != true || !mounted) return;
    }

    setState(() => _enviando = true);
    try {
      final resultado = await paquetesService.enviarSolicitud(modelo.solicitudJson());
      // No basta con que "no truene": se revisa el código 201
      if (resultado.codigo == 201) {
        modelo.marcarEnviada(resultado.numero, resultado.info);
        Future.delayed(const Duration(seconds: 3), modelo.avanzarEstado);
      } else {
        _mensaje('Respuesta inesperada del servidor (${resultado.codigo}).');
      }
    } on DioException catch (e) {
      _mensaje(mensajeDeError(e));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final modelo = context.watch<EventoModel>();
    final paquete = modelo.paqueteElegido;

    if (paquete == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mi deco')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.celebration_outlined, size: 56, color: kVino),
                const SizedBox(height: 12),
                const Text('Aún no eliges un paquete',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                const Text('Explora las opciones y arma la decoración de tu evento.',
                    textAlign: TextAlign.center, style: TextStyle(color: kMalva)),
                const SizedBox(height: 20),
                FilledButton(onPressed: _explorar, child: const Text('Explorar paquetes')),
              ],
            ),
          ),
        ),
      );
    }

    final enviada = modelo.estado != EstadoSolicitud.ninguna;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi deco')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          _EncabezadoEvento(modelo: modelo),
          const SizedBox(height: 20),
          const EtiquetaSeccion('Paquete elegido'),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kSuperficie,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kBorde),
            ),
            child: Row(
              children: [
                SizedBox(width: 72, height: 72, child: FotoRed(url: paquete.imagen, radio: 14, alto: 72)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(paquete.nombre, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      Text(paquete.decorador, style: const TextStyle(color: kMalva)),
                      const SizedBox(height: 4),
                      PuntosColor(colores: paquete.colores, tamano: 12),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(formatoPrecio(paquete.precio), style: const TextStyle(fontWeight: FontWeight.w700)),
                    TextButton(onPressed: enviada ? null : _explorar, child: const Text('Cambiar')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const EtiquetaSeccion('Extras'),
          ...modelo.extras.map(
            (extra) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              // Material propio para que el ListTile pinte su fondo y efectos
              child: Material(
                color: kSuperficie,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: kBorde),
                ),
                child: SwitchListTile(
                secondary: SizedBox(width: 48, height: 48, child: FotoRed(url: extra.imagen, radio: 12, alto: 48)),
                title: Text(extra.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${extra.detalle}\n+${formatoPrecio(extra.precio)}',
                    style: const TextStyle(color: kMalva, fontSize: 12)),
                isThreeLine: true,
                value: modelo.extraActivo(extra.id),
                onChanged: enviada ? null : (_) => modelo.alternarExtra(extra.id),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _Resumen(modelo: modelo),
          const SizedBox(height: 20),
          if (enviada) ...[
            const EtiquetaSeccion('Estado de la solicitud'),
            _Seguimiento(estado: modelo.estado),
            const SizedBox(height: 12),
            FranjaHttp(texto: modelo.infoPost),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton.icon(
            onPressed: enviada || _enviando ? null : _enviar,
            icon: _enviando
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(enviada ? Icons.check : Icons.send_outlined),
            label: Text(enviada ? 'Solicitud enviada' : 'Enviar solicitud al decorador'),
          ),
        ),
      ),
    );
  }
}

class _EncabezadoEvento extends StatelessWidget {
  const _EncabezadoEvento({required this.modelo});

  final EventoModel modelo;

  @override
  Widget build(BuildContext context) {
    final titulo = modelo.usuario == null
        ? modelo.tipoEvento
        : '${modelo.tipoEvento} de ${modelo.usuario!.split(' ').first}';
    final cuando = modelo.fecha == null
        ? 'Fecha por definir'
        : '${formatoFecha(modelo.fecha!)} · ${formatoHora(modelo.horaInicio ?? 960)}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: kTinta, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: kVino, borderRadius: BorderRadius.circular(12)),
            child: const Text('TU EVENTO',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 10),
          Text(titulo,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(cuando, style: estiloMono(size: 12, color: Colors.white70)),
            ],
          ),
          if (modelo.espacioM2 != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.square_foot, color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Text('Espacio de ${modelo.espacioM2!.toStringAsFixed(0)} m²',
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Resumen extends StatelessWidget {
  const _Resumen({required this.modelo});

  final EventoModel modelo;

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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: kSuperficie, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          fila('Paquete', modelo.paqueteElegido!.precio),
          fila('Extras', modelo.subtotalExtras),
          fila('Montaje y transporte', EventoModel.costoMontaje),
          const Divider(color: kBorde, height: 20),
          Row(
            children: [
              const Expanded(
                child: Text('Total estimado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              Text(formatoPrecio(modelo.total),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kVino)),
            ],
          ),
          const SizedBox(height: 6),
          const Text('El pago se confirma directamente con el decorador.',
              style: TextStyle(color: kMalva, fontSize: 12)),
        ],
      ),
    );
  }
}

// Seguimiento: Enviada → En revisión → Aprobada
class _Seguimiento extends StatelessWidget {
  const _Seguimiento({required this.estado});

  final EstadoSolicitud estado;

  @override
  Widget build(BuildContext context) {
    const pasos = [
      (EstadoSolicitud.enviada, 'Enviada', Icons.check),
      (EstadoSolicitud.enRevision, 'En revisión', Icons.hourglass_top),
      (EstadoSolicitud.aprobada, 'Aprobada', Icons.verified_outlined),
    ];
    return Row(
      children: pasos.map((paso) {
        // "Enviada" siempre está hecha cuando se muestra el seguimiento
        final hecho = paso.$1 == EstadoSolicitud.enviada || estado.index > paso.$1.index;
        final actual = !hecho && estado == paso.$1;
        final color = hecho ? kExito : (actual ? kAviso : kBorde);
        return Expanded(
          child: Column(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color,
                child: Icon(hecho ? Icons.check : paso.$3, color: Colors.white, size: 18),
              ),
              const SizedBox(height: 6),
              Text(paso.$2,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: actual ? FontWeight.w700 : FontWeight.w500,
                    color: hecho || actual ? kTinta : kMalva,
                  )),
            ],
          ),
        );
      }).toList(),
    );
  }
}
