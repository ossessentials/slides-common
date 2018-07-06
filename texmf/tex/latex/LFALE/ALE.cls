\ProvidesClass{ALE}
\LoadClass{book}

\newcommand{\dimensionsclass}{
  \usepackage[paperwidth=8.5in, paperheight=11.0in,
  tmargin=0.75in, bmargin=0.625in,
  outer=0.5in, inner=0.75in] {geometry}
}
\newcommand{\dimensionsslides}{
  \usepackage[paperwidth=8.5in, paperheight=6.375in,
  tmargin=0.50in, bmargin=0.500in,
outer=0.5in, inner=0.75in] {geometry}
%% keep outer inner the same as book to keep linebreaks consistent
%%  outer=0.5in, inner=0.500in] {geometry}
}

%%This magic is supposed to center all floats (figures, tables, etc.)
\makeatletter
\g@addto@macro\@floatboxreset\centering
\makeatother

\newcommand{\lflogo}{
  \begin{flushright}
    \includegraphics[scale=0.8]{linuxfoundation-cropped.png}
  \end{flushright}
}
%%%%%%%%%% Change the date format to 08/12/2014
%%% seems to be needed for the clearpage macros for a mysterious reason :)
\usepackage{datetime}
%%\renewcommand{\dateseparator}{\_}
\mmddyyyydate

