# Tilt Arena · Krazel Games

Nombre provisional. Primera candidata iOS del encargo de reconstruir la sensación
de Tilt to Live original. Registro central: PR-031.

- [Estado real](ESTADO.md), [investigación](research/REFERENCE.md),
  [dirección visual](design/DIRECTION.md), [verificación](VERIFICACION.md).
- `native-ios/`: candidata 0.2.0, build 2, iPhone iOS 16+; compilada para simulador.
- `qa/`: laboratorio del motor de producción. `npm run qa`, abrir
  http://127.0.0.1:4293. Flechas/WASD o arrastre; espacio pausa; R repite.
- `npm test`: reglas del motor y contrato de recursos. `npm run check:swift-syntax`:
  sintaxis Swift, sin resolver SDKs. `bash scripts/verify-ios.sh`: build y XCTest
  en Mac con Xcode y XcodeGen. CI verificada: 23 pruebas Node y 3 XCTest aprobadas.
- `app.js`, `index.html`, `assets/`: prototipo web heredado. Conservado sin cambios
  funcionales. No representa esta candidata ni valida iPhone.

Captura nativa de simulador: `verification/native-menu-build2.png`. Paquete y
metadatos verificados: `verification/simulator-artifact.json`. No hay IPA.
Repositorio público autorizado: https://github.com/Krazel/tilt-arena-ios .
La carpeta sigue en Codex Apps; no se ha ejecutado la migración.
