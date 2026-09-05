/* Krazel Games. Original simulation, shared by JavaScriptCore and Node tests.
 * The calibration/radii/timings are tuning values, not extracted original code.
 * World: 960 x 640, Y up. Fixed camera. See research/REFERENCE.md.
 */
(function (root) {
  'use strict';
  const TAU = Math.PI * 2;
  const clamp = (n, a, b) => Math.max(a, Math.min(b, n));
  const length = (x, y) => Math.hypot(x, y);
  const distance = (a, b) => length(a.x - b.x, a.y - b.y);
  const BOUNDS = Object.freeze({left: 24, right: 936, bottom: 52, top: 592});
  const TUNING = Object.freeze({step: 1 / 120, speed: 440, response: 22,
    playerRadius: 7, dotRadius: 7, comboWindow: 2.5, telegraph: 0.8,
    maxEnemies: 550, maxPickups: 5, pickupLife: 12, spawnClearance: 105});
  const POWERS = ['nuke', 'wave', 'missiles', 'frost', 'bubble', 'spikes', 'vortex', 'lightning', 'burn'];
  const COLORS = {nuke:'#ffb52a',wave:'#ba71ee',missiles:'#f7e36b',frost:'#70dce9',
    bubble:'#7bde83',spikes:'#6c9ce8',vortex:'#ee77bc',lightning:'#eeefff',burn:'#ff784c'};
  function swept(a, b, c, radius) {
    const dx = b.x - a.x, dy = b.y - a.y;
    const d = dx * dx + dy * dy;
    const t = d ? clamp(((c.x - a.x) * dx + (c.y - a.y) * dy) / d, 0, 1) : 0;
    return length(a.x + t * dx - c.x, a.y + t * dy - c.y) <= radius;
  }
  class RNG {
    constructor(seed) { this.state = (seed >>> 0) || 1; }
    next() {
      let x = this.state;
      x ^= x << 13; x ^= x >>> 17; x ^= x << 5;
      this.state = x >>> 0;
      return this.state / 4294967296;
    }
    range(a,b) { return a + (b-a) * this.next(); }
    pick(items) { return items[Math.floor(this.next()*items.length)]; }
  }
  // Device gravity is in portrait axes; screen-up is device +/-X in landscape.
  // Subtraction of a sampled neutral removes the user's comfortable holding angle.
  function tiltInput(gravity, neutral, orientation, sensitivity) {
    // UIInterfaceOrientation (not UIDeviceOrientation): Home-left means +deviceY
    // points screen-right, +deviceX points screen-down. Apple docs: research/REFERENCE.md.
    const sign = orientation === 'landscapeRight' ? 1 : -1;
    let x = -(gravity.y - neutral.y) * sign;
    let y = (gravity.x - neutral.x) * sign;
    const magnitude = length(x,y), dead = 0.018;
    if (magnitude <= dead) return {x:0,y:0};
    const strength = clamp((magnitude-dead) / 0.38 * sensitivity,0,1);
    return {x:x/magnitude*strength, y:y/magnitude*strength};
  }
  class ClassicGame {
    constructor(seed, options) {
      this.rng = new RNG(seed);
      this.options = options || {};
      this.powers = this.options.powers || POWERS;
      if (!this.powers.length || this.powers.some(p=>!POWERS.includes(p))) throw Error('Invalid arsenal');
      this.id = 0; this.time = 0; this.accumulator = 0;
      this.state = 'running'; this.score = 0; this.combo = 0; this.bestCombo = 0;
      this.comboUntil = 0; this.kills = 0;
      this.player = {x:480,y:320,vx:0,vy:0,angle:Math.PI/2,bubble:false,spikesUntil:0,burnUntil:0};
      this.enemies = []; this.pickups = []; this.projectiles = []; this.fields = [];
      this.events = []; this.spawnAt = 1; this.patternAt = 12; this.pickupAt = 3;
      this.waveAt = []; this.trailAt = 0;
      if (this.options.spawning !== false) {
        this.addPickup('nuke', 260, 310);
        this.addPickup('missiles', 700, 330);
      }
    }
    event(kind, data) { this.events.push(Object.assign({kind}, data)); }
    pause() { if(this.state === 'running') { this.state='paused'; this.accumulator=0; } }
    resume() { if(this.state === 'paused') { this.state='running'; this.accumulator=0; } }
    advance(dt, input) {
      this.events = [];
      if(this.state !== 'running') return this.snapshot();
      // A stall cannot advance a dangerous burst of game time when foregrounding.
      this.accumulator += clamp(Number.isFinite(dt) ? dt : 0, 0, 0.1);
      while(this.accumulator + 1e-10 >= TUNING.step && this.state === 'running') {
        this.step(TUNING.step,input || {x:0,y:0});
        this.accumulator -= TUNING.step;
      }
      return this.snapshot();
    }
    step(dt, input) {
      this.time += dt;
      if(this.combo && this.time >= this.comboUntil) this.bankCombo();
      const p = this.player, before = {x:p.x,y:p.y};
      let ix = Number.isFinite(input.x)?input.x:0, iy = Number.isFinite(input.y)?input.y:0;
      const mag = Math.max(1,length(ix,iy)); ix/=mag; iy/=mag;
      const response = 1 - Math.exp(-TUNING.response*dt);
      const boost = p.burnUntil>this.time ? 1.5 : 1;
      p.vx += (ix*TUNING.speed*boost-p.vx)*response;
      p.vy += (iy*TUNING.speed*boost-p.vy)*response;
      p.x = clamp(p.x+p.vx*dt,BOUNDS.left+7,BOUNDS.right-7);
      p.y = clamp(p.y+p.vy*dt,BOUNDS.bottom+7,BOUNDS.top-7);
      if (length(p.vx,p.vy)>8) p.angle = Math.atan2(p.vy,p.vx);
      if (this.options.spawning !== false) this.spawnDirector();
      for(const orb of this.pickups) {
        if(!orb.dead && orb.until>this.time && swept(before,p,orb,23)) {
          orb.dead = true;
          this.activate(orb.power,{x:orb.x,y:orb.y});
        }
      }
      for(const wave of this.waveAt) if(!wave.dead && this.time>=wave.at) {
        wave.dead=true;
        this.projectiles.push({id:++this.id,kind:'wave',x:p.x,y:p.y,
          vx:Math.cos(p.angle)*580,vy:Math.sin(p.angle)*580,angle:p.angle,radius:48,until:this.time+1.8});
        this.event('wave',{x:p.x,y:p.y,angle:p.angle,color:COLORS.wave});
      }
      this.waveAt = this.waveAt.filter(w=>!w.dead);
      this.updateFields(dt);
      this.updateProjectiles(dt);
      for(const e of this.enemies) {
        if(e.dead || this.time<e.activeAt) continue;
        const old = {x:e.x,y:e.y}, frozen = e.frozenUntil>this.time;
        if(!frozen) {
          if(e.formationUntil>this.time) {e.x+=e.vx*dt;e.y+=e.vy*dt;}
          else {
            const d=Math.max(1,distance(e,p));
            e.x+=(p.x-e.x)/d*e.speed*dt;e.y+=(p.y-e.y)/d*e.speed*dt;
          }
          e.x=clamp(e.x,BOUNDS.left+7,BOUNDS.right-7);
          e.y=clamp(e.y,BOUNDS.bottom+7,BOUNDS.top-7);
        }
        // Relative swept collision includes the dot's movement as well as the arrow's.
        const relativeEnd={x:p.x-(e.x-old.x),y:p.y-(e.y-old.y)};
        const armored = p.spikesUntil>this.time || p.burnUntil>this.time;
        if(swept(before,relativeEnd,old,armored?35:14)) {
          if(frozen || armored) this.kill(e, frozen?'ice':'dot');
          else if(p.bubble) {
            p.bubble=false;
            this.blast(p,130,'bubble');
          } else { this.die(); break; }
        }
      }
      this.enemies=this.enemies.filter(e=>!e.dead);
      this.pickups=this.pickups.filter(o=>!o.dead && o.until>this.time);
      this.projectiles=this.projectiles.filter(o=>!o.dead && o.until>this.time);
      this.fields=this.fields.filter(o=>o.until>this.time);
    }
    bankCombo() {
      if(!this.combo) return;
      const bonus=6*this.combo*this.combo;
      this.score+=bonus;
      this.event('combo',{value:this.combo,bonus,x:480,y:70});
      this.combo=0;this.comboUntil=0;
    }
    kill(e,style) {
      if(e.dead || this.time<e.activeAt) return;
      e.dead=true;this.kills++;this.score+=10;this.combo++;
      this.bestCombo=Math.max(this.bestCombo,this.combo);
      this.comboUntil=this.time+TUNING.comboWindow;
      this.event('kill',{x:e.x,y:e.y,color:style==='ice'?COLORS.frost:'#ff5658'});
    }
    die() {
      if(this.state!=='running')return;
      this.bankCombo();this.state='gameOver';
      this.event('death',{x:this.player.x,y:this.player.y});
    }
    addEnemy(x,y,options) {
      const o=options||{};
      const e=Object.assign({id:++this.id,x,y,speed:49+Math.min(60,this.time*0.23),
        activeAt:this.time+TUNING.telegraph,frozenUntil:0,vx:0,vy:0,formationUntil:0,dead:false},o);
      this.enemies.push(e);return e;
    }
    addPickup(power,x,y) {
      const o={id:++this.id,power,x,y,until:this.time+TUNING.pickupLife,dead:false};
      this.pickups.push(o);return o;
    }
    spawnDirector() {
      if(this.time>=this.spawnAt) {
        const n=2+Math.floor(Math.min(12,this.time/12));
        for(let i=0;i<n && this.enemies.length<TUNING.maxEnemies;i++) {
          const edge=Math.floor(this.rng.next()*4);
          let x=this.rng.range(40,920),y=this.rng.range(68,576);
          if(this.rng.next()<0.8) {
            if(edge===0)x=40;if(edge===1)x=920;if(edge===2)y=68;if(edge===3)y=576;
          }
          if(distance({x,y},this.player)>TUNING.spawnClearance) this.addEnemy(x,y);
        }
        this.spawnAt=this.time+Math.max(0.48,1.6-this.time*0.006);
      }
      if(this.time>=this.patternAt) {
        this.spawnPattern(this.rng.pick(['line','arrow','ring']));
        this.patternAt=this.time+Math.max(5,12-this.time*0.025);
      }
      if(this.time>=this.pickupAt) {
        if(this.pickups.length<TUNING.maxPickups) {
          for(let attempt=0;attempt<20;attempt++) {
            const x=this.rng.range(90,870),y=this.rng.range(110,534);
            if(distance({x,y},this.player)>85 && this.pickups.every(o=>distance({x,y},o)>65)) {
              this.addPickup(this.rng.pick(this.powers),x,y);break;
            }
          }
        }
        this.pickupAt=this.time+this.rng.range(2.2,3.4);
      }
    }
    spawnPattern(kind) {
      const right=this.rng.next()<0.5;
      const cx=right?850:110,cy=this.rng.range(210,430);
      const a=Math.atan2(this.player.y-cy,this.player.x-cx);
      const points=[];
      if(kind==='line') {
        for(let i=0;i<19;i++)points.push({x:right?902:58,y:96+i*25});
      } else if(kind==='arrow') {
        for(let i=0;i<7;i++)for(const side of (i===0?[1]:[-1,1])) {
          const dx=-i*18,dy=i*side*12;
          points.push({x:cx+dx*Math.cos(a)-dy*Math.sin(a),y:cy+dx*Math.sin(a)+dy*Math.cos(a)});
        }
      } else {
        for(let i=0;i<20;i++)points.push({x:cx+Math.cos(i/20*TAU)*70,y:cy+Math.sin(i/20*TAU)*70});
      }
      for(const point of points) {
        if(this.enemies.length>=TUNING.maxEnemies)break;
        if(distance(point,this.player)<TUNING.spawnClearance)continue;
        this.addEnemy(clamp(point.x,40,920),clamp(point.y,68,576),{
          formationUntil:this.time+TUNING.telegraph+2.6,
          vx:kind==='line'?(right?-68:68):Math.cos(a)*90,
          vy:kind==='line'?0:Math.sin(a)*90});
      }
      this.event('pattern',{pattern:kind});
    }
    blast(point,radius,power) {
      for(const e of this.enemies)if(distance(point,e)<=radius)this.kill(e,'dot');
      this.event('blast',{x:point.x,y:point.y,radius,color:COLORS[power]});
    }
    activate(power,point) {
      const p=this.player,at=point||p;
      // Pickup points, like timing, remain provisional; combo is the dominant reward.
      const points={nuke:3,wave:5,missiles:10,frost:10,bubble:10,spikes:10,vortex:10,lightning:6,burn:2000};
      this.score+=points[power]||0;
      this.event('pickup',{power,x:at.x,y:at.y,color:COLORS[power]});
      switch(power) {
      case 'nuke':this.blast(at,155,power);break;
      case 'wave':this.waveAt.push({at:this.time+0.22});break;
      case 'missiles':
        for(let i=0;i<5;i++) {
          const a=p.angle+(i-2)*0.7;
          this.projectiles.push({id:++this.id,kind:'missile',x:p.x,y:p.y,
            vx:Math.cos(a)*285,vy:Math.sin(a)*285,angle:a,radius:5,until:this.time+3.2,target:null});
        }break;
      case 'frost':
        for(const e of this.enemies)if(!e.dead && this.time>=e.activeAt && distance(at,e)<205)e.frozenUntil=this.time+4;
        this.event('freeze',{x:at.x,y:at.y,radius:205,color:COLORS.frost});break;
      case 'bubble':p.bubble=true;break;
      case 'spikes':p.spikesUntil=this.time+5;break;
      case 'vortex':this.fields.push({id:++this.id,kind:'vortex',x:at.x,y:at.y,until:this.time+4,radius:200});break;
      case 'lightning': {
        // Flood fill by actual adjacency; no arbitrary list of nearest targets.
        const queue=[{x:p.x,y:p.y}],visited=new Set();
        while(queue.length) {
          const from=queue.shift();
          for(const e of this.enemies)if(!e.dead && this.time>=e.activeAt && !visited.has(e.id) && distance(from,e)<90) {
            visited.add(e.id);queue.push(e);this.kill(e,'dot');
            this.event('lightning',{x:from.x,y:from.y,toX:e.x,toY:e.y,color:COLORS.lightning});
          }
        }break;
      }
      case 'burn':p.burnUntil=this.time+1.5;break;
      }
    }
    updateFields(dt) {
      const p=this.player;
      if(p.burnUntil>this.time && this.time>=this.trailAt) {
        this.fields.push({id:++this.id,kind:'fire',x:p.x,y:p.y,radius:22,until:this.time+3.2});
        this.trailAt=this.time+0.055;
      }
      for(const f of this.fields)if(f.until>this.time) {
        if(f.kind==='fire') {
          for(const e of this.enemies)if(!e.dead&&distance(e,f)<f.radius+7)this.kill(e,'dot');
        } else {
          for(const e of this.enemies)if(!e.dead&&this.time>=e.activeAt) {
            const d=Math.max(1,distance(e,f));
            if(d<f.radius && e.frozenUntil<=this.time) {
              const pull=(1-d/f.radius)*300;
              e.x+=(f.x-e.x)/d*pull*dt;e.y+=(f.y-e.y)/d*pull*dt;
              if(distance(e,f)<20)this.kill(e,'dot');
            }
          }
          for(const o of this.pickups)if(!o.dead) {
            const d=Math.max(1,distance(o,f));
            if(d<f.radius) {
              o.x+=(f.x-o.x)/d*Math.min(d,85*dt);
              o.y+=(f.y-o.y)/d*Math.min(d,85*dt);
            }
          }
        }
      }
    }
    updateProjectiles(dt) {
      for(const m of this.projectiles) {
        if(m.dead||m.until<=this.time)continue;
        const before={x:m.x,y:m.y};
        if(m.kind==='missile') {
          let target=this.enemies.find(e=>e.id===m.target&&!e.dead&&this.time>=e.activeAt);
          if(!target) {
            let best=Infinity;
            const assigned=new Set(this.projectiles.filter(o=>o!==m&&!o.dead).map(o=>o.target));
            for(const e of this.enemies)if(!e.dead&&this.time>=e.activeAt) {
              const rank=distance(m,e)+(assigned.has(e.id)?250:0);
              if(rank<best){best=rank;target=e;}
            }
            m.target=target?target.id:null;
          }
          if(target) {
            const angle=Math.atan2(target.y-m.y,target.x-m.x);
            const delta=Math.atan2(Math.sin(angle-m.angle),Math.cos(angle-m.angle));
            m.angle+=clamp(delta,-8*dt,8*dt);
            m.vx=Math.cos(m.angle)*330;m.vy=Math.sin(m.angle)*330;
          }
        }
        m.x+=m.vx*dt;m.y+=m.vy*dt;
        for(const e of this.enemies)if(!e.dead&&this.time>=e.activeAt) {
          let hit=false;
          if(m.kind==='wave') {
            // A wide front perpendicular to travel, not an all-direction radial bomb.
            const dx=e.x-m.x,dy=e.y-m.y;
            const along=dx*Math.cos(m.angle)+dy*Math.sin(m.angle);
            const across=-dx*Math.sin(m.angle)+dy*Math.cos(m.angle);
            hit=Math.abs(along)<16 && Math.abs(across)<m.radius+7;
          } else hit=swept(before,m,e,12);
          if(hit) {
            if(m.kind==='missile') {this.blast(e,32,'missiles');m.dead=true;break;}
            this.kill(e,'dot');
          }
        }
      }
    }
    snapshot() {
      return {state:this.state,time:this.time,score:this.score,combo:this.combo,
        comboBase:6*this.combo,pendingBonus:6*this.combo*this.combo,
        comboRemaining:Math.max(0,this.comboUntil-this.time)/TUNING.comboWindow,
        bestCombo:this.bestCombo,kills:this.kills,player:Object.assign({},this.player),
        enemies:this.enemies.map(e=>({id:e.id,x:e.x,y:e.y,telegraph:this.time<e.activeAt,
          frozen:this.time<e.frozenUntil,thawing:e.frozenUntil>this.time&&e.frozenUntil-this.time<1})),
        pickups:this.pickups.map(o=>({id:o.id,x:o.x,y:o.y,power:o.power,remaining:o.until-this.time})),
        projectiles:this.projectiles.map(o=>({id:o.id,x:o.x,y:o.y,kind:o.kind,angle:o.angle})),
        fields:this.fields.map(f=>({id:f.id,x:f.x,y:f.y,kind:f.kind,remaining:f.until-this.time})),
        events:this.events.slice()};
    }
  }
  let game=null;
  const API={create(seed){game=new ClassicGame(seed);return JSON.stringify(game.snapshot());},
    tick(dt,x,y){return JSON.stringify(game.advance(dt,{x,y}));},
    pause(){game.pause();},resume(){game.resume();},
    finish(){game.resume();game.die();return JSON.stringify(game.snapshot());},
    tilt(gx,gy,nx,ny,orientation,sensitivity){return tiltInput({x:gx,y:gy},{x:nx,y:ny},orientation,sensitivity);}};
  root.ClassicAPI=API;
  if(root.CLASSIC_DIAGNOSTICS===true)root.ClassicDiagnostics={ClassicGame,POWERS,COLORS};
  if(typeof module!=='undefined'&&module.exports)module.exports={ClassicGame,RNG,TUNING,BOUNDS,POWERS,COLORS,swept,tiltInput};
})(typeof globalThis!=='undefined'?globalThis:this);
