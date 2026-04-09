### T-1. `python3.10` freezes at `_dyld_start` on macOS 26+ (pyenv ad-hoc binary)

**Symptom**

Any invocation of `python3.10` (including `python3.10 --version` or `python3.10 -S -c "print('ok')"`) hangs indefinitely with no output. `Ctrl+C` does not terminate the process, and the process state shows as `U` or `UE` (uninterruptible) in `ps`. Multiple stuck processes accumulate over time -- IDE language servers, `uvicorn`, `pip` commands, etc.

**Diagnose**

1. Find the stuck PID:
   ```bash
   ps aux | grep -i python | grep -v grep
   ```
2. Sample the process to see where it is blocked:
   ```bash
   sample <PID> 3 -f /tmp/py-sample.txt
   head -60 /tmp/py-sample.txt
   ```
3. If the call graph shows the thread stuck at **`_dyld_start (in dyld)`** with a tiny physical footprint (~96K), the interpreter has not even finished loading the dynamic linker. This confirms a **kernel-level binary verification hang**, not a Python-level issue.

**Root cause**

pyenv builds Python with an **ad-hoc (linker-signed)** signature. macOS 26 (Sequoia/Tahoe) tags such binaries with the new **`com.apple.provenance`** extended attribute and routes them through `amfid`/`syspolicyd`/`trustd` for provenance verification. In some states the verification cache gets into a broken state and blocks `dyld_start` indefinitely on every invocation of the binary.

Confirm with:

```bash
PY="$(pyenv which python3.10 2>/dev/null || which python3.10)"
file "$PY"
xattr -l "$PY"                                   # look for com.apple.provenance
codesign -dv --verbose=2 "$PY" 2>&1 | grep -E 'Signature|Identifier'
# expected: Signature=adhoc
```

EDR/antivirus software and network issues are usually NOT the cause here -- dyld blocks before any network or user code runs.

**Fix -- Option A: keep pyenv, clear provenance and re-sign**

```bash
# 1) Remove the provenance attribute from the whole pyenv version tree
xattr -dr com.apple.provenance ~/.pyenv/versions/3.10.18

# 2) Re-sign the interpreter to refresh the AMFI cache
codesign --force --sign - ~/.pyenv/versions/3.10.18/bin/python3.10
codesign --force --sign - ~/.pyenv/versions/3.10.18/bin/python3

# 3) Verify
time python3.10 -S -c "print('ok')"
# expected: real time ~0.02s
```

If `com.apple.provenance` cannot be removed (it is a kernel-managed attribute in some cases), copy the binary to force a new inode:

```bash
cd ~/.pyenv/versions/3.10.18/bin
cp -p python3.10 python3.10.new
mv python3.10.new python3.10
codesign --force --sign - python3.10
```

**Fix -- Option B: switch to Homebrew `python@3.10`**

Recommended when you do not need to pin a specific patch version (Homebrew only ships the current patch of each minor release).

```bash
# 1) Kill and cleanup
pkill -9 -f "pyenv/versions/3.10"
rm -rf <project>/venv
rm -f <project>/.python-version

# 2) Remove pyenv
brew uninstall pyenv pyenv-virtualenv 2>/dev/null
rm -rf ~/.pyenv
# Remove pyenv init lines from ~/.zprofile / ~/.zshrc:
#   export PYENV_ROOT="$HOME/.pyenv"
#   command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
#   eval "$(pyenv init -)"

# 3) Install Homebrew python
brew install python@3.10

# 4) Verify
time /opt/homebrew/bin/python3.10 -S -c "print('ok')"

# 5) Recreate the project venv
cd <project>
/opt/homebrew/bin/python3.10 -m venv venv
./venv/bin/pip install -r pkg/pip_requirements.txt
```

**Caveats of Option B**

- Homebrew does not allow pinning to a specific patch version (e.g. `3.10.18`). `brew upgrade` may bump the patch version, breaking reproducibility. If the project requires a specific patch, use Option A or keep pyenv.
- Homebrew `python@3.10` is *also* ad-hoc signed, but its install pipeline registers the binary with the system caches cleanly, so the dyld freeze does not reproduce.

**Leftover processes in `UE` state**

Processes that were already hung in uninterruptible state cannot be killed with `kill -9` -- the kernel is holding them. They stay resident (zero CPU) and are harmless, but a **reboot** is required to remove them from the process table. Warn the user about this when applying the fix.

**IDE follow-up**

After switching Python installations, re-select the interpreter in VS Code / Cursor / PyCharm:
- Command Palette -> **Python: Select Interpreter** -> pick `<project>/venv/bin/python` or `/opt/homebrew/bin/python3.10`.
- Cursor/VS Code Pylance may still cache the old pyenv path; reload the window (`Developer: Reload Window`) if language server errors persist.
