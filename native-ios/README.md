# Candidata iOS 0.3.1 · build 1

SpriteKit dibuja; CoreMotion obtiene inclinación; SwiftUI presenta los menús.
JavaScriptCore ejecuta Resources/classic-core.js, el motor compartido con Node.
iPhone, iOS 16+, español. Sin red, cuentas, WebView, anuncios ni compras.

Arena adaptable, posturas Normal/Inclinado/Personalizado, calibración guardada
y Reanudar directo. Enemigos originales vectoriales restaurados: círculos rojos
con borde claro; congelados cian. Orbes y destellos conservan las dos texturas
de ChatGPT Images. Las nueve armas y los VFX se dibujan con SpriteKit.
La dificultad no cambia en esta corrección.

Pruebas: 25 Node, 7 XCTest y 2 XCUITest aprobados con Xcode 26.3.
https://github.com/Krazel/tilt-arena-ios/actions/runs/34043377249
El fixture visual existe solo en Debug; control físico y fps requieren iPhone.

Build Release firmada con SDK iOS 26.2, validada y subida a TestFlight interno:
https://github.com/Krazel/tilt-arena-ios/actions/runs/34043750047
No publicada en App Store. Bundle com.dmkr.tiltarena.

Verificación en Mac: Xcode 26.3 y XcodeGen, bash scripts/verify-ios.sh.
TestFlight: workflow manual, solo propietario/main, secretos cifrados en el
entorno app-store-production. Identidad de candidata en store/testflight.json.
La validación nativa debe aprobarse antes de lanzar una distribución.
El workflow Local-QA continúa disponible para generar IPA sin firma.
