#!/bin/bash

COURSE=$1
INPUT="$COURSE".tex
TOC="$COURSE".toc
OUTLINE="$COURSE"-long-outline.html

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

head -n $lastline $TOC | \
    sed \
    -e s/'\\contentsline'//g \
    -e s/'{\\numberline '//g \
    -e s/'{chapter}'/'<\/UL><LI>'/g \
    -e s/'{chapter.*}'/'<UL>'/g \
    -e s/'\\_'/_/g \
    | sed \
    -e s/}{[0-9]}/'<\/LI>'/g \
    -e s/}{[0-9][0-9]}/'<\/LI>'/g  \
    -e s/}{[0-9][0-9][0-9]}/'<\/LI>'/g  \
    -e s/{section}/'<LI>'/g \
    | sed -e s/'\\textbf {'/'<B>'/g \
    -e s/'\\texttt {'/'<B>'/g \
    | sed \
    -e s/{[0-9].[0-9]}//g  \
    -e s/{[0-9][0-9].[0-9]}//g  \
    -e s/{[0-9].[0-9][0-9]}//g  \
    -e s/{[0-9][0-9].[0-9][0-9]}//g  \
    -e s/{section.*}//g  \
    -e s/{..}//g \
    -e s/{.}//g \
    | sed \
    -e s/'}'/'<\/B>'/g  \
    | sed \
    -e s/{....}//g \
    | sed \
    -e 0,/'<\/UL>'/s/'<\/UL>'//  \
    | grep -vi ppendi \
    | grep -v 'select@language'  \
    >> $OUTLINE


cat <<EOF >> $OUTLINE
</UL></OL>
</BODY>
</HTML>
EOF
echo I made: "$OUTLINE"
