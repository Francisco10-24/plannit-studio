# Plannit Studio

Marketplace móvil para contratar **decoración de eventos** en San Salvador (cumpleaños, bodas, quince años, baby showers, graduaciones, fiestas infantiles).
Proyecto de Desarrollo de Aplicaciones Móviles — Flutter + Dart.

Equipo: Rodrigo Quijada · Mauricio Recinos · Paola Guzmán · Francisco Rauda

## Cómo correrla
```bash
flutter pub get
flutter run
```
Con un emulador o celular conectado se instala como app. Para el navegador: `flutter run -d chrome` (F12 → Ctrl+Shift+M → 390 × 844).

Cuenta de prueba para la demo: `andrea@plannit.sv` / `Plannit26` (también hay un botón "Usar cuenta de prueba" en Inicia sesión).

Pruebas:
```bash
flutter test
```

## Pantallas
| Pantalla | Qué hace | Requisito de clase | Archivo |
|---|---|---|---|
| Inicio (estilo Airbnb) | Primera pantalla sin login: categorías, paquetes, decoradores cerca, aviso del carrito, campana | HTTPS GET + `FutureBuilder` | `screens/inicio_screen.dart` |
| Cotiza tu deco | Datos del evento; al validar filtra Explorar con tipo, estilo y presupuesto | **Validación cruzada** | `screens/cotiza_screen.dart`, `utils/validadores.dart` |
| Explorar | Buscador, chips de estilo, filtros (tipo, precio, orden), modo sin conexión | HTTPS GET, `where` | `screens/paquetes_screen.dart`, `utils/filtros.dart` |
| Detalle del paquete | Foto (Hero), descripción, qué incluye, paleta, decorador, **Agregar al carrito** | Formulario con validación | `screens/detalle_paquete_screen.dart` |
| Carrito | Varios eventos, **un paquete por evento**, extras por evento, total con `fold`, envío | **HTTPS POST (201)** + `fold` | `screens/carrito_screen.dart`, `state/carrito_model.dart` |
| Mis solicitudes | Estado en vivo: Enviada → En revisión → Aprobada | Provider | `screens/solicitudes_screen.dart` |
| Notificaciones | Avisos de cada cambio de estado, con contador en la campana | Provider | `screens/notificaciones_screen.dart` |
| Crea tu cuenta | Registro cliente/decorador, aviso si el correo ya existe | **Validación de formularios** | `screens/registro_screen.dart`, `widgets/campo_texto.dart` |
| Inicia sesión | Correo + contraseña, mensajes de error | Validación de formularios | `screens/login_screen.dart` |
| Perfil, Favoritos, Decorador | Datos de la cuenta, paquetes guardados, perfil de cada decorador | Provider | `screens/perfil_screen.dart`, `favoritos_screen.dart`, `decorador_screen.dart` |

## Cómo está hecha
- **Estado (Provider):** cuatro `ChangeNotifier` en `main.dart`:
  - `CarritoModel`: eventos, extras, solicitudes y notificaciones.
  - `SesionModel`: cuenta y favoritos.
  - `CotizacionModel`: cotización, caché sin conexión y búsquedas recientes.
  - `NavegacionModel`: pestaña activa.
- **Totales:** nunca se guardan. Son getters con `where` + `fold` (`CarritoModel.total`, `totalEvento`, `subtotalExtras`).
- **Red:** una sola instancia de `Dio` con un interceptor que registra método, URL, código y tiempo en la consola (`data/api_client.dart`). Cada tipo de `DioException` tiene su propio mensaje.
- **Backend de prueba:**
  - GET → `db.json` (18 paquetes, 6 extras, 6 decoradores) del repo [plannit-studio-api](https://github.com/Francisco10-24/plannit-studio-api), versión `v2`, servido por jsDelivr.
  - POST → JSONPlaceholder (responde 201, no guarda datos).
- **Diseño:** `docs/DESIGN.md` (rojo vino #9B1B30, tipografía Figtree). Diseño original en Google Stitch.

## Probar el modo sin conexión
1. Abrir la app con internet (se guarda el catálogo con la fecha).
2. Quitar internet (modo avión en el emulador, o F12 → Network → Offline en Chrome).
3. Deslizar hacia abajo en Explorar o tocar Reintentar → "Sin conexión · mostrando paquetes guardados del …".
