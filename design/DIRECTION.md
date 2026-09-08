# Dirección visual y controles — 0.3.2

Revisión solicitada el 6 de septiembre de 2026. Comparación visual con el tráiler
oficial de Tilt to Live; geometría y efectos propios, sin reutilizar assets del original.

## Tamaños y lectura

Se conserva la arena adaptable a pantalla completa, escala uniforme y altura lógica
640. Aumentan los objetos respecto a 0.3.1: flecha de 28 a 36 unidades de ancho,
puntos de radio 7 a 10 (borde claro) y orbes de 42 a 56. El halo y las pulsaciones
pueden ampliar ligeramente su apariencia. Se conserva la forma vectorial de los
enemigos solicitada por el usuario. Los congelados siguen siendo cian.

La flecha mantiene una zona central de colisión indulgente: radio 8, reducido desde
9 por petición posterior del usuario. El contacto con puntos queda en 18 unidades
(antes 19 en esta candidata); recogida de orbes, 33. Margen de la
flecha 23 para alojar las esquinas al girar. Estas envolventes afectan a los huecos
transitables: no se afirma que la dificultad percibida sea idéntica. No se añaden
modos ni se retoca la programación de oleadas. Por petición del usuario, velocidad
máxima de la flecha 440 → 470 unidades/s (+6,8 %). Respuesta y frenado conservan
su constante; el impulso de fuego mantiene su multiplicador 1,5. Recogida de orbes
y contacto ofensivo con protecciones conservan sus alcances independientes.

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

## Ajustes posteriores para 0.3.3

Por petición del usuario, enemigos en z=3,5, por encima de orbes/proyectiles (3)
y debajo del protagonista (4). El agujero negro también aplica deriva al jugador:
60·(1-d/r)·min(1,d/24) unidades/s dentro de radio 200. Es suave, desaparece en el
borde y se amortigua cerca del centro. La inclinación sigue controlando velocidad;
campos superpuestos promedian su atracción para evitar que se acumulen sin límite.
El desplazamiento se aplica antes de recogidas y colisiones y se limita a la arena.
Pausa y caducidad desactivan la deriva. No se altera el arrastre de puntos/orbes.

Selección posterior: Onda A Crecientes, Fuego A Llamarada y Agujero negro A Espiral.
Referencias y detalle en APPROVALS.md. Fuego ahora carga 0,5 s inmóvil y orientable,
lanza automáticamente un impulso de 0,45 s a 1050 unidades/s y deja estela durante
3,2 s. Aro progresivo, partículas entrantes, guía de dirección y destello de salida.
La carga conserva protección de contacto; al terminar el impulso vuelve el control
normal. Pausa congela la carga; recoger otro fuego inicia una carga nueva.

## Correcciones de control y carga para 0.3.4

Petición del usuario posterior a probar 0.3.3: tras el lanzamiento de fuego se
puede dirigir inmediatamente a velocidad completa hasta que acaba. Se conserva
carga 0,5 s, velocidad 1050 y duración 0,45 s; el input gira el rumbo en cada paso,
sin frenar por menor inclinación. Neutral conserva el rumbo. La estela mantiene
posición y orientación de cada tramo al girar.

Agujero negro: radio físico y visual 140 frente a 200 (30 % menor), coeficiente
de atracción del protagonista 180 frente a 60. Sigue amortiguado en borde/centro,
promedia superpuestos y permite escapar. No amplía radios invisibles ni cambia
la duración o la fuerza base de arrastre de enemigos y orbes.

Onda lila: carga 0,5 s con núcleo, aro y chispas en la punta de la flecha.
Se puede seguir moviendo y apuntando mientras carga. Sale desde la punta con el
rumbo del momento de disparo. Las recogidas encadenadas conservan sus disparos;
la pausa congela temporizador y animación. Reducir movimiento conserva núcleo
y progreso y suprime las chispas decorativas.

## Atracción, pinchos y rareza para 0.3.5

Encargo del 2026-09-08: el alcance de atracción del protagonista pasa de 140 a
300, conservando tamaño del vórtice y alcance de enemigos/orbes en 140. Mantiene
coeficiente 180, caída en borde/centro y promedio al superponerse. Este alcance
separado reemplaza expresamente la decisión de 0.3.4 de coincidir con lo visible.

Mientras hay pinchos (5 s), los puntos activos huyen a su velocidad habitual;
la huida prevalece sobre formaciones. Congelados y apariciones conservan sus
estados. Al caducar, vuelven a su movimiento normal. Límites y contacto ofensivo
35 no cambian; el escudo verde no se consume al matar con pinchos.
Doce dientes rellenos de radio visual 43, borde oscuro, encima del escudo de radio
32. Giran a 2,4 rad/s y parpadean dos veces/s los últimos 1,25 s, sin desaparecer
del todo. Reloj de simulación: la pausa congela giro y aviso. Reducir movimiento
conserva dientes fijos y aviso atenuado estable.

Probabilidades por aparición: bomba/onda/hielo 20 % cada uno, misiles 16 %,
fuego/rayos/vórtice 7 % cada uno, protección 2 %, pinchos 1 %. El usuario confirmó
el reparto por grupos y pidió pinchos como el menos probable y protección justo
antes. Porcentajes elegidos como ajuste inicial, sin cuotas garantizadas.
Los dos orbes de apertura siguen siendo bomba y misiles; el muestreo ponderado
se aplica a nuevas apariciones y reposición inmediata del último orbe.
