;--------------------------------------------------------------------------------------------
;  Copyright (c) Ji-Feng Tsai. All rights reserved.
;  Code released under the MIT license.
;--------------------------------------------------------------------------------------------

; <summary>
; EaseOutQuad100
; </summary>
; <param name="t"></param>
; <returns>Returns 0-100 eased.</returns>
Procedure.i EaseOutQuad100(t.i)
  Protected u.i

  If t <= 0
    ProcedureReturn 0
  EndIf
  
  If t >= 100
    ProcedureReturn 100
  EndIf

  u = 100 - t
  ProcedureReturn 100 - (u * u) / 100
EndProcedure

; <summary>
; PlaceFxLinear
; </summary>
; <returns>Returns 0-100 linear time.</returns>
Procedure.i PlaceFxLinear()
  Protected elapsed.i

  If placeFxAt = 0 Or moveCount = 0
    ProcedureReturn 100
  EndIf

  elapsed = ElapsedMilliseconds() - placeFxAt

  If elapsed >= #FX_PLACE_MS
    ProcedureReturn 100
  EndIf

  If elapsed <= 0
    ProcedureReturn 0
  EndIf

  ProcedureReturn elapsed * 100 / #FX_PLACE_MS
EndProcedure

; <summary>
; PlaceFxProgress
; Eased alpha progress 0-100.
; </summary>
; <returns>Returns integer.</returns>
Procedure.i PlaceFxProgress()
  ProcedureReturn EaseOutQuad100(PlaceFxLinear())
EndProcedure

; <summary>
; PlaceFxScalePct
; Radius scale with overshoot, then settle to 100.
; </summary>
; <returns>Returns percent (e.g. 100 = normal size).</returns>
Procedure.i PlaceFxScalePct()
  Protected t.i = PlaceFxLinear()
  Protected p.i
  Protected grow.i

  If t >= 100
    ProcedureReturn 100
  EndIf

  If t < 72
    p = EaseOutQuad100(t * 100 / 72)
    ; Grow from 20% to 112%
    grow = 20 + p * 92 / 100
    ProcedureReturn grow
  EndIf

  ; Settle 112% → 100%
  p = (t - 72) * 100 / 28
  p = EaseOutQuad100(p)
  ProcedureReturn 112 - p * 12 / 100
EndProcedure

; <summary>
; DrawPiece
; </summary>
; <param name="sx">integer</param>
; <param name="sy">integer</param>
; <param name="isBlack">integer</param>
; <returns>Returns void.</returns>
Procedure DrawPiece(sx.i, sy.i, isBlack.i)
  DrawPieceFx(sx, sy, isBlack, pieceRadius, 255)
EndProcedure

