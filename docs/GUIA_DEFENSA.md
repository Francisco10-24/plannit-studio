# Guía de defensa — Plannit Studio

Esta guía explica qué hace la app, cómo está construida y dónde está cada tema de clase en el código.
Todos los archivos están en `C:\plannit_studio\lib\`.

---

## 1. La app en una frase
Plannit Studio es un marketplace para contratar **decoración de eventos** en San Salvador. El cliente explora paquetes de decoradores locales, los filtra, agrega al carrito uno o varios eventos (cada uno con su paquete y sus extras) y envía las solicitudes. Después ve cómo el decorador las revisa y aprueba.

## 2. Recorrido para la demo (3 minutos)
1. **Inicio**: se abre sin pedir cuenta (como Airbnb).
   - Mostrar las categorías.
   - Tocar el corazón de un paquete.
   - Tocar un decorador en "Decoradores cerca de ti".
2. **Cotiza tu deco** (tocar la barra "¿Qué evento vas a decorar?"):
   - Escribir 18 m², activar "arco XL", mínimo 450 y máximo 300.
   - Presionar **Ver paquetes**: aparecen los errores cruzados.
   - Corregir con Bodas, Boho, 40 m², mínimo 150 y máximo 450, y presionar **Ver paquetes** otra vez.
3. **Explorar**: aparece el banner "Según tu cotización" con solo los paquetes que cumplen.
   - Mostrar el buscador (escribir "quince").
   - Mostrar el botón de filtros (precio máximo y orden).
4. **Detalle**: tocar un paquete; la foto "vuela" a la pantalla de detalle. Presionar **Agregar al carrito**:
   - El formulario ya viene con la fecha y la hora de la cotización.
   - Presionar Agregar → aparece el aviso con "Ver carrito".
5. **Regla de no duplicar**: agregar **otro** paquete para la **misma fecha**. La app avisa "Ya tienes un evento ese día" y ofrece reemplazarlo (requisito 3 de la ficha).
6. **Carrito**: abrir "Agregar extras" y encender 2. El subtotal y el total cambian en vivo. Mostrar el contador en la pestaña Carrito.
7. **Enviar solicitud**: como no hay sesión, se abre **Crea tu cuenta**.
   - Mostrar los errores del formulario.
   - Tocar "¿Ya tienes cuenta? Inicia sesión" → **Usar cuenta de prueba** → Entrar.
8. **Mis solicitudes**: la app regresa sola, hace el POST (201) y muestra **Enviada**. A los 4 s pasa a **En revisión** y a los 10 s a **Aprobada**. La campana de Inicio muestra el contador de avisos nuevos.
9. **Modo avión** (requisito 5 de la ficha): quitar internet y deslizar hacia abajo en Explorar. Aparece "Sin conexión · mostrando paquetes guardados del …".

Cuenta de prueba: `andrea@plannit.sv` / `Plannit26`.

## 3. Cómo está organizado el código
```
lib/
  main.dart                 MultiProvider con los 4 estados + MaterialApp
  shared/theme.dart         colores y tipografía (Figtree)
  models/                   Paquete, Extra, Catalogo, Decorador  → fromJson / toJson
                            EventoCarrito, Solicitud, Notificacion
  data/api_client.dart      Dio + interceptor + mensajes de error
  data/paquetes_service.dart   GET del catálogo y POST de la solicitud
  data/cargar_catalogo.dart    hace el GET y guarda el resultado en los estados
  state/carrito_model.dart     carrito, extras, solicitudes, notificaciones
  state/sesion_model.dart      cuenta y favoritos
  state/cotizacion_model.dart  cotización, caché sin conexión, búsquedas recientes
  state/navegacion_model.dart  pestaña activa de la barra inferior
  utils/validadores.dart       reglas de validación (formularios y cruzadas)
  utils/filtros.dart           búsqueda, filtros y orden de paquetes
  utils/formato.dart           precios, fechas y horas en español
  widgets/                  tarjeta de paquete, campo de texto, banner, seguimiento
  screens/                  12 pantallas + la barra inferior
