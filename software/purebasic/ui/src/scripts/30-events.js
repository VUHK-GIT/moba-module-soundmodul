/* SPDX-License-Identifier: MIT
 * Copyright (c) 2026 Sven Häber
 */

ui.modeSoftware.addEventListener("change",()=>ui.modeSoftware.checked&&invoke("mode","SOFTWARE"));
ui.modeInputs.addEventListener("change",()=>ui.modeInputs.checked&&invoke("mode","INPUTS"));
ui.automation.addEventListener("change",()=>invoke("automation",ui.automation.checked?1:0));
[ui.randomMin,ui.randomMax].forEach(input=>{
 input.addEventListener("input",()=>cleanNumericInput(input));
 input.addEventListener("keydown",event=>{if(event.key==="Enter"){event.preventDefault();input.blur();}});
 input.addEventListener("blur",sendRandomRange);
});
[ui.randomMinUnit,ui.randomMaxUnit].forEach(unit=>unit.addEventListener("change",sendRandomRange));
ui.randomMinUp.addEventListener("click",()=>stepTime(ui.randomMin,ui.randomMinUnit,1,sendRandomRange));
ui.randomMinDown.addEventListener("click",()=>stepTime(ui.randomMin,ui.randomMinUnit,-1,sendRandomRange));
ui.randomMaxUp.addEventListener("click",()=>stepTime(ui.randomMax,ui.randomMaxUnit,1,sendRandomRange));
ui.randomMaxDown.addEventListener("click",()=>stepTime(ui.randomMax,ui.randomMaxUnit,-1,sendRandomRange));
ui.volumeSlider.addEventListener("input",()=>ui.volumeValue.textContent=ui.volumeSlider.value);
ui.volumeSlider.addEventListener("change",()=>invoke("volume",clamp(ui.volumeSlider.value,0,30)));
ui.volumeMinus.addEventListener("click",()=>invoke("volume",clamp(Number(ui.volumeSlider.value)-1,0,30)));
ui.volumePlus.addEventListener("click",()=>invoke("volume",clamp(Number(ui.volumeSlider.value)+1,0,30)));
ui.resetButton.addEventListener("click",()=>invoke("reset"));
ui.connectButton.addEventListener("click",()=>invoke("connect-port",ui.portSelect.value));
ui.portSelect.addEventListener("change",()=>applyLock(state));
ui.searchButton.addEventListener("click",()=>invoke("search"));
ui.reloadButton.addEventListener("click",()=>invoke("reload-config"));
ui.mediaButton.addEventListener("click",()=>invoke("media-scan"));

buildCards();applyLock({connected:false,scanning:true});invoke("ready");
