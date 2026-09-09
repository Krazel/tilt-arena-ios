# Verificación — 0.3.8 (1)

## Entrega actual: 0.3.8 (1)

Recogidas uniformes de 10 puntos; bajas 10 y bonus de combo 6 × bajas². Récord
nuevo con el anterior conservado. Bumerán con carga visual de 0,5 s en la punta,
movimiento libre y rumbo al terminar; máximo tres entre cargando y volando.
Velocidad normal 600 (+27,7 %), frenado neutral 24, impulso de fuego 1050. Fuego
y vórtice 5 % cada uno; bomba/onda/hielo 19 %. Curva difícil de enemigos conservada.

79 pruebas aprobadas: 54 Node, 16 XCTest y 9 XCUITest; sintaxis de 15 Swift correcta.
QA 34343923896, Xcode 26.3 (17C529), SDK iOS Simulator 26.2.
Capturas de carga, salida y regreso de bumerán revisadas. Fuente pública
ad8f3aa75c6c874583e165e80543d51d3dc9a724, canónico 74cb58e.
Firma y subida run 34344923067; Apple build ae14e9eb-f31b-4f14-8be7-a66e3fea3433,
VALID e IN_BETA_TESTING. Grupo interno solo del titular y notas es-ES releídas por
API. IPA Release ARM64, SDK iOS 26.2, 4768130 bytes; CRC, firma, perfil y
motor/audio comprobados. Archivo artifacts/TiltArena-0.3.8-build1-TestFlight.ipa.
SHA-256: 3c0ed4b701759869a00f95b2d1ee3893677f64d1f44958a06f24a20d4512bd4f.
Evidencia native-v038.json, simulator-v038.json, ipa-v038-testflight-build1.json,
testflight-v038.json, balance-v038.json y capturas native-v038/.
Prueba física pendiente. App Store 1.0 PREPARE_FOR_SUBMISSION; sin beta externa ni anuncios.

Pruebas nuevas: puntuación uniforme en diez poderes; liquidación única del combo;
carga exacta y rumbo/posición actuales; sin daño/protección durante carga; pausa,
muerte y límite conjunto de cargas/vuelos. Equivalencia 30/60/120 Hz, velocidad
600 en diagonal y ejes, parada rápida, impulso de fuego conservado. Director
y velocidades enemigas sin cambios; muestra de 20.000 apariciones.
XCTest comprueba carga nativa y Reducir movimiento, y conserva el récord anterior
al guardar/reabrir el nuevo. Las pruebas no acreditan sensación física ni balance
definitivo de dificultad.

QA: https://github.com/Krazel/tilt-arena-ios/actions/runs/34343923896
Subida: https://github.com/Krazel/tilt-arena-ios/actions/runs/34344923067

# Historial de verificación — 0.3.7 (1)

## Entrega actual: 0.3.7 (1)

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

La explosión tiene fases acotadas y desaparece a 0,7 s; Reducir movimiento elimina
fragmentos y expansión. Giro, pausa, color y arco de caducidad de pinchos comprobados.
Señuelo ausente del arsenal y rechazo de su identificador. Muestra de 20.000
apariciones y medición del director en balance-v037.json. Las pruebas validan
reglas y presentación; no demuestran equilibrio de dificultad ni sensación física.

QA: https://github.com/Krazel/tilt-arena-ios/actions/runs/34340648343
Subida: https://github.com/Krazel/tilt-arena-ios/actions/runs/34341910032

# Historial de verificación — 0.3.6 (1)

## Entrega TestFlight 0.3.6 verificada

