# Tilt Arena — estado de producto

Actualizado 2026-09-09. Krazel Games. Registro PR-031.
Responsable: tarea de producto 01a071f1-2875-7bc1-a4bd-9d9e38c35718.

## Candidata en verificación: 0.3.8 (1)

Recogidas uniformes de 10 puntos y récord nuevo, conservando el anterior.
Bumerán carga 0,5 s con animación en la punta, movimiento libre y rumbo al soltar.
Velocidad normal 600 (+27,7 %), frenado neutral 24. Fuego/vórtice 5 % cada uno;
bomba/onda/hielo 19 %. Curva difícil y velocidad de enemigos conservadas.
54 pruebas Node y sintaxis de 15 Swift pasan. Pendiente QA nativa, capturas,
firma y entrega autorizada. Activa 0.3.7 hasta verificar la nueva por API.

## Entrega anterior: 0.3.7 (1)

Señuelo retirado. Pinchos un 12 % mayores visualmente, giro un 75 % más rápido,
aviso ámbar de 1,5 s con dientes pulsantes y arco de cuenta atrás. Nueva explosión
nativa: núcleo blanco, expansión de fuego, dos ondas y fragmentos. Diez poderes;
el peso retirado pasa a bomba/onda/hielo. Progresión y puntuación conservadas;
informe medido en design/BALANCE.md.

71 pruebas aprobadas: 48 Node, 14 XCTest y 9 XCUITest; sintaxis de 14 Swift correcta.
QA 34340648343, Xcode 26.3 (17C529), SDK iOS Simulator 26.2.
Capturas de pinchos activos/aviso y explosión en dos fases revisadas. Fuente pública
029c446b726b07c2f1f0dd01289b98e322dbbebb, canónico c4c7148.
Firma y subida run 34341910032; Apple build d68c882f-3f34-4f36-9cf2-fe7882611f07,
VALID e IN_BETA_TESTING. Grupo interno solo del titular y notas es-ES releídas por
API. IPA Release ARM64, SDK iOS 26.2; CRC, firma, perfil y motor/audio comprobados.
Archivo artifacts/TiltArena-0.3.7-build1-TestFlight.ipa. SHA-256: 62624ad27d70ce3218003c7bfed2c0c48ff2f90ef85634aa7baeb004e7afbb8b.
Evidencia native-v037.json, simulator-v037.json, ipa-v037-testflight-build1.json,
testflight-v037.json, balance-v037.json y capturas native-v037/.
Prueba física pendiente. App Store 1.0 PREPARE_FOR_SUBMISSION; sin beta externa ni anuncios.

## Entrega anterior: 0.3.6 (1)

Más fuerza de vórtice solo sobre el jugador (+66,7 %), electricidad inicial 220,
pinchos 4 %, protección 5 %. Nuevos bumerán de ida/vuelta y señuelo de 4 segundos,
con arte nativo sobre la base de orbes aprobada. DIRECTION.md y notas v036 detallan
reglas y probabilidades. 51 pruebas Node y sintaxis de 13 Swift pasan.
QA nativa completada: 51 Node, 13 XCTest y 8 XCUITest (72 pruebas), Xcode 26.3.
Capturas revisadas de bumerán, señuelo y electricidad. Motor/audio del binario
coinciden con el canónico 3be57c6; fuente pública 00d36bb87b04aed847dae46d55c87e824986e3bf.
QA run 34293410088. Firma y subida completadas: run 34294298929.
Apple confirma VALID e IN_BETA_TESTING: build 0ce84509-460b-4cd8-bca9-c4807a381594.
Grupo interno solo del titular, asignación y notas es-ES guardadas y releídas por
API oficial. IPA Release ARM64, SDK iOS 26.2, 4.759.715 bytes; firma, perfil, CRC,
plataforma y motor/audio idénticos a la fuente canónica comprobados. Archivo
artifacts/TiltArena-0.3.6-build1-TestFlight.ipa. SHA-256:
c07c330ff9be0821794d5f4b6cd064abb9bac65d630b99e4826db84c711beda0.
Evidencia native-v036.json, control-v036.json, ipa-v036-testflight-build1.json,
testflight-v036.json y capturas native-v036/. Prueba física pendiente.
App Store 1.0 sigue PREPARE_FOR_SUBMISSION; sin beta externa ni anuncios.

