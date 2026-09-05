const canvas = document.querySelector("#gameCanvas");
const ctx = canvas.getContext("2d");

const ui = {
  startPanel: document.querySelector("#startPanel"),
  pausePanel: document.querySelector("#pausePanel"),
  gameOverPanel: document.querySelector("#gameOverPanel"),
  startButton: document.querySelector("#startButton"),
  tiltButton: document.querySelector("#tiltButton"),
  pauseButton: document.querySelector("#pauseButton"),
  resumeButton: document.querySelector("#resumeButton"),
  newRunButton: document.querySelector("#newRunButton"),
  restartButton: document.querySelector("#restartButton"),
  tiltPad: document.querySelector("#tiltPad"),
  tiltStick: document.querySelector("#tiltStick"),
  scoreText: document.querySelector("#scoreText"),
  comboText: document.querySelector("#comboText"),
  timeText: document.querySelector("#timeText"),
  bestText: document.querySelector("#bestText"),
  powerBar: document.querySelector("#powerBar"),
  controlText: document.querySelector("#controlText"),
  finalTitle: document.querySelector("#finalTitle"),
  finalScore: document.querySelector("#finalScore"),
  finalCombo: document.querySelector("#finalCombo"),
  finalTime: document.querySelector("#finalTime")
};

const storageBest = "tilt-arena-best";
const arena = { width: 0, height: 0, padding: 16 };
const perf = {
  hudInterval: 0.12,
  maxDpr: 1.35,
  maxEnemies: 76,
  maxEffects: 180
};
const pickupTypes = [
  { id: "frost", label: "Hielo", color: "#87b7c3", cooldown: 9.5, icon: "assets/concept-c/power-frost.svg", desc: "Pulso que congela y limpia enemigos cercanos." },
  { id: "missiles", label: "Misiles", color: "#c6a857", cooldown: 11, icon: "assets/concept-c/power-missiles.svg", desc: "Salva guiada hacia los enemigos mas cercanos." },
  { id: "vortex", label: "Vortice", color: "#8f78a8", cooldown: 13, icon: "assets/concept-c/power-vortex.svg", desc: "Campo que absorbe enemigos hacia su centro." },
  { id: "shield", label: "Escudo", color: "#7faa6e", cooldown: 12, icon: "assets/concept-c/power-shield.svg", desc: "Proteccion temporal que destruye al contacto." },
  { id: "spikes", label: "Sierra", color: "#e8ecd1", cooldown: 10, icon: "assets/concept-c/power-spikes.svg", desc: "Cuchillas orbitando alrededor de la flecha." },
  { id: "shock", label: "Rayo", color: "#87b7c3", cooldown: 8.5, icon: "assets/concept-c/power-shock.svg", desc: "Cadena electrica entre muchos enemigos." }
];

const assetSources = {
  player: "assets/concept-c/player-arrow.svg",
  enemy: "assets/concept-c/enemy.svg",
  elite: "assets/concept-c/elite.svg",
  pickup: "assets/concept-c/pickup.svg"
};
pickupTypes.forEach((type) => {
  assetSources[type.id] = type.icon;
});
const assets = Object.fromEntries(
  Object.entries(assetSources).map(([id, src]) => {
    const image = new Image();
    image.src = src;
    image.addEventListener("load", () => draw());
    return [id, image];
  })
);

const state = {
  mode: "menu",
  width: 0,
  height: 0,
  dpr: 1,
  lastTime: 0,
  elapsed: 0,
  spawnTimer: 0,
  pickupTimer: 0,
  score: 0,
  best: Number(localStorage.getItem(storageBest) || 0),
  combo: 1,
  maxCombo: 1,
  comboTimer: 0,
  keys: new Set(),
  pointer: { active: false, id: null, x: 0, y: 0 },
  tilt: { enabled: false, x: 0, y: 0, calibrated: false, beta0: 0, gamma0: 0 },
  player: null,
  enemies: [],
  pickups: [],
  bullets: [],
  effects: [],
  activePowers: [],
  hudTimer: 0,
  hudCache: {
    score: "",
    combo: "",
    time: "",
    best: "",
    control: "",
    powers: ""
  }
};

let lastStartAt = 0;

function resetGame() {
  state.elapsed = 0;
  state.spawnTimer = 0;
  state.pickupTimer = 2.2;
  state.score = 0;
  state.combo = 1;
  state.maxCombo = 1;
  state.comboTimer = 0;
  state.player = {
    x: arena.width / 2,
    y: arena.height / 2,
    vx: 0,
    vy: 0,
    r: 7,
    pickupR: 20,
    visualR: 32,
    angle: -Math.PI / 2,
    invulnerable: 1.6,
    shield: 0,
    spikes: 0
  };
  state.enemies = [];
  state.pickups = [];
  state.bullets = [];
  state.effects = [];
  state.activePowers = [];
  state.hudTimer = 0;
  state.hudCache = { score: "", combo: "", time: "", best: "", control: "", powers: "" };
  updateHud(true);
}

