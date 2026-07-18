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

RandomSeed(ElapsedMilliseconds())

IncludeFile "./Core/Enums.pbi"
IncludeFile "./Core/Globals.pbi"
IncludeFile "./Core/Helpers.pbi"
IncludeFile "./Core/Board.pbi"
IncludeFile "./Core/Drawing.pbi"
IncludeFile "./Core/Network.pbi"
IncludeFile "./Core/AI.pbi"
IncludeFile "./Core/Input.pbi"

If OpenWindow(#WIN_MAIN, #PB_Ignore, #PB_Ignore, 580, 800, "TinyGomoku by Jiowcl", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_ScreenCentered)
  CanvasGadget(#CANVAS, 15, 15, canvasW, canvasH)
  
  TextGadget(#LBL_NET, 15, 575, 550, 20, "Two-Player Battle in this Game")
  ButtonGadget(#BTN_LOCAL, 15, 600, 70, 30, "Local")
  ButtonGadget(#BTN_AI, 90, 600, 70, 30, "vs AI")
  ComboBoxGadget(#CMB_AI_DIFF, 165, 600, 70, 30)
  AddGadgetItem(#CMB_AI_DIFF, -1, "Easy")
  AddGadgetItem(#CMB_AI_DIFF, -1, "Normal")
  AddGadgetItem(#CMB_AI_DIFF, -1, "Hard")
  SetGadgetState(#CMB_AI_DIFF, #AI_NORMAL)
  ComboBoxGadget(#CMB_AI_SIDE, 240, 600, 75, 30)
  AddGadgetItem(#CMB_AI_SIDE, -1, "Black")
  AddGadgetItem(#CMB_AI_SIDE, -1, "White")
  SetGadgetState(#CMB_AI_SIDE, #AI_SIDE_BLACK)
  
  TextGadget(#PB_Any, 325, 608, 25, 20, "IP:")
  StringGadget(#STR_HOST, 350, 600, 105, 24, "127.0.0.1")
  TextGadget(#PB_Any, 460, 608, 30, 24, "Port:")
  StringGadget(#STR_PORT, 495, 600, 70, 24, Str(#NET_PORT_DEFAULT))
  
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
    AiPoll()
    EffectsTick()
  
    Select WaitWindowEvent(10)
      Case #PB_Event_CloseWindow
        Break
  
      Case #PB_Event_Gadget
        Select EventGadget()
          Case #BTN_LOCAL
            NetStartLocal()

          Case #BTN_AI
            AiStartGame()

          Case #CMB_AI_DIFF
            AiSyncDifficultyFromUi()
            If gameMode = #MODE_AI
              AiUpdateModeLabel()
            EndIf

          Case #CMB_AI_SIDE
            AiSyncSideFromUi()
            If gameMode = #MODE_AI
              ; Side applies on Restart / vs AI; update preference label hint only.
              SetGadgetText(#LBL_NET, "Side preference: " + GetGadgetText(#CMB_AI_SIDE) + " (Restart to apply) — " + AiDifficultyName(aiDifficulty))
            EndIf
  
          Case #BTN_HOST
            NetStartHost()
  
          Case #BTN_JOIN
            NetJoinHost()
  
          Case #BTN_RESTART
            AiCancelPending()
            If gameMode = #MODE_AI
              AiSyncDifficultyFromUi()
              AiSyncSideFromUi()
              AiApplySideSettings()
            EndIf
            InitBoard()
            DrawBoard()
            If gameMode = #MODE_AI
              AiUpdateModeLabel()
              UpdateStatus()
              AiEnsureTurn()
            EndIf
            
            If gameMode <> #MODE_LOCAL And gameMode <> #MODE_AI And networkConnected
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