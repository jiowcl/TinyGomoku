;--------------------------------------------------------------------------------------------
;  Copyright (c) Ji-Feng Tsai. All rights reserved.
;  Code released under the MIT license.
;--------------------------------------------------------------------------------------------

; <summary>
; MinI
; </summary>
; <param name="a">integer</param>
; <param name="b">integer</param>
; <returns>Returns integer.</returns>
Procedure.i MinI(a.i, b.i)
  If a < b
    ProcedureReturn a
  EndIf
  
  ProcedureReturn b
EndProcedure

; <summary>
; MaxI
; </summary>
; <param name="a">integer</param>
; <param name="b">integer</param>
; <returns>Returns integer.</returns>
Procedure.i MaxI(a.i, b.i)
  If a > b
    ProcedureReturn a
  EndIf
  
  ProcedureReturn b
EndProcedure

; <summary>
; ClampI
; </summary>
; <param name="v">integer</param>
; <param name="lo">integer</param>
; <param name="hi">integer</param>
; <returns>Returns integer.</returns>
Procedure.i ClampI(v.i, lo.i, hi.i)
  If v < lo
    ProcedureReturn lo
  EndIf

  If v > hi
    ProcedureReturn hi
  EndIf

  ProcedureReturn v
EndProcedure

; <summary>
; PlayerName
; </summary>
; <param name="player">integer</param>
; <returns>Returns string.</returns>
Procedure.s PlayerName(player.i)
  If player = #PLAYER_BLACK
    ProcedureReturn "Black Side"
  EndIf
  
  ProcedureReturn "White Side"
EndProcedure

; <summary>
; PlayerStatusText
; </summary>
; <param name="player">integer</param>
; <returns>Returns string.</returns>
Procedure.s PlayerStatusText(player.i)
  ProcedureReturn PlayerName(player) + " Plays the Pieces"
EndProcedure

