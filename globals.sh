#!/usr/bin/env sh

BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
LIME=$(tput setaf 190)
CYAN=$(tput setaf 153)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BRIGHT=$(tput bold)
RESET=$(tput sgr0)
UNDERLINE=$(tput smul)
NEW_LINE='
'

prog_exists() {
    command -v "$1" >/dev/null 2>&1
}

systemd_running() {
    systemctl status "$1" >/dev/null 2>&1
}

confirm() {
    while true; do
        printf "%sConfirm [y/n]: %s" $YELLOW $RESET
        read -r yn
        case $yn in
            [y]) return 0 ;;
            [n]) return 1 ;;
            *) ;;
        esac
    done
}

prompt() {
    args="$@"
    printf "\n%s%s%s\n" "$YELLOW" "$args" "$RESET"  
    if confirm; then
        return 0
    else
        return 1
    fi
}

ask() {
    args="$2"
    printf "\n%s%s%s:\n" "$YELLOW" "$args" "$RESET"    
    read -r "ask_variable"
    eval "$1=\"$ask_variable\""
}

msg_err() {
    broadcast_flag="$1"
    args="$@"

    if [ "$broadcast_flag" = "--broadcast" ]; then
        shift
        args="$@"
        if prog_exists notify-send; then
            notify-send -r 9999 "$args"
        else
            printf "%snotify-send is not installed!%s\n" "$RED" "$RESET"
        fi
    fi
    
    printf "%s%s%s\n" "$RED" "$args" "$RESET"
}

msg() {
    args="$@"
    printf "\n%s%s%s\n" "$GREEN" "$args" "$RESET"  
}

help_title() {
    args="$@"
    printf "%s%s%s\n" "$BRIGHT" "$GREEN" "$args" "$RESET"  
}

help_content() {
    args="$@"
    printf "%s%s%s\n" "$YELLOW" "$args" "$RESET"  
}
