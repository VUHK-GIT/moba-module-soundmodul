# Release process 1.0.0

## Principle

The release is prepared in the `release/1.0.0-open-source` branch. The
repository remains private until final approval. Executables, audio files and
proprietary standalone brand assets are not committed to the source branch.

## Confirmed release candidate

The following release-candidate state has been confirmed:

- PureBasic 6.40, Windows x64;
- hardware test with separate R1 and R2, both 1 kΩ, passed;
- BUSY values remained unchanged with R2 installed:
  - idle approximately 2 to 3 ADC counts;
  - playback approximately 537 to 540 ADC counts;
- executable tested on the Windows build system;
- executable also passed a functional test on a second Windows computer;
- verified executable:
  `MOBA-Module-Soundmodul-1.0.0-Windows-x64.exe`;
- SHA-256:
  `f7e7f848cc7c67181d3f7ac73f5abb816b72dacdd0afa2af39682b97c81c2946`.

A named mapping of audio files to sound indexes 1 through 10 is not required for
version 1.0.0. Users select and load their own audio files.

## Remaining work before merge

1. Change the draft pull request to `Ready for review`.
2. Squash merge the pull request into `main`.

## Tag and GitHub Release

After the merge:

1. Create a new GitHub Release and create tag `v1.0.0` on the new `main` commit.
2. Save the release as a draft first.
3. Upload:

```text
MOBA-Module-Soundmodul-1.0.0-Windows-x64.exe
moba-module-soundmodul-wiring-de.png
moba-module-soundmodul-wiring-en.png
SHA256SUMS.txt
```

GitHub automatically provides source-code archives in ZIP and TAR.GZ format for
the tag. A separate manually generated source ZIP is not required for the public
release. `scripts/package_source.py` remains available as an optional tool for
local reproducible packages.

4. Verify release notes and checksums.
5. Publish the release.
6. Only then change the repository visibility to public.
7. While signed out, verify that README, license, documentation and downloads
   are available as intended.

## Do not commit to Git

- Windows executable;
- ZIP release packages;
- MP3 or WAV files;
- proprietary upload tools;
- the official MOBA-Module logo or icon as a freely reusable standalone asset.
