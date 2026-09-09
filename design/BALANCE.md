# Balance medido — candidata 0.3.7

Inspección del motor de producción y medición reproducible del 9 de septiembre
de 2026: `verification/balance-v037.json`. Esta versión cambia presentación y
retira el señuelo; conserva la progresión, los alcances de daño y la puntuación.

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
| Bomba | 18 % |
| Onda | 18 % |
| Hielo | 17 % |
| Misiles | 12 % |
| Fuego | 7 % |
| Agujero negro | 7 % |
| Electricidad | 7 % |
| Protección | 5 % |
| Bumerán | 5 % |
| Pinchos | 4 % |

El 5 % retirado del señuelo se reparte entre bomba, onda e hielo. En una muestra
determinista de 20.000 apariciones del motor, los pinchos salieron el 3,91 % y
la protección el 5,045 %. Son probabilidades, sin garantía de aparición cada
25 o 20 recogidas. El jugador alcanza 470 unidades/s; su colisión con un enemigo
normal suma radios 8 + 10. Un contacto mortal termina la partida salvo protección.
Los pinchos mantienen alcance físico 35; el tamaño visual pasa a 48.

## Puntuación y evaluación

Cada baja da 10 puntos. Las bajas encadenadas a menos de 2,5 segundos acumulan
un bonus de `6 × bajas²`, liquidado al terminar el combo o morir: 10 bajas dan
600 extra; 25, 3.750 extra. Recoger bomba da 3 puntos, onda 5, electricidad 6
y la mayoría de los demás poderes 10. **Recoger fuego da 2.000 puntos**:
es una descompensación importante conservada para no alterar puntuación en un
encargo de explicación. La puntuación no incrementa la dificultad.

La curva actual es agresiva por densidad, con oferta programada de poderes
constante y dependencia del azar y la ruta de recogida. No está demostrado que
sea justa o esté bien equilibrada. Las pruebas verifican reglas, rangos y
temporizadores; faltan partidas físicas y datos de supervivencia por minuto
para ajustar la curva con criterio. Este informe no sustituye esas partidas.
