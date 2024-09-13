<#
Written By:			Brandon Johns
Version Created:	2024-09-13
Last Edited:		2024-09-13

# Almost same as
# https://github.com/Brandon-Johns/monash-thesis-template-latex-reworked
#   Changed the config and comments


********************************************************************************
Purpose
****************************************
This script runs the latexdiff utility, and does some extra post-processing

latexdiff generates tex file which can be built into a tracked changes pdf
	Read more about latexdiff here
	https://www.overleaf.com/learn/latex/Articles/Using_Latexdiff_For_Marking_Changes_To_Tex_Documents

This script is only for documents using the NUMERIC citation type
	The issue with direct use of latexdiff is that the citation numbers change
		without consideration of if the cite is inside of a \DIFdel{} or \DIFadd{}.
		Therefore, the resultant citation numbers don't match any document.
	This script post-processes the diff file to make
		\DIFdel{\cite{...}}: uses the numbers of old version
		\DIFadd{\cite{...}}: uses the numbers of new version
		\cite{...}:          uses the numbers of new version

This script also generates a .nocite file, which holds the citation order of the new version
	This is for use to \input{} into the top of your author response to reviewers comments.
	Hence, the response will use these same citation numbers as the diff file


********************************************************************************
Instructions
****************************************
Starting from the version of your article, as it was submitted for review

Install latexdiff

Save old version (DO THIS ONLY ONCE)
1) Compile main.tex
2) Run RevisionScripts\GenerateFlattened.ps1

Generate dif (REPEAT AS YOU MAKE CHANGES)
1) Revise the article as required
2) Compile main.tex
3) Run RevisionScripts\GenerateDiff.ps1
4) Write a review response using ReviewResponse.cls


********************************************************************************
Notes
****************************************
$fileOld.tex and $fileOld.bibkeys should be in the same directory
$fileOld.tex should be self-contained (no \input{} commands)
$fileOld.bibkeys should hold all citation keys in the order that the appear in the bibliography
	It should be formatted as follows
```
% Comments prefixed by a percent are permitted
example2
example1
example3
example4
```

#>
#********************************************************************************
# CONFIG
#****************************************
# Files to compare
$fileOld = 'Revisions\main_flat'
$fileNew = 'main'

# Filename for output
$fileDiff = 'main_diff'

# Optional arguments passed to latexdiff
$DiffOptions = @()
#$DiffOptions += '--flatten'
$DiffOptions += '--preamble=RevisionScripts\DiffPreamble.tex'
$DiffOptions += '--graphics-markup=none' # Level 1 was causing errors for some reason

# Add to list of commands that latexdiff is allowed to markup
#	Errors if you add commands that are used in xmpdata (related to package pdfx).
#	latexdiff struggles with table environments, particularly if you delete a whole row. Not much I can do.
#	algorithm2e is not really generalisable. The user will need to allow the commands themselves as desired
# safecmd means the command can appear inside of a DIFadd/DIFdel
# textcmd means DIFadd/DIFdel can appear inside of the last argument of the command
# context1cmd is weird
# context2cmd means how add only
$DiffOptions += '--append-safecmd="figref,tbref,eqref,chapref,secref,appref,algoref,algoRefLine,algoRefLines"'
#$DiffOptions += '--append-textcmd=""'
#$DiffOptions += '--append-context1cmd="captionbox"'
#$DiffOptions += '--append-context2cmd=""'


#********************************************************************************
# AUTOMATED
#****************************************
Push-Location $PSScriptRoot\..
If(-not (Test-Path "${fileOld}.tex"))     { throw "Can't find old file" }
If(-not (Test-Path "${fileOld}.bibkeys")) { throw "Can't find bibkeys file" }
If(-not (Test-Path "${fileNew}.tex"))     { throw "Can't find new file" }
If(-not (Test-Path "${fileNew}.bbl"))     { throw "Can't find bbl file. Compile ${fileNew}.tex, then try again" }

