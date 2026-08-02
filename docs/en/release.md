# Release process

1. Complete the hardware test checklist in `docs/en/testing.md`.
2. Add the official logo and icon locally if required, then run
   `python scripts/prepare_ui.py`.
3. Build the Windows x64 executable with PureBasic.
4. Run `python scripts/validate.py`.
5. Run `python scripts/package_source.py`.
6. Merge the reviewed release pull request into `main`.
7. Create tag `v1.0.0` from the reviewed commit.
8. Create a GitHub Release for `v1.0.0`.
9. Upload the Windows executable, source ZIP and `SHA256SUMS.txt` as release
   assets.
10. Only after final review, change repository visibility from private to public.

The executable belongs in the GitHub Release, not in the Git history.