function startGame() {
  const now = performance.now();
  if (state.mode === "running" && now - lastStartAt < 350) return;
  lastStartAt = now;
  resetGame();
  state.mode = "running";
  ui.startPanel.hidden = true;
  ui.pausePanel.hidden = true;
  ui.gameOverPanel.hidden = true;
  ui.scoreText.textContent = "0";
  ui.timeText.textContent = "0:00";
  addRing(state.player.x, state.player.y, "#f9dc5c", 180, 0.7);
  for (let i = 0; i < 6; i += 1) spawnEnemyRing(i, 6);
  spawnPickup();
  state.lastTime = performance.now();
  requestAnimationFrame(loop);
}

function loop(now) {
  if (state.mode !== "running") return;
  const dt = Math.min((now - state.lastTime) / 1000, 0.033);
  state.lastTime = now;
  update(dt);
  draw();
  requestAnimationFrame(loop);
}

function update(dt) {
  state.elapsed += dt;
  state.comboTimer = Math.max(0, state.comboTimer - dt);
  if (state.comboTimer <= 0) state.combo = 1;

  updatePlayer(dt);
  updateSpawns(dt);
  updatePickups(dt);
  updatePowers(dt);
  updateBullets(dt);
  updateEnemies(dt);
  updateEffects(dt);
  state.hudTimer -= dt;
  if (state.hudTimer <= 0) {
    updateHud();
    state.hudTimer = perf.hudInterval;
  }
}

function updatePlayer(dt) {
  const input = getInputVector();
  const p = state.player;
  const accel = 1500;
  const drag = 0.88;
  p.vx = (p.vx + input.x * accel * dt) * Math.pow(drag, dt * 60);
  p.vy = (p.vy + input.y * accel * dt) * Math.pow(drag, dt * 60);
  const speed = Math.hypot(p.vx, p.vy);
  const maxSpeed = state.tilt.enabled ? 620 : 560;
  if (speed > maxSpeed) {
    p.vx = (p.vx / speed) * maxSpeed;
    p.vy = (p.vy / speed) * maxSpeed;
  }
  p.x = clamp(p.x + p.vx * dt, arena.padding + p.r, arena.width - arena.padding - p.r);
  p.y = clamp(p.y + p.vy * dt, arena.padding + p.r, arena.height - arena.padding - p.r);
  if (speed > 18) p.angle = Math.atan2(p.vy, p.vx);
  p.invulnerable = Math.max(0, p.invulnerable - dt);
  p.shield = Math.max(0, p.shield - dt);
  p.spikes = Math.max(0, p.spikes - dt);
}

function getInputVector() {
  let x = 0;
  let y = 0;
  if (state.keys.has("arrowleft") || state.keys.has("a")) x -= 1;
  if (state.keys.has("arrowright") || state.keys.has("d")) x += 1;
  if (state.keys.has("arrowup") || state.keys.has("w")) y -= 1;
  if (state.keys.has("arrowdown") || state.keys.has("s")) y += 1;
  if (state.pointer.active) {
    x += state.pointer.x;
    y += state.pointer.y;
  }
  if (state.tilt.enabled) {
    x += state.tilt.x;
    y += state.tilt.y;
  }
  const len = Math.hypot(x, y);
  return len > 1 ? { x: x / len, y: y / len } : { x, y };
}

function updateSpawns(dt) {
  const pressure = 1 + state.elapsed / 42;
  state.spawnTimer -= dt;
  if (state.spawnTimer <= 0) {
    const wave = Math.min(22, Math.floor(3 + pressure * 2.2));
    const pattern = Math.random();
    const room = Math.max(0, perf.maxEnemies - state.enemies.length);
    for (let i = 0; i < Math.min(wave, room); i += 1) {
      if (pattern < 0.35) spawnEnemyRing(i, wave);
      else if (pattern < 0.68) spawnEnemySpiral(i, wave);
      else spawnEnemyEdge();
    }
    state.spawnTimer = Math.max(0.55, 1.85 - state.elapsed * 0.007);
  }

  state.pickupTimer -= dt;
  if (state.pickupTimer <= 0) {
    spawnPickup();
    state.pickupTimer = Math.max(2.1, 5.8 - state.elapsed * 0.018);
  }
}

function spawnEnemyRing(index, total) {
  const angle = (Math.PI * 2 * index) / total + Math.random() * 0.14;
  const point = edgePoint(angle, 8);
  spawnEnemy(point.x, point.y, 0.78 + Math.random() * 0.38);
}

function spawnEnemySpiral(index, total) {
  const angle = state.elapsed * 1.6 + index * 0.54;
  const point = edgePoint(angle + index * 0.08, 8 + index * 1.5);
  spawnEnemy(point.x, point.y, 0.82 + index / total * 0.45);
}

