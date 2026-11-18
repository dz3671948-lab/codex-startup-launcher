'use strict';
const $=id=>document.getElementById(id);
const defaults={name:'CODEX OPERATOR',theme:'dark',effects:true,voice:false};
let settings={...defaults};
try{const s=JSON.parse(localStorage.getItem('startup-settings-v2')||'{}');settings={name:typeof s.name==='string'?s.name.slice(0,32):defaults.name,theme:s.theme==='light'?'light':'dark',effects:s.effects!==false,voice:s.voice===true};}catch{}
const steps=[
 ['READY TO BEGIN','准备好，开始创造','按 Enter 或点击开始，动画将自动播放。'],
 ['YOUR CREATIVE SPACE','你好，创造者','这是你在启动画面中使用的显示名称。'],
 ['A MOMENT OF FOCUS','让灵感就绪','留一点空间，给下一个好想法。'],
 ['BRING IDEAS TO LIFE','从想法，到实现','把问题拆解，让创造发生。'],
 ['READY FOR WHAT’S NEXT','一切，从这里开始','你的下一段探索，即将展开。'],
 ['WELCOME BACK','欢迎回来','正在打开 Codex。']
];
let index=0,started=false,finished=false,timer=null,audio=null,launchSent=false;
const inLauncher=location.protocol==='http:'&&location.hostname==='127.0.0.1';
function clear(){clearTimeout(timer);timer=null;if(window.speechSynthesis)speechSynthesis.cancel();}
function apply(){document.documentElement.dataset.theme=settings.theme;$('logo').src=settings.theme==='light'?'openai-blossom-black.svg':'codex-icon.svg';$('identity').textContent=settings.name||defaults.name;$('sound').textContent='声音：'+(settings.effects||settings.voice?'开':'关');$('sound').setAttribute('aria-pressed',String(settings.effects||settings.voice));}
function save(){try{localStorage.setItem('startup-settings-v2',JSON.stringify(settings));}catch{}}
function unlock(){if(!settings.effects)return;try{audio??=new(window.AudioContext||window.webkitAudioContext)();if(audio.state==='suspended')audio.resume().catch(()=>{});}catch{}}
function chime(final=false){if(!settings.effects||!audio)return;const notes=final?[392,523.25,783.99]:[523.25,659.25];notes.forEach((freq,n)=>{const t=audio.currentTime+n*.12,o=audio.createOscillator(),g=audio.createGain();o.type='sine';o.frequency.value=freq;g.gain.setValueAtTime(.0001,t);g.gain.linearRampToValueAtTime(.04,t+.025);g.gain.exponentialRampToValueAtTime(.0001,t+.36);o.connect(g).connect(audio.destination);o.start(t);o.stop(t+.4);});}
function speak(text){if(!settings.voice||!window.speechSynthesis)return;speechSynthesis.cancel();const u=new SpeechSynthesisUtterance(text);u.lang='zh-CN';u.rate=.9;u.volume=.7;speechSynthesis.speak(u);}
function render(){const s=steps[index],percent=index*20;$('stage').textContent=String(index+1).padStart(2,'0')+' / 06';$('english').textContent=s[0];$('title').textContent=finished?'欢迎回来，'+(settings.name||defaults.name):s[1];$('description').textContent=s[2];$('bar').style.width=percent+'%';document.querySelector('.progress').setAttribute('aria-valuenow',percent);$('action').hidden=started&&(!finished||inLauncher);$('action').innerHTML=finished?'重新播放 <span>↵</span>':'开始体验 <span>↵</span>';$('skip').hidden=finished;$('status').textContent=finished?'正在打开 Codex':started?'自动播放 · '+(index+1)+' / 06':'等待开始';$('hint').textContent=finished?(inLauncher?'动画窗口即将关闭':'播放完成，点击可重播'):started?'动画将自动播放 · Esc 可跳过':'按一次 Enter 或点击开始 · 首次操作后播放声音';}
function notifyLauncher(){if(!inLauncher||launchSent)return;launchSent=true;fetch('/__launch_codex',{method:'POST',keepalive:true}).catch(()=>{$('status').textContent='启动失败，请直接打开 Codex';});}
function finish(){clear();index=5;finished=true;render();chime(true);speak(steps[5][1]);timer=setTimeout(notifyLauncher,1300);}
function next(){if($('panel').open||!started||finished)return;if(index>=4){finish();return;}index++;render();chime();speak(steps[index][1]);timer=setTimeout(next,1450);}
function start(){if($('panel').open||started&&!finished)return;clear();unlock();started=true;finished=false;launchSent=false;index=0;render();chime();timer=setTimeout(next,800);}
$('action').onclick=start;
$('skip').onclick=()=>{if(finished)return;unlock();started=true;finish();};
$('settings').onclick=()=>{$('name').value=settings.name;$('theme').value=settings.theme;$('effects').checked=settings.effects;$('voice').checked=settings.voice;clear();$('panel').showModal();};
$('close').onclick=()=>$('panel').close();
$('panel').addEventListener('close',()=>{if(started&&!finished)timer=setTimeout(next,650);});
$('config').onsubmit=e=>{e.preventDefault();settings={name:$('name').value.trim()||defaults.name,theme:$('theme').value,effects:$('effects').checked,voice:$('voice').checked};apply();save();render();unlock();$('panel').close();};
$('sound').onclick=()=>{const wasOn=settings.effects||settings.voice;settings.effects=!wasOn;settings.voice=false;apply();save();if(wasOn){if(window.speechSynthesis)speechSynthesis.cancel();if(audio)audio.suspend();}else{unlock();chime();}};
document.addEventListener('keydown',e=>{if($('panel').open||e.repeat||/INPUT|SELECT|TEXTAREA/.test(e.target.tagName))return;if(e.key==='Escape'&&!finished){e.preventDefault();$('skip').click();return;}if(e.target.tagName==='BUTTON')return;if(e.key==='Enter'||e.code==='Space'){e.preventDefault();start();}});
const canvas=$('stars'),ctx=canvas.getContext('2d');
function drawStars(){const d=Math.min(devicePixelRatio||1,2),w=innerWidth,h=innerHeight;canvas.width=w*d;canvas.height=h*d;ctx.setTransform(d,0,0,d,0,0);ctx.clearRect(0,0,w,h);let seed=91;const rand=()=>{seed=seed*16807%2147483647;return(seed-1)/2147483646;};for(let i=0;i<Math.min(65,Math.floor(w*h/22000));i++){const x=rand()*w,y=rand()*h,r=.4+rand()*.8,a=.1+rand()*.24;if(Math.abs(x-w/2)<w*.27&&Math.abs(y-h/2)<h*.31)continue;ctx.fillStyle=document.documentElement.dataset.theme==='light'?'rgba(60,70,90,'+a+')':'rgba(210,221,233,'+a+')';ctx.beginPath();ctx.arc(x,y,r,0,Math.PI*2);ctx.fill();}}
addEventListener('resize',drawStars);apply();render();drawStars();
