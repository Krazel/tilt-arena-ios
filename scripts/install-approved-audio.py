"""Package only the user's approved audio; preserve the audition originals."""
import pathlib,json,shutil,wave,hashlib
ROOT=pathlib.Path(__file__).resolve().parents[1]
proposal=ROOT/'design/audio-proposals/2026-09-23'
dest=ROOT/'native-ios/Resources'
catalog=json.loads((proposal/'catalog.json').read_text(encoding='utf-8'))
options={o['id']:o for g in catalog['groups'] for o in g['options']}
chosen={'ui':'click-A','pickup':'pickup-A','hit':'kill-A','vortex':'vortex-A','lightning':'lightning-A','shatter-a':'shatter-A','shatter-b':'shatter-B','bounce':'bounce-B','burn':'burn-A','boomerang':'boomerang-A','music-menu':'music-menu-A','music-a':'music-play-A','music-b':'music-play-B','music-c':'music-play-C'}
decisions=json.loads((proposal/'approved-decisions.json').read_text(encoding='utf-8'))
approved={d['id'] for d in decisions['decisions'] if d['vote']=='yes'}
assert set(chosen.values())==approved
manifest={'version':1,'menu':'music-menu','playlist':['music-a','music-b','music-c'],'assets':{},'silent':['death','warning','combo','nuke','wave','missiles','frost','bubble','spikes']}
volumes={'ui':.7,'pickup':.65,'hit':.4,'vortex':.2,'lightning':.55,'shatter-a':.5,'shatter-b':.5,'bounce':.45}
for name,id in chosen.items():
 o=options[id];src=proposal/o['src'];source=catalog['sources'][o['sourceId']]
 names=[name+'-charge',name+'-launch'] if name in ['burn','boomerang'] else [name]
 for key in names:
  file='audio-'+key+src.suffix;out=dest/file
  if len(names)==2:
   with wave.open(str(src),'rb') as w:
    params=w.getparams();data=w.readframes(w.getnframes());cut=round(.5*w.getframerate())*w.getnchannels()*w.getsampwidth()
   with wave.open(str(out),'wb') as w:
    w.setparams(params);w.writeframes(data[:cut] if key.endswith('charge') else data[cut:])
  else:shutil.copyfile(src,out)
  manifest['assets'][key]={'file':file,'volume':.3 if key.startswith('music') else volumes.get(key,.6),'proposal':id,'author':source['author'],'source':source['source'],'license':source['license'],'changes':o['edits']+(' Split at 0.5 s to synchronize with simulation charge/release events.' if len(names)==2 else ''),'sha256':hashlib.sha256(out.read_bytes()).hexdigest()}
(dest/'audio-approved.json').write_bytes(json.dumps(manifest,indent=2,ensure_ascii=False).encode('utf-8'))
credits=['TILT ARENA — AUDIO CREDITS','', 'Music by PeriTune / Sei Mutsuki','Ametsuchi, Kengeki, Conjurer (instrumental), Oboro2.','Licensed under CC BY 4.0: https://creativecommons.org/licenses/by/4.0/','Pre-March 2026 works retain CC BY 4.0: https://peritune.com/about/','Changes: volume normalization and MP3 encoding.','']
for id in ['music-play-A','music-play-B','music-play-C','music-menu-A']:
 credits.append(catalog['sources'][options[id]['sourceId']]['source'])
credits+=['','Torch Fire Spell / Waving Torch by spookymodem','https://opengameart.org/content/torch-fire-spell','CC BY 3.0: https://creativecommons.org/licenses/by/3.0/','Changes: trimmed, leveled, faded; derived 0.5-second reversed charge; split charge and release.','','Other sound effects (CC0):','Kenney — Interface Sounds, Impact Sounds, RPG Audio','https://kenney.nl/assets/interface-sounds','https://kenney.nl/assets/impact-sounds','https://kenney.nl/assets/rpg-audio','rubberduck — 50 CC0 Sci-Fi SFX','https://opengameart.org/content/50-cc0-sci-fi-sfx','IgnasD — Ice breaking/shattering','https://opengameart.org/content/ice-breakingshattering','Augmentality (Brandon Morris), submitted by HaelDB — Spell sounds','https://opengameart.org/content/spell-sounds','CC0: https://creativecommons.org/publicdomain/zero/1.0/','Changes: trimming, volume adjustment and short fades; derived boomerang charge.','','No endorsement by the original authors is implied.']
(dest/'Audio-Credits.txt').write_bytes(('\n'.join(credits)+'\n').encode('utf-8'))
print('Packaged',len(manifest['assets']),'approved audio assets')
# Preserve the user's later replacement/addition decision when rebuilding the catalog.
import subprocess
subprocess.run(['node',str(ROOT/'scripts/refresh-audio-v058.cjs')],check=True)