Run https://github.com/Krazel/tilt-arena-ios/actions/runs/34294298929.
Fuente 00d36bb87b04aed847dae46d55c87e824986e3bf, idéntica a la QA nativa.
Archive, firma, exportación y subida correctos. IPA 4.759.715 bytes, Release ARM64,
SDK iOS 26.2, SHA-256 c07c330ff9be0821794d5f4b6cd064abb9bac65d630b99e4826db84c711beda0.
CRC, versión/build, bundle, plataforma, arquitectura y perfil comprobados;
motor/audio coinciden con canónico y simulador. Apple build
0ce84509-460b-4cd8-bca9-c4807a381594: VALID e IN_BETA_TESTING, asignada al grupo
interno solo del titular. Relación y notas es-ES releídas por API el 2026-09-09.
Caduca 2026-12-08 UTC. App Store 1.0 PREPARE_FOR_SUBMISSION, sin beta externa.
Evidencia testflight-v036.json e ipa-v036-testflight-build1.json. Prueba física pendiente.

## QA nativa 0.3.6 verificada

Run https://github.com/Krazel/tilt-arena-ios/actions/runs/34293410088.
Fuente pública 00d36bb87b04aed847dae46d55c87e824986e3bf, canónico 3be57c6.
Xcode 26.3 (17C529), SDK iOS Simulator 26.2: BUILD SUCCEEDED y TEST SUCCEEDED.
72 pruebas pasan: 51 Node, 13 XCTest, 8 XCUITest. Sintaxis de 13 Swift correcta.
El motor del binario es idéntico al probado; también coinciden los cuatro audios.

Regresiones: fuerza extra solo al jugador, arrastre de puntos/orbes sin cambios;
escape, radio y caducidad. Primer rayo alcanza 219 pero no 221; saltos posteriores
conservan huecos y apariciones inofensivas. Bumerán atraviesa a ida/vuelta y retorna
a la posición actual, vuelve antes en paredes, respeta pausa, límite de tres,
caducidad y equivalencia 30/60/120 Hz. Señuelo desvía cercanos/formaciones,
conserva congelados/apariciones, no protege ni mata ni mueve orbes, caduca y se
reemplaza. Pinchos prevalecen sobre la distracción.
Muestra de 20.000 apariciones: pinchos 4,045 %, protección 5,075 %; bumerán
5,24 %, señuelo 5,005 %. El resto dentro de un punto porcentual del objetivo.

Capturas nativas de iPhone 16 Pro, paisaje y español, revisadas: 13-boomerang-and-decoy,
14-boomerang-return, 15-electricity-range. Once glifos caben en la arena;
copia menta hueca distinta del jugador opaco, cuchillas doradas legibles y primer
rayo largo con aro de alcance. La estela en movimiento y tacto requieren ensayo
físico; las capturas son estados estáticos de la app nativa, no una prueba de fps.
Evidencia native-v036.json, native-v036/captures.json, simulator-v036.json,
control-v036.json. API oficial de Apple comprobada: candidata 0.3.6 (1) libre.
Guía de subida de Apple consultada el 2026-09-09:
https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/.

## Historial: entrega TestFlight 0.3.5 verificada

Run https://github.com/Krazel/tilt-arena-ios/actions/runs/34233289930.
Fuente 66604059cfc1069574f5482aefd674c35eb7f04b, la misma que pasó QA nativa.
Archive, firma, exportación, validación y subida sin errores. IPA Release ARM64,
SDK iPhoneOS 26.2, 4.753.484 bytes; SHA-256:
ac99f3c95ba45a9275e04d1b71e0bcebcf4e1ed1c00ab4d9d3dd6dd255caf0d1.
CRC, versión, bundle, plataforma, arquitectura, perfil y contenido comprobados;
motor y audio idénticos a la fuente canónica y al simulador probado.
Apple: build 0cf5be7f-7c13-4d3a-8a6a-63648b3ea389, VALID e IN_BETA_TESTING.
Asignada a Pruebas internas, solo el titular; relación y notas es-ES releídas
por API oficial el 2026-09-08. Caduca 2026-12-07. Sin beta externa; App Store
1.0 sigue PREPARE_FOR_SUBMISSION. Evidencia testflight-v035.json y
ipa-v035-testflight-build1.json. Ensayo con iPhone físico pendiente.

