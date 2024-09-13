%%###############################################################################
%% Brandon Johns in 2023
%% This version is not directly compatible with the previous versions. The whole set of files go together
%%
%% Based off: https://github.com/mschroen/review_response_letter/blob/master/templates/preamble.tex
%% By: Martin Schrön
%% License: GNU General Public License v3.0
%%
%% Key changes
%%   Made into a class
%%   Restyled
%%   Removed command AR for author response. Now, just use bare paragraphs
%%   Added commands RCC, RCBlock, and RCEnv for reviewer comments
%%   Added headings on quote boxes
%%   Added support to cross referencing, using \ref{} on labels defined in the original document
%%   Added support for keeping same citation numbers
%%
%%###############################################################################
\NeedsTeXFormat{LaTeX2e}[1996/12/01]
\ProvidesClass{AuthorResponse}[2023/11/20 v2.0 LaTeX document class]
\LoadClass[12pt]{article}

%% Typography
\usepackage[T1]{fontenc}
\usepackage{times}
\usepackage{microtype}
\usepackage[utf8]{inputenc}

%% Misc
\usepackage{graphicx}
\usepackage[hidelinks]{hyperref}

\usepackage{datetime} %% Print the current date in different formats
\yyyymmdddate
\renewcommand{\dateseparator}{-}

\usepackage{xcolor}
\definecolor{arBlue}{HTML}{2F5496}
\definecolor{arPurple}{HTML}{7030A0}
\definecolor{arDarkGrey}{RGB}{25,25,25}


%%###############################################################################
%% Cross referencing from original document
%%#######################################
%% Section adapted from
%% https://www.overleaf.com/learn/how-to/Cross_referencing_with_the_xr_package_in_Overleaf
%% by cyberSingularity at http://tex.stackexchange.com/a/69832/226

