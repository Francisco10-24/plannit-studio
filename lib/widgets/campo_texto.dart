import 'package:flutter/material.dart';

import 'comunes.dart';

// TextFormField reutilizable: label arriba, ícono y validator
class CampoTexto extends StatelessWidget {
  const CampoTexto({
    super.key,
    required this.etiqueta,
    required this.controller,
    this.hint,
    this.icono,
    this.validator,
    this.teclado,
    this.accion = TextInputAction.next,
    this.oculto = false,
    this.soloLectura = false,
    this.onTap,
    this.onChanged,
    this.prefijo,
    this.sufijo,
  });

  final String etiqueta;
  final TextEditingController controller;
  final String? hint;
  final IconData? icono;
  final String? Function(String?)? validator;
  final TextInputType? teclado;
  final TextInputAction accion;
  final bool oculto;
  final bool soloLectura;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final Widget? prefijo;
  final Widget? sufijo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EtiquetaSeccion(etiqueta),
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: teclado,
            textInputAction: accion,
            obscureText: oculto,
            readOnly: soloLectura,
            onTap: onTap,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: prefijo ?? (icono == null ? null : Icon(icono)),
              suffixIcon: sufijo,
            ),
          ),
        ],
      ),
    );
  }
}
