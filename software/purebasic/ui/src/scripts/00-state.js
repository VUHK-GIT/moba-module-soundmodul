/* SPDX-License-Identifier: MIT
 * Copyright (c) 2026 Sven Häber
 */

const $=id=>document.getElementById(id);
const ui={
 statusChip:$("statusChip"),connectionTitle:$("connectionTitle"),connectionSub:$("connectionSub"),
 modeSoftware:$("modeSoftware"),modeInputs:$("modeInputs"),automation:$("automation"),
 randomMin:$("randomMin"),randomMinUnit:$("randomMinUnit"),randomMinUp:$("randomMinUp"),randomMinDown:$("randomMinDown"),
 randomMax:$("randomMax"),randomMaxUnit:$("randomMaxUnit"),randomMaxUp:$("randomMaxUp"),randomMaxDown:$("randomMaxDown"),
 soundGrid:$("soundGrid"),nowState:$("nowState"),nowDetail:$("nowDetail"),queueCount:$("queueCount"),
 volumeValue:$("volumeValue"),volumeSlider:$("volumeSlider"),volumeMinus:$("volumeMinus"),volumePlus:$("volumePlus"),
 resetButton:$("resetButton"),portValue:$("portValue"),firmwareValue:$("firmwareValue"),busyValue:$("busyValue"),
 triggerValue:$("triggerValue"),mediaTitle:$("mediaTitle"),mediaText:$("mediaText"),
 portSelect:$("portSelect"),connectButton:$("connectButton"),
 searchButton:$("searchButton"),reloadButton:$("reloadButton"),mediaButton:$("mediaButton"),
 queueGrid:$("queueGrid"),inputStrip:$("inputStrip"),notice:$("notice"),noticeTitle:$("noticeTitle"),noticeText:$("noticeText")
};
let state={},configUpdating=false,lastNotice=-1,noticeTimer=0;
const pendingDurationMs=2500;

function invoke(action,value=""){try{window.pbAction(String(action),String(value));}catch(error){}}
function clamp(value,min,max){return Math.max(min,Math.min(max,Number(value)||0));}
function unitMaximum(unit){return unit==="m"?1440:86400;}
function secondsFrom(value,unit){const number=clamp(parseInt(value,10),1,unitMaximum(unit));return unit==="m"?number*60:number;}
function displayDuration(seconds){
 const value=clamp(seconds,1,86400);
 return value>=60&&value%60===0?{value:value/60,unit:"m"}:{value:value,unit:"s"};
}
function fieldProtected(element){
 return document.activeElement===element || Number(element.dataset.pendingUntil||0)>Date.now();
}
function editorProtected(input,unit){
 return fieldProtected(input)||fieldProtected(unit);
}
function markPending(...elements){
 const until=String(Date.now()+pendingDurationMs);
 elements.forEach(element=>{if(element)element.dataset.pendingUntil=until;});
}
function setEditorFromState(input,unit,duration){
 if(editorProtected(input,unit))return;
 input.value=String(duration.value);
 input.dataset.lastValid=String(duration.value);
 unit.value=duration.unit;
}
function cleanNumericInput(input){
 const cleaned=input.value.replace(/[^0-9]/g,"").slice(0,5);
 if(input.value!==cleaned)input.value=cleaned;
}
function normalizeTimeInput(input,unit){
 const fallback=parseInt(input.dataset.lastValid||"1",10)||1;
 const maximum=unitMaximum(unit.value);
 const parsed=parseInt(input.value,10);
 const value=Number.isFinite(parsed)?clamp(parsed,1,maximum):clamp(fallback,1,maximum);
 input.value=String(value);
 input.dataset.lastValid=String(value);
 return value;
}
function stepTime(input,unit,delta,commit){
 const current=parseInt(input.value,10);
 const fallback=parseInt(input.dataset.lastValid||"1",10)||1;
 const value=clamp(Number.isFinite(current)?current+delta:fallback+delta,1,unitMaximum(unit.value));
 input.value=String(value);
 input.dataset.lastValid=String(value);
 markPending(input,unit);
 commit();
}
function showNotice(type,title,text){
 clearTimeout(noticeTimer);ui.notice.className="notice show "+type;ui.noticeTitle.textContent=title;ui.noticeText.textContent=text;
 noticeTimer=setTimeout(()=>ui.notice.classList.remove("show"),3800);
}
function stateLabel(value){return ({READY:"BEREIT",STARTING:"STARTET",PLAYING:"WIEDERGABE",RESETTING:"RESET"})[String(value||"").toUpperCase()]||"OFFLINE";}
function triggerLabel(value,input){
 const map={MANUAL:"Manuell",PERMANENT:"Dauerhaft",RANDOM:"Zufall",INTERVAL:"Intervall",INPUT:"IN"+input,NONE:"–"};
 return map[String(value||"NONE").toUpperCase()]||String(value||"–");
}
function updatePortList(ports,currentPort,probePort){
 const list=Array.isArray(ports)?ports:[];
 const previous=ui.portSelect.value;
 const preferred=currentPort||probePort||previous;
 ui.portSelect.innerHTML="";
 if(!list.length){
  const option=document.createElement("option");
  option.value="";
  option.textContent="Kein COM-Port gefunden";
  ui.portSelect.appendChild(option);
  return;
 }
 list.forEach(port=>{
  const option=document.createElement("option");
  option.value=port;
  option.textContent=port;
  ui.portSelect.appendChild(option);
 });
 if(preferred&&list.includes(preferred))ui.portSelect.value=preferred;
}
function queueItems(value){
 if(!value||value==="-")return[];
 return value.split(",").map(raw=>{const parts=raw.split(":");return{sound:Number(parts[0]),trigger:parts[1]||"NONE",input:Number(parts[2]||0)};});
}
function mediaText(index){
 if(!state.mediaKnown)return{text:"Belegung nicht geprüft",className:""};
 if(index<=Number(state.mediaCount||0))return{text:"Datei "+index+" gemeldet",className:"present"};
 return{text:"Index nicht belegt",className:"missing"};
}
