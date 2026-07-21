;--------------------------------------------------------------------------------------------
;  Copyright (c) Ji-Feng Tsai. All rights reserved.
;  Code released under the MIT license.
;--------------------------------------------------------------------------------------------

; <summary>
; AiCountLine
; </summary>
; <param name="x">integer</param>
; <param name="y">integer</param>
; <param name="dx">integer</param>
; <param name="dy">integer</param>
; <param name="player">integer</param>
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
; <param name="x">integer</param>
; <param name="y">integer</param>
; <param name="dx">integer</param>
; <param name="dy">integer</param>
; <param name="player">integer</param>
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
; <param name="x">integer</param>
; <param name="y">integer</param>
; <param name="dx">integer</param>
; <param name="dy">integer</param>
; <param name="player">integer</param>
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
      If aiDifficulty = #AI_HARD
        ProcedureReturn 8000
      EndIf
      ProcedureReturn 5000
    EndIf
  EndIf

  If count = 3
    If openEnds = 2
      If aiDifficulty = #AI_HARD
        ProcedureReturn 3500
      ElseIf aiDifficulty = #AI_EASY
        ProcedureReturn 800
      EndIf
      ProcedureReturn 2000
    ElseIf openEnds = 1
      If aiDifficulty = #AI_HARD
        ProcedureReturn 400
      EndIf
      ProcedureReturn 200
    EndIf
  EndIf

  If count = 2
    If openEnds = 2
      If aiDifficulty = #AI_HARD
        ProcedureReturn 80
      EndIf
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
; <param name="x">integer</param>
; <param name="y">integer</param>
; <param name="player">integer</param>
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
; <param name="x">integer</param>
; <param name="y">integer</param>
; <param name="radius">integer</param>
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
; AiDifficultyName
; </summary>
; <param name="level">integer</param>
; <returns>Returns string.</returns>
Procedure.s AiDifficultyName(level.i)
  Select level
    Case #AI_EASY
      ProcedureReturn "Easy"
    Case #AI_HARD
      ProcedureReturn "Hard"
    Default
      ProcedureReturn "Normal"
  EndSelect
EndProcedure

; <summary>
; AiMoveDelay
; </summary>
; <returns>Returns integer.</returns>
Procedure.i AiMoveDelay()
  Select aiDifficulty
    Case #AI_EASY
      ProcedureReturn 250
    Case #AI_HARD
      ProcedureReturn 500
    Default
      ProcedureReturn #AI_MOVE_DELAY_MS
  EndSelect
EndProcedure

