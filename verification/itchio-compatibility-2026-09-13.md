# Viabilidad de Tilt Arena en itch.io - 2026-09-13

**Resultado: ficha Draft viable; no hay archivo jugable compatible de la version
vigente preparado para distribuir en itch.io.** No se inicio un port ni otra captura.

0.3.9 (1) es iPhone iOS16+, SpriteKit/SwiftUI/CoreMotion y motor JavaScriptCore.
La IPA existente fue exportada para App Store/TestFlight, no distribucion directa
por un enlace de descarga. El archivo de simulador requiere Xcode/iOS Simulator
y la herramienta de captura usa entradas automatizadas: tampoco es un juego macOS.
No hay ejecutable Windows/Linux/macOS nativo entregado. La web antigua esta excluida
por encargo; qa/ es un laboratorio con renderer distinto, no una version web vigente.

itch.io permite alojar archivos, pero eso no convierte una IPA en ejecutable de PC
o juego de navegador. HTML5 exige una implementacion web completa con index.html y
sus recursos. Adaptar solo el motor JavaScript es insuficiente: faltan renderer y
VFX equivalentes, menus, controles, audio y guardado, y validacion en el iframe.
Esto es trabajo de port, no un empaquetado de archivos existente, y no esta encargado.

Marketing puede guardar el Draft informativo Tilt Arena/KrazelGames con capturas
nativas etiquetadas como iPhone simulado/control automatizado, sin archivo jugable,
sin venta y sin marcar soporte HTML5/PC. El usuario no ha rechazado el trailer de
Tilt: el MP4v1 queda interno para auditoria preventiva, como indica el encargo.
La beta iOS comprobada es interna solo del titular y no ofrece enlace publico;
no se debe presentar como acceso para visitantes de itch.io. Una beta externa
requeriria su proceso y autorizacion propios, no activados por este diagnostico.

Fuentes primarias:
- [itch.io: HTML5](https://itch.io/docs/creators/html5): ZIP con index.html y recursos web completos.
- [itch.io: Creator FAQ](https://itch.io/docs/creators/faq): alojar archivos para distintas plataformas.
- [itch.io: acceso](https://itch.io/docs/creators/access-control): Draft no es distribucion publica.
- [Apple: testers externos](https://developer.apple.com/help/app-store-connect/test-a-beta-version/invite-external-testers/): gestion de beta externa.

Estado de herramientas: ejecucion normal falla al arrancar con apply deny-read ACLs;
lectura autorizada require_escalated funciono sin cambiar ACL. Se recuperaron dos
documentos NUL de la interrupcion desde Git/evidencia; backups en artifacts/document-recovery-2026-09-13/.
No se afirma reparacion general de Codex ni bloqueo tecnico de toda lectura local.

Actualizacion 23:49:23 UTC (01:49 del 13/09 en Madrid): lectura normal de ESTADO.md y backups correcta tras la reparacion coordinada por el cerebro. No se modificaron ACL desde esta tarea.
