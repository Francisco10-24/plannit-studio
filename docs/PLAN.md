# Plan de implementación — Plannit Studio (Flutter)

Objetivo: convertir las 5 pantallas de Stitch en una app Flutter funcional, nivel de clase (sin arquitectura avanzada).
Fecha límite: martes 13 oct 2026. Meta: terminar lunes 12 en la noche.
Carpeta del proyecto: `C:\plannit_studio`
Diseño de referencia: `docs/DESIGN.md` + proyecto Stitch https://stitch.withgoogle.com/projects/14659848071634673797

Cada fase se puede ejecutar en un chat nuevo: lee primero este archivo, luego la sección de la fase.

---

## Fase 0 — Documentación descubierta (ya hecha)

### Fuentes
| Fuente | Qué aporta |
|---|---|
| `docs/clase19.txt` (Formularios) | `Form`, `GlobalKey<FormState>`, `TextFormField.validator`, `validate()`/`save()`, `autovalidateMode` |
| `docs/clase20.txt` (Validación cruzada + http) | Validación cruzada leyendo `.text` de otro controller; `http.get`, `jsonDecode`, `fromJson`/`toJson`, `FutureBuilder` 3 estados |
| `docs/clase21.txt` (POST/PUT + Dio) | `http.post` 201, `http.put` 200, `Dio()` instancia compartida, interceptores, `DioException` tipos |
| `C:\Carrito-moviles\carrito_provider` (Clase 14, proyecto propio) | Estructura de carpetas, `ChangeNotifierProvider`, `ChangeNotifier` + `fold`, `theme.dart`, `formato.dart`, tests |
| Bloques de clase 1–6 (pegados en chat) | `var/final/const/late`, null safety, `map/where/fold`, total como getter, `Scaffold`, `ListView.builder`, `setState`, `dispose`, `Provider` |
| Entorno | Flutter 3.47.1, Dart 3.13.1. Dispositivo disponible: Chrome (web). No hay emulador Android creado |

### APIs permitidas (solo estas)
- **Formularios (clase 19):**
  - `Form(key: _formKey, child: ...)`, con `final _formKey = GlobalKey<FormState>();` declarado en el `State`.
  - `TextFormField(controller:, validator: (value) { ... return null; })`.
  - `_formKey.currentState!.validate()` y `save()`; `autovalidateMode: AutovalidateMode.onUserInteraction`.
- **Validación cruzada (clase 20):** dentro del `validator` de un campo se lee `otroController.text`.
- **Red (clase 21):**
  - `final dio = Dio(BaseOptions(baseUrl:, connectTimeout:, receiveTimeout:))`.
  - `dio.get(path)`, con `response.data` ya decodificado.
  - `dio.post(path, data: map)`, revisando `response.statusCode == 201`.
  - `dio.interceptors.add(InterceptorsWrapper(onRequest:, onResponse:, onError:))`.
  - `on DioException catch (e)` → `e.type`: `DioExceptionType.connectionTimeout`, `.receiveTimeout`, `.connectionError`, `.badResponse`.
- **Modelos (clase 20):** `factory Paquete.fromJson(Map<String, dynamic> json)`, `Map<String, dynamic> toJson()`.
- **UI asíncrona (clase 20):** `FutureBuilder` con `ConnectionState.waiting`, `snapshot.hasError`, `snapshot.hasData`.
- **Estado (clase 6 + carrito_provider):**
  - `ChangeNotifier` + `notifyListeners()`; `ChangeNotifierProvider` en `main()` (o `MultiProvider`).
  - `context.watch<T>()` y `context.read<T>()`.
- **Layout (clase 5):** `Scaffold`, `AppBar`, `Column/Row/Stack`, `Expanded`, `ListView.builder`, `BottomNavigationBar`, `Navigator.push(MaterialPageRoute(...))`.
- **Colecciones (clase 3):** `where`, `map(...).toList()`, `fold`. El total SIEMPRE como getter, nunca como campo guardado.
- **Tipografía:** paquete `google_fonts`, `GoogleFonts.figtreeTextTheme()`.

