import 'package:flutter/material.dart';

// Formatea un valor numérico a moneda: 1240.5 -> $1,240.50
String formatoPrecio(double valor) {
  final partes = valor.toStringAsFixed(2).split('.');
  final entero = partes[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]},',
  );
  return '\$$entero.${partes[1]}';
}

// Convierte "#9B1B30" en un Color de Flutter
Color colorDesdeHex(String hex) {
  final limpio = hex.replaceFirst('#', '');
  return Color(int.parse('FF$limpio', radix: 16));
}

const _dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
const _meses = [
  'ene', 'feb', 'mar', 'abr', 'may', 'jun',
  'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
];

// "Sáb 12 dic 2026"
String formatoFecha(DateTime fecha) =>
    '${_dias[fecha.weekday - 1]} ${fecha.day} ${_meses[fecha.month - 1]} ${fecha.year}';

// Minutos desde medianoche -> "4:00 PM"
String formatoHora(int minutos) {
  final h = minutos ~/ 60;
  final m = (minutos % 60).toString().padLeft(2, '0');
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '$h12:$m ${h < 12 ? 'AM' : 'PM'}';
}

// "03 oct 2026, 8:14 PM"
String formatoFechaHora(DateTime fecha) =>
    '${fecha.day.toString().padLeft(2, '0')} ${_meses[fecha.month - 1]} ${fecha.year}, '
    '${formatoHora(fecha.hour * 60 + fecha.minute)}';