; <summary>
; UpdateStatus
; </summary>
; <returns>Returns void.</returns>
Procedure UpdateStatus()
  Protected msg.s

  If gameOver
    ProcedureReturn
  EndIf

  If gameMode = #MODE_LOCAL
    SetGadgetText(#LBL_STATUS, PlayerStatusText(currentPlayer))
    
    ProcedureReturn
  EndIf

  If gameMode = #MODE_AI
    If currentPlayer = myPlayer
      SetGadgetText(#LBL_STATUS, "Your Turn (" + PlayerName(myPlayer) + ")")
    Else
      SetGadgetText(#LBL_STATUS, "AI is Thinking… (" + PlayerName(aiPlayer) + ")")
    EndIf
    
    ProcedureReturn
  EndIf

  If Not networkConnected
    Select gameMode
      Case #MODE_HOST
        msg = "Waiting for Your Opponent to Join... (You are Black Side)"
      Case #MODE_CLIENT
        msg = "Connecting…"
      Default
        msg = "Not connected"
    EndSelect
    
    SetGadgetText(#LBL_STATUS, msg)
    
    ProcedureReturn
  EndIf

  If currentPlayer = myPlayer
    SetGadgetText(#LBL_STATUS, "It's Your Turn to Play Chess. (" + PlayerName(myPlayer) + ")")
  Else
    SetGadgetText(#LBL_STATUS, "Waiting for the Opponent… (" + PlayerName(currentPlayer) + ")")
  EndIf
EndProcedure

; <summary>
; SetOnlineControlsEnabled
; </summary>
; <param name="enabled">integer</param>
; <returns>Returns void.</returns>
Procedure SetOnlineControlsEnabled(enabled.i)
  Protected state.i

  If enabled
    state = 0
  Else
    state = 1
  EndIf

  DisableGadget(#BTN_LOCAL, state)
  DisableGadget(#BTN_AI, state)
  DisableGadget(#CMB_AI_DIFF, state)
  DisableGadget(#CMB_AI_SIDE, state)
  DisableGadget(#BTN_HOST, state)
  DisableGadget(#BTN_JOIN, state)
  DisableGadget(#STR_HOST, state)
  DisableGadget(#STR_PORT, state)
EndProcedure

; <summary>
; PlaySoundSafe
; </summary>
; <param name="soundId">integer</param>
; <returns>Returns void.</returns>
Procedure PlaySoundSafe(soundId.i)
  If soundEnabled = #False
    ProcedureReturn
  EndIf

  If IsSound(soundId) <> 0
    PlaySound(soundId)
  EndIf
EndProcedure

; <summary>
; LoadUIFont
; </summary>
; <returns>Returns void.</returns>
Procedure LoadUIFont()
  uiFont = LoadFont(#PB_Any, "Microsoft JhengHei UI", 12, #PB_Font_HighQuality)
  
  If uiFont = 0
    uiFont = LoadFont(#PB_Any, "Microsoft JhengHei", 12, #PB_Font_HighQuality)
  EndIf
  
  If uiFont = 0
    uiFont = LoadFont(#PB_Any, "Arial", 12, #PB_Font_HighQuality)
  EndIf
  
  If uiFont
    SetGadgetFont(#BTN_RESTART, FontID(uiFont))
    SetGadgetFont(#BTN_UNDO, FontID(uiFont))
    SetGadgetFont(#BTN_LOCAL, FontID(uiFont))
    SetGadgetFont(#BTN_AI, FontID(uiFont))
    SetGadgetFont(#CMB_AI_DIFF, FontID(uiFont))
    SetGadgetFont(#CMB_AI_SIDE, FontID(uiFont))
    SetGadgetFont(#BTN_HOST, FontID(uiFont))
    SetGadgetFont(#BTN_JOIN, FontID(uiFont))
    SetGadgetFont(#STR_HOST, FontID(uiFont))
    SetGadgetFont(#STR_PORT, FontID(uiFont))
    SetGadgetFont(#LBL_NET, FontID(uiFont))
    SetGadgetFont(#CHK_SOUND, FontID(uiFont))
    SetGadgetFont(#CHK_MUSIC, FontID(uiFont))
    SetGadgetFont(#LBL_VERSION, FontID(uiFont))
  EndIf

  statusFont = LoadFont(#PB_Any, "Microsoft JhengHei UI", 14, #PB_Font_HighQuality | #PB_Font_Bold)
  
  If statusFont = 0
    statusFont = LoadFont(#PB_Any, "Microsoft JhengHei", 14, #PB_Font_HighQuality | #PB_Font_Bold)
  EndIf
  
  If statusFont = 0
    statusFont = LoadFont(#PB_Any, "Arial", 14, #PB_Font_HighQuality | #PB_Font_Bold)
  EndIf
  
  If statusFont
    SetGadgetFont(#LBL_STATUS, FontID(statusFont))
  EndIf
EndProcedure

; <summary>
; PrefsFilePath
; </summary>
; <returns>Returns string.</returns>
Procedure.s PrefsFilePath()
  ProcedureReturn GetPathPart(ProgramFilename()) + #PREF_FILENAME
EndProcedure

; <summary>
; LoadAiPrefs
; </summary>
; <returns>Returns void.</returns>
Procedure LoadAiPrefs()
  If OpenPreferences(PrefsFilePath()) = 0
    ProcedureReturn
  EndIf

  PreferenceGroup("AI")
  aiDifficulty = ReadPreferenceInteger("Difficulty", #AI_NORMAL)
  aiHumanSide = ReadPreferenceInteger("Side", #AI_SIDE_BLACK)

  PreferenceGroup("Network")
  prefHost = ReadPreferenceString("Host", "127.0.0.1")
  prefPort = ReadPreferenceString("Port", Str(#NET_PORT_DEFAULT))

  PreferenceGroup("Audio")
  soundEnabled = ReadPreferenceInteger("Enabled", 1)
  musicEnabled = ReadPreferenceInteger("MusicEnabled", 1)
  musicVolume = ReadPreferenceInteger("MusicVolume", #MUSIC_VOLUME_DEFAULT)

  ClosePreferences()

  If aiDifficulty < #AI_EASY Or aiDifficulty > #AI_HARD
    aiDifficulty = #AI_NORMAL
  EndIf

  If aiHumanSide < #AI_SIDE_BLACK Or aiHumanSide > #AI_SIDE_WHITE
    aiHumanSide = #AI_SIDE_BLACK
  EndIf

  If Trim(prefHost) = ""
    prefHost = "127.0.0.1"
  EndIf

  If Val(prefPort) <= 0 Or Val(prefPort) > 65535
    prefPort = Str(#NET_PORT_DEFAULT)
  EndIf

  If soundEnabled <> 0
    soundEnabled = #True
  Else
    soundEnabled = #False
  EndIf

  If musicEnabled <> 0
    musicEnabled = #True
  Else
    musicEnabled = #False
  EndIf

  musicVolume = ClampI(musicVolume, 0, 100)
EndProcedure

; <summary>
; ApplyAiPrefsToUi
; </summary>
; <returns>Returns void.</returns>
Procedure ApplyAiPrefsToUi()
  SetGadgetState(#CMB_AI_DIFF, aiDifficulty)
  SetGadgetState(#CMB_AI_SIDE, aiHumanSide)
  SetGadgetText(#STR_HOST, prefHost)
  SetGadgetText(#STR_PORT, prefPort)
  SetGadgetState(#CHK_SOUND, soundEnabled)
  SyncMusicUi()
EndProcedure

; <summary>
; SaveAiPrefs
; </summary>
; <returns>Returns void.</returns>
Procedure SaveAiPrefs()
  If IsGadget(#CMB_AI_DIFF)
    aiDifficulty = GetGadgetState(#CMB_AI_DIFF)
    aiHumanSide = GetGadgetState(#CMB_AI_SIDE)
    prefHost = Trim(GetGadgetText(#STR_HOST))
    prefPort = Trim(GetGadgetText(#STR_PORT))
    soundEnabled = GetGadgetState(#CHK_SOUND)
    If IsGadget(#CHK_MUSIC) And musicLoaded
      musicEnabled = GetGadgetState(#CHK_MUSIC)
    EndIf
  EndIf

  If aiDifficulty < #AI_EASY Or aiDifficulty > #AI_HARD
    aiDifficulty = #AI_NORMAL
  EndIf

  If aiHumanSide < #AI_SIDE_BLACK Or aiHumanSide > #AI_SIDE_WHITE
    aiHumanSide = #AI_SIDE_BLACK
  EndIf

  If prefHost = ""
    prefHost = "127.0.0.1"
  EndIf

  If Val(prefPort) <= 0 Or Val(prefPort) > 65535
    prefPort = Str(#NET_PORT_DEFAULT)
  EndIf

  If soundEnabled <> 0
    soundEnabled = #True
  Else
    soundEnabled = #False
  EndIf

  If musicEnabled <> 0
    musicEnabled = #True
  Else
    musicEnabled = #False
  EndIf

  musicVolume = ClampI(musicVolume, 0, 100)

  If CreatePreferences(PrefsFilePath()) = 0
    ProcedureReturn
  EndIf

  PreferenceGroup("AI")
  WritePreferenceInteger("Difficulty", aiDifficulty)
  WritePreferenceInteger("Side", aiHumanSide)

  PreferenceGroup("Network")
  WritePreferenceString("Host", prefHost)
  WritePreferenceString("Port", prefPort)

  PreferenceGroup("Audio")
  WritePreferenceInteger("Enabled", soundEnabled)
  WritePreferenceInteger("MusicEnabled", musicEnabled)
  WritePreferenceInteger("MusicVolume", musicVolume)

  ClosePreferences()
EndProcedure
