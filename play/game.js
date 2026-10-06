import {GameSound} from './sound.js';
import {Renderer} from './renderer.js';
import {VIEWPORT,fitViewport} from './presentation.js';
const $=id=>document.getElementById(id),canvas=$('arena'),view=new Renderer(canvas),api=globalThis.ClassicAPI;
const setText=(id,value)=>{const node=$(id);if(node)node.textContent=value;};
const bindClick=(id,handler)=>{const node=$(id);if(node)node.onclick=handler;};
const es=/^es(?:[-_]|$)/i.test(navigator.languages?.[0]||navigator.language||'');
const tr=es?{classic:'CLÁSICO',play:'Jugar',resume:'Reanudar',again:'Volver a jugar',restart:'Reiniciar partida',menu:'Menú principal',restartQuestion:'¿Reiniciar la partida?',menuQuestion:'¿Volver al menú principal?',leaveMessage:'La partida actual terminará. Tu récord se guardará.',paused:'Pausa',over:'Por un punto…',subtitle:'Esquiva. Recoge. Encadena.',pausedSubtitle:'La arena te espera.',best:'RÉCORD',combo:'ENLAZA LAS ARMAS',style:'ESTILO VISUAL',sound:'Sonido',on:'Activado',off:'Desactivado',full:'Pantalla completa',exit:'Salir de pantalla completa',loading:'Cargando…',error:'No se han podido cargar los recursos. Recarga la página.',controlsTitle:'CONTROLES',mouse:'Ratón',space:'Espacio',controls:'Muévete con las teclas o mantén pulsado el ratón. Espacio / Esc o un toque en pantalla para pausar.',pause:'Pausar'}:
{classic:'CLASSIC',play:'Play',resume:'Resume',again:'Play again',restart:'Restart run',menu:'Main menu',restartQuestion:'Restart this run?',menuQuestion:'Return to the main menu?',leaveMessage:'This run will end. Your best score will be saved.',paused:'Paused',over:'One dot too many…',subtitle:'Dodge. Collect. Chain.',pausedSubtitle:'The arena can wait.',best:'BEST',combo:'CHAIN THE POWERS',style:'VISUAL STYLE',sound:'Sound',on:'On',off:'Off',full:'Fullscreen',exit:'Exit fullscreen',loading:'Loading…',error:'The game resources could not load. Reload the page.',controlsTitle:'CONTROLS',mouse:'Mouse',space:'Space',controls:'Move with the keys or hold the mouse button. Space / Esc or a touchscreen tap to pause.',pause:'Pause'};
document.documentElement.lang=es?'es':'en';
canvas.setAttribute('aria-label','Tilt Arena. '+tr.controls);
// Copy remains the approved iPhone menu. Desktop inputs continue to work as
// before; these posture choices preview the phone UI, not a desktop sensor.
const menuCopy=es?{
  posture:'POSTURA DE CONTROL',custom:'Calibrar',normal:'Normal',inclined:'Inclinado',calibrate:'Calibrar postura',recalibrate:'Recalibrar',
  customDescription:'Guarda el ángulo que te resulte más cómodo.',normalDescription:'Sujeta el iPhone a unos 45° sobre la mesa.',inclinedDescription:'iPhone plano, pantalla hacia arriba, como sobre una mesa.',
  hint:'Pulsa Calibrar para guardar tu postura',desktop:'La calibración se realiza en el iPhone. Aquí puedes jugar con teclado o ratón.'
}:{posture:'CONTROL POSTURE',custom:'Calibrate',normal:'Normal',inclined:'Inclined',calibrate:'Calibrate posture',recalibrate:'Recalibrate',
  customDescription:'Save the angle that feels most comfortable.',normalDescription:'Hold the iPhone at about 45° above the table.',inclinedDescription:'Keep the iPhone flat, screen up, like it is on a table.',
  hint:'Tap Calibrate to save your posture',desktop:'Calibration takes place on the iPhone. You can play here with the keyboard or mouse.'};
