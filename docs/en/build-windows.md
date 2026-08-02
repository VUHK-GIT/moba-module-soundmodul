# Build the Windows application

## Requirements

- Windows 10 or Windows 11;
- PureBasic 6.10 LTS or newer, x64 edition;
- Microsoft WebView2 Runtime;
- Python 3.10 or newer to assemble `software/purebasic/ui/index.html`;
- the complete repository checkout.

## Build

1. Run `python scripts/prepare_ui.py`. Without the proprietary logo, the script uses a text wordmark.
2. Open `software/purebasic/MOBA_Module_Soundmodul.pb` in PureBasic.
3. Select the Windows x64 compiler.
4. Compile or create an executable.
5. For an official release build, optionally add the proprietary application
   icon through PureBasic IDE options. The icon is not part of the MIT License.

The HTML interface is embedded at compile time with PureBasic `IncludeBinary`.
No external UI files are required next to the compiled executable.

## Release executable

Do not commit `.exe` files to the source branch. Upload the compiled executable
as an asset of the GitHub release tagged `v1.0.0`.

Recommended release asset names:

```text
MOBA-Module-Soundmodul-1.0.0-Windows-x64.exe
MOBA-Module-Soundmodul-1.0.0-source.zip
SHA256SUMS.txt
```
