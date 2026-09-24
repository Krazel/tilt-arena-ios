// Mirrors the approved native cue policy; no unapproved fallback effects.
export function soundCues(events, boomerangCharging=false) {
  const cues=[];
  for(const e of events){
    if(e.kind==='pickup'){cues.push('pickup');if(['burn','boomerang'].includes(e.power))cues.push(e.power+'-charge');if(['missiles','bubble','spikes'].includes(e.power))cues.push(e.power);}
    if(e.kind==='blast'&&e.power==='nuke')cues.push('nuke');
    if(e.kind==='freeze')cues.push('frost');
    if(e.kind==='wave')cues.push('wave');
    if(e.kind==='kill')cues.push(e.frozen||e.color==='#70dce9'?'shatter':'hit');
    if(e.kind==='electricPulse')cues.push('lightning');
    if(e.kind==='burnLaunch')cues.push('burn-launch');
    if(e.kind==='boomerangLaunch')cues.push('boomerang-launch');
    if(e.kind==='boomerangBounce')cues.push('bounce');
    if(e.kind==='boomerangCatch'){cues.push('pickup');if(boomerangCharging)cues.push('boomerang-charge');}
  }
  return [...new Set(cues)];
}
export class GameSound {
  constructor(catalog, makeAudio=file=>new Audio('/'+file), now=()=>performance.now()/1000){
    this.catalog=catalog;this.now=now;this.players={};this.mode='menu';this.muted=true;this.suspended=false;
    this.track=-1;this.current=null;this.last={};this.paused=new Set();this.shatter=0;this.lastFrame=null;this.vortex=false;this.laser=0;this.lastHealth=-100;
    for(const [name,a] of Object.entries(catalog.assets)){const p=makeAudio(a.file);p.preload='auto';p.volume=a.volume;p.loop=name===catalog.menu||['vortex','laser'].includes(name);this.players[name]=p;
      p.addEventListener('ended',()=>{if(this.mode==='game'&&this.current===name){this.advanceTrack();this.players[this.current].currentTime=0;this.music();}});}
  }
  get audible(){return !this.muted&&!this.suspended;}
  playPlayer(name){this.players[name]?.play().catch(()=>{});}
  advanceTrack(){this.track=(this.track+1)%this.catalog.playlist.length;this.current=this.catalog.playlist[this.track];}
  music(){const wanted=this.mode==='menu'?this.catalog.menu:this.mode==='game'?this.current:null;for(const [n,p] of Object.entries(this.players))if(n.startsWith('music')){if(this.audible&&n===wanted){if(p.paused)this.playPlayer(n);}else p.pause();}}
  clearEffects(){for(const [n,p]of Object.entries(this.players))if(!n.startsWith('music')&&n!=='ui'){p.pause();p.currentTime=0;}this.paused.clear();}
  setMuted(value){this.muted=value;if(value){Object.values(this.players).forEach(p=>p.pause());this.clearEffects();}else{this.music();this.refreshVortex();}}
  setSuspended(value){this.suspended=value;if(value)Object.values(this.players).forEach(p=>p.pause());else{this.music();this.refreshVortex();}}
  startRun(){this.clearEffects();this.last={};this.lastFrame=null;this.vortex=false;this.laser=0;this.lastHealth=-100;this.advanceTrack();this.players[this.current].currentTime=0;this.mode='game';this.music();}
  setMode(next){const prev=this.mode;this.mode=next;if(next!=='game'){if(next==='paused'){for(const [n,p]of Object.entries(this.players))if(!n.startsWith('music')&&n!=='ui'&&!p.paused){this.paused.add(n);p.pause();}}else{this.clearEffects();this.vortex=false;this.laser=0;this.lastHealth=-100;}}else if(prev==='paused'&&this.audible){for(const n of this.paused)this.playPlayer(n);this.paused.clear();}this.music();this.refreshVortex();}
  refreshLaser(){const p=this.players.laser;if(!p)return;if(this.audible&&this.mode==='game'&&this.laser>0){p.volume=this.catalog.assets.laser.volume*Math.min(1,this.laser/.12);if(p.paused)this.playPlayer('laser');}else{p.pause();if(!this.laser)p.currentTime=0;}}
  refreshVortex(){this.refreshLaser();const p=this.players.vortex;if(this.audible&&this.mode==='game'&&this.vortex){if(p.paused)this.playPlayer('vortex');}else{p.pause();if(!this.vortex)p.currentTime=0;}}
  uiClick(){this.music();this.refreshVortex();this.play('ui');}
  play(cue){if(!this.audible||(cue!=='ui'&&this.mode!=='game'))return;const now=this.now(),gap=['hit','shatter'].includes(cue)?.07:cue==='bounce'?.05:.015;if(now-(this.last[cue]??-100)<gap)return;this.last[cue]=now;let name=cue;if(cue==='shatter')name=this.shatter++%2?'shatter-b':'shatter-a';if(cue.endsWith('-launch'))this.players[cue.replace('-launch','-charge')]?.pause();const p=this.players[name];if(p){p.currentTime=0;this.playPlayer(name);}}
  consume(frame){if(this.mode!=='game'||!['running','gameOver'].includes(frame.state)||frame.time===this.lastFrame)return;this.lastFrame=frame.time;this.laser=frame.state==='running'?(frame.player.laserRemaining||0):0;if(this.now()-this.lastHealth>=1){this.lastHealth=this.now();this.music();}this.vortex=frame.fields.some(f=>f.kind==='vortex'&&f.remaining>0);this.refreshVortex();for(const cue of soundCues(frame.events,frame.player.boomerangCharging))this.play(cue);}
}
