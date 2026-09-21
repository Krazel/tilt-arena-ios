# Ink Tide — primera variante aprobada

El 2026-09-21 el usuario selecciona «01 Pinos y viento» y encarga trasladarla a
todo el juego, conservando el aspecto anterior para cambiar fácilmente.
Referencia: reference.png, imagen completa horizontal. Mismos controles y reglas.

Implementación: candidata iOS 0.4 (1), SpriteKit/SwiftUI. Tema predeterminado
Ink Tide; selector «Estilo visual / Visual style» en menú y pausa. Original
conserva renderer, assets y efectos previos. La preferencia usa classic.visualTheme,
independiente de récords y calibración. El cambio reconstruye solo los nodos
visuales y no reproduce eventos ni reinicia la simulación pausada.

Fondo y atlas originales generados con ChatGPT Imágenes tomando la referencia:
native-ios/Resources/ink-tide-arena.png y ink-tide-sprites.png. Atlas transparente
4×2: flecha, enemigo, sello, onda; fuego, vórtice, salpicadura y bumerán. Glifos
nativos de los diez poderes conservan su significado. El origen del enemigo
coincide con la cabeza redonda; cola decorativa fuera de la colisión. Flecha
orientada al eje +X del motor. Fondo adaptado al viewport completo del iPhone.

VFX: tinta opaca y pinceladas en lugar de brillo aditivo, fragmentos y anillos
irregulares, hielo con silueta cristalina conservada, aviso de pinchos legible
sobre escudo. Cargas siguen el reloj real de la simulación. Reducir movimiento
evita partículas y expansiones grandes. Máximo de 40 raíces VFX conservado.

Icono generado con el mismo estilo, normalizado a RGB 1024×1024 para el catálogo
iOS; máster guardado. Icono anterior en design/archive/original/AppIcon.png.
Cambiar el tema afecta al juego, no al icono de inicio de iOS.

Validación pendiente de compilación y capturas nativas. Las imágenes conceptuales
no son capturas del binario. Motor classic-core.js intacto, 60 pruebas Node pasan.
