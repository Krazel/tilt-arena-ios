# Verificación — candidata 0.3.2 (1)

6 de septiembre de 2026. Código preparado en espejo local, todavía sin publicar.

28 pruebas Node aprobadas, incluidos 100 reemplazos sucesivos de la última magia,
caducidad, colocación alternativa cuando falla el muestreo y pausa/final.
Diez archivos Swift pasan el analizador de sintaxis. Esto no resuelve tipos del SDK
ni sustituye la compilación con Xcode y las pruebas nativas.

Retirado el selector de sensibilidad y su persistencia; ClassicScene entrega
siempre sensibilidad 1 al puente. Las preferencias antiguas no se consultan.
Análisis sintáctico repetido tras este cambio: diez archivos Swift correctos.

Ajuste posterior: velocidad 440 → 470 unidades/s, radio del protagonista 9 → 8;
alcance de recogida separado en pickupReach=33 para conservarlo. Las 28 pruebas
del motor pasan tras el ajuste; node --check y git diff --check correctos.

Pendientes: compilación y XCTest/XCUITest en Mac, revisión de las capturas nativas,
IPA firmada, procesamiento Apple y asignación al grupo interno. Las acciones de
subir código al espejo público y ejecutar CI fueron rechazadas por auto-review
por considerar insuficiente la autorización anterior; confirmación concreta enviada.
No se ha publicado este commit ni se ha generado una IPA 0.3.2.

Los cambios de límites de colisión acompañan al aumento visual; la prueba física
debe evaluar legibilidad, huecos, sensibilidad plana, efectos y rendimiento.
La versión activa anterior sigue siendo 0.3.1 (1). Evidencia histórica:
verification/VERIFICACION-v031.md y verification/testflight-v031.json.
