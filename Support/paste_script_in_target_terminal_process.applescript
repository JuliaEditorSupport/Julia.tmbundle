on run argv
	
	set scriptToPaste to item 1 of argv
	set targetProcess to item 2 of argv
	
	tell application "Terminal"
		set windowCount to number of windows
		repeat with windowIndex from 1 to windowCount
			set tabCount to number of tabs of window windowIndex
			repeat with tabIndex from 1 to tabCount
				if processes of tab tabIndex of window windowIndex contains targetProcess then
					
					do script scriptToPaste in tab tabIndex of window windowIndex
                    set frontmost of window windowIndex to true
                    set selected of tab tabIndex of window windowIndex to true                    
                    -- tell application "System Events" to set frontmost of process "Terminal" to true -- Not necessesarily wanted behavior
					exit repeat
					
				end if
			end repeat
		end repeat
	end tell
end run