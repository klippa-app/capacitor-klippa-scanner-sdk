## 0.2.0

- Updated minimum Android API level: 21 → 25
- Updated minimum iOS version: 13.0 → 15.0
- Added `purge()` method to clear scanner storage
- Added `outputFormat` support: `jpeg`, `pdfSingle`, `pdfMerged`, `png`
- Added `pageFormat` support: `off`, `a3`, `a4`, `a5`, `a6`, `b4`, `b5`, `letter`
- Added `dpi` support: `auto`, `dpi200`, `dpi300`
- Added `performOnDeviceOCR` boolean option
- Added `brightnessLowerThreshold` and `brightnessUpperThreshold`
- Added `blackAndWhite` color mode to `defaultColor` options
- Added `userShouldAcceptResultToContinue` option
- Added `userCanPickMediaFromStorage` option
- Added `shouldGoToReviewScreenOnFinishPressed` option
- Renamed `name` → `fileName`
- Renamed `labelsName` → `modelLabels`

### iOS Only

- Added `buttonWithIconForegroundColor` and `buttonWithIconBackgroundColor`
- Added `primaryActionForegroundColor` and `primaryActionBackgroundColor`
- Added `continueButtonText`, `cropEditButtonText`, `filterEditButtonText`
- Added `rotateEditButtonText`, `deleteEditButtonText`, `cancelCropButtonText`
- Added `expandCropButtonText`, `saveCropButtonText`
- Added `imageColorBlackAndWhiteText`, `autoCaptureButtonText`, `manualButtonText`
- Added `deleteOptionsButtonText`
- Added `segmentedModeImageCountMessage`
- Added `imageTooBrightMessage` and `imageTooDarkMessage`

### Android Only

- Now uses XML only for text and colors, please check the README for more information.

## 0.1.0

- Bumped Android SDK to `3.1.3`.
- Bumped iOS SDK to `1.2.0`.
- Removed `allowMultipleDocuments`.
- Removed `defaultMultipleDocuments`.
- Added `DocumentMode`.
- Added `cameraModeSingle`, `cameraModeMulti`, `cameraModeSegmented` which are all of type `DocumentMode`.
- Fixed typo `imageColorGrayscaleText` becomes `imageColorGrayScaleText`.

## 0.0.2

- Fixed typo`Filepath` becomes `filePath` in Android SDK.

## 0.0.1

- Initial release of SDK support for Capacitor / IONIC.