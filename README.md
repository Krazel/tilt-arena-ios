# Tilt Arena · Krazel Games

Juego iOS inspirado en la sensación de Tilt to Live Classic, con código, arte y
sonido propios. Nombre provisional; biblioteca PR-031.

- Entrega actual: 0.3.3 (1), activa en TestFlight interno.
- Enemigos sobre orbes y atracción suave del vórtice al protagonista.
- Onda de tres crecientes, fuego luminoso y agujero negro en espiral.
- Fuego con carga orientable de 0,5 s, impulso y estela persistente.
- Objetos mayores, última magia repuesta inmediatamente y VFX mejorados.
- Calibrar inicial, Normal e Inclinado plano; sensibilidad fija sin selector.
- Velocidad máxima +6,8 % y hitbox del protagonista ligeramente menor.
- 35 Node, 10 XCTest y 5 XCUITest aprobados; capturas nativas e IPA verificadas.
- Ensayo físico pendiente. Sin publicación en App Store.

native-ios/: SwiftUI, SpriteKit, CoreMotion y motor JavaScriptCore único.
npm test prueba el motor; npm run check:swift-syntax comprueba sintaxis sin SDK;
bash scripts/verify-ios.sh compila y prueba en Mac. qa/ es un laboratorio de reglas,
no una validación de iPhone. Web y assets anteriores preservados como historial.

Repositorio: https://github.com/Krazel/tilt-arena-ios .
QA: https://github.com/Krazel/tilt-arena-ios/actions/runs/34137296208
Subida: https://github.com/Krazel/tilt-arena-ios/actions/runs/34138863698
Fuente compilada: d09515338c6051b4b43f0c676bf5f6c85a94168a.
No contiene claves ni historial privado de Studio. Ruta local sin traslado.
