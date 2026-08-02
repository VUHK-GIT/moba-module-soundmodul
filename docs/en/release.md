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

1. Perform the final English and German documentation review.
2. Perform the final brand and logo exclusion review.
3. Run `python scripts/validate.py` on the final branch.
4. Run `python scripts/package_source.py`.
5. Assemble the final release assets and checksum manifest.
6. Change the draft pull request to `Ready for review`.
7. Squash merge the pull request into `main`.

## Tag and GitHub Release

After the merge:

1. Create the annotated tag `v1.0.0` on the new `main` commit.
2. Create a draft GitHub Release.
3. Upload:

```text
MOBA-Module-Soundmodul-1.0.0-Windows-x64.exe
MOBA-Module-Soundmodul-1.0.0-source.zip
moba-module-soundmodul-wiring-de.png
moba-module-soundmodul-wiring-en.png
SHA256SUMS.txt
```

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