function spawnEnemyEdge() {
  const side = Math.floor(Math.random() * 4);
  const x = side === 0 ? arena.padding : side === 1 ? arena.width - arena.padding : random(arena.padding, arena.width - arena.padding);
  const y = side === 2 ? arena.padding : side === 3 ? arena.height - arena.padding : random(arena.padding, arena.height - arena.padding);
  spawnEnemy(x, y, 0.92 + Math.random() * 0.5);
}

function spawnEnemy(x, y, speedScale) {
  if (state.enemies.length >= perf.maxEnemies) return;
  const elite = Math.random() < Math.min(0.12, state.elapsed / 900);
  state.enemies.push({
    x: clamp(x, arena.padding, arena.width - arena.padding),
    y: clamp(y, arena.padding, arena.height - arena.padding),
    vx: 0,
    vy: 0,
    r: elite ? 16 : 10 + Math.random() * 3,
    speed: (elite ? 46 : 58) * speedScale * (1 + state.elapsed / 260),
    frozen: 0,
    elite,
    pulse: Math.random() * Math.PI * 2
  });
}

function edgePoint(angle, inset) {
  const cx = arena.width / 2;
  const cy = arena.height / 2;
  const dx = Math.cos(angle);
  const dy = Math.sin(angle);
  const tx = dx > 0 ? (arena.width - arena.padding - inset - cx) / dx : (arena.padding + inset - cx) / dx;
  const ty = dy > 0 ? (arena.height - arena.padding - inset - cy) / dy : (arena.padding + inset - cy) / dy;
  const t = Math.min(Math.abs(tx), Math.abs(ty));
  return {
    x: clamp(cx + dx * t, arena.padding + inset, arena.width - arena.padding - inset),
    y: clamp(cy + dy * t, arena.padding + inset, arena.height - arena.padding - inset)
  };
}

function spawnPickup() {
  const type = pickupTypes[Math.floor(Math.random() * pickupTypes.length)];
  state.pickups.push({
    ...type,
    x: random(arena.padding + 48, arena.width - arena.padding - 48),
    y: random(arena.padding + 48, arena.height - arena.padding - 48),
    r: 16,
    age: 0,
    ttl: 10
  });
}

function updatePickups(dt) {
  const p = state.player;
  state.pickups = state.pickups.filter((pickup) => {
    pickup.age += dt;
    if (distance(p, pickup) < (p.pickupR || p.r) + pickup.r) {
      triggerPower(pickup.id);
      addRing(pickup.x, pickup.y, pickup.color, 38, 0.45);
      vibrate(24);
      return false;
    }
    return pickup.age < pickup.ttl;
  });
}

function triggerPower(id) {
  const type = pickupTypes.find((item) => item.id === id);
  if (!type) return;
  state.activePowers.unshift({ id, label: type.label, color: type.color, time: type.cooldown });
  const field = Math.min(arena.width, arena.height);
  if (id === "frost") {
    const radius = field * 0.58;
    state.enemies.forEach((enemy) => {
      enemy.frozen = Math.max(enemy.frozen, 3.2);
      if (distance(enemy, state.player) < radius) killEnemy(enemy, "ice");
    });
    addRing(state.player.x, state.player.y, type.color, radius, 0.65);
    addScreenFlash(type.color, 0.08);
    addRadialShards(state.player.x, state.player.y, type.color, 14, 160);
  }
  if (id === "missiles") {
    const targets = nearestEnemies(8);
    for (const enemy of targets) {
      spawnBullet(enemy, type.color, 520, 34, 14);
      window.setTimeout(() => {
        if (state.mode === "running" && state.enemies.includes(enemy)) {
          addBeam(state.player, enemy, type.color);
          killEnemy(enemy, "missile");
        }
      }, 120);
    }
    addRadialShards(state.player.x, state.player.y, type.color, 8, 90);
  }
  if (id === "vortex") {
    state.effects.push({ kind: "vortex", x: state.player.x, y: state.player.y, r: field * 0.48, life: 3.8, maxLife: 3.8, color: type.color });
    addScreenFlash(type.color, 0.06);
  }
  if (id === "shield") {
    state.player.shield = 7.5;
    state.player.invulnerable = Math.max(state.player.invulnerable, 1);
    addRing(state.player.x, state.player.y, type.color, 90, 0.45);
    addRadialShards(state.player.x, state.player.y, type.color, 10, 110);
  }
  if (id === "spikes") {
    state.player.spikes = 6.4;
    addScreenFlash(type.color, 0.06);
    addRadialShards(state.player.x, state.player.y, type.color, 12, 120);
  }
  if (id === "shock") {
    const targets = nearestEnemies(14);
    targets.forEach((enemy, index) => {
      window.setTimeout(() => {
        if (state.mode === "running" && state.enemies.includes(enemy)) {
          killEnemy(enemy, "shock");
          addBeam(index === 0 ? state.player : targets[index - 1], enemy, type.color);
          addBurst(enemy.x, enemy.y, type.color, 6);
        }
      }, index * 45);
    });
    addScreenFlash(type.color, 0.08);
  }
}

