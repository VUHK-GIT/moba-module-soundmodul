; SPDX-License-Identifier: MIT
; Copyright (c) 2026 Sven Häber

Procedure.i Clamp(Value.i, Minimum.i, Maximum.i)
  If Value < Minimum
    ProcedureReturn Minimum
  EndIf
  If Value > Maximum
    ProcedureReturn Maximum
  EndIf
  ProcedureReturn Value
EndProcedure

Procedure.s BoolJson(Value.i)
  If Value
    ProcedureReturn "true"
  EndIf
  ProcedureReturn "false"
EndProcedure

Procedure.s JsonString(Value.s)
  Value = ReplaceString(Value, Chr(92), Chr(92) + Chr(92))
  Value = ReplaceString(Value, Chr(34), Chr(92) + Chr(34))
  Value = ReplaceString(Value, Chr(13), "")
  Value = ReplaceString(Value, Chr(10), Chr(92) + "n")
  ProcedureReturn Chr(34) + Value + Chr(34)
EndProcedure

Procedure.s SettingsDirectory()
  Protected Base.s = GetEnvironmentVariable("APPDATA")
  Protected Vendor.s
  Protected App.s

  If Base = ""
    Base = GetHomeDirectory()
  EndIf

  Vendor = Base + "\Moba-Module"
  App = Vendor + "\MOBA-Module-Soundmodul"

  CreateDirectory(Vendor)
  CreateDirectory(App)

  ProcedureReturn App
EndProcedure

Procedure.s SettingsFile()
  ProcedureReturn SettingsDirectory() + "\Einstellungen.ini"
EndProcedure

Procedure LoadSettings()
  If OpenPreferences(SettingsFile())
    PreferenceGroup("Verbindung")
    gLastPort = ReadPreferenceString("LetzterPort", "")
    PreferenceGroup("Audio")
    gVolume = Clamp(ReadPreferenceInteger("Lautstaerke", 15), 0, 30)
    ClosePreferences()
  EndIf
EndProcedure

Procedure SaveSettings()
  If CreatePreferences(SettingsFile())
    PreferenceGroup("Verbindung")
    WritePreferenceString("LetzterPort", gLastPort)
    PreferenceGroup("Audio")
    WritePreferenceInteger("Lautstaerke", gVolume)
    ClosePreferences()
  EndIf
EndProcedure

Procedure AddLog(Text.s)
  AddElement(gLogs())
  gLogs() = FormatDate("%hh:%ii:%ss", Date()) + "  " + Text

  While ListSize(gLogs()) > #MAX_LOG_LINES
    FirstElement(gLogs())
    DeleteElement(gLogs())
  Wend

  gUiDirty = #True
EndProcedure

Procedure SetNotice(Text.s, Type.s = "info")
  gNotice = Text
  gNoticeType = Type
  gNoticeId = gNoticeId + 1
  gUiDirty = #True
EndProcedure

Procedure UpdatePlaybackLock()
  Select UCase(gDeviceState)
    Case "STARTING", "PLAYING"
      gPlaybackLocked = #True
    Default
      gPlaybackLocked = #False
  EndSelect
EndProcedure