## Entrega anterior: 0.3.5 (1)

Alcance de atracción del protagonista 300 conservando vórtice de radio 140.
Pinchos hacen huir a puntos activos, giran sobre el escudo verde y parpadean
los últimos 1,25 s. Reparto: bomba/onda/hielo 20 % cada uno; misiles 16 %;
fuego/rayos/vórtice 7 % cada uno; protección 2 %; pinchos 1 %.
62 pruebas pasan: 43 Node, 12 XCTest, 7 XCUITest; sintaxis de 13 Swift correcta.
Capturas nativas de pinchos con escudo y aviso final revisadas. Motor/audio del
binario de simulador coinciden con el canónico. QA run 34231987284, Xcode 26.3.
Firma y subida completadas: run 34233289930. Fuente pública
66604059cfc1069574f5482aefd674c35eb7f04b, canónico c4715ae.
Apple confirma VALID e IN_BETA_TESTING; build 0cf5be7f-7c13-4d3a-8a6a-63648b3ea389.
Asignada al grupo interno solo con el titular; relación y notas es-ES releídas
por API. IPA Release ARM64, SDK iOS 26.2, 4.753.484 bytes, firma y contenido
verificados. SHA-256 ac99f3c95ba45a9275e04d1b71e0bcebcf4e1ed1c00ab4d9d3dd6dd255caf0d1.
Archivo artifacts/TiltArena-0.3.5-build1-TestFlight.ipa. Evidencia native-v035.json,
control-v035.json, ipa-v035-testflight-build1.json y testflight-v035.json.
Prueba física de sensor, lectura y rendimiento pendiente. Ficha App Store 1.0
en PREPARE_FOR_SUBMISSION; sin pruebas externas ni anuncios.

## Entrega anterior: 0.3.4 (1)

0.3.4 (1) firmada, VALID y activa en TestFlight interno solo para el titular.
Asignación y notas en español guardadas y releídas por API oficial. Fuego ahora
dirigible inmediatamente tras cargar, a velocidad completa durante el impulso.
Onda lila con carga de 0,5 s visible en la punta y disparo desde el rumbo actual.
Vórtice 30 % menor (radio 140), atracción del protagonista con coeficiente 180.
Pasan 56 pruebas: 39 Node, 11 XCTest y 6 XCUITest. Capturas nativas revisadas:
carga lila en punta, disparo, giro de fuego con estela y vórtice menor.
El usuario confirmó explícitamente autorización permanente para publicar código
en el repositorio público y entregar builds; guardada en AGENTS.md. Bloqueo resuelto.
Envío público completado, fuente f4148118d6cef9248d53ac290a89af0fbe9fe5e9.
QA: https://github.com/Krazel/tilt-arena-ios/actions/runs/34144917480.
Subida: https://github.com/Krazel/tilt-arena-ios/actions/runs/34145838577.
Código canónico bcfb322. Build Apple e324b2fe-36fc-416d-b2fb-19d247224dc4.
IPA Release ARM64, SDK iOS 26.2, 4.752.132 bytes. Firma, perfil, contenido y
correspondencia del motor/audio comprobados. Archivo:
artifacts/TiltArena-0.3.4-build1-TestFlight.ipa.
SHA-256: 48f7468fffc5bf4ad3083a84cadf8951d97e48127cbb2b1982c29fa0becc70d9.
Evidencia: verification/native-v034.json, control-v034.json,
ipa-v034-testflight-build1.json y testflight-v034.json.
App Store 1.0 sigue PREPARE_FOR_SUBMISSION. Sin pruebas externas; anuncios No.
Pendiente probar control, posturas, giros con fuego, ondas consecutivas y
atracción del vórtice durante 10 minutos en iPhone físico.

