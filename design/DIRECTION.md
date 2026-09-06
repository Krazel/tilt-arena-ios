# Dirección visual y controles — 0.3.2

Revisión solicitada el 6 de septiembre de 2026. Comparación visual con el tráiler
oficial de Tilt to Live; geometría y efectos propios, sin reutilizar assets del original.

## Tamaños y lectura

Se conserva la arena adaptable a pantalla completa, escala uniforme y altura lógica
640. Aumentan los objetos respecto a 0.3.1: flecha de 28 a 36 unidades de ancho,
puntos de radio 7 a 10 (borde claro) y orbes de 42 a 56. El halo y las pulsaciones
pueden ampliar ligeramente su apariencia. Se conserva la forma vectorial de los
enemigos solicitada por el usuario. Los congelados siguen siendo cian.

La flecha mantiene una zona central de colisión indulgente: radio 9. El contacto
con puntos pasa de 14 a 19 unidades; recogida de orbes, de 23 a 33. Margen de la
flecha 23 para alojar las esquinas al girar. Estas envolventes afectan a los huecos
transitables: no se afirma que la dificultad percibida sea idéntica. No se añaden
modos ni se retoca la programación de oleadas y velocidad.

Siempre queda un orbe durante la partida: tras recoger o caducar el último, se
crea otro en ese mismo paso, a más de 85 unidades de la flecha. Veinte candidatos
priorizan distancia de enemigos; si ninguno sirve, cuadrícula determinista acotada.
La reposición no activa otra recogida en ese paso, no supera cinco orbes y respeta
pausa/final. Las fixtures con spawning:false se mantienen aisladas.

## Posturas

Orden visible: Calibrar, Normal, Inclinado. Calibrar es el valor inicial y se aplica
una vez al migrar preferencias antiguas. Conserva el neutral personalizado guardado;
si existe, Jugar y Reanudar lo reutilizan. Si no existe, Calibrar y jugar toma la
muestra antes de empezar. Las elecciones posteriores se recuerdan.

Normal: unos 45° sobre la mesa. Inclinado: iPhone horizontal, pantalla hacia arriba,
como apoyado en una mesa, neutral 0°. Los dos sentidos de paisaje conservan la
transformación del sensor. Recalibrar sigue siendo una acción independiente.

Por petición posterior del usuario se elimina el selector Suave/Normal/Rápida.
La sensibilidad queda fija en 1 (la anterior Normal) para todas las posturas.
No se lee ni se escribe classic.sensitivity; valores antiguos dejan de influir.
El selector modificaba la inclinación necesaria para alcanzar la velocidad máxima,
no dicha velocidad: al saturar la entrada, las tres opciones se comportaban igual.

## Efectos nativos

Hielo con silueta rellena, doce facetas, expansión breve y partículas. Explosiones
con núcleo radial, dos ondas y rayos; relámpago segmentado de doble trazo. Frente
de onda con cuerpo luminoso, vórtice de tres brazos que cubren su zona de influencia
y estela continua de misiles. Aparición y recogida de orbes tienen pulsos distintos.

Texturas conservadas de ChatGPT Images: orb-glass-v03 y energy-spark-v03. El nuevo
volumen visual se dibuja y anima en SpriteKit. enemy-dot-v03 permanece archivado y
excluido de la app. Los efectos transitorios tienen un máximo de 40 raíces; los de
armas desplazan chispas antiguas cuando se alcanza el límite. Duración máxima 1,15 s.
Reducir movimiento suprime estelas y expansión decorativa, y reduce partículas.

## Verificación

Pruebas del motor: reposición rápida repetida, caducidad, fallback de colocación,
pausa/final y reglas anteriores. Nativas: controles guardados, migración, inclinación
plana, respuesta equivalente, giro y reanudación. Interfaz: inicio con Calibrar,
reapertura con perfil guardado y posturas. Captura nativa de todos los orbes y otra
con hielo/explosión detenidos en su máximo mediante fixture exclusiva de Debug.
El fixture no es una prueba de rendimiento físico. Ensayo con iPhone pendiente.

Historial: DIRECTION-v03.md y DIRECTION-v02.md.
