# Tilt Arena PR-031 — auditoría para marketing y PC/Steam

12 de septiembre de 2026. Responsable de producto: 01a071f1-2875-7bc1-a4bd-9d9e38c35718.
Revisión de código, artefactos y API; no implementación ni compilación de un port.

**Actualización de entrega, 19:06 UTC:** 0.3.9 (1) ya está VALID e
IN_BETA_TESTING, solo titular. Evidencia testflight-v039.json, build Apple
88f7f95e-aeaa-40ab-bae8-456a4d829471. Frenado anterior y bumerán con rebotes/recaptura
entregados; 85 pruebas aprobadas y 20 capturas Debug en native-v039/. Estas siguen
siendo pruebas de iOS simulado, no de PC. D1 revisión 38 conserva marketing.
El inventario y los datos de 0.3.8 que siguen se conservan como base de esta auditoría.

## Versión comprobada y distribución

La entrega verificada al iniciar esta auditoría es **0.3.8 (1)**. Apple confirma
VALID e IN_BETA_TESTING, grupo interno con solo el titular y sin enlace público.
Beta externa: no activa (READY_FOR_BETA_SUBMISSION). Ficha App Store 1.0 creada
en PREPARE_FOR_SUBMISSION; no publicación visible. Sin SDK de anuncios integrado
ni anuncios activos; seguimiento de biblioteca: No. Planificación de campañas
publicitarias fuera del producto: por confirmar con marketing.

Evidencia: testflight-v038.json, consulta oficial 2026-09-12T18:32:32.473Z.
[TestFlight](https://appstoreconnect.apple.com/apps/6809193185/testflight) ·
[Ficha ASC](https://appstoreconnect.apple.com/apps/6809193185/distribution).
QA 34343923896: 54 Node, 16 XCTest, 9 XCUITest, cero fallos; Xcode 26.3.
Fuente pública ad8f3aa75c6c874583e165e80543d51d3dc9a724. Ensayo físico pendiente.

IPA real: `C:/Users/dmkra/Documents/Codex Apps/TiltArena/artifacts/TiltArena-0.3.8-build1-TestFlight.ipa`.
4.768.130 bytes; SHA256 3c0ed4b701759869a00f95b2d1ee3893677f64d1f44958a06f24a20d4512bd4f.
Ejecutable dentro de la IPA: `Payload/TiltArena.app/TiltArena`, ARM64 iOS.
**No se ha encontrado ejecutable Windows, instalador ni build Steam** en el producto.

La candidata 0.3.9 añade frenado anterior y bumerán con rebotes/recaptura. Está en
QA iOS por encargo previo confirmado del usuario; no presentarla como distribuida
hasta consultar su evidencia de entrega. El bumerán de 0.3.8 carga 0,5 s y regresa
automáticamente; no confundir ambas reglas.

## Funciones e idiomas reales

iPhone iOS 16+, horizontal en ambas orientaciones, **interfaz solo en español**.
Classic individual de supervivencia: esquiva, combos y récord local. Diez poderes:
bomba, onda, misiles, hielo, protección, pinchos, vórtice, electricidad, fuego
propulsor y bumerán. Calibrar inicial, Normal a 45° e Inclinado plano; postura
personalizada guardada y reanudación. Sin selector de sensibilidad ni fácil/difícil.
Mayor presión de enemigos por tiempo, con límites; no dificultad adaptativa por
puntos. Offline, sin cuentas, multijugador, compras ni integración de Steam.

## PC: soporte actual, propuesta y pendientes

Producción: SwiftUI/SpriteKit, CoreMotion, JavaScriptCore y AVFoundation. El
motor JavaScript y sus pruebas son reutilizables; interfaz, render, entrada,
audio y almacenamiento necesitan adaptación para Windows. Ninguna tecnología de
port ha sido seleccionada ni implementada en esta auditoría.

`qa/index.html` admite WASD/flechas, arrastre relativo, Espacio para pausa y R para
reinicio. `npm run qa` sirve el motor en localhost:4293 con un renderer diagnóstico.
Es soporte leído en código, no un ejecutable nativo ni una demo equivalente a iOS;
incluso conserva el texto antiguo «9 armas». La web heredada tampoco acredita paridad.
El arrastre de ClassicScene está condicionado al simulador. No hay soporte de
mando/teclado/Steam Input en la app de producción.

Propuesta pendiente de implementación: stick izquierdo como vector analógico,
WASD/flechas alternativos con diagonales normalizadas, Esc/Start para pausa y
navegación de menús con teclado/mando. Remapeo, zona muerta, giroscopio opcional y
ajuste de dificultad necesitan pruebas. No anunciar soporte completo de mando.

Pendientes: runtime y renderer, empaquetado/ejecutable, guardados, audio, controles,
instalación limpia, rendimiento, resoluciones/DPI, pantalla completa, mínimos de
CPU/GPU/RAM/OS, compatibilidad y licencias de dependencias. No hay pruebas nativas
Windows, macOS, Linux o Steam Deck ni requisitos mínimos medidos. Steam requiere
configurar el lanzamiento del ejecutable entregado y sus depots; referencia:
[SteamPipe](https://partner.steamgames.com/doc/sdk/uploading).

## Capturas, vídeo y procedencia

Carpeta absoluta: `C:/Users/dmkra/Documents/Codex Apps/TiltArena/verification/native-v038/`.
Contiene 19 PNG y `captures.json` con nombres, pruebas, dispositivo y hashes.
Proceden de XCUITest, iPhone 16 Pro **simulado**, QA 34343923896 del 09-09, renderer
nativo de 0.3.8. Son escenas Debug preparadas para verificar estados; no partidas
ordinarias continuas ni prueba de una versión PC. Ejemplos útiles:

- `01-menu-wide.png`: menú; `05-native-ice-and-blast.png`: hielo/explosión.
- `07-selected-vfx-fire-trail.png`: fuego; `11-spikes-over-shield.png`: pinchos.
- `16-explosion-hot-core.png`, `17-explosion-dissipation.png`: fases de explosión.
- `18-boomerang-charging.png`, `13-boomerang-outbound.png`, `14-boomerang-return.png`.

No se encontró vídeo propio verificable de 0.3.8 en el repositorio/artefactos
examinados. Los vídeos de Tilt to Live son referencias de terceros, no material
propio. Las láminas de propuestas VFX son conceptos, no capturas del juego.
Steam pide capturas de gameplay; preparar las definitivas desde la versión PC
real cuando exista: [recursos de tienda](https://partner.steamgames.com/doc/store/assets/standard).

Orbes y chispas: ChatGPT Images, prompts en design/imagegen-v03-prompts.json y
manifiesto verification/generated-art-v03.json. Enemigos son puntos dibujados por
SpriteKit; el PNG alternativo está excluido de la build. Resto de glifos/VFX:
geometría propia; cuatro WAV sintetizados por scripts/generate-audio.cjs, sin
audio de Tilt to Live. Revisión final de licencias y declaración de contenido IA
pendiente antes de publicar en Steam; no atribuir assets del original a este juego.
