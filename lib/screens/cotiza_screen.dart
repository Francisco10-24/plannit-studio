import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../shared/theme.dart';
import '../state/evento_model.dart';
import '../utils/formato.dart';
import '../utils/validadores.dart';
import '../widgets/campo_texto.dart';
import '../widgets/comunes.dart';
import 'paquetes_screen.dart';

// Pantalla 2: formulario con validación cruzada entre campos
class CotizaScreen extends StatefulWidget {
  const CotizaScreen({super.key});

  @override
  State<CotizaScreen> createState() => _CotizaScreenState();
}

class _CotizaScreenState extends State<CotizaScreen> {
  static const _tipos = ['Cumpleaños', 'Bodas', 'Quince años', 'Baby shower', 'Graduación'];
  static const _estilos = ['Boho', 'Glam', 'Minimal', 'Temática'];

  // La llave va en el State, nunca dentro de build()
  final _formKey = GlobalKey<FormState>();

  final _fechaCtrl = TextEditingController();
  final _inicioCtrl = TextEditingController();
  final _montajeCtrl = TextEditingController();
  final _espacioCtrl = TextEditingController();
  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();

  String _tipo = 'Cumpleaños';
  String _estilo = 'Glam';
  DateTime? _fecha;
  int? _inicio; // minutos desde medianoche
  int? _finMontaje;
  bool _arcoXL = false;
  bool _intentado = false;
  int _errores = 0;

