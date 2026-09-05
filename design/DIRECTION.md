# Dirección visual y controles — 0.3

Encargo explícito del usuario tras probar 0.2.0 build 3: quitar los bordes negros,
reanudar sin calibración obligatoria, posturas Normal/Inclinado/Personalizado,
crear los círculos con ChatGPT Imágenes y mejorar VFX. El usuario confirma que
las opciones son posturas de control, no modos de estirado. Decisiones delegadas.

## Referencia de composición

Paisaje a pantalla completa. Fondo oliva de borde a borde, arena adaptada al ancho
real, alturas y tamaños de entidades constantes en 640 unidades. La escala X/Y
es uniforme. Borde de juego y HUD respetan el mayor margen lateral del dispositivo;
la isla y el indicador de inicio no ocultan objetivos. El fondo sí ocupa esos márgenes.

Menú y pausa: tarjeta oscura con borde lima, ancho máximo 780 pt. Dos columnas:
izquierda marca pequeña, título, estado/récord, botón principal; derecha POSTURA
DE CONTROL, tres tarjetas con icono y título, descripción, sensibilidad y sonido.
Se conserva el lenguaje oliva/lima del juego. Los orbes son materiales luminosos,
con símbolo oscuro de fondo y glifo blanco claramente legible.

Estados y acciones:
- Menú: Jugar usa la postura seleccionada; Calibrar postura guarda Personalizado.
- Pausa: Reanudar conserva partida y postura; Recalibrar es independiente;
  Terminar partida liquida la puntuación. Cancelar calibración vuelve a Pausa.
- Personalizado: primera vez pide una muestra; después usa la guardada. Normal
  e Inclinado tienen referencia de 45° y 70°, valores propios, no extraídos del
  código de Tilt to Live. La respuesta compara ángulos para compensar el cambio
  de postura. La transformación de 180° conserva la referencia en ejes de pantalla.
- Final: Otra partida usa la postura ya elegida; no pide calibrar por defecto.

## Recursos de ChatGPT Imágenes

Herramienta incorporada image_gen (sin CLI/API alternativa). PNG RGBA conservados
con alfa real y sin editar: native-ios/Resources/orb-glass-v03.png,
enemy-dot-v03.png y energy-spark-v03.png. Prompts completos:
imagegen-v03-prompts.json; SHA256 y formato: ../verification/generated-art-v03.json.

SpriteKit reduce resolución al cargar para evitar texturas de 1254px por entidad.
Una sola textura compartida de cada recurso. El orbe se tiñe por arma; los nueve
glifos son geometría nativa. Los puntos conservan diámetro físico de colisión.
La partícula blanca alimenta destellos y estelas, teñida en el motor.

VFX: doble onda de choque expansiva, partículas aditivas, astillas para hielo,
rayo segmentado con halo, estelas de misiles, fuego luminoso y vórtice giratorio.
Los emisores caducan y la capa limita nuevos efectos a 48 nodos. Reducir movimiento
suprime estelas, expansión decorativa y astillas y reduce las partículas.

## Verificación requerida

25 pruebas de motor. XCTest para respuesta entre posturas, conservación al girar,
resolución adaptable, reanudación sin calibrar y carga de las tres texturas.
XCUITest para seleccionar postura, jugar, pausar, reanudar y guardar Personalizado.
Capturas de menú, pausa y fixture nativo de las nueve armas/VFX. Este fixture está
solo en Debug y no demuestra una partida ni fps; el IPA Release no lo activa.
Comparar las capturas con la composición anterior antes de dar la entrega por lista.
La prueba física del nuevo control y rendimiento corresponde a la nueva IPA.

Historial de la dirección previa: DIRECTION-v02.md.

QA de cierre: los puntos congelados usan capa nativa cian con faceta blanca sobre
la textura generada. Multiplicar el tinte cian por el punto rojo lo oscurecía,
detectado en la captura de build 1; corregido para build 2. La textura original
permanece intacta y se comparte entre puntos.
