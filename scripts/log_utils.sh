#!/bin/sh

log() {
    local emoji="$1"
    local message="$2"
    local end="$3"
    if [ "$end" = "done" ]; then
        printf "\r\033[K%s %b\n" "$emoji" "$message"
    else
        printf "\r\033[K%s %b" "$emoji" "$message"
    fi
}
