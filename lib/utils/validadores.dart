// Reglas de validación. Cada función devuelve un mensaje de error o null si es válido.

// ---------- Crea tu cuenta ----------

String? validarNombre(String? valor) {
  final texto = (valor ?? '').trim();
  if (texto.isEmpty) return 'Ingresa tu nombre completo';
  if (texto.length < 3) return 'Escribe al menos 3 caracteres';
  return null;
}

final RegExp _formatoCorreo = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validarCorreo(String? valor) {
  final texto = (valor ?? '').trim();
  if (texto.isEmpty) return 'Ingresa tu correo electrónico';
  if (!_formatoCorreo.hasMatch(texto)) {
    return 'Ingresa un correo válido (ej. nombre@dominio.com)';
  }
  return null;
}

String? validarTelefono(String? valor) {
  // Se ignoran guiones y espacios: 7845-2190 -> 78452190
  final digitos = (valor ?? '').replaceAll(RegExp(r'[\s-]'), '');
  if (!RegExp(r'^\d{8}$').hasMatch(digitos)) {
    return 'El teléfono debe tener 8 dígitos';
  }
  return null;
}

// Estado de cada regla para el checklist en vivo
class ReglasPassword {
  const ReglasPassword({
    required this.largo,
    required this.numero,
    required this.mayuscula,
  });

  final bool largo;
  final bool numero;
  final bool mayuscula;

  bool get todas => largo && numero && mayuscula;
}

ReglasPassword reglasPassword(String valor) {
  return ReglasPassword(
    largo: valor.length >= 8,
    numero: RegExp(r'\d').hasMatch(valor),
    mayuscula: RegExp(r'[A-ZÁÉÍÓÚÑ]').hasMatch(valor),
  );
}

String? validarPassword(String? valor) {
  if ((valor ?? '').isEmpty) return 'Ingresa una contraseña';
  if (!reglasPassword(valor!).todas) return 'La contraseña no cumple las reglas';
  return null;
}

// ---------- Cotiza tu deco (validación cruzada) ----------

String? validarFecha(DateTime? fecha, DateTime hoy) {
  if (fecha == null) return 'Selecciona la fecha del evento';
  final soloHoy = DateTime(hoy.year, hoy.month, hoy.day);
  if (fecha.isBefore(soloHoy)) return 'La fecha ya pasó';
  return null;
}

// Las horas se manejan como minutos desde medianoche (16:00 -> 960)
String? validarHoraInicio(int? inicio) {
  if (inicio == null) return 'Selecciona la hora del evento';
  return null;
}

// Compara el fin del montaje con el inicio del evento (dos campos distintos)
String? validarMontaje(int? finMontaje, int? inicioEvento) {
  if (finMontaje == null) return 'Selecciona la hora de fin del montaje';
  if (inicioEvento == null) return null; // el otro campo muestra su propio error
  if (inicioEvento - finMontaje < 120) {
    return 'El montaje debe terminar al menos 2 h antes del evento';
  }
  return null;
}

// Compara el tamaño del espacio con el extra elegido (arco XL)
String? validarEspacio(String? valor, bool arcoXL) {
  final m2 = double.tryParse((valor ?? '').trim());
  if (m2 == null) return 'Ingresa un número válido de m²';
  if (m2 <= 0) return 'El espacio debe ser mayor que 0';
  if (arcoXL && m2 < 30) return 'El arco XL necesita mínimo 30 m²';
  return null;
}

String? validarPresupuestoMin(String? valor) {
  final monto = double.tryParse((valor ?? '').trim());
  if (monto == null) return 'Ingresa un monto válido';
  if (monto <= 0) return 'El monto debe ser mayor que 0';
  return null;
}

// Lee también el presupuesto mínimo para comparar ambos campos
String? validarPresupuestoMax(String? valorMax, String? valorMin) {
  final maximo = double.tryParse((valorMax ?? '').trim());
  if (maximo == null) return 'Ingresa un monto válido';
  final minimo = double.tryParse((valorMin ?? '').trim());
  if (minimo != null && maximo < minimo) {
    return 'El máximo no puede ser menor que el mínimo';
  }
  return null;
}
