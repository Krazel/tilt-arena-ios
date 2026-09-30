const test=require('node:test'),assert=require('node:assert/strict'),fs=require('node:fs'),vm=require('node:vm'),path=require('node:path');
const root=path.join(__dirname,'..');
// Exercise the real browser controller and shared engine with DOM/audio boundaries
// replaced. No production diagnostics, injected powers or browser automation hooks.
async function harness(missing=[]){
  const elements=new Map(),windowEvents={},documentEvents={},storage=new Map();
  const element=id=>{if(!elements.has(id))elements.set(id,{id,tagName:id==='arena'?'CANVAS':'BUTTON',dataset:{},style:{setProperty(){}},clientWidth:1280,clientHeight:588.741418764302,value:'inkTide',hidden:false,disabled:false,setAttribute(){},focus(){},setPointerCapture(){},getBoundingClientRect(){return{left:0,bottom:654.370709382151,width:1280,height:588.741418764302};}});return elements.get(id);};
  class Renderer{constructor(){this.theme='inkTide';this.frames=[];}async load(){}resize(w,h){this.width=w;this.height=h;}reset(){}accept(){}render(f){this.frame=f;}}
  class Audio{constructor(){this.paused=true;}play(){this.paused=false;return Promise.resolve();}pause(){this.paused=true;}addEventListener(){}}
  let next,frame,renderView;
  class SpyRenderer extends Renderer{constructor(){super();renderView=this;}}
  const window={innerWidth:1280,innerHeight:720,confirm:()=>true,addEventListener:(k,v)=>windowEvents[k]=v};
  const document={documentElement:{},body:{append(){}},createElement:()=>({style:{},append(){},showModal(){},close(){}}),hidden:false,getElementById:id=>missing.includes(id)?null:element(id),addEventListener:(k,v)=>documentEvents[k]=v};
  const {GameSound:RealGameSound}=await import('../play/sound.js');
  class GameSound extends RealGameSound {constructor(catalog){super(catalog,()=>new Audio(),()=>0);}}
  const fetch=async()=>({json:async()=>JSON.parse(fs.readFileSync(path.join(root,'native-ios/Resources/audio-approved.json'))),text:async()=>''});
  class MutationObserver{observe(){}}
  const {VIEWPORT,fitViewport}=await import('../play/presentation.js');
  class SeedDate extends Date {static now(){return 1702;}}
  const context=vm.createContext({Renderer:SpyRenderer,Audio,GameSound,fetch,MutationObserver,VIEWPORT,fitViewport,Date:SeedDate,window,document,navigator:{languages:['en-US']},localStorage:{getItem:k=>storage.get(k)??null,setItem:(k,v)=>storage.set(k,v)},requestAnimationFrame:f=>next=f,performance:{now:()=>0},console});
  vm.runInContext(fs.readFileSync(path.join(root,'native-ios/Resources/classic-core.js'),'utf8'),context);
  const original=context.ClassicAPI.tick;
  context.ClassicAPI.tick=(...args)=>{const result=original(...args);frame=JSON.parse(result);return result;};
  const controller=fs.readFileSync(path.join(root,'play/game.js'),'utf8').replace(/^import .*;\r?\n/gm,'');
  await vm.runInContext(`(async()=>{${controller}})()`,context);
  let now=100;
  const step=(count=1)=>{for(let i=0;i<count;i++){next(now);now+=1000/60;}return frame;};
  const key=(type,k,target=element('arena'))=>windowEvents[type]({key:k,target,repeat:false,preventDefault(){}});
  return{element,window,windowEvents,documentEvents,document,storage,step,key,get frame(){return frame;},get view(){return renderView;}};
}
test('browser keyboard and mouse drive the production engine, then release and brake',async()=>{
  const h=await harness();h.element('play').onclick();let f=h.step(1),x=f.player.x;
  h.key('keydown','d');f=h.step(10);assert(f.player.x>x+50);h.key('keyup','d');f=h.step(20);assert(Math.abs(f.player.vx)<1);
  x=f.player.x;h.element('arena').onpointerdown({clientX:100,clientY:360,pointerId:1});f=h.step(10);assert(f.player.x<x-50);
  h.element('arena').onpointerup();f=h.step(20);assert(Math.abs(f.player.vx)<1);
});
test('browser pause and focus loss freeze time; changing theme preserves the run and resume clears input',async()=>{
  const h=await harness();h.element('play').onclick();h.step();h.key('keydown','w');h.step(10);h.windowEvents.blur();
  const paused=JSON.stringify(h.frame);h.step(30);assert.equal(JSON.stringify(h.frame),paused);assert.equal(h.frame.state,'paused');
  h.element('theme-classic').onclick();assert.equal(h.view.theme,'classic');assert.equal(JSON.stringify(h.frame),paused);assert.equal(h.storage.get('tilt.play.theme'),'classic');
  h.element('play').onclick();const resumed=h.step(25);assert.equal(resumed.state,'running');assert(Math.abs(resumed.player.vy)<1);
  h.document.hidden=true;h.documentEvents.visibilitychange();assert.equal(h.frame.state,'paused');
});
test('browser game over offers a fresh game and never continues hidden behind the menu',async()=>{
  const h=await harness();h.element('play').onclick();h.step(2400);assert.equal(h.frame.state,'gameOver');
  assert.equal(h.element('play').textContent,'Restart run');assert.equal(h.element('overlay').hidden,false);
  const time=h.frame.time;h.step(30);assert.equal(h.frame.time,time);
  h.element('play').onclick();assert.notEqual(h.element('ui').dataset.phase,'gameOver');h.step();assert.equal(h.frame.state,'running');assert.equal(h.frame.time,0);assert.equal(h.frame.score,0);
});
test('touch pauses anywhere without steering or resuming on release; no pause button is needed',async()=>{
  const h=await harness(['pause']);h.element('play').onclick();h.step();
  for(const [clientX,clientY] of [[640,360],[10,80],[1260,630]]){
    h.key('keydown','d');h.step(4);
    const before=JSON.stringify(h.frame.player),time=h.frame.time,score=h.frame.score;
    let prevented=false;
    h.element('arena').onpointerdown({clientX,clientY,pointerId:1,pointerType:'touch',preventDefault(){prevented=true;}});
    assert(prevented);assert.equal(h.frame.state,'paused');assert.equal(h.element('overlay').hidden,false);
    h.element('arena').onpointermove({clientX:100,clientY:100});h.element('arena').onpointerup();h.step(20);
    assert.equal(h.frame.time,time);assert.equal(h.frame.score,score);assert.equal(JSON.stringify(h.frame.player),before);
    h.element('play').onclick();h.step(2);assert.equal(h.frame.state,'running');assert(h.frame.time>time);
    h.step(20);assert(Math.abs(h.frame.player.vx)<1,'resume clears keyboard and touch input');
  }
  h.key('keydown','escape');assert.equal(h.frame.state,'paused');
});
test('both browser skins replay native reference geometry and movement exactly through window resizes',async()=>{
  // Existing engine is CommonJS-exportable despite its .js path in the ES package.
  const engine={exports:{}};vm.runInNewContext(fs.readFileSync(path.join(root,'native-ios/Resources/classic-core.js'),'utf8'),{module:engine});
  const native=new engine.exports.ClassicGame(1702);
  // Actual native capture-start.json, not the approximate preflight script bounds.
  native.resize(118.70646766169155,1272.7363184079602,57.840796019900495,592);
  const ink=await harness(),classic=await harness();classic.element('theme-classic').onclick();
  for(const h of [ink,classic]){h.element('play').onclick();h.step();}
  native.advance(0,{x:0,y:0});
  const compare=(actual,expected,trail='frame')=>{
    if(typeof expected==='number'){assert(Math.abs(actual-expected)<1e-7,trail+': '+actual+' != '+expected);return;}
    if(expected&&typeof expected==='object'){assert.deepEqual(Object.keys(actual),Object.keys(expected),trail);for(const k of Object.keys(expected))compare(actual[k],expected[k],trail+'.'+k);return;}
    assert.equal(actual,expected,trail);
  };
  let previous='',peak=0;
  for(let i=0;i<360;i++){
    const key=['d','w','a','s'][Math.floor(i/60)%4],input={x:key==='d'?1:key==='a'?-1:0,y:key==='w'?1:key==='s'?-1:0};
    for(const h of [ink,classic]){
      if(key!==previous){if(previous)h.key('keyup',previous);h.key('keydown',key);}
      if(i===47||i===121){h.window.innerWidth=i===47?800:1920;h.window.innerHeight=i===47?1000:1080;h.windowEvents.resize();}
    }
    previous=key;const expected=JSON.parse(JSON.stringify(native.advance(1/60,input)));
    for(const h of [ink,classic])compare(h.step(),expected);
    peak=Math.max(peak,Math.hypot(expected.player.vx,expected.player.vy));
    if(expected.state==='gameOver')break;
  }
  assert(peak>599&&peak<=600.000001,'same 600-unit maximum speed');
  assert(Math.abs(ink.view.width-874/402*640)<1e-9);assert.equal(ink.view.height,640);
});
test('display fitting preserves native landscape aspect at wide, tall and fullscreen dimensions',async()=>{
  const {fitViewport}=await import('../play/presentation.js');
  for(const [w,h] of [[1280,720],[800,1000],[1920,1080],[2622,1206]]){
    const fit=fitViewport(w,h);assert(fit.width<=w+.001&&fit.height<=h+.001);assert(Math.abs(fit.width/fit.height-874/402)<1e-12);
  }
});

