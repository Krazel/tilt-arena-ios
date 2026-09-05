# Publicación de fuente autorizada · 05/09/2026

El usuario respondió «autorizo» a la propuesta concreta de crear públicamente
`Krazel/tilt-arena-ios` y compilar en GitHub Actions el paquete preparado
`artifacts/TiltArena-0.2.0-build-source.zip`.

SHA256 del paquete: `F3E8AA9C9587CE0F859746ED907D65B43776D39C4F2ACD56AF1E476D281707B9`.
Fuente canónica del paquete: `7ae88251001338f1f28f48981f919c4b6a569720`.
Primer commit público: `8513881ca9b9969ddd354c6b858eec305302545a`.

El repositorio público tiene un historial nuevo con los 29 archivos del paquete.
El historial del producto, prototipos heredados, capturas de referencia y notas
de Studio permanecen en el repositorio local. El checkout de publicación está
en `artifacts/public-build`, excluido del Git canónico. No subir todo el historial
local a ese remoto. Sincronizar solo los archivos de implementación autorizados.

La primera ejecución `33976594323` pasó 23 pruebas Node y falló al compilar Swift:
`ClassicScene.frame` chocaba con `SKNode.frame`, y el inicializador necesitaba
`override`. La corrección está en el commit canónico
`0e741d379ae28be5454ac8b6b2e297210562c43e` y público
`15696c03dda4b3ac3533e1f891dd7700bc09ed38`.

Se mantiene 0.2.0 build 1: el primer intento no produjo un binario; la corrección
completa la primera candidata sin cambiar su comportamiento previsto. Esta
autorización no supone firma, IPA, TestFlight ni publicación en App Store.

Repositorio: https://github.com/Krazel/tilt-arena-ios
Segunda ejecución: https://github.com/Krazel/tilt-arena-ios/actions/runs/33976739671

## Resultado final

La segunda ejecución produjo build 1 y pasó 3 XCTest, pero falló después al intentar
instalar la app para la captura en un simulador apagado. Se incrementó a build 2
para recompilar tras corregir únicamente CI; versión de juego conservada.
Se empaqueta antes de XCTest y `simctl bootstatus -b` arranca el dispositivo para
la captura. No se oculta ni se omite el fallo de una prueba.

Build 2 correcta: https://github.com/Krazel/tilt-arena-ios/actions/runs/33977023251 .
Commit compilado público: `bf55e83612df722d54f79bde78758cf0a6388b71`.
Commit canónico de implementación: `26a892491dc1ace9f7d3b12c7b3162a55f4c10e5`.
El posterior commit público `0fcdb2b` solo actualiza README, sin recompilación.
23 pruebas Node, 3 XCTest, paquete y captura nativa verificados. Artefacto remoto:
https://github.com/Krazel/tilt-arena-ios/actions/runs/33977023251/artifacts/9972725301 .
Retención en Actions: 7 días; copia descargada conservada en `artifacts/build2/`.
Manifiesto y límites: `simulator-artifact.json` y `../VERIFICACION.md`.
