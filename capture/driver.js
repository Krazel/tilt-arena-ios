// Capture-only input player. Receives a snapshot, never the mutable game or RNG.
// No spawn, damage, power, clock or score overrides. Not bundled in production.
(function(root) {
  const clamp=(x,a,b)=>Math.max(a,Math.min(b,x));
  let previous=new Map(),previousTime=0,lastDecision=-1,input=[0,0],targetId;
  function next(f,b) {
    if(f.time-lastDecision<0.075)return input;
    lastDecision=f.time;
    const p=f.player,dt=f.time-previousTime;
    const threats=f.enemies.filter(e=>!e.frozen).map(e=>{
      const old=previous.get(e.id);
      const vx=old&&dt>0?(e.x-old.x)/dt:0,vy=old&&dt>0?(e.y-old.y)/dt:0;
      return {...e,vx:clamp(vx,-120,120),vy:clamp(vy,-120,120)};
    });
    previous=new Map(f.enemies.map(e=>[e.id,e]));previousTime=f.time;
    const protectedNow=p.spikesUntil>f.time+0.6||p.bubble||p.burnUntil>f.time||p.fireChargeUntil>f.time;
    let target=f.pickups.find(o=>o.id===targetId);
    if(!target) {
      const ranked=f.pickups.map(o=>({o,c:Math.hypot(o.x-p.x,o.y-p.y)+
        threats.reduce((s,e)=>s+(Math.hypot(e.x-o.x,e.y-o.y)<70?120:0),0)}));
      ranked.sort((a,z)=>a.c-z.c);target=ranked[0]?.o;targetId=target?.id;
    }
    target=target||{x:(b.left+b.right)/2,y:(b.bottom+b.top)/2};
    const angle=Math.atan2(target.y-p.y,target.x-p.x);
    const candidates=[[0,0]];
    for(const speed of [1,0.6]) {
      candidates.push([Math.cos(angle)*speed,Math.sin(angle)*speed]);
      for(let i=0;i<24;i++)candidates.push([Math.cos(i*Math.PI/12)*speed,Math.sin(i*Math.PI/12)*speed]);
    }
    let best=Infinity;
    for(const c of candidates) {
      let cost=0;
      for(const t of [0.09,0.20,0.36]) {
        const ease=(1-Math.exp(-22*t))/22;
        const x=p.x+c[0]*600*t+(p.vx-c[0]*600)*ease;
        const y=p.y+c[1]*600*t+(p.vy-c[1]*600)*ease;
        const edge=Math.min(x-b.left,b.right-x,y-b.bottom,b.top-y);
        if(edge<26)cost+=(26-edge)*1000;
        const px=clamp(x,b.left+23,b.right-23),py=clamp(y,b.bottom+23,b.top-23);
        cost+=Math.hypot(px-target.x,py-target.y)*(t===0.36?1:0.15);
        if(!protectedNow)for(const e of threats) {
          const d=Math.hypot(px-e.x-e.vx*t,py-e.y-e.vy*t);
          cost+=d<27?100000+(27-d)*5000:d<95?Math.pow((95-d)/68,3)*900:0;
        }
      }
      cost+=12*Math.hypot(c[0]-input[0],c[1]-input[1]);
      if(cost<best){best=cost;input=c;}
    }
    return input;
  }
  root.CaptureDriver={next};
})(globalThis);
