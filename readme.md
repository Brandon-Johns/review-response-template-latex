# Reviewer Response Latex Template
For authors of scientific articles to respond to reviewer comments.

Example output
- Tracked changes: [pdf](./main_diff.pdf)
- Response letter: [pdf](./response1.pdf)


## About
The reviewer response letter is not a standalone document. It partners with the
- old version of the manuscript
- new version of the manuscript
- tracked changes document

Consider if a reviewer asks you to change a paragraph.
- It is a good idea to quote changes that you have made in the response letter.
- But if the paragraph references the label of a section, table, equation, then it will fail to compile.
- This template uses cross-document referencing to automatically match the numbering to that of the main file.
- And that's not all...

Benefits
- Consistent numbering of citations between documents
    - old file: old numbers
    - new file: new numbers
    - tracked changes file: new numbers, except deleted citations are in the old numbers
    - response letter:      new numbers, except deleted citations are in the old numbers
- Automatically match section/table/equation numbering to that of the main file.
- Automatically generate tracked changes markup with latexdiff.

Limitations
- Must follow the strictly defined workflow.


## Instructions
Prerequisites
- Install latex and latexdiff on your computer.
- Non-windows users will need to install the cross-platform [PowerShell Core](https://github.com/PowerShell/PowerShell).

Setup
1. Start from the version of your article that was submitted for review
2. Name the main latex file `main.tex`
3. Copy the folder `RevisionScripts\` into the same folder as `main.tex`
4. Compile `main.tex`
5. Run `RevisionScripts\GenerateFlattened.ps1`
    - This will save the old version of the article in a new folder named `Revisions\`

Generate tracked changes file
1. Edit your article as required to address all reviewer comments
2. Compile `main.tex`
3. Run `RevisionScripts\GenerateDiff.ps1`
4. Compile `main_diff.tex`

Create response letter
1. Write your response letter in `response1.tex`
    - Quotes of the text with tracked-changes markup can be copied from the generated `main_diff.tex` into the response
2. Compile `response1.tex`

Output
- `main_diff.pdf` is the tracked changes document.
- `response1.pdf` is the review response letter.

Notes
* If you make more changes, you can regenerate the tracked changes file. Be sure to recompile `main.tex` first.
* For 2nd round of revision, rerun `RevisionScripts\GenerateFlattened.ps1` to reset file that you compare against.

Troubleshooting
* latexdiff is not perfect. It defaults to skipping markup in environments and commands that it does not know. You can register more commands in `RevisionScripts\GenerateDiff.ps1`, using the `$DiffOptions` variable. This will require some trial and error.


## License
The response letter class and template are based off [the work of Martin Schrön](https://github.com/mschroen/review_response_letter/blob/master/templates/preamble.tex), and are distributed under the [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.en.html).

The rest is distributed under the [BSD-3-Clause License](https://opensource.org/license/bsd-3-clause/). Copyright (c) 2023 Brandon Johns.


## Source Code
This project is hosted at https://github.com/Brandon-Johns/review-response-template-latex

