# Plannit Studio

Marketplace móvil para contratar **decoración de eventos** en San Salvador (cumpleaños, bodas, quince años, baby showers, graduaciones).
Proyecto de Desarrollo de Aplicaciones Móviles — Flutter + Dart.

Equipo: Rodrigo Quijada · Mauricio Recinos · Paola Guzmán · Francisco Rauda

## Cómo correrla
```bash
flutter pub get
flutter run -d chrome
```
Para verla como celular en Chrome: F12 → ícono de dispositivo (Ctrl+Shift+M) → 390 × 844.

Pruebas:
```bash
flutter test
```

## Pantallas y requisito que cubre cada una
| Pantalla | Requisito | Dónde está la lógica |
|---|---|---|
| Inicio (estilo Airbnb) | Primera pantalla, sin login. GET del catálogo | `lib/screens/inicio_screen.dart` |
| Cotiza tu deco | **Validación cruzada**: montaje 2 h antes del evento, arco XL ≥ 30 m², presupuesto máx ≥ mín | `lib/screens/cotiza_screen.dart`, `lib/utils/validadores.dart` |
| Paquetes de deco | **HTTPS GET** con `FutureBuilder` (cargando / error / datos) y modo sin conexión con fecha | `lib/screens/paquetes_screen.dart` |
| Mi deco | **HTTPS POST** (201 Created) y total calculado con `fold` | `lib/screens/mi_deco_screen.dart`, `lib/state/evento_model.dart` |
| Crea tu cuenta | **Validación de formularios**: `Form`, `GlobalKey<FormState>`, `validator` | `lib/screens/registro_screen.dart`, `lib/widgets/campo_texto.dart` |

## Cómo está hecha
- **Estado:** `Provider` + `ChangeNotifier` (`EventoModel`). El total nunca se guarda: es un getter con `where` + `fold`.
- **Red:** una sola instancia de `Dio` con un interceptor que registra método, URL, código y tiempo (`lib/data/api_client.dart`). Cada tipo de `DioException` tiene su propio mensaje.
- **Backend de prueba:**
  - GET → `db.json` del repo [plannit-studio-api](https://github.com/Francisco10-24/plannit-studio-api) servido por jsDelivr.
  - POST → JSONPlaceholder.
- **Diseño:** `docs/DESIGN.md` (rojo vino #9B1B30, tipografía Figtree). Diseño original en Google Stitch.

## Probar el modo sin conexión
1. Abrir la app con internet (se guarda el catálogo con la fecha).
2. F12 → Network → Offline.
3. Ir a Explorar → aparece "Sin conexión · mostrando paquetes guardados del …" con el botón Reintentar.
