// Exact iPhone 16 Pro landscape reference used by native v0.3.9/v0.4 captures.
// ClassicScene.configureViewport: captured safe insets 62 pt sides, 20 pt bottom.
const scale=640/402;
export const VIEWPORT=Object.freeze({pointsWidth:874,pointsHeight:402,width:874*scale,height:640,
  left:62*scale+20,right:874*scale-(62*scale+20),bottom:20*scale+26,top:592});
export const ART=Object.freeze({arrow:62,enemy:64,pickup:60*(56/42),classicPickup:56,
  missile:29,wave:135,boomerang:78,vortex:450,fire:80,telegraphScale:1.45,
  boomerangSpin:14,vortexSpin:-1.7});
export function fitViewport(width,height){const scale=Math.min(width/874,height/402);return{width:874*scale,height:402*scale,scale};}