function updatePowers(dt) {
  state.activePowers.forEach((power) => {
    power.time -= dt;
  });
  state.activePowers = state.activePowers.filter((power) => power.time > 0).slice(0, 6);

  const vortexes = state.effects.filter((effect) => effect.kind === "vortex");
  vortexes.forEach((vortex) => {
    state.enemies.forEach((enemy) => {
      const dx = vortex.x - enemy.x;
      const dy = vortex.y - enemy.y;
      const d = Math.max(1, Math.hypot(dx, dy));
      if (d < vortex.r) {
        enemy.x += (dx / d) * 155 * dt;
        enemy.y += (dy / d) * 155 * dt;
        if (d < 44) killEnemy(enemy, "vortex");
      }
    });
  });

  if (state.player.spikes > 0) {
    state.enemies.forEach((enemy) => {
      if (distance(enemy, state.player) < 76) killEnemy(enemy, "spikes");
    });
  }
}

function spawnBullet(target, color, speed, damageRadius, size) {
  const angle = Math.atan2(target.y - state.player.y, target.x - state.player.x);
  state.bullets.push({
    x: state.player.x,
    y: state.player.y,
    vx: Math.cos(angle) * speed,
    vy: Math.sin(angle) * speed,
    r: size,
    damageRadius,
    life: 1.45,
    color
  });
}

function updateBullets(dt) {
  state.bullets = state.bullets.filter((bullet) => {
    bullet.x += bullet.vx * dt;
    bullet.y += bullet.vy * dt;
    bullet.life -= dt;
    for (const enemy of state.enemies) {
      if (distance(enemy, bullet) < enemy.r + bullet.r) {
        state.enemies.forEach((other) => {
          if (distance(other, bullet) < bullet.damageRadius + other.r) killEnemy(other, "missile");
        });
        addRing(bullet.x, bullet.y, bullet.color, bullet.damageRadius + 18, 0.28);
        return false;
      }
    }
    return bullet.life > 0;
  });
}

function updateEnemies(dt) {
  const p = state.player;
  state.enemies.forEach((enemy) => {
    enemy.pulse += dt * 8;
    enemy.frozen = Math.max(0, enemy.frozen - dt);
    const speed = enemy.speed * (enemy.frozen > 0 ? 0.28 : 1);
    const angle = Math.atan2(p.y - enemy.y, p.x - enemy.x);
    enemy.vx = Math.cos(angle) * speed;
    enemy.vy = Math.sin(angle) * speed;
    enemy.x += enemy.vx * dt;
    enemy.y += enemy.vy * dt;

    if (distance(enemy, p) < enemy.r + p.r) {
      if (p.shield > 0 || p.invulnerable > 0) {
        killEnemy(enemy, "shield");
        p.invulnerable = Math.max(p.invulnerable, 0.12);
      } else {
        endGame();
      }
    }
  });
  state.enemies = state.enemies.filter((enemy) => !enemy.dead);
}

function killEnemy(enemy, source) {
  if (enemy.dead) return;
  enemy.dead = true;
  const points = Math.round((enemy.elite ? 80 : 15) * state.combo);
  state.score += points;
  state.combo = Math.min(99, state.combo + 0.15 + (enemy.elite ? 0.5 : 0));
  state.maxCombo = Math.max(state.maxCombo, Math.floor(state.combo));
  state.comboTimer = 1.6;
  addBurst(enemy.x, enemy.y, source === "ice" ? "#88dcff" : enemy.elite ? "#ff9f1c" : "#ff3159", enemy.elite ? 18 : 9);
}

function updateEffects(dt) {
  state.effects.forEach((effect) => {
    effect.life -= dt;
    if (effect.kind === "spark") {
      effect.x += effect.vx * dt;
      effect.y += effect.vy * dt;
      effect.vx *= Math.pow(0.82, dt * 60);
      effect.vy *= Math.pow(0.82, dt * 60);
    }
    if (effect.kind === "shard") {
      effect.x += effect.vx * dt;
      effect.y += effect.vy * dt;
      effect.rotation += effect.spin * dt;
      effect.vx *= Math.pow(0.9, dt * 60);
      effect.vy *= Math.pow(0.9, dt * 60);
    }
  });
  state.effects = state.effects.filter((effect) => effect.life > 0);
}

function endGame() {
  state.mode = "over";
  if (state.score > state.best) {
    state.best = state.score;
    localStorage.setItem(storageBest, String(state.best));
    ui.finalTitle.textContent = "Nuevo record";
  } else {
    ui.finalTitle.textContent = "Has caido";
  }
  ui.finalScore.textContent = String(state.score);
  ui.finalCombo.textContent = `x${state.maxCombo}`;
  ui.finalTime.textContent = formatTime(state.elapsed);
  ui.gameOverPanel.hidden = false;
  vibrate(90);
  draw();
}

