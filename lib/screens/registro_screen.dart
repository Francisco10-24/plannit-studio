import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../shared/theme.dart';
import '../state/evento_model.dart';
import '../utils/validadores.dart';
import '../widgets/campo_texto.dart';
import '../widgets/comunes.dart';

// Pantalla 5: registro con validación de formularios
class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key, this.desdeSolicitud = false});

  // true cuando se abre desde "Enviar solicitud": al terminar regresa
  final bool desdeSolicitud;

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _esCliente = true;
  bool _verPassword = false;
  bool _terminos = false;
  bool _formularioValido = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _telefonoCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // Recalcula si el botón se puede habilitar (sin mostrar errores aún)
  void _actualizar() {
    setState(() {
      _formularioValido = validarNombre(_nombreCtrl.text) == null &&
          validarCorreo(_correoCtrl.text) == null &&
          validarTelefono(_telefonoCtrl.text) == null &&
          validarPassword(_passwordCtrl.text) == null;
    });
  }

  void _crearCuenta() {
    if (!_formKey.currentState!.validate() || !_terminos) return;
    _formKey.currentState!.save();
    context.read<EventoModel>().registrarUsuario(_nombreCtrl.text.trim());

    if (widget.desdeSolicitud) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta creada. ¡Bienvenida/o a Plannit Studio!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<EventoModel>().usuario;
    if (usuario != null && !widget.desdeSolicitud) return _Perfil(nombre: usuario);

    final reglas = reglasPassword(_passwordCtrl.text);

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: widget.desdeSolicitud),
      body: Form(
        key: _formKey,
        // Muestra el error cuando el usuario ya interactuó con el campo
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: _actualizar,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          children: [
            const Text('Crea tu cuenta', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
              widget.desdeSolicitud
                  ? 'Necesitas una cuenta para enviar tu solicitud'
                  : 'Decora tu evento en minutos',
              style: const TextStyle(color: kMalva),
            ),
            const SizedBox(height: 20),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Cliente'), icon: Icon(Icons.person_outline)),
                ButtonSegment(value: false, label: Text('Decorador'), icon: Icon(Icons.brush_outlined)),
              ],
              selected: {_esCliente},
              onSelectionChanged: (s) => setState(() => _esCliente = s.first),
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: kVino,
                selectedForegroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            CampoTexto(
              etiqueta: 'Nombre completo',
              controller: _nombreCtrl,
              hint: 'Andrea Menjívar',
              icono: Icons.badge_outlined,
              validator: validarNombre,
              sufijo: validarNombre(_nombreCtrl.text) == null
                  ? const Icon(Icons.check_circle, color: kExito)
                  : null,
            ),
            CampoTexto(
              etiqueta: 'Correo electrónico',
              controller: _correoCtrl,
              hint: 'nombre@dominio.com',
              icono: Icons.mail_outline,
              teclado: TextInputType.emailAddress,
              validator: validarCorreo,
              sufijo: validarCorreo(_correoCtrl.text) == null
                  ? const Icon(Icons.check_circle, color: kExito)
                  : null,
            ),
            CampoTexto(
              etiqueta: 'Teléfono',
              controller: _telefonoCtrl,
              hint: '7845-2190',
              teclado: TextInputType.phone,
              validator: validarTelefono,
              prefijo: const Padding(
                padding: EdgeInsets.only(left: 14, right: 8),
                child: Text('+503', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              sufijo: validarTelefono(_telefonoCtrl.text) == null
                  ? const Icon(Icons.check_circle, color: kExito)
                  : null,
            ),
            CampoTexto(
              etiqueta: 'Contraseña',
              controller: _passwordCtrl,
              icono: Icons.lock_outline,
              oculto: !_verPassword,
              accion: TextInputAction.done,
              validator: validarPassword,
              sufijo: IconButton(
                icon: Icon(_verPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                onPressed: () => setState(() => _verPassword = !_verPassword),
              ),
            ),
            // Checklist de reglas en vivo
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: kSuperficie, borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: [
                  _Regla(texto: 'Mínimo 8 caracteres', cumple: reglas.largo),
                  _Regla(texto: 'Al menos 1 número', cumple: reglas.numero),
                  _Regla(texto: 'Al menos 1 mayúscula', cumple: reglas.mayuscula),
                ],
              ),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: kVino,
              value: _terminos,
              onChanged: (v) => setState(() => _terminos = v ?? false),
              title: const Text('Acepto los términos y condiciones'),
            ),
            const SizedBox(height: 8),
            FilledButton(
              // Deshabilitado hasta que todo sea válido
              onPressed: _formularioValido && _terminos ? _crearCuenta : null,
              child: const Text('Crear cuenta'),
            ),
            if (!(_formularioValido && _terminos))
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Completa los campos marcados para continuar',
                    textAlign: TextAlign.center, style: TextStyle(color: kMalva, fontSize: 12)),
              ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text('¿Ya tienes cuenta? Inicia sesión'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Regla extends StatelessWidget {
  const _Regla({required this.texto, required this.cumple});

  final String texto;
  final bool cumple;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(cumple ? Icons.check_circle : Icons.cancel,
              size: 18, color: cumple ? kExito : kError),
          const SizedBox(width: 8),
          Text(texto, style: TextStyle(color: cumple ? kTinta : kError)),
        ],
      ),
    );
  }
}

// Vista de perfil cuando ya hay sesión
class _Perfil extends StatelessWidget {
  const _Perfil({required this.nombre});

  final String nombre;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: kVino,
            child: Text(nombre[0].toUpperCase(),
                style: const TextStyle(fontSize: 32, color: Colors.white)),
          ),
          const SizedBox(height: 12),
          Text(nombre,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 24),
          const BannerEstado(tipo: TipoBanner.exito, mensaje: 'Tu cuenta está activa.'),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => context.read<EventoModel>().cerrarSesion(),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