## QA nativa 0.3.5 verificada

Código canónico c4715ae; fuente pública 66604059cfc1069574f5482aefd674c35eb7f04b.
Run https://github.com/Krazel/tilt-arena-ios/actions/runs/34231987284.
Xcode 26.3 (17C529), SDK iOS Simulator 26.2: BUILD SUCCEEDED y TEST SUCCEEDED.
62 pruebas pasan: 43 Node, 12 XCTest y 7 XCUITest. Sintaxis de 13 Swift correcta.

Atracción del protagonista hasta 300 sin ampliar tamaño físico/visual del vórtice
140 ni arrastre de orbes/puntos. Deriva a 250 unidades comprobada; radio límite,
escape, superposición, pausa, centro, caducidad y bordes siguen verificados.
Pinchos: huida de activos/formaciones; congelados/apariciones respetados, regreso
al comportamiento habitual al acabar, contacto ofensivo sin consumir burbuja,
límites, pausa y equivalencia a 30/60/120 Hz.
20.000 apariciones reales: pinchos 1,01 %, protección 1,94 %, resto dentro de un
punto porcentual de sus objetivos. Subconjuntos se renormalizan; reposición del
último orbe sigue garantizada. Evidencia control-v035.json.

Capturas nativas 11-spikes-over-shield y 12-spikes-expiry-warning revisadas:
dientes rellenos fuera del escudo, borde oscuro, flecha legible y atenuación sin
ocultar el poder. XCTest verifica giro, aviso, pausa y Reducir movimiento;
JavaScriptCore nativo decodifica las dos protecciones y enemigos que se alejan.
Binario de simulador: versión/build, plataforma y motor/audio iguales a la fuente
canónica. Evidencia native-v035.json, simulator-v035.json y native-v035/captures.json.
Prueba de sensor, tacto y rendimiento físico pendiente.

Fuentes operativas de Apple comprobadas el 2026-09-08:
https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/
y https://developer.apple.com/help/app-store-connect/test-a-beta-version/add-internal-testers/.
La entrega se gestiona por CI y API oficial; no requiere nuevas cuentas de testers.

## Historial: entrega TestFlight 0.3.4 verificada

Run https://github.com/Krazel/tilt-arena-ios/actions/runs/34145838577.
Fuente f4148118d6cef9248d53ac290a89af0fbe9fe5e9, idéntica a la QA nativa.
Archive Release ARM64, firma, exportación, validación y subida correctos.
IPA 0.3.4 (1), SDK iPhoneOS 26.2, 4.752.132 bytes; SHA-256:
48f7468fffc5bf4ad3083a84cadf8951d97e48127cbb2b1982c29fa0becc70d9.
CRC, plataforma iOS, arquitectura, versión/build, firma, perfil, recursos y
motor/audio idénticos a la fuente canónica verificados.
Apple: e324b2fe-36fc-416d-b2fb-19d247224dc4, VALID e IN_BETA_TESTING.
Grupo Pruebas internas con un tester, solo el titular; relación con la build
y notas es-ES releídas. Ficha App Store 1.0 PREPARE_FOR_SUBMISSION, sin pruebas
externas. Evidencia testflight-v034.json e ipa-v034-testflight-build1.json.

## QA nativa: 0.3.4 (1)

