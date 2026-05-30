;--------------------------------------------------------------------------------------------
;  Copyright (c) Ji-Feng Tsai. All rights reserved.
;  Code released under the MIT license.
;--------------------------------------------------------------------------------------------

; <summary>
; DrawPiece
; </summary>
; <param name="sx"></param>
; <param name="sy"></param>
; <param name="isBlack"></param>
; <returns>Returns void.</returns>
Procedure DrawPiece(sx.i, sy.i, isBlack.i)
  Protected r.i = pieceRadius

  DrawingMode(#PB_2DDrawing_Default | #PB_2DDrawing_Transparent)

  If isBlack
    Circle(sx, sy, r, RGB(0, 0, 0))
  Else
    Circle(sx, sy, r, RGB(255, 255, 255))
  EndIf
EndProcedure

; <summary>
; DrawWinLine
; </summary>
; <returns>Returns void.</returns>
Procedure DrawWinLine()
  Protected i.i, minIdx.i, maxIdx.i
  Protected minX.i, minY.i, maxX.i, maxY.i
  Protected sx1.i, sy1.i, sx2.i, sy2.i

  If winLineCount < 5
    ProcedureReturn
  EndIf

  minIdx = 0
  maxIdx = 0
  minX = winLineX(0) : minY = winLineY(0)
  maxX = winLineX(0) : maxY = winLineY(0)

  For i = 1 To winLineCount - 1
    If winLineX(i) < minX Or (winLineX(i) = minX And winLineY(i) < minY)
      minIdx = i
      minX = winLineX(i)
      minY = winLineY(i)
    EndIf
    
    If winLineX(i) > maxX Or (winLineX(i) = maxX And winLineY(i) > maxY)
      maxIdx = i
      maxX = winLineX(i)
      maxY = winLineY(i)
    EndIf
  Next

  sx1 = BoardPosX(winLineX(minIdx))
  sy1 = BoardPosY(winLineY(minIdx))
  sx2 = BoardPosX(winLineX(maxIdx))
  sy2 = BoardPosY(winLineY(maxIdx))

  DrawingMode(#PB_2DDrawing_AlphaBlend)
  FrontColor(RGBA(255, 68, 68, 80))
  LineXY(sx1, sy1, sx2, sy2)
  FrontColor(RGB(255, 0, 0))
  LineXY(sx1, sy1, sx2, sy2)
  DrawingMode(#PB_2DDrawing_Default)
EndProcedure

; <summary>
; DrawBoardContent
; </summary>
; <returns>Returns void.</returns>
Procedure DrawBoardContent()
  Protected x.i, y.i, i.i
  Protected sx.i, sy.i, x1.i, y1.i
  Protected r.i, hx.i, hy.i
  Protected starX.i, starY.i
  Protected last.i
  Protected resultText.s
  Protected font.i

  CalculateLayout()

  Box(0, 0, canvasW, canvasH, RGB(210, 176, 126))
  Box(gridLeft - 2, gridTop - 2, gridRight - gridLeft + 5, gridBottom - gridTop + 5, RGB(198, 162, 112))
  FrontColor(RGB(70, 48, 35))
  
  For i = 0 To #BOARD_SIZE - 1
    x1 = gridLeft + i * cellSize
    LineXY(x1, gridTop, x1, gridBottom)
    
    y1 = gridTop + i * cellSize
    LineXY(gridLeft, y1, gridRight, y1)
  Next

  r = MaxI(3, cellSize / 10)
  For i = 0 To 4
    Select i
      Case 0 : starX = 7 : starY = 7
      Case 1 : starX = 3 : starY = 3
      Case 2 : starX = 3 : starY = 11
      Case 3 : starX = 11 : starY = 3
      Case 4 : starX = 11 : starY = 11
    EndSelect
    
    sx = BoardPosX(starX) : sy = BoardPosY(starY)
    
    Circle(sx, sy, r, RGB(93, 64, 55))
  Next

  If Not gameOver And hoverX >= 0 And hoverY >= 0 And board(hoverX, hoverY) = #PLAYER_NONE
    If gameMode = #MODE_LOCAL Or (networkConnected And currentPlayer = myPlayer)
      hx = BoardPosX(hoverX) : hy = BoardPosY(hoverY)
      r = pieceRadius
      DrawingMode(#PB_2DDrawing_AlphaBlend)
      
      If currentPlayer = #PLAYER_BLACK
        Circle(hx, hy, r, RGBA(0, 0, 0, 110))
      Else
        Circle(hx, hy, r, RGBA(255, 255, 255, 160))
      EndIf
      
      DrawingMode(#PB_2DDrawing_Default)
    EndIf
  EndIf

  For y = 0 To #BOARD_SIZE - 1
    For x = 0 To #BOARD_SIZE - 1
      If board(x, y) <> #PLAYER_NONE
        sx = BoardPosX(x) : sy = BoardPosY(y)
        DrawPiece(sx, sy, Bool(board(x, y) = #PLAYER_BLACK))
      EndIf
    Next
  Next

  If moveCount > 0
    last = moveCount - 1
    sx = BoardPosX(moveX(last)) : sy = BoardPosY(moveY(last))
    r = MaxI(4, cellSize / 7)
    
    FrontColor(RGB(255, 0, 0))
    LineXY(sx - r, sy, sx + r, sy)
    LineXY(sx, sy - r, sx, sy + r)
  EndIf

  If gameOver And winner <> #PLAYER_NONE
    DrawWinLine()
  EndIf

  If gameOver
    DrawingMode(#PB_2DDrawing_AlphaBlend)
    Box(0, 0, canvasW, canvasH, RGBA(0, 0, 0, 53))
    DrawingMode(#PB_2DDrawing_Default)

    If winner = #PLAYER_BLACK
      resultText = "Black Wins"
    ElseIf winner = #PLAYER_WHITE
      resultText = "White Wins"
    Else
      resultText = "Draw"
    EndIf

    font = LoadFont(#PB_Any, "Microsoft JhengHei UI", MaxI(20, cellSize * 4 / 5), #PB_Font_HighQuality)
    
    If font = 0
      font = LoadFont(#PB_Any, "Microsoft JhengHei", MaxI(20, cellSize * 4 / 5), #PB_Font_HighQuality)
    EndIf
    
    If font
      DrawingFont(FontID(font))
      DrawingMode(#PB_2DDrawing_AlphaBlend)
      FrontColor(RGBA(0, 0, 0, 140))
      DrawText((canvasW - TextWidth(resultText)) / 2 + 3, (canvasH - TextHeight(resultText)) / 2 + 3, resultText)
      DrawingMode(#PB_2DDrawing_Default)

      If winner = #PLAYER_BLACK
        FrontColor(RGB(255, 215, 0))
      ElseIf winner = #PLAYER_WHITE
        FrontColor(RGB(255, 255, 255))
      Else
        FrontColor(RGB(144, 238, 144))
      EndIf
      
      DrawText((canvasW - TextWidth(resultText)) / 2, (canvasH - TextHeight(resultText)) / 2, resultText)
      FreeFont(font)
    EndIf
  EndIf
EndProcedure

; <summary>
; DrawBoard
; </summary>
; <returns>Returns void.</returns>
Procedure DrawBoard()
  EnsureBoardImage()

  If StartDrawing(ImageOutput(boardImage))
    DrawBoardContent()
    StopDrawing()
  EndIf

  If StartDrawing(CanvasOutput(#CANVAS))
    DrawImage(ImageID(boardImage), 0, 0)
    StopDrawing()
  EndIf
EndProcedure

; IDE Options = PureBasic 6.40 (Windows - x64)
; CursorPosition = 191
; FirstLine = 155
; Folding = -
; Optimizer
; EnableAsm
; EnableXP
; DPIAware
; EnableOnError
; DisableDebugger
; CompileSourceDirectory