test('optional menu blocks can be removed without breaking play, pause or resume',async()=>{
  const h=await harness(['theme-label','theme-classic','theme-inkTide','controls','controls-label','posture-hint','posture-custom','posture-normal','posture-inclined','custom-label','normal-label','inclined-label','sound-label','sound-value','sound']);
  h.element('play').onclick();h.step();h.key('keydown','d');h.step(10);
  h.key('keyup','d');h.windowEvents.blur();assert.equal(h.frame.state,'paused');
  const time=h.frame.time;h.element('play').onclick();h.step(2);
  assert.equal(h.frame.state,'running');assert(h.frame.time>time);
});


test('browser mode selection persists, cannot change a paused run, and keeps records separate',async()=>{
 const h=await harness();h.storage.set('tilt.play.best.v1','6966');h.storage.set('tilt.play.best.hard.v1','321');
 h.element('mode-hard').onclick();assert.equal(h.storage.get('tilt.play.mode'),'hard');assert.match(h.element('menu-best').textContent,/321/);
 h.element('play').onclick();h.step();assert.equal(h.frame.mode,'hard');assert(h.frame.enemies.length>=6&&h.frame.enemies.length<=8);
 h.windowEvents.blur();h.element('mode-classic').onclick();assert.equal(h.storage.get('tilt.play.mode'),'hard');
 h.element('menu').onclick();h.element('confirm-accept').onclick();assert.equal(h.storage.get('tilt.play.best.hard.v1'),'321');assert.equal(h.storage.get('tilt.play.best.v1'),'6966');
 h.element('menu').onclick();h.element('mode-classic').onclick();assert.equal(h.element('menu-best').textContent.replace(/\D/g,''),'6966');
 h.element('play').onclick();h.step();assert.equal(h.frame.mode,'classic');assert.equal(h.frame.enemies.length,0);
});

