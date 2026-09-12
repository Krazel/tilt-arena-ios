# Selecciones visuales — 2026-09-07

Usuario: «haz el primero del lila, el de fuego normal y el primero de agujero negro».
Referencias de ChatGPT Images conservadas completas en vfx-proposals/2026-09-07;
SHA-256 originales en files.json. Idioma español; destino iPhone en paisaje.

| Efecto | Referencia aprobada | Implementación |
| --- | --- | --- |
| Onda lila | 02-onda-abc.png, A Crecientes | Tres crecientes suaves, borde blanco lila y cola violeta |
| Fuego | 09-fuego-abc.png, A Llamarada | Lenguas naranjas con núcleo crema, detrás de la flecha |
| Agujero negro | 07-agujero-negro-abc.png, A Espiral | Tres cintas espirales violetas anchas y núcleo oscuro |
| Hielo | Efecto nativo entregado en 0.3.2 | Se conserva |

El usuario añade: detenerse 0,5 segundos, poder orientar el puntero durante la
carga, salir disparado después y dejar fuego. Animación de carga: aro de progreso,
chispas entrantes y guía de dirección. Geometría y animación nativas SpriteKit;
las láminas aprobadas son referencias, no una textura rectangular pegada al juego.

Ajuste inicial del impulso: 0,45 s a 1050 unidades/s, dirección fijada al terminar
la carga, sin deriva de vórtice durante carga/impulso. Después vuelve el control
normal. Se conserva la protección de contacto del poder durante carga e impulso.
Fuego en el suelo durante 3,2 s, sin acumular segmentos inmóviles contra paredes.
Pausa congela también progreso visual y dirección. Reducir movimiento conserva
la señal de progreso y elimina chispas de carga y oscilación decorativa.

Verificación nativa completada en simulador iPhone 16 Pro, candidata 0.3.3 (1),
Xcode 26.3, run 34137296208. Capturas comparables:
[Carga](C:/Users/dmkra/Documents/Codex%20Apps/TiltArena/verification/native-v033/06-selected-vfx-charge.png)
y [Estela](C:/Users/dmkra/Documents/Codex%20Apps/TiltArena/verification/native-v033/07-selected-vfx-fire-trail.png).
Tres crecientes, tres cintas espirales con núcleo oscuro y fuego naranja-blanco
orientado detrás de la flecha. Se conserva la lectura del concepto mediante
geometría nativa; no se afirma identidad píxel a píxel con las láminas.
SHA-256 de capturas en verification/native-v033/captures.json. Carga, pausa,
rumbo, impulso y estela probados por motor y puente JavaScriptCore real.
Prueba de tacto y rendimiento en iPhone físico pendiente. El resto de propuestas
sigue sin seleccionar. Subida posterior verificada: 0.3.3 (1) activa en TestFlight
interno, build ac24434e-81b1-452d-ba88-87bc8503400c, run 34138863698.

## Corrección encargada para 0.3.4

Usuario: fuego dirigible inmediatamente después de cargar, agujero negro más
pequeño y con mayor atracción, onda lila con carga visible en la punta antes de salir.
Se conservan los tres diseños seleccionados. Se aplica escala 0,7 al vórtice y
un nodo nativo de carga violeta en x=28 de la flecha; no se necesita otro bitmap.
La animación sigue el reloj de simulación. DIRECTION.md documenta el control.
QA nativa de estos ajustes aprobada: run 34144917480, iPhone 16 Pro, Xcode 26.3.
Capturas en verification/native-v034: 08-wave-tip-charge, 09-wave-released y
10-fire-steering. Núcleo violeta en punta antes de disparar, onda liberada delante,
fuego siguiendo un giro de 90° y vórtice al 70 % de su tamaño lineal anterior.
Hashes de las capturas conservados en native-v034/captures.json. Las capturas
de la sección anterior corresponden a 0.3.3. Prueba física pendiente.
Entrega posterior verificada: 0.3.4 (1) activa en TestFlight interno, build
e324b2fe-36fc-416d-b2fb-19d247224dc4, run 34145838577.

## Pinchos encargados para 0.3.5 — 2026-09-08

