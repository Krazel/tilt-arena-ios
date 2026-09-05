const fs=require('node:fs'),path=require('node:path');
const states=[['MENÚ','CLÁSICO','Esquiva los puntos. Alcanza las armas.','RÉCORD  38.570','Calibrar y jugar','Normal    ·    Sonido'],
['CALIBRACIÓN','Busca tu postura','Mantén el iPhone quieto y cómodo un instante.','◌','Calibrando…','Volver'],
['PAUSA','PAUSA','La arena te espera.','','Calibrar y continuar','Normal    ·    Sonido    ·    Terminar partida'],
['RESULTADO','Por un punto…','38.570','COMBO ×42    ·    68 s','Otra partida','Menú']];
let body='';
for(let i=0;i<4;i++){
 const x=32+(i%2)*876,y=100+Math.floor(i/2)*444,s=states[i];
 body+=`<g transform="translate(${x} ${y})"><text x="0" y="-14" fill="#c9d5ad" font-size="15" letter-spacing="2">${s[0]} · MAQUETA</text><rect width="844" height="390" rx="20" fill="#344b1b"/><rect x="145" y="24" width="554" height="342" rx="15" fill="#648027" stroke="#d8e9b080"/><g opacity=".5"><circle cx="235" cy="170" r="5" fill="#ff5658"/><circle cx="580" cy="285" r="5" fill="#ff5658"/></g><rect width="844" height="390" rx="20" fill="#0006"/><rect x="207" y="26" width="430" height="338" rx="22" fill="#172613" stroke="#cfe67950"/><text x="422" y="63" text-anchor="middle" fill="#d1f563" font-size="11" letter-spacing="4">KRAZEL GAMES</text><text x="422" y="114" text-anchor="middle" fill="#f4f7e9" font-size="${i===1?28:38}" font-weight="800">${s[1]}</text><text x="422" y="159" text-anchor="middle" fill="#d8dfcb" font-size="${i===3?34:15}">${s[2]}</text><text x="422" y="202" text-anchor="middle" fill="#d8dfcb" font-size="18">${s[3]}</text><rect x="233" y="227" width="378" height="46" rx="12" fill="#d1f563"/><text x="422" y="256" text-anchor="middle" fill="#18260d" font-size="17" font-weight="700">${s[4]}</text><text x="422" y="318" text-anchor="middle" fill="#d8dfcb" font-size="14">${s[5]}</text></g>`;
}
const svg=`<svg xmlns="http://www.w3.org/2000/svg" width="1784" height="1014" viewBox="0 0 1784 1014"><rect width="1784" height="1014" fill="#10190c"/><g font-family="Arial,sans-serif"><text x="32" y="43" font-size="25" fill="#eef5df" font-weight="700">Krazel Games · Classic 0.2.0 — referencia de estados</text><text x="32" y="70" font-size="15" fill="#acb99a">Propuesta local ES · iPhone horizontal 844 × 390 · No son capturas de una build nativa</text>${body}</g></svg>`;
fs.mkdirSync(path.join(__dirname,'../design'),{recursive:true});fs.writeFileSync(path.join(__dirname,'../design/states.svg'),svg);
console.log('Saved 4 full visual state references.');
