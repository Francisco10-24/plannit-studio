import 'package:sembast/sembast.dart';

import '../../models/solicitud.dart';

// Fuente local del carrito: los eventos siguen ahí aunque se cierre la app
class CarritoLocal {
  CarritoLocal(this._abrir);

  final Future<Database> Function() _abrir;

  // StoreRef<int, Map<String, Object?>>: llave = id del evento
  final _store = intMapStoreFactory.store('carrito');

  Future<void> guardarTodo(List<EventoCarrito> eventos) async {
    final db = await _abrir();
    // Transacción: se borra y se reescribe el carrito completo en un solo paso
    await db.transaction((txn) async {
      await _store.delete(txn);
      for (final evento in eventos) {
        await _store.record(evento.id).put(txn, evento.toMap());
      }
    });
  }

  Future<List<EventoCarrito>> leerTodo() async {
    final db = await _abrir();
    final registros = await _store.find(db, finder: Finder(sortOrders: [SortOrder(Field.key)]));
    return registros.map((r) => EventoCarrito.fromMap(r.value)).toList();
  }
}
