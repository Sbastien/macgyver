#!/bin/sh

# Log levels
LOG_LEVEL_DEBUG=0
LOG_LEVEL_INFO=1
LOG_LEVEL_WARN=2
LOG_LEVEL_ERROR=3

# Default log level (can be overridden by VERBOSE env variable)
: "${LOG_LEVEL:=$LOG_LEVEL_INFO}"

# Enable verbose mode if VERBOSE=1
if [ "${VERBOSE:-0}" = "1" ]; then
    LOG_LEVEL=$LOG_LEVEL_DEBUG
fi

# Color codes (ANSI) - using printf for POSIX compatibility
COLOR_RESET="$(printf '\033[0m')"
COLOR_BLUE="$(printf '\033[0;34m')"
COLOR_GREEN="$(printf '\033[0;32m')"
COLOR_YELLOW="$(printf '\033[0;33m')"
COLOR_RED="$(printf '\033[0;31m')"
COLOR_GRAY="$(printf '\033[0;90m')"

# Base log function
log() {
    local level="$1"
    local emoji="$2"
    local message="$3"
    local end="$4"
    local color="$5"

    # Skip if log level is too low
    if [ "$level" -lt "$LOG_LEVEL" ]; then
        return
    fi

    if [ "$end" = "done" ]; then
        printf "\r\033[K${color}%s %b${COLOR_RESET}\n" "$emoji" "$message"
    else
        printf "\r\033[K${color}%s %b${COLOR_RESET}" "$emoji" "$message"
    fi
}

# Convenience functions
log_debug() {
    log "$LOG_LEVEL_DEBUG" "🔍" "$1" "${2:-done}" "$COLOR_GRAY"
}

log_info() {
    log "$LOG_LEVEL_INFO" "ℹ️ " "$1" "${2:-done}" "$COLOR_BLUE"
}

log_success() {
    log "$LOG_LEVEL_INFO" "✅" "$1" "${2:-done}" "$COLOR_GREEN"
}

log_warn() {
    log "$LOG_LEVEL_WARN" "⚠️ " "$1" "${2:-done}" "$COLOR_YELLOW"
}

log_error() {
    log "$LOG_LEVEL_ERROR" "❌" "$1" "${2:-done}" "$COLOR_RED"
}

log_step() {
    log "$LOG_LEVEL_INFO" "🔧" "$1" "${2:-}" "$COLOR_BLUE"
}

# Progress indicator for long-running tasks
log_progress() {
    log "$LOG_LEVEL_INFO" "⏳" "$1" "" "$COLOR_BLUE"
}

# Section headers
log_section() {
    printf "\n%s━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%s\n" "${COLOR_BLUE}" "${COLOR_RESET}"
    log "$LOG_LEVEL_INFO" "📦" "$1" "done" "$COLOR_BLUE"
    printf "%s━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%s\n" "${COLOR_BLUE}" "${COLOR_RESET}"
}
