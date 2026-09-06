# Tilt Arena — estado de producto

Actualizado 2026-09-06. Krazel Games. Registro PR-031.
Responsable: tarea 01a071f1-2875-7bc1-a4bd-9d9e38c35718.

## Candidata en desarrollo

0.3.2 (1), código local preparado. Flecha, puntos y orbes mayores; última magia
repuesta al recogerla o caducar en el mismo paso; VFX con hielo facetado, explosiones
con más cuerpo y estelas. Menú Calibrar/Normal/Inclinado, calibración como valor
inicial y migración única; Inclinado para iPhone plano sobre la mesa (0°).
Se recuerdan elecciones posteriores y calibraciones guardadas. Se conservan los
enemigos vectoriales, orbes y partículas aprobados. Modos y progresión aplazados.
Selector Suave/Normal/Rápida eliminado por petición del usuario; sensibilidad fija
en 1 para todas las posturas, sin usar preferencias antiguas de sensibilidad.
Último ajuste pedido: velocidad máxima 470 (+6,8 %); radio del protagonista frente
a enemigos 8 en vez de 9. Contacto total 18; recogida de orbes conservada en 33.

28 pruebas Node y sintaxis de diez archivos Swift aprobadas. Los radios de contacto
acompañan el nuevo tamaño: no se afirma dificultad percibida idéntica. Ensayo físico
pendiente. Faltan Xcode, XCTest, XCUITest y revisión de las nuevas capturas nativas.

Espejo público local preparado, todavía sin subir. Auto-review rechazó
la subida de los 11 archivos a Krazel/tilt-arena-ios y ejecución de CI: no considera
suficiente la autorización anterior ni el registro del repositorio autorizado.
Se ha pedido confirmación explícita. No eludir el rechazo con otro canal.
Siguiente paso: con esa autorización, subir el commit, verificar nativo, compilar
IPA 0.3.2 y actualizar el mismo grupo TestFlight interno de la cuenta del titular.

## Distribución comprobada anterior

0.3.1 (1) continúa activa en TestFlight interno; procesada VALID e IN_BETA_TESTING.
No se ha creado ni subido una IPA 0.3.2. Sin pruebas externas ni publicación visible
en App Store. La ficha 1.0 está en preparación, sin envío a revisión.
App ID 6809193185; bundle com.dmkr.tiltarena. Anuncios: No.
https://appstoreconnect.apple.com/apps/6809193185/testflight
https://appstoreconnect.apple.com/apps/6809193185/distribution

IPA anterior: artifacts/TiltArena-0.3.1-build1-TestFlight.ipa.
Firma, hashes y pruebas anteriores: verification/ESTADO-v031.md,
verification/VERIFICACION-v031.md y verification/testflight-v031.json.

## Conservación

Ruta efectiva: C:\Users\dmkra\Documents\Codex Apps\TiltArena. Sin traslado.
Git independiente; base heredada preservada. Espejo público saneado, sin historial
privado ni claves. Las credenciales siguen fuera del producto, protegidas.
Biblioteca PR-031 actualizada y verificada por GET, revisión 13, 2026-09-06
21:16:43 UTC. Candidata local 0.3.2 separada de entrega interna 0.3.1, bloqueo y
siguiente paso registrados. Notas, releases y tracking conservados.
Evidencia: verification/library-sync.json.
