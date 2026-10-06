// Approved original paper artwork, reflected about the flight axis. The seal
// is drawn separately from an untouched red texture sample so it stays round.
export function symmetricArrow(ctx, atlas, size, drawOriginal) {
  for(const sign of [1,-1]) {
    ctx.save();ctx.scale(1,sign);ctx.beginPath();ctx.rect(-size,0,size*2,size);ctx.clip();
    drawOriginal();ctx.restore();
  }
  const scale=size/62,r=6.15*scale,x=4.1*scale;
  ctx.save();ctx.beginPath();ctx.arc(x,0,r,0,Math.PI*2);ctx.clip();
  ctx.drawImage(atlas,183,181,38,38,x-r,-r,2*r,2*r);ctx.restore();
}
