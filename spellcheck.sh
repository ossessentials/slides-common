#!/bin/bash
# Per course speelcking wrapper
# Written by: Behan Webster
#################################
set -e

VERSION=1.3

#################################
export LANGUAGE="en"
LOCALE=en_US.UTF-8
ADICT="american"
export LANG=$LOCALE
export LC_ALL=$LOCALE
export LC_COLLATE=$LOCALE

#################################
ASPELL="aspell ${LANGUAGE:+--lang=$LANGUAGE} --home-dir=."
ACHECK="$ASPELL ${ADICT:+--master=$ADICT} --ignore-repl --sug-mode=bad-spellers check"
BACKUP="--backup"

#################################
colors() {
	RED="\e[0;31m"
	#GREEN="\e[0;32m"
	#YELLOW="\e[0;33m"
	CYAN="\e[0;36m"
	BLUE="\e[0;34m"
	BACK="\e[0m"
}

#################################
debug() {
	[[ -z $DEBUG ]] || echo -e "${BLUE}D: $*${BACK}" >&2
}
error() {
	echo -e "${RED}E: $*${BACK}" >&2
	exit 1
}
info() {
	[[ -n $QUIET ]] || echo -e "${CYAN}I: $*${BACK}" >&2
}
verbose() {
	[[ -z $VERBOSE ]] || echo "+ $*" >&2
	# shellcheck disable=SC2048
	[[ -n $TEST ]] || $*
}

#################################
mv_if_changed() {
	if cmp -s "$1" "$2" ; then
		rm -f "$2"
	else
		cp "$2" "$1"
	fi
}

#################################
sort_list() {
	local WL=$1 T
	T=$(mktemp /dev/shm/spellcheck-dict.XXXXXX)
	sort -u "$WL" | grep -v FIXME \
		| sort > "$T" \
		&& mv_if_changed "$WL" "$T"
	rm -f "$T" # Should have been mv or rm in previous step
}

#################################
build_word_lists() {
	debug "build_word_lists: $*"
	local DIR UNIQ
	for DIR in "$@" ; do
		debug "Examining $DIR for wordlist"
		# Use only absolute paths, because aspell is picky
		realpath "$DIR"
		local PARENT
		PARENT=$(dirname "$DIR")
		realpath "$PARENT"
	done | sort --unique | while read -r UNIQ ; do
		local AS BW WL
		AS="$UNIQ/.aspell.en.pws"
		BW="$UNIQ/badwords.txt"
		WL="$UNIQ/wordlist.txt"
		if [[ ! -e "$WL" || -e "$AS" && "$AS" -nt "$WL" ]] ; then
			if [[ -e "$AS" ]] ; then
				debug "Building $WL from $AS"
				sed -e 1d "$AS" >> "$WL"
				if [[ $(dirname "$AS") == $(pwd) ]] ; then
					debug "Truncating $AS"
					sed -i -e '2,$d' "$AS"
				fi
			fi
			if [[ -e "$BW" && "$BW" -nt "$WL" ]] ; then
				local T WORD
				debug "Applying $BW to $WL"
				T=$(mktemp /dev/shm/spellcheck-sedbl.XXXXXX)
				# shellcheck disable=SC2013
				for WORD in $(cat "$BW") ; do
					echo "/^$WORD$/d"
				done > "$T"
				verbose sed -i -f "$T" "$WL"
				rm -f "$T"
			fi
		fi
		if [[ -s "$WL" ]] ; then
			sort_list "$WL"
			echo "$WL"
		fi
	done
}

#################################
build_word_dict() {
	debug "build_word_dict: $*"
	local WL WD
	for WL in "$@" ; do
		if [[ -s "$WL" ]] ; then
			debug "Found $WL"
			WD=${WL/txt/dict}
			if [[ ! -e "$WD" || "$WL" -nt "$WD" ]] ; then
				debug "Building $WD"
				TEST=1 verbose "$ASPELL" create master "$WD"
				$ASPELL create master "$WD" < "$WL" 2>/dev/null
				[[ -e $WD ]] || error "$WD not created"
			fi
			echo "$WD"
		fi
	done
}

#################################
get_tex_dirs() {
	local FILE=$1
	grep subimport "$FILE" | sed -re 's|.*\{(.*)\/}\{index\}|\1|;'
}
 
#################################
FILEEXTS="tex"
get_text_files() {
	local DIR EXT
	for DIR in "$@" ; do
		for EXT in $FILEEXTS ; do
			debug "Look for *.$EXT in $DIR"
			# Dereference all symlinks with realpath,
			# or we'll destroy symlinks
			find "$DIR" -maxdepth 4 -name "*.$EXT" -print0 \
				| xargs -0 --no-run-if-empty realpath \
				| sort
		done
	done
}