39 pruebas Node pasan. Comprueban giro de fuego desde el primer paso a velocidad
constante, input débil/neutral, estela con giros, independencia 30/60/120 Hz,
carga de onda mientras se mueve, pausa, origen en punta, rumbo de salida y
recogidas encadenadas. Vórtice con radio físico/visual 140 y mayor atracción;
se conservan escape, caída de fuerza, caducidad y límites.
Sintaxis de doce Swift correcta. Código canónico bcfb322; fuente pública
f4148118d6cef9248d53ac290a89af0fbe9fe5e9. Xcode 26.3 (17C529): BUILD SUCCEEDED,
11 XCTest y 6 XCUITest sin fallos, TEST SUCCEEDED. Total: 56 pruebas.
Run https://github.com/Krazel/tilt-arena-ios/actions/runs/34144917480.
Capturas nativas revisadas: 08-wave-tip-charge, 09-wave-released, 10-fire-steering;
núcleo/aro/chispas en la punta, disparo posterior, estela en L al girar y vórtice menor.
Archivo de simulador verificado: 0.3.4 (1), bundle correcto, motor y audio idénticos
a la fuente canónica. Evidencia: native-v034.json, simulator-v034.json y control-v034.json.
El bloqueo quedó resuelto por autorización explícita permanente de publicar código
al repositorio público y entregar builds, guardada en AGENTS.md.
Ensayo físico de control y rendimiento pendiente.

## Historial: entrega TestFlight 0.3.3 verificada

Run https://github.com/Krazel/tilt-arena-ios/actions/runs/34138863698.
Fuente d09515338c6051b4b43f0c676bf5f6c85a94168a, idéntica a la QA nativa.
Archive Release ARM64, firma, exportación, validación y subida correctos.
IPA 0.3.3 (1), SDK iPhoneOS 26.2, 4.747.507 bytes; SHA-256:
23448724e68daa311016c6006723dfbff75974709fa5b6cfb1509470c0b990d2.
Comprobados CRC, plataforma iOS, arquitectura, versión/build, firma, perfil,
recursos y motor/audio idénticos a la fuente canónica.

API Apple: build ac24434e-81b1-452d-ba88-87bc8503400c, VALID e IN_BETA_TESTING.
Grupo Pruebas internas con un tester, solo el titular; relación con la nueva build
y notas es-ES guardadas y releídas. Caduca el 06/12/2026. Ficha App Store 1.0
PREPARE_FOR_SUBMISSION; sin distribución externa. Evidencia testflight-v033.json
e ipa-v033-testflight-build1.json. Siguientes subidas autorizadas permanentemente
por el usuario y registradas en AGENTS.md. Prueba física pendiente.

## Candidata posterior: 0.3.3 (1), compilada y verificada en simulador

Enemigos por encima de orbes y deriva suave del protagonista hacia vórtices.
35 pruebas Node pasan: atracción consistente a 30/60/120 Hz, escape con control,
pausa, caducidad, centro, alcance, límites, campos superpuestos, recogida y choque
con puntos congelados al ser arrastrado. Carga de fuego inmóvil y orientable a
30/60/120 Hz, exactamente 0,5 s sin estela anticipada; impulso único de 0,45 s,
conservación de rumbo con input neutral, pausa, recogida repetida, protección
limitada, recogidas/colisiones durante impulso, fuego persistente y límites.
Sintaxis de once Swift correcta. Xcode 26.3 (17C529), SDK iOS Simulator 26.2:
BUILD SUCCEEDED, 10 XCTest y 5 XCUITest sin fallos, TEST SUCCEEDED. Total: 50.
Código canónico b629799; fuente pública d09515338c6051b4b43f0c676bf5f6c85a94168a.
El usuario autorizó expresamente el envío al espejo público y la compilación;
el rechazo anterior quedó resuelto y ambas acciones se completaron.
Run: https://github.com/Krazel/tilt-arena-ios/actions/runs/34137296208.

Revisadas capturas de iPhone 16 Pro: 06-selected-vfx-charge (0,25 s),
07-selected-vfx-fire-trail (0,7 s), 05-native-ice-and-blast. Aro de carga a la mitad,
guía de rumbo, estela naranja-blanca detrás, tres crecientes lilas, espiral violeta
con núcleo oscuro y enemigos encima de orbes. Son adaptaciones geométricas nativas
de las referencias aprobadas. Capturas completas y SHA-256 en native-v033/captures.json.
Son fixtures de simulador; falta prueba de inclinación y rendimiento en iPhone físico.

