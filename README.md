# Tilt Arena · Krazel Games

Juego iOS inspirado en la sensación de Tilt to Live Classic, con código, arte y
sonido propios. Nombre provisional; biblioteca PR-031.

- Entrega actual: 0.3.5 (1), activa en TestFlight interno.
- Enemigos sobre orbes; vórtice pequeño con atracción al protagonista desde radio 300.
- Pinchos giratorios visibles sobre el escudo, aviso final y enemigos que huyen.
- Poderes ponderados: bomba/onda/hielo 20 % cada uno, misiles 16 %,
  fuego/rayos/vórtice 7 % cada uno, protección 2 % y pinchos 1 %.
- Onda de tres crecientes, fuego luminoso y agujero negro en espiral.
- Fuego con carga de 0,5 s, dirección libre a plena velocidad y estela persistente.
- Onda lila con carga de 0,5 s animada en la punta antes del disparo.
- Objetos mayores, última magia repuesta inmediatamente y VFX mejorados.
- Calibrar inicial, Normal e Inclinado plano; sensibilidad fija sin selector.
- Velocidad máxima +6,8 % y hitbox del protagonista ligeramente menor.
- 43 Node, 12 XCTest y 7 XCUITest aprobados; capturas nativas e IPA verificadas.
- Ensayo físico pendiente. Sin publicación en App Store.

native-ios/: SwiftUI, SpriteKit, CoreMotion y motor JavaScriptCore único.
npm test prueba el motor; npm run check:swift-syntax comprueba sintaxis sin SDK;
bash scripts/verify-ios.sh compila y prueba en Mac. qa/ es un laboratorio de reglas,
no una validación de iPhone. Web y assets anteriores preservados como historial.

Repositorio: https://github.com/Krazel/tilt-arena-ios .
QA: https://github.com/Krazel/tilt-arena-ios/actions/runs/34231987284
Subida: https://github.com/Krazel/tilt-arena-ios/actions/runs/34233289930
Fuente compilada: 66604059cfc1069574f5482aefd674c35eb7f04b.
No contiene claves ni historial privado de Studio. Ruta local sin traslado.
