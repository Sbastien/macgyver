#!/usr/bin/env bats
#
# Tests for bin/validate and bin/generate.
#
# Only the checks CI depends on, and only their failure cases. A check that
# never fails is worse than no check: it reports safety it is not providing.
# The passing cases are covered by CI running these scripts on every push.

setup() {
    TMP="$BATS_TEST_TMPDIR/case.Brewfile"
}

@test "validate accepts the repository as it stands" {
    run bin/validate Brewfile
    [ "$status" -eq 0 ]
    for profile in profiles/*.Brewfile; do
        run bin/validate "$profile"
        [ "$status" -eq 0 ]
    done
}

@test "validate rejects a Brewfile that does not parse" {
    printf 'brew "jq" # ok\nthis is not ruby(((\n' >"$TMP"
    run bin/validate "$TMP"
    [ "$status" -eq 1 ]
}

@test "validate catches duplicates that differ only by their comment" {
    # The previous grep-based check compared whole lines and missed these
    printf 'brew "jq"   # one\nbrew "jq"   # two\n' >"$TMP"
    run bin/validate "$TMP"
    [ "$status" -eq 1 ]
}

@test "validate rejects a section icon the website does not define" {
    # An unknown name renders nothing at all, silently, in the browser
    printf '# Fake\n# @icon:doesnotexist\nbrew "jq" # x\n' >"$TMP"
    run bin/validate "$TMP"
    [ "$status" -eq 1 ]
}

@test "generate --check fails when the Brewfile is edited by hand" {
    cp Brewfile "$BATS_TEST_TMPDIR/bak"
    printf 'brew "tampered" # x\n' >>Brewfile
    run bin/generate --check
    cp "$BATS_TEST_TMPDIR/bak" Brewfile
    [ "$status" -eq 1 ]
}

@test "generate --check fails when a profile changes without regenerating" {
    cp profiles/base.Brewfile "$BATS_TEST_TMPDIR/bak"
    printf '\n# Extra\n# @icon:cog\nbrew "hyperfine" # x\n' >>profiles/base.Brewfile
    run bin/generate --check
    cp "$BATS_TEST_TMPDIR/bak" profiles/base.Brewfile
    [ "$status" -eq 1 ]
}
