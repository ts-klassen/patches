# patches – simple per-file patch manager

`patches` is a tiny Bash utility that keeps a directory full of **patch
files – one per changed source file** – and can:

* **Generate / refresh** those patch files ( *make mode* )
* **Apply** them to produce a patched copy of the original sources ( *apply
  mode* )

The tool is particularly handy for packaging workflows where you need to
track local edits on top of an upstream tarball without dragging full
git history along.

---

## Quick start

```
patches [--make|-m] [WORKDIR]
```

* `WORKDIR` is the working directory that contains the following peers:

  ```text
  orig/      – pristine upstream sources (must exist)
  dist/      – copy of orig/ with patches applied         (apply mode)
  patches/   – *.patch files, one per changed file        (make mode)
  rej/       – *.rej files from failed hunks              (apply mode)
  ```

* With no flag ( **apply mode**, default)

  1. `dist/` is recreated as a clean copy of `orig/`.
  2. Every `patches/*.patch` file is applied ( `patch -p1 --no-backup-if-mismatch` ).
  3. Exit status
     * `0` – all patches applied cleanly
     * `1` – one or more hunks failed ( see `rej/` )

* With `--make` or `-m` ( **make mode** )

  1. The script compares files between `orig/` and `dist/`.
  2. A unified diff is written to `patches/<file>.patch` for each *added* / *deleted* / *modified* file.
  3. Leading comment headers that were already in a patch are preserved, so you can keep human-readable explanations on top of every patch file.
  4. Unchanged patches are removed and empty directories pruned.

### Minimal example

```bash
# starting point
tar xf upstream-1.0.tar.gz
mv upstream-1.0 mypkg && cd mypkg
mv . orig                       # keep pristine copy
cp -a orig/ dist                # work in dist/

# hack away
echo '// local change' >> dist/src/foo.c

# snapshot the edits
patches -m                      # creates patches/src/foo.c.patch

# Later, refresh dist/ again
rm -rf dist && patches          # dist/ rebuilt & patched
```

---

## Running the test-suite

Tests are written with [Bats](https://github.com/bats-core/bats-core).

1. Install Bats (for example via `brew install bats-core` or your distro’s
   package manager).
2. From the repository root, execute:

   ```bash
   bats tests
   ```

   You should see:

   ```text
   1..3
   ok 1 make mode creates patch for modified file
   ok 2 apply mode applies patch and returns 0
   ok 3 apply mode signals failure on hunk reject
   ```

The test-suite spins up isolated temporary working directories, so it is
safe to run in parallel or repeatedly.

---

## License

See `LICENSE` for details.
