# Changelog

All notable changes to the PKS Edit for Flutter will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [LATEST] - 2025-01-09

### Added
- Editing Settings will now save the settings right away for the next session. Generally editing settings was
  improved to allow for more configuration options.
- Added support for file system watches: PKS Edit detects now, that files currently edited were changed outside
  PKS Edit so the user may choose to update and integrate the changes. 
- A new option was added: `silentlyReloadFilesChangedExternally`.
- Various new functions like Find..., Find&Replace... and Outdent and Indent were added. Also find again
  forward and backward will work in a way compatible to PKS EDIT Windows version.
- L10N was improved and most texts are now available in English and German.
- Byte Order Mark detection and handling was added.
- New View Options (show/hide highlight, show/hide line numbers) were added.
- Added "Word"-wise caret movement and selection
- Support for renderers depending on document type added.
- Support for Search (and Replace) in Files is on the run.