  @override
  void dispose() {
    _fechaCtrl.dispose();
    _inicioCtrl.dispose();
    _montajeCtrl.dispose();
    _espacioCtrl.dispose();
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final hoy = DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha ?? hoy.add(const Duration(days: 30)),
      firstDate: hoy.subtract(const Duration(days: 365)),
      lastDate: hoy.add(const Duration(days: 730)),
    );
    if (elegida == null) return;
    setState(() {
      _fecha = elegida;
      _fechaCtrl.text = formatoFecha(elegida);
    });
    _revalidar();
  }

  Future<void> _elegirHora({required bool esInicio}) async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: esInicio ? 16 : 14, minute: 0),
    );
    if (hora == null) return;
    final minutos = hora.hour * 60 + hora.minute;
    setState(() {
      if (esInicio) {
        _inicio = minutos;
        _inicioCtrl.text = formatoHora(minutos);
      } else {
        _finMontaje = minutos;
        _montajeCtrl.text = formatoHora(minutos);
      }
    });
    _revalidar();
  }

  // Al cambiar un campo se vuelve a validar el otro que depende de él
  void _revalidar() {
    if (_intentado) _contarYValidar();
  }

  // Cuenta cuántas reglas fallan, para el banner superior
  bool _contarYValidar() {
    final valido = _formKey.currentState!.validate();
    final errores = [
      validarFecha(_fecha, DateTime.now()),
      validarHoraInicio(_inicio),
      validarMontaje(_finMontaje, _inicio),
      validarEspacio(_espacioCtrl.text, _arcoXL),
      validarPresupuestoMin(_minCtrl.text),
      validarPresupuestoMax(_maxCtrl.text, _minCtrl.text),
    ].where((e) => e != null).length;
    setState(() => _errores = errores);
    return valido;
  }

  void _verPaquetes() {
    setState(() => _intentado = true);
    if (!_contarYValidar()) return;

    context.read<EventoModel>().guardarEvento(
          tipo: _tipo,
          estiloElegido: _estilo,
          fechaEvento: _fecha!,
          inicio: _inicio!,
          espacio: double.parse(_espacioCtrl.text),
          minimo: double.parse(_minCtrl.text),
          maximo: double.parse(_maxCtrl.text),
        );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PaquetesScreen(estiloInicial: _estilo)),
    );
  }

  Widget _chips(List<String> opciones, String actual, ValueChanged<String> alElegir) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: opciones
          .map((o) => ChoiceChip(
                label: Text(o),
                selected: actual == o,
                onSelected: (_) => alElegir(o),
                labelStyle: TextStyle(color: actual == o ? Colors.white : kTinta),
              ))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recientes = context.watch<EventoModel>().recientes;

    return Scaffold(
      appBar: AppBar(title: const Text('Cotiza tu deco')),
      body: Form(
        key: _formKey,
        autovalidateMode:
            _intentado ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          children: [
            const Text('Cuéntanos tu evento y te mostramos opciones',
                style: TextStyle(color: kMalva)),
            const SizedBox(height: 16),
            if (_intentado && _errores > 0) ...[
              BannerEstado(
                tipo: TipoBanner.error,
                mensaje: _errores == 1
                    ? '1 dato no coincide. Revisa el campo marcado.'
                    : '$_errores datos no coinciden entre sí. Revisa los campos marcados.',
              ),
              const SizedBox(height: 16),
            ],
            const EtiquetaSeccion('Tipo de evento'),
            _chips(_tipos, _tipo, (t) => setState(() => _tipo = t)),
            const SizedBox(height: 16),
            const EtiquetaSeccion('Estilo de decoración'),
            _chips(_estilos, _estilo, (e) => setState(() => _estilo = e)),
            const SizedBox(height: 20),
            CampoTexto(
              etiqueta: 'Fecha del evento',
              controller: _fechaCtrl,
              hint: 'Selecciona la fecha',
              icono: Icons.calendar_today_outlined,
              soloLectura: true,
              onTap: _elegirFecha,
              validator: (_) => validarFecha(_fecha, DateTime.now()),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CampoTexto(
                    etiqueta: 'Inicio del evento',
                    controller: _inicioCtrl,
                    hint: '4:00 PM',
                    icono: Icons.schedule,
                    soloLectura: true,
                    onTap: () => _elegirHora(esInicio: true),
                    validator: (_) => validarHoraInicio(_inicio),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CampoTexto(
                    etiqueta: 'Fin del montaje',
                    controller: _montajeCtrl,
                    hint: '2:00 PM',
                    icono: Icons.handyman_outlined,
                    soloLectura: true,
                    onTap: () => _elegirHora(esInicio: false),
                    // Validación cruzada: compara con la hora de inicio
                    validator: (_) => validarMontaje(_finMontaje, _inicio),
                  ),
                ),
              ],
            ),
            CampoTexto(
              etiqueta: 'Tamaño del espacio (m²)',
              controller: _espacioCtrl,
              hint: 'Ej. 40',
              icono: Icons.square_foot,
              teclado: TextInputType.number,
              onChanged: (_) => _revalidar(),
              // Validación cruzada: depende del switch del arco XL
              validator: (valor) => validarEspacio(valor, _arcoXL),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Agregar arco de globos XL'),
              subtitle: const Text('Requiere al menos 30 m²', style: TextStyle(color: kMalva)),
              value: _arcoXL,
              onChanged: (v) {
                setState(() => _arcoXL = v);
                _revalidar();
              },
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CampoTexto(
                    etiqueta: 'Presupuesto mínimo',
                    controller: _minCtrl,
                    hint: '150',
                    prefijo: const Icon(Icons.attach_money),
                    teclado: TextInputType.number,
                    onChanged: (_) => _revalidar(),
                    validator: validarPresupuestoMin,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CampoTexto(
                    etiqueta: 'Presupuesto máximo',
                    controller: _maxCtrl,
                    hint: '450',
                    prefijo: const Icon(Icons.attach_money),
                    teclado: TextInputType.number,
                    accion: TextInputAction.done,
                    onChanged: (_) => _revalidar(),
                    // Validación cruzada: lee el .text del otro controller
                    validator: (valor) => validarPresupuestoMax(valor, _minCtrl.text),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FilledButton(onPressed: _verPaquetes, child: const Text('Ver paquetes')),
            const SizedBox(height: 28),
            const EtiquetaSeccion('Búsquedas recientes'),
            if (recientes.isEmpty)
              const Text('Aún no tienes búsquedas.', style: TextStyle(color: kMalva))
            else
              ...recientes.map(
                (b) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.history, color: kMalva),
                  title: Text('${b.tipo} · ${b.estilo}'),
                  subtitle: Text('consultado ${formatoFechaHora(b.fecha)}',
                      style: estiloMono(color: kMalva)),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PaquetesScreen(estiloInicial: b.estilo)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
