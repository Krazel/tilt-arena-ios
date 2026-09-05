# Tilt Arena · Krazel Games

Nombre provisional. Primera candidata iOS del encargo de reconstruir la sensación
de Tilt to Live original. Registro central: PR-031.

- [Estado real](ESTADO.md), [investigación](research/REFERENCE.md),
  [dirección visual](design/DIRECTION.md), [verificación](VERIFICACION.md).
- `native-ios/`: candidata 0.3, build 2, iPhone iOS 16+; IPA Local-QA creada.
- `qa/`: laboratorio del motor de producción. `npm run qa`, abrir
  http://127.0.0.1:4293. Flechas/WASD o arrastre; espacio pausa; R repite.
- `npm test`: reglas del motor y contrato de recursos. `npm run check:swift-syntax`:
  sintaxis Swift, sin resolver SDKs. `bash scripts/verify-ios.sh`: build y XCTest
  en Mac con Xcode y XcodeGen. CI verificada: 25 Node, 7 XCTest y 2 XCUITest aprobadas.
- `app.js`, `index.html`, `assets/`: prototipo web heredado. Conservado sin cambios
  funcionales. No representa esta candidata ni valida iPhone.

Captura nativa de simulador: `verification/native-menu-build2.png`. Paquete y
metadatos de simulador: `verification/simulator-artifact.json`.
IPA para firmar con Sideloadly: `artifacts/TiltArena-0.3-build2-Local-QA-cbb96fa.ipa`.
Verificación de iPhoneOS ARM64 y recursos: `verification/ipa-v03-build2.json`.
Repositorio público autorizado: https://github.com/Krazel/tilt-arena-ios .
La carpeta sigue en Codex Apps; no se ha ejecutado la migración.
