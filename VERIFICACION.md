# Verificación — candidata 0.2.0

5 de septiembre de 2026. Equipo real: Windows x64, Node 24.14.0.

## Resultado comprobado

- Build final **0.2.0 (2)**: ejecución `33977023251` completada correctamente.
  Commit público `bf55e83612df722d54f79bde78758cf0a6388b71`.
  Archivo de simulador descargado e inspeccionado sin ejecutarlo en Windows:
  bundle, versión, build, plataforma iPhoneSimulator, Mach-O y recursos correctos.
  Los cinco recursos coinciden byte a byte con la fuente canónica.
  Manifiesto: `verification/simulator-artifact.json`.
- Menú nativo capturado e inspeccionado: `verification/native-menu-build2.png`.
  Texto y botón legibles, sin solapamiento visible. La captura conserva los ejes
  del dispositivo en vertical, con contenido en paisaje; no es una maqueta.
  Esto no acredita el recorrido completo de la partida.
- Xcode 16.4: compilación y enlace de la app de simulador completados.
- XCTest sobre JavaScriptCore de Apple: **3/3**, cero fallos. Ejecución
  `33976739671`: el fallo posterior fue al capturar un simulador apagado,
  después de `BUILD SUCCEEDED` y `TEST SUCCEEDED`.
  La build 2 repite las tres pruebas con cero fallos y conserva el informe xcresult.

- `npm test`: **23/23** pasan. Son pruebas ejecutables del archivo de simulación
  que carga la app, más validación de WAV y del contrato de datos.
- `npm run check:swift-syntax`: seis archivos Swift sin errores sintácticos.
  Tree-sitter **no comprueba tipos de Apple ni enlaza el binario**. Se usa
  `--liftoff-only` porque el compilador optimizador WASM del Node instalado falló
  con falta de memoria al cerrar el analizador; con ese modo el proceso termina
  correctamente. Esto no es una limitación observada de la app.
- Navegador: carga de laboratorio sin errores de consola; inicio, pausa por
  espacio y prueba de misiles. La escena fija permite inspeccionar las nueve
  armas, la flecha, los puntos y HUD. Captura `design/candidate-lab.png`.
- Maquetas de cuatro estados renderizadas e inspeccionadas en `design/states.png`.
- Cuatro archivos PCM de audio propios: formato, longitud, señal no silenciosa y
  picos sin recorte comprobados. No se acredita escucha o mezcla en iPhone.
- Benchmark del motor y serialización: 550 puntos quietos, 3600 muestras,
  media 0,86 ms, p95 1,37 ms, máximo 14,74 ms en esta ejecución.
  Resultado exacto y limitaciones en `verification/engine-benchmark.json`.
  **No son medidas de fps nativos**, GPU, JavaScriptCore ni lectura del sensor.

## Qué cubren las pruebas

Neutral, zona muerta, cambio de ejes en ambas orientaciones, saturación; movimiento
equivalente a 30/60/120 Hz; frenado y límites; contacto fatal y colisión barrida;
apariciones en aviso; explosión local; congelar, romper y descongelar; burbuja de
un impacto; misiles con trayecto; onda dirigida; propagación de rayo; púas y fuego;
atracción de vórtice; combo entero y pago único; pausa; orbes caducados; fin manual;
reproducibilidad por semilla; límites de entidades; JSON y recursos de audio.

## No ejecutado / no acreditado

- Firma para dispositivo, IPA, TestFlight o App Store.
- Recorrido completo de UI nativa, safe areas, tamaños de texto y accesibilidad.
- Inclinación en dispositivo, precisión física, consumo, calentamiento y fps.
- Comparación temporal exhaustiva de partidas originales: ventana de combo,
  distribución de spawns, protección e interacciones simultáneas de armas.

## Recorrido nativo pendiente

1. Revisar el artefacto y captura generados por `scripts/verify-ios.sh`.
2. En iPhone: calibrar apoyando brazos, quietud 10 s, cuatro direcciones, sensibilidad
   suave/normal/rápida y ambas orientaciones. Repetir en postura casi vertical.
3. Recoger hielo y atravesar puntos; esperar deshielo; chocar con burbuja y después
   sin ella. Confirmar radios visibles frente a colisiones.
4. Mantener combo, dejarlo caducar y morir con cadena activa. Verificar que no se
   paga dos veces. Comparar marcadores con una grabación del original.
5. Pausar con un arma activa durante 15 s, continuar; bloquear teléfono, volver;
   girar 180 grados; cancelar calibración; detener y recuperar el sensor.
6. Ensayo de 10 minutos y escena de 300 puntos a 60 fps. Medir app real, no Node.

## Compilación en GitHub

Repositorio público autorizado: https://github.com/Krazel/tilt-arena-ios .
El workflow manual compila para simulador, ejecuta Node y XCTest, y conserva
el paquete de la app, el informe xcresult y una captura nativa. No usa secretos
de firma ni sube a tienda. Alcance e intentos: `verification/publication-scope.md`.
