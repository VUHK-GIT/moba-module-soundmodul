/* SPDX-License-Identifier: MIT
 * Copyright (c) 2026 Sven Häber
 */

function applyLock(current){
 const connected=!!current.connected,locked=!!current.playbackLocked,resetting=!!current.resetting;
 const software=current.controlMode==="SOFTWARE";
 const operationBlocked=locked||resetting;
 const controlBlocked=!connected||operationBlocked;
 ui.modeSoftware.disabled=controlBlocked;ui.modeInputs.disabled=controlBlocked;
 ui.automation.disabled=controlBlocked||!software;
 ui.randomMin.disabled=controlBlocked||!software;ui.randomMinUnit.disabled=controlBlocked||!software;
 ui.randomMinUp.disabled=controlBlocked||!software;ui.randomMinDown.disabled=controlBlocked||!software;
 ui.randomMax.disabled=controlBlocked||!software;ui.randomMaxUnit.disabled=controlBlocked||!software;
 ui.randomMaxUp.disabled=controlBlocked||!software;ui.randomMaxDown.disabled=controlBlocked||!software;
 ui.portSelect.disabled=operationBlocked||ui.portSelect.options.length===0||ui.portSelect.value==="";
 ui.connectButton.disabled=operationBlocked||ui.portSelect.options.length===0||ui.portSelect.value==="";
 ui.searchButton.disabled=operationBlocked;
 ui.reloadButton.disabled=controlBlocked;
 ui.mediaButton.disabled=controlBlocked||!!current.automationEnabled||Number(current.queueCount)>0;
 document.querySelectorAll(".sound-card").forEach(card=>{
   card.querySelector(".play").disabled=controlBlocked||!software;
   card.querySelectorAll(".options input,.options select,.options button").forEach(element=>element.disabled=controlBlocked||!software);
 });
 ui.resetButton.disabled=!connected||resetting;
 ui.volumeSlider.disabled=!connected||resetting;
 ui.volumeMinus.disabled=!connected||resetting;
 ui.volumePlus.disabled=!connected||resetting;
}
window.applyState=function(current){
 state=current||{};configUpdating=true;
 const connected=!!current.connected,locked=!!current.playbackLocked,activeSound=Number(current.current)||0;
 ui.statusChip.className="status-chip "+(locked?"playing":connected?"good":"error");
 const scanPosition=Math.min(Number(current.scanIndex||0)+1,Number(current.scanCount||0));
 ui.connectionTitle.textContent=current.scanning?"Automatische COM-Suche läuft":locked?"Sound "+activeSound+" läuft":connected?"Soundmodul bereit":"Nicht verbunden";
 ui.connectionSub.textContent=locked?"Nur Reset und Lautstärke sind bedienbar":
   current.scanning?((scanPosition||1)+" / "+(Number(current.scanCount)||1)+" · "+(current.probePort||current.statusText||"COM-Port wird geprüft")):
   connected?(current.port+" · "+current.firmware):(current.statusText||"Nano nicht gefunden");
 updatePortList(current.availablePorts,current.port,current.probePort);
 {
 const title=ui.searchButton.querySelector("span");
 const description=ui.searchButton.querySelector("small");
 if(title)title.textContent=current.scanning?"COM-Suche neu starten":"COM-Ports neu suchen";
 if(description)description.textContent=current.scanning?
  "Aktuelle Suche abbrechen und erneut beginnen":
  "Alle vorhandenen Anschlüsse prüfen";
}

 ui.modeSoftware.checked=current.controlMode==="SOFTWARE";ui.modeInputs.checked=current.controlMode==="INPUTS";
 ui.automation.checked=!!current.automationEnabled;
 const randomMinimum=displayDuration(Number(current.randomMinSeconds)||120);
 const randomMaximum=displayDuration(Number(current.randomMaxSeconds)||600);
 setEditorFromState(ui.randomMin,ui.randomMinUnit,randomMinimum);
 setEditorFromState(ui.randomMax,ui.randomMaxUnit,randomMaximum);

 ui.nowState.textContent=stateLabel(current.deviceState);
 ui.nowDetail.textContent=locked?("Sound "+activeSound+" · "+triggerLabel(current.currentTrigger,current.currentInput)):
   (current.controlMode==="INPUTS"?"PC ist im Eingangsmodus.":"PC-Steuerung bereit.");
 ui.queueCount.textContent=Number(current.queueCount)||0;
 ui.volumeValue.textContent=Number(current.volume)||0;ui.volumeSlider.value=Number(current.volume)||0;
 ui.portValue.textContent=current.port||"–";ui.firmwareValue.textContent=current.firmware||"–";
 ui.busyValue.textContent=connected?(current.busyRaw+" / "+(current.busy?"HIGH":"LOW")):"–";
 ui.triggerValue.textContent=triggerLabel(current.currentTrigger,current.currentInput);

 if(current.mediaKnown){
   ui.mediaTitle.textContent="JQ-Dateien: "+Number(current.mediaCount)+" gemeldet";
   ui.mediaText.textContent=Number(current.mediaCount)===0?"Keine Datei gemeldet oder keine Antwort erhalten.":"Belegung aus Anzahl abgeleitet; Namen sind nicht auslesbar.";
 }else{
   ui.mediaTitle.textContent="JQ-Dateien: nicht geprüft";
   ui.mediaText.textContent="Dateianzahl ist Diagnose; Dateinamen sind intern nicht auslesbar.";
 }

 const configurations=Array.isArray(current.soundConfigs)?current.soundConfigs:[];
 document.querySelectorAll(".sound-card").forEach(card=>{
  const index=Number(card.dataset.sound),configuration=configurations.find(item=>Number(item.sound)===index)||{};
  card.classList.toggle("active",locked&&activeSound===index);
  card.querySelector(".permanent").checked=!!configuration.permanent;
  card.querySelector(".random").checked=!!configuration.random;
  card.querySelector(".interval").checked=!!configuration.interval;
  const duration=displayDuration(Number(configuration.intervalSeconds)||300);
  setEditorFromState(card.querySelector(".intervalValue"),card.querySelector(".intervalUnit"),duration);
  const labels=[];if(configuration.permanent)labels.push("Dauer");if(configuration.random)labels.push("Zufall");
  if(configuration.interval)labels.push(duration.value+(duration.unit==="m"?" Min.":" Sek."));
  card.querySelector(".modeText").textContent=labels.length?labels.join(" · "):"nicht geplant";
  const media=mediaText(index),mediaElement=card.querySelector(".media-state");
  mediaElement.textContent=media.text;mediaElement.className="media-state "+media.className;
 });

 const items=queueItems(current.queueItems);ui.queueGrid.innerHTML="";
 if(!items.length)ui.queueGrid.innerHTML='<div class="empty">Keine wartenden Sounds.</div>';
 items.slice(0,10).forEach((item,index)=>{
   const row=document.createElement("div");row.className="queue-item";
   row.innerHTML="<span>"+(index+1)+". Sound "+item.sound+"</span><b>"+triggerLabel(item.trigger,item.input)+"</b>";
   ui.queueGrid.appendChild(row);
 });

 const mask=Number(current.inputMask)||0;
 for(let index=1;index<=10;index++)$("input"+index).classList.toggle("on",(mask&(1<<(index-1)))!==0);

 if(Number(current.noticeId)!==lastNotice){
   lastNotice=Number(current.noticeId);
   if(current.notice)showNotice(current.noticeType||"info",current.noticeType==="error"?"Fehler":current.noticeType==="warning"?"Hinweis":"Status",current.notice);
 }
 configUpdating=false;applyLock(current);
};
