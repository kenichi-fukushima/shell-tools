#!/usr/bin/env bash

################################################################################
# Terminal Control
################################################################################

# Returns a sequence of control characters that can be enbedded in a display
# text for a given "command", such as change foreground color to red, enable
# underline, and reset all settings to default. See the references for a
# complete set of commands. "sgr" stands for Select Graphic Rendition.
#
# Examples:
#   $ echo "$(sgr 31)this part is red$(sgr 0)this part is black"
#   $ echo "$(sgr 38;5;75)this part is sky blue$(sgr 0)this part is black"
#   $ echo "$(sgr 4)this part is underlined$(sgr 0)this part is not"
#
# Options:
#   p: whether to wrap result with additional characters to use it for shell
#      prompt.
#
# Reference:
#   https://en.wikipedia.org/wiki/ANSI_escape_code
#   http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/index.html
function sgr() {
    local prompt_mode=false
    while getopts p OPT; do
	case $OPT in
	    p) prompt_mode=true ;;
	esac
    done
    shift $((OPTIND-1))

    local param=$1
    if [[ $prompt_mode == true ]]; then
	echo "\[\033[${param}m\]"
    else
	echo -e "\033[${param}m"
    fi
}

function color_catalog() {
    for i in $(seq 0 7); do
        local param
	param="3${i}"
        echo -n "$(sgr $param) ***${param}* $(sgr 0)"
    done
    echo ""
    for i in $(seq 0 7); do
        local param
	param="1;3${i}"
        echo -n "$(sgr $param) *${param}* $(sgr 0)"
    done
    echo ""
}

function color_catalog256() {
    for i in $(seq 0 15); do
        for j in $(seq 0 15); do
            local code=$((i *16 + j))
            local param="38;5;${code}"
            echo -n "$(sgr $param) **$(printf '%03d' ${code})** $(sgr 0)"
        done
        echo ""
    done
}

################################################################################
# Git
################################################################################

export __GIT_ROOT=$HOME/GitClients

function gcd() {
    local query_terms="$@"
    local paths=$(find_git.py $query_terms)
    local old_ifs="$IFS"
    IFS=$'\n'
    set -- $paths
    IFS="$old_ifs"
    if [[ $# == 1 ]]; then
	cd "${__GIT_ROOT}/$1"
	echo $PWD
    elif [[ $# == 0 ]]; then
	echo "$(sgr 31)There is no directory that matches [$query_terms]$(sgr 0):"
    else
	echo "$(sgr 31)There are multiple directories that matches [$query_terms]$(sgr 0):"
	for path in $paths; do
	    echo "$path"
	done
	return 1
    fi
}

function gls() {
    find_git.py
}

################################################################################
# Prompt
################################################################################

__PS_FG_BLACK=$(sgr -p '30')
__PS_FG_BLUE=$(sgr -p '34')
__PS_FG_CYAN=$(sgr -p '36')
__PS_FG_GREEN=$(sgr -p '32')
__PS_FG_MAGENTA=$(sgr -p '35')
__PS_FG_RED=$(sgr -p '31')
__PS_FG_YELLOW=$(sgr -p '33')
__PS_FG_WHITE=$(sgr -p '37')
__PS_NO_FG=$(sgr -p '39')

__PS_UNDERLINE=$(sgr -p '4')
__PS_NO_UNDERLINE=$(sgr -p '24')

__PS_RESET=$(sgr -p '0')

# Reference:
#     https://gist.github.com/jasonm23/2868981
__PS_4=$(sgr -p '38;5;4')
__PS_31=$(sgr -p '38;5;31')
__PS_54=$(sgr -p '38;5;54')
__PS_70=$(sgr -p '38;5;70')
__PS_242=$(sgr -p '38;5;242')

function __prompt_command() {
    if [[ $PWD =~ ^${__GIT_ROOT}/([^/]+)/([^/]+)/([^/]+)/([^/]+)(/.*)? ]]; then
	local site=${BASH_REMATCH[1]}
	local repository=${BASH_REMATCH[2]}
	local project=${BASH_REMATCH[3]}
	local label=${BASH_REMATCH[4]}
	local rel_path="${BASH_REMATCH[5]}"
	local branch=$(git branch | grep "*")
	branch=${branch#* }
	local result="${__PS_UNDERLINE}"
	result="${result}${__PS_31}${project}${__PS_NO_FG}"
	if [[ $label == Dev ]]; then
	    local print_label=""
	else
	    local print_label="($label)"
	fi
	result="${result}${__PS_242}${print_label}:${__PS_242}"
	result="${result}${__PS_70}${branch}${__PS_NO_FG}"
	if [[ "$rel_path" ]]; then
	    result="${result}${__PS_242}:${rel_path}${__PS_NO_FG}"
	fi
	result="${result}${__PS_NO_UNDERLINE} $ "
	PS1="$result"
    else
	PS1="${__PS_4}${__PS_UNDERLINE}\w${__PS_NO_UNDERLINE} "'$'"${__PS_RESET} "
    fi
}

PROMPT_COMMAND=__prompt_command
