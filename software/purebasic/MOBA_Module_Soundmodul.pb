; ============================================================================
; SPDX-License-Identifier: MIT
; Copyright (c) 2026 Sven Häber
;
; MOBA-Module Sound Module desktop application 1.0.0
; Windows control application for Arduino Nano + JQ6500-16P.
;
; Runtime responsibility:
; - READY: sound controls, reset and volume are available.
; - STARTING/PLAYING: only reset and volume remain available.
; - RESETTING: controls remain locked until EVENT RESET DONE is received.
;
; Scheduling, EEPROM persistence and the blocking FIFO queue run on the Nano.
; The user interface is German-only in version 1.0.0. Code identifiers and
; comments are English.
;
; The MOBA-Module name and logo are excluded from the MIT License.
; See TRADEMARKS.md and ASSETS.md.
; ============================================================================

; IDE Options = PureBasic 6.10 LTS (Windows - x64)
; ExecutableFormat = Windows
; DPIAware

EnableExplicit

CompilerIf #PB_Compiler_OS <> #PB_OS_Windows
  CompilerError "Diese Version ist für Windows vorgesehen."
CompilerEndIf

#APP_NAME = "MOBA-Module-Soundmodul"
#APP_VERSION = "1.0.0"
#SERIAL_BAUD = 115200
#RUNTIME_TIMER_MS = 40
#STATUS_INTERVAL_MS = 1000
#CONNECTION_TIMEOUT_MS = 6000
#PROBE_TIMEOUT_MS = 3600
#PROBE_FIRST_REQUEST_MS = 1400
#PROBE_REPEAT_MS = 500
#AUTO_SEARCH_RETRY_MS = 5000
#MAX_LOG_LINES = 120

Enumeration Windows
  #MainWindow
EndEnumeration

Enumeration Gadgets
  #WebView
EndEnumeration

Enumeration SerialPorts
  #SerialNano
EndEnumeration

Enumeration Timers
  #TimerRuntime
EndEnumeration

Enumeration JsonObjects
  #JsonCallback
EndEnumeration

Enumeration ScanStates
  #ScanIdle
  #ScanOpenNext
  #ScanWaiting
EndEnumeration

Global gRunning.i = #True
Global gWebReady.i = #False
Global gUiDirty.i = #True

Global gConnected.i = #False
Global gScanning.i = #False
Global gRecognized.i = #False
Global gScanState.i = #ScanIdle
Global gScanIndex.i = 0
Global gScanCount.i = 0
Global gScanDeadline.i = 0
Global gScanNextRequest.i = 0
Global gProbePort.s = ""
Global Dim gScanPorts.s(255)

Global gPort.s = ""
Global gFirmware.s = ""
Global gLastPort.s = ""
Global gSerialBuffer.s = ""
Global gLastRx.i = 0
Global gLastStatusTx.i = 0
Global gReconnectAt.i = 0
Global gReconnectPending.i = #False

Global gDeviceState.s = "OFFLINE"
Global gPlaybackLocked.i = #False
Global gResetting.i = #False
Global gBusy.i = #False
Global gBusyRaw.i = 0
Global gCurrent.i = 0
Global gVolume.i = 15
Structure SoundUiConfig
  Permanent.i
  RandomEnabled.i
  IntervalEnabled.i
  IntervalSeconds.i
EndStructure

Global gControlMode.s = "SOFTWARE"
Global gAutomationEnabled.i = #False
Global gRandomMinSeconds.i = 120
Global gRandomMaxSeconds.i = 600
Global Dim gSound.SoundUiConfig(10)

Global gMediaKnown.i = #False
Global gMediaCount.i = 0

Global gCurrentTrigger.s = "NONE"
Global gCurrentInput.i = 0
Global gInputMask.i = 0
Global gQueueCount.i = 0
Global gQueueItems.s = "-"
Global gUptime.q = 0
Global gStatusText.s = "Soundmodul wird gesucht"
Global gLastEvent.s = ""

Global gNotice.s = ""
Global gNoticeType.s = "info"
Global gNoticeId.i = 0
Global gLastUiPush.i = 0
Global gWindowIcon.i = 0

Global NewList gLogs.s()

IncludeFile "src\Utilities.pbi"
IncludeFile "src\SerialConnection.pbi"
IncludeFile "src\PortSearch.pbi"
IncludeFile "src\UiActions.pbi"
IncludeFile "src\Runtime.pbi"

LoadSettings()
AddLog(#APP_NAME + " " + #APP_VERSION + " wird gestartet.")

If Not OpenWindow(#MainWindow, 0, 0, 1440, 900, #APP_NAME + " " + #APP_VERSION, #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_SizeGadget | #PB_Window_ScreenCentered | #PB_Window_Invisible)
  MessageRequester(#APP_NAME, "Das Hauptfenster konnte nicht geöffnet werden.", #PB_MessageRequester_Error)
  End
EndIf

WindowBounds(#MainWindow, 1280, 900, #PB_Ignore, #PB_Ignore)

ApplyWindowIcon()

If Not WebViewGadget(#WebView, 0, 0, WindowWidth(#MainWindow), WindowHeight(#MainWindow))
  MessageRequester(#APP_NAME, "WebView konnte nicht erstellt werden. PureBasic 6.10 oder neuer sowie Microsoft WebView2 sind erforderlich.", #PB_MessageRequester_Error)
  End
EndIf

BindWebViewCallback(#WebView, "pbAction", @UiActionCallback())
SetGadgetItemText(#WebView, #PB_WebView_HtmlCode, EmbeddedHtml())
BindEvent(#PB_Event_SizeWindow, @ResizeWebView(), #MainWindow)
AddWindowTimer(#MainWindow, #TimerRuntime, #RUNTIME_TIMER_MS)

HideWindow(#MainWindow, #False)
SetWindowState(#MainWindow, #PB_Window_Maximize)
BeginPortSearch()

Repeat
  Select WaitWindowEvent()
    Case #PB_Event_Timer
      If EventTimer() = #TimerRuntime
        HandleRuntime()
      EndIf

    Case #PB_Event_CloseWindow
      DisconnectNano(#False, #True)
      gRunning = #False
  EndSelect
Until Not gRunning

CloseSerialSafe()

If gWindowIcon
  DestroyIcon_(gWindowIcon)
EndIf

End

DataSection
UiHtmlStart:
  IncludeBinary "ui\index.html"
UiHtmlEnd:
EndDataSection
