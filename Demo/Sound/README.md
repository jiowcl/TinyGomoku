# Sound / Music assets

Optional files used by TinyGomoku:

## SFX (WAV)

| File | Usage |
|------|--------|
| `100.wav` | Put down a piece |
| `101.wav` | Opponent four-in-a-row threat cue |
| `200.wav` | Game completed |
| `201.wav` | Network connect / disconnect |

## BGM

Place one of these next to the WAV files (first found wins):

| File | Format |
|------|--------|
| `bgm.wav` | Waveform (supported via ModPlug) |
| `bgm.xm` | FastTracker II |
| `bgm.it` | Impulse Tracker |
| `bgm.mod` | ProTracker |

Played via PureBasic `LoadMusic` / `PlayMusic`. Keep volume moderate so SFX stay audible.

If a file is missing, the game still runs; that cue or BGM is skipped. When no BGM file is present, the **Music** checkbox is disabled.

Suggested sources: [効果音ラボ](https://soundeffect-lab.info/) for SFX; [PANICPUMPKIN](https://pansound.com) or other royalty-free tracks for BGM (attribute the author if required).
