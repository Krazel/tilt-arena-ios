# Tilt Arena — estado de producto

Actualizado 2026-09-07. Krazel Games. Registro PR-031.
Responsable: tarea de producto 01a071f1-2875-7bc1-a4bd-9d9e38c35718.

## Entrega actual

Propuestas visuales en revisión: 27 variantes de VFX (A/B/C para nueve poderes),
generadas con ChatGPT Images y guardadas en design/vfx-proposals/2026-09-07/GALERIA.md.
Son conceptos estáticos, no assets integrados ni animaciones verificadas. El usuario
valora el hielo existente de 0.3.2; se conserva como referencia. Próximo paso visual:
recibir su selección por poder antes de implementar estos nuevos diseños.

Candidata local siguiente: 0.3.3 (1), aún sin compilar ni subir. Enemigos por encima
de los orbes (z=3,5 frente a 3); protagonista en 4. El agujero negro atrae suavemente
al protagonista dentro de su radio, con caída en borde y centro, conservando el
control. Campos superpuestos promedian su atracción. Desplazamiento incluido en
recogidas y colisiones, respetando pausa, caducidad y límites de arena.
31 pruebas Node y sintaxis Swift aprobadas. Pendiente QA nativa de esta candidata.
La entrega comprobada en TestFlight continúa siendo 0.3.2 (1), descrita debajo.

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

PR-031 sincronizada y verificada por GET, revisión 17, 2026-09-07 13:38:08 UTC.
La ficha separa la candidata local 0.3.3 de la entrega activa 0.3.2 y registra
las 27 propuestas visuales pendientes de elección, aún sin implementar.
Notas, releases y valores de tracking conservados. TestFlight Interno, ficha
Creada en App Store Connect, anuncios No. Evidencia verification/library-sync.json.
Historial: verification/ESTADO-v031.md y verification/VERIFICACION-v031.md.
