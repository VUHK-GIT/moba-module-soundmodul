; SPDX-License-Identifier: MIT
; Copyright (c) 2026 Sven Häber

Procedure.s CallbackParameter(JsonParameters.s, Index.i)
  Protected Result.s = ""
  Protected Root.i

  If ParseJSON(#JsonCallback, JsonParameters)
    Root = JSONValue(#JsonCallback)

    If JSONType(Root) = #PB_JSON_Array And JSONArraySize(Root) > Index
      Result = GetJSONString(GetJSONElement(Root, Index))
    EndIf

    FreeJSON(#JsonCallback)
  EndIf

  ProcedureReturn Result
EndProcedure

Procedure UiActionCallback(JsonParameters.s)
  Protected Action.s = LCase(CallbackParameter(JsonParameters, 0))
  Protected RawValue.s = CallbackParameter(JsonParameters, 1)
  Protected Value.i = Val(RawValue)
  Protected Ok.i = #True
  Protected Message.s = ""
  Protected Sound.i
  Protected Permanent.i
  Protected RandomEnabled.i
  Protected IntervalEnabled.i
  Protected IntervalSeconds.i
  Protected MinimumSeconds.i
  Protected MaximumSeconds.i

  Select Action
    Case "ready"
      gWebReady = #True
      gUiDirty = #True

    Case "play"
      If Not gConnected
        Ok = #False
        Message = "Kein Soundmodul verbunden."
      ElseIf gControlMode <> "SOFTWARE"
        Ok = #False
        Message = "Im Eingangsmodus erfolgt die Auslösung ausschließlich über IN1 bis IN10."
      ElseIf gResetting Or gPlaybackLocked
        Ok = #False
        Message = "Während der Wiedergabe sind nur Reset und Lautstärke freigegeben."
      ElseIf Value < 1 Or Value > 10
        Ok = #False
        Message = "Soundindex muss zwischen 1 und 10 liegen."
      ElseIf Not WriteSerialLine("PLAY " + Str(Value))
        Ok = #False
        Message = "PLAY konnte nicht vollständig übertragen werden."
        ScheduleReconnect(Message)
      Else
        AddLog("TX: PLAY " + Str(Value))
      EndIf

    Case "volume"
      If Not gConnected
        Ok = #False
        Message = "Kein Soundmodul verbunden."
      ElseIf gResetting
        Ok = #False
        Message = "Während des Resets ist die Lautstärke kurzzeitig gesperrt."
      ElseIf Value < 0 Or Value > 30
        Ok = #False
        Message = "Lautstärke muss zwischen 0 und 30 liegen."
      ElseIf Not WriteSerialLine("VOLUME " + Str(Value))
        Ok = #False
        Message = "VOLUME konnte nicht vollständig übertragen werden."
        ScheduleReconnect(Message)
      Else
        gVolume = Value
        SaveSettings()
        AddLog("TX: VOLUME " + Str(Value))
      EndIf

    Case "reset"
      If Not gConnected
        Ok = #False
        Message = "Kein Soundmodul verbunden."
      ElseIf gResetting
        Ok = #False
        Message = "Reset läuft bereits."
      ElseIf Not WriteSerialLine("RESET")
        Ok = #False
        Message = "RESET konnte nicht vollständig übertragen werden."
        ScheduleReconnect(Message)
      Else
        gDeviceState = "RESETTING"
        gResetting = #True
        gPlaybackLocked = #False
        gQueueCount = 0
        gQueueItems = "-"
        gAutomationEnabled = #False
        AddLog("TX: RESET")
      EndIf

    Case "mode"
      If Not gConnected Or gPlaybackLocked Or gResetting
        Ok = #False
        Message = "Die Betriebsart kann während der Wiedergabe nicht geändert werden."
      ElseIf UCase(RawValue) = "SOFTWARE"
        WriteSerialLine("MODE SOFTWARE")
        AddLog("TX: MODE SOFTWARE")
      ElseIf UCase(RawValue) = "INPUTS"
        WriteSerialLine("MODE INPUTS")
        AddLog("TX: MODE INPUTS")
      Else
        Ok = #False
        Message = "Ungültige Betriebsart."
      EndIf

    Case "automation"
      If Not gConnected Or gPlaybackLocked Or gResetting
        Ok = #False
        Message = "Die Automatik kann während der Wiedergabe nicht geändert werden."
      ElseIf gControlMode <> "SOFTWARE" And Value <> 0
        Ok = #False
        Message = "Automatik ist nur im Softwarebetrieb verfügbar."
      ElseIf Value < 0 Or Value > 1
        Ok = #False
        Message = "Ungültiger Automatikwert."
      Else
        WriteSerialLine("AUTOMATION " + Str(Value))
        AddLog("TX: AUTOMATION " + Str(Value))
      EndIf

    Case "random-range"
      MinimumSeconds = Val(StringField(RawValue, 1, "|"))
      MaximumSeconds = Val(StringField(RawValue, 2, "|"))

      If Not gConnected Or gPlaybackLocked Or gResetting
        Ok = #False
        Message = "Der Zufallsbereich kann während der Wiedergabe nicht geändert werden."
      ElseIf gControlMode <> "SOFTWARE"
        Ok = #False
        Message = "Zufallsabläufe sind nur im Softwarebetrieb verfügbar."
      ElseIf MinimumSeconds < 1 Or MaximumSeconds < MinimumSeconds Or MaximumSeconds > 86400
        Ok = #False
        Message = "Der Zufallsbereich muss zwischen 1 Sekunde und 24 Stunden liegen."
      Else
        WriteSerialLine("RANDOM_RANGE " + Str(MinimumSeconds) + " " + Str(MaximumSeconds))
        AddLog("TX: RANDOM_RANGE " + Str(MinimumSeconds) + " " + Str(MaximumSeconds) + " Sekunden")
      EndIf

    Case "sound-config"
      Sound = Val(StringField(RawValue, 1, "|"))
      Permanent = Val(StringField(RawValue, 2, "|"))
      RandomEnabled = Val(StringField(RawValue, 3, "|"))
      IntervalEnabled = Val(StringField(RawValue, 4, "|"))
      IntervalSeconds = Val(StringField(RawValue, 5, "|"))

      If Not gConnected Or gPlaybackLocked Or gResetting
        Ok = #False
        Message = "Soundeinstellungen können während der Wiedergabe nicht geändert werden."
      ElseIf gControlMode <> "SOFTWARE"
        Ok = #False
        Message = "Soundautomatik ist im Eingangsmodus deaktiviert."
      ElseIf Sound < 1 Or Sound > 10 Or IntervalSeconds < 1 Or IntervalSeconds > 86400
        Ok = #False
        Message = "Ungültige Soundkonfiguration."
      Else
        WriteSerialLine("CONFIG " + Str(Sound) + " " + Str(Permanent) + " " + Str(RandomEnabled) + " " + Str(IntervalEnabled) + " " + Str(IntervalSeconds))
        AddLog("TX: CONFIG Sound " + Str(Sound) + " / " + Str(IntervalSeconds) + " Sekunden")
      EndIf

    Case "media-scan"
      If Not gConnected
        Ok = #False
        Message = "Kein Soundmodul verbunden."
      ElseIf gPlaybackLocked Or gResetting
        Ok = #False
        Message = "Die Dateiprüfung ist während der Wiedergabe gesperrt."
      ElseIf gAutomationEnabled Or gQueueCount > 0
        Ok = #False
        Message = "Automatik ausschalten und Warteschlange leeren, bevor die Dateien geprüft werden."
      Else
        gMediaKnown = #False
        WriteSerialLine("MEDIA?")
        AddLog("TX: MEDIA?")
      EndIf

    Case "reload-config"
      If Not gConnected Or gPlaybackLocked Or gResetting
        Ok = #False
        Message = "Konfiguration kann während der Wiedergabe nicht geladen werden."
      Else
        WriteSerialLine("CONFIG?")
        WriteSerialLine("STATUS")
        AddLog("TX: CONFIG?")
      EndIf

    Case "connect-port"
      If gPlaybackLocked Or gResetting
        Ok = #False
        Message = "Während der Wiedergabe sind nur Reset und Lautstärke freigegeben."
      ElseIf Trim(RawValue) = ""
        Ok = #False
        Message = "Bitte zuerst einen COM-Port auswählen."
      Else
        BeginPortSearch(RawValue)
      EndIf

    Case "search"
      If gPlaybackLocked Or gResetting
        Ok = #False
        Message = "Während der Wiedergabe sind nur Reset und Lautstärke freigegeben."
      Else
        BeginPortSearch()
      EndIf

    Default
      Ok = #False
      Message = "Unbekannte Bedienaktion."
  EndSelect

  If Message <> ""
    If Ok
      SetNotice(Message, "info")
    Else
      SetNotice(Message, "error")
    EndIf
  EndIf

  gUiDirty = #True

  ProcedureReturn UTF8("{" + Chr(34) + "ok" + Chr(34) + ":" + BoolJson(Ok) + "," + Chr(34) + "message" + Chr(34) + ":" + JsonString(Message) + "}")
EndProcedure
