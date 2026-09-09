# Tilt Arena · Krazel Games

Juego iOS inspirado en la sensación de Tilt to Live Classic, con código, arte y
sonido propios. Nombre provisional; biblioteca PR-031.

- Entrega actual: 0.3.6 (1), activa en TestFlight interno.
- Nuevos poderes: bumerán de ida/vuelta y señuelo que distrae durante 4 segundos.
- Enemigos sobre orbes; vórtice pequeño con atracción al protagonista desde radio 300,
  un 67 % más fuerte. Electricidad con primer salto de radio 220 y cadenas de 90.
- Pinchos giratorios visibles sobre el escudo, aviso final y enemigos que huyen.
- Poderes ponderados: bomba/onda/hielo 16 % cada uno, misiles 12 %,
  fuego/rayos/vórtice 7 % cada uno, protección/bumerán/señuelo 5 % cada uno y pinchos 4 %.
- Onda de tres crecientes, fuego luminoso y agujero negro en espiral.
- Fuego con carga de 0,5 s, dirección libre a plena velocidad y estela persistente.
- Onda lila con carga de 0,5 s animada en la punta antes del disparo.
- Objetos mayores, última magia repuesta inmediatamente y VFX mejorados.
- Calibrar inicial, Normal e Inclinado plano; sensibilidad fija sin selector.
- Velocidad máxima +6,8 % y hitbox del protagonista ligeramente menor.
- 51 Node, 13 XCTest y 8 XCUITest aprobados; capturas nativas e IPA verificadas.
- Ensayo físico pendiente. Sin publicación en App Store.

native-ios/: SwiftUI, SpriteKit, CoreMotion y motor JavaScriptCore único.
npm test prueba el motor; npm run check:swift-syntax comprueba sintaxis sin SDK;
bash scripts/verify-ios.sh compila y prueba en Mac. qa/ es un laboratorio de reglas,
no una validación de iPhone. Web y assets anteriores preservados como historial.

Repositorio: https://github.com/Krazel/tilt-arena-ios .
QA: https://github.com/Krazel/tilt-arena-ios/actions/runs/34293410088
Subida: https://github.com/Krazel/tilt-arena-ios/actions/runs/34294298929
Fuente compilada: 00d36bb87b04aed847dae46d55c87e824986e3bf.
No contiene claves ni historial privado de Studio. Ruta local sin traslado.