### Anti-patrones (prohibidos)
- `GlobalKey` creada dentro de `build()` (clase 19, p6).
- `double.tryParse(x) ?? 0` sin mostrar error (clase 19, p4).
- Guardar `total` como campo (clase 3). Usar getter con `fold`.
- `Column` + `SingleChildScrollView` para listas largas (clase 5). Usar `ListView.builder`.
- Olvidar `dispose()` de `TextEditingController` (clase 6).
- Asumir éxito sin revisar `statusCode` (clase 21, p5).
- Un solo `catch` genérico para todo error de red (clase 21, p6). Diferenciar ≥2 tipos de `DioException`.
- Inventar APIs: si un método no está en la lista de arriba ni en la documentación oficial, no se usa.
- Riverpod, Bloc, GoRouter, Clean Architecture, Firebase: fuera de alcance (no se vieron en clase).

### Decisión de backend (falso pero real por HTTPS)
- **Opción A (recomendada): my-json-server.typicode.com.**
  - Se sube `db.json` a un repo **público** de GitHub del equipo.
  - Queda disponible `GET https://my-json-server.typicode.com/<usuario>/<repo>/paquetes`.
  - `POST /solicitudes` responde 201 (falso; no guarda nada).
  - Sin servidor propio, gratis, límite de 10 KB para `db.json`.
- **Opción B (respaldo sin GitHub):**
  - GET a `https://raw.githubusercontent.com/...` o, si tampoco hay repo, `assets/db.json` cargado localmente.
  - POST a `https://jsonplaceholder.typicode.com/posts` (responde 201, visto en clase 21).

---

## Estructura final (copia de carrito_provider)
```
C:\plannit_studio\
  lib\
    main.dart                     MultiProvider + MaterialApp(home: HomeShell)
    shared\theme.dart             colores DESIGN.md + Figtree
    models\paquete.dart           Paquete.fromJson/toJson
    models\extra.dart             Extra (nombre, precio, activo)
    models\busqueda.dart          Busqueda reciente (texto, fecha)
    data\api_client.dart          instancia Dio + interceptor de logging
    data\paquetes_service.dart    obtenerPaquetes(), enviarSolicitud()
    state\evento_model.dart       paquete elegido, extras, total (fold), estado solicitud, búsquedas recientes
    utils\validadores.dart        funciones puras de validación (correo, teléfono, contraseña, cruzadas)
    utils\formato.dart            formatoPrecio()
    widgets\campo_texto.dart      TextFormField reutilizable (tarea clase 20)
    widgets\tarjeta_paquete.dart  card estilo Airbnb
    widgets\franja_http.dart      franja "GET ... · 200 OK · 386 ms"
    widgets\banner_estado.dart    banner error / sin conexión / aviso
    screens\home_shell.dart       BottomNavigationBar (Inicio, Explorar, Mi deco, Perfil)
    screens\inicio_screen.dart
    screens\cotiza_screen.dart
    screens\paquetes_screen.dart
    screens\mi_deco_screen.dart
    screens\registro_screen.dart
  assets\images\                  fotos de paquetes (exportadas de Stitch)
  test\validadores_test.dart
  test\evento_model_test.dart
  docs\                           este plan, DESIGN.md, textos de clases
  db.json                         datos para my-json-server
```

---

## Fase 1 — Proyecto base, tema y navegación (domingo, ~1.5 h)
**Implementar**
1. Crear el proyecto: `flutter create --org com.plannit --project-name plannit_studio --platforms android,web C:\plannit_studio`.
2. Agregar dependencias con `flutter pub add provider dio google_fonts`; no escribir versiones a mano.
3. `shared/theme.dart`: copiar la forma de `carrito_provider/lib/shared/theme.dart` con estos cambios:
   - Colores de `docs/DESIGN.md` §2 (`kVino 0xFF9B1B30`, `kTinta 0xFF2B1216`, `kFondo 0xFFFBF4F1`, etc.).
   - `textTheme: GoogleFonts.figtreeTextTheme()`.
