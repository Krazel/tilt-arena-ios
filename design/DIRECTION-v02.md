# Dirección visual — candidata Classic 0.2.0

Elegida dentro del encargo delegado el 05/09/2026; no hay una aprobación visual
expresa del usuario para esta nueva propuesta. Se prioriza lectura del original.

- Arena fija 960 × 640, relación 3:2. En iPhone ancho se centra sin estirar ni
  agrandar el terreno. Safe areas y botón de pausa quedan fuera del campo siempre
  que el tamaño del dispositivo lo permita; validar especialmente iPhone SE.
- Fondo verde oliva con líneas y círculos propios; borde crema tenue. Flecha
  blanca de 28 × 22 y hitbox circular de radio 7, puntos rojos de radio 7.
- Nueve orbes con siluetas internas diferentes. Color apoya al símbolo; congelación
  y caducidad tienen también cambios de presencia. Reducir movimiento limita
  pulsos decorativos. La lectura de congelados por forma aún necesita mejorarse.
- Puntuación arriba a la izquierda, récord a la derecha, base × cadena debajo.
- Menú: marca Krazel Games, Clásico, breve regla, récord, calibrar y jugar,
  sensibilidad y silencio. Calibración: postura, progreso y volver. Pausa:
  continuar con calibración, ajustes y terminar. Final: resultado, combo máximo,
  tiempo, récord, repetir y menú. Mensaje de fallo permite volver sin iniciar
  una partida inmóvil por ausencia de sensor.
- Los controles del menú son SwiftUI con etiquetas accesibles y altura mínima
  44 pt. No se afirma accesibilidad VoiceOver de la acción de esquivar.

Referencias completas de los estados: `states.svg` (maqueta, no captura nativa).
Composición de arena: `candidate-lab.png` (navegador, motor real con escena fija).
Implementación: `native-ios/Sources/ClassicArt.swift` y `ClassicScene.swift`.
Símbolos, fondo y audio son generados por código propio. No se usa el arte de
referencia del original en el bundle. El arte heredado queda preservado en Git.

Verificación visual realizada: lectura general del laboratorio a 960 unidades,
HUD y puntos frente a los fotogramas originales. Pendiente: comparación de una
captura real de iOS a igual tamaño, escalado Retina, notch, tipografía y animación.
Los efectos de hielo/explosión todavía son demasiado esquemáticos para dar por
cerrada la fidelidad visual. La maqueta no sustituye esa comprobación.
