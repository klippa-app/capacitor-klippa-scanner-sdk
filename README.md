[![Npm version][npm-version]][npm-url]

[npm-version]:https://img.shields.io/npm/v/@klippa/capacitor-klippa-scanner-sdk.svg
[npm-url]:https://www.npmjs.com/package/@klippa/capacitor-klippa-scanner-sdk

### SDK License
Please be aware you need to have a license to use this SDK.
If you would like to use our scanner, please contact us [here](https://www.klippa.com/en/contact-en/)

### Getting started
#### Android
Edit the file `android/key.properties`, if it doesn't exist yet, create it. Add the SDK credentials:
```bash
klippa.scanner.sdk.username={your-username}
klippa.scanner.sdk.password={your-password}
```
Replace the `{your-username}` and `{your-password}` values with the ones provided by Klippa.

#### iOS

Edit the file `ios/Podfile`, add the Klippa CocoaPod:
```ruby
// Edit the platform to a minimum of 15.0, our SDK doesn't support earlier iOS versions.
platform :ios, '15.0'

target 'YourApplicationName' do
  # Pods for YourApplicationName
  // ... other pods

  pod 'Klippa-Scanner', podspec: 'https://custom-ocr.klippa.com/sdk/ios/specrepo/{your-username}/{your-password}/KlippaScanner/latest.podspec'
end
```

Replace the `{your-username}` and `{your-password}` values with the ones provided by Klippa.

Edit the file `ios/{project-name}/Info.plist` and add the `NSCameraUsageDescription` value:
```xml
...
<key>NSCameraUsageDescription</key>
<string>Access to your camera is needed to photograph documents.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Access to your photo library is used to save the images of documents.</string>
...
```

### Ionic

```bash
npm install @klippa/capacitor-klippa-scanner-sdk
npx cap sync
```
Don't forget to run `pod install` in the ios folder when running the iOS app.

### Usage

#### Import & Configuration
```javascript
import { KlippaScannerSDK } from "@klippa/capacitor-klippa-scanner-sdk"

// KlippaScanner configuration
const KlippaScannerConfig: CameraConfig = {
    // Required
    license: "your-license",

    // Optional.
    // Whether to show the icon to enable "multi-document-mode"
    allowMultipleDocuments: false,

    // Whether the "multi-document-mode" should be enabled by default.
    defaultMultipleDocuments: false,

    // Ability to disable/hide the shutter button (only works when a model is supplied as well).
    shutterButton: { allowShutterButton: true, hideShutterButton: false },

    // Whether the crop mode (auto edge detection) should be enabled by default.
    defaultCrop: false,

    // Define the max resolution of the output file. It’s possible to set only one of these values. We will make sure the picture fits in the given resolution. We will also keep the aspect ratio of the image. Default is max resolution of camera.
    imageMaxWidth: 1920,
    imageMaxHeight: 1080,

    // Set the output quality (between 0-100) of the jpg encoder. Default is 100.
    imageMaxQuality: 95,

    deleteButtonText: "Delete",

    retakeButtonText: "Retake",

    cancelButtonText: "Cancel",

    cancelConfirmationMessage: "Are you sure you want to cancel?",

    cancelAndDeleteImagesButtonText: "Delete images",

    // The camera mode for scanning one part documents.
    cameraModeSingle: { name: "Single", message: "Instructions" },

    // The camera mode for scanning documents that consist of multiple pages.
    cameraModeMulti: { name: "Multi", message: "Instructions" },

    // The camera mode for scanning long documents in separate parts.
    cameraModeSegmented: { name: "Segmented", message: "Instructions" },

    startingIndex: 0,

    // Optional. Only affects Android.

    // What the default color conversion will be (original, grayscale, enhanced, blackAndWhite).
    defaultColor: 'enhanced',

    // The output format (jpeg, pdfSingle, pdfMerged, png). Default is jpeg.
    outputFormat: 'jpeg',

    // Set the output resolution, uses the DPI to calculate the resolution. Default is off.
    pageFormat: 'off', // off, a3, a4, a5, a6, b4, b5, letter

    // The DPI which is used to calculate the PageFormat resolution.
    dpi: 'auto', // auto, dpi200, dpi300

    // Whether to perform on-device OCR after scanning completes.
    performOnDeviceOCR: false,

    // Where to put the image results.
    //StoragePath: '/sdcard/scanner',

    // The filename to use for the output images, supports replacement tokens %dateTime% and %randomUUID%.
    //OutputFilename: 'KlippaScannerExample-%dateTime%-%randomUUID%',


    // The threshold sensitive the motion detection is. (lower value is higher sensitivity, default 50).
    imageMovingSensitivityAndroid: 50,

    // Whether to hide or show the rotate button in the Review Screen. (default shown/true)
    userCanRotateImage: true,

    // Whether to hide or show the cropping button in the Review Screen. (default shown/true)
    userCanCropManually: true,

    // Whether to hide or show the color changing button in the Review Screen. (default shown/true)
    userCanChangeColorSetting: true,

    // Whether to go to the Review Screen once the image limit has been reached. (default false)
    shouldGoToReviewScreenWhenImageLimitReached: false,

    // Whether the user must confirm the taken photo before the SDK continues.
    userShouldAcceptResultToContinue: false,

    // Whether to allow users to select media from their device (Shows a media button bottom left on the scanner screen).
    userCanPickMediaFromStorage: false,

    // Whether the next button in the bottom right of the scanner screen goes to the review screen instead of finishing the session.
    shouldGoToReviewScreenOnFinishPressed: false,

    // The primary color of the interface, should be a HEX Color.
    primaryColor: '#52277c',

    // The accent color of the interface, should be a  HEX Color.
    accentColor: '#52277c',

    // The color of the background of the warning message, should be a  HEX Color.
    warningBackgroundColor: '#fff',

    // The color of the text of the warning message, should be a  HEX Color.
    warningTextColor: '#52277c',

    imageLimit: 5,

    // The color of the menu icons when they are enabled, should be a  HEX Color.
    iconEnabledColor: '#9B3BF9',

    // The color of the menu icons when they are disabled, should be a  HEX Color.
    iconDisabledColor: '#bab9bd',

    // The amount of opacity for the overlay, should be a float.
    overlayColorAlpha: 0.75,

    // The amount of seconds the preview should be visible for, should be a float.
    previewDuration: 1.0,

    // Whether the camera has a view finder overlay (a helper grid so the user knows where the document should be), should be a Boolean.
    isViewFinderEnabled: true,

    // If you would like to use a custom model for object detection. Model + labels file should be packaged in your bundle.
    // Model: {name: "model", labelsName: "labels"},

    // If you would like to enable automatic capturing of images.
    timer: { allowed: false, enabled: false, duration: 0.4 },

    // To add extra horizontal and / or vertical padding to the cropped image.
    cropPadding: { width: 100, height: 100 },

    // After capture, show a checkmark preview with this success message, instead of a preview of the image.
    success: { message: 'Success', previewDuration: 1 },

    // Whether the camera automatically saves the images to the camera roll. Default true. (iOS version 0.4.2 and up only)
    storeImagesToCameraRoll: false,

    // The threshold sensitive the motion detection is. (lower value is higher sensitivity, default 200).
    imageMovingSensitivityIOS: 200,
}

```

#### Starting the scanner
The result of `KlippaScannerSDK.getCameraResult(config: CameraConfig)` is a Promise, so you can get the result with:
```javascript
// Call this in a method (i.e after a button press)
KlippaScannerSDK.getCameraResult(KlippaScannerConfig).then((result) => {
    console.log(`Took ${result.images.length} pictures`);
}).catch((reason) => {
    console.log(reason)
})
```

#### Clear Storage
```javascript
// Clear all stored images and data
KlippaScannerSDK.purge().then(() => {
    console.log('Storage cleared successfully');
}).catch((reason) => {
    console.log('Failed to clear storage:', reason);
})
```

The content of the result object is:
```javascript
{
  // Whether the Crop option was turned on, so you can save it as default.
  "crop": true,

  // Whether the Timer option was turned on, so you can save it as default.
  "timerEnabled": false,

  // What color option was used, so you can save it as default
  "color": "original", // original, grayscale, enhanced, blackAndWhite

  // Whether the single document mode instructions were dismissed
  "singleDocumentModeInstructionsDismissed": false,

  // Whether the multi document mode instructions were dismissed
  "multiDocumentModeInstructionsDismissed": false,

  // Whether the segmented document mode instructions were dismissed
  "segmentedDocumentModeInstructionsDismissed": false,

  // An array of images.
  "images": [
    {
      "filePath": "example/path/to/your/image.jpg"
    }
  ]
}
```

The reject reason object has a code and a message, the used codes are:
 - E_ACTIVITY_DOES_NOT_EXIST (Android only)
 - E_FAILED_TO_SHOW_SESSION (Android only)
 - E_MISSING_LICENSE
 - E_CANCELED
 - E_UNKNOWN_ERROR

### Specify SDK Version

#### Android

Edit the file `android/build.gradle`, add the following:

```groovy
allprojects {
  // ... other definitions
  project.ext {
      klippaScannerVersion = "{version}"
  }
}
```

Replace the `{version}` value with the version you want to use.

#### iOS

Edit the file `ios/Podfile`, change the pod line of `Klippa-Scanner` and replace `latest.podspec` with `{version}.podspec`, replace the `{version}` value with the version you want to use.

### Customize the colours

#### Android

Add or edit the file `android/app/src/main/res/values/colors.xml`, add the following:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="klippa_scanner_sdk_color_primary">#000000</color>
    <color name="klippa_scanner_sdk_color_accent">#ffffff</color>
    <color name="klippa_scanner_sdk_color_secondary">#2dc36a</color>
    <color name="klippa_scanner_sdk_color_warning_background">#BF000000</color>
    <color name="klippa_scanner_sdk_color_warning_text">#ffffff</color>
    <color name="klippa_scanner_sdk_color_icon_disabled">#444</color>
    <color name="klippa_scanner_sdk_color_icon_enabled">#ffffff</color>
    <color name="klippa_scanner_sdk_color_button_with_icon_foreground">#ffffff</color>
    <color name="klippa_scanner_sdk_color_button_with_icon_background">#444444</color>
    <color name="klippa_scanner_sdk_color_primary_action_foreground">#ffffff</color>
    <color name="klippa_scanner_sdk_color_primary_action_background">#2dc36a</color>
</resources>
```

#### iOS

Use the following properties in the config when running `getCameraResult`: `primaryColor`, `accentColor`, `secondaryColor`, `warningBackgroundColor`, `warningTextColor`, `overlayColorAlpha`, `iconDisabledColor`, `iconEnabledColor`, `buttonWithIconForegroundColor`, `buttonWithIconBackgroundColor`, `primaryActionForegroundColor`, `primaryActionBackgroundColor`.

### Customize the texts

#### Android

Add or edit the file `android/app/src/main/res/values/strings.xml`, add the following:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="klippa_action_crop">Crop</string>
    <string name="klippa_action_delete">Delete</string>
    <string name="klippa_action_expand">Expand</string>
    <string name="klippa_action_filter">Filter</string>
    <string name="klippa_action_rotate">Rotate</string>
    <string name="klippa_action_save">Save</string>
    <string name="klippa_auto_capture">Auto-Capture</string>
    <string name="klippa_cancel_button_text">Cancel</string>
    <string name="klippa_cancel_confirmation">When you close the taken scans will be deleted. Are you sure you want to cancel without saving?</string>
    <string name="klippa_cancel_delete_images">Cancel Scanner</string>
    <string name="klippa_continue_button_text">Continue</string>
    <string name="klippa_delete_button_text">Delete</string>
    <string name="klippa_image_color_enhanced">Enhanced</string>
    <string name="klippa_image_color_grayscale">Grayscale</string>
    <string name="klippa_image_color_original">Original</string>
    <string name="klippa_image_color_black_and_white">Black and White</string>
    <string name="klippa_image_limit_reached">You have reached the image limit</string>
    <string name="klippa_image_moving_message">Moving too much</string>
    <string name="klippa_images">Images</string>
    <string name="klippa_manual_capture">Manual</string>
    <string name="klippa_orientation_warning_message">Hold your phone in portrait mode</string>
    <string name="klippa_retake_button_text">Retake</string>
    <string name="klippa_success_message">Success</string>
    <string name="klippa_zoom_message">Move closer to the document</string>
    <string name="klippa_too_bright_warning_message">The image is too bright</string>
    <string name="klippa_too_dark_warning_message">The image is too dark</string>
</resources>
```

#### iOS

Use the following properties in the config when running `getCameraResult`: `imageTooBrightMessage`, `imageTooDarkMessage`, `deleteButtonText`, `retakeButtonText`, `cancelButtonText`, `cancelAndDeleteImagesButtonText`, `cancelConfirmationMessage`, `moveCloserMessage`, `imageMovingMessage`, `imageLimitReachedMessage`, `imageColorOriginalText`, `imageColorGrayScaleText`, `imageColorEnhancedText`, `imageColorBlackAndWhiteText`, `continueButtonText`, `cropEditButtonText`, `filterEditButtonText`, `rotateEditButtonText`, `deleteEditButtonText`, `cancelCropButtonText`, `expandCropButtonText`, `saveCropButtonText`, `autoCaptureButtonText`, `manualButtonText`, `deleteOptionsButtonText`, `segmentedModeImageCountMessage`.

### Important iOS notes
Older iOS versions do not ship the Swift libraries. To make sure the SDK works on older iOS versions, you can configure the build to embed the Swift libraries using the build setting `EMBEDDED_CONTENT_CONTAINS_SWIFT = YES`.

We started using XCFrameworks from version 0.1.0, if you want to use that version or up, you need CocoaPod version 1.9.0 or higher.

### Important Android notes
When using a custom trained model for object detection, add the following to your app's build.gradle file to ensure Gradle doesn’t compress the models when building the app:

```groovy
android {
    aaptOptions {
        noCompress "tflite"
    }
}
```
### Using the Example App

- Clone the project
- Run `npm install` in both `root` and `example` folders.
- Run `npm run build` in both `root` and `example` folders.
- Run `npx cap sync` in example folder.
- Run `npx cap run ios` or `npx cap run android` for whichever OS you want to run on.

Note: You will need to add your own Klippa username and password to the `Podfile` and `build.gradle` to pull the dependencies correctly.
You might also need to run `pod install` in example/ios/App/ folder.

### About Klippa

[Klippa](https://www.klippa.com/en) is a scale-up from [Groningen, The Netherlands](https://goo.gl/maps/CcCGaPTBz3u8noSd6) and was founded in 2015 by six Dutch IT specialists with the goal to digitize paper processes with modern technologies.

We help clients enhance the effectiveness of their organization by using machine learning and OCR. Since 2015 more than a 1000 happy clients have been served with a variety of the software solutions that Klippa offers. Our passion is to help our clients to digitize paper processes by using smart apps, accounts payable software and data extraction by using OCR.

### License

The MIT License (MIT)
