;--------------------------------------------------------------------------------------------
;  Copyright (c) Ji-Feng Tsai. All rights reserved.
;  Code released under the MIT license.
;--------------------------------------------------------------------------------------------

Global Dim board.i(#BOARD_SIZE - 1, #BOARD_SIZE - 1)
Global currentPlayer.i = #PLAYER_BLACK
Global gameOver.i = #False
Global winner.i = #PLAYER_NONE
Global moveCount.i = 0
Global Dim moveX.i(#MAX_MOVES - 1)
Global Dim moveY.i(#MAX_MOVES - 1)
Global Dim movePlayer.i(#MAX_MOVES - 1)

Global hoverX.i, hoverY.i
Global winLineCount.i
Global Dim winLineX.i(#MAX_WIN_POINTS - 1)
Global Dim winLineY.i(#MAX_WIN_POINTS - 1)

Global cellSize.i, padding.i, pieceRadius.i
Global gridLeft.i, gridTop.i, gridRight.i, gridBottom.i
Global canvasW.i = #CANVAS_DEFAULT_W
Global canvasH.i = #CANVAS_DEFAULT_H
Global boardImage.i = -1
Global boardImageW.i, boardImageH.i
Global uiFont.i
Global statusFont.i
Global stbX.i, stbY.i

Global gameMode.i = #MODE_LOCAL
Global myPlayer.i = #PLAYER_NONE
Global networkConnected.i = #False
Global netConnection.i = 0
Global netClientID.i = 0
Global netRxBuffer.s = ""

; IDE Options = PureBasic 6.40 (Windows - x64)
; CursorPosition = 32
; Optimizer
; EnableAsm
; EnableXP
; DPIAware
; EnableOnError
; DisableDebugger
; CompileSourceDirectory