function pauseGame() {
  if (state.mode !== "running") return;
  state.mode = "paused";
  ui.pausePanel.hidden = false;
  draw();
}

function resumeGame() {
  if (state.mode !== "paused") return;
  state.mode = "running";
  ui.pausePanel.hidden = true;
  state.lastTime = performance.now();
  requestAnimationFrame(loop);
}

window.startTiltArena = startGame;
window.resumeTiltArena = resumeGame;
window.enableTiltArena = enableTilt;

function draw() {
  ctx.clearRect(0, 0, state.width, state.height);
  drawBackground();
  drawArena();
  drawPickups();
  drawBullets();
  drawEnemies();
  drawEffects();
  drawPlayer();
}

function toScreen(entity) {
  return { x: entity.x, y: entity.y };
}

function drawBackground() {
  const gradient = ctx.createLinearGradient(0, 0, state.width, state.height);
  gradient.addColorStop(0, "#e8f5bd");
  gradient.addColorStop(1, "#cfe7a1");
  ctx.fillStyle = gradient;
  ctx.fillRect(0, 0, state.width, state.height);

  ctx.save();
  ctx.globalAlpha = 0.18;
  ctx.strokeStyle = "#9fbe73";
  ctx.lineWidth = 2;
  for (let i = 0; i < 7; i += 1) {
    const x = ((i * 151 + state.elapsed * 5) % (state.width + 180)) - 90;
    const y = ((i * 91 + state.elapsed * 4) % (state.height + 160)) - 80;
    ctx.beginPath();
    ctx.arc(x, y, 30 + (i % 4) * 18, 0, Math.PI * 2);
    ctx.stroke();
  }
  ctx.globalAlpha = 0.14;
  ctx.fillStyle = "#8dac64";
  for (let i = 0; i < 22; i += 1) {
    const x = (i * 79 + state.elapsed * 18) % state.width;
    const y = (i * 41 + state.elapsed * 12) % state.height;
    ctx.beginPath();
    ctx.arc(x, y, 1.5 + (i % 3), 0, Math.PI * 2);
    ctx.fill();
  }
  ctx.restore();
}

function drawArena() {
  ctx.save();
  ctx.strokeStyle = "rgba(31, 45, 20, 0.64)";
  ctx.shadowColor = "transparent";
  ctx.shadowBlur = 0;
  ctx.lineWidth = 2;
  ctx.strokeRect(arena.padding, arena.padding, arena.width - arena.padding * 2, arena.height - arena.padding * 2);
  ctx.restore();
}

function drawPlayer() {
  if (!state.player) return;
  const p = toScreen(state.player);
  const player = state.player;
  ctx.save();
  ctx.translate(p.x, p.y);
  ctx.rotate(player.angle);
  drawArrowShape();
  ctx.restore();

  if (player.shield > 0) {
    drawCircle(p.x, p.y, 30 + Math.sin(state.elapsed * 8) * 2, "rgba(83, 240, 168, 0.08)", "#b8ffd4", 2);
  }
  if (player.spikes > 0) {
    ctx.save();
    ctx.translate(p.x, p.y);
    ctx.rotate(state.elapsed * 9);
    ctx.strokeStyle = "#f7f7ff";
    ctx.lineWidth = 3;
    ctx.shadowColor = "transparent";
    ctx.shadowBlur = 0;
    for (let i = 0; i < 12; i += 1) {
      ctx.rotate(Math.PI / 6);
      ctx.beginPath();
      ctx.moveTo(44, 0);
      ctx.lineTo(70, 0);
      ctx.stroke();
    }
    ctx.restore();
  }
}

function drawEnemies() {
  state.enemies.forEach((enemy) => {
    const p = toScreen(enemy);
    const wobble = Math.sin(enemy.pulse) * 1.8;
    ctx.save();
    ctx.translate(p.x, p.y);
    drawEnemyShape(enemy, wobble);
    ctx.restore();
  });
}

function drawArrowShape() {
  ctx.lineJoin = "round";
  ctx.lineCap = "round";
  ctx.strokeStyle = "#17200e";
  ctx.lineWidth = 3.5;
  ctx.beginPath();
  ctx.moveTo(20, 0);
  ctx.lineTo(-16, -17);
  ctx.lineTo(-6, 0);
  ctx.lineTo(-16, 17);
  ctx.closePath();
  ctx.stroke();
}

