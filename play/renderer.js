import {lightningA} from './lightning-vfx.js';
import {symmetricArrow} from './player-art.js';
// Canvas presentation of the existing native art. Simulation lives in core.js.
import {VIEWPORT,ART} from './presentation.js';
import {drawArea} from './area-vfx.js';
import {laserTrial,deathA} from './trial-vfx.js';
const paper='#eee4c9', gold='#c79a49', teal='#55969a', blue='#4a94cf', red='#ed4128';
const colors={nuke:'#ffb52a',wave:'#ba71ee',missiles:'#f7e36b',frost:'#70dce9',bubble:'#7bde83',spikes:'#6c9ce8',vortex:'#ee77bc',lightning:'#eeefff',burn:'#ff784c',boomerang:'#ffc06a',laser:'#ed8f91'};
const orbColors={nuke:'#806326',wave:'#69556f',missiles:'#858252',frost:'#367582',bubble:'#526444',spikes:'#466277',vortex:'#76546a',lightning:'#657986',burn:'#975937',boomerang:'#796746',laser:'#85535c'};
const inkColor=k=>['frost','wave','lightning','electricPulse'].includes(k)?blue:['bubble','vortex'].includes(k)?teal:['death','kill'].includes(k)?red:gold;
export class Renderer {
  constructor(canvas){this.canvas=canvas;this.ctx=canvas.getContext('2d');this.theme='inkTide';this.effects=[];this.previous=new Map();this.headings=new Map();this.reduced=matchMedia('(prefers-reduced-motion: reduce)').matches;}
  async load(){
    const load=async name=>{const img=new Image();img.src=`/${name}.png`;await img.decode();return img;};
    [this.background,this.atlas,this.orb]=await Promise.all(['ink-tide-arena','ink-tide-sprites','orb-glass-v03'].map(load));
    const [approvedSheet,manifest]=await Promise.all([load('ink-tide-approved-orbs'),fetch('/approved-orbs.json').then(r=>{if(!r.ok)throw Error('Approved orb regions unavailable');return r.json();})]);
    const waveSheet=await load('ink-wave-orb-v058');
    // Copy the complete approved drawings: their painted symbols are already present.
    // Only clip the background around the silhouette; never recolor their pixels.
    this.approvedOrbs=Object.fromEntries(await Promise.all(Object.entries(manifest.regions).map(async ([power,region])=>{
      const source=region.image?await load(region.image):(power==='wave'?waveSheet:approvedSheet);
      const image=document.createElement('canvas');image.width=256;image.height=256;
      const ctx=image.getContext('2d');ctx.beginPath();
      region.mask.forEach(([x,y],i)=>i?ctx.lineTo(x,y):ctx.moveTo(x,y));ctx.closePath();ctx.clip();
      ctx.drawImage(source,...region.crop,0,0,256,256);
      return [power,{image,size:region.displaySize}];
    })));
    // Freeze tint is cached once; preserve the alpha channel of the approved atlas.
    const tint=(source,color,opacity)=>{const out=document.createElement('canvas');out.width=source.width;out.height=source.height;const ctx=out.getContext('2d');ctx.drawImage(source,0,0);ctx.globalCompositeOperation='source-atop';ctx.globalAlpha=opacity;ctx.fillStyle=color;ctx.fillRect(0,0,out.width,out.height);return out;};
    const pigment=(source,hex)=>{
      const out=document.createElement('canvas');out.width=source.width;out.height=source.height;
      const ctx=out.getContext('2d');ctx.drawImage(source,0,0);
      const pixels=ctx.getImageData(0,0,out.width,out.height),d=pixels.data;
      const target=[1,3,5].map(i=>parseInt(hex.slice(i,i+2),16)/255),lum=([r,g,b])=>.2126*r+.7152*g+.0722*b;
      for(let i=0;i<d.length;i+=4){
        if(!d[i+3])continue;
        const rgb=[d[i]/255,d[i+1]/255,d[i+2]/255];
        const mask=Math.max(0,Math.min(1,(Math.min(rgb[1],rgb[2])-rgb[0]-.015)/.09));
        const scale=lum(rgb)/lum(target);
        for(let c=0;c<3;c++)d[i+c]=Math.round(255*(rgb[c]*(1-mask)+Math.min(1,target[c]*scale)*mask));
      }
      ctx.putImageData(pixels,0,0);return out;
    };
    this.inkOrbs=Object.fromEntries(Object.entries(orbColors).map(([key,color])=>[key,pigment(this.atlas,color)]));
    this.classicOrbs=Object.fromEntries(Object.entries(colors).map(([key,color])=>[key,tint(this.orb,color,.72)]));
    this.frozen=document.createElement('canvas');this.frozen.width=this.atlas.width;this.frozen.height=this.atlas.height;
    const c=this.frozen.getContext('2d');c.drawImage(this.atlas,0,0);c.globalCompositeOperation='source-in';c.fillStyle=blue;c.fillRect(0,0,this.frozen.width,this.frozen.height);
  }
  resize(w,h){this.width=w;this.height=h;const dpr=Math.min(devicePixelRatio||1,2);this.canvas.width=Math.round(this.canvas.clientWidth*dpr);this.canvas.height=Math.round(this.canvas.clientHeight*dpr);}
  reset(){this.effects=[];this.previous.clear();this.headings.clear();}
  accept(frame){let kills=0;for(const event of frame.events){if(event.kind==='freeze'||(event.kind==='blast'&&event.power==='nuke'))continue;if(event.x==null||event.y==null)continue;if(event.kind==='kill'&&++kills>12)continue;this.effects.push({...event,born:frame.time});}if(this.effects.length>40)this.effects.splice(0,this.effects.length-40);}
  at(x,y,angle,draw){const c=this.ctx;c.save();c.translate(x,this.height-y);c.rotate(-angle);draw();c.restore();}
  sprite(cell,size,angle=0,anchorX=.5,anchorY=.5,frozen=false,power=null){const c=this.ctx,img=power?this.inkOrbs[power]:frozen?this.frozen:this.atlas,w=img.width/4,h=img.height/2;c.save();c.rotate(-angle);c.drawImage(img,(cell%4)*w,Math.floor(cell/4)*h,w,h,-size*anchorX,-size*(1-anchorY),size,size);c.restore();}
  path(points,color=paper,width=2.5,fill=false){const c=this.ctx;c.beginPath();points.forEach(([x,y],i)=>i?c.lineTo(x,y):c.moveTo(x,y));c.lineWidth=width;c.strokeStyle=color;c.lineCap='round';c.lineJoin='round';if(fill){c.closePath();c.fillStyle=fill;c.fill();}c.stroke();}
  ring(r,color=paper,width=3,fraction=1,phase=0){const p=[];for(let i=0;i<=90;i++){const a=phase+i/90*Math.PI*2*fraction,d=r*(this.theme==='inkTide'?1+.018*Math.sin(a*13)+.012*Math.cos(a*23):1);p.push([Math.cos(a)*d,Math.sin(a)*d]);}this.path(p,color,width);}
  star(r,inner,n,color=paper){const p=[];for(let i=0;i<=n*2;i++){const a=i*Math.PI/n,d=i%2?inner:r;p.push([Math.cos(a)*d,Math.sin(a)*d]);}this.path(p,color);}
  glyph(kind){const c=this.ctx,color=this.theme==='inkTide'?paper:'#fff';
    switch(kind){
      case'nuke':this.ring(6,color,5);for(let i=0;i<8;i++){const a=i*Math.PI/4;this.path([[10*Math.cos(a),10*Math.sin(a)],[14*Math.cos(a),14*Math.sin(a)]],color);}break;
      case'wave':c.beginPath();c.moveTo(-2,-11);c.quadraticCurveTo(17,0,-2,11);c.strokeStyle=color;c.lineWidth=4;c.stroke();this.path([[-13,0],[-4,0]],color,2);break;
      case'laser':this.path([[-11,0],[14,0]],color,4);this.path([[-10,-7],[-10,7]],color,3);this.path([[7,-6],[14,0],[7,6]],color,2);break;
      case'missiles':for(const x of [-9,0,9])this.path([[x-4,10],[x+1,-10],[x+5,-2]],color);break;
      case'frost':for(let i=0;i<3;i++){const a=i*Math.PI/3;this.path([[-13*Math.cos(a),-13*Math.sin(a)],[13*Math.cos(a),13*Math.sin(a)]],color);}break;
      case'bubble':this.ring(11,color);break;
      case'spikes':this.star(14,8,8,color);break;
      case'vortex':for(let i=0;i<3;i++){c.save();c.rotate(i*Math.PI*2/3);c.beginPath();c.moveTo(0,2);c.bezierCurveTo(14,-2,13,12,0,11);c.quadraticCurveTo(7,7,0,2);c.fillStyle=color;c.fill();c.restore();}break;
      case'lightning':this.path([[7,-14],[-7,1],[5,1],[-6,14]],color,3);break;
      case'burn':this.path([[-10,9],[-9,-5],[-3,0],[1,-14],[10,9],[-10,9]],color);break;
      case'boomerang':this.path([[-12,-9],[12,0],[-2,10],[2,0],[-12,-9]],color);break;
    }
  }
  originalArrow(size=ART.arrow){if(this.theme==='inkTide')this.sprite(0,size,-2.46);else{const s=size/62;this.path([[20*s,0],[-16*s,-14*s],[-8*s,0],[-16*s,14*s]],'#243815',2,'#f7ffe5');}}
  arrow(size=ART.arrow){if(this.theme==='inkTide'&&size===ART.arrow)symmetricArrow(this.ctx,this.atlas,size,target=>{const old=this.ctx;this.ctx=target;this.originalArrow(size);this.ctx=old;});else this.originalArrow(size);}
  charge(progress,cell,color,x=0){const c=this.ctx,radius=cell===4?32:20;c.save();c.translate(x,0);this.ring(radius,color,3,progress,-Math.PI/2);c.save();if(cell===4)c.translate(34,0);c.globalAlpha=.45+progress*.55;if(this.theme==='inkTide')this.sprite(cell,35*(.35+progress*.65),cell===7&&!this.reduced?progress*Math.PI*2:0);else this.star(9+progress*8,5,6,color);c.restore();if(!this.reduced)for(let i=0;i<7;i++){const a=i*Math.PI*2/7+progress,t=(progress*1.7+i/7)%1,r=radius+18-t*30;c.globalAlpha=Math.sin(t*Math.PI);this.path([[Math.cos(a)*r,Math.sin(a)*r],[Math.cos(a)*(r+4),Math.sin(a)*(r+4)]],color,2);}c.restore();}
  render(f){
    const c=this.ctx,w=this.width,h=this.height,ink=this.theme==='inkTide',t=f.time,p=f.player;
    c.setTransform(this.canvas.width/w,0,0,this.canvas.height/h,0,0);c.globalAlpha=1;
    if(ink)c.drawImage(this.background,0,0,w,h);else{const g=c.createLinearGradient(0,0,w,h);g.addColorStop(0,'#354e17');g.addColorStop(1,'#77942c');c.fillStyle=g;c.fillRect(0,0,w,h);this.at(w*.65,h*.6,0,()=>{for(let i=0;i<10;i++)this.ring(40+i*40,'#d1ee8012',3);});}
    c.strokeStyle=ink?'#c79a4938':'#e3efc980';c.lineWidth=ink?1:2;c.beginPath();c.roundRect(VIEWPORT.left,h-VIEWPORT.top,VIEWPORT.right-VIEWPORT.left,VIEWPORT.top-VIEWPORT.bottom,16);c.stroke();
    for(const field of f.fields){if(field.kind==='blast'||field.kind==='frost'){this.area(field);continue;}this.at(field.x,field.y,field.kind==='vortex'?(this.reduced?0:t*ART.vortexSpin):field.angle,()=>{c.globalAlpha=Math.min(field.kind==='fire'?1:.85,field.remaining);if(field.kind==='fire')c.scale(1,this.reduced?1:.9+.1*Math.sin(t*12+field.id));if(ink)this.sprite(field.kind==='vortex'?5:4,field.kind==='vortex'?ART.vortex*field.radius/200:ART.fire);else if(field.kind==='vortex'){for(let i=0;i<4;i++)this.ring(15+i*19,'#ee77bc',4,.8,i*.8);c.fillStyle='#201428';c.beginPath();c.arc(0,0,18,0,Math.PI*2);c.fill();}else this.path([[22,0],[-40,-19],[-24,-4],[-48,-7],[-30,2],[-43,17],[-12,7]],'#ffb324',3,'#ef5321');});}
    for(const o of f.pickups)this.at(o.x,o.y,this.reduced?0:o.angle,()=>{c.globalAlpha=o.remaining<2?.55+.45*Math.sin(t*10):1;const pulse=this.reduced?1:1+.04*Math.sin(t*4+o.id);c.scale(pulse,pulse);const approved=ink&&this.approvedOrbs[o.power];if(approved){const {image,size}=approved;c.drawImage(image,-size/2,-size/2,size,size);return;}if(ink)this.sprite(2,ART.pickup,0,.5,.5,false,o.power);else{c.drawImage(this.classicOrbs[o.power],-28,-28,ART.classicPickup,ART.classicPickup);this.ring(25,colors[o.power],3);}c.scale(56/42,56/42);this.glyph(o.power);});
    for(const shot of f.projectiles)this.at(shot.x,shot.y,shot.kind==='boomerang'&&!this.reduced?t*ART.boomerangSpin:shot.angle,()=>{if(shot.kind==='missile')this.arrow(ART.missile);else if(ink)this.sprite(shot.kind==='wave'?3:7,shot.kind==='wave'?ART.wave:ART.boomerang);else if(shot.kind==='wave'){c.beginPath();c.moveTo(-24,-48);c.quadraticCurveTo(54,0,-24,48);c.strokeStyle='#ba71ee';c.lineWidth=12;c.stroke();}else this.path([[-22,-10],[22,0],[-4,14],[1,0],[-22,-10]],'#fff5d8',2,'#ffc06a');});
    if(f.beam && this.laserStyle && this.laserStyle!=='current'){laserTrial(this,f.beam,t,p.laserRemaining,this.laserStyle);}
    else if(f.beam){const b=f.beam;c.save();c.globalAlpha=Math.min(1,p.laserRemaining/.12)*(this.reduced?1:.94+.06*Math.sin(t*23));this.path([[b.x,h-b.y],[b.toX,h-b.toY]],ink?'#c97478':colors.laser,b.width);this.path([[b.x,h-b.y],[b.toX,h-b.toY]],ink?paper:'#fff',4);this.at(b.x,b.y,0,()=>this.ring(9,ink?'#c97478':colors.laser,2));c.restore();}
    const next=new Map(),headings=new Map();
    for(const e of f.enemies){const old=this.previous.get(e.id),angle=old&&!e.frozen&&Math.hypot(e.x-old.x,e.y-old.y)>.05?Math.atan2(e.y-old.y,e.x-old.x):(this.headings.get(e.id)??Math.atan2(p.y-e.y,p.x-e.x));next.set(e.id,e);headings.set(e.id,angle);this.at(e.x,e.y,angle,()=>{c.globalAlpha=e.telegraph?.22+.12*Math.sin(t*18):e.thawing?.65+.35*Math.sin(t*22):1;if(e.telegraph)c.scale(ART.telegraphScale,ART.telegraphScale);if(ink)this.sprite(1,ART.enemy,0,.75,.55,e.frozen);else{c.beginPath();c.arc(0,0,10,0,Math.PI*2);c.fillStyle=e.frozen?'#70dce9':'#ff5658';c.fill();c.strokeStyle='#fff5d7';c.lineWidth=2;c.stroke();}});}
    this.previous=next;this.headings=headings;
    this.at(p.x,p.y,p.angle,()=>{if(p.fireChargeUntil>t)this.charge(p.fireChargeProgress,4,ink?gold:colors.burn);if(p.waveCharging)this.charge(p.waveChargeProgress,3,ink?blue:colors.wave,28);if(p.boomerangCharging)this.charge(p.boomerangChargeProgress,7,ink?gold:colors.boomerang,38);if(f.state!=='gameOver')this.arrow();if(p.fireRecoveryRemaining>0){c.save();c.globalAlpha=Math.min(1,p.fireRecoveryRemaining/.5)*(this.reduced?1:.65+.35*Math.cos(t*24));this.ring(26,ink?gold:'#ffc06a',2);c.restore();}if(p.bubble)this.ring(32,ink?teal:colors.bubble,4);});
    if(p.spikesUntil>t)this.at(p.x,p.y,this.reduced?0:t*4.2,()=>{const left=p.spikesUntil-t,warning=left<=1.5;c.globalAlpha=warning&&!this.reduced?.7+.3*Math.cos(left*Math.PI*4):1;for(let i=0;i<12;i++){c.save();c.rotate(i*Math.PI/6);this.path([[32,-6],[48,0],[32,6]],ink?gold:'#223968',2,warning?gold:ink?paper:'#ceeaff');c.restore();}if(warning){c.globalAlpha=1;this.ring(54,paper,3,left/1.5,t*4.2-Math.PI/2);}});
    this.effects=this.effects.filter(e=>e.kind==='death'?(this.deathAge??t-e.born)<2.4:t-e.born<1.15);
    for(const e of this.effects)this.effect(e,e.kind==='death'?(this.deathAge??t-e.born):t-e.born);
    c.globalAlpha=1;
  }
  area(field){drawArea(this,field);}
  effect(e,age){if(['lightning','electricPulse'].includes(e.kind)){lightningA.call(this,e,age);return;}if(e.kind==='death'){deathA(this,e,age);return;}const c=this.ctx,ink=this.theme==='inkTide',color=ink?inkColor(e.power||e.kind):(e.color||'#fff'),q=Math.min(1,age/.7),spread=this.reduced?1:1-(1-Math.min(1,age/.26))**3;
    this.at(e.x,e.y,0,()=>{
      c.globalAlpha=Math.max(0,1-age/.7);
      if(e.kind==='lightning'&&e.toX!=null){const dx=e.toX-e.x,dy=e.y-e.toY,d=Math.max(1,Math.hypot(dx,dy)),points=[[0,0]];for(let i=1;i<9;i++){const j=i%2?8:-8;points.push([dx*i/9-dy/d*j,dy*i/9+dx/d*j]);}points.push([dx,dy]);c.globalAlpha=Math.max(0,1-age/.28);this.path(points,ink?blue:color,7);this.path(points,paper,2);return;}
      if(e.kind==='combo'){c.font='bold 24px system-ui';c.fillStyle=paper;c.textAlign='center';c.fillText(`+${e.bonus}`,0,this.reduced?0:-q*22);return;}
      if(e.kind==='freeze'){const r=e.radius||205;for(let i=0;i<12;i++){const a=i*Math.PI/6,R=r*(i%2?.75:1)*spread;c.save();c.rotate(a);c.globalAlpha=Math.max(0,.65-age);this.path([[0,0],[R*.3,-R*.04],[R,0],[R*.45,R*.06]],paper,1,i%2?paper:blue);c.restore();}this.ring(r*spread,blue,3);return;}
      if(['blast','death'].includes(e.kind)){const r=e.radius||95;this.ring(r*(.1+.9*spread),ink?paper:color,5);this.ring(r*.82*(.1+.9*spread),color,8);if(ink){c.globalAlpha=Math.max(0,1-age/.3);this.sprite(6,r*1.6*(.1+spread));}c.globalAlpha=1-q;}
      else if(e.kind==='electricPulse'){this.ring((e.radius||220)*spread,ink?blue:color,2);return;}
      else if(e.kind!=='kill')this.ring((e.kind==='spawnPickup'?38:50)*spread,color,3);
      const count=this.reduced?3:e.kind==='kill'?6:12,r=e.radius||35;
      for(let i=0;i<count;i++){const a=i*2.39996,d=r*(.15+spread*(.45+(i%3)*.16));c.save();c.translate(Math.cos(a)*d,Math.sin(a)*d);c.rotate(a);this.path([[0,0],[9*(1-q),2],[3,5*(1-q)]],color,1,color);c.restore();}
    });
  }
}
