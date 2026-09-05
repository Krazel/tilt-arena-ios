# Verificación — 0.2.0, build prevista 1

5 de septiembre de 2026. Equipo real: Windows x64, Node 24.14.0.

## Resultado comprobado

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

- Compilación y enlace con Xcode, firma, IPA, TestFlight o App Store.
- Las tres pruebas XCTest contra **JavaScriptCore de Apple**; están preparadas.
- Ejecución en simulador; UI nativa real, safe areas, tamaños de texto y accesibilidad.
- Inclinación en dispositivo, precisión física, consumo, calentamiento y fps.
- Comparación temporal exhaustiva de partidas originales: ventana de combo,
  distribución de spawns, protección e interacciones simultáneas de armas.

## Recorrido nativo pendiente

1. Generar con XcodeGen, compilar y ejecutar `scripts/verify-ios.sh`.
2. En iPhone: calibrar apoyando brazos, quietud 10 s, cuatro direcciones, sensibilidad
   suave/normal/rápida y ambas orientaciones. Repetir en postura casi vertical.
3. Recoger hielo y atravesar puntos; esperar deshielo; chocar con burbuja y después
   sin ella. Confirmar radios visibles frente a colisiones.
4. Mantener combo, dejarlo caducar y morir con cadena activa. Verificar que no se
   paga dos veces. Comparar marcadores con una grabación del original.
5. Pausar con un arma activa durante 15 s, continuar; bloquear teléfono, volver;
   girar 180 grados; cancelar calibración; detener y recuperar el sensor.
6. Ensayo de 10 minutos y escena de 300 puntos a 60 fps. Medir app real, no Node.

## Primera compilación preparada

`scripts/verify-ios.sh` compila para simulador y ejecuta XCTest en un iPhone
disponible de Xcode. `.github/workflows/verify-ios.yml` permite el mismo recorrido
en macOS de GitHub, únicamente por lanzamiento manual y sin secretos o subida a
tienda. No existe todavía un repositorio remoto del juego: la consulta de los
repositorios de Krazel no encontró uno con Tilt en el nombre. No se ha creado
ningún repositorio público ni ejecutado Actions.
