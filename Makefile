.EXPORT_ALL_VARIABLES:

SHELL=/bin/bash

#COURSE=$(shell basename $(PWD))
# only define $COURSE if Undefined
COURSE ?= $(shell basename $(PWD))

INPUT=$(COURSE).tex
SLIDES=$(COURSE)-SLIDES

COMMON=./common
export TEXMFHOME=$(COMMON)/texmf

SRC_TEXFILES= $(wildcard CHAPS/*/*.*) $(INPUT)

PDFS = $(shell ls *.pdf | sed -e s/.pdf//g )
HTMLS = $(shell ls *.html | sed -e s/.html//g )


VERSION=$(shell grep '\\newcommand{\\version}' $(INPUT) \
    | sed -e s/'\\newcommand{\\version}{'//g \
    | sed -e s/'}'//g)

COURSETITLE=$(shell grep '\\newcommand{\\coursetitle}' $(INPUT) \
    | sed -e s/'\\newcommand{\\coursetitle}{'//g \
    | sed -e s/'}'//g)

FRONTCOVER = $(COURSE)-COVER-FRONT
BACKCOVER = $(COURSE)-COVER-BACK
SLIDECOVER = $(COURSE)-COVER-SLIDE

.PHONY: $(COURSE) slides SLIDES release RELEASE \
	clean veryclean help COVERS covers \
	findoverfull FINDOVERFULL 

ifneq "$(DRYRUN)" ""
ROPTS += --dry-run
endif

FAKEROOT:= $(shell which fakeroot >/dev/null && echo fakeroot || true)
TAR	= $(FAKEROOT) tar
RSYNC	= rsync -crlptvHxP --inplace --exclude old $(ROPTS)

################################

class:	$(COURSE).pdf

$(COURSE).pdf: $(SRC_TEXFILES) $(FRONTCOVER).pdf
	pdflatex $(COURSE) 
	makeindex $(COURSE)
	pdflatex $(COURSE) > /dev/null  
	makeindex $(COURSE) > /dev/null
	makeindex $(COURSE) > /dev/null
	pdflatex $(COURSE) > /dev/null  

slides SLIDES: $(SLIDES).pdf
$(SLIDES).pdf:  $(SRC_TEXFILES) $(SLIDECOVER).pdf
	echo "\def\slideoutput{1} \input{$(COURSE)}" | pdflatex -jobname $(SLIDES)	
	makeindex $(SLIDES)
	echo "\def\slideoutput{1} \input{$(COURSE)}" | pdflatex -jobname $(SLIDES)	
	makeindex $(SLIDES) > /dev/null
	makeindex $(SLIDES) > /dev/null
	echo "\def\slideoutput{1} \input{$(COURSE)}" | pdflatex -jobname $(SLIDES)


RELEASE_DIR=./RELEASE
#PDFS = $(subst .pdf,,$(wildcard *.pdf))

RELEASE release: all 
	echo Making Release VERSION = $(VERSION)
	@if [ ! -d $(RELEASE_DIR) ] ; then mkdir $(RELEASE_DIR) ; fi

	@for names in $(PDFS) ; do \
	cp "$$names".pdf $(RELEASE_DIR)/"$$names"_V_"$(VERSION)".pdf ; \
	done

	@for names in $(HTMLS) ; do \
	cp "$$names".html $(RELEASE_DIR)/"$$names"_V_"$(VERSION)".html ; \
	done

	ls -l $(RELEASE_DIR)

outline: class
	@$(COMMON)/get_long_html_outline.sh $(COURSE)
	@$(COMMON)/get_short_html_outline.sh $(COURSE)

#################################


#################################

COVERS covers: $(FRONTCOVER).pdf $(BACKCOVER).pdf $(SLIDECOVER).pdf
# FRONT COVER
#$(FRONTCOVER).pdf: $(INPUT)
# remove $(INPUT) target as it malfunctions on RHEL6
$(FRONTCOVER).pdf:
	echo \\newcommand{\\coverheight}{11.0in} > $(FRONTCOVER).tex  
	echo \\documentclass{CALEcover} >> $(FRONTCOVER).tex  
	echo \\title{$(COURSETITLE)}\\subtitle{$(COURSE)}\\myversion{$(VERSION)} >> $(FRONTCOVER).tex  
	echo \\begin{document}\\makefront\\end{document} >> $(FRONTCOVER).tex  
	pdflatex $(FRONTCOVER) && pdflatex $(FRONTCOVER) && pdflatex $(FRONTCOVER) 
	rm $(FRONTCOVER).tex
# BACK COVER
$(BACKCOVER).pdf:
	echo \\newcommand{\\coverheight}{11.0in} > $(BACKCOVER).tex  
	echo \\documentclass{CALEcover} >> $(BACKCOVER).tex  
	echo \\title{$(COURSETITLE)}\\subtitle{$(COURSE)}\\myversion{$(VERSION)} >> $(BACKCOVER).tex  
	echo \\begin{document}\\makeback\\end{document} >> $(BACKCOVER).tex  
	pdflatex $(BACKCOVER) && pdflatex $(BACKCOVER) && pdflatex $(BACKCOVER) 
	rm $(BACKCOVER).tex
# SLIDE FRONT COVER
#$(SLIDECOVER).pdf: $(INPUT)
# remove $(INPUT) target as it malfunctions on RHEL6
$(SLIDECOVER).pdf:
	echo \\newcommand{\\coverheight}{6.375in} > $(SLIDECOVER).tex  
	echo \\documentclass{CALEcover} >> $(SLIDECOVER).tex  
	echo \\title{$(COURSETITLE)}\\subtitle{$(COURSE)}\\myversion{$(VERSION)} >> $(SLIDECOVER).tex  
	echo \\begin{document}\\makefront\\end{document} >> $(SLIDECOVER).tex  
	pdflatex $(SLIDECOVER) && pdflatex $(SLIDECOVER) && pdflatex $(SLIDECOVER) 
	rm $(SLIDECOVER).tex

help HELP usage:
	@echo "make TARGETS: "
	@echo "none or class:  Produces $(COURSE).pdf (full-size, color)"
	@echo "slides/SLIDES:  Produces $(COURSE)-SLIDES.pdf (slide-size, color)"
	@echo "outline:        Produces $(COURSE)_{short,long}_outline.tml (do make first)"
	@echo "COVERS          Produces full, front and slides covers"
	@echo "RELEASE/release Populate RELEASE directory with all PDFS with version numbers embedded"
	@echo 'spellcheck      Check spelling'
	@echo 'spellcheck-list-files  List files that would be spell-checked'
	@echo 'FINDOVERFULL    Find vertical and horizonal overruns'
	@echo 'make clean      get rid of all products but .pdf files'
	@echo 'make veryclean  get rid of all products including .pdf files'
	@echo "help HELP or usage: Produces this message"

all: class slides outline COVERS

# You can add options for spellcheck.sh here or in $(COURSE)/.spellcheckrc
#SPELLOPTS="-e inc"

spellcheck:
	$(COMMON)/spellcheck.sh $(SPELLOPTS) $(COURSE).tex
spellcheck-list-files:
	$(COMMON)/spellcheck.sh -l $(SPELLOPTS) $(COURSE).tex

# check for horizontal and vertical overruns:

FINDOVERFULL findoverfull: $(COURSE).pdf 
	@echo FINDING VERTICAL OVERRUNS .........	
	@if grep -H -A3 -B5 'Overfull \\vbox ([0-9][0-9]' $(COURSE).log ; then echo "">/dev/null ; fi
	@echo FINDING HORIZONTAL  OVERRUNS .........
	@if grep --color -H -A3 -B5 'Overfull \\hbox ([0-9][0-9].*[0-9]' $(COURSE).log ; then echo "">/dev/null ; fi

#################################
clean:
	rm -rf *~ *log *aux *dvi *.out *.lof *.mtc* *.bmt *.lot *.maf *.cpt \
	*.ind *.ilg *.idx $(COURSE)_*  "*outline*" *COVER*.tex 

veryclean: clean
	rm -rf $(COURSE).pdf $(COURSE)-SLIDES.pdf $(COURSE)-*COVER*.pdf \
	*.toc *.html RELEASE 

