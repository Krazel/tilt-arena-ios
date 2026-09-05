# Tilt Arena · Krazel Games

Nombre provisional. Primera candidata iOS del encargo de reconstruir la sensación
de Tilt to Live original. Registro central: PR-031.

- [Estado real](ESTADO.md), [investigación](research/REFERENCE.md),
  [dirección visual](design/DIRECTION.md), [verificación](VERIFICACION.md).
- `native-ios/`: candidata 0.2.0, build configurada 1, iPhone iOS 16+.
- `qa/`: laboratorio del motor de producción. `npm run qa`, abrir
  http://127.0.0.1:4293. Flechas/WASD o arrastre; espacio pausa; R repite.
- `npm test`: reglas del motor y contrato de recursos. `npm run check:swift-syntax`:
  sintaxis Swift, sin resolver SDKs. `bash scripts/verify-ios.sh`: build y XCTest
  en Mac con Xcode y XcodeGen. Preparado, no ejecutado aquí.
- `app.js`, `index.html`, `assets/`: prototipo web heredado. Conservado sin cambios
  funcionales. No representa esta candidata ni valida iPhone.

La primera captura local está en `design/candidate-lab.png`. No hay IPA ni build
de simulador generada. La carpeta sigue en Codex Apps; no se ha ejecutado la migración.
