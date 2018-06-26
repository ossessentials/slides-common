#!/bin/bash

[ "$LEN" == "" ] && LEN=110

for names in $*
do 
#echo $names
    /teaching/LFCW/UTILS/getlonglines $names $LEN
done
