// Approved ice A / explosion A, from the reviewed animated proposal.
const TAU=Math.PI*2,clamp=x=>Math.max(0,Math.min(1,x)),ease=x=>1-(1-clamp(x))**3;
const noise=(i,s=1)=>{const n=Math.sin(i*127.1+s*311.7)*43758.5453;return n-Math.floor(n)};
let effectFade=1;
function line(c,pts,color,width=1,alpha=1){c.globalAlpha=clamp(alpha)*effectFade;c.strokeStyle=color;c.lineWidth=width;c.lineCap='round';c.lineJoin='round';c.beginPath();pts.forEach((p,i)=>i?c.lineTo(...p):c.moveTo(...p));c.stroke();}
function glow(c,x,y,r,color,alpha=1){if(r<=0||alpha<=0)return;c.globalAlpha=clamp(alpha)*effectFade;const g=c.createRadialGradient(x,y,0,x,y,r);g.addColorStop(0,color);g.addColorStop(.24,color);g.addColorStop(1,'#0000');c.fillStyle=g;c.fillRect(x-r,y-r,r*2,r*2);}
function shard(c,x,y,a,size,alpha=1,ice=true){c.save();c.translate(x,y);c.rotate(a);c.globalAlpha=clamp(alpha)*effectFade;c.beginPath();c.moveTo(size,0);c.lineTo(-size*.55,size*.26);c.lineTo(-size*.28,-size*.3);c.closePath();c.fillStyle=ice?'#b9f3f5':'#ffb953';c.fill();line(c,[[size,0],[-size*.27,0]],ice?'#fff5de':'#fff1b0',.65,alpha);c.restore();}
function wave(c,r,alpha,ice,seed,width=2){if(r<1||alpha<=0)return;const pts=[];for(let i=0;i<=100;i++){const a=i/100*TAU,k=1+.022*Math.sin(a*9+seed)+.014*Math.sin(a*17-seed);pts.push([Math.cos(a)*r*k,Math.sin(a)*r*k]);}line(c,pts,ice?'#bdefff':'#ffd59c',width,alpha);}
function puff(c,x,y,r,alpha,fire=false){c.globalAlpha=clamp(alpha)*effectFade;const g=c.createRadialGradient(x-r*.18,y-r*.23,0,x,y,r);g.addColorStop(0,fire?'#aa5a22':'#78bbc4');g.addColorStop(.5,fire?'#373335':'#3b6e7c');g.addColorStop(1,'#171e2000');c.fillStyle=g;c.fillRect(x-r,y-r,r*2,r*2);}
function crack(c,a,len,alpha,seed){const pts=[[0,0]];for(let j=1;j<=6;j++){const r=len*j/6;const theta=a+(noise(j,seed)-.5)*.16;pts.push([Math.cos(theta)*r,Math.sin(theta)*r]);}line(c,pts,'#86e9f0',1,alpha);for(let j=2;j<5;j++){const p=pts[j],b=a+(j%2?1:-1)*.67;line(c,[p,[p[0]+Math.cos(b)*len*.18,p[1]+Math.sin(b)*len*.18]],'#d5f7eb',.6,alpha*.55);}}
function iceFX(c,age,v){const R=129;
 // A localized flash rather than a screen-sized flash.
 c.globalCompositeOperation='lighter';glow(c,0,0,42+age*130,'#89e9fb',Math.exp(-age*21)*.8);c.globalCompositeOperation='source-over';

  for(let i=0;i<11;i++)crack(c,i/11*TAU, R*(.62+noise(i)*.33)*ease(age/.2),clamp((2.0-age)/1.8)*.5,i+2);
  wave(c,R*ease(age/.18),Math.exp(-age*6),true,2,3.5);
  for(let i=0;i<82;i++){const a=noise(i,2)*TAU,s=32+noise(i,7)*110,r=s*(1-Math.exp(-age*4)),life=.35+noise(i,6)*1.7,alpha=clamp((life-age)/.3);if(alpha<=0)continue;const x=Math.cos(a)*r,y=Math.sin(a)*r+age*age*8;line(c,[[x-Math.cos(a)*9*Math.exp(-age*3),y-Math.sin(a)*9*Math.exp(-age*3)],[x,y]],'#75d6f4',1,alpha*.45);shard(c,x,y,a+age*(noise(i,4)-.5)*9,2+noise(i)*6,alpha,true);}

 // Quiet drifting frost after the initial impact.
 for(let i=0;i<18;i++){const a=noise(i,11)*TAU,r=noise(i,12)*R,q=age-.15;if(q<0)continue;const alpha=Math.sin(clamp(q/2.4)*Math.PI)*.25;puff(c,Math.cos(a)*r+q*8,Math.sin(a)*r-q*8,15+q*8,alpha);}
}
function flame(c,a,r,length,width,alpha,seed){c.save();c.rotate(a);c.globalAlpha=clamp(alpha)*effectFade;const g=c.createLinearGradient(r-length,0,r,0);g.addColorStop(0,'#ffbe4a00');g.addColorStop(.35,'#ff571be0');g.addColorStop(.75,'#ffad37');g.addColorStop(1,'#ffe7a6');c.fillStyle=g;c.beginPath();c.moveTo(r,0);c.bezierCurveTo(r-length*.25,-width,r-length*.65,width*.7,r-length,0);c.bezierCurveTo(r-length*.5,-width*.6,r-length*.25,width*.65,r,0);c.fill();c.restore();}
function fireFX(c,age,v){const R=115;
 // Smoke expands independently, underneath the hot material.
 for(let i=0;i<26;i++){const a=i*2.39996,delay=noise(i,4)*.13,q=age-delay;if(q<0)continue;const r=(22+noise(i,2)*80)*ease(q/1.1),alpha=clamp(q/.16)*clamp((2.2-q)/.8)*.58;puff(c,Math.cos(a)*r,Math.sin(a)*r-q*14,16+q*23,alpha,true);}
 c.globalCompositeOperation='lighter';glow(c,0,0,25+R*ease(age/.19),'#fa6b18',Math.exp(-age*5)*.85);glow(c,0,0,12+45*ease(age/.07),'#fff1b9',Math.exp(-age*24));
 // Uneven volumes of hot gas expand, peel apart and cool independently.
 for(let i=0;i<13;i++){const delay=v===1?noise(i,26)*.16:noise(i,26)*.025,q=age-delay;if(q<0)continue;const a=i*2.39996+q*.4,reach=(15+noise(i,27)*52)*ease(q/.3),size=(19+noise(i,28)*20)*(1+q*.7),alpha=clamp(q/.025)*Math.exp(-q*(v===1?4.5:v===2?11:6));const x=Math.cos(a)*reach,y=Math.sin(a)*reach;glow(c,x,y,size*1.55,'#ff5412',alpha*.72);glow(c,x,y,size*.8,'#ffce65',alpha*.75);if(i%3===0)glow(c,x,y,size*.35,'#fff6cd',alpha*.6);}
 c.globalCompositeOperation='source-over';

  wave(c,150*ease(age/.27),Math.exp(-age*10)*.85,false,1,4);wave(c,130*ease(age/.36),Math.exp(-age*8)*.22,false,2,1);
  for(let i=0;i<34;i++){const a=i*2.39996,q=Math.max(0,age-noise(i)*.045),r=(55+noise(i,7)*55)*ease(q/.26),len=(22+noise(i)*32)*Math.exp(-q*2.8);flame(c,a,r,len,9+noise(i)*15,Math.exp(-q*5),i);}

 const count=v===2?125:v===1?65:92;
 c.globalCompositeOperation='lighter';
 for(let i=0;i<count;i++){const a=noise(i,9)*TAU,delay=v===1?noise(i,8)*.4:noise(i,8)*.07,q=age-delay;if(q<0)continue;const speed=45+noise(i,3)*(v===2?155:110),rr=speed*(1-Math.exp(-q*3)),life=.35+noise(i,5)*1.75,alpha=clamp((life-q)/.4);if(alpha<=0)continue;const x=Math.cos(a)*rr,y=Math.sin(a)*rr+q*q*(v===2?18:8),tail=(v===2?19:12)*Math.exp(-q*2);
  line(c,[[x-Math.cos(a)*tail,y-Math.sin(a)*tail],[x,y]],i%4===0?'#ffeabd':'#ff762c',i%7===0?2.2:1,alpha);glow(c,x,y,i%7===0?5:2,'#ffb447',alpha*.4);
 }c.globalCompositeOperation='source-over';
 for(let i=0;i<20;i++){const a=noise(i,15)*TAU,r=(25+noise(i,11)*112)*ease(age/.3),alpha=clamp((1.7-age)/.6);shard(c,Math.cos(a)*r,Math.sin(a)*r+age*age*13,a+age*4,1+noise(i)*2.5,alpha,false);}
}

export function drawArea(view,field){
 const c=view.ctx,ice=field.kind==='frost',age=Math.max(0,field.duration-field.remaining),scale=field.radius/(ice?145:165),fade=clamp(field.remaining/.25);
 effectFade=fade*(view.reduced?.55:1);
 view.at(field.x,field.y,0,()=>{
  c.save();c.scale(scale,scale);if(ice)iceFX(c,age,0);else fireFX(c,age,0);c.restore();
 });
}
