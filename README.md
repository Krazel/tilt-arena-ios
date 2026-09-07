# Tilt Arena · Krazel Games

Juego iOS inspirado en la sensación de Tilt to Live Classic, con código, arte y
sonido propios. Nombre provisional; biblioteca PR-031.

- Entrega actual: 0.3.4 (1), activa en TestFlight interno.
- Enemigos sobre orbes; vórtice 30 % menor y atracción más fuerte al protagonista.
- Onda de tres crecientes, fuego luminoso y agujero negro en espiral.
- Fuego con carga de 0,5 s, dirección libre a plena velocidad y estela persistente.
- Onda lila con carga de 0,5 s animada en la punta antes del disparo.
- Objetos mayores, última magia repuesta inmediatamente y VFX mejorados.
- Calibrar inicial, Normal e Inclinado plano; sensibilidad fija sin selector.
- Velocidad máxima +6,8 % y hitbox del protagonista ligeramente menor.
- 39 Node, 11 XCTest y 6 XCUITest aprobados; capturas nativas e IPA verificadas.
- Ensayo físico pendiente. Sin publicación en App Store.

native-ios/: SwiftUI, SpriteKit, CoreMotion y motor JavaScriptCore único.
npm test prueba el motor; npm run check:swift-syntax comprueba sintaxis sin SDK;
bash scripts/verify-ios.sh compila y prueba en Mac. qa/ es un laboratorio de reglas,
no una validación de iPhone. Web y assets anteriores preservados como historial.

Repositorio: https://github.com/Krazel/tilt-arena-ios .
QA: https://github.com/Krazel/tilt-arena-ios/actions/runs/34144917480
Subida: https://github.com/Krazel/tilt-arena-ios/actions/runs/34145838577
Fuente compilada: f4148118d6cef9248d53ac290a89af0fbe9fe5e9.
No contiene claves ni historial privado de Studio. Ruta local sin traslado.