## Historial de entrega anterior: 0.3.3 (1)

Selección visual entregada en TestFlight: Onda A Crecientes, Fuego A Llamarada y
Agujero negro A Espiral, de las láminas de ChatGPT Images conservadas en
design/vfx-proposals/2026-09-07/GALERIA.md. Hielo nativo existente conservado.
Fuego carga 0,5 s inmóvil y orientable, con aro de progreso, guía y chispas entrantes;
después impulsa 0,45 s a 1050 unidades/s dejando fuego durante 3,2 s. Conserva
protección durante carga/impulso; después devuelve el control normal.
Detalles y referencias: design/APPROVALS.md. Resto de variantes sin seleccionar.

0.3.3 (1) firmada y activa en TestFlight interno para la cuenta del titular.
Apple confirma VALID e IN_BETA_TESTING. Grupo con solo el titular, asignación
y notas en español verificadas por API. Enemigos por encima
de los orbes (z=3,5 frente a 3); protagonista en 4. El agujero negro atrae suavemente
al protagonista dentro de su radio, con caída en borde y centro, conservando el
control. Campos superpuestos promedian su atracción. Desplazamiento incluido en
recogidas y colisiones, respetando pausa, caducidad y límites de arena.
50 pruebas aprobadas: 35 Node, 10 XCTest y 5 XCUITest. Canónico b629799;
fuente pública compilada d09515338c6051b4b43f0c676bf5f6c85a94168a. Xcode 26.3.
Capturas nativas de carga/estela, crecientes, espiral y solapamiento revisadas.
Motor y audio del binario coinciden con el código canónico. Evidencia:
verification/native-v033.json, verification/simulator-v033.json y native-v033/.
El usuario autorizó expresamente el envío público y la compilación; bloqueo resuelto.
QA: https://github.com/Krazel/tilt-arena-ios/actions/runs/34137296208.
Subida: https://github.com/Krazel/tilt-arena-ios/actions/runs/34138863698.
Build ID ac24434e-81b1-452d-ba88-87bc8503400c. IPA Release ARM64, SDK iOS 26.2,
4.747.507 bytes. Firma, perfil, contenido y correspondencia del motor verificados.
Archivo: artifacts/TiltArena-0.3.3-build1-TestFlight.ipa.
SHA-256: 23448724e68daa311016c6006723dfbff75974709fa5b6cfb1509470c0b990d2.
Evidencia: verification/ipa-v033-testflight-build1.json y testflight-v033.json.
App Store 1.0 sigue PREPARE_FOR_SUBMISSION. Sin pruebas externas; anuncios No.

Próxima prueba: instalar 0.3.3 desde TestFlight, orientar durante la carga, probar
impulso y estela, pausa durante carga, paredes, poderes encadenados, atracción del
vórtice y visibilidad de enemigos; comprobar sensor y rendimiento en iPhone físico.

Autorización permanente del usuario (07/09): siguientes subidas a TestFlight
interno autorizadas, incluidas firma y CI. Guardada en AGENTS.md; completar las
entregas tras verificarlas sin pedir de nuevo permiso de subida.

## Historial de entrega anterior: 0.3.2 (1)

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
los bloqueos anteriores quedaron resueltos por autorización expresa. Envío público
y QA nativa de 0.3.3 completados, así como firma, subida y activación en TestFlight.
Autorización permanente de próximas subidas guardada en AGENTS.md. App Store Connect por API.

PR-031 sincronizada y verificada por GET, revisión 30, 2026-09-09T10:49:29.200Z.
La ficha registra 0.3.7 (1) activa en TestFlight interno, cambios visuales, retirada
del señuelo, 71 pruebas, capturas e IPA verificadas y balance pendiente de ensayo físico.
Autorizaciones permanentes en AGENTS.md.
Notas, releases y valores de tracking conservados. TestFlight Interno, ficha
Creada en App Store Connect, anuncios No. Evidencia verification/library-sync.json.
Historial: verification/ESTADO-v031.md y verification/VERIFICACION-v031.md.