function drawEnemyShape(enemy, wobble) {
  const r = enemy.r + wobble;
  const body = enemy.frozen > 0 ? "#8bd1e6" : enemy.elite ? "#e84232" : "#e33132";
  const rim = enemy.frozen > 0 ? "#3e8394" : enemy.elite ? "#8e271f" : "#991f2f";
  ctx.fillStyle = body;
  ctx.beginPath();
  ctx.arc(0, 0, r, 0, Math.PI * 2);
  ctx.fill();
  ctx.strokeStyle = rim;
  ctx.lineWidth = enemy.elite ? 2.5 : 2;
  ctx.stroke();

  ctx.fillStyle = "#fff7e8";
  ctx.beginPath();
  ctx.arc(-r * 0.32, -r * 0.18, Math.max(2, r * 0.2), 0, Math.PI * 2);
  ctx.arc(r * 0.22, -r * 0.2, Math.max(2, r * 0.18), 0, Math.PI * 2);
  ctx.fill();
  ctx.fillStyle = "#1f2d14";
  ctx.beginPath();
  ctx.arc(-r * 0.25, -r * 0.16, Math.max(1.2, r * 0.08), 0, Math.PI * 2);
  ctx.arc(r * 0.28, -r * 0.18, Math.max(1.2, r * 0.08), 0, Math.PI * 2);
  ctx.fill();
}

function drawPickups() {
  state.pickups.forEach((pickup) => {
    const p = toScreen(pickup);
    const pulse = 1 + Math.sin((pickup.age + state.elapsed) * 7) * 0.12;
    ctx.save();
    ctx.translate(p.x, p.y);
    ctx.rotate(state.elapsed * 2.2);
    ctx.shadowColor = "transparent";
    ctx.shadowBlur = 0;
    const image = assets[pickup.id] || assets.pickup;
    const size = pickup.r * 2.1 * pulse;
    if (image.complete) {
      ctx.drawImage(image, -size / 2, -size / 2, size, size);
    } else {
      ctx.fillStyle = "#fff9e9";
      ctx.beginPath();
      for (let i = 0; i < 4; i += 1) {
        const angle = (Math.PI * 2 * i) / 4 + Math.PI / 4;
        const radius = pickup.r * 0.86 * pulse;
        ctx.lineTo(Math.cos(angle) * radius, Math.sin(angle) * radius);
      }
      ctx.closePath();
      ctx.fill();
      ctx.strokeStyle = "#1f2d14";
      ctx.lineWidth = 2;
      ctx.stroke();
    }
    ctx.restore();
  });
}

function drawBullets() {
  state.bullets.forEach((bullet) => {
    const p = toScreen(bullet);
    ctx.save();
    ctx.translate(p.x, p.y);
    ctx.rotate(Math.atan2(bullet.vy, bullet.vx));
    ctx.shadowColor = bullet.color;
    ctx.shadowBlur = 18;
    ctx.fillStyle = bullet.color;
    ctx.beginPath();
    ctx.ellipse(0, 0, bullet.r * 1.5, bullet.r * 0.72, 0, 0, Math.PI * 2);
    ctx.fill();
    ctx.restore();
  });
}

function drawEffects() {
  state.effects.forEach((effect) => {
    const alpha = Math.max(0, effect.life / effect.maxLife);
    const p = toScreen(effect);
    ctx.save();
    ctx.globalAlpha = alpha;
    if (effect.kind === "flash") {
      ctx.fillStyle = effect.color;
      ctx.globalAlpha = alpha * effect.strength * 0.55;
      ctx.fillRect(0, 0, state.width, state.height);
    }
    if (effect.kind === "spark") {
      ctx.fillStyle = effect.color;
      ctx.beginPath();
      ctx.arc(p.x, p.y, effect.r * alpha, 0, Math.PI * 2);
      ctx.fill();
    }
    if (effect.kind === "shard") {
      ctx.translate(p.x, p.y);
      ctx.rotate(effect.rotation);
      ctx.fillStyle = effect.color;
      ctx.strokeStyle = "#1f2d14";
      ctx.lineWidth = 1;
      ctx.beginPath();
      ctx.moveTo(effect.size * 1.2, 0);
      ctx.lineTo(-effect.size * 0.8, -effect.size * 0.42);
      ctx.lineTo(-effect.size * 0.35, 0);
      ctx.lineTo(-effect.size * 0.8, effect.size * 0.42);
      ctx.closePath();
      ctx.fill();
      ctx.stroke();
    }
    if (effect.kind === "ring") {
      ctx.strokeStyle = effect.color;
      ctx.lineWidth = 2 + alpha * 2;
      ctx.beginPath();
      ctx.arc(p.x, p.y, effect.r * (1 - alpha * 0.35), 0, Math.PI * 2);
      ctx.stroke();
    }
    if (effect.kind === "beam") {
      const b = toScreen({ x: effect.x2, y: effect.y2 });
      ctx.strokeStyle = effect.color;
      ctx.lineWidth = 3;
      ctx.beginPath();
      ctx.moveTo(p.x, p.y);
      const midX = (p.x + b.x) / 2 + Math.sin(effect.life * 80) * 18;
      const midY = (p.y + b.y) / 2 + Math.cos(effect.life * 80) * 18;
      ctx.quadraticCurveTo(midX, midY, b.x, b.y);
      ctx.stroke();
    }
    if (effect.kind === "vortex") {
      ctx.strokeStyle = effect.color;
      ctx.lineWidth = 2.4;
      ctx.translate(p.x, p.y);
      ctx.rotate((1 - alpha) * 8);
      for (let i = 0; i < 3; i += 1) {
        ctx.beginPath();
        ctx.arc(0, 0, effect.r * (0.16 + i * 0.12) * alpha, i * 0.7, i * 0.7 + Math.PI * 1.45);
        ctx.stroke();
      }
    }
    ctx.restore();
  });
}

