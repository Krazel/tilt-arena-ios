// Same complete geometry and timings as ClassicAreaEffect. No atlas cropping.
const contours=new Map();
function contour(radius,lobes=0,roughness=0){
  const key=[radius,lobes,roughness].join(':');if(contours.has(key))return contours.get(key);
  const p=new Path2D();for(let i=0;i<120;i++){const a=i/120*Math.PI*2,r=radius*(1+lobes*Math.sin(a*7+.4)+roughness*Math.sin(a*19));if(i)p.lineTo(Math.cos(a)*r,-Math.sin(a)*r);else p.moveTo(Math.cos(a)*r,-Math.sin(a)*r);}p.closePath();contours.set(key,p);return p;
}
export function drawArea(view,field){
  const c=view.ctx,ink=view.theme==='inkTide',ice=field.kind==='frost',r=field.radius,age=Math.max(0,field.duration-field.remaining),fade=Math.min(1,Math.max(0,field.remaining)/.3),tint=ice?'#79d9ed':'#ef8738',light=ink?'#eee4c9':'#fff',spread=1-(1-Math.min(1,age/.24))**3,reduced=view.reduced;
  const paint=(p,fill,stroke,width,fillAlpha=1,strokeAlpha=1)=>{if(fill){c.globalAlpha=fade*fillAlpha;c.fillStyle=fill;c.fill(p);}if(stroke){c.globalAlpha=fade*strokeAlpha;c.strokeStyle=stroke;c.lineWidth=width;c.stroke(p);}};
  view.at(field.x,field.y,0,()=>{
    c.save();if(ice&&!reduced)c.scale(.08+spread*.92,.08+spread*.92);
    paint(contour(r*.96,0,ink?.008:0),tint,tint,1,ice?.035:.065,.24);
    if(ice){
      for(let i=0;i<6;i++){
        c.save();c.rotate(-i*Math.PI/3);const p=new Path2D();p.moveTo(r*.08,0);p.lineTo(r*.86,0);
        for(const reach of [.32,.55,.75])for(const side of [-1,1]){p.moveTo(r*reach,0);p.lineTo(r*(reach-.12),r*.085*side);}
        paint(p,null,tint,1.6,0,reduced?.3:.65);c.restore();
      }
      for(let i=0;i<12;i++){
        const a=i*Math.PI/6+Math.PI/12,d=r*(i%2===0?.57:.37),length=r*(i%2===0?.18:.12),w=length*.22,alpha=reduced?.4:.65+.18*Math.sin(age*4+i);
        c.save();c.translate(Math.cos(a)*d,-Math.sin(a)*d);c.rotate(-a);
        const p=new Path2D();p.moveTo(-length*.45,0);p.lineTo(0,-w);p.lineTo(length,0);p.lineTo(length*.2,w);p.closePath();
        paint(p,i%2===0?tint:light,light,1,alpha*.45,alpha);c.restore();
      }
      const p=new Path2D();for(let i=0;i<12;i++){const a=i*Math.PI/6,d=r*(i%2?.12:.14);if(i)p.lineTo(Math.cos(a)*d,-Math.sin(a)*d);else p.moveTo(d,0);}p.closePath();paint(p,light,tint,1.5,.2,1);
    }else{
      c.save();const scale=reduced?.85:.08+spread*.92,alpha=Math.max(.14,1-age*1.15)*(reduced?.4:1);c.scale(scale,scale);
      for(let i=0;i<3;i++){c.save();c.rotate(-i*.55);paint(contour(r*(.68-i*.17),.12,ink?.025:0),[tint,'#ffc66c',light][i],[tint,'#ffd68a',light][i],1.5,[.28,.48,.8][i]*alpha,alpha);c.restore();}c.restore();
      for(let i=0;i<(reduced?6:16);i++){
        const a=i*2.39996,d=r*(reduced?.65:.16+spread*(.46+(i%3)*.1)),scale=reduced?1:Math.max(.4,1-age*.45);
        c.save();c.translate(Math.cos(a)*d,-Math.sin(a)*d);c.rotate(-a);c.scale(scale,scale);
        const p=new Path2D();p.ellipse(0,0,r*(i%3===0?.095:.055)/2,r*.025/2,0,0,Math.PI*2);paint(p,i%3===0?light:tint,null,0,Math.max(.18,.85-age*.5));c.restore();
      }
    }c.restore();
    for(const [radius,scale,alpha,width,color,rough]of [[r*.97,reduced?1:.12+spread*.88,Math.max(.12,.8-age*.65)*(reduced?.4:1),ice?2:3.5,ice?tint:light,.009],[r*.78,reduced?1:.15+spread*.85,Math.max(.1,.5-age*.45),1.5,tint,.012]]){
      c.save();c.scale(scale,scale);paint(contour(radius,0,ink?rough:0),null,color,width,0,alpha);c.restore();
    }
  });
}
