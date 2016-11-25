#!/bin/bash
# Create the snippets from the latex_symbols.jl file

file=$(julia -e 'println(joinpath(JULIA_HOME, "..", "share", "julia", "base", "latex_symbols.jl"))')
[ -r "$file" ] || { echo "Can't find file '$file'" >&2; exit 1; }

# Check we're in the correct directory
dir="$(dirname "$0")"
[ -d "$dir/../Snippets" ] ||
	{ echo "Run this script from the 'Support' directory" >&2; exit 1; }

# Generate snippets files
awk '
	# Return a filename, based on name, by ensuring it does not match any other strings
	# in the array names, ignoring case.  Matching names have a + appended.
	function new_filename(name, names,   n){
		for (n in names) {
			if (tolower(name) == tolower(names[n])) {
				return new_filename(name"+", names)
			}
		}
		return name
	}

	BEGIN {
		# Command to return a UUID
		uuidgen = "uuidgen"
		# XML into which we sub
		base_snippet = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n<plist version=\"1.0\">\n<dict>\n	<key>content</key>\n	<string>@@SYMBOL@@</string>\n	<key>name</key>\n	<string>@@NAME@@</string>\n	<key>scope</key>\n	<string>source.julia</string>\n	<key>tabTrigger</key>\n	<string>\\@@NAME@@</string>\n	<key>uuid</key>\n	<string>@@UUID@@</string>\n</dict>\n</plist>"
		# TextMate suffix for snippets
		extension = ".tmSnippet"
		# Snippet directory
		dir = "../Snippets"
	}
	
	# Lines where symbols are defined
	FILENAME == "'"$file"'" && $2 == "=>" {		
		i++
		gsub("\"","")
		gsub(",","")
		
		gsub("\\\\", "", $1) # Remove \s; reinsert later
		name = $1
		symbol = $3
		symbol_sub = symbol
		# Convert notation for raw Unicode numbers
		if (symbol ~ /\\u..../) {
			symbol = "&#" substr(symbol,3)";"
			symbol_sub = "\\" symbol
			next # Not working with TM for now; not sure why...
		}
		
		# Work around macOS case-insensitivity by modifying filenames where needed
		filename[i] = new_filename(name, filename)
		
		uuidgen | getline uuid
		close(uuidgen)
		
		# Replace relevant parts of base snippet XML
		s = base_snippet
		gsub("@@NAME@@", name, s)
		gsub("@@SYMBOL@@", symbol_sub, s)
		gsub("@@UUID@@", uuid, s)
		path = dir "/" filename[i] "" extension
		print s > path
		close(path)
		print "Created snippet for symbol \"" symbol "\" in file \"" filename[i] "\""
	}
' "$file"
