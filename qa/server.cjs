const http=require('node:http'),fs=require('node:fs'),path=require('node:path');
const routes={'/':'qa/index.html','/core.js':'native-ios/Resources/classic-core.js','/states.svg':'design/states.svg'};
for(const name of ['classic-loop','pickup','hit','death'])routes['/'+name+'.wav']='native-ios/Resources/'+name+'.wav';
http.createServer((req,res)=>{
  const pathname=new URL(req.url,'http://127.0.0.1').pathname,resource=routes[pathname];
  if(!resource){res.writeHead(404);res.end('Not found');return;}
  const file=path.join(__dirname,'..',resource);
  res.setHeader('Content-Type',resource.endsWith('.html')?'text/html; charset=utf-8':resource.endsWith('.js')?'text/javascript':resource.endsWith('.svg')?'image/svg+xml':'audio/wav');
  res.setHeader('Cache-Control','no-store');fs.createReadStream(file).pipe(res);
}).listen(4293,'127.0.0.1',()=>console.log('Classic engine QA: http://127.0.0.1:4293 (loopback only)'));
