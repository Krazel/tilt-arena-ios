# Verificación — candidata 0.3, build 2

5 de septiembre de 2026. Desarrollo local Windows; compilación nativa Xcode 16.4
mediante GitHub Actions macos-15. Historial 0.2: `verification/VERIFICACION-v02.md`.

## Binario de dispositivo final

IPA Release correcta: https://github.com/Krazel/tilt-arena-ios/actions/runs/33983076969 .
Commit compilado `cbb96fa4890960284f2a0737a902b44390a04acf`, canónico `c0f3724`.
Descarga `artifacts/TiltArena-0.3-build2-Local-QA-cbb96fa.ipa`.
SHA256 `0b5b3dc13e39ec788ecc94082b57ee3d673979a7a8adbfb1f5248b6f3ca7d49a`.
CRC íntegro, versión 0.3, build 2, bundle com.dmkr.tiltarena, iPhoneOS ARM64,
Mach-O IOS (2), ejecutable sin cifrar y con permiso 755. Sin firma ni perfil;
Sideloadly aporta la firma al instalar. Sin envío a TestFlight ni App Store.

Motor JS y WAV coinciden byte a byte con la fuente. Xcode optimiza los tres PNG
al formato Apple CgBI: CRC, presencia y dimensiones 1254×1254 comprobadas; no se
presentan como idénticos byte a byte. XCTest carga las tres texturas desde el bundle.
Manifiesto y comprobador: `verification/ipa-v03-build2.json`, `inspect-ipa-v03.py`.
Procedencia de imágenes: `design/imagegen-v03-prompts.json` y `verification/generated-art-v03.json`.

## Pruebas automatizadas

CI nativa: https://github.com/Krazel/tilt-arena-ios/actions/runs/33981931289 .
- Node: 25/25. Incluye resize de arena, independencia de instancias y preservación
  de progreso y posiciones relativas al redimensionar estando en pausa.
- XCTest: 7/7. JavaScriptCore real, perfiles y ejes en ambas orientaciones,
  deltas angulares equivalentes en Normal/Inclinado, resolución adaptable,
  reanudar/cancelar calibración y carga de arte del bundle.
- XCUITest: 2/2. Selección de postura, Jugar, Pausa, Reanudar sin calibración,
  guardado de Personalizado y fixture visual nativo.
- Analizador sintáctico: diez archivos Swift sin errores; esto solo complementa
  la compilación real de Xcode, no la sustituye.

Las capturas iniciales de XCUIApplication recortaban la ventana en paisaje. La
captura simctl del menú llena correctamente la pantalla. Se cambió únicamente
el capturador del test a XCUIScreen, commit público `86f1407`, y se repite la
verificación: https://github.com/Krazel/tilt-arena-ios/actions/runs/33982436995 .
No cambia el código del IPA ni su versión/build: esta repetición es evidencia visual.

## Límites y siguiente ensayo físico

El usuario probó 0.2.0 build 3, informó bordes negros y pidió las mejoras incluidas.
Ese ensayo no valida la nueva 0.3. La escena de arte es un fixture Debug sin
apariciones aleatorias; permite ver las nueve armas y efectos, no medir una partida
ni fps. El IPA Release no activa ese fixture ni los argumentos de prueba.

Pendiente en iPhone: pantalla y zonas seguras en el modelo del usuario; precisión
angular, neutral y deriva; ambas orientaciones; pausa/salir/volver y recuperación
del sensor; sonido, radios visuales de impactos y 10 minutos de fps/temperatura.
Comparación cuantitativa de combos, densidad, Pong, desbloqueos y mezcla pendiente.

## Revisión visual 0.3 build 1 y corrección de cierre

La repetición 33982436995 terminó correctamente: 7 XCTest y 2 XCUITest sin fallos.
Capturas originales de pantalla completa guardadas en `verification/native-v03/`:
menú Inclinado, pausa, Personalizado guardado y escena de nueve orbes/VFX.
Inspección: fondo hasta todos los bordes, menú y botones legibles, orbes completos,
rayos y partículas presentes. Detectado un problema: el tinte de hielo multiplicado
por la nueva textura roja daba puntos oscuros. No se dio por cerrado el arte así.

Build 2 corrige ese problema con una capa nativa de hielo cian y faceta blanca,
sin modificar la imagen generada. Conserva el estado visible de deshielo y el tamaño
físico del punto. La capa se oculta al descongelar; se evita aplanarla en la caché.
Commit público `cbb96fa4890960284f2a0737a902b44390a04acf`, canónico
`c0f37244d9118dea26a267f63c4841e44da1637b`. Se mantiene 0.3 como candidata aún no
entregada y aumenta build a 2 por la recompilación de la corrección visual.

## Resultado final build 2

CI https://github.com/Krazel/tilt-arena-ios/actions/runs/33983075349 completada
con éxito sobre el mismo commit que la IPA final: 25 Node, 7 XCTest y 2 XCUITest,
cero fallos. Capturas completas en `verification/native-v03-build2/`.
La escena final confirma hielo cian con borde claro, puntos rojos, nueve orbes
completos y arena de borde a borde. Los destellos transitorios aparecen según
el instante de captura; el rayo y explosión se revisaron también en build 1.
No hay cambios posteriores en el código de producción compilado.