# Generate diff file
latexdiff $DiffOptions "${fileOld}.tex" "${fileNew}.tex" | Out-File "${fileDiff}.tex" -Encoding utf8
$diffFileContent = Get-Content -Path "${fileDiff}.tex" -Raw

#********************************************************************************
# AUTOMATED - Replace all \DIFdel{\cite{...}} with citation numbers according to 
#****************************************
# Create associative array (hash table) of key to citation number
$citedKeys = [ordered]@{}
$citeNumber = 1
foreach ($line in Get-Content -Path "${fileOld}.bibkeys") {
	if ($line -match '^(?!%)(?<citeKey>.+?)$') {
		$citedKeys[$Matches.citeKey] = $citeNumber;
		$citeNumber += 1;
	}
}

# Search diff file for a '\cite{}' inside of a '\DIFdel{}'
#	This regex assumes that the cite will come before any '}', which is very limiting
#		e.g. it would fail the case of '\DIFdel{\textbf{Hi} \cite{}}'
#		But testing shows that latexdiff will always split this into '\DIFdel{\textbf{Hi}} \DIFdel{\cite{}}'
#		So the failure case never happens yay.
#	Case sensitive match
$reCite = '(?<delCommand>\\DIFdel\{[^\}]*?(?<citeCommand>\\cite\{(?<citeKeys>.+?)\}))'
while($diffFileContent -cmatch $reCite) {
	# Split into array of individual keys
	$keysInCite = $Matches.citeKeys -split ','

	# Exchange keys for citation numbers and sort numerically
	$citeNumbersInCite = @()
	foreach ($key in $keysInCite) {
		$citeNumbersInCite += $citedKeys[$key];
	}
	$citeNumbersInCite = $citeNumbersInCite | Sort-Object {[int]$_}

	# String to write out
	$FormattedCite = '[' + ($citeNumbersInCite -join ',') + ']'

	# Replace the cite command with the formatted cite
	# Replace through the full capture string, as to not replace any cite not in a DIFdel
	$FormattedDIFdel = $Matches.delCommand.Replace($Matches.citeCommand, $FormattedCite)
	$diffFileContent = $diffFileContent.Replace($Matches.delCommand, $FormattedDIFdel)

	#Write-Host $Matches.delCommand
	#Write-Host $Matches.citeKeys
	#Write-Host $FormattedCite
	#Write-Host ''
}

# Remove all the redundant diff commands because they can sometimes cause problems
$reDif = '(?<!\\providecommand\{)\\(DIFaddbegin|DIFaddend|DIFdelbegin|DIFdelend|DIFmodbegin|DIFmodend|DIFaddbeginFL|DIFaddendFL|DIFdelbeginFL|DIFdelendFL)\b'
$diffFileContent = $diffFileContent -replace $reDif, ''


# Perform write
$diffFileContent | Set-Content -Path "${fileDiff}.tex" -Encoding utf8


#********************************************************************************
# AUTOMATED - generate nocite
#****************************************
$bibItems = @(@"
% AUTO-GENERATED FILE
% This file contains the \bibitem{} or \entry{} content from the .bbl file from compiling ${fileNew}.tex
% The order of the keys therefore matches the citation numbers
"@)
$reBib = '^\s*\\(bibitem|entry)\{(?<bibItem>.+?)\}'
foreach  ($line in Get-Content -Path "${fileNew}.bbl") {
	if ($line -cmatch $reBib) {
		$bibItems += '\nocite{'+$Matches.bibItem+'}'
	}
}

$bibItems | Out-File -LiteralPath "${fileNew}.nocite" -Encoding utf8


#********************************************************************************
# AUTOMATED - Build and clean up
#****************************************
# Build pdf
#latexmk -interaction=nonstopmode -pdf "${fileDiff}.tex"

# Clean up
#Remove-Item -LiteralPath "${fileDiff}.tex"

# Open pdf with chrome
#Start-Process chrome -ArgumentList (Get-ChildItem "${fileDiff}.pdf").FullName

Pop-Location

