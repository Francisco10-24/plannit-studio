# Guía de defensa — Plannit Studio

Esta guía explica qué hace la app, cómo está construida y dónde está cada tema de clase en el código.
Los archivos están en `C:\plannit_studio\lib\`.

---

## 1. La app en una frase
Plannit Studio es un marketplace para contratar **decoración de eventos** en San Salvador: el cliente ve paquetes de decoradores, filtra por estilo, arma su decoración con extras y envía la solicitud al decorador desde una sola app.

## 2. Recorrido para la demo (2 minutos)
1. **Inicio**: se abre directo, sin pedir cuenta (como Airbnb). Los paquetes llegan desde internet.
2. Tocar la barra **"¿Qué evento vas a decorar?"** y pasar a **Cotiza tu deco**.
   - Poner 18 m², activar "arco XL", mínimo 450 y máximo 300.
   - Presionar **Ver paquetes**: aparecen los errores cruzados.
   - Corregir los datos y continuar.
3. **Paquetes de deco**: mostrar la franja `GET … 200 OK`, filtrar por estilo y tocar un paquete.
4. **Mi deco**: activar y desactivar extras; el total cambia solo.
5. Presionar **Enviar solicitud**: como no hay cuenta, se abre **Crea tu cuenta**.
   - Mostrar los errores: correo sin ".com", teléfono incompleto y contraseña sin número.
   - Corregir, aceptar términos y crear la cuenta.
6. La app regresa sola, envía el **POST** y el estado pasa de **Enviada** a **En revisión**.
7. **Modo avión** (requisito 5 de la ficha): activar el modo avión, ir a Explorar y mostrar que aparecen los paquetes guardados con la fecha.

## 3. Cómo está organizado el código (igual que el carrito de la clase 14)
```
lib/
  main.dart              arranca la app y registra el Provider
  shared/theme.dart      colores y tipografía (Figtree)
  models/                Paquete, Extra, Catalogo  → fromJson / toJson
  data/api_client.dart   Dio + interceptor + mensajes de error
  data/paquetes_service.dart   GET del catálogo y POST de la solicitud
  state/evento_model.dart      estado compartido (ChangeNotifier)
  utils/validadores.dart       todas las reglas de validación
  utils/formato.dart           precios, fechas y horas en español
  widgets/               piezas reutilizables (tarjeta, banner, campo de texto)
  screens/               las 5 pantallas + la barra inferior
