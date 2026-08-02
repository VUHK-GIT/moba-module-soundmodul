# Release process 1.0.0

## Phase 1 – Release candidate in the private repository

1. Bring `release/1.0.0-open-source` to the final source state.
2. Run `python scripts/validate.py` and wait for GitHub Actions.
3. Load a documented sound 1 through sound 10 order into the JQ6500.
4. Build the hardware, including R1 and R2, according to `docs/en/hardware.md`.
5. Complete the hardware tests in `docs/en/testing.md`.
6. Build the Windows x64 executable with PureBasic.
7. Start the executable on a second Windows system or clean user environment and
   verify COM connection and WebView2 operation.
8. Run `python scripts/package_source.py`.
9. Generate SHA-256 checksums for the executable, source ZIP and other release
   assets.
10. Record results and known limitations in the draft pull request.

## Phase 2 – Approve the pull request

1. Check every open item in the draft pull request.
2. Confirm that the source branch contains no executable, proprietary logo or
   audio file.
3. Change the pull request from `Draft` to `Ready for review`.
4. Review the final diff and file list.
5. Prefer a **squash merge** into `main` so the first public release has one
   clear release commit.

## Phase 3 – Tag and GitHub Release

1. Create the signed or annotated tag `v1.0.0` on the reviewed merge commit.
2. Create a draft GitHub Release.
3. Upload:

   ```text
   MOBA-Module-Soundmodul-1.0.0-Windows-x64.exe
   MOBA-Module-Soundmodul-1.0.0-source.zip
   moba-module-soundmodul-wiring-de.png
   moba-module-soundmodul-wiring-en.png
   SHA256SUMS.txt
   ```

4. Prepare release notes from `CHANGELOG.md` and `CHANGELOG.de.md`.
5. Download and independently verify the checksums.
6. Publish the GitHub Release.

## Phase 4 – Make the repository public

Only after the release is published:

1. Open repository settings.
2. Under `Settings → General → Danger Zone → Change repository visibility`,
   change the repository from `Private` to `Public`.
3. Enter the repository name when GitHub requests confirmation.
4. Verify without signing in:
   - README and license are visible;
   - release `v1.0.0` is accessible;
   - executable and checksums can be downloaded;
   - wiring SVGs render correctly;
   - issues and security guidance are available;
   - no proprietary brand asset was published accidentally.

The executable belongs in the GitHub Release, not in Git history.
