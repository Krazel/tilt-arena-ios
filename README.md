# Tilt Arena · Krazel Games

Juego iOS inspirado en la sensación de Tilt to Live Classic, con código, arte y
sonido propios. Nombre provisional; biblioteca PR-031.

- Entrega actual: 0.3.8 (1), activa en TestFlight interno.
- Puntuación: 10 por recogida, 10 por baja y bonus de combo 6 × bajas².
  Nuevo récord de estas reglas; el récord anterior se conserva aparte.
- Velocidad máxima normal 600 (+28 %), frenado rápido; impulso de fuego 1050.
- Bumerán: carga visual de 0,5 s en la punta, movimiento libre y rumbo al salir.
  Atraviesa en ida/vuelta; máximo tres entre cargas y vuelos.
- Poderes: bomba/onda/hielo 19 % cada uno, misiles 12 %, rayos 7 %, fuego/gravedad/
  protección/bumerán 5 % cada uno y pinchos 4 %. Señuelo retirado.
- Pinchos mayores, giro rápido y aviso ámbar de 1,5 s con cuenta atrás sobre escudo.
- Explosión con núcleo blanco, expansión, doble onda y fragmentos.
- Enemigos sobre orbes; vórtice pequeño con atracción al protagonista desde radio 300.
- Electricidad con primer salto de radio 220 y cadenas de 90.
- Onda lila y fuego con carga de 0,5 s; fuego con dirección libre a plena velocidad.
- Última magia repuesta inmediatamente. Calibrar inicial, Normal e Inclinado plano.
- Curva difícil por tiempo conservada; sensación pendiente de partidas físicas.
- 54 Node, 16 XCTest y 9 XCUITest aprobados; capturas nativas e IPA verificadas.
- Ensayo físico pendiente. Sin publicación en App Store.

native-ios/: SwiftUI, SpriteKit, CoreMotion y motor JavaScriptCore único.
npm test prueba el motor; npm run check:swift-syntax comprueba sintaxis sin SDK;
bash scripts/verify-ios.sh compila y prueba en Mac. qa/ es un laboratorio de reglas,
no una validación de iPhone. Web y assets anteriores preservados como historial.

Repositorio: https://github.com/Krazel/tilt-arena-ios .
QA: https://github.com/Krazel/tilt-arena-ios/actions/runs/34343923896
Subida: https://github.com/Krazel/tilt-arena-ios/actions/runs/34344923067
Fuente compilada: ad8f3aa75c6c874583e165e80543d51d3dc9a724.
No contiene claves ni historial privado de Studio. Ruta local sin traslado.
