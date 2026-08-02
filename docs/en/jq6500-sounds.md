# Loading audio files into the JQ6500-16P

## Principle

The JQ6500-16P uses internal flash storage. The Nano firmware and Windows
application in this project do **not** transfer audio files. Program the module
separately through its USB interface before installation or first use.

Audio files are not part of this repository. You are responsible for the
copyright and usage rights of every sound you load.

## Windows procedure

1. Connect the JQ6500-16P to the Windows PC through the module's USB connector.
2. Start the uploader supplied for the module. Many modules expose a virtual
   CD-ROM containing `MusicDownload.exe`.
3. Select the required MP3 files in the `Files` section.
4. Verify the order. It defines the sound indexes used by the firmware:

   ```text
   first uploaded file  -> sound 1
   second uploaded file -> sound 2
   ...
   tenth uploaded file  -> sound 10
   ```

5. Start the write operation in the `Flash` section and wait until it finishes.
6. Safely disconnect the module and test it with a speaker or the MOBA-Module
   firmware.

## Important notes

- Internal flash capacity is limited. Re-encode files when necessary.
- The project software cannot read file names from internal flash. Maintain the
  file-order mapping outside the module.
- A missing sound index may cause a trigger command to produce no playback.
  Provide at least sounds 1 through 3 for the release test and sounds 1 through
  10 for the complete input test.
- The uploader is third-party software and is not distributed by this
  repository.
- Update user and test documentation whenever the sound order changes.

## Reference

Additional uploader references are listed in
`docs/assets/wiring/SOURCES.md`.