\newcommand{\checkclearpage}[1]
{
  \ifthenelse{\equal{#1}{\course}}{\clearpage}{}
}

\newcommand{\clearthepage}[1]{\checkclearpage{#1}}

%% slides or book dimensions

\ifdefined\slideoutput
%%slides
  \dimensionsslides
  \renewcommand{\checkclearpage}[1]
  {\ifthenelse{\equal{#1}{FUCKSHIT}}{\clearpage}{}}
  \newcommand{\clearpageslides}{\clearpage}
  \let\oldfigbegin\figure
  \let\oldfigend\endfigure
  \renewenvironment{figure}{\oldfigbegin}{\oldfigend\clearpage}
  \newcommand{\coverfigure}{\course-COVER-SLIDE.pdf}
\else
%%book
  \dimensionsclass
  \newcommand{\clearpageslides}{}
  \newcommand{\coverfigure}{\course-COVER-FRONT.pdf}
\fi

\RequirePackage[user,abspage]{zref}

\usepackage{layout}
\usepackage{graphics}
\usepackage[pdftex]{color,graphicx}
\usepackage[usenames,dvipsnames]{xcolor}
\usepackage{verbatim}
\usepackage[textfont=bf,tableposition=top,figureposition=top]{caption}
\usepackage{wrapfig}
\usepackage{xcolor}
\usepackage{longtable}
\usepackage{makeidx}
\usepackage{tabularx}
\usepackage{colortbl}
\usepackage{fancyvrb}
\usepackage{setspace}
\usepackage{supertabular}
\usepackage{import}
\usepackage{alltt}
\usepackage{multicol}
\usepackage{cprotect}
\usepackage{smartdiagram}
\usepackage{titling}
%%\usepackage[utf8x]{inputenc}
%%\usepackage[T1]{fontenc}

%% Change alltt to be smaller font and blue text color
\let\oldallttbegin\alltt
\let\oldallttend\endalltt
\renewenvironment{alltt}{\oldallttbegin\small\color{blue}}{\oldallttend}

%%%%%%% avoid subsection numbers of 10 fucking things up
\usepackage[titles]{tocloft}
\setlength{\cftsecnumwidth}{3em}
\setlength{\cftfignumwidth}{3em}
\setlength{\cfttabnumwidth}{3em}

\usepackage{minitoc}
\nomtcrule

\usepackage{appendix}

\parindent 0pt
\parskip 7.2pt
\raggedbottom

\captionsetup[table]{position=top}
\captionsetup[figure]{position=top}

%% Various raw environments of different size

\DefineVerbatimEnvironment%
{raw}{Verbatim}
{fontsize=\small\color{blue}}

\DefineVerbatimEnvironment%
{rawsmall}{Verbatim}
{fontsize=\small\color{blue}}

\DefineVerbatimEnvironment%
{rawhuge}{Verbatim}
{fontsize=\huge\color{blue}}

\DefineVerbatimEnvironment%
{rawfootnotesize}{Verbatim}
{fontsize=\footnotesize\color{blue}}

\DefineVerbatimEnvironment%
{rawscriptsize}{Verbatim}
{fontsize=\scriptsize\color{blue}}

\RecustomVerbatimCommand{\VerbatimInput}{VerbatimInput}%
{fontsize=\small}

\newcommand{\rawfile}[1]
  {\begingroup\small\color{blue} {\verbatiminput{#1}}\endgroup}
\newcommand{\rawfilesmall}[1]
  {\begingroup\small\color{blue}{\verbatiminput{#1}}\endgroup}
\newcommand{\rawfiletiny}[1]
  {\begingroup\tiny\color{blue}{\verbatiminput{#1}}\endgroup}
\newcommand{\rawfilescriptsize}[1]
  {\begingroup\scriptsize\color{blue}{\verbatiminput{#1}}\endgroup}
\newcommand{\rawfilefootnotesize}[1]
  {\begingroup\footnotesize\color{blue}{\verbatiminput{#1}}\endgroup}

%%to produce shaded background boxes

\usepackage{framed,color}

%% 0.95 for rather light gray
\definecolor{lgray}{gray}{0.95}

%% increase the box border width, affects all boxes
\setlength{\fboxrule}{1.5pt}

%%to produce shaded background boxes

\newenvironment{lfbox}[1][black]
{\def\FrameCommand{\fboxsep=\FrameSep\fcolorbox{#1}{lgray}}%
  \MakeFramed {\advance\hsize-2.5\leftmargin \FrameRestore}}
{\endMakeFramed}

\newcommand{\lfcopyright}{
\textcopyright\  Copyright the Linux Foundation 2018.  All rights reserved.}

%%%%%%%%%%% header and footer crap
%%%%%%   This must come after the pagesize dimensions are set

\usepackage{fancyhdr}
\pagestyle{fancy}
\renewcommand{\footrulewidth}{0.6pt}
\fancyhf{}
\fancyhead[RE]{\textit{\leftmark}}
\fancyhead[LO]{\textit{\rightmark}}
\fancyhead[LE]{\thepage} 
\fancyhead[RO]{\thepage} 
\fancyfoot[C]{\textbf{\lfcopyright}}
\fancyfoot[R]{\includegraphics[scale=0.25]{linuxfoundation-cropped}
}
\fancyfoot[L]{\textbf{\course: V\_\version by \speaker}}

% this disables the boxes around links
\usepackage[breaklinks,pdftex, pdfborderstyle={/S/U/W 0} ]{hyperref}
%% set link colors, url=http links, file=localfiles, link=toc etc.
\hypersetup{colorlinks=true,urlcolor=RawSienna,filecolor=RawSienna,
linkcolor=Red}

%%\newcommand{\filelink}[1]{\href{run:///#1}{\texttt{#1}}}
\newcommand{\filelink}[1]{\href{run:///#1}{\texttt{\nolinkurl{#1}}}}
%%\newcommand{\kernlink}[1]{\href{run:////usr/src/linux/#1}{\texttt{#1}}}

%% just to refer to a file that you won't click on
\newcommand{\file}[1]{\url{#1}}

\newcommand{\topshit}{
  \frontmatter
  \begin{titlepage}
    \begin{center}
      \includegraphics[scale=0.76]{\coverfigure}
    \end{center}
    \textbf{
      \course: Version \version
    }
    \par
    \textbf{\lfcopyright}

    \pagebreak
    \input{longcopyright}

%%    \lfcopyrighttext
  \end{titlepage}
  \tablestuff
  \mainmatter
}

\newcommand{\tablestuff}
{
  \setcounter{tocdepth}{1}
  \dominitoc[n]
  \begin{spacing}{0.0}
    \tableofcontents
  \end{spacing}
}

\makeindex


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% For conversion of LFS documents to LFD format
\usepackage[scaled]{helvet}
\usepackage{float}
\renewcommand{\familydefault}{\sfdefault}


\newcounter{labno}
%%\newcommand{\fulllabno}{\large\thechapter.\arabic{labno}}
\newcommand{\fulllabno}{\Large\thechapter.\thelabno}

\newenvironment{Lab}{
  \setcounter{labno}{0}
}{}

\newtoggle{split}
\togglefalse{split}
\DeclareOption{splitlabs}{\toggletrue{split}}

\ProcessOptions
\ExecuteOptions{splitlabs}

%% separate lab page number stuff
\iftoggle{split}{
  \newwrite\myfile
  \immediate\openout\myfile=labcontents.data
}{}

\iftoggle{split}
{
  \newenvironment{exe}[1]{
    \clearpage
\setcounter{page}{1}
    \stepcounter{labno}
    {
      \lflogo
      \Large{\textbf{Exercise \fulllabno :  #1}}}    
%% Cannot use \large in immeidat\write so use full macro def
%    \immediate\write\myfile{\fulllabno\space\theabspage}
      \immediate\write\myfile{\thechapter.\thelabno\space\theabspage}
  }{
    \immediate\write\myfile{\theabspage}
  }
}{
  \newenvironment{exe}[1]{
    \stepcounter{labno}
    {\Large{\textbf{Exercise \fulllabno :  #1}}}
  } {}
}
\newenvironment{sol}{
  {\Large{\textbf{Solution \fulllabno} } } }
{}

\ifdefined\slideoutput
\newcommand{\note}[1]{ }
\else
\newcommand{\note}[1]{
\begin{minipage}[t]{\textwidth}
     {\parskip4pt
        {#1}
     }
   \end{minipage}
   \vfill


}
\fi
\newsavebox{\coopslidebox}
\renewenvironment{frame}[1]{
   \begin{lrbox}{\coopslidebox}
\begin{minipage}[c][4.7in][t]{6.9in}
         \begin{Large}
            \colorbox{NavyBlue}{
               \parbox[c][8ex][c]{\dimexpr\linewidth-3\fboxsep}{
                  \textcolor{white}{
                     \hspace{10pt}
                     \begin{center}
                        \begin{Huge}
%% \includegraphics[scale=0.25]{linuxfoundation-cropped}
                           \textbf{#1}
                        \end{Huge}
                     \end{center}
                  }
               } 
            }
            \parindent0pt
            \vfill
\RecustomVerbatimEnvironment
{raw}{Verbatim}
{fontsize=\large\color{blue}}
            \begin{quote}
            }{ 
            \end{quote}
         \end{Large}
         \vfill
         \hfill
      \end{minipage}
   \end{lrbox}
   \fboxsep3mm
   \fcolorbox{black}{white}
   {\usebox{\coopslidebox}
   }
}

\newif\ifEMBEDDED
\EMBEDDEDfalse