; <summary>
; AiSyncDifficultyFromUi
; </summary>
; <returns>Returns void.</returns>
Procedure AiSyncDifficultyFromUi()
  Protected state.i = GetGadgetState(#CMB_AI_DIFF)

  If state < #AI_EASY Or state > #AI_HARD
    state = #AI_NORMAL
    SetGadgetState(#CMB_AI_DIFF, state)
  EndIf

  aiDifficulty = state
EndProcedure

; <summary>
; AiSyncSideFromUi
; </summary>
; <returns>Returns void.</returns>
Procedure AiSyncSideFromUi()
  Protected state.i = GetGadgetState(#CMB_AI_SIDE)

  If state < #AI_SIDE_BLACK Or state > #AI_SIDE_WHITE
    state = #AI_SIDE_BLACK
    SetGadgetState(#CMB_AI_SIDE, state)
  EndIf

  aiHumanSide = state
EndProcedure

; <summary>
; AiApplySideSettings
; </summary>
; <returns>Returns void.</returns>
Procedure AiApplySideSettings()
  If aiHumanSide = #AI_SIDE_WHITE
    myPlayer = #PLAYER_WHITE
    aiPlayer = #PLAYER_BLACK
  Else
    myPlayer = #PLAYER_BLACK
    aiPlayer = #PLAYER_WHITE
  EndIf
EndProcedure

; <summary>
; AiUpdateModeLabel
; </summary>
; <returns>Returns void.</returns>
Procedure AiUpdateModeLabel()
  SetGadgetText(#LBL_NET, "Human (" + PlayerName(myPlayer) + ") vs AI (" + PlayerName(aiPlayer) + ") - " + AiDifficultyName(aiDifficulty))
EndProcedure

; <summary>
; AiEnsureTurn
; </summary>
; <returns>Returns void.</returns>
Procedure AiEnsureTurn()
  If gameMode = #MODE_AI And Not gameOver And currentPlayer = aiPlayer And Not aiPending
    AiScheduleMove()
  EndIf
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
  Protected radius.i = 2
  Protected defensePct.i = 95
  Protected Dim candX.i(#AI_MAX_CANDIDATES - 1)
  Protected Dim candY.i(#AI_MAX_CANDIDATES - 1)
  Protected candCount.i = 0
  Protected threshold.i
  Protected pick.i

  Select aiDifficulty
    Case #AI_EASY
      radius = 1
      defensePct = 55
    Case #AI_HARD
      radius = 2
      defensePct = 105
    Default
      radius = 2
      defensePct = 95
  EndSelect

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

      If Not AiHasNeighbor(x, y, radius)
        Continue
      EndIf

      attack = AiEvaluateCell(x, y, aiPlayer)
      defense = AiEvaluateCell(x, y, opponent)

      If defense >= 1000000
        score = defense
      ElseIf attack >= 1000000
        score = attack
      Else
        score = attack + (defense * defensePct / 100)
      EndIf

      If score > bestScore
        bestScore = score
        aiMoveX = x
        aiMoveY = y
        found = #True
      ElseIf score = bestScore And found And aiDifficulty <> #AI_EASY
        If Abs(x - center) + Abs(y - center) < Abs(aiMoveX - center) + Abs(aiMoveY - center)
          aiMoveX = x
          aiMoveY = y
        EndIf
      EndIf
    Next
  Next

  If found = #False
    ProcedureReturn #False
  EndIf

  If aiDifficulty = #AI_EASY
    threshold = bestScore * 45 / 100
    If threshold < 1 And bestScore > 0
      threshold = 1
    EndIf

    For y = 0 To #BOARD_SIZE - 1
      For x = 0 To #BOARD_SIZE - 1
        If board(x, y) <> #PLAYER_NONE
          Continue
        EndIf

        If Not AiHasNeighbor(x, y, radius)
          Continue
        EndIf

        attack = AiEvaluateCell(x, y, aiPlayer)
        defense = AiEvaluateCell(x, y, opponent)

        If defense >= 1000000
          score = defense
        ElseIf attack >= 1000000
          score = attack
        Else
          score = attack + (defense * defensePct / 100)
        EndIf

        If score >= threshold And candCount < #AI_MAX_CANDIDATES
          candX(candCount) = x
          candY(candCount) = y
          candCount + 1
        EndIf
      Next
    Next

    If candCount > 0
      pick = Random(candCount - 1)
      aiMoveX = candX(pick)
      aiMoveY = candY(pick)
    EndIf
  EndIf

  ProcedureReturn #True
EndProcedure

; <summary>
; AiCancelPending
; </summary>
; <returns>Returns void.</returns>
Procedure AiCancelPending()
  aiPending = #False
  aiPendingAt = 0
EndProcedure

; <summary>
; AiScheduleMove
; </summary>
; <returns>Returns void.</returns>
Procedure AiScheduleMove()
  If gameMode <> #MODE_AI Or gameOver Or currentPlayer <> aiPlayer
    ProcedureReturn
  EndIf

  aiPending = #True
  aiPendingAt = ElapsedMilliseconds() + AiMoveDelay()
  UpdateStatus()
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
; AiPoll
; </summary>
; <returns>Returns void.</returns>
Procedure AiPoll()
  If Not aiPending
    ProcedureReturn
  EndIf

  If gameMode <> #MODE_AI Or gameOver Or currentPlayer <> aiPlayer
    AiCancelPending()
    ProcedureReturn
  EndIf

  If ElapsedMilliseconds() < aiPendingAt
    ProcedureReturn
  EndIf

  AiCancelPending()
  AiMakeMove()
EndProcedure

; <summary>
; AiStartGame
; </summary>
; <returns>Returns void.</returns>
Procedure AiStartGame()
  NetDisconnect()

  AiSyncDifficultyFromUi()
  AiSyncSideFromUi()
  AiApplySideSettings()
  gameMode = #MODE_AI
  AiCancelPending()

  InitBoard()
  DrawBoard()
  AiUpdateModeLabel()
  DisableGadget(#BTN_UNDO, #False)
  UpdateStatus()
  AiEnsureTurn()
EndProcedure

; IDE Options = PureBasic 6.40 (Windows - x64)
; CursorPosition = 442
; FirstLine = 397
; Folding = ---
; Optimizer
; EnableAsm
; EnableXP
; DPIAware
; EnableOnError
; DisableDebugger
; CompileSourceDirectory