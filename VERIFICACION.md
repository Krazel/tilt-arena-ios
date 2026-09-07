# Verificación — 0.3.2 (1)

## Trabajo local posterior: 0.3.3 (1)

Enemigos por encima de orbes y deriva suave del protagonista hacia vórtices.
35 pruebas Node pasan: atracción consistente a 30/60/120 Hz, escape con control,
pausa, caducidad, centro, alcance, límites, campos superpuestos, recogida y choque
con puntos congelados al ser arrastrado. Carga de fuego inmóvil y orientable a
30/60/120 Hz, exactamente 0,5 s sin estela anticipada; impulso único de 0,45 s,
conservación de rumbo con input neutral, pausa, recogida repetida, protección
limitada, recogidas/colisiones durante impulso, fuego persistente y límites.
Sintaxis de once Swift correcta. Nuevas pruebas XCTest y XCUITest preparadas,
pero aún no ejecutadas con SDK. Código canónico b629799; espejo local d095153.
Revisión automática rechazó el push público y disparo de CI; requiere autorización
para enviar estos nuevos cambios al repositorio público. No se intentó un rodeo.
QA visual nativa, compilación y subida pendientes; las pruebas nativas y la IPA
descritas a continuación corresponden exclusivamente a 0.3.2 (1).

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
