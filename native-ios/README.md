# Candidata iOS 0.2.0 · build configurada 1

SpriteKit dibuja; CoreMotion obtiene inclinación; SwiftUI presenta los menús.
JavaScriptCore ejecuta `Resources/classic-core.js`, exactamente el motor de las
pruebas Node. Funciona sin red, cuentas, WebView, anuncios ni compras.

En Mac: instalar Xcode y XcodeGen, ejecutar `bash ../scripts/verify-ios.sh` desde
esta carpeta. Genera el proyecto, compila para simulador y ejecuta XCTest.
Alternativamente `xcodegen generate` y abrir `TiltArena.xcodeproj`.
Para un iPhone se necesita seleccionar el equipo de firma propio en Xcode.
Bundle ID heredado: `com.dmkr.tiltarena`; no se ha registrado uno nuevo.

En iPhone se calibra una postura estable antes de jugar. En simulador se habilita
arrastre porque no hay un sensor físico. El cambio de orientación, la pérdida de
datos del sensor y la salida de la app pausan la partida. Al volver se recalibra.

Las nueve armas están abiertas para comparar; desbloqueos y modos secundarios
pendientes. Valores de radios, velocidades, tiempo de combo y mezcla de sonido
son provisionales y están declarados en `../research/REFERENCE.md`.

**Estado:** no compilado con Xcode, no ejecutado en simulador ni iPhone.
La validación local del motor y la sintaxis no es validación de la aplicación.
