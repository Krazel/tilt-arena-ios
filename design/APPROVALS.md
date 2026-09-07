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
