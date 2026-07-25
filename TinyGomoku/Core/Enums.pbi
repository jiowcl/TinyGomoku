;--------------------------------------------------------------------------------------------
;  Copyright (c) Ji-Feng Tsai. All rights reserved.
;  Code released under the MIT license.
;--------------------------------------------------------------------------------------------

#APP_VERSION$     = "1.2"
#VERSION          = 1.2

; CheckerBoard
#BOARD_SIZE       = 15
#MAX_MOVES        = #BOARD_SIZE * #BOARD_SIZE
#MAX_WIN_POINTS   = 9

; Window
#WIN_MAIN         = 0
#CANVAS           = 1
#BTN_RESTART      = 2
#BTN_UNDO         = 3
#LBL_STATUS       = 4
#BTN_LOCAL        = 5
#BTN_HOST         = 6
#BTN_JOIN         = 7
#STR_HOST         = 8
#STR_PORT         = 9
#LBL_NET          = 10
#BTN_AI           = 11
#CMB_AI_DIFF      = 12
#CMB_AI_SIDE      = 13
#CHK_SOUND        = 14
#LBL_VERSION      = 15

; Piece
#PLAYER_NONE      = 0
#PLAYER_BLACK     = 1
#PLAYER_WHITE     = 2

; Game
#MODE_LOCAL       = 0
#MODE_HOST        = 1
#MODE_CLIENT      = 2
#MODE_AI          = 3

; AI
#AI_EASY          = 0
#AI_NORMAL        = 1
#AI_HARD          = 2
#AI_SIDE_BLACK    = 0
#AI_SIDE_WHITE    = 1
#AI_MOVE_DELAY_MS = 350
#AI_MAX_CANDIDATES = 64

; Network
#NET_PORT_DEFAULT = 8765
#NET_SERVER       = 0

; Canvas
#CANVAS_DEFAULT_W = 550
#CANVAS_DEFAULT_H = 550

; Sounds
; From: https://soundeffect-lab.info/sound/button/
#SOUND_PUTDOWN_PIECE   = 100
#SOUND_PUTDOWN_PIECE_4 = 101
#SOUND_COMPLETED_GAME  = 200
#SOUND_NET_CONNECTION  = 201

; Effects
#FX_PLACE_MS          = 280
#FX_WINLINE_PERIOD_MS = 800
#FX_WINLINE_THICK     = 3
#FX_RESULT_MS         = 480
#FX_UNDO_MS           = 240
#FX_UNDO_MAX          = 2
#FX_PARTICLE_MAX      = 40
#FX_PARTICLE_MS       = 1200

; Preferences
#PREF_FILENAME        = "TinyGomoku.ini"

; Function Declare
Declare.i MinI(a.i, b.i)
Declare.i MaxI(a.i, b.i)

Declare.s PlayerName(player.i)
Declare.s PlayerStatusText(player.i)
Declare UpdateStatus()
Declare SetOnlineControlsEnabled(enabled.i)
Declare LoadUIFont()
Declare.s PrefsFilePath()
Declare LoadAiPrefs()
Declare ApplyAiPrefsToUi()
Declare SaveAiPrefs()
Declare PlaySoundSafe(soundId.i)

Declare SyncCanvasSize()
Declare CalculateLayout()
Declare EnsureBoardImage()
Declare InitBoard()
Declare ScreenToBoard(sx.i, sy.i)
Declare.i BoardPosX(bx.i)
Declare.i BoardPosY(by.i)
Declare.i CheckDirection(x.i, y.i, dx.i, dy.i, player.i)
Declare.b CheckWin(x.i, y.i, player.i)
Declare.b CheckDraw()
Declare FinishGame(wonPlayer.i, isDraw.i)
Declare.b HasFourInRow(x.i, y.i, player.i)
Declare PlayMoveSound(mover.i, x.i, y.i, fromNetwork.i)
Declare.b ApplyMove(x.i, y.i, fromNetwork.i)
Declare UndoMove()
Declare ClearUndoFx()
Declare QueueUndoGhost(moveIndex.i)

Declare DrawPiece(sx.i, sy.i, isBlack.i)
Declare DrawPieceFx(sx.i, sy.i, isBlack.i, radius.i, alpha.i)
Declare DrawWinLine()
Declare DrawUndoGhosts()
Declare DrawWinParticles()
Declare SpawnWinParticles()
Declare ClearParticleFx()
Declare DrawBoardContent()
Declare DrawBoard()
Declare.b EffectsActive()
Declare EffectsTick()
Declare.i PlaceFxProgress()
Declare.i PlaceFxLinear()
Declare.i PlaceFxScalePct()
Declare.i EaseOutQuad100(t.i)

Declare NetSendLine(line.s)
Declare NetReceiveData(connectionID.i)
Declare NetDisconnect()
Declare NetStartHost()
Declare NetJoinHost()
Declare NetStartLocal()
Declare NetPoll()

Declare.b AiFindBestMove()
Declare.i AiMoveDelay()
Declare.i AiThreatComboBonus(x.i, y.i, player.i)
Declare.i AiBestReplyScore(player.i)
Declare.b AiHasNeighbor(x.i, y.i, radius.i)
Declare.s AiDifficultyName(level.i)
Declare AiSyncDifficultyFromUi()
Declare AiSyncSideFromUi()
Declare AiApplySideSettings()
Declare AiUpdateModeLabel()
Declare AiEnsureTurn()
Declare AiMakeMove()
Declare AiScheduleMove()
Declare AiPoll()
Declare AiCancelPending()
Declare AiStartGame()
