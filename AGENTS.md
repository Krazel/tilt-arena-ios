# Tilt Arena — Krazel Games

Propietario: esta tarea de producto, `01a071f1-2875-7bc1-a4bd-9d9e38c35718`.
Biblioteca: conservar PR-031; Tilt Arena es un nombre provisional.
Encargo vigente: reconstruir la sensación y funcionamiento del Tilt to Live
original, empezando por Classic en iPhone, con código, arte y sonido propios.
Esta tarea sí desarrolla; el límite del cerebro central no se aplica aquí.

Leer ESTADO.md, research/REFERENCE.md y design/DIRECTION.md antes de modificar.
No confundir el prototipo web heredado con la candidata iOS. La interfaz y el
sensor son nativos (SpriteKit/CoreMotion). La simulación de producción se carga
en JavaScriptCore y se prueba directamente con Node, sin WebView ni red.
Mantener el motor en native-ios/Resources/classic-core.js como fuente única.
No duplicarlo en la web heredada. No anunciar builds ni pruebas físicas sin evidencia.

Ruta actual: TiltArena dentro de Codex Apps. No mover durante la migración pendiente.
La base heredada está preservada en el commit 2c505de. No borrar sus assets.
