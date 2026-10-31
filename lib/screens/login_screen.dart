import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../shared/theme.dart';
import '../state/sesion_model.dart';
import '../utils/validadores.dart';
import '../widgets/campo_texto.dart';
import '../widgets/comunes.dart';

// Iniciar sesión con Firebase Authentication
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
  bool _entrando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _rellenarCorreo();
  }

  // El último correo usado se guardó cifrado (flutter_secure_storage)
  Future<void> _rellenarCorreo() async {
    final correo = await context.read<SesionModel>().ultimoCorreo();
    if (correo != null && mounted && _correoCtrl.text.isEmpty) {
      setState(() => _correoCtrl.text = correo);
    }
  }

  @override
  void dispose() {
    _correoCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _entrando = true;
      _error = null;
    });
    final error = await context.read<SesionModel>().iniciarSesion(_correoCtrl.text, _passwordCtrl.text);
    if (!mounted) return;
    setState(() {
      _entrando = false;
      _error = error;
    });
    if (error == null) Navigator.pop(context, true);
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
            // Espacio fijo para el aviso (no mueve los campos de abajo)
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: BannerEstado(tipo: TipoBanner.error, mensaje: _error!),
              )
            else
              const SizedBox.shrink(),
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
            FilledButton(
              onPressed: _entrando ? null : _entrar,
              child: _entrando
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Entrar'),
            ),
          ],
        ),
      ),
    );
  }
}
