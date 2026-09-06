# Referencia: Tilt to Live original

Investigación y primera candidata: 5 de septiembre de 2026. Producto PR-031.
Nombre de trabajo: Tilt Arena. El objetivo es conservar la sensación de esquivar
con inclinación y encadenar armas, con implementación, dibujos y sonido propios.

## Fuentes y calidad de evidencia

1. **Primaria, desarrollador:** [tráiler de OneManLeft](https://www.youtube.com/watch?v=vr03CIfjK4I),
   «Tilt To Live iPhone Game Trailer», duración 1:50. Autor verificado en la página.
   Localizado a través de [Pocket Gamer, 28/02/2010](https://www.pocketgamer.com/tilt-to-live/shumps-get-arty-in-tilt-to-live/)
   y [MikePK, 27/06/2010](https://mikepk.com/2010/06/tilt-to-live-favorite-iphone-game-so-far/),
   que enlazan el mismo vídeo. Se inspeccionaron fotogramas de partidas, no se
   extrajo código ni se reutilizó el vídeo como asset. Capturas locales de consulta
   en `captures/`. No constituyen análisis completo fotograma a fotograma.
2. **Primaria, editor:** [ficha e historial de App Store](https://apps.apple.com/us/app/tilt-to-live/id335454448).
   Verificación actual: la ficha muestra 1.9.0 y una actualización de compatibilidad.
   No asumir que dejó de existir porque artículos antiguos lo describan abandonado.
   Para el comportamiento se toma el Classic original, no cambios actuales sin probar.
3. **Descripción secundaria:** [MobyGames: mecánicas, armas y créditos](https://www.mobygames.com/game/50920/tilt-to-live/).
4. **Guía secundaria contemporánea:** [iPhone AC](https://iphoneac.com/tilttolive.html).
   Aporta controles, puntuación y desbloqueos; se distingue de documentación oficial.
5. **Secundaria/comunidad, menor confianza:** [Points](https://tilttolive.fandom.com/wiki/Points).
   Los pequeños premios por recoger cada arma necesitan contrastarse en el original.
6. **Declaraciones del estudio reproducidas en prensa:** [modos de abril de 2010](https://toucharcade.com/2010/03/20/tilt-to-live-getting-new-game-modes-in-april/).
7. **Comparación de plataformas:** [anuncio HD](https://toucharcade.com/2010/09/22/new-trailer-released-for-upcoming-tilt-to-live-hd/).
   Incluye otro tráiler, de iPad. Su arena se describe como cuatro veces mayor.
   No usar sus densidades absolutas para ajustar la versión de iPhone. Ese segundo
   vídeo queda localizado, pero no se ha analizado visualmente en esta intervención.
8. **Sonido, referencia secundaria:** [iLounge, guía 2010, p.117](https://www.ilounge.com/bg/iLounge_iPad_BG_s.pdf)
   caracteriza la música como rockabilly. No se ha hecho audición comparativa ni
   análisis de tempo del audio original; la música incluida es provisional y propia.
9. **Fuentes técnicas primarias:** [Core Motion](https://developer.apple.com/documentation/coremotion/getting-processed-device-motion-data),
   [horizontal izquierda](https://developer.apple.com/documentation/uikit/uiinterfaceorientation/landscapeleft),
   [horizontal derecha](https://developer.apple.com/documentation/uikit/uiinterfaceorientation/landscaperight),
   [frecuencia de SpriteKit](https://developer.apple.com/documentation/spritekit/skview/preferredframespersecond).
   Leídas también en el Markdown oficial cuando el visor web solo mostró el contenedor.

La antigua web `onemanleft.com/tilttolive/` no respondió: el navegador de investigación
rechazó la recuperación y la consulta HTTP directa recibió conexión denegada.
No se presenta como una página leída ni se sustituye por contenido de un clon de GitHub.

## Lo observado en la referencia visual

El tráiler muestra un campo rectangular completo, fondo verde, flecha clara,
puntos rojos con borde luminoso y orbes de colores. El marcador va arriba y el
combo abajo. Las explosiones y formas de energía contrastan con el fondo; los
enemigos siguen siendo puntos incluso al formar líneas. Las aproximaciones de la
cámara en el montaje publicitario no prueban que el juego tenga zoom dinámico.

En el fotograma pausado en 1:20.85 se lee un combo `1698 × 283`, compatible con
base `6n`. En otro estado observado se leyó `1062 × 177`. El fotograma de 1:00
permite examinar la escala de una descarga de hielo y el HUD. Los efectos de esta
candidata aún son esquemáticos frente a esa referencia. La captura no acredita
tiempos de colisión, latencia o duración de poderes.

## Bucle y controles

La ficha oficial anuncia controles por inclinación y ausencia de botones o
joysticks para jugar. La flecha debe evitar el contacto y alcanzar armas situadas
en el campo. Un punto sin protección termina Classic. Los desafíos desbloquean
armas; no es una progresión de experiencia con vida y niveles.

La guía iPhone AC diferencia Regular, Top-Down y Custom. La versión 1.3 añadió
sensibilidad según el historial oficial. En 0.3 el usuario confirma los nombres
Normal, Inclinado y Personalizado para las posturas. Los neutros propios de 45° y
70° y la postura guardada son decisiones de implementación, no ángulos medidos
del original. Se conservan tres sensibilidades. El puente usa diferencias angulares
con gravedad Z para evitar la pérdida de respuesta de la resta simple en un eje.
No se afirma reproducir las curvas internas; casi vertical requiere ensayo físico.

Apple define `UIInterfaceOrientation.landscapeLeft` con el antiguo botón Home a
la izquierda. Es diferente de nombrar la orientación física con UIDeviceOrientation.
Por ello el motor transforma gravedad a `(gy, -gx)` en horizontal izquierda y
`(-gy, gx)` en derecha. En 0.3 TiltProfile guarda el neutral en ejes de pantalla y
entrega el delta angular al motor. XCTest verifica neutral, giro de 180° y respuesta
equivalente a 45°/70°; Node verifica zona muerta y saturación. Ensayo físico pendiente.

## Enemigos y dificultad

MobyGames describe puntos perseguidores, líneas, flechas dirigidas y una formación
de palas tipo Pong. La presión aumenta con el tiempo. Las cifras y el algoritmo
de aparición no están publicados en las fuentes consultadas.

Nuestra primera aproximación usa puntos idénticos, perseguidores y formaciones
de línea, flecha y anillo. **El anillo es una hipótesis de diseño**, no una formación
del original verificada aquí. Pong queda pendiente. Se conservan huecos y un aviso
antes de activar puntos para evitar muertes por aparición instantánea; duración
del aviso y distancia de seguridad también son ajustes nuestros.

## Armas: comportamiento que se intenta conservar

Resumen funcional apoyado por MobyGames; cantidades y duraciones no verificadas.

| Referencia | Comportamiento objetivo | Candidata |
|---|---|---|
| Nuke | Explosión local al recoger | Radio 155 |
| Blastwave | Frente ancho dirigido | Carga 0,22 s; viaja hacia donde mira la flecha |
| Cluster missiles | Proyectiles que persiguen | Cinco misiles, giran y reasignan objetivos |
| Ice Blast | Congelar y romper al contacto | Radio 205, 4 s; no mata al congelar |
| Bubble Shield | Protección que detona con un impacto | Persiste hasta impacto; radio 130 |
| Spike Shield | Contacto ofensivo durante un tiempo | Radio 35, 5 s |
| Vortex | Atracción de enemigos y orbes | Radio 200, 4 s |
| Lightning | Propagación entre puntos próximos | Grafo de vecinos, distancia 90 |
| Burnicade | Impulso y estela de fuego | Impulso 1,5 s, fuego 3,2 s |

El destino final de los orbes absorbidos y la interacción exacta entre poderes
simultáneos necesitan contrastarse. En esta versión los orbes se acercan al centro
del vórtice y siguen siendo recogibles. Las nueve armas están habilitadas para
evaluación: **no se ha implementado todavía la progresión de desbloqueos**.

## Puntuación y combos

La guía iPhone AC describe que cada baja suma 6 a la base y 1 a la cadena. El
fotograma oficial anterior concuerda con esa relación. La guía comunitaria añade
10 por baja y bonus `6n²`. La implementación paga las bajas inmediatamente y
liquida el bonus al terminar la cadena o morir. Con 213 bajas, el ejemplo produce
`2130 + 6·213² = 274344`. Eso está probado en el motor, pero **el momento exacto
del abono y la ventana de 2,5 s siguen siendo provisionales**.

Los pequeños premios de orbes se mantienen como tabla de menor confianza. No hay
puntuación por sobrevivir ni multiplicador fraccionario con tope 99 como en el
prototipo heredado. Falta grabar cadenas cortas del original para medir caducidad,
abonos y comportamiento al pausar o morir en la misma actualización.

## Modos y presentación sonora

El historial oficial fecha el lanzamiento inicial el 24/02/2010 y sitúa la adición
de Code Red y Gauntlet después; no estaban los tres disponibles desde el primer
día como afirma alguna base secundaria. Frostbite y Burnicade llegaron con 1.4,
y Viva la Turret con 1.6. Esa expansión y su cooperativo quedan fuera del primer corte.

La descripción del estudio en TouchArcade caracteriza Code Red como Classic con
presión máxima desde el inicio. Gauntlet cambia a obstáculos y tiempo de supervivencia.
No mezclar esas reglas con Classic. La guía iPhone AC describe Frostbite con puntos
congelados descendentes y deshielo al fondo. El resto de modos será trabajo posterior.

Créditos de MobyGames atribuyen la música clásica a Steven Paul Glotzer; los otros
modos tienen compositores distintos. La candidata incluye un bucle rítmico y tres
señales sintetizados localmente. Aún no pretende fidelidad tímbrica, musical ni
de mezcla. No se descargaron ni reutilizaron grabaciones del juego.

## Objetivos verificables y orden siguiente

1. Conseguir build de simulador y ejecutar las tres pruebas XCTest del puente real.
2. En iPhone: calibrar en ambas orientaciones; medir deriva <10 unidades lógicas
   durante 10 s y verificar que inclinar a cada lado mueve hacia ese lado.
3. Medir respuesta: objetivo propio 90 % de velocidad en unos 105 ms y frenado por
   debajo del 1 % en 250 ms. Comparar después con grabación del original.
4. Verificar 60 fps sostenidos con 300 puntos y cinco armas, sin confundirlo con
   los tiempos del motor medidos en Windows.
5. Comparar recorridos de 30/60/120 s: densidad, velocidad relativa, salidas entre
   grupos, accesibilidad de orbes y distribución de muertes. Sin datos físicos no
   ajustar por intuición hasta afirmar equivalencia.
6. Medir y cerrar combos, Pong, desbloqueos, arte de efectos y sonido. Después
   ampliar modos. No introducir disparo continuo, vida, experiencia, jefes ni scroll.

## Decisión técnica y reutilización

Se conserva SpriteKit y CoreMotion, con SwiftUI únicamente para las pantallas de
menú y pausa como ya hacía el prototipo. La simulación se aisló en JavaScriptCore
para probar **el mismo archivo de producción** con Node desde Windows. No hay
WebView, descargas de lógica, servicios ni SDKs externos dentro de la app.
Se asume un coste de serializar el estado cada frame; perfilado nativo pendiente.
La web anterior se conserva íntegra como historial; el laboratorio nuevo es una
herramienta de diagnóstico y no sustituye la entrega de iOS.

## Revisión de escala — 6 de septiembre de 2026

Se volvió a ver en Chrome el tráiler del estudio OneManLeft:
https://www.youtube.com/watch?v=vr03CIfjK4I . Se contrastaron además las capturas
ya conservadas official-trailer-11s.png y official-trailer-60s.png. En el campo de
juego de un fotograma (aprox. 1170 × 698 px), puntos con borde de unos 32 px,
orbe de unos 60 px y flecha de unos 50 px. Son estimaciones visuales a partir de
vídeo comprimido, no medidas del código original ni escala física del iPhone.

Respecto a la altura del campo, el original muestra objetos mayores que 0.3.1.
Se adoptan flecha 36, punto diámetro 22 con borde y orbe 56 en arena lógica de
540 de alto: aproximadamente 6,7 %, 4,1 % y 10,4 %. Son decisiones de lectura
propias, no una afirmación de identidad exacta con el original. El hielo del
fotograma de referencia tiene volumen relleno y facetas; se implementa ese tipo
de lectura con geometría original. Alcances físicos de hielo y bomba se conservan.

La garantía de al menos un orbe, y la postura Inclinado con neutral plano a 0°,
proceden del encargo expreso del usuario. No se atribuyen a reglas verificadas del
original. La nueva envolvente de colisión necesita evaluación en iPhone antes de
concluir que los huecos y la presión sean adecuados. Los modos fácil/difícil y el
rediseño de progresión siguen aplazados.
