# Tilt Arena — estado de producto

Actualizado 2026-09-05. Krazel Games. Registro: PR-031.
Responsable: tarea de producto `01a071f1-2875-7bc1-a4bd-9d9e38c35718`.
El nombre comercial definitivo sigue pendiente.

## Encargo vigente

«Quiero que crees un proyecto de rehacer Tilt to Live, un juego móvil que había
antes, quiero que se parezca lo más posible». Esta tarea investiga y desarrolla;
el cerebro central organiza. Objetivo inicial: Classic con inclinación en iOS.

## Entrega local

Candidata **0.2.0, build 2**, compilada para simulador con Xcode 16.4. No hay versión
pública en tienda ni binario de iPhone. SpriteKit/CoreMotion, menú nativo, nueve armas,
perseguidores y tres formaciones, puntuación por bajas y combos. Recursos propios.
Motor compartido probado con Node; laboratorio local jugable para diagnóstico.
**No se presenta el laboratorio como la app de iPhone.**

Investigación: `research/REFERENCE.md`. Evidencia y límites: `VERIFICACION.md`.
23 pruebas Node y 3 XCTest pasan en macOS. Binario descargado, metadatos y recursos
comprobados; captura del menú nativo inspeccionada. Sin Xcode local.
Fuentes, suposiciones y objetivos medibles de fidelidad están separados.

## Conservación y rutas

Ruta efectiva: `C:\Users\dmkra\Documents\Codex Apps\TiltArena`.
Migración a Krazel Studio/Juegos pendiente; no se movió ni duplicó la carpeta.
Git independiente inicializado: la base heredada completa queda en `2c505de`.
Web heredada y assets conservados. No se modificaron otros productos.
Bundle ID heredado `com.dmkr.tiltarena`; iPhone, iOS mínimo 16, español.

## Compilación y siguiente resultado

Autorización expresa recibida y ejecutada: repositorio público
https://github.com/Krazel/tilt-arena-ios . Solo contiene el paquete preparado y sus
correcciones; no incluye el historial local, las referencias ni las notas de Studio.
CI correcta: https://github.com/Krazel/tilt-arena-ios/actions/runs/33977023251 .
Commit compilado público `bf55e83612df722d54f79bde78758cf0a6388b71`, equivalente de
implementación local `26a892491dc1ace9f7d3b12c7b3162a55f4c10e5`.
Artefacto en `artifacts/build2/`; manifiesto `verification/simulator-artifact.json`.
La build 1 pasó Xcode y XCTest pero falló al preparar la captura; build 2 corrige
ese paso de CI sin cambiar el juego. Se mantiene la versión 0.2.0.

Siguiente resultado: validar inclinación, latencia, dificultad y mezcla en iPhone.
La firma y entrega a dispositivo se prepararán al acordar esa distribución.
No se ha generado IPA ni subido nada a TestFlight o App Store.

Después: contrastar tiempos de combo, densidad y formaciones (Pong pendiente),
desbloqueos, VFX y mezcla de sonido. Los otros modos no forman parte de este corte.

## Biblioteca

Sincronización comprobada en D1 y en la interfaz: **PR-031, revisión 5**, guardada
el 05/09/2026 a las 16:20:20 UTC. En producción, candidata de simulador 0.2.0 build 2,
repositorio, pruebas, evidencia y siguiente paso actualizados. Se conservaron el
nombre «Tilt Arena — Tilt to Live» y las notas previas. Evidencia independiente:
`verification/library-sync.json`. No se editaron la semilla ni el Excel.
