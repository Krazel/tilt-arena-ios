const clamp=x=>Math.max(0,Math.min(1,x));
const noise=(i,s)=>{const n=Math.sin(i*127.1+s*311.7)*43758.5453;return n-Math.floor(n);};
export function lightningA(e,age){
  const style='branches';
  const c=this.ctx,life=style==='surge'?.38:.55,fade=clamp(1-age/life);if(!fade)return;
  const violet=style==='violet',color=violet?'#b7a0ff':'#65bdff';
  c.save();c.globalCompositeOperation='lighter';
  this.at(e.x,e.y,0,()=>{
   if(e.kind==='electricPulse'){
    c.globalAlpha=Math.exp(-age*24)*.6;this.ring(18+age*90,color,5);
    c.globalAlpha=fade*.22;this.ring(14+130*(1-Math.exp(-age*9)),color,1.5);return;
   }
   const dx=e.toX-e.x,dy=e.y-e.toY,len=Math.max(1,Math.hypot(dx,dy)),seed=Math.floor(age*(this.reduced?0:28));
   const points=[[0,0]],segments=Math.max(5,Math.ceil(len/15));
   for(let i=1;i<segments;i++){const j=violet?Math.sin(i/segments*Math.PI*4-age*22)*Math.sin(i/segments*Math.PI)*13:(noise(i+Math.floor(e.x),seed)-.5)*(style==='surge'?15:27);points.push([dx*i/segments-dy/len*j,dy*i/segments+dx/len*j]);}points.push([dx,dy]);
   c.globalAlpha=fade*.22;c.shadowColor=color;c.shadowBlur=this.reduced?0:13;this.path(points,color,style==='surge'?14:8);
   c.shadowBlur=0;c.globalAlpha=fade;this.path(points,style==='surge'?'#ffffff':'#e6f7ff',style==='surge'?3.2:1.8);
   if(style==='branches'){for(let i=2;i<points.length-1;i+=3){const p=points[i],sign=i%2?1:-1;c.globalAlpha=fade*.6;this.path([p,[p[0]-dy/len*sign*19-dx/len*8,p[1]+dx/len*sign*19-dy/len*8],[p[0]-dy/len*sign*29,p[1]+dx/len*sign*29]],color,1.2);}}
   c.globalAlpha=Math.exp(-age*14);
   c.save();c.translate(dx,dy);this.ring(4+age*44,color,2);for(let i=0;i<(this.reduced?3:7);i++){const a=i*2.39996,r=age*65;c.globalAlpha=fade*.7;this.path([[Math.cos(a)*r,Math.sin(a)*r],[Math.cos(a)*(r+7),Math.sin(a)*(r+7)]],color,1.5);}c.restore();
  });c.restore();
}
