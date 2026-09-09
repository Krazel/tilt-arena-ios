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

## Nuevos poderes y ajuste para 0.3.6 — 2026-09-09

El usuario encarga más atracción solo al protagonista, electricidad con mejor
alcance inicial, pinchos raros sin llegar al 1 % y algunos poderes nuevos creativos.
Fuerza del vórtice al jugador: 300 frente a 180 (+66,7 %); alcance 300, radio visual
y de enemigos/orbes 140. No se toca su coeficiente de arrastre de puntos/orbes.
El primer salto eléctrico alcanza 220 frente a 90; los siguientes conservan 90.
Un aro breve y tenue marca el alcance inicial, con rayos segmentados existentes.

Reparto: bomba/onda/hielo 16 % cada uno, misiles 12 %, fuego/rayos/vórtice 7 % cada
uno, protección/bumerán/señuelo 5 % cada uno, pinchos 4 %. Los pinchos siguen
siendo el menos probable, en promedio una vez cada 25 apariciones. Ni cuotas ni
garantía por partida. Se conserva apertura y reposición inmediata del último orbe.

Dos poderes originales encargados, sin atribuirlos al Tilt to Live de referencia:
- Bumerán: dos cuchillas doradas, núcleo crema y estela breve. Avanza 0,55 s a
  540 unidades/s en el rumbo de recogida; vuelve a la posición actual del jugador
  a 680 unidades/s. Atraviesa y mata a ida/vuelta, retorna antes al llegar a pared,
  desaparece al recogerse o tras 3 s. Máximo tres activos; la siguiente recogida
  sustituye el más antiguo. Destellos distintos de giro y recuperación. Se puede
  dirigir su regreso moviéndose; no modifica control, protección ni recogidas.
- Señuelo: copia hueca verde menta de la flecha, doble contorno y arcos de señal.
  Queda quieta en la posición de activación 4 s. Atrae a puntos a menos de 260,
  incluidas formaciones, a su velocidad normal; al llegar se quedan en su centro.
  No mata, protege ni arrastra orbes. Congelados y apariciones siguen sus reglas;
  pinchos prevalecen y los hacen huir. Al caducar vuelven a perseguir al jugador.
  Una nueva recogida reemplaza el anterior. Los arcos pulsan y se atenúan al final.

Ambos reutilizan la base de orbe aprobada de ChatGPT Images con glifos nuevos y
geometría SpriteKit. Reducir movimiento suprime giro/estela del bumerán y pulsación
del señuelo. Reloj de simulación y pausa conservados; no se introduce otro modo.

## Retirada y revisión visual para 0.3.7 — 2026-09-09

El usuario retira el señuelo: se eliminan aparición, lógica y arte de producción.
Su 5 % se reparte entre bomba (+2), onda (+2) e hielo (+1), sin alterar la rareza
de pinchos/protección ni el resto. Quedan diez poderes. Historial preservado en Git.
Pinchos: punta visual 43 → 48 (+11,6 %), base 32 y giro 2,4 → 4,2 rad/s (+75 %).
El alcance de contacto conserva 35. Aviso final 1,5 s: dientes ámbar con borde
crema, pulsación de 2 Hz y arco exterior de radio 54 que se vacía. Solo los dientes
pulsan; el arco queda legible e inmóvil respecto al mundo. Reducir movimiento
conserva color y cuenta atrás sin giro/pulsación. Pausa congela el reloj visual.

Explosiones: nuevo núcleo crema, corona caliente, ocho lóbulos de expansión,
dos frentes y doce fragmentos, disipación completa en 0,7 s. Colores por poder;
alcances físicos de bomba, burbuja y misiles conservados. Reducir movimiento evita
expansión/fragmentos y reduce luminosidad. Máximo existente de 40 raíces VFX.
Capturas nativas preparadas en dos fases exactas (0,16 y 0,4 s) de la misma clase
animada que usa producción. Las escenas de muerte e hielo conservan sus efectos.

La revisión de balance se documenta en BALANCE.md con datos del motor. El encargo
pide explicación, no rediseñar la progresión: se conservan oleadas y puntuación.
