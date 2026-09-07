# Tilt Arena — estado de producto

Actualizado 2026-09-07. Krazel Games. Registro PR-031.
Responsable: tarea de producto 01a071f1-2875-7bc1-a4bd-9d9e38c35718.

## Entrega actual

0.3.2 (1) activa en TestFlight interno para la cuenta del titular. Apple confirma
VALID e IN_BETA_TESTING. Grupo Pruebas internas: solo el titular; la nueva build
se añade a la anterior. Notas en español guardadas y verificadas por API oficial.
Sin pruebas externas ni enlace público. Ficha App Store 1.0 en
PREPARE_FOR_SUBMISSION, sin publicación visible. Anuncios: No.

https://appstoreconnect.apple.com/apps/6809193185/testflight
https://appstoreconnect.apple.com/apps/6809193185/distribution
App ID 6809193185; bundle com.dmkr.tiltarena.
Build ID ceadfcad-99d6-4684-b820-2462d19b322a.

## Cambios entregados

Flecha, puntos vectoriales y orbes mayores. Reposición inmediata del último orbe
al recogerlo o caducar. Hielo facetado, explosiones con cuerpo, ondas, rayos y
estelas mejorados. Calibrar inicial; Normal a 45° e Inclinado plano, pantalla
hacia arriba como sobre una mesa. Se conservan calibraciones guardadas y las
nuevas elecciones de postura. Reanudar no obliga a volver a calibrar.

Selector de sensibilidad retirado; valor fijo 1. Velocidad máxima 470 (+6,8 %);
radio del protagonista contra puntos 8 en vez de 9 en la candidata anterior.
Contacto total 18; recogida de orbes conservada en 33. Enemigos vectoriales, con
congelados cian; PNG de enemigo histórico excluido. Orbes y partículas aprobados
conservados. Modos fácil/difícil y rediseño de progresión siguen aplazados.

## Evidencia y siguiente prueba

41 pruebas aprobadas: 28 Node, 9 XCTest, 4 XCUITest. Capturas de iPhone 16 Pro
revisadas; firma, subida y contenido final de la IPA verificados.
QA: https://github.com/Krazel/tilt-arena-ios/actions/runs/34105589370
Subida: https://github.com/Krazel/tilt-arena-ios/actions/runs/34106646635
Fuente pública compilada: 5a832ec1906091583383c09c629ae79351717b70.
Código canónico equivalente: 5f78fa1. Xcode 26.3, SDK iOS 26.2, ARM64 Release.
IPA: artifacts/TiltArena-0.3.2-build1-TestFlight.ipa (4.733.087 bytes).
SHA256: e742cc968358c601287ddf6ad5b91b7fbf7818efeddf435b78c3bff732acf5e7.

Pendiente instalar desde TestFlight y probar 10 minutos: velocidad, huecos entre
puntos, orbes, posturas, sensor en ambas orientaciones, pausa/reanudar, sonido,
VFX, fps y temperatura. Las fixtures de simulador no demuestran ensayo físico.
Detalles: VERIFICACION.md, verification/native-v032.json,
verification/ipa-v032-testflight-build1.json, verification/testflight-v032.json.

## Conservación y biblioteca

Ruta efectiva: C:\Users\dmkra\Documents\Codex Apps\TiltArena. Sin traslado.
Git independiente e historial preservado. Espejo público saneado; firma y claves
fuera del repo, en entorno protegido. Usuario autorizó compilar y subir el 07/09;
el bloqueo de aprobación anterior quedó resuelto. App Store Connect por API.

PR-031 sincronizada y verificada por GET, revisión 15, 2026-09-07 09:38:54 UTC.
Notas, releases y valores de tracking conservados. TestFlight Interno, ficha
Creada en App Store Connect, anuncios No. Evidencia verification/library-sync.json.
Historial: verification/ESTADO-v031.md y verification/VERIFICACION-v031.md.
