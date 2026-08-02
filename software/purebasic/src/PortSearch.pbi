; SPDX-License-Identifier: MIT
; Copyright (c) 2026 Sven Häber

Procedure PollSerial()
  Protected Available.i
  Protected ReadCount.i
  Protected *Buffer
  Protected Position.i
  Protected Line.s

  If Not IsSerialPort(#SerialNano)
    ProcedureReturn
  EndIf

  Available = AvailableSerialPortInput(#SerialNano)

  If Available <= 0
    ProcedureReturn
  EndIf

  If Available > 1024
    Available = 1024
  EndIf

  *Buffer = AllocateMemory(Available)

  If *Buffer = 0
    ProcedureReturn
  EndIf

  ReadCount = ReadSerialPortData(#SerialNano, *Buffer, Available)

  If ReadCount > 0
    gSerialBuffer = gSerialBuffer + PeekS(*Buffer, ReadCount, #PB_Ascii)
  EndIf

  FreeMemory(*Buffer)

  Repeat
    Position = FindString(gSerialBuffer, Chr(10))

    If Position = 0
      Break
    EndIf

    Line = Left(gSerialBuffer, Position - 1)
    gSerialBuffer = Mid(gSerialBuffer, Position + 1)
    HandleSerialLine(Line)
  ForEver
EndProcedure

Procedure.i OpenProbePort(Port.s)
  CloseSerialSafe()

  gSerialBuffer = ""
  gRecognized = #False
  gProbePort = Port

  If OpenSerialPort(#SerialNano, Port, #SERIAL_BAUD, #PB_SerialPort_NoParity, 8, 1, #PB_SerialPort_NoHandshake, 4096, 4096)
    gScanDeadline = ElapsedMilliseconds() + #PROBE_TIMEOUT_MS
    gScanNextRequest = ElapsedMilliseconds() + #PROBE_FIRST_REQUEST_MS
    gStatusText = "Prüfe " + Port
    AddLog("Prüfe " + Port + " auf MMSM-NANO.")
    ProcedureReturn #True
  EndIf

  AddLog(Port + " konnte nicht geöffnet werden.")
  gProbePort = ""
  ProcedureReturn #False
EndProcedure

Procedure BeginPortSearch(PreferredPort.s = "")
  Protected Index.i
  Protected Temporary.s

  If gPlaybackLocked Or gResetting
    SetNotice("Während der Wiedergabe ist die Verbindungssuche gesperrt.", "warning")
    ProcedureReturn
  EndIf

  gReconnectPending = #False
  gScanning = #False
  gScanState = #ScanIdle
  DisconnectNano(#False, #True)
  EnumerateSerialPorts()

  If PreferredPort <> ""
    PreferredPort = UCase(Trim(PreferredPort))

    If Not PortExists(PreferredPort)
      gStatusText = PreferredPort + " ist nicht mehr vorhanden"
      AddLog(gStatusText)
      SetNotice(gStatusText + ". Die Portliste wird neu eingelesen.", "error")
      gUiDirty = #True
      ProcedureReturn
    EndIf

    For Index = 0 To gScanCount - 1
      If UCase(gScanPorts(Index)) = PreferredPort
        Temporary = gScanPorts(0)
        gScanPorts(0) = gScanPorts(Index)
        gScanPorts(Index) = Temporary
        Break
      EndIf
    Next
  EndIf

  If gScanCount <= 0
    gScanning = #False
    gStatusText = "Kein COM-Anschluss gefunden – erneute Suche in 5 Sekunden"
    AddLog("Kein COM-Anschluss gefunden.")
    SetNotice(gStatusText, "error")
    gReconnectPending = #True
    gReconnectAt = ElapsedMilliseconds() + #AUTO_SEARCH_RETRY_MS
    gUiDirty = #True
    ProcedureReturn
  EndIf

  gScanning = #True
  gScanState = #ScanOpenNext
  gScanIndex = 0

  If PreferredPort <> ""
    gStatusText = "Verbinde gezielt mit " + PreferredPort
    AddLog("Gezielte Verbindung mit " + PreferredPort + " gestartet.")
  Else
    gStatusText = "Automatische Suche über " + Str(gScanCount) + " COM-Port(s)"
    AddLog("Automatische Gerätesuche gestartet.")
  EndIf

  gUiDirty = #True
EndProcedure

Procedure ProcessPortSearch()
  Protected Now.i = ElapsedMilliseconds()

  If Not gScanning
    ProcedureReturn
  EndIf

  Select gScanState
    Case #ScanOpenNext
      If gScanIndex >= gScanCount
        gScanning = #False
        gScanState = #ScanIdle
        gProbePort = ""
        CloseSerialSafe()
        gStatusText = "Soundmodul nicht gefunden – erneute Suche in 5 Sekunden"
        AddLog(gStatusText)
        SetNotice(gStatusText, "error")
        gReconnectPending = #True
        gReconnectAt = ElapsedMilliseconds() + #AUTO_SEARCH_RETRY_MS
        gUiDirty = #True
        ProcedureReturn
      EndIf

      gStatusText = "Suche " + Str(gScanIndex + 1) + " von " + Str(gScanCount) + ": " + gScanPorts(gScanIndex)

      If OpenProbePort(gScanPorts(gScanIndex))
        gScanState = #ScanWaiting
      Else
        gScanIndex = gScanIndex + 1
      EndIf

    Case #ScanWaiting
      PollSerial()

      If gRecognized
        EstablishConnection()
        ProcedureReturn
      EndIf

      If Now >= gScanNextRequest
        WriteSerialLine("IDENTIFY")
        gScanNextRequest = Now + #PROBE_REPEAT_MS
      EndIf

      If Now >= gScanDeadline
        AddLog(gProbePort + " antwortet nicht als MMSM-NANO.")
        CloseSerialSafe()
        gProbePort = ""
        gScanIndex = gScanIndex + 1
        gScanState = #ScanOpenNext
      EndIf
  EndSelect

  gUiDirty = #True
EndProcedure
