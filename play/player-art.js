// Approved original paper artwork, reflected about the flight axis. The seal
// is drawn separately from an untouched red texture sample so it stays round.
export function largeSealArrow(ctx, atlas, size, drawOriginal) {
  for(const sign of [1,-1]) {
    ctx.save();ctx.scale(1,sign);ctx.beginPath();ctx.rect(-size,0,size*2,size);ctx.clip();
    drawOriginal();ctx.restore();
  }
  const scale=size/62,r=6.15*scale,x=4.1*scale;
  ctx.save();ctx.beginPath();ctx.arc(x,0,r,0,Math.PI*2);ctx.clip();
  ctx.drawImage(atlas,183,181,38,38,x-r,-r,2*r,2*r);ctx.restore();
}

const smallSeals=new WeakMap();
function prepareSmallSeal(ctxOriginal, atlas, drawOriginal){
    // Preview only: keep the production renderer and iOS candidate untouched.
    const image=document.createElement('canvas');image.width=image.height=360;
    const ctx=image.getContext('2d');
    ctx.translate(180,180);ctx.scale(4,4);
    for(const sign of [1,-1]){
      ctx.save();ctx.scale(1,sign);ctx.beginPath();ctx.rect(-45,0,90,45);ctx.clip();
      drawOriginal(ctx);ctx.restore();
    }

    // Remove only the red pigment before placing the centered original-size seal.
    // Use nearby paper from the same untouched atlas, retaining alpha/body outline.
    const paper=document.createElement('canvas');paper.width=paper.height=32;
    const pc=paper.getContext('2d');pc.drawImage(atlas,187,246,25,25,0,0,32,32);
    const pd=pc.getImageData(0,0,32,32).data, pixels=ctx.getImageData(0,0,360,360);
    for(let y=0;y<360;y++)for(let x=0;x<360;x++){
      const i=(y*360+x)*4,r=pixels.data[i],g=pixels.data[i+1],b=pixels.data[i+2];
      if(r>100&&r>g*1.3&&r>b*1.3){
        const p=((y%32)*32+x%32)*4;
        for(let k=0;k<3;k++)pixels.data[i+k]=pd[p+k];
      }
    }
    ctx.putImageData(pixels,0,0);
    // Original atlas seal: 76 px diameter in a 443.5 px cell rendered at 62 units.
    const radius=38*62/443.5,x=4.1;
    ctx.save();ctx.beginPath();ctx.arc(x,0,radius,0,Math.PI*2);ctx.clip();
    ctx.drawImage(atlas,183,181,38,38,x-radius,-radius,radius*2,radius*2);ctx.restore();
    return image;
  }

export function symmetricArrow(ctx, atlas, size, drawOriginal) {
  let image=smallSeals.get(atlas);
  if(!image){
    // Renderer callback accepts a temporary target context, preserving its state.
    image=prepareSmallSeal(ctx,atlas,drawOriginal);smallSeals.set(atlas,image);
  }
  const s=size/62;ctx.drawImage(image,-45*s,-45*s,90*s,90*s);
}