test/                    20 pruebas automáticas
```
**Idea clave:** las pantallas solo dibujan. Las reglas viven en `validadores.dart`, los datos en `models/`, la red en `data/` y lo compartido en `state/`.

---

## 4. Cada tema de clase y dónde está

### Dart básico (Bloque 2)
- **`final`**: en casi todos los campos, por ejemplo `final _formKey`.
- **`const`**: en widgets que no cambian, como `const Text('Mi deco')`.
- **`late`**: `late Future<Catalogo> _futuro;` se asigna en `initState`, antes de usarlo (`screens/paquetes_screen.dart`).
- **Null safety:**
  - `Paquete? paqueteElegido` puede ser null mientras no se elige un paquete.
  - `int? _inicio` puede ser null mientras no se elige la hora.
  - Para leerlos se usan `?.` y `??`; por ejemplo `(json['etiqueta'] as String?) ?? ''`.

### Colecciones funcionales: map, where, fold (Bloque 3)
- `models/catalogo.dart`: `.map((p) => Paquete.fromJson(p)).toList()` convierte la lista JSON en objetos.
- `screens/paquetes_screen.dart`: `.where((p) => p.estilo == _estilo)` filtra por estilo.
- `state/evento_model.dart:61-66`, el total:
  ```dart
  double get subtotalExtras => _extras
      .where((e) => _extrasActivos.contains(e.id))
      .fold(0.0, (suma, e) => suma + e.precio);

  double get total => _paquete == null ? 0 : _paquete!.precio + subtotalExtras + costoMontaje;
  ```
  **Pregunta probable:** "¿Por qué el total es un getter?"
  Porque es un valor **derivado**. Si se guardara en una variable, al activar un extra quedaría desactualizado.

### Layouts y listas (Bloque 5)
- `Scaffold` + `AppBar` + `BottomNavigationBar` (`screens/home_shell.dart:31`).
- `Row`, `Column` y `Stack`. El `Stack` pone la etiqueta "Favorito de clientes" y el corazón encima de la foto (`widgets/tarjeta_paquete.dart`).
- `ListView.builder` en Inicio y Paquetes: solo construye las tarjetas visibles (renderizado perezoso).
- `Expanded` reparte el espacio, por ejemplo en las dos columnas de presupuesto.

### Estado: setState, ciclo de vida, Provider (Bloque 6)
- **`setState`:**
  - El corazón de favorito (`BotonFavorito`).
  - Los chips seleccionados.
  - El checklist de la contraseña.
- **`initState`:** el GET se crea **una sola vez** (`paquetes_screen.dart:37`). Si se creara en `build()`, se repetiría la petición cada vez que la pantalla se redibuja.
- **`dispose`:** `cotiza_screen.dart:44` y `registro_screen.dart:35` liberan todos los `TextEditingController` para evitar fugas de memoria.
- **Provider:**
  - `main.dart:12` registra `ChangeNotifierProvider(create: (_) => EventoModel())`.
  - `context.watch<EventoModel>()` redibuja cuando cambia el estado; por ejemplo, el total en Mi deco.
  - `context.read<EventoModel>()` solo ejecuta una acción, como `elegirPaquete` o `registrarUsuario`.
  - `notifyListeners()` avisa a las pantallas que algo cambió (`state/evento_model.dart`).

### Formularios (Clase 19) — pantalla **Crea tu cuenta**
- `registro_screen.dart:22`: `final _formKey = GlobalKey<FormState>();` va **en el State, no dentro de build()**. Si estuviera en `build`, se crearía una llave nueva en cada redibujo y se perdería el estado del formulario.
- Cada campo tiene su `validator`, que devuelve un mensaje de error o `null` si es válido (`utils/validadores.dart`):
  - Nombre: obligatorio, mínimo 3 caracteres.
  - Correo: formato `nombre@dominio.com` (expresión regular).
  - Teléfono: 8 dígitos.
  - Contraseña: mínimo 8 caracteres, 1 número y 1 mayúscula.
- `autovalidateMode: AutovalidateMode.onUserInteraction` (línea 79): el error aparece cuando el usuario ya tocó el campo, no desde el inicio.
- `_formKey.currentState!.validate()` (línea 54): solo se guarda si todos los validators devuelven `null`.
- **Tarea de la clase 20:** `widgets/campo_texto.dart` es un `TextFormField` reutilizable (label arriba, ícono y validator).

### Validación cruzada (Clase 20) — pantalla **Cotiza tu deco**
Un validator normal solo conoce su propio campo. Aquí cada regla **lee otro campo**:

| Regla | Línea | Qué compara |
|---|---|---|
| El montaje termina 2 h antes del evento | `cotiza_screen.dart:212` | hora de fin del montaje contra hora de inicio |
| El arco XL necesita ≥ 30 m² | `cotiza_screen.dart:225` | m² escritos contra el switch del arco |
| Presupuesto máx ≥ mín | `cotiza_screen.dart:263` | `.text` del controller del mínimo (como en la diapositiva de la clase 20) |

```dart
validator: (valor) => validarPresupuestoMax(valor, _minCtrl.text),
```
Además, cuando cambia un campo se vuelve a validar el otro (`_revalidar()`). Así, si corriges el mínimo, el error del máximo desaparece solo.

### Consumo de APIs: GET, FutureBuilder, fromJson (Clase 20)
- `data/paquetes_service.dart:24`: `await _dio.get(kUrlCatalogo)` trae `paquetes`, `extras` y `decoradores`.
- `models/paquete.dart:34`: `factory Paquete.fromJson(...)` convierte el `Map` en objeto. `toJson()` hace el camino inverso.
- `FutureBuilder` con **los 3 estados** (`paquetes_screen.dart:98-135`):
  1. `ConnectionState.waiting`: muestra tarjetas grises (skeleton).
  2. `snapshot.hasError`: muestra un banner con el mensaje según el tipo de error y el botón **Reintentar**.
  3. `hasData`: muestra la franja `GET … 200 OK · ms` y la lista.

### POST, Dio, interceptores y DioException (Clase 21)
- **Una sola instancia de Dio** (`data/api_client.dart:12`) con timeouts de 8 segundos.
- **Interceptor** (`api_client.dart:24`): antes de cada petición imprime `→ GET url`; al responder imprime `← 200 url (245 ms)`. Así se mide el tiempo que aparece en la franja.
- **POST** (`paquetes_service.dart:35`): `_dio.post(url, data: datos)`. Dio convierte el `Map` a JSON solo, sin `jsonEncode`.
- **Se revisa el código** (`mi_deco_screen.dart:56`): `if (resultado.codigo == 201)`. No basta con que "no truene".
- **Errores con nombre** (`api_client.dart`, función `mensajeDeError`):

  | Tipo de DioException | Mensaje que ve el usuario |
  |---|---|
  | `connectionError` | "Sin conexión a internet." + paquetes guardados |
  | `connectionTimeout` / `receiveTimeout` | "El servidor tardó demasiado en responder." |
  | `badResponse` | "Error del servidor (404)." |

### Modo avión (Bloque 1 + requisito 5 de la ficha)
- Cada vez que el GET funciona, se guarda el catálogo con la fecha (`EventoModel.guardarCatalogo`).
- Sin red aparece "Sin conexión · mostrando paquetes guardados del 11 oct 2026, 8:14 PM" con su lista.
- **Límite honesto:** se guarda en memoria. Si se cierra la app, se pierde. Guardarlo en el teléfono es el tema de la Semana 8 (persistencia local).

---

## 5. El backend (de dónde salen los datos)
- **GET:** el archivo `db.json` vive en el repo público `github.com/Francisco10-24/plannit-studio-api` y se sirve por **HTTPS** con jsDelivr (una CDN gratuita).
- **POST:** va a **JSONPlaceholder** (el mismo de la clase 21). Responde `201 Created`, pero no guarda nada. Es una simulación, igual que el pago, que está fuera del alcance de la ficha.
- **Pregunta probable:** "¿Por qué no un servidor propio?"
  El alcance de la ficha pide flujo móvil, no backend. El plan era my-json-server, pero estaba caído (error 530). Por eso se usó jsDelivr con el mismo archivo. Cambiarlo es una línea en `api_client.dart`.

## 6. Pruebas automáticas (`flutter test` → 20/20)
| Archivo | Qué prueba |
|---|---|
| `test/validadores_test.dart` | cada regla de formulario y cada regla cruzada, con un caso válido y uno inválido |
| `test/evento_model_test.dart` | el total con `fold`, un solo paquete por evento, el estado de la solicitud y la caché con fecha |
| `test/paquete_test.dart` | `fromJson` / `toJson` (incluye un precio entero en JSON que llega como `double`) |
| `test/errores_red_test.dart` | cada tipo de `DioException` da su propio mensaje |
| `test/cotiza_screen_test.dart` | cada error cruzado aparece **debajo de su propio campo** (fue un bug real y este test lo atrapó) |

## 7. Preguntas difíciles que pueden hacer
- **¿Por qué Flutter y no nativo?** Un solo código para Android e iOS con un equipo de 4 en 12 semanas. El costo asumido es el tamaño: el APK pesa 53 MB, dentro de lo previsto en la ficha (30–50 MB, más imágenes y fuentes).
- **¿Por qué Dio y no http?**
  - Interceptores para registrar y medir cada petición.
  - Errores diferenciados con `DioException`.
  - No se necesita `jsonEncode`/`jsonDecode` manual.
  Con `http` todo cae en un `catch` genérico.
- **¿Por qué Provider y no pasar datos por parámetros?** El paquete elegido, los extras y la cuenta se usan en 4 pantallas. Con Provider no se pasan por todo el árbol.
- **¿Qué pasa si escribo letras en el presupuesto?** El validator responde "Ingresa un monto válido". Nunca se usa `?? 0` para esconder el error (anti-patrón de la clase 19).
- **¿Cómo evitan doble reserva?** Requisito 3 de la ficha: `elegirPaquete` **reemplaza** el paquete anterior; un evento tiene un solo paquete. Además, después de enviar, los extras y el botón quedan bloqueados.
- **¿Qué falta?**
  - Login real (Inicia sesión no está conectado).
  - Guardar la caché en el teléfono (Semana 8).
  - Notificaciones push, fuera del alcance de la ficha.

## 8. Comandos útiles
```bash
cd C:\plannit_studio
flutter run -d chrome        # ver en el navegador
flutter run                  # con el celular conectado por USB
flutter test                 # 20 pruebas
flutter build apk --release  # genera build/app/outputs/flutter-apk/app-release.apk
```
