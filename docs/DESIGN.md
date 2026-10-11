# Design System: Plannit Studio — Decoración de eventos (App móvil)

Proyecto Stitch (v2, nicho decoración): https://stitch.withgoogle.com/projects/14659848071634673797
Proyecto Stitch anterior (v1, salones, descartado): https://stitch.withgoogle.com/projects/14223092761542140289

## 0. Nicho
Marketplace para contratar DECORACIÓN de eventos en San Salvador. El cliente ve rápido paquetes de decoradores locales (arcos de globos, centros de mesa, backdrops, letras LED, mesas principales) para cumpleaños, bodas, quince años, baby showers y graduaciones, los compara y envía solicitud al decorador.

## 1. Visual Theme & Atmosphere
Juvenil, fresca y elegante; "digna de Instagram" pero limpia. Fondo rosado papel, tinta vino oscura, un solo acento rojo elegante. Tipografía estilo Airbnb (Figtree); monoespaciada solo para datos técnicos HTTP.
- Densidad 4/10, variación 6/10, movimiento 4/10.
- Móvil vertical 390 x 844. Construible en Flutter con Scaffold, AppBar, Column, Row, Stack, TextFormField, ListView.builder, BottomNavigationBar.

## 2. Color Palette & Roles
- **Blush Paper** (#FBF4F1) — fondo de pantallas.
- **Soft White** (#FFFDFC) — cards, inputs.
- **Deep Wine Ink** (#2B1216) — texto principal.
- **Muted Mauve** (#8A6E72) — texto secundario.
- **Rose Border** (#F0DEDA) — bordes 1px, divisores, botón deshabilitado.
- **Rojo Elegante** (#9B1B30) — ÚNICO acento: botón primario, chips activos, foco, ícono activo del nav, estrellas.
- **Soft Rose** (#F7DDE0) — fondo de tags y franja técnica HTTP.
- Semánticos: Error **#D9480F** (rojo-naranja, distinto del acento), Éxito **#3F7D5A**, Aviso **#C98A1B**.

## 3. Typography Rules
Estilo Airbnb. Airbnb usa "Airbnb Cereal" (fuente propietaria, no disponible en Google Fonts); el equivalente libre más cercano es **Figtree**.
- **Títulos:** Figtree 700–800, tracking -0.3px. H1 28–32px, H2 22–24px, H3 18–20px.
- **Cuerpo/UI:** Figtree 400/500, 15–16px, interlineado 1.5. Labels 13px. Botones Figtree 600.
- **Precios:** Figtree 600 (no monoespaciada, como Airbnb).
- **Mono:** Space Mono SOLO en las franjas técnicas HTTP (GET / POST).
- En Flutter: paquete `google_fonts` → `GoogleFonts.figtreeTextTheme()` en `ThemeData`.
- Prohibido: Inter, Roboto por defecto, serif genéricas, caligrafía.

## 4. Component Stylings
* **Botón primario:** pill 52px, Rojo Elegante, texto blanco Figtree 600. Deshabilitado: fondo Rose Border, texto Muted Mauve + texto auxiliar explicando por qué.
* **Cards:** Soft White, radio 24px, borde 1px Rose Border, sombra difusa teñida de vino. Card de paquete: foto grande 20px radio + tag "Disponible" + corazón, nombre en Figtree, decorador en Mauve, 4 puntos de color de la paleta, precio en Figtree 600, estrellas rojas.
* **Inputs:** label arriba, radio 16px, alto 52px. Foco borde 2px Rojo Elegante. Inválido: borde 2px #D9480F + texto de error debajo con ícono. Válido: check verde.
* **Chips:** pill 36px; activo relleno Rojo Elegante texto blanco; inactivo Soft Rose.
* **Banners:** color semántico al 10–12% de opacidad, ícono + texto + acción.
* **Loaders:** skeleton con shimmer, mismas medidas que la card real.
* **Bottom nav:** Inicio, Explorar, Mi deco, Perfil.

## 5. Mapeo a requisitos de clase
| Pantalla | Requisito | Lógica en Flutter |
|---|---|---|
| 0. Inicio (primera al abrir, estilo Airbnb) | Pantalla de entrada, sin login | Barra de búsqueda pill, `TabBar` de categorías, feed con `ListView.builder` de cards grandes con foto, carrusel horizontal "Decoradores cerca de ti". Login solo se pide al enviar solicitud |
| 1. Crea tu cuenta | Validación de formularios | `Form` + `TextFormField.validator` (regex correo, 8 dígitos, contraseña ≥8 con número y mayúscula) |
| 2. Cotiza tu deco | Validación cruzada | Validator que compara campos: fin de montaje ≤ inicio − 2 h; arco XL ⇒ espacio ≥ 30 m²; presupuesto máx ≥ mín |
| 3. Paquetes de deco | HTTPS GET | `http.get` a `/v1/paquetes`, estados cargando (skeleton), error (Reintentar), sin conexión (caché con fecha, req. 5) |
| 4. Mi deco | HTTPS POST + `fold` | `http.post` a `/v1/solicitudes`, total = `items.fold(0, (s, i) => s + i.precio)`, estado Enviada → En revisión → Aprobada |

## 6. Anti-Patterns (Banned)
Sin emojis, sin negro puro, sin neón ni degradados morados, sin 3 cards iguales en fila, sin nombres genéricos (usar Andrea Menjívar, Santa Tecla, Escalón), sin números redondos falsos, sin frases cliché de IA.
