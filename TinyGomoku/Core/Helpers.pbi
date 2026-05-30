;--------------------------------------------------------------------------------------------
;  Copyright (c) Ji-Feng Tsai. All rights reserved.
;  Code released under the MIT license.
;--------------------------------------------------------------------------------------------

; <summary>
; MinI
; </summary>
; <param name="a"></param>
; <param name="b"></param>
; <returns>Returns integer.</returns>
Procedure.i MinI(a.i, b.i)
  If a < b
    ProcedureReturn a
  EndIf
  
  ProcedureReturn b
EndProcedure

; <summary>
; MaxI
; </summary>
; <param name="a"></param>
; <param name="b"></param>
; <returns>Returns integer.</returns>
Procedure.i MaxI(a.i, b.i)
  If a > b
    ProcedureReturn a
  EndIf
  
  ProcedureReturn b
EndProcedure

; <summary>
; PlayerName
; </summary>
; <param name="player"></param>
; <returns>Returns string.</returns>
Procedure.s PlayerName(player.i)
  If player = #PLAYER_BLACK
    ProcedureReturn "Black Side"
  EndIf
  ProcedureReturn "White Side"
EndProcedure

; <summary>
; PlayerStatusText
; </summary>
; <param name="player"></param>
; <returns>Returns string.</returns>
Procedure.s PlayerStatusText(player.i)
  ProcedureReturn PlayerName(player) + " Plays the Pieces"
EndProcedure

; <summary>
; UpdateStatus
; </summary>
; <returns>Returns void.</returns>
Procedure UpdateStatus()
  Protected msg.s

  If gameOver
    ProcedureReturn
  EndIf

  If gameMode = #MODE_LOCAL
    SetGadgetText(#LBL_STATUS, PlayerStatusText(currentPlayer))
    
    ProcedureReturn
  EndIf

  If Not networkConnected
    Select gameMode
      Case #MODE_HOST
        msg = "Waiting for Your Opponent to Join... (You are Black Side)"
      Case #MODE_CLIENT
        msg = "Connecting…"
      Default
        msg = "Not connected"
    EndSelect
    
    SetGadgetText(#LBL_STATUS, msg)
    
    ProcedureReturn
  EndIf

  If currentPlayer = myPlayer
    SetGadgetText(#LBL_STATUS, "It's Your Turn to Play Chess. (" + PlayerName(myPlayer) + ")")
  Else
    SetGadgetText(#LBL_STATUS, "Waiting for the Opponent… (" + PlayerName(currentPlayer) + ")")
  EndIf
EndProcedure

; <summary>
; SetOnlineControlsEnabled
; </summary>
; <param name="enabled"></param>
; <returns>Returns void.</returns>
Procedure SetOnlineControlsEnabled(enabled.i)
  Protected state.i

  If enabled
    state = 0
  Else
    state = 1
  EndIf

  DisableGadget(#BTN_LOCAL, state)
  DisableGadget(#BTN_HOST, state)
  DisableGadget(#BTN_JOIN, state)
  DisableGadget(#STR_HOST, state)
  DisableGadget(#STR_PORT, state)
EndProcedure

; <summary>
; LoadUIFont
; </summary>
; <returns>Returns void.</returns>
Procedure LoadUIFont()
  uiFont = LoadFont(#PB_Any, "Microsoft JhengHei UI", 12, #PB_Font_HighQuality)
  
  If uiFont = 0
    uiFont = LoadFont(#PB_Any, "Microsoft JhengHei", 12, #PB_Font_HighQuality)
  EndIf
  
  If uiFont = 0
    uiFont = LoadFont(#PB_Any, "Arial", 12, #PB_Font_HighQuality)
  EndIf
  
  If uiFont
    SetGadgetFont(#BTN_RESTART, FontID(uiFont))
    SetGadgetFont(#BTN_UNDO, FontID(uiFont))
    SetGadgetFont(#BTN_LOCAL, FontID(uiFont))
    SetGadgetFont(#BTN_HOST, FontID(uiFont))
    SetGadgetFont(#BTN_JOIN, FontID(uiFont))
    SetGadgetFont(#STR_HOST, FontID(uiFont))
    SetGadgetFont(#STR_PORT, FontID(uiFont))
    SetGadgetFont(#LBL_NET, FontID(uiFont))
  EndIf

  statusFont = LoadFont(#PB_Any, "Microsoft JhengHei UI", 14, #PB_Font_HighQuality | #PB_Font_Bold)
  
  If statusFont = 0
    statusFont = LoadFont(#PB_Any, "Microsoft JhengHei", 14, #PB_Font_HighQuality | #PB_Font_Bold)
  EndIf
  
  If statusFont = 0
    statusFont = LoadFont(#PB_Any, "Arial", 14, #PB_Font_HighQuality | #PB_Font_Bold)
  EndIf
  
  If statusFont
    SetGadgetFont(#LBL_STATUS, FontID(statusFont))
  EndIf
EndProcedure
; IDE Options = PureBasic 6.40 (Windows - x64)
; CursorPosition = 147
; FirstLine = 104
; Folding = --
; Optimizer
; EnableAsm
; EnableXP
; DPIAware
; EnableOnError
; DisableDebugger
; CompileSourceDirectory