# Tilt Arena — estado de producto

Actualizado 2026-09-05. Krazel Games. Registro PR-031.
Responsable: tarea de producto `01a071f1-2875-7bc1-a4bd-9d9e38c35718`.
Nombre comercial provisional. Referencia: Tilt to Live, Classic para iPhone.

## Entrega actual

Candidata **0.3, build 2**. IPA Local-QA iPhoneOS ARM64, iOS 16+, español.
El usuario probó la anterior 0.2.0 build 3 y comunicó bordes negros y la necesidad
de reanudar sin recalibrar. Confirmó las posturas Normal, Inclinado y Personalizado.

Implementado: arena adaptable al aspecto de pantalla, menú a dos columnas,
reanudar directamente, perfiles de inclinación y calibración personalizada guardada.
Tres texturas creadas con ChatGPT Images: orbe de cristal, punto rojo y destello.
VFX de explosión, hielo, rayos, estelas y partículas integrados en SpriteKit.
Prompts y procedencia: `design/imagegen-v03-prompts.json`.

25 pruebas Node, 7 XCTest y 2 XCUITest aprobadas. Build Release de dispositivo
correcta y descargada; CRC, hash, ARM64, plataforma iOS y recursos comprobados.
La captura nativa del menú llena la pantalla. La inclinación y rendimiento de
esta nueva candidata necesitan prueba física; la del usuario corresponde a 0.2.0.
Detalle y evidencias: `VERIFICACION.md`.

IPA: `artifacts/TiltArena-0.3-build2-Local-QA-cbb96fa.ipa`.
Sin firma ni perfil; se firma al instalar con Sideloadly. Sin envío a tiendas.
CI: https://github.com/Krazel/tilt-arena-ios/actions/runs/33983076969 .
Fuente pública compilada: `cbb96fa4890960284f2a0737a902b44390a04acf`.
Fuente canónica equivalente: `c0f3724`.

## Siguiente prueba

Instalar la nueva IPA y probar Normal, Inclinado y Personalizado, ambas
orientaciones, pausar/reanudar, salir y volver, y comprobar los VFX durante partida.
Medir control y fps en el dispositivo antes de declarar equivalencia con el original.
Después: ajustar combos, densidad, Pong, desbloqueos y sonido; otros modos pendientes.

## Conservación y biblioteca

Ruta efectiva: `C:\Users\dmkra\Documents\Codex Apps\TiltArena`.
Migración pendiente; no se movió la carpeta. Git independiente, base `2c505de`.
SpriteKit/CoreMotion/SwiftUI y JavaScriptCore; web heredada conservada.
El repositorio público contiene solo la fuente preparada, sin historial privado.
Estado anterior conservado en `verification/ESTADO-v02-build3.md`.

PR-031 actualizado a 0.3 build 2 y comprobado en D1: revisión 8,
05/09/2026 18:16:28 UTC. Notas y nombre conservados.
Evidencia: `verification/library-sync.json`.
