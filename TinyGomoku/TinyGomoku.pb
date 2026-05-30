;--------------------------------------------------------------------------------------------
;  Copyright (c) Ji-Feng Tsai. All rights reserved.
;  Code released under the MIT license.
;--------------------------------------------------------------------------------------------

EnableExplicit

CompilerIf #PB_Compiler_Unicode = 0
  CompilerError "Enable Unicode in Compiler menu, and save this file as UTF-8 with BOM."
CompilerEndIf

If InitSound() = 0
  MessageRequester("Error", "Sound System is not Available",  0)
  
  End
EndIf

IncludeFile "./Core/Enums.pbi"
IncludeFile "./Core/Globals.pbi"
IncludeFile "./Core/Helpers.pbi"
IncludeFile "./Core/Board.pbi"
IncludeFile "./Core/Drawing.pbi"
IncludeFile "./Core/Network.pbi"
IncludeFile "./Core/Input.pbi"

If OpenWindow(#WIN_MAIN, #PB_Ignore, #PB_Ignore, 580, 800, "TinyGomoku by Jiowcl", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_ScreenCentered)
  CanvasGadget(#CANVAS, 15, 15, canvasW, canvasH)
  
  TextGadget(#LBL_NET, 15, 575, 550, 20, "Two-Player Battle in this Game")
  ButtonGadget(#BTN_LOCAL, 15, 600, 135, 30, "Local")
  
  TextGadget(#PB_Any, 296, 608, 30, 20, "IP:")
  StringGadget(#STR_HOST, 330, 600, 120, 24, "127.0.0.1")
  TextGadget(#PB_Any, 475, 608, 30, 24, "Port:")
  StringGadget(#STR_PORT, 510, 600, 55, 24, Str(#NET_PORT_DEFAULT))
  
  ButtonGadget(#BTN_HOST, 15, 634, 270, 30, "Create a Room")
  ButtonGadget(#BTN_JOIN, 295, 634, 270, 30, "Join Room")
  
  ButtonGadget(#BTN_RESTART, 15, 688, 270, 35, "Restart")
  ButtonGadget(#BTN_UNDO, 295, 688, 270, 35, "Back a Move")
  TextGadget(#LBL_STATUS, 15, 760, 550, 30, "", #PB_Text_Center)
  
  LoadUIFont()
  SyncCanvasSize()
  BindGadgetEvent(#CANVAS, @CanvasGadgetEvent())
  
  InitBoard()
  DrawBoard()
  
  ; Ui Event
  Repeat
    NetPoll()
  
    Select WaitWindowEvent(10)
      Case #PB_Event_CloseWindow
        Break
  
      Case #PB_Event_Gadget
        Select EventGadget()
          Case #BTN_LOCAL
            NetStartLocal()
  
          Case #BTN_HOST
            NetStartHost()
  
          Case #BTN_JOIN
            NetJoinHost()
  
          Case #BTN_RESTART
            InitBoard()
            DrawBoard()
            
            If gameMode <> #MODE_LOCAL And networkConnected
              NetSendLine("RESET")
            EndIf
  
          Case #BTN_UNDO
            UndoMove()
            DrawBoard()
        EndSelect
    EndSelect
  ForEver
  
  NetDisconnect()
  
  If boardImage <> -1
    FreeImage(boardImage)
  EndIf
  
  If uiFont
    FreeFont(uiFont)
  EndIf
  
  If statusFont
    FreeFont(statusFont)
  EndIf
  
  CloseWindow(#WIN_MAIN)
EndIf
; IDE Options = PureBasic 6.40 (Windows - x64)
; CursorPosition = 45
; FirstLine = 9
; Folding = -
; Optimizer
; EnableAsm
; EnableXP
; DPIAware
; EnableOnError
; DisableDebugger
; CompileSourceDirectory