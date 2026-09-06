# Verificación — 0.3.1, build 1

6 de septiembre de 2026. Corrección visual y primera distribución TestFlight.
Fuente pública f25fa839a558d2f352b3d2d26b9e19c2d8a1ed6c; canónica 7e6cb19.

## Pruebas nativas

CI: https://github.com/Krazel/tilt-arena-ios/actions/runs/34043377249 .
Xcode 26.3 (17C529), SDK 26.2. BUILD SUCCEEDED y TEST SUCCEEDED.
25 Node, 7 XCTest y 2 XCUITest sin fallos; diez archivos Swift sin errores sintácticos.
Capturas de iPhone 16 Pro en `verification/native-v031/`: menú, pausa,
Personalizado guardado y fixture de arte. Revisadas menú y escena: fondo completo,
controles legibles, enemigos rojos vectoriales, congelados cian, orbes conservados.
El fixture es exclusivo de Debug; no demuestra rendimiento de una partida física.

## Firma y envío

CI: https://github.com/Krazel/tilt-arena-ios/actions/runs/34043750047 .
Archive y exportación App Store correctos, codesign --verify --deep --strict
aprobado, validación altool correcta y UPLOAD SUCCEEDED sin errores.
IPA 4.731.674 bytes, SHA256 5ad6b885ad77e9249a1b3ec48f56b8282b8890a38040de5d92237e887a1bdf92.
Verificador `verification/inspect-ipa-testflight.py`: CRC, versión 0.3.1 (1),
bundle, iPhoneOS ARM64, perfil, firma incluida, icono compilado, manifest de
privacidad, ausencia de enemy-dot-v03 y motor/WAV idénticos a la fuente.
Los dos PNG conservados usan optimización CgBI; se verifican dimensiones y CRC.
Resultado: `verification/ipa-v031-testflight-build1.json`.

El manifiesto declara UserDefaults CA92.1 (preferencias locales) y SystemBootTime
35F9.1 (intervalos y temporizadores). Sin datos recogidos, seguimiento ni cifrado
no exento. El icono es el SVG propio preexistente rasterizado a 1024, opaco.
Requisito de SDK: https://developer.apple.com/news/?id=ueeok6yw .
Razones: https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitype .

## Estado comprobado en Apple

App ID 6809193185. Build 410710dc-eb9b-4736-b869-453236cfd1b8.
Procesamiento VALID; IN_BETA_TESTING interno. Grupo f188cdd9-6415-456e-8054-9925c02bead5,
«Pruebas internas», con solo la cuenta del titular y esta build. Caduca 05/12/2026.
Descripción e instrucciones en español guardadas. Sin revisión beta externa.
La ficha App Store 1.0 permanece PREPARE_FOR_SUBMISSION; no está publicada.
Evidencia API: `verification/testflight-v031.json`; Chrome confirma la asignación.

Pendiente: instalación y ensayo del usuario en iPhone, precisión del sensor,
ambas orientaciones, fps/temperatura, sonido y VFX. Dificultad sin cambios.
Historial anterior: `verification/VERIFICACION-v03-build2.md`.
