;--------------------------------------------------------------------------------------------
;  Copyright (c) Ji-Feng Tsai. All rights reserved.
;  Code released under the MIT license.
;--------------------------------------------------------------------------------------------

; <summary>
; SyncCanvasSize
; </summary>
; <returns>Returns void.</returns>
Procedure SyncCanvasSize()
  Protected w.i = GadgetWidth(#CANVAS)
  Protected h.i = GadgetHeight(#CANVAS)

  If w > 0
    canvasW = w
  EndIf
  
  If h > 0
    canvasH = h
  EndIf
EndProcedure

; <summary>
; CalculateLayout
; </summary>
; <returns>Returns void.</returns>
Procedure CalculateLayout()
  Protected size.i = MinI(canvasW, canvasH)
  Protected offsetX.i = (canvasW - size) / 2
  Protected offsetY.i = (canvasH - size) / 2
  Protected span.i

  cellSize = size / (#BOARD_SIZE - 1)
  span = cellSize * (#BOARD_SIZE - 1)
  padding = (size - span) / 2
  pieceRadius = MaxI(6, cellSize * 42 / 100)

  gridLeft = offsetX + padding
  gridTop = offsetY + padding
  gridRight = gridLeft + span
  gridBottom = gridTop + span
EndProcedure

; <summary>
; EnsureBoardImage
; </summary>
; <returns>Returns void.</returns>
Procedure EnsureBoardImage()
  SyncCanvasSize()

  If boardImage = -1 Or canvasW <> boardImageW Or canvasH <> boardImageH
    If boardImage <> -1
      FreeImage(boardImage)
    EndIf
    
    boardImage = CreateImage(#PB_Any, canvasW, canvasH, 24)
    boardImageW = canvasW
    boardImageH = canvasH
  EndIf
EndProcedure

; <summary>
; InitBoard
; </summary>
; <returns>Returns void.</returns>
Procedure InitBoard()
  Protected x.i, y.i

  For y = 0 To #BOARD_SIZE - 1
    For x = 0 To #BOARD_SIZE - 1
      board(x, y) = #PLAYER_NONE
    Next
  Next

  currentPlayer = #PLAYER_BLACK
  gameOver = #False
  winner = #PLAYER_NONE
  moveCount = 0
  winLineCount = 0
  hoverX = -1
  hoverY = -1

  UpdateStatus()
EndProcedure

; <summary>
; ScreenToBoard
; </summary>
; <param name="sx"></param>
; <param name="sy"></param>
; <returns>Returns void.</returns>
Procedure ScreenToBoard(sx.i, sy.i)
  Protected fx.i = sx - gridLeft
  Protected fy.i = sy - gridTop
  Protected span.i = gridRight - gridLeft

  If fx < 0 Or fy < 0 Or fx > span Or fy > span
    stbX = -1
    stbY = -1
    
    ProcedureReturn
  EndIf

  stbX = (fx + cellSize / 2) / cellSize
  stbY = (fy + cellSize / 2) / cellSize

  If stbX < 0 Or stbX >= #BOARD_SIZE Or stbY < 0 Or stbY >= #BOARD_SIZE
    stbX = -1
    stbY = -1
  EndIf
EndProcedure

; <summary>
; BoardPosX
; </summary>
; <param name="bx"></param>
; <returns>Returns integer.</returns>
Procedure.i BoardPosX(bx.i)
  ProcedureReturn gridLeft + bx * cellSize
EndProcedure

; <summary>
; BoardPosY
; </summary>
; <param name="by"></param>
; <returns>Returns integer.</returns>
Procedure.i BoardPosY(by.i)
  ProcedureReturn gridTop + by * cellSize
EndProcedure

; <summary>
; CheckDirection
; </summary>
; <param name="x"></param>
; <param name="y"></param>
; <param name="dx"></param>
; <param name="dy"></param>
; <param name="player"></param>
; <returns>Returns integer.</returns>
Procedure.i CheckDirection(x.i, y.i, dx.i, dy.i, player.i)
  Protected nx.i, ny.i
  Protected count.i

  count = 1
  winLineCount = 1
  winLineX(0) = x
  winLineY(0) = y

  nx = x + dx
  ny = y + dy
  
  While nx >= 0 And nx < #BOARD_SIZE And ny >= 0 And ny < #BOARD_SIZE And board(nx, ny) = player
    If winLineCount < #MAX_WIN_POINTS
      winLineX(winLineCount) = nx
      winLineY(winLineCount) = ny
      winLineCount + 1
    EndIf
    
    count + 1
    nx = nx + dx
    ny = ny + dy
  Wend

  nx = x - dx
  ny = y - dy
  
  While nx >= 0 And nx < #BOARD_SIZE And ny >= 0 And ny < #BOARD_SIZE And board(nx, ny) = player
    If winLineCount < #MAX_WIN_POINTS
      winLineX(winLineCount) = nx
      winLineY(winLineCount) = ny
      winLineCount + 1
    EndIf
    
    count + 1
    nx = nx - dx
    ny = ny - dy
  Wend

  ProcedureReturn count
EndProcedure

; <summary>
; CheckWin
; </summary>
; <param name="x"></param>
; <param name="y"></param>
; <param name="player"></param>
; <returns>Returns bool.</returns>
Procedure.b CheckWin(x.i, y.i, player.i)
  If CheckDirection(x, y, 1, 0, player) >= 5
    ProcedureReturn #True
  EndIf
  
  If CheckDirection(x, y, 0, 1, player) >= 5
    ProcedureReturn #True
  EndIf
  
  If CheckDirection(x, y, 1, 1, player) >= 5
    ProcedureReturn #True
  EndIf
  
  If CheckDirection(x, y, 1, -1, player) >= 5
    ProcedureReturn #True
  EndIf
  
  ProcedureReturn #False
EndProcedure

; <summary>
; CheckDraw
; </summary>
; <returns>Returns bool.</returns>
Procedure.b CheckDraw()
  Protected x.i, y.i

  For y = 0 To #BOARD_SIZE - 1
    For x = 0 To #BOARD_SIZE - 1
      If board(x, y) = #PLAYER_NONE
        ProcedureReturn #False
      EndIf
    Next
  Next

  ProcedureReturn #True
EndProcedure

; <summary>
; CheckDraw
; </summary>
; <param name="wonPlayer"></param>
; <param name="isDraw"></param>
; <returns>Returns void.</returns>
Procedure FinishGame(wonPlayer.i, isDraw.i)
  gameOver = #True

  If isDraw
    winner = #PLAYER_NONE
    SetGadgetText(#LBL_STATUS, "Draw")
  Else
    winner = wonPlayer
    
    If winner = #PLAYER_BLACK
      SetGadgetText(#LBL_STATUS, "Black Wins")
    Else
      SetGadgetText(#LBL_STATUS, "White Wins")
    EndIf
  EndIf
EndProcedure

; <summary>
; ApplyMove
; </summary>
; <param name="x"></param>
; <param name="y"></param>
; <param name="fromNetwork"></param>
; <returns>Returns bool.</returns>
Procedure.b ApplyMove(x.i, y.i, fromNetwork.i)
  Protected mover.i

  If gameOver
    ProcedureReturn #False
  EndIf
  
  If x < 0 Or x >= #BOARD_SIZE Or y < 0 Or y >= #BOARD_SIZE
    ProcedureReturn #False
  EndIf
  
  If board(x, y) <> #PLAYER_NONE
    ProcedureReturn #False
  EndIf

  If gameMode <> #MODE_LOCAL And networkConnected
    If fromNetwork = #False And currentPlayer <> myPlayer
      ProcedureReturn #False
    EndIf
  EndIf

  mover = currentPlayer
  board(x, y) = mover
  moveX(moveCount) = x
  moveY(moveCount) = y
  movePlayer(moveCount) = mover
  moveCount + 1

  If CheckWin(x, y, mover)
    FinishGame(mover, #False)
  ElseIf CheckDraw()
    FinishGame(#PLAYER_NONE, #True)
  Else
    If currentPlayer = #PLAYER_BLACK
      currentPlayer = #PLAYER_WHITE
    Else
      currentPlayer = #PLAYER_BLACK
    EndIf
    UpdateStatus()
  EndIf

  ProcedureReturn #True
EndProcedure

; <summary>
; UndoMove
; </summary>
; <returns>Returns void.</returns>
Procedure UndoMove()
  Protected last.i

  If gameMode <> #MODE_LOCAL
    ProcedureReturn
  EndIf

  If moveCount = 0
    ProcedureReturn
  EndIf

  If gameOver
    gameOver = #False
    winner = #PLAYER_NONE
    winLineCount = 0
  EndIf

  moveCount - 1
  last = moveCount
  board(moveX(last), moveY(last)) = #PLAYER_NONE
  currentPlayer = movePlayer(last)
  
  UpdateStatus()
EndProcedure

; IDE Options = PureBasic 6.40 (Windows - x64)
; CursorPosition = 322
; FirstLine = 278
; Folding = ---
; Optimizer
; EnableAsm
; EnableXP
; DPIAware
; EnableOnError
; DisableDebugger
; CompileSourceDirectory