const read=(k,fallback)=>{try{return localStorage.getItem(k)??fallback;}catch{return fallback;}};
const save=(k,v)=>{try{localStorage.setItem(k,String(v));}catch{}};
let pendingRunAction=null;
let posture=read('tilt.play.posturePreview','custom');
let autoCalibrate=read('tilt.play.autoCalibrate','true')!=='false';
if(!['custom','normal','inclined'].includes(posture))posture='custom';
let mode=read('tilt.play.mode','classic')==='hard'?'hard':'classic';
const bestKey=()=>mode==='hard'?'tilt.play.best.hard.v1':'tilt.play.best.v1';
let best=Number(read(bestKey(),0))||0,phase='menu',frame=null,last=0,ready=false,sound=read('tilt.play.sound','false')==='true',pointer=null;
const keys=new Set(), sounds=new GameSound(await fetch('/audio-approved.json').then(r=>r.json()));
sounds.setMuted(!sound);
let deathElapsed=0;
const deathDuration=2.4;
view.laserStyle='plasma';
view.theme='inkTide';
function music(){sounds.setMode(phase==='running'||phase==='dying'?'game':phase==='paused'?'paused':'menu');}
function hud(){
  if(!frame)return;
  $('score').textContent=frame.score.toLocaleString();
  $('best').textContent=tr.best+'  '+Math.max(best,phase==='menu'||frame.mode!==mode?0:frame.score).toLocaleString();
  $('combo-text').textContent=frame.combo?'COMBO  '+frame.comboBase+' × '+frame.combo:tr.combo;
  $('combo-bar').style.transform='scaleX('+frame.comboRemaining+')';
}
function overlay(){
  const paused=phase==='paused',dead=phase==='gameOver';
  setText('mode-label',es?'MODO DE JUEGO':'GAME MODE');
  setText('mode-classic',es?'Clásico':'Classic');setText('mode-hard',es?'Difícil':'Hard');
  setText('mode-description',mode==='hard'?(es?'Un reto mayor. Cada decisión cuenta.':'A tougher challenge. Every decision counts.'):(es?'La presión aumenta poco a poco.':'The pressure builds over time.'));
  for(const value of ['classic','hard'])$('mode-'+value)?.setAttribute('aria-pressed',String(mode===value));
  $('ui').dataset.phase=phase;$('ui').dataset.theme=view.theme;$('ui').dataset.mode=mode;
  $('overlay').hidden=phase==='running'||phase==='dying';
  $('title').textContent=paused?tr.paused:dead?tr.over:mode==='hard'?(es?'DIFÍCIL':'HARD'):tr.classic;
  $('subtitle').textContent=dead?'COMBO ×'+frame.bestCombo+'  ·  '+Math.floor(frame.time)+' s':paused?tr.pausedSubtitle:tr.subtitle;
  $('menu-best').textContent=dead?frame.score.toLocaleString():tr.best+'  '+best.toLocaleString();
  $('play').textContent=!ready?tr.loading:paused?tr.resume:dead?tr.restart:tr.play;
  $('restart').hidden=!paused;$('restart').textContent=tr.restart;
  $('run-actions').hidden=!paused&&!dead;
  $('menu').hidden=!paused&&!dead;$('menu').textContent=tr.menu;
  $('fullscreen').hidden=true;
  $('calibrate').hidden=dead;$('calibrate').textContent=paused?menuCopy.recalibrate:menuCopy.calibrate;
  setText('controls',menuCopy[posture+'Description']);setText('controls-label',menuCopy.posture);
  for(const value of ['custom','normal','inclined']){
    setText(value+'-label',menuCopy[value]);
    $('posture-'+value)?.setAttribute('aria-pressed',String(posture===value));
  }
  if($('auto-calibrate')){
    $('auto-calibrate').hidden=posture!=='custom';
    $('auto-calibrate').setAttribute('aria-pressed',String(autoCalibrate));
    setText('auto-calibrate-label',es?'Recalibrar al jugar o reanudar':'Recalibrate on play or resume');
    setText('auto-calibrate-mark',autoCalibrate?'●':'○');
  }
  setText('theme-label',tr.style);
  $('theme-inkTide')?.setAttribute('aria-pressed',String(view.theme==='inkTide'));
  $('theme-classic')?.setAttribute('aria-pressed',String(view.theme==='classic'));
  setText('sound-label',tr.sound);setText('sound-value',sound?tr.on:tr.off);
  $('sound')?.setAttribute('aria-label',tr.sound+': '+(sound?tr.on:tr.off));
  $('sound')?.setAttribute('aria-pressed',String(sound));
}
function clearInput(){keys.clear();pointer=null;}
function resize(){
  const fitted=fitViewport(window.innerWidth,window.innerHeight);
  $('stage').style.width=fitted.width+'px';$('stage').style.height=fitted.height+'px';
  $('ui').style.setProperty('--display-scale',String(fitted.scale));
  view.resize(VIEWPORT.width,VIEWPORT.height);
  if(ready&&frame)view.render(frame);
  // Never call API.resize or reset its clock for a display-only resize.
}
function configureGame(){frame=JSON.parse(api.resize(VIEWPORT.left,VIEWPORT.right,VIEWPORT.bottom,VIEWPORT.top));}
function start(){
  if(phase==='dying')return;
  view.deathAge=null;deathElapsed=0;
  if(!ready)return;$('error').textContent='';clearInput();view.reset();
  frame=JSON.parse(api.create(Date.now(),true,mode));configureGame();
  phase='running';sounds.startRun();last=0;overlay();hud();canvas.focus();music();
}
function pause(){
  if(phase!=='running')return;
  api.pause();frame=JSON.parse(api.tick(0,0,0));phase='paused';
  clearInput();last=0;music();overlay();$('play').focus();
}
function resume(){
  if(!ready||phase!=='paused')return;
  $('error').textContent='';clearInput();api.resume();phase='running';last=0;overlay();canvas.focus();music();
}
function finish(){
  deathElapsed=0;view.deathAge=0;phase='dying';last=0;clearInput();best=Math.max(best,frame.score);
  save(bestKey(),best);music();overlay();hud();
}
function theme(value){view.theme=value;save('tilt.play.theme',value);view.reset();overlay();if(ready)view.render(frame);}
for(const value of ['classic','hard'])bindClick('mode-'+value,()=>{if(phase!=='menu')return;mode=value;save('tilt.play.mode',mode);best=Number(read(bestKey(),0))||0;overlay();hud();});
for(const value of ['custom','normal','inclined'])bindClick('posture-'+value,()=>{posture=value;save('tilt.play.posturePreview',value);$('error').textContent='';overlay();});
bindClick('auto-calibrate',()=>{autoCalibrate=!autoCalibrate;save('tilt.play.autoCalibrate',autoCalibrate);overlay();});
$('calibrate').onclick=()=>{$('error').textContent=menuCopy.desktop;};
function requestRunAction(action){
  if(phase!=='paused'&&phase!=='gameOver')return;
  pendingRunAction=action;$('overlay').inert=true;$('confirm-question').textContent=action==='restart'?tr.restartQuestion:tr.menuQuestion;
  if($('audio-credits'))$('audio-credits').inert=true;
  $('confirm-message').textContent=phase==='gameOver'?(es?'Tu récord se ha guardado.':'Your best score has been saved.'):tr.leaveMessage;$('confirm-accept').textContent=action==='restart'?tr.restart:tr.menu;
  $('confirm-cancel').textContent=es?'Cancelar':'Cancel';$('run-confirm').hidden=false;$('confirm-cancel').focus();
}
function resolveRunAction(accept){
  const action=pendingRunAction;pendingRunAction=null;$('run-confirm').hidden=true;$('overlay').inert=false;
  if($('audio-credits'))$('audio-credits').inert=false;
  if(!action)return;
  if(!accept){$('play').focus();return;}
  if(phase==='paused'){frame=JSON.parse(api.finish());view.accept(frame);view.render(frame);}
  best=Math.max(best,frame.score);save(bestKey(),best);clearInput();last=0;
  if(action==='restart')start();else{phase='menu';music();overlay();hud();$('play').focus();}
}
$('play').onclick=()=>phase==='paused'?resume():start();
$('restart').onclick=()=>requestRunAction('restart');
$('confirm-cancel').onclick=()=>resolveRunAction(false);$('confirm-accept').onclick=()=>resolveRunAction(true);
bindClick('theme-inkTide',()=>theme('inkTide'));bindClick('theme-classic',()=>theme('classic'));
$('menu').onclick=()=>requestRunAction('menu');
bindClick('sound',()=>{sound=!sound;save('tilt.play.sound',sound);sounds.setMuted(!sound);overlay();music();});
$('fullscreen').onclick=async()=>{try{if(document.fullscreenElement)await document.exitFullscreen();else await document.documentElement.requestFullscreen();}catch{}overlay();};
document.addEventListener('fullscreenchange',()=>{overlay();resize();});
window.addEventListener('keydown',e=>{
  if(pendingRunAction){if(e.key==='Escape'){e.preventDefault();resolveRunAction(false);}else if(e.key==='Tab'){e.preventDefault();(document.activeElement===$('confirm-cancel')?$('confirm-accept'):$('confirm-cancel')).focus();}return;}
  if(['INPUT','SELECT','TEXTAREA'].includes(e.target.tagName))return;
  const k=e.key.toLowerCase();
  if(['arrowup','arrowdown','arrowleft','arrowright','w','a','s','d',' ','escape'].includes(k)&&e.target.tagName!=='BUTTON')e.preventDefault();
  if((k===' '||k==='escape')&&!e.repeat){
    if(e.target.tagName==='BUTTON'&&k===' ')return;
    if(phase==='running')pause();else if(phase==='paused')resume();return;
  }
  if(phase==='running')keys.add(k);
});
window.addEventListener('keyup',e=>keys.delete(e.key.toLowerCase()));
function point(e){const r=canvas.getBoundingClientRect();return{x:(e.clientX-r.left)/r.width*VIEWPORT.width,y:(r.bottom-e.clientY)/r.height*VIEWPORT.height};}
canvas.onpointerdown=e=>{
  if(phase!=='running')return;
  if(e.pointerType==='touch'){e.preventDefault();pause();return;}
  canvas.focus();canvas.setPointerCapture(e.pointerId);pointer=point(e);
};
canvas.onpointermove=e=>{if(pointer)pointer=point(e);};
canvas.onpointerup=canvas.onpointercancel=canvas.onlostpointercapture=()=>{pointer=null;};
window.addEventListener('blur',pause);document.addEventListener('visibilitychange',()=>{if(document.hidden)pause();last=0;sounds.setSuspended(document.hidden);});window.addEventListener('resize',resize);
function tick(time){
  if(ready&&phase==='running'){
    const dt=last?(time-last)/1000:0;last=time;
    let x=(keys.has('d')||keys.has('arrowright')?1:0)-(keys.has('a')||keys.has('arrowleft')?1:0);
    let y=(keys.has('w')||keys.has('arrowup')?1:0)-(keys.has('s')||keys.has('arrowdown')?1:0);
    if(!x&&!y&&pointer){x=(pointer.x-frame.player.x)/70;y=(pointer.y-frame.player.y)/70;}
    frame=JSON.parse(api.tick(dt,x,y));view.accept(frame);view.render(frame);hud();
    sounds.consume(frame);
    if(frame.state==='gameOver')finish();
  }
  if(ready&&phase==='dying'&&!document.hidden){
    deathElapsed+=last?Math.max(0,Math.min(.1,(time-last)/1000)):0;last=time;
    view.deathAge=deathElapsed;view.render(frame);
    if(deathElapsed>=deathDuration){phase='gameOver';last=0;music();overlay();$('play').focus();}
  }
  requestAnimationFrame(tick);
}
overlay();resize();
try{
  await view.load();frame=JSON.parse(api.create(1702,true,mode));configureGame();api.pause();frame=JSON.parse(api.tick(0,0,0));
  ready=true;$('play').disabled=false;overlay();view.render(frame);hud();requestAnimationFrame(tick);
}catch(error){$('error').textContent=tr.error;console.error(error);}

