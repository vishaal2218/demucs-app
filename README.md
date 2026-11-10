# Demucs Splitter

A small Mac app: drag songs onto it (or double-click it) to split them into stems (vocals and music, 4 stems, or 6 stems) with [Demucs](https://github.com/adefossez/demucs). You choose MP3 or WAV and where to save; each song gets its own folder of stems.

## Set up from GitHub

Needs a Mac with Apple silicon and [Homebrew](https://brew.sh).

```bash
brew install pipx ffmpeg
pipx install demucs
git clone https://github.com/vishaal2218/demucs-app.git
cd demucs-app
./build.sh
```

`build.sh` builds **Demucs Splitter.app** and installs it into `/Applications`. The first split downloads the Demucs model. A log is written to `~/Library/Logs/Demucs Splitter.log`.

`demucs-commands.md` has the same splits as Terminal commands.

## Files

- `Demucs Splitter.applescript`: the app itself
- `icon/make-icon.swift`: draws the app icon
- `build.sh`: builds and installs the app