Procedure.s BuildStateJson()
  Protected Json.s
  Protected LogsJson.s = "["
  Protected ConfigJson.s = "["
  Protected PortsJson.s = "["
  Protected First.i = #True
  Protected Index.i
  Protected PortIndex.i

  ForEach gLogs()
    If Not First
      LogsJson = LogsJson + ","
    EndIf
    LogsJson = LogsJson + JsonString(gLogs())
    First = #False
  Next
  LogsJson = LogsJson + "]"

  For Index = 1 To 10
    If Index > 1
      ConfigJson = ConfigJson + ","
    EndIf

    ConfigJson = ConfigJson + "{"
    ConfigJson = ConfigJson + Chr(34) + "sound" + Chr(34) + ":" + Str(Index) + ","
    ConfigJson = ConfigJson + Chr(34) + "permanent" + Chr(34) + ":" + BoolJson(gSound(Index)\Permanent) + ","
    ConfigJson = ConfigJson + Chr(34) + "random" + Chr(34) + ":" + BoolJson(gSound(Index)\RandomEnabled) + ","
    ConfigJson = ConfigJson + Chr(34) + "interval" + Chr(34) + ":" + BoolJson(gSound(Index)\IntervalEnabled) + ","
    ConfigJson = ConfigJson + Chr(34) + "intervalSeconds" + Chr(34) + ":" + Str(gSound(Index)\IntervalSeconds)
    ConfigJson = ConfigJson + "}"
  Next
  ConfigJson = ConfigJson + "]"

  For PortIndex = 0 To gScanCount - 1
    If PortIndex > 0
      PortsJson = PortsJson + ","
    EndIf
    PortsJson = PortsJson + JsonString(gScanPorts(PortIndex))
  Next
  PortsJson = PortsJson + "]"

  Json = "{"
  Json = Json + Chr(34) + "connected" + Chr(34) + ":" + BoolJson(gConnected) + ","
  Json = Json + Chr(34) + "scanning" + Chr(34) + ":" + BoolJson(gScanning) + ","
  Json = Json + Chr(34) + "scanIndex" + Chr(34) + ":" + Str(gScanIndex) + ","
  Json = Json + Chr(34) + "scanCount" + Chr(34) + ":" + Str(gScanCount) + ","
  Json = Json + Chr(34) + "availablePorts" + Chr(34) + ":" + PortsJson + ","
  Json = Json + Chr(34) + "playbackLocked" + Chr(34) + ":" + BoolJson(gPlaybackLocked) + ","
  Json = Json + Chr(34) + "resetting" + Chr(34) + ":" + BoolJson(gResetting) + ","
  Json = Json + Chr(34) + "port" + Chr(34) + ":" + JsonString(gPort) + ","
  Json = Json + Chr(34) + "probePort" + Chr(34) + ":" + JsonString(gProbePort) + ","
  Json = Json + Chr(34) + "firmware" + Chr(34) + ":" + JsonString(gFirmware) + ","
  Json = Json + Chr(34) + "deviceState" + Chr(34) + ":" + JsonString(gDeviceState) + ","
  Json = Json + Chr(34) + "busy" + Chr(34) + ":" + BoolJson(gBusy) + ","
  Json = Json + Chr(34) + "busyRaw" + Chr(34) + ":" + Str(gBusyRaw) + ","
  Json = Json + Chr(34) + "current" + Chr(34) + ":" + Str(gCurrent) + ","
  Json = Json + Chr(34) + "currentTrigger" + Chr(34) + ":" + JsonString(gCurrentTrigger) + ","
  Json = Json + Chr(34) + "currentInput" + Chr(34) + ":" + Str(gCurrentInput) + ","
  Json = Json + Chr(34) + "volume" + Chr(34) + ":" + Str(gVolume) + ","
  Json = Json + Chr(34) + "controlMode" + Chr(34) + ":" + JsonString(gControlMode) + ","
  Json = Json + Chr(34) + "automationEnabled" + Chr(34) + ":" + BoolJson(gAutomationEnabled) + ","
  Json = Json + Chr(34) + "randomMinSeconds" + Chr(34) + ":" + Str(gRandomMinSeconds) + ","
  Json = Json + Chr(34) + "randomMaxSeconds" + Chr(34) + ":" + Str(gRandomMaxSeconds) + ","
  Json = Json + Chr(34) + "mediaKnown" + Chr(34) + ":" + BoolJson(gMediaKnown) + ","
  Json = Json + Chr(34) + "mediaCount" + Chr(34) + ":" + Str(gMediaCount) + ","
  Json = Json + Chr(34) + "queueCount" + Chr(34) + ":" + Str(gQueueCount) + ","
  Json = Json + Chr(34) + "queueItems" + Chr(34) + ":" + JsonString(gQueueItems) + ","
  Json = Json + Chr(34) + "inputMask" + Chr(34) + ":" + Str(gInputMask) + ","
  Json = Json + Chr(34) + "uptime" + Chr(34) + ":" + Str(gUptime) + ","
  Json = Json + Chr(34) + "statusText" + Chr(34) + ":" + JsonString(gStatusText) + ","
  Json = Json + Chr(34) + "lastEvent" + Chr(34) + ":" + JsonString(gLastEvent) + ","
  Json = Json + Chr(34) + "notice" + Chr(34) + ":" + JsonString(gNotice) + ","
  Json = Json + Chr(34) + "noticeType" + Chr(34) + ":" + JsonString(gNoticeType) + ","
  Json = Json + Chr(34) + "noticeId" + Chr(34) + ":" + Str(gNoticeId) + ","
  Json = Json + Chr(34) + "soundConfigs" + Chr(34) + ":" + ConfigJson + ","
  Json = Json + Chr(34) + "logs" + Chr(34) + ":" + LogsJson
  Json = Json + "}"

  ProcedureReturn Json
EndProcedure

Procedure PushStateToWeb()
  If gWebReady And IsGadget(#WebView)
    WebViewExecuteScript(#WebView, "window.applyState(" + BuildStateJson() + ");")
    gUiDirty = #False
    gLastUiPush = ElapsedMilliseconds()
  EndIf
EndProcedure