// A single click timbre for every actual button, including confirmations and credits.
document.addEventListener('click',e=>{if(e.target.closest('button:not(:disabled)')){sounds.uiClick();music();}});
const creditsButton=document.createElement('button');creditsButton.textContent=es?'Créditos':'Credits';creditsButton.id='audio-credits';
creditsButton.style.cssText='position:fixed;left:8px;bottom:3px;z-index:7;font-size:10px;padding:4px 7px;background:#161713aa;color:#e8deca;border:0;border-radius:3px';
const creditsDialog=document.createElement('dialog');creditsDialog.style.cssText='max-width:650px;max-height:80vh;background:#201f1c;color:#e8deca;border:1px solid #d9b46e;padding:22px';
const closeCredits=document.createElement('button');closeCredits.textContent=es?'Cerrar':'Close';closeCredits.onclick=()=>creditsDialog.close();
const creditsText=document.createElement('pre');creditsText.style.cssText='white-space:pre-wrap;font:13px/1.5 system-ui';
creditsDialog.append(closeCredits,creditsText);document.body.append(creditsButton,creditsDialog);
creditsButton.onclick=async()=>{creditsText.textContent=await fetch('/Audio-Credits.txt').then(r=>r.text());creditsDialog.showModal();};
const creditsVisibility=new MutationObserver(()=>{creditsButton.hidden=$('overlay').hidden;});creditsVisibility.observe($('overlay'),{attributes:true,attributeFilter:['hidden']});