; <summary>
; DrawPieceFx
; Soft shadow + body + rim + highlight.
; </summary>
; <param name="sx">integer</param>
; <param name="sy">integer</param>
; <param name="isBlack">integer</param>
; <param name="radius">integer</param>
; <param name="alpha">integer</param>
; <returns>Returns void.</returns>
Procedure DrawPieceFx(sx.i, sy.i, isBlack.i, radius.i, alpha.i)
  Protected r.i = radius
  Protected shadowA.i, rimA.i, highA.i
  Protected hx.i, hy.i, hr.i

  If r < 2
    r = 2
  EndIf

  If alpha < 1
    alpha = 1
  ElseIf alpha > 255
    alpha = 255
  EndIf

  shadowA = alpha * 55 / 255
  rimA = alpha
  highA = alpha * 140 / 255
  hx = sx - r / 3
  hy = sy - r / 3
  hr = MaxI(2, r / 3)

  DrawingMode(#PB_2DDrawing_AlphaBlend)

  ; Soft drop shadow
  Circle(sx + 1, sy + 2, r, RGBA(0, 0, 0, shadowA))

  If isBlack
    Circle(sx, sy, r, RGBA(18, 18, 18, alpha))
    Circle(sx, sy, MaxI(2, r - 1), RGBA(8, 8, 8, alpha))
    Circle(hx, hy, hr, RGBA(120, 120, 120, highA))
    Circle(hx - 1, hy - 1, MaxI(1, hr / 2), RGBA(210, 210, 210, highA * 2 / 3))
  Else
    Circle(sx, sy, r, RGBA(170, 170, 170, rimA))
    Circle(sx, sy, MaxI(2, r - 1), RGBA(250, 250, 250, alpha))
    Circle(hx, hy, hr, RGBA(255, 255, 255, highA))
    Circle(sx + r / 4, sy + r / 4, MaxI(2, r / 4), RGBA(200, 200, 200, alpha / 3))
  EndIf

  DrawingMode(#PB_2DDrawing_Default)
EndProcedure

; <summary>
; DrawWinLine
; </summary>
; <returns>Returns void.</returns>
Procedure DrawWinLine()
  Protected i.i, minIdx.i, maxIdx.i
  Protected minX.i, minY.i, maxX.i, maxY.i
  Protected sx1.i, sy1.i, sx2.i, sy2.i
  Protected phase.i, alpha.i, softAlpha.i, coreAlpha.i
  Protected period.i = #FX_WINLINE_PERIOD_MS
  Protected ox.i, oy.i
  Protected thick.i = #FX_WINLINE_THICK

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

  If winFxAt > 0
    phase = (ElapsedMilliseconds() - winFxAt) % period
    If phase > period / 2
      phase = period - phase
    EndIf
    ; Triangle 0..period/2 → alpha 120..255
    alpha = 120 + phase * 135 / (period / 2)
  Else
    alpha = 230
  EndIf

  softAlpha = alpha * 70 / 255
  If softAlpha < 50
    softAlpha = 50
  EndIf
  coreAlpha = alpha

  DrawingMode(#PB_2DDrawing_AlphaBlend)

  ; Soft thick glow via offset strokes
  For oy = -thick To thick
    For ox = -thick To thick
      If ox * ox + oy * oy <= thick * thick
        FrontColor(RGBA(255, 60, 60, softAlpha))
        LineXY(sx1 + ox, sy1 + oy, sx2 + ox, sy2 + oy)
      EndIf
    Next
  Next

  ; Bright core
  FrontColor(RGBA(255, 230, 120, coreAlpha))
  LineXY(sx1, sy1, sx2, sy2)
  FrontColor(RGBA(255, 40, 40, coreAlpha))
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
  Protected fxProgress.i
  Protected fxScale.i
  Protected fxRadius.i, fxAlpha.i
  Protected lastX.i = -1, lastY.i = -1
  Protected animatingPlace.i = #False
  Protected resultProg.i, resultElapsed.i
  Protected resultAlpha.i, resultShadow.i, resultRise.i

  CalculateLayout()

  fxProgress = PlaceFxProgress()
  fxScale = PlaceFxScalePct()
  If moveCount > 0 And PlaceFxLinear() < 100
    lastX = moveX(moveCount - 1)
    lastY = moveY(moveCount - 1)
    animatingPlace = #True
  EndIf

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
    If gameMode = #MODE_LOCAL Or gameMode = #MODE_AI Or (networkConnected And currentPlayer = myPlayer)
      If Not (gameMode = #MODE_AI And currentPlayer = aiPlayer)
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
  EndIf

  For y = 0 To #BOARD_SIZE - 1
    For x = 0 To #BOARD_SIZE - 1
      If board(x, y) <> #PLAYER_NONE
        If animatingPlace And x = lastX And y = lastY
          Continue
        EndIf

        sx = BoardPosX(x) : sy = BoardPosY(y)
        DrawPiece(sx, sy, Bool(board(x, y) = #PLAYER_BLACK))
      EndIf
    Next
  Next

  If animatingPlace
    sx = BoardPosX(lastX) : sy = BoardPosY(lastY)
    fxRadius = MaxI(2, pieceRadius * fxScale / 100)
    fxAlpha = 70 + fxProgress * 185 / 100
    If fxAlpha > 255
      fxAlpha = 255
    EndIf
    DrawPieceFx(sx, sy, Bool(board(lastX, lastY) = #PLAYER_BLACK), fxRadius, fxAlpha)
  EndIf

  DrawUndoGhosts()

  If moveCount > 0 And PlaceFxLinear() >= 65
    last = moveCount - 1
    sx = BoardPosX(moveX(last)) : sy = BoardPosY(moveY(last))
    r = MaxI(4, cellSize / 7)
    
    FrontColor(RGB(255, 0, 0))
    LineXY(sx - r, sy, sx + r, sy)
    LineXY(sx, sy - r, sx, sy + r)
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

    resultProg = 100
    If resultFxAt > 0
      resultElapsed = ElapsedMilliseconds() - resultFxAt
      If resultElapsed < #FX_RESULT_MS
        resultProg = EaseOutQuad100(resultElapsed * 100 / #FX_RESULT_MS)
      EndIf
    EndIf

    resultAlpha = resultProg * 255 / 100
    resultShadow = resultProg * 140 / 100
    resultRise = (100 - resultProg) * 10 / 100

    font = LoadFont(#PB_Any, "Microsoft JhengHei UI", MaxI(20, cellSize * 4 / 5), #PB_Font_HighQuality)
    
    If font = 0
      font = LoadFont(#PB_Any, "Microsoft JhengHei", MaxI(20, cellSize * 4 / 5), #PB_Font_HighQuality)
    EndIf
    
    If font
      DrawingFont(FontID(font))
      DrawingMode(#PB_2DDrawing_AlphaBlend)
      FrontColor(RGBA(0, 0, 0, resultShadow))
      DrawText((canvasW - TextWidth(resultText)) / 2 + 3, (canvasH - TextHeight(resultText)) / 2 + 3 + resultRise, resultText)

      If winner = #PLAYER_BLACK
        FrontColor(RGBA(255, 215, 0, resultAlpha))
      ElseIf winner = #PLAYER_WHITE
        FrontColor(RGBA(255, 255, 255, resultAlpha))
      Else
        FrontColor(RGBA(144, 238, 144, resultAlpha))
      EndIf
      
      DrawText((canvasW - TextWidth(resultText)) / 2, (canvasH - TextHeight(resultText)) / 2 + resultRise, resultText)
      DrawingMode(#PB_2DDrawing_Default)
      FreeFont(font)
    EndIf
  EndIf

  ; Win line above dim overlay so the pulse stays readable
  If gameOver And winner <> #PLAYER_NONE
    DrawWinLine()
  EndIf

  DrawWinParticles()
EndProcedure

; <summary>
; ClearParticleFx
; </summary>
; <returns>Returns void.</returns>
Procedure ClearParticleFx()
  particleCount = 0
  particleFxAt = 0
EndProcedure

; <summary>
; SpawnWinParticles
; </summary>
; <returns>Returns void.</returns>
Procedure SpawnWinParticles()
  Protected i.i, n.i
  Protected cx.i, cy.i
  Protected baseColor.i

  ClearParticleFx()
  CalculateLayout()

  If winLineCount > 0
    cx = 0
    cy = 0
    For i = 0 To winLineCount - 1
      cx + BoardPosX(winLineX(i))
      cy + BoardPosY(winLineY(i))
    Next
    cx = cx / winLineCount
    cy = cy / winLineCount
  Else
    cx = canvasW / 2
    cy = canvasH / 2
  EndIf

  If winner = #PLAYER_BLACK
    baseColor = RGB(255, 215, 0)
  Else
    baseColor = RGB(255, 255, 255)
  EndIf

  particleFxAt = ElapsedMilliseconds()
  n = #FX_PARTICLE_MAX
  particleCount = n

  For i = 0 To n - 1
    particleX(i) = cx + Random(24) - 12
    particleY(i) = cy + Random(24) - 12
    particleVx(i) = Random(11) - 5
    particleVy(i) = Random(9) - 8
    particleLife(i) = 700 + Random(500)
    If Random(2) = 0
      particleColor(i) = baseColor
    Else
      particleColor(i) = RGB(255, 80 + Random(40), 60)
    EndIf
  Next
EndProcedure

; <summary>
; DrawUndoGhosts
; </summary>
; <returns>Returns void.</returns>
Procedure DrawUndoGhosts()
  Protected i.i
  Protected elapsed.i
  Protected prog.i, alpha.i
  Protected sx.i, sy.i

  If undoFxCount <= 0 Or undoFxAt = 0
    ProcedureReturn
  EndIf

  elapsed = ElapsedMilliseconds() - undoFxAt
  If elapsed >= #FX_UNDO_MS
    ClearUndoFx()
    ProcedureReturn
  EndIf

  prog = EaseOutQuad100(elapsed * 100 / #FX_UNDO_MS)
  alpha = 220 - prog * 220 / 100
  If alpha < 1
    ProcedureReturn
  EndIf

  For i = 0 To undoFxCount - 1
    sx = BoardPosX(undoFxX(i))
    sy = BoardPosY(undoFxY(i))
    DrawPieceFx(sx, sy, Bool(undoFxPlayer(i) = #PLAYER_BLACK), pieceRadius, alpha)
  Next
EndProcedure

; <summary>
; DrawWinParticles
; </summary>
; <returns>Returns void.</returns>
Procedure DrawWinParticles()
  Protected i.i
  Protected age.i
  Protected sx.i, sy.i, r.i
  Protected alpha.i
  Protected now.i
  Protected cr.i, cg.i, cb.i

  If particleCount <= 0 Or particleFxAt = 0
    ProcedureReturn
  EndIf

  now = ElapsedMilliseconds()
  If now - particleFxAt > #FX_PARTICLE_MS
    ClearParticleFx()
    ProcedureReturn
  EndIf

  DrawingMode(#PB_2DDrawing_AlphaBlend)

  For i = 0 To particleCount - 1
    age = now - particleFxAt
    If age >= particleLife(i)
      Continue
    EndIf

    sx = particleX(i) + particleVx(i) * age / 18
    sy = particleY(i) + particleVy(i) * age / 18 + (age * age) / 9000
    alpha = 255 - age * 255 / particleLife(i)
    If alpha < 1
      Continue
    EndIf

    r = MaxI(2, 5 - age / 250)
    cr = Red(particleColor(i))
    cg = Green(particleColor(i))
    cb = Blue(particleColor(i))
    Circle(sx, sy, r + 1, RGBA(cr, cg, cb, alpha / 3))
    Circle(sx, sy, r, RGBA(cr, cg, cb, alpha))
  Next

  DrawingMode(#PB_2DDrawing_Default)
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

; <summary>
; EffectsActive
; </summary>
; <returns>Returns bool.</returns>
Procedure.b EffectsActive()
  If placeFxAt > 0 And (ElapsedMilliseconds() - placeFxAt) < #FX_PLACE_MS
    ProcedureReturn #True
  EndIf

  If resultFxAt > 0 And (ElapsedMilliseconds() - resultFxAt) < #FX_RESULT_MS
    ProcedureReturn #True
  EndIf

  If undoFxAt > 0 And undoFxCount > 0 And (ElapsedMilliseconds() - undoFxAt) < #FX_UNDO_MS
    ProcedureReturn #True
  EndIf

  If particleFxAt > 0 And particleCount > 0 And (ElapsedMilliseconds() - particleFxAt) < #FX_PARTICLE_MS
    ProcedureReturn #True
  EndIf

  If gameOver And winner <> #PLAYER_NONE And winFxAt > 0
    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure

; <summary>
; EffectsTick
; </summary>
; <returns>Returns void.</returns>
Procedure EffectsTick()
  If EffectsActive()
    DrawBoard()
  EndIf
EndProcedure

; IDE Options = PureBasic 6.40 (Windows - x64)
; CursorPosition = 20
; FirstLine = 51
; Folding = --
; Optimizer
; EnableAsm
; EnableXP
; DPIAware
; EnableOnError
; DisableDebugger
; CompileSourceDirectory