function drawCircle(x, y, r, fill, stroke, lineWidth) {
  ctx.save();
  ctx.fillStyle = fill;
  ctx.strokeStyle = stroke;
  ctx.lineWidth = lineWidth;
  ctx.shadowColor = stroke;
  ctx.shadowBlur = 14;
  ctx.beginPath();
  ctx.arc(x, y, r, 0, Math.PI * 2);
  ctx.fill();
  ctx.stroke();
  ctx.restore();
}

function addBurst(x, y, color, amount) {
  const room = Math.max(0, perf.maxEffects - state.effects.length);
  amount = Math.min(amount, room);
  for (let i = 0; i < amount; i += 1) {
    const angle = Math.random() * Math.PI * 2;
    const speed = random(80, 260);
    state.effects.push({
      kind: "spark",
      x,
      y,
      vx: Math.cos(angle) * speed,
      vy: Math.sin(angle) * speed,
      r: random(5, 11),
      life: random(0.25, 0.55),
      maxLife: 0.55,
      color
    });
  }
}

function addRing(x, y, color, r, life) {
  if (state.effects.length >= perf.maxEffects) return;
  state.effects.push({ kind: "ring", x, y, r, life, maxLife: life, color });
}

function addBeam(from, to, color) {
  if (state.effects.length >= perf.maxEffects) return;
  state.effects.push({ kind: "beam", x: from.x, y: from.y, x2: to.x, y2: to.y, life: 0.18, maxLife: 0.18, color });
}

function addScreenFlash(color, strength) {
  if (state.effects.length >= perf.maxEffects) return;
  state.effects.push({ kind: "flash", x: 0, y: 0, life: 0.32, maxLife: 0.32, color, strength });
}

function addRadialShards(x, y, color, amount, speed) {
  const room = Math.max(0, perf.maxEffects - state.effects.length);
  amount = Math.min(amount, room);
  for (let i = 0; i < amount; i += 1) {
    const angle = (Math.PI * 2 * i) / amount + random(-0.12, 0.12);
    const velocity = random(speed * 0.45, speed);
    state.effects.push({
      kind: "shard",
      x,
      y,
      vx: Math.cos(angle) * velocity,
      vy: Math.sin(angle) * velocity,
      rotation: angle,
      spin: random(-8, 8),
      size: random(7, 16),
      life: random(0.42, 0.9),
      maxLife: 0.9,
      color
    });
  }
}

function nearestEnemies(amount) {
  return [...state.enemies]
    .filter((enemy) => !enemy.dead)
    .sort((a, b) => distance(a, state.player) - distance(b, state.player))
    .slice(0, amount);
}

function updateHud(force = false) {
  const next = {
    score: String(state.score),
    combo: `x${Math.max(1, Math.floor(state.combo))}`,
    time: formatTime(state.elapsed),
    best: String(state.best),
    control: state.tilt.enabled ? "Inclinacion activa" : "Teclado / raton",
    powers: state.activePowers
      .map((power) => `${power.id}:${Math.ceil(power.time * 10) / 10}`)
      .join("|")
  };

  if (force || next.score !== state.hudCache.score) ui.scoreText.textContent = next.score;
  if (force || next.combo !== state.hudCache.combo) ui.comboText.textContent = next.combo;
  if (force || next.time !== state.hudCache.time) ui.timeText.textContent = next.time;
  if (force || next.best !== state.hudCache.best) ui.bestText.textContent = next.best;
  if (force || next.control !== state.hudCache.control) ui.controlText.textContent = next.control;

  if (force || next.powers !== state.hudCache.powers) {
    ui.powerBar.replaceChildren();
    state.activePowers.forEach((power) => {
      const item = document.createElement("span");
      item.style.borderColor = `${power.color}66`;
      item.innerHTML = `<img src="${assetSources[power.id]}" alt="" />${power.label} ${power.time.toFixed(1)}s`;
      ui.powerBar.append(item);
    });
  }

  state.hudCache = next;
}