#################################
list_texfiles() {
	local FILE=$1
	debug "list_tex_files: $FILE"
	local DIRS

	DIRS=$(get_tex_dirs "$FILE")
	# shellcheck disable=SC2086
	get_text_files $DIRS | ${PAGER:-less}
}

#################################
count_texfiles() {
	local COUNT
	COUNT=$(wc -l <<< "$@")
	info "Spellchecked $COUNT files"
}

#################################
do_spell() {
	local FILE=$1

	info "Spellchecking $FILE"

	local DIRS
	DIRS="$(pwd) "$(get_tex_dirs "$FILE")

	#########################
	# Build aspell options
	local OPTS LISTS DICTS DICT
	OPTS=$BACKUP
	# shellcheck disable=SC2086
	LISTS=$(build_word_lists $DIRS)
	# shellcheck disable=SC2086
	DICTS=$(build_word_dict $LISTS)
	for DICT in $DICTS ; do
		debug "Add extra dict $DICT"
		OPTS+=" --add-extra-dicts=$DICT"
	done

	#########################
	# spellcheck files
	local FILES F
	# shellcheck disable=SC2086
	FILES=$(get_text_files $DIRS)
	for F in $FILES ; do
		info "Processing $F"
		verbose "$ACHECK" "$OPTS" "$F"
	done

	#########################
	# Rebuild wordlist from .aspell files
	# shellcheck disable=SC2086
	build_word_lists $DIRS >/dev/null

	#########################
	# Delete temporary dict files
	# shellcheck disable=SC2086
	if [[ -z $DEBUG && -n $DELETE ]] ; then
		verbose rm -f $DICTS
	fi

	count_texfiles "$FILES"
}

#################################
usage() {
	local CMD
	CMD=$(basename "$0")
	echo "Usage: $CMD <options> [course.tex]"
	echo "    -e --extention EXT  Look for *.EXT in each directory"
	echo "    -h --help           Print this help"
	echo "    -l --list           List tex files which will be spell checked"
	echo "    -q --quiet          No output (except for running aspell)"
	echo "    -v --verbose        Show all the commands executed"
	echo "    -V --version        Print out the version of this script"
	echo "    -w --wordlist       Build word lists in each directory"
	echo "    -x --dont-backup    Don't make backup files when spellchecking"
	echo
	echo "    .../wordlist.txt    List of words for dictionary (checkin)"
	echo "    .../badwords.txt    Words which shouldn't be added to wordlist (checkin)"
	echo "    .../wordlist.dict   Temporary dictionary file (can delete)"
	exit 0
}
 
#################################
version() {
	local CMD
	CMD=$(basename "$0")
	echo "$CMD v$VERSION"
	exit 0
}
 
#################################
while [[ $# -gt 0 ]] ; do
	case $1 in
		-c|--color) colors ;;
		--debug) DEBUG=y ;;
		--Debug) colors; DEBUG=y; VERBOSE=y ;;
		-e|--extension) FILEEXTS+=" $2"; shift ;;
		-l|--list) LIST=y ;;
		-q|--quiet) QUIET=y ;;
		--test) TEST=y; VERBOSE=y ;;
		--trace) set -x ;;
		-v|--verbose) VERBOSE=y ;;
		-V|--version) version ;;
		-w|--wordlist) WORDLIST=y ;;
		-x|--dont-backup) BACKUP="--dont-backup"; DELETE=y ;;
		-h|--help) usage ;;
		--|*) break ;;
	esac
	shift
done

#################################
# Find course.tex file
COURSE=${COURSE:-$(basename "$PWD")}
FILE="${1:-$COURSE.tex}"
[[ -e $FILE ]] || error "$FILE not found"

#################################
# Handle course.tex in another directory
DIR=$(dirname "$FILE")
FILE=$(basename "$FILE")
cd "$DIR"

#################################
# Read config file
CONFIG=.spellcheckrc
if [[ -e $CONFIG ]] ; then
	info "Reading local config file: ${DIR:+$DIR/}$CONFIG"
	if [[ -n $DEBUG ]] ; then
		debug "Contents of config file"
		cat $CONFIG
	fi
	source $CONFIG
fi

#################################
if [[ -n $LIST ]] ; then
	list_texfiles "$FILE"
elif [[ -n $WORDLIST ]] ; then
	DIRS=$(get_tex_dirs "$FILE") 
	[[ -z $VERBOSE ]] || echo -e "Directories:\n$DIRS\nWordlists:"
	# shellcheck disable=SC2086
	build_word_lists "$(pwd)" $DIRS
else
	do_spell "$FILE"
fi
