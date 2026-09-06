# Tilt Arena · Krazel Games

Juego iOS inspirado en la sensación de Tilt to Live Classic, con código, arte y
sonido propios. Nombre provisional; biblioteca PR-031.

- [Estado actual](ESTADO.md), [investigación](research/REFERENCE.md),
  [dirección visual](design/DIRECTION.md), [verificación](VERIFICACION.md).
- Candidata local 0.3.2 (1); última entrega activa: TestFlight interno 0.3.1 (1).
- native-ios/: SwiftUI, SpriteKit, CoreMotion y motor JavaScriptCore único.
- npm test: pruebas del motor de producción. npm run check:swift-syntax:
  análisis sintáctico sin SDK. bash scripts/verify-ios.sh: compilación y pruebas
  nativas con Xcode en Mac; no sustituibles por la demo web.
- qa/: laboratorio del motor (npm run qa). Web y assets anteriores preservados
  como historial; no representan ni validan la candidata iPhone.

Repositorio público registrado como autorizado: https://github.com/Krazel/tilt-arena-ios .
La subida de los nuevos cambios está pendiente de la confirmación específica
exigida por auto-review; ver ESTADO.md. No contiene claves ni historial privado.
La carpeta sigue en Codex Apps; no se ha ejecutado la migración.
