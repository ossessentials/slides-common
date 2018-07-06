% 8 December 2012
% Lian Tze LIM (liantze@gmail.com)
%
% LFcover.cls
% Book cover class for the Linux Foundation's training manuals
%
% Extensively modify by Jerry Cooperstein 5/2013 for Developer classes
% Modified again in 1/2014 to just do separate front and back covers
% rewritten extensive in 2015 to unify book and slide covers
\ProvidesClass{LFcover}
\LoadClass[17pt]{extarticle}
\RequirePackage{tikz}
\usetikzlibrary{calc}
\RequirePackage{graphicx}
\RequirePackage[latin1]{inputenc}
\RequirePackage[T1]{fontenc}
\RequirePackage{helvet}
\renewcommand{\familydefault}{\sfdefault}
\setlength{\parskip}{1ex}

\definecolor{LFOrange}{HTML}{F57925}
\definecolor{LFDeepBlue}{HTML}{2C7AC8}
\definecolor{LFLightBlue}{HTML}{76AFE3}

\def\@myversion{0}
\newcommand{\myversion}[1]{\def\@myversion{#1}}
\newcommand{\subtitle}[1]{\def\@subtitle{#1}}

\RequirePackage{calc}

\AtBeginDocument{
   \newlength\singlewidth
   \setlength{\singlewidth}{8.5in}
   %% Note coverheight=11.0 for books, 6.375 for slides
   \RequirePackage[paperheight=\coverheight,paperwidth=\singlewidth]{geometry}
   \newcommand{\makefront}{%
      \begin{tikzpicture}[remember picture,overlay]

         % Top/bottom strips
         \fill[LFDeepBlue]
         (current page.north west) rectangle
         ([yshift=-.45in]current page.north east);
         \fill[LFLightBlue]
         ([yshift=-.45in]current page.north west) rectangle
         ([yshift=-.72in]current page.north east);
         \fill[LFOrange]
         (current page.south west) rectangle ([yshift=.45in]current page.south east);

         % Front cover
         \node[text width=\singlewidth-1.3in,align=flush left,anchor=north east] at
         ([xshift=-.75in,yshift=-1.2in] current page.north east)
         {{\color{LFLightBlue}\huge\@subtitle\par}\medskip
            {\color{LFDeepBlue}\fontsize{54pt}{56pt}\fontseries{bc}\selectfont\@title\par}
            \medskip\hfill{\color{LFLightBlue}\LARGE Version \@myversion\par}
         };
         \node[anchor=south east] at
         ([xshift=-.75in,yshift=1.5in] current page.south east)
         {\includegraphics[height=.75in]{linuxfoundation-cropped}};

      \end{tikzpicture}
   }
   \newcommand{\makeback}{%
      \begin{tikzpicture}[remember picture,overlay]

         % Top/bottom strips
         \fill[LFDeepBlue]
         (current page.north west) rectangle
         ([yshift=-.45in]current page.north east);
         \fill[LFLightBlue]
         ([yshift=-.45in]current page.north west) rectangle
         ([yshift=-.72in]current page.north east);
         \fill[LFOrange]
         (current page.south west) rectangle
         ([yshift=.45in]current page.south east);

         % Back cover
         \node[font=\fontsize{19pt}{21pt}\selectfont\color{gray},text
         width=\singlewidth-1.3in, align=flush left, anchor=north west] at
         ([xshift=.75in,yshift=-1.2in]current page.north west)
         {
            \textbf{\color{LFDeepBlue}Train with
               the Linux Experts}\par\medskip The
            Linux Foundation has a mandate to
            train the next generation of Linux
            developers, architects and system
            administrators. We have done this by
            creating the most comprehensive and
            advanced Linux training program, and
            we have made it customizable to suit
            your needs.\par\medskip If your use of
            Linux is crucial to your business,
            count on The Linux Foundation to
            ensure your developers or IT staff
            will get the most out of Linux. We
            have helped hundreds of companies
            either move to Linux or gain advanced
            knowledge of the technology to give
            their development or operations teams
            a competitive advantage.\par\medskip
            To learn more, or to enroll in an
            upcoming Linux training course visit
            \textbf{\color{LFDeepBlue}training.linuxfoundation.org}.\par
         };

         \node[anchor=south west] at ([xshift=.75in,yshift=1.5in] current
         page.south west) {\includegraphics[height=.75in]{linuxfoundation-cropped}};

      \end{tikzpicture}
   }

}
\pagestyle{empty}
