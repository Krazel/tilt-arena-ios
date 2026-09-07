# Tilt Arena · Krazel Games

Juego iOS inspirado en la sensación de Tilt to Live Classic, con código, arte y
sonido propios. Nombre provisional; biblioteca PR-031.

- Entrega actual: 0.3.2 (1), activa en TestFlight interno.
- Objetos mayores, última magia repuesta inmediatamente y VFX mejorados.
- Calibrar inicial, Normal e Inclinado plano; sensibilidad fija sin selector.
- Velocidad máxima +6,8 % y hitbox del protagonista ligeramente menor.
- 28 Node, 9 XCTest y 4 XCUITest aprobados; capturas nativas revisadas.
- Ensayo físico pendiente. Sin publicación en App Store.

native-ios/: SwiftUI, SpriteKit, CoreMotion y motor JavaScriptCore único.
npm test prueba el motor; npm run check:swift-syntax comprueba sintaxis sin SDK;
bash scripts/verify-ios.sh compila y prueba en Mac. qa/ es un laboratorio de reglas,
no una validación de iPhone. Web y assets anteriores preservados como historial.

Repositorio: https://github.com/Krazel/tilt-arena-ios .
QA: https://github.com/Krazel/tilt-arena-ios/actions/runs/34105589370
Subida: https://github.com/Krazel/tilt-arena-ios/actions/runs/34106646635
Fuente compilada: 5a832ec1906091583383c09c629ae79351717b70.
No contiene claves ni historial privado de Studio. Ruta local sin traslado.
