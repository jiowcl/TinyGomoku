;--------------------------------------------------------------------------------------------
;  Copyright (c) Ji-Feng Tsai. All rights reserved.
;  Code released under the MIT license.
;--------------------------------------------------------------------------------------------

; <summary>
; ResolveAssetPath
; Prefer ./Sound (compile dir), then exe-side Sound/.
; </summary>
; <param name="fileName">string</param>
; <returns>Returns string.</returns>
Procedure.s ResolveAssetPath(fileName.s)
  Protected localPath.s = soundPath + fileName
  Protected exePath.s = GetPathPart(ProgramFilename()) + "Sound/" + fileName

  If FileSize(localPath) > 0
    ProcedureReturn localPath
  EndIf

  If FileSize(exePath) > 0
    ProcedureReturn exePath
  EndIf

  ProcedureReturn localPath
EndProcedure

; <summary>
; TryLoadBgmFile
; </summary>
; <param name="fileName">string</param>
; <returns>Returns bool.</returns>
Procedure.b TryLoadBgmFile(fileName.s)
  Protected path.s = ResolveAssetPath(fileName)

  If FileSize(path) <= 0
    ProcedureReturn #False
  EndIf

  If LoadMusic(#MUSIC_BGM, path) = 0
    ProcedureReturn #False
  EndIf

  musicLoaded = #True
  MusicVolume(#MUSIC_BGM, ClampI(musicVolume, 0, 100))

  ProcedureReturn #True
EndProcedure

; <summary>
; InitBgm
; Tries bgm.wav / bgm.xm / bgm.it / bgm.mod. Missing file is OK.
; </summary>
; <returns>Returns bool.</returns>
Procedure.b InitBgm()
  musicLoaded = #False
  musicPlaying = #False
  musicPaused = #False
  musicFadeAt = 0

  If TryLoadBgmFile("bgm.wav")
    ProcedureReturn #True
  EndIf

  If TryLoadBgmFile("bgm.xm")
    ProcedureReturn #True
  EndIf

  If TryLoadBgmFile("bgm.it")
    ProcedureReturn #True
  EndIf

  If TryLoadBgmFile("bgm.mod")
    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure

; <summary>
; FreeBgm
; </summary>
; <returns>Returns void.</returns>
Procedure FreeBgm()
  If musicLoaded
    StopMusic(#MUSIC_BGM)
    FreeMusic(#MUSIC_BGM)
  EndIf

  musicLoaded = #False
  musicPlaying = #False
  musicPaused = #False
  musicFadeAt = 0
EndProcedure

; <summary>
; ApplyMusicVolume
; </summary>
; <param name="vol">integer</param>
; <returns>Returns void.</returns>
Procedure ApplyMusicVolume(vol.i)
  If musicLoaded = #False
    ProcedureReturn
  EndIf

  MusicVolume(#MUSIC_BGM, ClampI(vol, 0, 100))
EndProcedure

; <summary>
; StartBgm
; </summary>
; <returns>Returns void.</returns>
Procedure StartBgm()
  If musicLoaded = #False Or musicEnabled = #False
    ProcedureReturn
  EndIf

  musicFadeAt = 0
  musicPaused = #False
  ApplyMusicVolume(musicVolume)
  PlayMusic(#MUSIC_BGM)
  musicPlaying = #True
EndProcedure

; <summary>
; StopBgm
; </summary>
; <returns>Returns void.</returns>
Procedure StopBgm()
  If musicLoaded = #False
    ProcedureReturn
  EndIf

  StopMusic(#MUSIC_BGM)
  musicPlaying = #False
  musicPaused = #False
  musicFadeAt = 0
EndProcedure

; <summary>
; EnsureBgmPlaying
; Restart BGM after fade-out / board reset when still enabled.
; </summary>
; <returns>Returns void.</returns>
Procedure EnsureBgmPlaying()
  If musicLoaded = #False Or musicEnabled = #False
    ProcedureReturn
  EndIf

  If musicPlaying = #False Or musicFadeAt <> 0
    StartBgm()
  EndIf
EndProcedure

; <summary>
; FadeOutBgm
; </summary>
; <returns>Returns void.</returns>
Procedure FadeOutBgm()
  If musicLoaded = #False Or musicPlaying = #False
    ProcedureReturn
  EndIf

  If musicPaused
    musicFadeFrom = #MUSIC_PAUSE_VOLUME
  Else
    musicFadeFrom = musicVolume
  EndIf

  musicFadeAt = ElapsedMilliseconds()
  musicPaused = #False
EndProcedure

; <summary>
; MusicTick
; Soft fade-out after game end.
; </summary>
; <returns>Returns void.</returns>
Procedure MusicTick()
  Protected elapsed.i
  Protected prog.i
  Protected vol.i

  If musicFadeAt = 0 Or musicLoaded = #False
    ProcedureReturn
  EndIf

  elapsed = ElapsedMilliseconds() - musicFadeAt
  If elapsed >= #MUSIC_FADE_MS
    StopBgm()
    ProcedureReturn
  EndIf

  prog = EaseOutQuad100(elapsed * 100 / #MUSIC_FADE_MS)
  vol = musicFadeFrom - musicFadeFrom * prog / 100
  ApplyMusicVolume(vol)
EndProcedure

; <summary>
; SyncMusicUi
; </summary>
; <returns>Returns void.</returns>
Procedure SyncMusicUi()
  If IsGadget(#CHK_MUSIC) = 0
    ProcedureReturn
  EndIf

  If musicLoaded
    DisableGadget(#CHK_MUSIC, 0)
    SetGadgetState(#CHK_MUSIC, musicEnabled)
  Else
    SetGadgetState(#CHK_MUSIC, 0)
    DisableGadget(#CHK_MUSIC, 1)
  EndIf
EndProcedure
