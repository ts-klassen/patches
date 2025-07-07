#!/usr/bin/env bats

# Directory of repository root where the patches script lives.
repo_root="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
patches_script="$repo_root/patches"

setup() {
  # Create isolated temporary workdir for each test.
  workdir=$(mktemp -d)
  mkdir "$workdir/orig"
}

teardown() {
  rm -rf "$workdir"
}

@test "make mode creates patch for modified file" {
  echo 'hello' > "$workdir/orig/foo.txt"

  cp -a "$workdir/orig" "$workdir/dist"
  echo 'hello, world' > "$workdir/dist/foo.txt"

  run "$patches_script" --make "$workdir"

  [ "$status" -eq 0 ]
  [ -f "$workdir/patches/foo.txt.patch" ]
  grep -q '+hello, world' "$workdir/patches/foo.txt.patch"
}

@test "apply mode applies patch and returns 0" {
  echo 'A' > "$workdir/orig/a.txt"

  cp -a "$workdir/orig" "$workdir/dist"
  echo 'AA' > "$workdir/dist/a.txt"

  "$patches_script" --make "$workdir"
  rm -rf "$workdir/dist"

  run "$patches_script" "$workdir"

  [ "$status" -eq 0 ]
  [ -f "$workdir/dist/a.txt" ]
  result=$(cat "$workdir/dist/a.txt")
  [ "$result" = 'AA' ]
}

@test "apply mode signals failure on hunk reject" {
  echo 'one' > "$workdir/orig/x.txt"

  cp -a "$workdir/orig" "$workdir/dist"
  echo 'two' > "$workdir/dist/x.txt"

  "$patches_script" -m "$workdir"

  echo 'THREE' > "$workdir/orig/x.txt"
  rm -rf "$workdir/dist"

  run "$patches_script" "$workdir"

  [ "$status" -eq 1 ]
  [ -s "$workdir/rej/x.txt.rej" ]
}
