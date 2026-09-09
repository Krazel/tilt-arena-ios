# Tilt Arena · Krazel Games

Juego iOS inspirado en la sensación de Tilt to Live Classic, con código, arte y
sonido propios. Nombre provisional; biblioteca PR-031.

- Entrega actual: 0.3.7 (1), activa en TestFlight interno.
- Señuelo retirado; se conserva el bumerán de ida/vuelta.
- Pinchos un 12 % mayores visualmente y giro un 75 % más rápido; aviso ámbar
  de 1,5 s con arco de cuenta atrás, visible sobre el escudo verde.
- Nueva explosión: núcleo blanco, expansión de fuego, doble onda y fragmentos.
- Enemigos sobre orbes; vórtice pequeño con atracción al protagonista desde radio 300.
- Electricidad con primer salto de radio 220 y cadenas de 90.
- Poderes: bomba/onda 18 % cada uno, hielo 17 %, misiles 12 %, fuego/rayos/vórtice
  7 % cada uno, protección/bumerán 5 % cada uno y pinchos 4 %.
- Onda lila y fuego con carga de 0,5 s; fuego con dirección libre a plena velocidad.
- Última magia repuesta inmediatamente. Calibrar inicial, Normal e Inclinado plano.
- Curva por tiempo conservada; balance y puntuación pendientes de ajuste con partidas.
- 48 Node, 14 XCTest y 9 XCUITest aprobados; capturas nativas e IPA verificadas.
- Ensayo físico pendiente. Sin publicación en App Store.

native-ios/: SwiftUI, SpriteKit, CoreMotion y motor JavaScriptCore único.
npm test prueba el motor; npm run check:swift-syntax comprueba sintaxis sin SDK;
bash scripts/verify-ios.sh compila y prueba en Mac. qa/ es un laboratorio de reglas,
no una validación de iPhone. Web y assets anteriores preservados como historial.

Repositorio: https://github.com/Krazel/tilt-arena-ios .
QA: https://github.com/Krazel/tilt-arena-ios/actions/runs/34340648343
Subida: https://github.com/Krazel/tilt-arena-ios/actions/runs/34341910032
Fuente compilada: 029c446b726b07c2f1f0dd01289b98e322dbbebb.
No contiene claves ni historial privado de Studio. Ruta local sin traslado.
