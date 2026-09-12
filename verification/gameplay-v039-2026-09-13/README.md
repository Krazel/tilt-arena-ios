# Metraje nativo Tilt Arena 0.3.9 (1)

Entrega del 13/09/2026, iPhone 16 Pro simulado, iOS26.2/Xcode26.3, control automatizado.
Dos MP4 completos en ../../artifacts/: TiltArena-0.3.9-native-gameplay-seed2.mp4
(70,37 s, 65,02 de juego) y TiltArena-0.3.9-native-gameplay-seed7.mp4 (54,23 s,
49,67 de juego y muerte final). Resolucion2622x1206. Sin cortes, recorte, rotulos
ni audio; solo giro antihorario de90 grados y codificacion H.264 CRF18.
Brutos originales y comandos en capture-provenance.json; hashes y rutas en delivery.json.

El motor y renderer de produccion siguen intactos. Se reproducen las6832 entradas
registradas, con eventos/puntos/bajas iguales y error maximo de posicion1,3e-13.
Ver replay-verification.json. CI34723559098, fuente basec733e9e, overlay692a5ac.
No fixtures, spawning falso, inmunidad artificial ni cambios de dificultad.

Siete seed-N-gameplay-NN.png son capturas originales de simctl (giradas).
Cuatro seed-N-video-NNs.png son fotogramas horizontales del video, sin rotulos.
Musica propia para montaje: ../../native-ios/Resources/classic-loop.wav; no se
presenta como audio directo ni efectos sincronizados. Dynamic Island negro queda
fuera de la arena. Cadencia capturada variable: no anunciar60fps garantizados.

Se revisaron fotogramas y ambos videos se decodificaron completos al girarlos.
El mayor salto de telemetria es0,684s en toma2 y0,051s en toma7. No hubo recogida de
bumeran. Marketing confirmo que estos brutos bastaban; no segunda CI. MP4 final
interno para auditoria de cadencia/montaje. No prueba fisica ni footage PC.