test/                       41 pruebas automáticas
```
**Idea clave:** las pantallas solo dibujan. Las reglas viven en `utils/`, los datos en `models/`, la red en `data/` y lo que comparten varias pantallas en `state/`.

---

## 4. Cada tema de clase y dónde está

### Colecciones funcionales: map, where, fold (Bloque 3)
- `models/catalogo.dart`: `.map((p) => Paquete.fromJson(p)).toList()` convierte la lista JSON en objetos.
- `utils/filtros.dart:24`: `filtrarPaquetes` usa `where` para buscar y filtrar.
- `state/carrito_model.dart:31-38`, los totales:
  ```dart
  double subtotalExtras(EventoCarrito evento) => _extrasCatalogo
      .where((extra) => evento.extras.contains(extra.id))
      .fold(0.0, (suma, extra) => suma + extra.precio);

  double totalEvento(EventoCarrito evento) =>
      evento.paquete.precio + subtotalExtras(evento) + costoMontaje;

  double get total => _eventos.fold(0.0, (suma, evento) => suma + totalEvento(evento));
  ```
  **Pregunta probable:** "¿Por qué el total es un getter?"
  Porque es un valor **derivado**. Si se guardara en una variable, al encender un extra o quitar un evento quedaría desactualizado.

### Layouts y listas (Bloque 5)
- `Scaffold`, `AppBar` y `BottomNavigationBar` con contador en Carrito (`screens/home_shell.dart`).
- `Stack` para poner la etiqueta y el corazón encima de la foto (`widgets/tarjeta_paquete.dart`).
- `ListView.builder` en Inicio (`inicio_screen.dart:119`) y Explorar (`paquetes_screen.dart:252`): solo construye las tarjetas visibles.
- `CustomScrollView` + `SliverAppBar` en el detalle, para la foto grande que se encoge al bajar.
- `IndexedStack` (`home_shell.dart:24`) mantiene vivas las 4 pestañas, así no se repite el GET al cambiar de pestaña.

### Estado: setState, ciclo de vida, Provider (Bloque 6)
- **`setState`:**
  - La tarjeta que se encoge al tocarla.
  - Los chips.
  - El buscador.
  - El checklist de la contraseña.
- **`initState`:** el GET se crea **una sola vez** (`inicio_screen.dart:46`, `paquetes_screen.dart:55`).
- **`dispose`:** todas las pantallas con formularios liberan sus `TextEditingController` (`cotiza_screen.dart:44`, `registro_screen.dart:37`, `login_screen.dart:26`, `detalle_paquete_screen.dart:326`, `paquetes_screen.dart:70`).
- **Provider** (`main.dart:15`): `MultiProvider` registra 4 `ChangeNotifier`.
  - `context.watch<CarritoModel>()` redibuja cuando cambia el carrito; por ejemplo, el total y el contador de la pestaña.
  - `context.read<...>()` solo ejecuta acciones, como `agregar` o `alternarFavorito`.
  - El corazón de favorito está en `SesionModel`, por eso aparece igual en Inicio, Explorar, Detalle y Decorador.

### Formularios (Clase 19) — **Crea tu cuenta**, **Inicia sesión** y **Agregar al carrito**
- `GlobalKey<FormState>` siempre **en el State, nunca dentro de `build()`**.
- Cada campo tiene su `validator`, que devuelve un mensaje de error o `null` si es válido (`utils/validadores.dart`):
  - Nombre: mínimo 3 caracteres.
  - Correo: formato `nombre@dominio.com`.
  - Teléfono: 8 dígitos.
  - Contraseña: mínimo 8 caracteres, 1 número y 1 mayúscula.
  - Fecha: no puede estar en el pasado.
- `autovalidateMode: AutovalidateMode.onUserInteraction`: el error aparece cuando el usuario ya tocó el campo.
- `_formKey.currentState!.validate()`: solo se guarda si todo es válido.
- Además de validar el formato, el registro valida contra los datos: "Ya existe una cuenta con ese correo" (`sesion_model.dart:51`). El login responde "No encontramos una cuenta" o "Contraseña incorrecta" (`sesion_model.dart:60`).
- `widgets/campo_texto.dart` es el `TextFormField` reutilizable (tarea de la clase 20).

### Validación cruzada (Clase 20) — **Cotiza tu deco**
Un validator normal solo conoce su propio campo. Aquí cada regla **lee otro campo**:

| Regla | Línea | Qué compara |
|---|---|---|
| El montaje termina 2 h antes del evento | `cotiza_screen.dart:212` | hora de fin del montaje contra hora de inicio |
| El arco XL necesita ≥ 30 m² | `cotiza_screen.dart:225` | m² escritos contra el switch del arco |
| Presupuesto máx ≥ mín | `cotiza_screen.dart:263` | `.text` del controller del mínimo |

Hay una segunda validación cruzada, **entre el formulario y el carrito**: al agregar un paquete se compara la fecha con los eventos que ya están en el carrito (`detalle_paquete_screen.dart:236`, `carrito_model.dart:48`). Si coincide, se pregunta antes de reemplazar.

### Consumo de APIs: GET, FutureBuilder, fromJson (Clase 20)
- `data/paquetes_service.dart:27`: `await _dio.get(kUrlCatalogo)` trae 18 paquetes, 6 extras y 6 decoradores.
- `models/paquete.dart:40`: `factory Paquete.fromJson(...)`. Los campos `descripcion` y `detalles` son opcionales: si no vienen, quedan vacíos.
- `FutureBuilder` con **los 3 estados** (`paquetes_screen.dart:196-235`):
  1. `ConnectionState.waiting`: muestra tarjetas grises.
  2. `snapshot.hasError`: muestra un banner según el tipo de error, con Reintentar.
  3. Con datos: muestra la lista filtrada.
- **Deslizar hacia abajo** (`RefreshIndicator`) repite el GET.

### POST, Dio, interceptores y DioException (Clase 21)
- **Una sola instancia de Dio** (`data/api_client.dart:13`).
- **Interceptor** (`api_client.dart:25`): registra en la consola `→ GET url` y `← 200 url (245 ms)`. No se muestra en pantalla: es una herramienta de desarrollo.
- **POST** (`paquetes_service.dart:36`): `_dio.post(url, data: datos)`, **uno por cada evento del carrito**.
- **Se revisa el código** (`carrito_screen.dart:71`): si no es 201, se detiene y avisa.
- **Errores con nombre** (`api_client.dart:54`, `mensajeDeError`):

  | Tipo de DioException | Mensaje |
  |---|---|
  | `connectionError` | "Sin conexión a internet." + paquetes guardados |
  | `connectionTimeout` / `receiveTimeout` | "El servidor tardó demasiado en responder." |
  | `badResponse` | "Error del servidor (404)." |

### Requisitos de la ficha del proyecto
| Requisito | Cómo se cumple |
|---|---|
| 1. Del Home a la ficha de un paquete en ≤ 4 clics | Inicio → tocar paquete = **1 clic** |
| 3. Varios eventos en un carrito, uno por paquete, sin duplicados | `CarritoModel`: lista de eventos con un solo `paquete`; aviso de fecha repetida |
| 4. El proveedor recibe la solicitud con fecha, cliente y servicios | `solicitudJson`: cliente, evento, fecha, hora, paquete, decorador, extras y total |
| 5. Sin internet muestra lo último consultado con su fecha | Caché en `CotizacionModel` + banner con fecha |
| Estados enviada / en revisión / aprobada | `avanzarSolicitud` + `widgets/seguimiento.dart` + notificaciones |

---

## 5. El backend (de dónde salen los datos)
- **GET:** el archivo `db.json` del repo público `github.com/Francisco10-24/plannit-studio-api` (versión etiquetada `v2`), servido por **HTTPS** con jsDelivr.
- **POST:** va a **JSONPlaceholder**. Responde `201 Created`, pero no guarda nada. La aprobación del decorador se **simula** con un temporizador (4 s y 10 s), igual que el pago, que según la ficha está fuera del alcance.
- **Pregunta probable:** "¿Las cuentas y el carrito se guardan?"
  Viven en memoria mientras la app está abierta. Guardarlos en el teléfono es el tema de la Semana 8 (persistencia local).

## 6. Pruebas automáticas (`flutter test` → 41/41)
| Archivo | Qué prueba |
|---|---|
| `validadores_test.dart` | cada regla de formulario y cada regla cruzada |
| `carrito_model_test.dart` | total con `fold`, extras por evento, fecha repetida, reemplazar, quitar, envío, estados y notificaciones |
| `sesion_model_test.dart` | registro, correo repetido, login correcto e incorrecto, cuenta de prueba, favoritos |
| `filtros_test.dart` | búsqueda sin tildes y por tipo de evento, filtros por estilo, tipo y precio, orden |
| `cotizacion_model_test.dart` | guardar y quitar la cotización, caché con fecha |
| `paquete_test.dart` | `fromJson` / `toJson` y campos opcionales |
| `errores_red_test.dart` | cada tipo de `DioException` da su propio mensaje |
| `cotiza_screen_test.dart` | cada error cruzado aparece **debajo de su propio campo** |
| `agregar_carrito_test.dart` | sin fecha no agrega; con cotización agrega; la misma fecha pregunta y reemplaza |

## 7. Preguntas difíciles que pueden hacer
- **¿Por qué Flutter y no nativo?** Un solo código para Android e iOS con un equipo de 4. El costo asumido es el tamaño del APK, dentro de lo previsto en la ficha.
- **¿Por qué Dio y no http?**
  - Interceptores.
  - Errores diferenciados con `DioException`.
  - No se necesita `jsonEncode` manual.
- **¿Por qué 4 Providers y no uno?** Cada uno tiene una sola responsabilidad (carrito, sesión, cotización, navegación). Una pantalla solo escucha lo que necesita.
- **¿Cómo evitan la doble reserva?** Un evento tiene un solo paquete. Si se agrega otro para la misma fecha, la app pregunta y **reemplaza** en lugar de duplicar.
- **¿Qué pasa si se cae internet al enviar?** El `DioException` muestra "Sin conexión a internet." y los eventos **se quedan en el carrito**; no se pierde nada.
- **¿Qué falta?**
  - Guardar datos en el teléfono (Semana 8).
  - Backend propio para que el decorador apruebe de verdad.
  - Notificaciones push (fuera del alcance de la ficha).

## 8. Comandos útiles
```bash
cd C:\plannit_studio
flutter run                  # en el emulador o celular
flutter run -d chrome        # en el navegador
flutter test                 # 41 pruebas
flutter build apk --release  # genera build/app/outputs/flutter-apk/app-release.apk
```
