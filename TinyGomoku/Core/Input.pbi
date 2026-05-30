;--------------------------------------------------------------------------------------------
;  Copyright (c) Ji-Feng Tsai. All rights reserved.
;  Code released under the MIT license.
;--------------------------------------------------------------------------------------------

; <summary>
; TryPlaceAt
; </summary>
; <param name="x"></param>
; <param name="y"></param>
; <returns>Returns void.</returns>
Procedure TryPlaceAt(x.i, y.i)
  If ApplyMove(x, y, #False)
    If gameMode <> #MODE_LOCAL And networkConnected
      NetSendLine("MOVE|" + Str(x) + "|" + Str(y))
    EndIf
    
    DrawBoard()
  EndIf
EndProcedure

; <summary>
; CanvasGadgetEvent
; </summary>
; <returns>Returns void.</returns>
Procedure CanvasGadgetEvent()
  Protected mx.i, my.i

  Select EventType()
    Case #PB_EventType_MouseMove
      mx = GetGadgetAttribute(#CANVAS, #PB_Canvas_MouseX)
      my = GetGadgetAttribute(#CANVAS, #PB_Canvas_MouseY)
      ScreenToBoard(mx, my)
      
      If stbX <> hoverX Or stbY <> hoverY
        hoverX = stbX
        hoverY = stbY
        
        DrawBoard()
      EndIf

    Case #PB_EventType_MouseLeave
      If hoverX >= 0 Or hoverY >= 0
        hoverX = -1
        hoverY = -1
        
        DrawBoard()
      EndIf

    Case #PB_EventType_LeftButtonUp
      If gameOver
        ProcedureReturn
      EndIf
      
      If gameMode <> #MODE_LOCAL And Not networkConnected
        ProcedureReturn
      EndIf
      
      mx = GetGadgetAttribute(#CANVAS, #PB_Canvas_MouseX)
      my = GetGadgetAttribute(#CANVAS, #PB_Canvas_MouseY)
      ScreenToBoard(mx, my)
      
      If stbX >= 0 And stbY >= 0
        TryPlaceAt(stbX, stbY)
      EndIf
  EndSelect
EndProcedure

; IDE Options = PureBasic 6.40 (Windows - x64)
; CursorPosition = 37
; Folding = -
; Optimizer
; EnableAsm
; EnableXP
; DPIAware
; EnableOnError
; DisableDebugger
; CompileSourceDirectory