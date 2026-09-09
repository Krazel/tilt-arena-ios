# Balance medido — candidata 0.3.8

Inspección del motor de producción y medición reproducible del 9 de septiembre
de 2026: `verification/balance-v038.json`. Esta versión corrige la puntuación,
aumenta la movilidad y retrasa el bumerán. Conserva la progresión difícil.

## Dificultad por tiempo

La dificultad depende del tiempo transcurrido, sin adaptación a puntuación,
habilidad ni rendimiento. Cada tanda ordinaria intenta crear
`2 + floor(min(12, tiempo / 12))` enemigos; el intervalo es
`max(0.48, 1.6 - tiempo * 0.006)` segundos.

| Tiempo | Enemigos/tanda | Intervalo | Intentos ordinarios/s | Velocidad al nacer | Intervalo de formación |
|---|---:|---:|---:|---:|---:|
| Inicio | 2 | 1,60 s | 1,25 | 49 | 12 s |
| 1 min | 7 | 1,24 s | 5,65 | 62,8 | 10,5 s |
| 2 min | 12 | 0,88 s | 13,64 | 76,6 | 9 s |
| 3 min | 14 | 0,52 s | 26,92 | 90,4 | 7,5 s |
| 4 min | 14 | 0,48 s | 29,17 | 104,2 | 6 s |
| 5 min | 14 | 0,48 s | 29,17 | 109 | 5 s |

Son intentos con espacio disponible, no enemigos simultáneos ni apariciones
garantizadas. Se descartan posiciones a menos de 105 unidades del jugador;
hay un límite de 550 enemigos vivos. El 80 % de candidatos ordinarios nace en
los bordes y el 20 % en el interior. El aviso previo dura 0,8 segundos.

Desde los 12 segundos se suman formaciones de línea (19), flecha (13) o anillo
(20), también limitadas por espacio y aforo. Su movimiento inicial dura 2,6 s,
a velocidad 68 o 90, antes de perseguir. La velocidad de persecución se fija
al nacer: los enemigos antiguos conservan la suya.

La presión crece especialmente entre el primer y el tercer minuto: la frecuencia
ordinaria al minuto 3 es unas 21,5 veces la inicial. No crece indefinidamente:
tanda máxima a 2:24, intervalo ordinario mínimo a 3:07, velocidad de nuevos
enemigos máxima a 4:21 y frecuencia máxima de formaciones a 4:40.

## Poderes y supervivencia

Se empieza con bomba y misiles. El intervalo programado sigue siendo aleatorio
entre 2,2 y 3,4 segundos (media 2,8), sin crecer con la dificultad. Hay hasta
cinco orbes y duran 12 segundos. Si se recoge o caduca el último, aparece otro
inmediatamente; por ello la cadencia efectiva puede superar la programada.

| Poder | Probabilidad por aparición aleatoria |
|---|---:|
| Bomba | 19 % |
| Onda | 19 % |
| Hielo | 19 % |
| Misiles | 12 % |
| Fuego | 5 % |
| Agujero negro | 5 % |
| Electricidad | 7 % |
| Protección | 5 % |
| Bumerán | 5 % |
| Pinchos | 4 % |

Fuego y gravedad bajan de 7 % a 5 %: aproximadamente un 29 % menos de frecuencia
esperada. Los cuatro puntos se reparten entre bomba (+1), onda (+1) e hielo (+2).
En 20.000 apariciones del motor, fuego salió 5,24 %, gravedad 4,9 %, pinchos
4,015 % y protección 4,91 %. Son probabilidades, sin garantía de aparición cada
25 o 20 recogidas. El jugador alcanza 600 unidades/s (+27,7 %); su colisión con un enemigo
normal suma radios 8 + 10. Un contacto mortal termina la partida salvo protección.
Los pinchos mantienen alcance físico 35; el tamaño visual pasa a 48.

## Puntuación y evaluación

Cada baja da 10 puntos. Las bajas encadenadas a menos de 2,5 segundos acumulan
un bonus de `6 × bajas²`, liquidado al terminar el combo o morir: 10 bajas dan
600 extra; 25, 3.750 extra. Todos los poderes dan **10 puntos al recogerlos**,
incluido fuego (antes 2.000). Diez bajas en un combo, tras una recogida, suman
710 puntos: 10 + 100 + 600. El récord nuevo usa estas reglas y el anterior queda
conservado bajo su clave histórica, sin mezclar puntuaciones incompatibles.
La puntuación no incrementa la dificultad.

El bumerán carga 0,5 s sin inmovilizar ni proteger; sale desde la punta y rumbo
actuales, después conserva su vuelo y retorno. El máximo de tres incluye cargas.
La mayor velocidad normal conserva frenado rápido (coeficiente 24 en neutral,
respuesta al inclinar 22). El fuego impulsor conserva velocidad 1.050.

La curva actual es agresiva por densidad, con oferta programada de poderes
constante y dependencia del azar y la ruta de recogida. No está demostrado que
sea justa o esté bien equilibrada. Las pruebas verifican reglas, rangos y
temporizadores; faltan partidas físicas y datos de supervivencia por minuto
para ajustar la curva con criterio. El usuario pide conservar el juego difícil;
no se suavizan oleadas ni velocidades enemigas. La movilidad adicional puede
facilitar esquivas y exige medir su efecto real. Este informe no sustituye esas partidas.
