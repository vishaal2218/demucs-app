-- Demucs Splitter: drag songs onto the app (or double-click it) to split them into stems.
-- You choose the save folder each time; each song gets its own folder of stems inside it.

property demucsPath : "demucs" -- found on PATH (pipx installs it to ~/.local/bin)
property logFile : "~/Library/Logs/Demucs\\ Splitter.log"

on run
	set picked to choose file with prompt "Choose the song(s) to split:" with multiple selections allowed
	splitFiles(picked)
end run

on open droppedFiles
	splitFiles(droppedFiles)
end open

on splitFiles(theFiles)
	set modeChoices to {"Vocals + Music (2 stems)", "Vocals, Drums, Bass, Other (4 stems)", "6 stems (adds Guitar + Piano)"}
	set modePick to choose from list modeChoices with title "Demucs Splitter" with prompt "How do you want to split it?" default items {item 1 of modeChoices}
	if modePick is false then return
	set modePick to item 1 of modePick

	set formatPick to button returned of (display dialog "Save the stems as:" with title "Demucs Splitter" buttons {"Cancel", "MP3 (smaller)", "WAV (best quality)"} default button "WAV (best quality)" cancel button "Cancel")

	set saveFolder to choose folder with prompt "Where should the stems be saved?" default location (path to downloads folder)
	set savePath to POSIX path of saveFolder

	set opts to "-d mps"
	if modePick is item 1 of modeChoices then set opts to opts & " --two-stems=vocals"
	if modePick is item 3 of modeChoices then set opts to opts & " -n htdemucs_6s"
	if formatPick starts with "MP3" then set opts to opts & " --mp3 --mp3-bitrate 320"

	set fileArgs to ""
	repeat with f in theFiles
		set fileArgs to fileArgs & " " & quoted form of POSIX path of f
	end repeat

	display notification "Splitting " & (count of theFiles) & " file(s). This can take a few minutes per song." with title "Demucs Splitter"

	-- Demucs always adds a model-named folder, so split into a temp folder, then move each song's folder into the chosen one.
	set tmpDir to do shell script "mktemp -d -t demucs-splitter"
	-- Apps launched from Finder don't see Homebrew, so add it to PATH (ffmpeg is needed for .m4a and video files)
	set cmd to "export PATH=$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH && " & quoted form of demucsPath & " " & opts & " -o " & quoted form of tmpDir & fileArgs & " > " & logFile & " 2>&1"
	set moveCmd to "for d in " & quoted form of tmpDir & "/*/*/; do ditto \"$d\" " & quoted form of savePath & "\"$(basename \"$d\")\"; done"
	try
		with timeout of 36000 seconds
			do shell script cmd
		end timeout
		do shell script moveCmd
	on error
		do shell script "rm -rf " & quoted form of tmpDir
		set lastLines to do shell script "grep -v -i warning " & logFile & " | tail -5"
		display dialog "Something went wrong while splitting:" & return & return & lastLines & return & return & "Full log: ~/Library/Logs/Demucs Splitter.log" with title "Demucs Splitter" buttons {"OK"} default button "OK" with icon stop
		return
	end try
	do shell script "rm -rf " & quoted form of tmpDir

	display notification "Done! Your stems are in " & savePath with title "Demucs Splitter" sound name "Glass"
	do shell script "open " & quoted form of savePath
end splitFiles
