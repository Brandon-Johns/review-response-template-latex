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
Generates a single tex file with all \input{} commands resolved
Generates a bibkeys file which holds the bibliography keys in the order that they were cited

Intent
	The output of running this can be used with latexdiff e.g.
		```
		latexdiff main_flat.tex main.tex > main_diff.tex
		```
		where main_flat.tex is the output of running this script on the version that was submitted for review
		and main.tex is the revised version

	But instead of running latexdiff yourself, this script is intended to pair with GenerateDiff.ps1
		which provides extra functionality on top of the output of latexdiff
		Thus is the intended use of the bibkeys file
		(Note that the .bibkeys extension is my own creation. It not meaningful)


********************************************************************************
Instructions
****************************************
1) Compile main.tex
2) Run this script with powershell

Non-windows users can use the cross-platform 'PowerShell Core'
https://github.com/PowerShell/PowerShell


#>
#********************************************************************************
# CONFIG
#****************************************
# Main file
$fileMain = 'main'

# Filename for output
$fileFlat = 'Revisions\main_flat'


#********************************************************************************
# AUTOMATED
#****************************************
Push-Location $PSScriptRoot\..
If(-not (Test-Path "${fileMain}.tex")) { throw "Can't find main file" }
If(-not (Test-Path "${fileMain}.bbl")) { throw "Can't find bbl file. Compile ${fileMain}.tex, then try again" }


$fileFlat_ParentDir = Split-Path -Path "${fileFlat}.tex" -Parent
If(-not (Test-Path $fileFlat_ParentDir)) { New-Item -Path $fileFlat_ParentDir -ItemType Directory }


#********************************************************************************
# AUTOMATED - Generate flat
#****************************************
$contentFlat = Get-Content -Path "${fileMain}.tex" -Raw

# Recursively evaluate \input{}
# 1) Search main file for a '\input{}'
#       Skip if line is commented out
#       Remove file extension from match (to add back in after)
# 2) Replace command with file content
$reInput = '\n([^%]|\\%)*(?<inputCommand>\\input\{(?<inputPath>.+?)(.tex)?\})'
while($contentFlat -cmatch $reInput) {
	# Add file extension
	$inputPath = $Matches.inputPath + '.tex'

	# Get content from path specified in the input command
	If(-not (Test-Path $inputPath)) { throw "Can't find file referenced by input: ${inputPath}" }
	$contentInput = Get-Content -Path $inputPath -Raw

	# Replace the input command with the content
	$contentFlat = $contentFlat.Replace($Matches.inputCommand, $contentInput)
}

# Perform write
$contentFlat | Set-Content -Path "${fileFlat}.tex" -Encoding utf8


#********************************************************************************
# AUTOMATED - generate bibkeys
#****************************************
$bibItems = @(@"
% AUTO-GENERATED FILE
% This file contains the \bibitem{} or \entry{} content from the .bbl file from compiling ${fileMain}.tex
% The order of the keys therefore matches the citation numbers
"@)
$reBib = '^\s*\\(bibitem|entry)\{(?<bibItem>.+?)\}'
foreach  ($line in Get-Content -Path "${fileMain}.bbl") {
	if ($line -cmatch $reBib) {
		$bibItems += $Matches.bibItem
	}
}

$bibItems | Out-File -LiteralPath "${fileFlat}.bibkeys" -Encoding utf8


#********************************************************************************
# AUTOMATED - copy bbl
#****************************************
#Copy-Item -LiteralPath "${fileMain}.bbl" -Destination "${fileFlat}.bbl"


Pop-Location

