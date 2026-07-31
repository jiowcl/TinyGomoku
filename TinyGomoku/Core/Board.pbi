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
  placeFxAt = 0
  winFxAt = 0
  resultFxAt = 0
  ClearUndoFx()
  ClearParticleFx()
  EnsureBgmPlaying()

  UpdateStatus()
EndProcedure

; <summary>
; ScreenToBoard
; </summary>
; <param name="sx">integer</param>
; <param name="sy">integer</param>
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
; <param name="bx">integer</param>
; <returns>Returns integer.</returns>
Procedure.i BoardPosX(bx.i)
  ProcedureReturn gridLeft + bx * cellSize
EndProcedure

; <summary>
; BoardPosY
; </summary>
; <param name="by">integer</param>
; <returns>Returns integer.</returns>
Procedure.i BoardPosY(by.i)
  ProcedureReturn gridTop + by * cellSize
EndProcedure

; <summary>
; CheckDirection
; </summary>
; <param name="x">integer</param>
; <param name="y">integer</param>
; <param name="dx">integer</param>
; <param name="dy">integer</param>
; <param name="player">integer</param>
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
; <param name="x">integer</param>
; <param name="y">integer</param>
; <param name="player">integer</param>
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
; <param name="wonPlayer">integer</param>
; <param name="isDraw">integer</param>
; <returns>Returns void.</returns>
Procedure FinishGame(wonPlayer.i, isDraw.i)
  gameOver = #True
  resultFxAt = ElapsedMilliseconds()
  ClearUndoFx()

  If isDraw
    winner = #PLAYER_NONE
    winFxAt = 0
    ClearParticleFx()
    
    SetGadgetText(#LBL_STATUS, "Draw")
  Else
    winner = wonPlayer
    winFxAt = ElapsedMilliseconds()
    SpawnWinParticles()
    
    If winner = #PLAYER_BLACK
      SetGadgetText(#LBL_STATUS, "Black Wins")
    Else
      SetGadgetText(#LBL_STATUS, "White Wins")
    EndIf
  EndIf
  
  PlaySoundSafe(#SOUND_COMPLETED_GAME)
  FadeOutBgm()
EndProcedure

; <summary>
; CountLineSimple
; Line length through (x,y) without touching win-line state.
; </summary>
; <param name="x">integer</param>
; <param name="y">integer</param>
; <param name="dx">integer</param>
; <param name="dy">integer</param>
; <param name="player">integer</param>
; <returns>Returns integer.</returns>
Procedure.i CountLineSimple(x.i, y.i, dx.i, dy.i, player.i)
  Protected nx.i, ny.i
  Protected count.i = 1

  nx = x + dx
  ny = y + dy
  While nx >= 0 And nx < #BOARD_SIZE And ny >= 0 And ny < #BOARD_SIZE And board(nx, ny) = player
    count + 1
    nx = nx + dx
    ny = ny + dy
  Wend

  nx = x - dx
  ny = y - dy
  While nx >= 0 And nx < #BOARD_SIZE And ny >= 0 And ny < #BOARD_SIZE And board(nx, ny) = player
    count + 1
    nx = nx - dx
    ny = ny - dy
  Wend

  ProcedureReturn count
EndProcedure

; <summary>
; HasFourInRow
; </summary>
; <param name="x">integer</param>
; <param name="y">integer</param>
; <param name="player">integer</param>
; <returns>Returns bool.</returns>
Procedure.b HasFourInRow(x.i, y.i, player.i)
  If CountLineSimple(x, y, 1, 0, player) >= 4
    ProcedureReturn #True
  EndIf
  If CountLineSimple(x, y, 0, 1, player) >= 4
    ProcedureReturn #True
  EndIf
  If CountLineSimple(x, y, 1, 1, player) >= 4
    ProcedureReturn #True
  EndIf
  If CountLineSimple(x, y, 1, -1, player) >= 4
    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure

; <summary>
; PlayMoveSound
; Normal putdown, or four-threat cue when the opponent creates a four.
; Win/draw sounds are handled by FinishGame.
; </summary>
; <param name="mover">integer</param>
; <param name="x">integer</param>
; <param name="y">integer</param>
; <param name="fromNetwork">integer</param>
; <returns>Returns void.</returns>
Procedure PlayMoveSound(mover.i, x.i, y.i, fromNetwork.i)
  Protected threat.i = #False

  If gameOver
    ProcedureReturn
  EndIf

  If HasFourInRow(x, y, mover)
    Select gameMode
      Case #MODE_LOCAL
        threat = #True
      Case #MODE_AI
        If mover = aiPlayer
          threat = #True
        EndIf
      Case #MODE_HOST, #MODE_CLIENT
        If fromNetwork Or mover <> myPlayer
          threat = #True
        EndIf
    EndSelect
  EndIf

  If threat
    PlaySoundSafe(#SOUND_PUTDOWN_PIECE_4)
  Else
    PlaySoundSafe(#SOUND_PUTDOWN_PIECE)
  EndIf
EndProcedure

; <summary>
; ApplyMove
; </summary>
; <param name="x">integer</param>
; <param name="y">integer</param>
; <param name="fromNetwork">integer</param>
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

  If gameMode <> #MODE_LOCAL And gameMode <> #MODE_AI And networkConnected
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
  placeFxAt = ElapsedMilliseconds()
  ClearUndoFx()

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

  PlayMoveSound(mover, x, y, fromNetwork)

  ProcedureReturn #True
EndProcedure

; <summary>
; ClearUndoFx
; </summary>
; <returns>Returns void.</returns>
Procedure ClearUndoFx()
  undoFxCount = 0
  undoFxAt = 0
EndProcedure

; <summary>
; QueueUndoGhost
; </summary>
; <param name="moveIndex">integer</param>
; <returns>Returns void.</returns>
Procedure QueueUndoGhost(moveIndex.i)
  If moveIndex < 0 Or moveIndex >= moveCount
    ProcedureReturn
  EndIf

  If undoFxCount >= #FX_UNDO_MAX
    ProcedureReturn
  EndIf

  undoFxX(undoFxCount) = moveX(moveIndex)
  undoFxY(undoFxCount) = moveY(moveIndex)
  undoFxPlayer(undoFxCount) = movePlayer(moveIndex)
  undoFxCount + 1
EndProcedure

; <summary>
; UndoOneMove
; </summary>
; <returns>Returns void.</returns>
Procedure UndoOneMove()
  Protected last.i

  If moveCount = 0
    ProcedureReturn
  EndIf

  If gameOver
    gameOver = #False
    winner = #PLAYER_NONE
    winLineCount = 0
    winFxAt = 0
    resultFxAt = 0
    ClearParticleFx()
  EndIf

  moveCount - 1
  last = moveCount
  board(moveX(last), moveY(last)) = #PLAYER_NONE
  currentPlayer = movePlayer(last)
  placeFxAt = 0
EndProcedure

; <summary>
; UndoMove
; </summary>
; <returns>Returns void.</returns>
Procedure UndoMove()
  If gameMode <> #MODE_LOCAL And gameMode <> #MODE_AI
    ProcedureReturn
  EndIf

  If moveCount = 0
    ProcedureReturn
  EndIf

  ClearUndoFx()
  undoFxAt = ElapsedMilliseconds()

  If gameMode = #MODE_AI
    AiCancelPending()

    ; While AI is still "thinking", only the human's last stone exists.
    If currentPlayer = aiPlayer And moveCount >= 1 And movePlayer(moveCount - 1) = myPlayer
      QueueUndoGhost(moveCount - 1)
      UndoOneMove()
    ElseIf moveCount >= 2
      QueueUndoGhost(moveCount - 1)
      QueueUndoGhost(moveCount - 2)
      UndoOneMove()
      UndoOneMove()
    Else
      QueueUndoGhost(moveCount - 1)
      UndoOneMove()
    EndIf
  Else
    QueueUndoGhost(moveCount - 1)
    UndoOneMove()
  EndIf

  UpdateStatus()
  AiEnsureTurn()
EndProcedure

; IDE Options = PureBasic 6.40 (Windows - x64)
; CursorPosition = 251
; FirstLine = 232
; Folding = ---
; Optimizer
; EnableAsm
; EnableXP
; DPIAware
; EnableOnError
; DisableDebugger
; CompileSourceDirectory