\usepackage{xr}
\newcommand*{\arAddFileDependency}[1]{%% argument=file name and extension
\typeout{(#1)}%% latexmk will find this if recorder=0
%% however, in that case, it will ignore #1 if it is a .aux or 
%% .pdf file etc and it exists! If it doesn't exist, it will appear 
%% in the list of dependents regardless)
%%
%% Write the following if you want it to appear in \listfiles 
%% --- although not really necessary and latexmk doesn't use this
%%
\@addtofilelist{#1}
%%
%% latexmk will find this message if #1 doesn't exist (yet)
\IfFileExists{#1}{}{\typeout{No file #1.}}
}

\newcommand*{\arImportReferences}[1]{%
\externaldocument{#1}%
\arAddFileDependency{#1.tex}%
\arAddFileDependency{#1.aux}%
}


%%###############################################################################
%% Page dimensions, margins, line spacing, header, footer, headings
%%#######################################
\usepackage[
	a4paper,
	margin=20mm,
	ignorehead,
	includefoot, %% Contain within header and footer within the margins
	footskip=15pt,
	headheight=15pt, %% Unused, but fancyhdr gives warnings without this
]{geometry}

%% Paragraph styles
\setlength{\parskip}{0.8\baselineskip}
\setlength{\parindent}{0pt}

%% Section title styles
%% SYNTAX: \titleformat{command} [shape] {format} {label text} {label to title hSep} {code before} [code after]
%% SYNTAX: \titlespacing{command} {left} {before} {after} [right]
\usepackage[nobottomtitles]{titlesec}
\titleformat{\section}{\normalfont\LARGE\color{arPurple}\bfseries}{}{0em}{}
\renewcommand{\bottomtitlespace}{8\baselineskip} %% Minimum distance between a section heading and the bottom of a page

%% Header and footer formatting
%% The titlesec and fancyhdr work together
\usepackage{fancyhdr}
\fancyhfinit{\color{arDarkGrey}} %% Change colour of header & footer
\fancypagestyle{arPageStyle}[fancydefault]{%%
	\fancyhf{}%% Clear header and footer
	\let\headrule\null\relax%%
	\let\footrule\null\relax%%
	\fancyfoot[R]{\footnotesize \thepage}%%
}

\fancypagestyle{arPageStyleFirst}[arPageStyle]{%
	\fancyfoot[L]{\footnotesize \today}%%
}

%%###############################################################################
%% Quote style
%% \begin{quote}[quote heading]    text    \end{quote}
%%#######################################
\usepackage{framed}
\let\oldquote=\quote
\let\endoldquote=\endquote
\renewenvironment{quote}[1][]{\begin{arQuoteWrapper}[#1]\advance\leftmargini -2.4em\begin{oldquote}}{\end{oldquote}\end{arQuoteWrapper}}

%% Quote environment to wrap the default quote environment
%% Not for user use. It is called aromatically from the overridden quote environment
%% SYNTAX: \newenvironment{env name} [number of args] [optional arg default] {code before} {code after}
\newenvironment{arQuoteWrapper}[1][\@nil]{%%
	\def\FrameCommand{
		\fboxsep=0.6em %% Box to text padding
		\fcolorbox{black}{white}%%
	}%%
	\begin{minipage}{\linewidth}
	%% Quote heading
	\def\tmp{#1}%%
	\ifx\tmp\@nnil
	\else
		\hspace{0.6em}\textit{#1}\vspace{-1\baselineskip}
	\fi
	%% Quote framing
	%% The "2" can be changed to change the box size
	\MakeFramed {\advance\hsize-2\width \FrameRestore}
	\begin{minipage}{\linewidth}
}{
	\end{minipage}\endMakeFramed\end{minipage}\par
}

% Reviewer comment environment
\usepackage{mdframed}
\newmdenv[
	topline=false,
	bottomline=false,
	rightline=false,
	leftline=true,
	skipabove=3\baselineskip,
	skipbelow=0,
	innertopmargin=0pt,
	innerbottommargin=0pt,
	innerrightmargin=0pt,
	innerleftmargin=10pt,
	leftmargin=-14pt, %% = -(innerleftmargin+linewidth)
	linewidth=4pt,
	linecolor=arBlue,
	fontcolor=arBlue,
]{RCEnv}

\newmdenv[
	topline=false,
	bottomline=false,
	rightline=false,
	leftline=true,
	skipabove=0, %% Only difference from RCEnv
	skipbelow=0,
	innertopmargin=0pt,
	innerbottommargin=0pt,
	innerrightmargin=0pt,
	innerleftmargin=10pt,
	leftmargin=-14pt,
	linewidth=4pt,
	linecolor=arBlue,
	fontcolor=arBlue,
]{RCCEnv}


%%###############################################################################
%% Custom commands
%%#######################################
% SYNTAX: \arTitle[format commands]{title}
\newcommand{\arTitle}[2][\LARGE]{%%
	{\large\bf Author Response to Reviews of}\\[1em]%%
	{#1 {#2}}%%
}

\usepackage{fbox}
\newcommand{\arLegend}{%%
	\vspace{0.5em}
	\hrule
	\emph{Legend}\\
	\makebox[1.5cm]{\raisebox{4pt}{\fbox[L,boxrule=4pt,lcolor=arBlue]{\color{arBlue}text}\hspace*{4pt}}} Reviewer Comment\\
	\makebox[1.5cm]{text} Author Response\\
	\makebox[1.5cm]{\fbox{text}}  Manuscript text: Unchanged\\
	\makebox[1.5cm]{\fbox{\DIFdel{text}}}  Manuscript text: Removed\\
	\makebox[1.5cm]{\fbox{\DIFadd{text}}}  Manuscript text: Added
	\vspace{2em}
}

%% Reviewer comment
%% SYNTAX: \RC text up to end of paragraph
\long\def\RC#1\par{%%
	\begin{RCEnv}#1\end{RCEnv}\par%%
}
%% Reviewer comment continued (if 2 in a row with no author text in between)
%% SYNTAX: \RCC text up to end of paragraph
\long\def\RCC#1\par{%%
	{\begin{RCCEnv}\vspace{1\baselineskip}#1\end{RCCEnv}}\par%%
}

% Or use this command (with normal syntax) to enclose a block of text
\newcommand{\RCBlock}[1]{
	\begin{RCEnv}
		#1
	\end{RCEnv}
}


%%###############################################################################
%% Latex diff styles
%%#######################################
%% Based on the preamble added by latexdiff, but I changed the style a little
%%DIF PREAMBLE EXTENSION ADDED BY LATEXDIFF
\RequirePackage[normalem]{ulem}
\RequirePackage{color}
\definecolor{difRed}{RGB}{192,0,0}
\definecolor{difBlue}{RGB}{0,0,192}
\providecommand{\DIFadd}[1]{{\protect\color{difBlue}#1}}
\providecommand{\DIFdel}[1]{{\protect\color{difRed}\sout{#1}}}
\providecommand{\DIFaddbegin}{}
\providecommand{\DIFaddend}{}
\providecommand{\DIFdelbegin}{}
\providecommand{\DIFdelend}{}
\providecommand{\DIFmodbegin}{}
\providecommand{\DIFmodend}{}
\providecommand{\DIFaddFL}[1]{\DIFadd{#1}}
\providecommand{\DIFdelFL}[1]{\DIFdel{#1}}
\providecommand{\DIFaddbeginFL}{}
\providecommand{\DIFaddendFL}{}
\providecommand{\DIFdelbeginFL}{}
\providecommand{\DIFdelendFL}{}
\RequirePackage{listings}
\RequirePackage{color}
\lstdefinelanguage{DIFcode}{
  moredelim=[il][\color{difRed}\sout]{\%DIF\ <\ },
  moredelim=[il][\color{difBlue}]{\%DIF\ >\ }
}
\lstdefinestyle{DIFverbatimstyle}{
	language=DIFcode,
	basicstyle=\ttfamily,
	columns=fullflexible,
	keepspaces=true
}
\lstnewenvironment{DIFverbatim}{\lstset{style=DIFverbatimstyle}}{}
\lstnewenvironment{DIFverbatim*}{\lstset{style=DIFverbatimstyle,showspaces=true}}{}
%%DIF END PREAMBLE EXTENSION ADDED BY LATEXDIFF


%%###############################################################################
%% User commands: citations & bibliography
%%#######################################
\hyphenpenalty=10000 %% Prevent hyphenation (Part 1/2)
\exhyphenpenalty=10000 %% Prevent hyphenation (Part 2/2)
\doublehyphendemerits=10000 %% No consecutive line hyphens.
\brokenpenalty=10000 %% No broken words across columns/pages.
\widowpenalty=9999 %% Almost no widows at bottom of page.
\clubpenalty=9999 %% Almost no orphans at top of page.
\interfootnotelinepenalty=9999 %% Almost never break footnotes.

\emergencystretch 3em %% Having disabled hyphenation, drop long words to the next line instead of overflowing
\hfuzz=2.0em %% Suppress warnings for \hbox overflow ("overfull \hbox") by up to given length
\hbadness=4000 %% range=[0,10000] Suppress warnings for underfull \hbox up to given badness level


%%###############################################################################
%% EOF
%%#######################################
\endinput