# Tilt Arena — estado de producto

Actualizado 2026-09-05. Krazel Games. Registro: PR-031.
Responsable: tarea de producto `01a071f1-2875-7bc1-a4bd-9d9e38c35718`.
El nombre comercial definitivo sigue pendiente.

## Encargo vigente

«Quiero que crees un proyecto de rehacer Tilt to Live, un juego móvil que había
antes, quiero que se parezca lo más posible». Esta tarea investiga y desarrolla;
el cerebro central organiza. Objetivo inicial: Classic con inclinación en iOS.

## Entrega local

Candidata de código **0.2.0**, build configurada **1**, sin compilar. No hay versión
pública ni binario de iPhone. SpriteKit/CoreMotion, menú nativo, nueve armas,
perseguidores y tres formaciones, puntuación por bajas y combos. Recursos propios.
Motor compartido probado con Node; laboratorio local jugable para diagnóstico.
**No se presenta el laboratorio como la app de iPhone.**

Investigación: `research/REFERENCE.md`. Evidencia y límites: `VERIFICACION.md`.
23 pruebas pasan y seis archivos Swift pasan análisis de sintaxis. Sin Xcode local.
Fuentes, suposiciones y objetivos medibles de fidelidad están separados.

## Conservación y rutas

Ruta efectiva: `C:\Users\dmkra\Documents\Codex Apps\TiltArena`.
Migración a Krazel Studio/Juegos pendiente; no se movió ni duplicó la carpeta.
Git independiente inicializado: la base heredada completa queda en `2c505de`.
Web heredada y assets conservados. No se modificaron otros productos.
Bundle ID heredado `com.dmkr.tiltarena`; iPhone, iOS mínimo 16, español.

## Bloqueo real y siguiente resultado

Obtener primera build de simulador, pasar XCTest en JavaScriptCore y después
calibrar en iPhone. Este Windows carece de Xcode y no se encontró repositorio
previo del juego. Se han preparado script de Mac, pruebas y workflow manual.
Crear un repositorio público expondría el código: queda por autorizar esa ruta
o disponer de un Mac. No se ha subido fuente, ejecutado CI, firmado ni publicado.

Después: contrastar tiempos de combo, densidad y formaciones (Pong pendiente),
desbloqueos, VFX y mezcla de sonido. Los otros modos no forman parte de este corte.

## Biblioteca

Sincronización comprobada en D1: **PR-031, revisión 4**, guardada el 05/09/2026
a las 15:24:40 UTC. Estado En producción y candidata local con límites reales.
Se conservó el nombre «Tilt Arena — Tilt to Live» y las notas de la revisión 3
del cerebro. El primer guardado antiguo fue rechazado por concurrencia y se
reaplicaron solo los avances sobre la ficha recargada. Evidencia independiente:
`verification/library-sync.json`. No se editaron la semilla ni el Excel.
