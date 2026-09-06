# Tilt Arena — estado de producto

Actualizado 2026-09-06. Krazel Games. Registro PR-031.
Responsable: tarea de producto `01a071f1-2875-7bc1-a4bd-9d9e38c35718`.
Nombre comercial provisional. Referencia: Tilt to Live, Classic para iPhone.

## Entrega actual

**0.3.1, build 1**, activa en TestFlight interno para la cuenta del titular.
Apple ha procesado la build como VALID y su estado interno es IN_BETA_TESTING.
Grupo «Pruebas internas»: un tester, una build, distribución futura manual.
Sin pruebas externas ni enlace público de invitación.

Ficha creada en App Store Connect: https://appstoreconnect.apple.com/apps/6809193185/distribution .
TestFlight: https://appstoreconnect.apple.com/apps/6809193185/testflight .
Apple ID 6809193185; bundle com.dmkr.tiltarena. La ficha pública 1.0 está en
preparación, sin envío a revisión ni publicación visible en la tienda.

Los enemigos vuelven al círculo vectorial original: rojo, borde claro y radio 7.
El PNG enemy-dot-v03 queda conservado como asset histórico, excluido del bundle.
Los congelados son cian. Se conservan los orbes y destellos de ChatGPT Images,
los VFX y las mejoras 0.3 de pantalla, posturas y reanudación.
No se han añadido modos fácil/difícil ni cambiado la curva de dificultad:
el usuario aplazó expresamente ese trabajo.

IPA firmada: `artifacts/TiltArena-0.3.1-build1-TestFlight.ipa`.
SHA256: `5ad6b885ad77e9249a1b3ec48f56b8282b8890a38040de5d92237e887a1bdf92`.
Xcode 26.3, SDK iOS 26.2, Release iPhoneOS ARM64, iOS 16+, español.
Subida: https://github.com/Krazel/tilt-arena-ios/actions/runs/34043750047 .
Fuente pública compilada: `f25fa839a558d2f352b3d2d26b9e19c2d8a1ed6c`.
Fuente canónica equivalente: `7e6cb19`.

25 Node, 7 XCTest y 2 XCUITest aprobados. Capturas nativas revisadas, firma
verificada en CI y contenido de la IPA comprobado localmente. No equivale a
prueba física: el último ensayo comunicado por el usuario fue 0.2.0 build 3.
Detalles: `VERIFICACION.md`, `verification/testflight-v031.json`.

## Siguiente prueba

Instalar 0.3.1 (1) desde TestFlight. Probar pantalla completa en ambas orientaciones,
Normal/Inclinado/Personalizado, calibración guardada, pausa/reanudar, salir/volver,
sonido y efectos durante 10 minutos. Medir control, fps y temperatura en iPhone.

## Conservación y biblioteca

Ruta efectiva: `C:\Users\dmkra\Documents\Codex Apps\TiltArena`. Sin traslado.
Git independiente; base heredada 2c505de preservada. El espejo público contiene
solo fuente saneada. Firma privada fuera del repositorio; secretos cifrados del
entorno app-store-production restringido a main. Certificado existente reutilizado
con un perfil exclusivo de Tilt Arena; no se han cambiado perfiles de otros juegos.

PR-031 actualizado y verificado en la API autorizada de D1, revisión 10,
2026-09-06 16:01:20 UTC. Nombre, notas y releases anteriores conservados.
Seguimiento: TestFlight Interno; Creada en App Store Connect; anuncios No.
Evidencia: `verification/library-sync.json`. Historial 0.3: `verification/ESTADO-v03-build2.md`.
