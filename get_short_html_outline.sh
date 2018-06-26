#!/bin/bash

COURSE=$1
INPUT="$COURSE".tex
TOC="$COURSE".toc
OUTLINE="$COURSE"-short-outline.html

COURSE=$COURSE 
VERSION=$(grep '\\newcommand{\\version}' $INPUT \
    | sed -e s/'\\newcommand{\\version}{'//g | sed -e s/'}'//g) \

TITLE="$(grep 'coursetitle' $INPUT \
	| sed -e s/'\\newcommand{\\coursetitle}{'//g | sed -e s/'}'//g)" \

cat <<EOF > $OUTLINE
<HTML>
<HEAD>
<TITLE>
$COURSE $TITLE
</TITLE>
</HEAD>
<BODY>
<H1>$COURSE $TITLE</H1>
<OL>
EOF

appendixstart="$(grep -n Appendices $TOC)"
appendixstart="$(echo $appendixstart | sed 's/:.*//')"
lastline=$(($appendixstart-1))

head -n $lastline $TOC |  \
    grep -v '\{section}'   |  \
    grep -v 'select@language' | \
    sed \
    -e s/'\\contentsline'//g \
    -e s/'{\\numberline '//g \
    -e s/'{chapter}'/'<LI>'/g \
    -e s/'{chapter.*}'//g  \
    -e s/'\\_'/_/g \
    | sed \
    -e s/}{[0-9]}/'<\/LI>'/g \
    -e s/}{[0-9][0-9]}/'<\/LI>'/g  \
    -e s/}{[0-9][0-9][0-9]}/'<\/LI>'/g  \
    | sed -e s/'\\textbf {'/'<B>'/g \
    -e s/'\\texttt {'/'<B>'/g \
    | sed \
    -e s/{[0-9].[0-9]}//g  \
    -e s/{[0-9][0-9].[0-9]}//g  \
    -e s/{[0-9].[0-9][0-9]}//g  \
    -e s/{[0-9][0-9].[0-9][0-9]}//g  \
    -e s/{..}//g \
    -e s/{.}//g \
    | sed \
    -e s/'}'/'<\/B>'/g  \
    | sed \
    -e s/{....}//g \
    >> $OUTLINE

cat <<EOF >> $OUTLINE
</OL>
</BODY>
</HTML>
EOF
echo I made: "$OUTLINE"

