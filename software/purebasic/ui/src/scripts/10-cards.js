/* SPDX-License-Identifier: MIT
 * Copyright (c) 2026 Sven Häber
 */

function buildCards(){
 for(let index=1;index<=10;index++){
  const card=document.createElement("article");card.className="sound-card";card.dataset.sound=index;
  card.innerHTML=`<div class="sound-top">
   <button class="play">▶</button>
   <div class="sound-name"><strong>Sound ${index}</strong><small>Index ${index} · IN${index}</small><span class="media-state"></span></div>
  </div>
  <div class="options">
   <label class="check-row"><input class="permanent" type="checkbox"><span>Dauerhaft</span></label>
   <label class="check-row"><input class="random" type="checkbox"><span>Zufällig</span></label>
   <label class="check-row"><input class="interval" type="checkbox"><span>Intervall</span></label>
   <span class="interval-time time-editor">
    <input class="intervalValue time-number" type="text" inputmode="numeric" pattern="[0-9]*" autocomplete="off" aria-label="Intervallwert">
    <span class="step-stack">
      <button class="time-step intervalUp" type="button" aria-label="Intervall erhöhen">▲</button>
      <button class="time-step intervalDown" type="button" aria-label="Intervall verringern">▼</button>
    </span>
    <select class="intervalUnit" aria-label="Intervalleinheit"><option value="s">Sek.</option><option value="m">Min.</option></select>
   </span>
  </div>
  <div class="card-state"><span class="modeText">nicht geplant</span><b class="run-badge">LÄUFT</b></div>`;
  card.querySelector(".play").addEventListener("click",()=>invoke("play",index));
  ["permanent","random","interval"].forEach(className=>card.querySelector("."+className).addEventListener("change",()=>sendConfig(card)));
  const intervalInput=card.querySelector(".intervalValue");
  const intervalUnit=card.querySelector(".intervalUnit");
  intervalInput.addEventListener("input",()=>cleanNumericInput(intervalInput));
  intervalInput.addEventListener("keydown",event=>{if(event.key==="Enter"){event.preventDefault();intervalInput.blur();}});
  intervalInput.addEventListener("blur",()=>{normalizeTimeInput(intervalInput,intervalUnit);markPending(intervalInput,intervalUnit);sendConfig(card);});
  intervalUnit.addEventListener("change",()=>{normalizeTimeInput(intervalInput,intervalUnit);markPending(intervalInput,intervalUnit);sendConfig(card);});
  card.querySelector(".intervalUp").addEventListener("click",()=>stepTime(intervalInput,intervalUnit,1,()=>sendConfig(card)));
  card.querySelector(".intervalDown").addEventListener("click",()=>stepTime(intervalInput,intervalUnit,-1,()=>sendConfig(card)));
  ui.soundGrid.appendChild(card);

  const input=document.createElement("div");input.id="input"+index;input.className="input-tile";input.textContent="IN"+index;ui.inputStrip.appendChild(input);
 }
}
function sendConfig(card){
 if(configUpdating)return;
 const sound=Number(card.dataset.sound);
 const permanent=card.querySelector(".permanent").checked?1:0;
 const randomEnabled=card.querySelector(".random").checked?1:0;
 const intervalEnabled=card.querySelector(".interval").checked?1:0;
 const intervalInput=card.querySelector(".intervalValue");
 const intervalUnit=card.querySelector(".intervalUnit");
 const seconds=secondsFrom(normalizeTimeInput(intervalInput,intervalUnit),intervalUnit.value);
 markPending(intervalInput,intervalUnit);
 invoke("sound-config",[sound,permanent,randomEnabled,intervalEnabled,seconds].join("|"));
}
function sendRandomRange(){
 if(configUpdating)return;
 const minimumValue=normalizeTimeInput(ui.randomMin,ui.randomMinUnit);
 const maximumValue=normalizeTimeInput(ui.randomMax,ui.randomMaxUnit);
 const minimum=secondsFrom(minimumValue,ui.randomMinUnit.value);
 const maximum=secondsFrom(maximumValue,ui.randomMaxUnit.value);
 if(maximum<minimum){
  showNotice("warning","Zeitbereich","Das Maximum muss mindestens dem Minimum entsprechen.");
  return;
 }
 markPending(ui.randomMin,ui.randomMinUnit,ui.randomMax,ui.randomMaxUnit);
 invoke("random-range",minimum+"|"+maximum);
}