4. `screens/home_shell.dart`: `StatefulWidget` con `BottomNavigationBar` de 4 ítems y `setState` del índice. Pestañas:
   - Inicio → `InicioScreen`.
   - Explorar → `PaquetesScreen`.
   - Mi deco → `MiDecoScreen`.
   - Perfil → `RegistroScreen`.
5. Las 5 pantallas como `Scaffold` con su título, todavía sin contenido.
6. Navegación con `Navigator.push`:
   - Inicio (barra de búsqueda) → Cotiza.
   - Cotiza ("Ver paquetes") → Paquetes.
   - Paquetes (card) → Mi deco.
   - Mi deco ("Enviar") → Registro.
7. `git init` y primer commit.

**Verificar**
- [ ] `flutter analyze` sin errores.
- [ ] `flutter run -d chrome`: se recorren las 5 pantallas y las 4 pestañas.
- [ ] La letra es Figtree, no Roboto.

**No hacer:** GoRouter ni rutas con nombre complejas.

---

## Fase 2 — Modelos, backend falso, Dio y estado (domingo, ~2 h)
**Implementar**
1. `db.json` con 6 paquetes. Campos: `id`, `nombre`, `decorador`, `zona`, `estilo`, `precio`, `rating`, `resenas`, `colores` (lista hex), `incluye`, `imagen`. Datos de las pantallas de Stitch: Glam Rosa y Dorado $285, Jardín Boho Pampa $340, etc.
2. Subir `db.json` a un repo público del equipo (Opción A) o usar la Opción B.
3. `models/paquete.dart`: `fromJson`/`toJson` (clase 20, p8). Lo mismo para `Extra` y `Busqueda`.
4. `data/api_client.dart`:
   - `Dio(BaseOptions(baseUrl: ..., connectTimeout: Duration(seconds: 8), receiveTimeout: Duration(seconds: 8)))`.
   - Un interceptor de logging con `debugPrint` del método, la ruta, el `statusCode` y el tiempo (clase 21, p8 y p12).
5. `data/paquetes_service.dart`:
   - `Future<List<Paquete>> obtenerPaquetes({String? estilo})` hace `dio.get('/paquetes')` y transforma con `.map(Paquete.fromJson).toList()`. Si llega `estilo`, filtra con `where`.
   - `Future<int> enviarSolicitud(Map<String, dynamic> datos)` hace `dio.post('/solicitudes', data: datos)` y devuelve el `statusCode`.
6. `state/evento_model.dart` (`ChangeNotifier`, copiar la forma de `carrito_model.dart`):
   - Un solo `Paquete? paqueteElegido` (requisito 3 de la ficha: un evento = un paquete).
   - `List<Extra> extras`; `alternarExtra(id)`.
   - `double get total => paquete.precio + extras.where((e) => e.activo).fold(0, (s, e) => s + e.precio) + montaje`.
   - `EstadoSolicitud estado` (enum `ninguna, enviada, enRevision, aprobada`).
   - `List<Busqueda> recientes` y `List<Paquete> ultimosPaquetes` con `DateTime consultadoEn` (caché en memoria para el modo sin conexión).
7. `main.dart`: `ChangeNotifierProvider(create: (_) => EventoModel())`.

**Verificar**
- [ ] `test/evento_model_test.dart`: el total cambia al activar o desactivar extras, y elegir otro paquete reemplaza al anterior.
- [ ] Un test de `Paquete.fromJson` con un Map de ejemplo.
- [ ] `flutter test` en verde.
- [ ] Abrir la URL del GET en el navegador devuelve el JSON.

**No hacer:** guardar `total` como campo; usar `http` y `Dio` a la vez (se usa solo Dio, lo más reciente de clase).

---

## Fase 3 — Inicio + Paquetes de deco (GET, estados de red) (domingo noche, ~2.5 h)
**Implementar**
1. `widgets/tarjeta_paquete.dart`: card estilo Airbnb.
   - Foto en `ClipRRect` de radio 20 con `Stack`: etiqueta "Favorito de clientes" + `IconButton` de corazón.
   - Nombre, ★ rating, decorador · zona, puntos de color (`Row` de `Container` circulares) y precio con `formatoPrecio`.
