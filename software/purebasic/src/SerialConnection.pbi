; SPDX-License-Identifier: MIT
; Copyright (c) 2026 Sven Häber

Procedure.i PortExists(PortName.s)
  Protected Target.s = Space(2048)

  If QueryDosDevice_(PortName, @Target, 2048)
    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure

Procedure EnumerateSerialPorts()
  Protected Index.i
  Protected Port.s
  Protected Count.i = 0

  For Index = 0 To ArraySize(gScanPorts())
    gScanPorts(Index) = ""
  Next

  If gLastPort <> "" And PortExists(gLastPort)
    gScanPorts(Count) = gLastPort
    Count = Count + 1
  EndIf

  For Index = 1 To 256
    Port = "COM" + Str(Index)

    If PortExists(Port)
      If gLastPort = "" Or UCase(Port) <> UCase(gLastPort)
        If Count <= ArraySize(gScanPorts())
          gScanPorts(Count) = Port
          Count = Count + 1
        EndIf
      EndIf
    EndIf
  Next

  gScanCount = Count
EndProcedure

Declare.i WriteSerialLine(Line.s)

Procedure CloseSerialSafe()
  If IsSerialPort(#SerialNano)
    CloseSerialPort(#SerialNano)
  EndIf
EndProcedure

Procedure ResetDeviceState()
  gDeviceState = "OFFLINE"
  gPlaybackLocked = #False
  gResetting = #False
  gBusy = #False
  gBusyRaw = 0
  gCurrent = 0
  gCurrentTrigger = "NONE"
  gCurrentInput = 0
  gInputMask = 0
  gQueueCount = 0
  gQueueItems = "-"
  gMediaKnown = #False
  gMediaCount = 0
  gUptime = 0
EndProcedure

Procedure DisconnectNano(LogEvent.i = #True, Graceful.i = #False)
  If Graceful And gConnected And IsSerialPort(#SerialNano)
    WriteSerialLine("SESSION END")
    Delay(120)
  EndIf

  CloseSerialSafe()

  gConnected = #False
  gPort = ""
  gFirmware = ""
  gSerialBuffer = ""
  ResetDeviceState()

  If LogEvent
    AddLog("Verbindung zum Soundmodul getrennt.")
  EndIf

  gUiDirty = #True
EndProcedure

Procedure.i WriteSerialLine(Line.s)
  Protected Text.s = Line + Chr(13) + Chr(10)
  Protected ByteCount.i = StringByteLength(Text, #PB_Ascii)
  Protected Written.i

  If Not IsSerialPort(#SerialNano)
    ProcedureReturn #False
  EndIf

  Written = WriteSerialPortString(#SerialNano, Text, #PB_Ascii)

  If Written = ByteCount
    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure

Procedure.s GetTokenValue(Line.s, Key.s)
  Protected TokenCount.i = CountString(Line, " ") + 1
  Protected Index.i
  Protected Token.s
  Protected Prefix.s = UCase(Key) + "="

  For Index = 1 To TokenCount
    Token = StringField(Line, Index, " ")

    If Left(UCase(Token), Len(Prefix)) = Prefix
      ProcedureReturn Mid(Token, Len(Prefix) + 1)
    EndIf
  Next

  ProcedureReturn ""
EndProcedure

Procedure ParseStatus(Line.s)
  Protected Value.s

  Value = GetTokenValue(Line, "STATE")
  If Value <> ""
    gDeviceState = UCase(Value)
  EndIf

  Value = GetTokenValue(Line, "BUSY")
  If Value <> ""
    gBusy = Val(Value)
  EndIf

  Value = GetTokenValue(Line, "BUSY_RAW")
  If Value <> ""
    gBusyRaw = Clamp(Val(Value), 0, 1023)
  EndIf

  Value = GetTokenValue(Line, "CURRENT")
  If Value <> ""
    gCurrent = Clamp(Val(Value), 0, 10)
  EndIf

  Value = GetTokenValue(Line, "TRIGGER")
  If Value <> ""
    gCurrentTrigger = UCase(Value)
  EndIf

  Value = GetTokenValue(Line, "INPUT")
  If Value <> ""
    gCurrentInput = Clamp(Val(Value), 0, 10)
  EndIf

  Value = GetTokenValue(Line, "VOLUME")
  If Value <> ""
    gVolume = Clamp(Val(Value), 0, 30)
  EndIf

  Value = GetTokenValue(Line, "MODE")
  If Value <> ""
    gControlMode = UCase(Value)
  EndIf

  Value = GetTokenValue(Line, "AUTOMATION")
  If Value <> ""
    gAutomationEnabled = Val(Value)
  EndIf

  Value = GetTokenValue(Line, "QUEUE_COUNT")
  If Value <> ""
    gQueueCount = Clamp(Val(Value), 0, 10)
  EndIf

  Value = GetTokenValue(Line, "INPUT_MASK")
  If Value <> ""
    gInputMask = Clamp(Val(Value), 0, 1023)
  EndIf

  Value = GetTokenValue(Line, "UPTIME")
  If Value <> ""
    gUptime = Val(Value)
  EndIf

  gResetting = Bool(UCase(gDeviceState) = "RESETTING")
  UpdatePlaybackLock()
EndProcedure

Procedure EstablishConnection()
  gConnected = #True
  gScanning = #False
  gScanState = #ScanIdle
  gPort = gProbePort
  gProbePort = ""
  gLastPort = gPort
  gStatusText = "Verbunden über " + gPort
  gLastRx = ElapsedMilliseconds()
  gLastStatusTx = 0

  SaveSettings()
  AddLog("Soundmodul an " + gPort + " erkannt.")
  SetNotice("Soundmodul an " + gPort + " verbunden.", "success")

  WriteSerialLine("SESSION START")
  WriteSerialLine("VOLUME " + Str(gVolume))
  WriteSerialLine("CONFIG?")
  WriteSerialLine("STATUS")

  gUiDirty = #True
EndProcedure

Procedure ScheduleReconnect(Message.s)
  DisconnectNano(#False)
  gScanning = #False
  gScanState = #ScanIdle
  gStatusText = Message
  AddLog(Message)
  SetNotice(Message, "error")
  gReconnectPending = #True
  gReconnectAt = ElapsedMilliseconds() + 700
EndProcedure

Procedure HandleSerialLine(Line.s)
  Protected Upper.s
  Protected Value.s
  Protected Sound.i

  Line = Trim(ReplaceString(Line, Chr(13), ""))

  If Line = ""
    ProcedureReturn
  EndIf

  Upper = UCase(Line)
  gLastRx = ElapsedMilliseconds()

  If Left(Upper, 10) = "MMSM-NANO "
    gRecognized = #True
    gFirmware = StringField(Line, 2, " ")

    If gConnected
      AddLog("RX: " + Line)
    EndIf

  ElseIf Left(Upper, 7) = "STATUS "
    ParseStatus(Line)

  ElseIf Left(Upper, 9) = "SETTINGS "
    Value = GetTokenValue(Line, "MODE")
    If Value <> ""
      gControlMode = UCase(Value)
    EndIf
    Value = GetTokenValue(Line, "AUTOMATION")
    If Value <> ""
      gAutomationEnabled = Val(Value)
    EndIf
    Value = GetTokenValue(Line, "RANDOM_MIN_SECONDS")
    If Value <> ""
      gRandomMinSeconds = Clamp(Val(Value), 1, 86400)
    EndIf
    Value = GetTokenValue(Line, "RANDOM_MAX_SECONDS")
    If Value <> ""
      gRandomMaxSeconds = Clamp(Val(Value), 1, 86400)
    EndIf
    Value = GetTokenValue(Line, "VOLUME")
    If Value <> ""
      gVolume = Clamp(Val(Value), 0, 30)
    EndIf

  ElseIf Left(Upper, 7) = "CONFIG "
    Sound = Clamp(Val(GetTokenValue(Line, "SOUND")), 1, 10)
    gSound(Sound)\Permanent = Val(GetTokenValue(Line, "PERMANENT"))
    gSound(Sound)\RandomEnabled = Val(GetTokenValue(Line, "RANDOM"))
    gSound(Sound)\IntervalEnabled = Val(GetTokenValue(Line, "INTERVAL"))
    gSound(Sound)\IntervalSeconds = Clamp(Val(GetTokenValue(Line, "INTERVAL_SECONDS")), 1, 86400)

  ElseIf Left(Upper, 6) = "MEDIA "
    gMediaCount = Clamp(Val(GetTokenValue(Line, "COUNT")), 0, 65535)
    gMediaKnown = #True
    AddLog("RX: " + Line)

    If gMediaCount = 0
      SetNotice("Der JQ6500 meldet null Dateien. Das kann leerer Speicher oder eine fehlende Abfrageantwort sein.", "warning")
    Else
      SetNotice("Der JQ6500 meldet " + Str(gMediaCount) + " Dateien im internen Speicher.", "success")
    EndIf

  ElseIf Left(Upper, 6) = "QUEUE "
    gQueueCount = Clamp(Val(GetTokenValue(Line, "COUNT")), 0, 10)
    gQueueItems = GetTokenValue(Line, "ITEMS")
    If gQueueItems = ""
      gQueueItems = "-"
    EndIf

  ElseIf Left(Upper, 8) = "OK PLAY "
    gCurrent = Clamp(Val(GetTokenValue(Line, "INDEX")), 1, 10)
    gCurrentTrigger = UCase(GetTokenValue(Line, "TRIGGER"))
    gCurrentInput = Clamp(Val(GetTokenValue(Line, "INPUT")), 0, 10)
    gDeviceState = "STARTING"
    UpdatePlaybackLock()
    gLastEvent = "Sound " + Str(gCurrent) + " wird gestartet."
    AddLog("RX: " + Line)

  ElseIf Left(Upper, 12) = "EVENT START "
    gCurrent = Clamp(Val(GetTokenValue(Line, "INDEX")), 1, 10)
    gCurrentTrigger = UCase(GetTokenValue(Line, "TRIGGER"))
    gCurrentInput = Clamp(Val(GetTokenValue(Line, "INPUT")), 0, 10)
    gDeviceState = "PLAYING"
    gBusy = #True
    gResetting = #False
    UpdatePlaybackLock()
    gLastEvent = "Sound " + Str(gCurrent) + " läuft."
    AddLog("RX: " + Line)
    SetNotice("Sound " + Str(gCurrent) + " läuft. Nur Reset und Lautstärke sind freigegeben.", "success")

  ElseIf Left(Upper, 10) = "EVENT END "
    Value = GetTokenValue(Line, "INDEX")
    gLastEvent = "Sound " + Str(Val(Value)) + " ist beendet."
    gDeviceState = "READY"
    gBusy = #False
    gCurrent = 0
    gCurrentTrigger = "NONE"
    gCurrentInput = 0
    gResetting = #False
    UpdatePlaybackLock()
    AddLog("RX: " + Line)

  ElseIf Left(Upper, 13) = "EVENT QUEUED"
    gQueueCount = Clamp(Val(GetTokenValue(Line, "QUEUE_COUNT")), 0, 10)
    AddLog("RX: " + Line)

  ElseIf Left(Upper, 18) = "EVENT INPUT_QUEUED"
    AddLog("RX: " + Line)

  ElseIf Left(Upper, 19) = "EVENT INPUT_IGNORED"
    AddLog("RX: " + Line)

  ElseIf Left(Upper, 10) = "OK VOLUME "
    gVolume = Clamp(Val(GetTokenValue(Line, "VALUE")), 0, 30)
    SaveSettings()
    AddLog("RX: " + Line)

  ElseIf Left(Upper, 18) = "EVENT RESET START"
    gDeviceState = "RESETTING"
    gResetting = #True
    gPlaybackLocked = #False
    gQueueCount = 0
    gQueueItems = "-"
    gLastEvent = "JQ6500 wird zurückgesetzt."
    AddLog("RX: " + Line)

  ElseIf Left(Upper, 16) = "EVENT RESET DONE"
    gDeviceState = "READY"
    gResetting = #False
    gPlaybackLocked = #False
    gBusy = #False
    gCurrent = 0
    gCurrentTrigger = "NONE"
    gCurrentInput = 0
    gAutomationEnabled = #False
    AddLog("RX: " + Line)
    SetNotice("Reset abgeschlossen. Warteschlange leer, Automatik aus.", "warning")

  ElseIf Left(Upper, 20) = "ERROR START_TIMEOUT"
    gDeviceState = "READY"
    gResetting = #False
    gPlaybackLocked = #False
    gBusy = #False
    gCurrent = 0
    gCurrentTrigger = "NONE"
    gCurrentInput = 0
    AddLog("RX: " + Line)
    SetNotice("Der JQ6500 hat den Soundstart nicht über BUSY bestätigt.", "error")

  ElseIf Left(Upper, 3) = "OK "
    AddLog("RX: " + Line)

  ElseIf Left(Upper, 4) = "ERR "
    AddLog("RX: " + Line)

    If Upper = "ERR MEDIA_BUSY"
      SetNotice("Dateiprüfung ist nur bei gestoppter Automatik, leerer Warteschlange und ohne Wiedergabe möglich.", "warning")
    Else
      SetNotice("Firmwaremeldung: " + Mid(Line, 5), "error")
    EndIf

  ElseIf Upper <> "PONG"
    AddLog("RX: " + Line)
  EndIf

  gUiDirty = #True
EndProcedure
