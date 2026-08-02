; SPDX-License-Identifier: MIT
; Copyright (c) 2026 Sven Häber

Procedure HandleConnectedRuntime()
  Protected Now.i = ElapsedMilliseconds()

  PollSerial()

  If Not gConnected
    ProcedureReturn
  EndIf

  If Now - gLastStatusTx >= #STATUS_INTERVAL_MS
    If WriteSerialLine("STATUS")
      gLastStatusTx = Now
    Else
      ScheduleReconnect("Serielle Verbindung unterbrochen. Neuverbindung läuft.")
      ProcedureReturn
    EndIf
  EndIf

  If Now - gLastRx >= #CONNECTION_TIMEOUT_MS
    ScheduleReconnect("Das Soundmodul antwortet nicht mehr. Neuverbindung läuft.")
  EndIf
EndProcedure

Procedure HandleRuntime()
  Protected Now.i = ElapsedMilliseconds()

  If gReconnectPending And Now >= gReconnectAt
    gReconnectPending = #False
    BeginPortSearch()
  EndIf

  If gScanning
    ProcessPortSearch()
  ElseIf gConnected
    HandleConnectedRuntime()
  EndIf

  If gUiDirty Or Now - gLastUiPush >= 700
    PushStateToWeb()
  EndIf
EndProcedure

Procedure ResizeWebView()
  If IsGadget(#WebView)
    ResizeGadget(#WebView, 0, 0, WindowWidth(#MainWindow), WindowHeight(#MainWindow))
  EndIf
EndProcedure

Procedure ApplyWindowIcon()
  Protected IconPath.s = GetPathPart(#PB_Compiler_File) + "assets\MOBA_Module_Soundmodul.ico"

  If FileSize(IconPath) < 0
    IconPath = GetPathPart(ProgramFilename()) + "assets\MOBA_Module_Soundmodul.ico"
  EndIf

  If FileSize(IconPath) >= 0
    gWindowIcon = LoadImage_(0, IconPath, #IMAGE_ICON, 0, 0, #LR_LOADFROMFILE | #LR_DEFAULTSIZE)

    If gWindowIcon
      SendMessage_(WindowID(#MainWindow), #WM_SETICON, #ICON_BIG, gWindowIcon)
      SendMessage_(WindowID(#MainWindow), #WM_SETICON, #ICON_SMALL, gWindowIcon)
    EndIf
  EndIf
EndProcedure

Procedure.s EmbeddedHtml()
  ProcedureReturn PeekS(?UiHtmlStart, ?UiHtmlEnd - ?UiHtmlStart, #PB_UTF8 | #PB_ByteLength)
EndProcedure