2. `InicioScreen`:
   - Barra de búsqueda tipo pill (`InkWell` → Cotiza).
   - Chips de categorías en `ListView` horizontal.
   - Feed con `FutureBuilder(future: servicio.obtenerPaquetes())` y `ListView.builder` de tarjetas.
   - Sección "Decoradores cerca de ti" en lista horizontal.
3. `PaquetesScreen`: `StatefulWidget`.
   - El `Future` se crea en `initState` (clase 6) para no repetir el GET en cada `build`.
   - `FutureBuilder` con los 3 estados (clase 20, p9):
     - `waiting`: 2 tarjetas skeleton (`Container` gris redondeado).
     - `hasError`: `BannerEstado` según el tipo de `DioException`:
       - `connectionError` → "Sin conexión · mostrando paquetes guardados del {fecha}" + lista `ultimosPaquetes` + botón Reintentar.
       - `connectionTimeout` o `receiveTimeout` → "El servidor tardó demasiado" + Reintentar.
       - `badResponse` → "Error del servidor ({código})".
     - `hasData`: `FranjaHttp` ("GET /paquetes · 200 OK · N ms") + lista. Al llegar, guardar en `EventoModel.ultimosPaquetes` con la fecha.
   - "Reintentar": `setState(() => _futuro = servicio.obtenerPaquetes())`.
   - Tocar una tarjeta: `context.read<EventoModel>().elegirPaquete(p)` y luego `Navigator.push` a Mi deco.

**Verificar**
- [ ] En Chrome los paquetes cargan desde la URL real.
- [ ] Prueba de **modo avión**: DevTools → Network → Offline → Reintentar muestra el banner y los paquetes guardados con su fecha (requisito 5 de la ficha).
- [ ] Una URL rota a propósito muestra el mensaje de `badResponse`, distinto al de sin conexión (clase 21, p12).
- [ ] La consola muestra el log del interceptor.

**No hacer:** crear el `Future` dentro de `build()`; usar un `catch` genérico.

---

## Fase 4 — Cotiza tu deco (validación cruzada) (lunes, ~2 h)
**Implementar** (`StatefulWidget` con `Form` y `GlobalKey` en el State)
1. Controllers:
   - `_inicioEvento` y `_finMontaje` (hora, con `showTimePicker`).
   - `_espacioM2` (número).
   - `_presupuestoMin` y `_presupuestoMax`.
   - `bool _arcoXL`.
   - Liberar todos en `dispose()`.
2. Chips de tipo de evento y de estilo con `ChoiceChip` + `setState`.
3. Validadores en `utils/validadores.dart` (funciones puras que se pueden probar):
   - `validarMontaje(finMontaje, inicioEvento)` → "El montaje debe terminar al menos 2 h antes del evento".
   - `validarEspacio(m2, arcoXL)` → "El arco XL necesita mínimo 30 m²".
   - `validarPresupuesto(min, max)` → "El máximo no puede ser menor que el mínimo"; también rechaza valores no numéricos con mensaje, nunca con `?? 0`.
   - Cada `validator` lee el `.text` del OTRO controller (clase 20, p4).
4. Banner superior: "N datos no coinciden entre sí" cuando `validate()` da false.
5. Botón "Ver paquetes":
   - Si `validate()` es true, guarda una `Busqueda` en `recientes` con la fecha y hace `Navigator.push` a Paquetes con el estilo elegido.
6. Lista "Búsquedas recientes" desde `EventoModel.recientes`.

**Verificar**
- [ ] `test/validadores_test.dart`: un caso válido y uno inválido por cada regla cruzada.
- [ ] Con los datos de la pantalla de Stitch (4:00 PM / 3:00 PM, 18 m² + arco XL, $450 / $300) aparecen los 3 errores.
- [ ] Al corregirlos, pasa a Paquetes.

---

