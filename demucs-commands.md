# Demucs: Command Cheat Sheet

Demucs splits a song into stems (vocals, drums, bass, other).

General form:

    demucs [options] file1 file2 ...

Results go to `./separated/<model>/<song-name>/` unless you use `-o`.

## Easiest way: the Demucs Splitter app (no terminal)

App location: `Applications/Demucs Splitter.app`. Open it from Launchpad or Spotlight, or drag it to your Dock.

To rebuild after changes: run `demucs-app/build.sh` (it reinstalls into Applications).

1. Drag one or more songs onto the app icon (or double-click it and pick files).
2. Choose: Vocals + Music, 4 stems, or 6 stems.
3. Choose: WAV or MP3.
4. Pick the folder to save into (starts in Downloads; you can make a New Folder there).
5. Wait for the "Done!" notification. The folder opens by itself.

Each song gets its own folder of stems inside the folder you picked. If something fails, the app shows the error; the full log is at `~/Library/Logs/Demucs Splitter.log`.

The commands below are only needed for extra options the app doesn't offer.

## Install (already done)

    uv tool install --force --python 3.12 --with numpy git+https://github.com/adefossez/demucs.git

## Choosing the model

| Option | What it does |
|---|---|
| `-n NAME` | Pick a model. Default is `htdemucs`. Others: `htdemucs_ft` (higher quality, slower), `htdemucs_6s` (6 stems, adds guitar and piano), `mdx_extra`. |
| `--list-models` | Show available models and exit. |
| `-s SIG` | Use a locally trained model by signature (advanced). |
| `--repo FOLDER` | Load models from a downloaded folder (advanced). |

## Output

| Option | What it does |
|---|---|
| `-o FOLDER` | Where to save results. Default `./separated`. |
| `--filename PATTERN` | Rename output files. Variables: `{track}`, `{trackext}`, `{stem}`, `{ext}`. Default `{track}/{stem}.{ext}`. |
| `--two-stems STEM` | Split into one stem plus the rest. E.g. `--two-stems=vocals` gives `vocals` and `no_vocals`. |
| `--other-method none/add/minus` | How `no_<stem>` is made. `none` = don't save it, `add` = sum the other stems, `minus` = original minus the stem. |
| `--mp3` | Save as MP3. |
| `--mp3-bitrate N` | MP3 bitrate, e.g. `320`. |
| `--mp3-preset 2-7` | MP3 encoder quality. 2 = best/slowest, 7 = fastest. |
| `--flac` | Save as FLAC (lossless, smaller than WAV). |
| `--int24` | Save WAV as 24-bit. |
| `--float32` | Save WAV as 32-bit float (twice the size). |
| `--clip-mode rescale/clamp/none` | How to avoid distortion if output is too loud. |

## Quality and speed

| Option | What it does |
|---|---|
| `-d DEVICE` | `cpu` or `mps` (Apple GPU). Default is cuda if available, else cpu. |
| `--shifts N` | Average N slightly shifted passes. Better quality, N times slower. `--shifts 1` is a cheap boost. |
| `--overlap 0.25` | Overlap between processed chunks. Higher = slightly better, slower. |
| `-j N` | Parallel jobs. Faster on multi-core, uses more memory. |

## Memory

| Option | What it does |
|---|---|
| `--segment N` | Chunk size in seconds. Smaller uses less memory. Use if you hit out-of-memory errors. |
| `--no-split` | Process the whole track in one piece. Can use a lot of memory. |

## Other

| Option | What it does |
|---|---|
| `-v` | Verbose output. |
| `-h` | Show help text. |

## Examples

Basic 4-stem split:

    demucs "$HOME/Downloads/song.mp3"

Vocals only, 320 kbps MP3, saved to the Desktop:

    demucs --two-stems=vocals --mp3 --mp3-bitrate 320 -o ~/Desktop/stems "song.mp3"

Higher quality model on the Apple GPU:

    demucs -n htdemucs_ft -d mps --shifts 1 "song.wav"

Note: if `-d mps` errors, drop it and Demucs will use the CPU.

## Troubleshooting

- `No module named 'numpy'`: reinstall with the install command above (it includes `--with numpy`).
- Out of memory: add `--segment 7` or a smaller number.
- Other missing module: reinstall with an extra `--with <module>`.
