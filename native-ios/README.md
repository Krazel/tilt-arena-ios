# Candidata iOS 0.2.0 · build 3

SpriteKit dibuja; CoreMotion obtiene inclinación; SwiftUI presenta los menús.
JavaScriptCore ejecuta `Resources/classic-core.js`, exactamente el motor de las
pruebas Node. Funciona sin red, cuentas, WebView, anuncios ni compras.

En Mac: instalar Xcode y XcodeGen, ejecutar `bash ../scripts/verify-ios.sh` desde
esta carpeta. Genera el proyecto, compila para simulador y ejecuta XCTest.
Alternativamente `xcodegen generate` y abrir `TiltArena.xcodeproj`.
Para un iPhone se necesita seleccionar el equipo de firma propio en Xcode.
Bundle ID heredado: `com.dmkr.tiltarena`; no se ha registrado uno nuevo.

En iPhone se calibra una postura estable antes de jugar. En simulador se habilita
arrastre porque no hay un sensor físico. El cambio de orientación, la pérdida de
datos del sensor y la salida de la app pausan la partida. Al volver se recalibra.

Las nueve armas están abiertas para comparar; desbloqueos y modos secundarios
pendientes. Valores de radios, velocidades, tiempo de combo y mezcla de sonido
son provisionales; deben contrastarse jugando en un iPhone real.

**Estado:** compilación con Xcode 16.4 y tres XCTest de integración aprobados
en simulador. Pendientes la inclinación física y el recorrido completo de UI
en iPhone. Las tres XCTest corresponden a build 2; el motor no ha cambiado.
Build 3 compilada Release para iPhoneOS ARM64 y empaquetada como IPA Local-QA,
con 23 pruebas Node aprobadas. No está subida a TestFlight ni App Store.

Para generar la IPA: `bash scripts/build-local-qa.sh` desde la raíz del repositorio,
o ejecutar el workflow **Build iPhone Local-QA IPA**. Es una IPA de dispositivo
sin firma: cargarla en Sideloadly para firmar e instalar con la cuenta del usuario.
El artefacto incluye versión, build, commit y SHA256. No se necesitan secretos
en CI. Resultado de build 3:
https://github.com/Krazel/tilt-arena-ios/actions/runs/33979490999 .

Código y ejecuciones: https://github.com/Krazel/tilt-arena-ios .
El artefacto de Actions conserva el `.app` de simulador en `.tar.gz` para mantener
sus permisos. En Mac se extrae y se instala con `xcrun simctl install booted`
seguido de la ruta de `TiltArena.app`. No se puede instalar ese paquete en iPhone.
