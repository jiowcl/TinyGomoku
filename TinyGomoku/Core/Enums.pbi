;--------------------------------------------------------------------------------------------
;  Copyright (c) Ji-Feng Tsai. All rights reserved.
;  Code released under the MIT license.
;--------------------------------------------------------------------------------------------

#VERSION          = 1.1

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

; Piece
#PLAYER_NONE      = 0
#PLAYER_BLACK     = 1
#PLAYER_WHITE     = 2

; Game
#MODE_LOCAL       = 0
#MODE_HOST        = 1
#MODE_CLIENT      = 2
#MODE_AI          = 3

; Network
#NET_PORT_DEFAULT = 8765
#NET_SERVER       = 0

; Canvas
#CANVAS_DEFAULT_W = 550
#CANVAS_DEFAULT_H = 550

; Sounds
; From: https://soundeffect-lab.info/sound/button/
#SOUND_PUTDOWN_PIECE  = 100
#SOUND_COMPLETED_GAME = 200
#SOUND_NET_CONNECTION = 201

; Function Declare
Declare.i MinI(a.i, b.i)
Declare.i MaxI(a.i, b.i)

Declare.s PlayerName(player.i)
Declare.s PlayerStatusText(player.i)
Declare UpdateStatus()
Declare SetOnlineControlsEnabled(enabled.i)
Declare LoadUIFont()

Declare SyncCanvasSize()
Declare CalculateLayout()
Declare EnsureBoardImage()
Declare InitBoard()
Declare ScreenToBoard(sx.i, sy.i)
Declare.i BoardPosX(bx.i)
Declare.i CheckDirection(x.i, y.i, dx.i, dy.i, player.i)
Declare.b CheckWin(x.i, y.i, player.i)
Declare.b CheckDraw()
Declare FinishGame(wonPlayer.i, isDraw.i)
Declare.b ApplyMove(x.i, y.i, fromNetwork.i)
Declare UndoMove()

Declare DrawPiece(sx.i, sy.i, isBlack.i)
Declare DrawWinLine()
Declare DrawBoardContent()
Declare DrawBoard()

Declare NetSendLine(line.s)
Declare NetReceiveData(connectionID.i)
Declare NetDisconnect()
Declare NetStartHost()
Declare NetJoinHost()
Declare NetStartLocal()
Declare NetPoll()

Declare.b AiFindBestMove()
Declare AiMakeMove()
Declare AiStartGame()

; IDE Options = PureBasic 6.40 (Windows - x64)
; CursorPosition = 5
; Optimizer
; EnableAsm
; EnableXP
; DPIAware
; EnableOnError
; DisableDebugger
; CompileSourceDirectory