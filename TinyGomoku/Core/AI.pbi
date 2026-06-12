;--------------------------------------------------------------------------------------------
;  Copyright (c) Ji-Feng Tsai. All rights reserved.
;  Code released under the MIT license.
;--------------------------------------------------------------------------------------------

; <summary>
; AiCountLine
; </summary>
; <param name="x"></param>
; <param name="y"></param>
; <param name="dx"></param>
; <param name="dy"></param>
; <param name="player"></param>
; <returns>Returns integer.</returns>
Procedure.i AiCountLine(x.i, y.i, dx.i, dy.i, player.i)
  Protected nx.i, ny.i
  Protected count.i

  count = 1
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
; AiCountOpenEnds
; </summary>
; <param name="x"></param>
; <param name="y"></param>
; <param name="dx"></param>
; <param name="dy"></param>
; <param name="player"></param>
; <returns>Returns integer.</returns>
Procedure.i AiCountOpenEnds(x.i, y.i, dx.i, dy.i, player.i)
  Protected nx.i, ny.i
  Protected openEnds.i

  openEnds = 0
  nx = x + dx
  ny = y + dy

  While nx >= 0 And nx < #BOARD_SIZE And ny >= 0 And ny < #BOARD_SIZE And board(nx, ny) = player
    nx = nx + dx
    ny = ny + dy
  Wend

  If nx >= 0 And nx < #BOARD_SIZE And ny >= 0 And ny < #BOARD_SIZE And board(nx, ny) = #PLAYER_NONE
    openEnds + 1
  EndIf

  nx = x - dx
  ny = y - dy

  While nx >= 0 And nx < #BOARD_SIZE And ny >= 0 And ny < #BOARD_SIZE And board(nx, ny) = player
    nx = nx - dx
    ny = ny - dy
  Wend

  If nx >= 0 And nx < #BOARD_SIZE And ny >= 0 And ny < #BOARD_SIZE And board(nx, ny) = #PLAYER_NONE
    openEnds + 1
  EndIf

  ProcedureReturn openEnds
EndProcedure

; <summary>
; AiDirectionScore
; </summary>
; <param name="x"></param>
; <param name="y"></param>
; <param name="dx"></param>
; <param name="dy"></param>
; <param name="player"></param>
; <returns>Returns integer.</returns>
Procedure.i AiDirectionScore(x.i, y.i, dx.i, dy.i, player.i)
  Protected count.i
  Protected openEnds.i

  count = AiCountLine(x, y, dx, dy, player)
  openEnds = AiCountOpenEnds(x, y, dx, dy, player)

  If count >= 5
    ProcedureReturn 1000000
  EndIf

  If count = 4
    If openEnds = 2
      ProcedureReturn 50000
    ElseIf openEnds = 1
      ProcedureReturn 5000
    EndIf
  EndIf

  If count = 3
    If openEnds = 2
      ProcedureReturn 2000
    ElseIf openEnds = 1
      ProcedureReturn 200
    EndIf
  EndIf

  If count = 2
    If openEnds = 2
      ProcedureReturn 50
    ElseIf openEnds = 1
      ProcedureReturn 10
    EndIf
  EndIf

  ProcedureReturn 0
EndProcedure

; <summary>
; AiEvaluateCell
; </summary>
; <param name="x"></param>
; <param name="y"></param>
; <param name="player"></param>
; <returns>Returns integer.</returns>
Procedure.i AiEvaluateCell(x.i, y.i, player.i)
  Protected score.i

  board(x, y) = player
  score = AiDirectionScore(x, y, 1, 0, player)
  score + AiDirectionScore(x, y, 0, 1, player)
  score + AiDirectionScore(x, y, 1, 1, player)
  score + AiDirectionScore(x, y, 1, -1, player)
  board(x, y) = #PLAYER_NONE

  ProcedureReturn score
EndProcedure

; <summary>
; AiHasNeighbor
; </summary>
; <param name="x"></param>
; <param name="y"></param>
; <param name="radius"></param>
; <returns>Returns bool.</returns>
Procedure.b AiHasNeighbor(x.i, y.i, radius.i)
  Protected nx.i, ny.i
  Protected dx.i, dy.i

  For dy = -radius To radius
    For dx = -radius To radius
      If dx = 0 And dy = 0
        Continue
      EndIf

      nx = x + dx
      ny = y + dy

      If nx >= 0 And nx < #BOARD_SIZE And ny >= 0 And ny < #BOARD_SIZE
        If board(nx, ny) <> #PLAYER_NONE
          ProcedureReturn #True
        EndIf
      EndIf
    Next
  Next

  ProcedureReturn #False
EndProcedure

; <summary>
; AiFindBestMove
; </summary>
; <returns>Returns bool.</returns>
Procedure.b AiFindBestMove()
  Protected x.i, y.i
  Protected bestScore.i = -1
  Protected score.i
  Protected attack.i, defense.i
  Protected opponent.i
  Protected found.i = #False
  Protected center.i = #BOARD_SIZE / 2

  If moveCount = 0
    aiMoveX = center
    aiMoveY = center
    ProcedureReturn #True
  EndIf

  opponent = #PLAYER_BLACK + #PLAYER_WHITE - aiPlayer

  For y = 0 To #BOARD_SIZE - 1
    For x = 0 To #BOARD_SIZE - 1
      If board(x, y) <> #PLAYER_NONE
        Continue
      EndIf

      If Not AiHasNeighbor(x, y, 2)
        Continue
      EndIf

      attack = AiEvaluateCell(x, y, aiPlayer)
      defense = AiEvaluateCell(x, y, opponent)

      If defense >= 1000000
        score = defense
      ElseIf attack >= 1000000
        score = attack
      Else
        score = attack + (defense * 95 / 100)
      EndIf

      If score > bestScore
        bestScore = score
        aiMoveX = x
        aiMoveY = y
        found = #True
      ElseIf score = bestScore And found
        If Abs(x - center) + Abs(y - center) < Abs(aiMoveX - center) + Abs(aiMoveY - center)
          aiMoveX = x
          aiMoveY = y
        EndIf
      EndIf
    Next
  Next

  ProcedureReturn found
EndProcedure

; <summary>
; AiMakeMove
; </summary>
; <returns>Returns void.</returns>
Procedure AiMakeMove()
  If gameMode <> #MODE_AI Or gameOver Or currentPlayer <> aiPlayer
    ProcedureReturn
  EndIf

  If AiFindBestMove()
    ApplyMove(aiMoveX, aiMoveY, #False)
    DrawBoard()

    If IsSound(#SOUND_PUTDOWN_PIECE) <> 0
      PlaySound(#SOUND_PUTDOWN_PIECE)
    EndIf
  EndIf
EndProcedure

; <summary>
; AiStartGame
; </summary>
; <returns>Returns void.</returns>
Procedure AiStartGame()
  NetDisconnect()

  gameMode = #MODE_AI
  myPlayer = #PLAYER_BLACK
  aiPlayer = #PLAYER_WHITE

  InitBoard()
  DrawBoard()
  SetGadgetText(#LBL_NET, "Human (Black) vs AI (White)")
  DisableGadget(#BTN_UNDO, #False)
  UpdateStatus()
EndProcedure

; IDE Options = PureBasic 6.40 (Windows - x64)
; Folding = -
; Optimizer
; EnableAsm
; EnableXP
; DPIAware
; EnableOnError
; DisableDebugger
; CompileSourceDirectory
