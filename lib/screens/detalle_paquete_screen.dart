import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/catalogo.dart';
import '../models/paquete.dart';
import '../shared/theme.dart';
import '../state/carrito_model.dart';
import '../state/cotizacion_model.dart';
import '../state/navegacion_model.dart';
import '../utils/formato.dart';
import '../utils/validadores.dart';
import '../widgets/campo_texto.dart';
import '../widgets/comunes.dart';
import '../widgets/tarjeta_paquete.dart';
import 'decorador_screen.dart';

// Atajo para abrir el detalle desde cualquier lista
void abrirDetalle(BuildContext context, Paquete paquete) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => DetallePaqueteScreen(paquete: paquete)));
}

// Ficha completa de un paquete con el botón "Agregar al carrito"
class DetallePaqueteScreen extends StatelessWidget {
  const DetallePaqueteScreen({super.key, required this.paquete});

  final Paquete paquete;

  Decorador? _decorador(BuildContext context) {
    final catalogo = context.read<CotizacionModel>().ultimoCatalogo;
    if (catalogo == null) return null;
    for (final d in catalogo.decoradores) {
      if (d.nombre == paquete.decorador) return d;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final decorador = _decorador(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: kFondo,
            foregroundColor: kTinta,
            leading: const Padding(
              padding: EdgeInsets.all(6),
              child: CircleAvatar(backgroundColor: kSuperficie, child: BackButton(color: kTinta)),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(6),
                child: CircleAvatar(
                  backgroundColor: kSuperficie,
                  child: BotonFavorito(paqueteId: paquete.id, colorVacio: kTinta),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'foto-paquete-${paquete.id}',
                child: FotoRed(url: paquete.imagen, radio: 0, alto: 320),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            sliver: SliverList.list(
              children: [
                Text(paquete.nombre, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: kVino, size: 20),
                    Text(' ${paquete.rating}', style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(' · ${paquete.resenas} reseñas · ${paquete.zona}',
                        style: const TextStyle(color: kMalva)),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Etiqueta(texto: paquete.estilo, icono: Icons.palette_outlined),
                    ...paquete.eventos.map((e) => _Etiqueta(texto: e, icono: Icons.celebration_outlined)),
                  ],
                ),
                const Divider(height: 36, color: kBorde),
                // Decorador
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: decorador == null
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => DecoradorScreen(decorador: decorador)),
                          ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 52,
                        height: 52,
                        child: FotoRed(url: decorador?.imagen ?? '', radio: 26, alto: 52),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Decorado por ${paquete.decorador}',
                                style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text(decorador?.descripcion ?? paquete.zona,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: kMalva, fontSize: 13)),
                          ],
                        ),
                      ),
                      if (decorador != null) const Icon(Icons.chevron_right, color: kMalva),
                    ],
                  ),
                ),
                const Divider(height: 36, color: kBorde),
                if (paquete.descripcion.isNotEmpty) ...[
                  Text(paquete.descripcion, style: const TextStyle(fontSize: 16, height: 1.5)),
                  const SizedBox(height: 24),
                ],
                const Text('Qué incluye', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                ...(paquete.detalles.isEmpty ? [paquete.incluye] : paquete.detalles).map(
                  (d) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle, color: kExito, size: 20),
                        const SizedBox(width: 10),
                        Expanded(child: Text(d, style: const TextStyle(fontSize: 15))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Paleta de colores', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                PuntosColor(colores: paquete.colores, tamano: 30),
                const SizedBox(height: 24),
                const BannerEstado(
                  tipo: TipoBanner.exito,
                  mensaje: 'Puedes sumar extras como luces, mesa de postres o photo booth desde tu carrito.',
                ),
              ],
            ),
          ),
        ],
      ),
      // Barra fija inferior: precio + botón, como Airbnb
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: const BoxDecoration(
            color: kSuperficie,
            border: Border(top: BorderSide(color: kBorde)),
          ),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(formatoPrecio(paquete.precio),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const Text('por evento', style: TextStyle(color: kMalva, fontSize: 12)),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => agregarAlCarrito(context, paquete),
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Agregar al carrito'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta({required this.texto, required this.icono});

  final String texto;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: kRosa, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 16, color: kVino),
          const SizedBox(width: 6),
          Text(texto, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}

// ---------------- Agregar al carrito ----------------

