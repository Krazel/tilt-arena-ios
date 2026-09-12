# Captura nativa reproducible — 0.3.9

Herramienta exclusiva de marketing; no se incluye en el target de producción.
`prepare.py` copia native-ios a artifacts/capture-target y añade únicamente
entrada simulada, inicio por señal y registro de frames/inputs. No modifica el
motor, arte, sonido, reglas, temporizadores, daño, puntos ni apariciones. La
partida se crea con spawning true y una semilla registrada; no hay fixtures.

`driver.js` solo recibe snapshots y límites y devuelve un vector normalizado.
`preflight.cjs` verifica que no muta el snapshot y busca una partida normal con
bumerán. Elegir una semilla reproducible no garantiza la misma supervivencia
con temporización real del simulador; se conservan también muertes y resultados.

En Mac con Xcode 26.3/iOS Simulator 26.2 y XcodeGen:

```sh
node capture/preflight.cjs
python3 capture/prepare.py
python3 capture/record.py
```

CI: capture-gameplay.yml, sin secretos de firma ni acciones de App Store Connect.
Produce dos MP4 sin cortes ni rótulos, PNG nativos y telemetría en
artifacts/gameplay-capture/. La app conserva menús y HUD; los archivos indican
la semilla, dispositivo simulado, fuente base, overlay y comandos de grabación.
Los primeros segundos muestran el menú antes de comenzar la partida.

Captura de pantalla mediante el comando oficial
[simctl recordVideo](https://developer.apple.com/videos/play/wwdc2020/10647/).
No se presenta como iPhone físico ni PC. El MP4 bruto no presupone pista de audio;
marketing puede montar classic-loop.wav propio como música y declararlo como
montaje. No inventar sincronía de efectos. No enviar la app instrumentada a Apple.