Archivo de simulador inspeccionado: versión 0.3.3 (1), bundle com.dmkr.tiltarena,
plataforma iPhoneSimulator. Motor y audio idénticos a fuente probada. SHA-256:
d9930bdf5e78db3a6eda39c94b27fc5fdb77fa8decf393ef12f15beebb06bb92.
Evidencia verification/native-v033.json y verification/simulator-v033.json.
Ese archivo de simulador no es instalable en iPhone. La IPA firmada y su
activación en TestFlight están verificadas por separado en la sección anterior.
Las pruebas y la IPA descritas a continuación corresponden exclusivamente a 0.3.2.

7 de septiembre de 2026. Autorización expresa de compilar y subir recibida.
Fuente pública 5a832ec1906091583383c09c629ae79351717b70; código canónico 5f78fa1.

## Pruebas nativas

https://github.com/Krazel/tilt-arena-ios/actions/runs/34105589370
Xcode 26.3 (17C529). BUILD SUCCEEDED y TEST SUCCEEDED. 28 Node, 9 XCTest y
4 XCUITest, cero fallos. Sintaxis de diez archivos Swift previamente comprobada.

Las pruebas incluyen reposición inmediata y repetida del último orbe, caducidad,
fallback de colocación, pausa/final; puente real JavaScriptCore, respuesta del
neutral plano, migración de posturas y calibración persistente al reabrir la app.

Capturas completas de iPhone 16 Pro en verification/native-v032. Revisadas:
Calibrar inicial, Inclinado con descripción plana, selector de sensibilidad ausente,
puntos vectoriales rojos y cian, flecha/orbes mayores y nueve glifos legibles.
Efecto de hielo relleno facetado y explosión de doble onda y partículas visibles.
Escala uniforme y fondo a pantalla completa. Fixtures exclusivas de Debug para
revisar arte; no equivalen a una partida física ni demuestran rendimiento sostenido.
Evidencia: verification/native-v032.json y native-v032/captures.json.

## Firma y envío verificados

https://github.com/Krazel/tilt-arena-ios/actions/runs/34106646635 .
Archive, exportación, codesign, validación y subida correctos. IPA Release ARM64,
SDK iOS 26.2, 4.733.087 bytes. SHA256:
e742cc968358c601287ddf6ad5b91b7fbf7818efeddf435b78c3bff732acf5e7.
Verificador local: CRC, plataforma iPhoneOS, arquitectura, versión/build, firma y
perfil incluidos, privacidad, icono, PNG y motor/audio correspondientes a fuente.
Evidencia verification/ipa-v032-testflight-build1.json.
No hay cambios de código posteriores a la fuente verificada.

## Estado final Apple y biblioteca

Build ceadfcad-99d6-4684-b820-2462d19b322a, VALID e IN_BETA_TESTING interno.
Asignada al grupo Pruebas internas con un único tester, el titular; notas es-ES
guardadas y releídas. Vence el 06/12/2026. Gestión y verificación por API oficial.
Sin pruebas externas. Ficha App Store 1.0 en PREPARE_FOR_SUBMISSION; sin publicar.
Evidencia verification/testflight-v032.json. Biblioteca PR-031 revisión 15 guardada
y verificada, conservando notas, releases y seguimiento; verification/library-sync.json.

## Ensayo físico pendiente

Velocidad 440 → 470 unidades/s; radio del protagonista 9 → 8 en esta candidata.
Contacto total con puntos 18; recogida de orbes conservada en 33. Verificar sensación,
huecos entre enemigos, control en las dos orientaciones, postura plana, efectos,
sonido, fps y temperatura durante 10 minutos. No se declara prueba física superada.

Historial: verification/VERIFICACION-v031.md y verification/testflight-v031.json.