test('restart and main menu confirm, cancel preserves the paused run, and restart retains mode',async()=>{
 const h=await harness();h.element('mode-hard').onclick();h.element('play').onclick();h.step();h.windowEvents.blur();
 const before=JSON.stringify(h.frame);
 for(const id of ['restart','menu']){assert.equal(h.element(id).hidden,false);h.element(id).onclick();assert.equal(h.element('run-confirm').hidden,false);h.key('keydown',' ');h.step(10);assert.equal(JSON.stringify(h.frame),before);h.element('confirm-cancel').onclick();assert.equal(h.element('run-confirm').hidden,true);assert.equal(h.element('ui').dataset.phase,'paused');}
 h.element('restart').onclick();h.key('keydown','Escape');assert.equal(h.element('run-confirm').hidden,true);assert.equal(h.element('ui').dataset.phase,'paused');
 h.element('restart').onclick();h.element('confirm-accept').onclick();h.step();assert.equal(h.frame.state,'running');assert.equal(h.frame.mode,'hard');assert.equal(h.frame.time,0);
 h.windowEvents.blur();h.element('menu').onclick();h.element('confirm-accept').onclick();assert.equal(h.element('ui').dataset.phase,'menu');const time=h.frame.time;h.step(20);assert.equal(h.frame.time,time);
});
