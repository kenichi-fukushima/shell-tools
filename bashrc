#!/usr/bin/env bash

################################################################################
# Terminal Control
################################################################################

function sgr() {
    # sgr stands for Select Graphic Rendition.
    #
    # reference:
    #     https://en.wikipedia.org/wiki/ANSI_escape_code
    #     http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/index.html
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
# PROMPT
################################################################################

__PS_FG_BLACK=$(sgr -p '30')
__PS_FG_BLUE=$(sgr -p '34')
__PS_FG_CYAN=$(sgr -p '36')
__PS_FG_GREEN=$(sgr -p '32')
__PS_FG_MAGENTA=$(sgr -p '35')
__PS_FG_RED=$(sgr -p '31')
__PS_FG_YELLOW=$(sgr -p '33')
__PS_FG_WHITE=$(sgr -p '37')

__PS_UNDERLINE=$(sgr -p '4')
__PS_NO_UNDERLINE=$(sgr -p '24')

__PS_RESET=$(sgr -p '0')

__PS_12=$(sgr -p '38;5;12')

function __prompt_command() {
    PS1="${__PS_12}${__PS_UNDERLINE}\w${__PS_NO_UNDERLINE} "'$'"${__PS_RESET} "
}

PROMPT_COMMAND=__prompt_command