// Abre el formulario del evento y, si todo es válido, agrega al carrito
Future<void> agregarAlCarrito(BuildContext context, Paquete paquete) async {
  final datos = await showModalBottomSheet<_DatosEvento>(
    context: context,
    isScrollControlled: true,
    backgroundColor: kFondo,
    showDragHandle: true,
    builder: (_) => _HojaEvento(paquete: paquete),
  );
  if (datos == null || !context.mounted) return;

  final carrito = context.read<CarritoModel>();
  final mismoDia = carrito.eventoEnFecha(datos.fecha);

  // Regla de la ficha: un evento tiene un solo paquete, no se duplica la reserva
  if (mismoDia != null) {
    final reemplazar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ya tienes un evento ese día'),
        content: Text(
          '"${mismoDia.nombre}" del ${formatoFecha(mismoDia.fecha)} ya tiene el paquete '
          '${mismoDia.paquete.nombre}. Cada evento puede tener un solo paquete.\n\n'
          '¿Quieres reemplazarlo por ${paquete.nombre}?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reemplazar')),
        ],
      ),
    );
    if (reemplazar != true || !context.mounted) return;
    carrito.reemplazarPaquete(mismoDia.id, paquete);
  } else {
    carrito.agregar(
      nombre: datos.nombre,
      tipo: datos.tipo,
      fecha: datos.fecha,
      hora: datos.hora,
      paquete: paquete,
    );
  }

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(mismoDia != null ? 'Paquete reemplazado en tu carrito' : 'Agregado a tu carrito'),
        action: SnackBarAction(
          label: 'Ver carrito',
          onPressed: () {
            context.read<NavegacionModel>().ir(NavegacionModel.carrito);
            Navigator.popUntil(context, (ruta) => ruta.isFirst);
          },
        ),
      ),
    );
}

class _DatosEvento {
  const _DatosEvento({required this.nombre, required this.tipo, required this.fecha, required this.hora});

  final String nombre;
  final String tipo;
  final DateTime fecha;
  final int hora;
}

// Formulario corto del evento (con validación) antes de agregar al carrito
class _HojaEvento extends StatefulWidget {
  const _HojaEvento({required this.paquete});

  final Paquete paquete;

  @override
  State<_HojaEvento> createState() => _HojaEventoState();
}

class _HojaEventoState extends State<_HojaEvento> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _fechaCtrl = TextEditingController();
  final _horaCtrl = TextEditingController();

  late String _tipo;
  DateTime? _fecha;
  int? _hora;

  @override
  void initState() {
    super.initState();
    _tipo = widget.paquete.eventos.first;

    // Si el usuario ya cotizó, se reutilizan esos datos
    final cotizacion = context.read<CotizacionModel>();
    if (cotizacion.tieneCotizacion) {
      if (widget.paquete.eventos.contains(cotizacion.tipoEvento)) _tipo = cotizacion.tipoEvento;
      _fecha = cotizacion.fecha;
      _hora = cotizacion.horaInicio;
      if (_fecha != null) _fechaCtrl.text = formatoFecha(_fecha!);
      if (_hora != null) _horaCtrl.text = formatoHora(_hora!);
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _fechaCtrl.dispose();
    _horaCtrl.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final hoy = DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha ?? hoy.add(const Duration(days: 30)),
      firstDate: hoy,
      lastDate: hoy.add(const Duration(days: 730)),
    );
    if (elegida == null) return;
    setState(() {
      _fecha = elegida;
      _fechaCtrl.text = formatoFecha(elegida);
    });
  }

  Future<void> _elegirHora() async {
    final hora = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 16, minute: 0));
    if (hora == null) return;
    setState(() {
      _hora = hora.hour * 60 + hora.minute;
      _horaCtrl.text = formatoHora(_hora!);
    });
  }

  void _confirmar() {
    if (!_formKey.currentState!.validate()) return;
    final nombre = _nombreCtrl.text.trim();
    Navigator.pop(
      context,
      _DatosEvento(
        nombre: nombre.isEmpty ? _tipo : nombre,
        tipo: _tipo,
        fecha: _fecha!,
        hora: _hora!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Sube el formulario cuando aparece el teclado
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Datos de tu evento', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(widget.paquete.nombre, style: const TextStyle(color: kMalva)),
              const SizedBox(height: 20),
              const EtiquetaSeccion('Tipo de evento'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.paquete.eventos.map((t) {
                  final activo = _tipo == t;
                  return ChoiceChip(
                    label: Text(t),
                    selected: activo,
                    onSelected: (_) => setState(() => _tipo = t),
                    labelStyle: TextStyle(color: activo ? Colors.white : kTinta),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              CampoTexto(
                etiqueta: 'Nombre del evento (opcional)',
                controller: _nombreCtrl,
                hint: 'Ej. Cumpleaños de Andrea',
                icono: Icons.edit_outlined,
                validator: (v) => (v ?? '').trim().length > 40 ? 'Máximo 40 caracteres' : null,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CampoTexto(
                      etiqueta: 'Fecha',
                      controller: _fechaCtrl,
                      hint: 'Elegir fecha',
                      icono: Icons.calendar_today_outlined,
                      soloLectura: true,
                      onTap: _elegirFecha,
                      validator: (_) => validarFecha(_fecha, DateTime.now()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CampoTexto(
                      etiqueta: 'Hora',
                      controller: _horaCtrl,
                      hint: 'Elegir hora',
                      icono: Icons.schedule,
                      soloLectura: true,
                      onTap: _elegirHora,
                      validator: (_) => validarHoraInicio(_hora),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _confirmar,
                icon: const Icon(Icons.add_shopping_cart),
                label: Text('Agregar · ${formatoPrecio(widget.paquete.precio)}'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
