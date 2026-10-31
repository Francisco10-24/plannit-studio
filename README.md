# Plannit Studio

Marketplace móvil para contratar **decoración de eventos** en San Salvador: el cliente explora paquetes, arma su carrito (varios eventos, un paquete por evento) y envía solicitudes; el decorador las recibe y las aprueba en tiempo real.
Proyecto de Desarrollo de Aplicaciones Móviles — Flutter + Dart + Firebase.

Equipo: Rodrigo Quijada · Mauricio Recinos · Paola Guzmán · Francisco Rauda

## Cómo ejecutar
```bash
flutter pub get
flutter run
```
- Flutter 3.47.1 (stable), Dart 3.13.1.
- La configuración de Firebase ya está en el repo (`lib/firebase_options.dart` y `android/app/google-services.json`, generados con `flutterfire configure`). No hace falta ninguna clave extra.
- Las cuentas de prueba (cliente y decorador) están en el documento de entrega, no en este repositorio.

Pruebas y análisis:
```bash
flutter test
flutter analyze
```

## Arquitectura por capas
| Capa | Carpetas y clases |
|---|---|
| Presentación | `lib/screens/` (13 pantallas), `lib/widgets/` |
| Estado | Provider + ChangeNotifier: `CarritoModel`, `SolicitudesModel`, `SesionModel`, `CotizacionModel`, `NavegacionModel` (`lib/state/`) |
| Repository | `CatalogoRepository`, `SolicitudesRepository` (contrato) con `FirestoreSolicitudes` y `HttpSolicitudes` (`lib/data/repositorios/`) |
| Fuentes de datos | Remota: `DioCatalogoRemoto` (HTTPS), Firestore. Local: Sembast (`CatalogoLocal`, `CarritoLocal`), SharedPreferences y flutter_secure_storage (`lib/data/fuentes/`, `lib/data/servicios/`) |
| Servicios externos | Firebase Auth, Cloud Firestore, Analytics, Crashlytics, Cloud Messaging; catálogo en [plannit-studio-api](https://github.com/Francisco10-24/plannit-studio-api) vía jsDelivr |

## Pantallas
Inicio · Cotiza tu deco · Explorar · Detalle del paquete · Carrito · Mis solicitudes · Notificaciones · Crea tu cuenta · Inicia sesión · Perfil · Favoritos · Decorador · Panel del decorador.

## Temas del curso aplicados
| Tema | Dónde |
|---|---|
| Formularios y validación cruzada | `screens/registro_screen.dart`, `screens/cotiza_screen.dart`, `utils/validadores.dart` |
| HTTP GET/POST con Dio, interceptor, `DioException` | `data/api_client.dart`, `data/repositorios/` |
| Repository + inyección por constructor | `data/repositorios/`, `main.dart` |
| SharedPreferences | `data/servicios/almacenamiento.dart` (favoritos, última categoría, bienvenida) |
| flutter_secure_storage | `data/servicios/almacenamiento.dart` (último correo de inicio de sesión) |
| Sembast (NoSQL local) | `data/fuentes/` (caché del catálogo sin conexión, carrito persistente) |
| Depuración y pruebas | `analysis_options.yaml`, `assert` en `CarritoModel`, `test/` con fakes |
| Firebase | Auth, Firestore (`firestore.rules`), Analytics, Crashlytics, FCM (`main.dart`, `data/servicios/`) |

## Modo sin conexión
1. Abrir la app con internet: el catálogo se guarda en Sembast con su fecha.
2. Quitar internet (modo avión) y deslizar hacia abajo en Explorar: aparece "Sin conexión · mostrando paquetes guardados del …".
