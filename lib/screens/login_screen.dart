import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../shared/theme.dart';
import '../state/sesion_model.dart';
import '../utils/validadores.dart';
import '../widgets/campo_texto.dart';
import '../widgets/comunes.dart';

// Iniciar sesión con una cuenta creada antes (o la cuenta de prueba)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _verPassword = false;
  String? _error;

  @override
  void dispose() {
    _correoCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _entrar() {
    if (!_formKey.currentState!.validate()) return;
    final error = context.read<SesionModel>().iniciarSesion(_correoCtrl.text, _passwordCtrl.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.pop(context, true);
  }

  void _usarCuentaDemo() {
    setState(() {
      _correoCtrl.text = SesionModel.correoDemo;
      _passwordCtrl.text = SesionModel.passwordDemo;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          children: [
            const Text('Inicia sesión', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Qué bueno verte de nuevo', style: TextStyle(color: kMalva)),
            const SizedBox(height: 24),
            if (_error != null) ...[
              BannerEstado(tipo: TipoBanner.error, mensaje: _error!),
              const SizedBox(height: 16),
            ],
            CampoTexto(
              etiqueta: 'Correo electrónico',
              controller: _correoCtrl,
              hint: 'nombre@dominio.com',
              icono: Icons.mail_outline,
              teclado: TextInputType.emailAddress,
              validator: validarCorreo,
            ),
            CampoTexto(
              etiqueta: 'Contraseña',
              controller: _passwordCtrl,
              icono: Icons.lock_outline,
              oculto: !_verPassword,
              accion: TextInputAction.done,
              validator: (v) => (v ?? '').isEmpty ? 'Ingresa tu contraseña' : null,
              sufijo: IconButton(
                icon: Icon(_verPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                onPressed: () => setState(() => _verPassword = !_verPassword),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(onPressed: _entrar, child: const Text('Entrar')),
            const SizedBox(height: 16),
            // Atajo para la presentación
            Center(
              child: TextButton.icon(
                onPressed: _usarCuentaDemo,
                icon: const Icon(Icons.bolt_outlined),
                label: const Text('Usar cuenta de prueba'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