El usuario pide giro, parpadeo al agotarse y visibilidad con el escudo verde.
Se conservan flecha, escudo y demás VFX. Doce dientes rellenos azul-blanco con
borde oscuro sobresalen del aro verde y giran independientemente del rumbo.
Capturas nativas revisadas en iPhone 16 Pro, paisaje, español, Xcode 26.3:
verification/native-v035/11-spikes-over-shield.png (activo) y
verification/native-v035/12-spikes-expiry-warning.png (mínimo del parpadeo).
La silueta exterior se distingue con ambos poderes; en el aviso se atenúa sin
desaparecer. Flecha y escudo siguen legibles. SHA-256 en native-v035/captures.json.
El XCTest del nodo verifica giro, extremos del aviso, pausa y Reducir movimiento.
Run 34231987284: 43 Node, 12 XCTest y 7 XCUITest pasan. Es QA de simulador;
percepción, sensor y rendimiento físico pendientes. Los cambios son geometría
SpriteKit del diseño existente, sin nuevos bitmaps ni otra selección pendiente.
Entrega posterior verificada: 0.3.5 (1) activa en TestFlight interno, build
0cf5be7f-7c13-4d3a-8a6a-63648b3ea389, run 34233289930.

## Nuevos poderes encargados para 0.3.6 — 2026-09-09

El usuario pide algunos poderes nuevos y delega creatividad. Dos diseños propios:
bumerán con dos cuchillas doradas/núcleo crema y señuelo con copia hueca menta,
doble contorno y arcos de señal. Conservan el lenguaje geométrico y la base
aprobada de orbes de ChatGPT Images; nuevos glifos de bumerán y doble flecha.
La electricidad conserva sus rayos segmentados y añade aro tenue del primer alcance.

Capturas reales del simulador iPhone 16 Pro, paisaje, español, Xcode 26.3, run
34293410088. Revisadas verification/native-v036/13-boomerang-and-decoy.png,
14-boomerang-return.png y 15-electricity-range.png. La copia hueca se distingue
del protagonista opaco; cuchillas legibles en dos posiciones/orientaciones;
once orbes en el ancho útil y rayo inicial de mayor longitud. SHA-256 en
native-v036/captures.json. 72 pruebas aprobadas. No se presenta la captura como
animación ni prueba física; sensor, sensación y rendimiento pendientes en iPhone.
Entrega posterior verificada: 0.3.6 (1) activa en TestFlight interno; build
0ce84509-460b-4cd8-bca9-c4807a381594, run 34294298929.

## Pinchos y explosión encargados para 0.3.7 — 2026-09-09

Señuelo retirado por petición expresa. Doce dientes mayores, giro independiente
más rápido y aviso ámbar con arco decreciente. Explosión de geometría SpriteKit
con núcleo crema, lóbulos de fuego, doble frente y doce fragmentos; conserva
el alcance físico. Base aprobada de orbes e hielo conservados.

Capturas nativas revisadas: native-v037/11-spikes-over-shield.png,
12-spikes-expiry-warning.png, 16-explosion-hot-core.png y
17-explosion-dissipation.png. Hallazgos concretos y hashes en verification/.
QA 34340648343, 71 pruebas; entrega interna 34341910032, build d68c882f-3f34-4f36-9cf2-fe7882611f07.
Capturas de fases reales del renderer, no una prueba física ni un vídeo.

## Carga de bumerán encargada para 0.3.8 — 2026-09-09

El usuario pide espera de medio segundo. Se reutilizan las cuchillas doradas
aprobadas: crecen y giran en la punta con un arco de progreso. Movimiento libre
y disparo en el rumbo final. Reducir movimiento evita giro; pausa congela el reloj.
Capturas del renderer nativo revisadas: verification/native-v038/18-boomerang-charging.png,
13-boomerang-outbound.png y 14-boomerang-return.png. Hallazgos y hashes en verification/.
QA 34343923896, 79 pruebas. Entrega interna 34344923067, build ae14e9eb-f31b-4f14-8be7-a66e3fea3433.
Capturas de simulador; ensayo físico de lectura, velocidad y sensor pendiente.

## Bumerán con rebotes y recarga — 0.3.9, 2026-09-12

Encargo del usuario: rebotes, mayor recorrido y un lanzamiento adicional al
interceptarlo. Conserva cuchillas doradas y carga de 0,5 s. Revisión nativa en
verification/native-v039/: 18-boomerang-charging.png, 13-boomerang-outbound.png,
14-boomerang-wall-bounce.png y 19-boomerang-recharged.png. QA 34711942552, 85 pruebas.
Entrega interna 34712768490; prueba física pendiente.