## Fase 5 — Mi deco (POST + total con fold) (lunes, ~1.5 h)
**Implementar**
1. Card oscura de encabezado del evento (tipo, fecha, lugar).
2. Paquete elegido con "Cambiar", que hace `Navigator.pop` o vuelve a Paquetes. Si no hay paquete elegido: estado vacío con botón "Explorar paquetes".
3. Extras con `SwitchListTile` → `alternarExtra`.
4. Resumen: Paquete, Extras, Montaje y **Total** leído del getter `total` (`context.watch`).
5. Botón "Enviar solicitud al decorador":
   - Si no hay cuenta (`EventoModel.usuario == null`), primero `Navigator.push` a Registro. Al volver con cuenta, envía.
   - Envío:
     - `await servicio.enviarSolicitud(map)`; si `statusCode == 201`, `estado = enviada` y la `FranjaHttp` muestra "POST /solicitudes · 201 Created".
     - Simulación de avance: `Future.delayed` → `enRevision`. Es pago y aprobación simulados, según el alcance de la ficha.
   - `DioException` → `SnackBar` con mensaje según el tipo.
6. Stepper horizontal simple (3 `Column` con ícono y texto): Enviada → En revisión → Aprobada.

**Verificar**
- [ ] El total cambia en vivo al mover los switches.
- [ ] El POST real devuelve 201 y se ve en el log del interceptor.
- [ ] Sin red, aparece un mensaje claro y la app no se cae.

---

## Fase 6 — Crea tu cuenta (validación de formularios) (lunes, ~1.5 h)
**Implementar**
1. `widgets/campo_texto.dart`: `StatelessWidget` que envuelve `TextFormField` (label arriba, ícono, `validator`, `obscureText`, `keyboardType`, `textInputAction`). Es la tarea de la clase 20.
2. `RegistroScreen`: `Form` + `GlobalKey` en el State + `autovalidateMode: AutovalidateMode.onUserInteraction` (clase 19, p9).
   - Toggle Cliente | Decorador con `SegmentedButton` o dos `ChoiceChip`.
   - Nombre: obligatorio, ≥3 caracteres.
   - Correo: regex simple `^[^@\s]+@[^@\s]+\.[^@\s]+$`.
   - Teléfono: 8 dígitos con prefijo +503.
   - Contraseña: ≥8 caracteres, 1 número, 1 mayúscula. Checklist en vivo con `setState` en `onChanged`.
   - Checkbox de términos.
   - Botón "Crear cuenta" deshabilitado (`onPressed: null`) hasta que el formulario sea válido y los términos estén aceptados.
3. Al crear la cuenta: guardar `usuario` en `EventoModel` y `Navigator.pop(context, true)`.
4. `dispose()` de los 4 controllers.

**Verificar**
- [ ] Los datos de la pantalla de Stitch (correo sin dominio, teléfono de 6 dígitos) muestran sus errores.
- [ ] Al menos 3 campos rechazan datos inválidos (actividad de la clase 19).
- [ ] Tests de `validarCorreo`, `validarTelefono` y `validarPassword`.

---

## Fase 7 — Verificación final y entrega (lunes noche / martes mañana, ~1 h)
1. `flutter analyze` → 0 issues. `flutter test` → todo verde.
2. Grep de anti-patrones:
   - `grep -rn "GlobalKey" lib/` → ninguna dentro de `build`.
   - `grep -rn "?? 0" lib/` → ninguno sin mensaje.
   - `grep -rn "total =" lib/` → no hay asignación de total (solo getter).
   - Cada `TextEditingController` tiene su `dispose()`.
3. Recorrido completo en Chrome con la vista de celular de DevTools (390×844):
   - Inicio → Cotiza (forzar los errores cruzados) → Paquetes (online y offline) → Mi deco (switches y POST) → Registro (errores y luego cuenta creada) → solicitud enviada.
4. Comparar visualmente cada pantalla con Stitch y ajustar solo colores, espaciados y textos.
5. Opcional, si sobra tiempo: crear un emulador Android (`flutter emulators --create`) y probar ahí.
6. Opcional: `README.md` con cómo correr la app y qué requisito cubre cada pantalla.
7. Commit final; push al repo del equipo si lo piden.

## Cronograma
| Cuándo | Fases |
|---|---|
| Domingo 11 | 1, 2, 3 |
| Lunes 12 | 4, 5, 6 |
| Lunes noche / martes mañana | 7 + capturas |
