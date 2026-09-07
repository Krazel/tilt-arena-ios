# Candidata iOS 0.3.2 · build 1

SpriteKit dibuja; CoreMotion obtiene inclinación; SwiftUI presenta los menús.
JavaScriptCore ejecuta Resources/classic-core.js, el motor compartido con Node.
iPhone, iOS 16+, español. Sin red, cuentas, WebView, anuncios ni compras.

Arena adaptable, objetos mayores y reposición inmediata del último orbe. Posturas
Calibrar (inicial), Normal a 45° e Inclinado plano. Calibración guardada, Reanudar
directo y sensibilidad fija sin selector. Velocidad 470 y radio del protagonista 8.
Enemigos vectoriales rojos/cian; orbes y destellos conservan las dos texturas de
ChatGPT Images. VFX nativos de hielo facetado, explosiones, ondas, rayos y estelas.

41 pruebas aprobadas: 28 Node, 9 XCTest y 4 XCUITest con Xcode 26.3.
https://github.com/Krazel/tilt-arena-ios/actions/runs/34105589370
Fixtures de arte solo en Debug. Control físico y fps requieren ensayo en iPhone.

Release ARM64 firmada, SDK iOS 26.2, validada y activa en TestFlight interno:
https://github.com/Krazel/tilt-arena-ios/actions/runs/34106646635
No publicada en App Store. Bundle com.dmkr.tiltarena.
Fuente compilada: 5a832ec1906091583383c09c629ae79351717b70.

Verificación: Xcode 26.3 y XcodeGen, bash scripts/verify-ios.sh.
TestFlight: workflow manual autorizado, propietario/main, secretos cifrados en
app-store-production. Identidad de candidata en store/testflight.json. Validar
nativo antes de distribuir; verificar operaciones de App Store Connect por API.
