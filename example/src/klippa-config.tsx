import { CameraConfig } from "@klippa/capacitor-klippa-scanner-sdk";

export const KlippaScannerConfig: CameraConfig = {
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


    // Optional. Only affects Android.

    // What the default color conversion will be (grayscale, original, enhanced).
    defaultColor: 'enhanced',

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


    // The primary color of the interface, should be a UIColor.
    primaryColor: '#52277c',

    // The accent color of the interface, should be a UIColor.
    accentColor: '#52277c',

    // The overlay color (when using document detection), should be a UIColor.
    overlayColor: '#52277c',

    // The color of the background of the warning message, should be a UIColor.
    warningBackgroundColor: '#fff',

    // The color of the text of the warning message, should be a UIColor.
    warningTextColor: '#52277c',

    imageLimit: 5,

    // The color of the menu icons when they are enabled, should be a UIColor.
    iconEnabledColor: '#9B3BF9',

    // The color of the menu icons when they are disabled, should be a UIColor.
    iconDisabledColor: '#bab9bd',

    // The color of the menu icons of the screen where you can review/edit the images, should be a UIColor.
    reviewIconColor: '#fff',

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