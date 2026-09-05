# Candidata iOS 0.3 · build 2

SpriteKit dibuja; CoreMotion obtiene inclinación; SwiftUI presenta los menús.
JavaScriptCore ejecuta `Resources/classic-core.js`, el mismo motor de las pruebas
Node. iPhone, iOS 16+, español. Funciona sin red, cuentas, WebView, anuncios ni compras.

Arena adaptable a pantalla completa, posturas Normal/Inclinado/Personalizado,
calibración guardada y Reanudar directo. El cambio de orientación, la pérdida de
sensor y salir de la app pausan la partida; Reanudar conserva la postura elegida.
En simulador se permite arrastre porque no hay sensor físico.

Orbes, puntos y destellos usan tres texturas generadas con ChatGPT Images.
Los glifos de las nueve armas y los efectos animados se dibujan en SpriteKit.
Las nueve armas están abiertas para comparar; desbloqueos y modos secundarios
pendientes. Balance, respuesta física y fps necesitan pruebas en iPhone.

En Mac: Xcode y XcodeGen, `bash scripts/verify-ios.sh` desde la raíz del repositorio.
Genera el proyecto, compila y ejecuta 7 XCTest y 2 XCUITest; exporta capturas nativas.
`npm test`: 25 pruebas del motor y recursos. Las tres suites pasan en CI.
El fixture `--visual-qa` existe solo en Debug para revisar arte, no en el IPA Release.

IPA Local-QA Release iPhoneOS ARM64 0.3 build 2 compilada y verificada:
https://github.com/Krazel/tilt-arena-ios/actions/runs/33983076969 .
No está subida a TestFlight ni App Store. Sin firma: cargar en Sideloadly para
firmar e instalar con la cuenta del usuario. Bundle ID: `com.dmkr.tiltarena`.

Para generar: `bash scripts/build-local-qa.sh` o workflow **Build iPhone Local-QA IPA**.
El artefacto incluye versión, build, commit y SHA256. No necesita secretos de firma.
El paquete `.tar.gz` del otro workflow es para simulador y no se instala en iPhone.
