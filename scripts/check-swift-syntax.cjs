// Syntax only; this does not resolve Apple SDK types or replace xcodebuild.
const fs=require('node:fs'),path=require('node:path');
const {Parser,Language}=require('web-tree-sitter');
(async()=>{
  await Parser.init();const parser=new Parser();
  parser.setLanguage(await Language.load(require.resolve('tree-sitter-wasms/out/tree-sitter-swift.wasm')));
  let failures=0;
  for(const subfolder of ['Sources','Tests']) {
  const folder=path.join(__dirname,'../native-ios',subfolder);
  for(const file of fs.readdirSync(folder).filter(f=>f.endsWith('.swift'))){
    const tree=parser.parse(fs.readFileSync(path.join(folder,file),'utf8'));
    const errors=[];
    function visit(n){if(n.type==='ERROR'||n.isMissing)errors.push(`${file}:${n.startPosition.row+1}:${n.startPosition.column+1} ${n.type} ${n.text.slice(0,100)}`);else for(const c of n.children)visit(c);}
    visit(tree.rootNode);failures+=errors.length;console.log(errors.length?errors.join('\n'):`Syntax OK: ${file}`);tree.delete();
  }
  }
  parser.delete();process.exitCode=failures?1:0;
})().catch(e=>{console.error(e);process.exitCode=1});