function resize() {
  const rect = canvas.getBoundingClientRect();
  state.dpr = Math.min(window.devicePixelRatio || 1, perf.maxDpr);
  state.width = rect.width;
  state.height = rect.height;
  arena.width = state.width;
  arena.height = state.height;
  arena.padding = Math.max(10, Math.min(18, Math.round(Math.min(state.width, state.height) * 0.025)));
  canvas.width = Math.round(rect.width * state.dpr);
  canvas.height = Math.round(rect.height * state.dpr);
  ctx.setTransform(state.dpr, 0, 0, state.dpr, 0, 0);
  if (!state.player) resetGame();
  else {
    state.player.x = clamp(state.player.x, arena.padding + state.player.r, arena.width - arena.padding - state.player.r);
    state.player.y = clamp(state.player.y, arena.padding + state.player.r, arena.height - arena.padding - state.player.r);
  }
  draw();
}

async function enableTilt() {
  try {
    const DeviceOrientation = window.DeviceOrientationEvent;
    if (DeviceOrientation?.requestPermission) {
      const permission = await DeviceOrientation.requestPermission();
      if (permission !== "granted") return;
    }
    state.tilt.enabled = true;
    state.tilt.calibrated = false;
    ui.tiltButton.textContent = "Inclinacion activa";
    vibrate(20);
  } catch {
    state.tilt.enabled = false;
    ui.tiltButton.textContent = "Sin permiso de inclinacion";
  }
}

function setPointer(clientX, clientY) {
  const rect = ui.tiltPad.getBoundingClientRect();
  const cx = rect.left + rect.width / 2;
  const cy = rect.top + rect.height / 2;
  const dx = clientX - cx;
  const dy = clientY - cy;
  const max = rect.width * 0.34;
  const dist = Math.min(max, Math.hypot(dx, dy));
  const angle = Math.atan2(dy, dx);
  state.pointer.x = Math.cos(angle) * (dist / max);
  state.pointer.y = Math.sin(angle) * (dist / max);
  ui.tiltStick.style.transform = `translate(${Math.cos(angle) * dist}px, ${Math.sin(angle) * dist}px)`;
}

function releasePointer() {
  state.pointer.active = false;
  state.pointer.id = null;
  state.pointer.x = 0;
  state.pointer.y = 0;
  ui.tiltStick.style.transform = "translate(0, 0)";
}

function formatTime(seconds) {
  const minutes = Math.floor(seconds / 60);
  const rest = Math.floor(seconds % 60).toString().padStart(2, "0");
  return `${String(minutes).padStart(2, "0")}:${rest}`;
}

function clamp(value, min, max) {
  return Math.min(max, Math.max(min, value));
}

function random(min, max) {
  return min + Math.random() * (max - min);
}

function distance(a, b) {
  return Math.hypot(a.x - b.x, a.y - b.y);
}

function vibrate(ms) {
  if (navigator.vibrate) navigator.vibrate(ms);
}

window.addEventListener("resize", resize);
window.addEventListener("keydown", (event) => {
  const key = event.key.toLowerCase();
  state.keys.add(key);
  if (key === " " && state.mode === "running") pauseGame();
  if (key === " " && state.mode === "paused") resumeGame();
});
window.addEventListener("keyup", (event) => state.keys.delete(event.key.toLowerCase()));
window.addEventListener("deviceorientation", (event) => {
  if (!state.tilt.enabled) return;
  if (!state.tilt.calibrated) {
    state.tilt.beta0 = event.beta || 0;
    state.tilt.gamma0 = event.gamma || 0;
    state.tilt.calibrated = true;
  }
  const gamma = (event.gamma || 0) - state.tilt.gamma0;
  const beta = (event.beta || 0) - state.tilt.beta0;
  state.tilt.x = clamp(gamma / 18, -1, 1);
  state.tilt.y = clamp(beta / 18, -1, 1);
});

ui.startButton.addEventListener("click", startGame);
ui.startButton.addEventListener("pointerup", startGame);
ui.restartButton.addEventListener("click", startGame);
ui.restartButton.addEventListener("pointerup", startGame);
ui.newRunButton.addEventListener("click", startGame);
ui.newRunButton.addEventListener("pointerup", startGame);
ui.pauseButton.addEventListener("click", () => (state.mode === "paused" ? resumeGame() : pauseGame()));
ui.resumeButton.addEventListener("click", resumeGame);
ui.resumeButton.addEventListener("pointerup", resumeGame);
ui.tiltButton.addEventListener("click", enableTilt);

ui.tiltPad.addEventListener("pointerdown", (event) => {
  ui.tiltPad.setPointerCapture(event.pointerId);
  state.pointer.active = true;
  state.pointer.id = event.pointerId;
  setPointer(event.clientX, event.clientY);
});
ui.tiltPad.addEventListener("pointermove", (event) => {
  if (!state.pointer.active || state.pointer.id !== event.pointerId) return;
  setPointer(event.clientX, event.clientY);
});
ui.tiltPad.addEventListener("pointerup", releasePointer);
ui.tiltPad.addEventListener("pointercancel", releasePointer);

resize();
resetGame();
if (window.__tiltArenaPendingStart) startGame();
