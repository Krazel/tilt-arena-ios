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

Verificación nativa de las tres selecciones y los estados de carga/estela pendiente
en la candidata 0.3.3 (1). El resto de propuestas sigue sin seleccionar.
