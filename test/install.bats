#!/usr/bin/env bats
#
# Tests for docs/install.sh
#
# Deliberately short. Each test here corresponds to a bug that actually
# shipped, or to a branch no CI runner can reach. Tests that only restate
# what the code says were removed — they cost maintenance and catch nothing.
#
# Functions run in a subshell rather than being sourced into the bats
# process, because install.sh sets `-euo pipefail` and that should not leak
# into the harness.

INSTALLER="docs/install.sh"

with_installer() {
    bash -c "BREWFILE_INSTALLER_LIB=1; source $INSTALLER; $1"
}

@test "spin returns the watched job's exit code" {
    # Shipped bug: spin ended with printf, so it always returned 0 and every
    # background failure was reported as success.
    run with_installer '(exit 7) & spin $! msg >/dev/null 2>&1'
    [ "$status" -eq 7 ]
}

@test "a failed download aborts instead of continuing to brew bundle" {
    run with_installer '
        set -e
        (exit 1) & spin $! "Downloading..." >/dev/null 2>&1 || die "download failed"
        echo REACHED
    '
    [ "$status" -eq 1 ]
    [[ "$output" != *REACHED* ]]
}

@test "exit 0 survives the cleanup trap" {
    # Shipped bug: cleanup ended with a failing test, and bash replaces the
    # exit status with the trap's when the trap's last command fails. So
    # declining the installation exited 1.
    run with_installer 'trap cleanup EXIT; exit 0'
    [ "$status" -eq 0 ]
}

@test "detect_platform resolves the Intel prefix" {
    # No Intel runner exists, so this is the only thing exercising the branch.
    run with_installer 'uname() { [[ $1 == -s ]] && echo Darwin || echo x86_64; }
                        detect_platform; echo "$BREW_PREFIX $GUM_URL"'
    [[ "$output" == "/usr/local "* ]]
    [[ "$output" == *"Darwin_x86_64.tar.gz" ]]
}

@test "detect_platform refuses a host it cannot support" {
    run with_installer 'uname() { echo Linux; } ; detect_platform'
    [ "$status" -eq 1 ]
}

@test "spin prints one line when stdout is not a terminal" {
    # Otherwise a CI log gets one line per animation frame
    run with_installer 'true & spin $! "Working..."'
    [ "$(grep -c "Working" <<<"$output")" -eq 1 ]
}

@test "a dry run answers prompts instead of blocking" {
    run bash -c "BREWFILE_INSTALLER_LIB=1; source $INSTALLER
                 DRY_RUN=1; confirm 'x' yes </dev/null && ! confirm 'y' </dev/null"
    [ "$status" -eq 0 ]
}

@test "--help exits zero" {
    run "$INSTALLER" --help
    [ "$status" -eq 0 ]
}

@test "an unknown option exits non-zero with usage" {
    run "$INSTALLER" --bogus
    [ "$status" -eq 1 ]
    [[ "$output" == *"Usage: install.sh"* ]]
}

@test "--dry-run runs the whole installer without touching the machine" {
    # The one test that exercises the script end to end, including the real
    # download and parse of the published Brewfile.
    local before
    before=$(ls "$HOME" | md5)

    run "$INSTALLER" --dry-run
    [ "$status" -eq 0 ]
    [[ "$output" == *"no changes were made"* ]]

    [ "$before" = "$(ls "$HOME" | md5)" ]
}
