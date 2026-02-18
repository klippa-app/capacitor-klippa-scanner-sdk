import { registerPlugin } from '@capacitor/core'

export interface ModelOptions {
    // The name of the model file when using custom object detection.
    fileName: string
    // The name of the label file when using custom object detection.
    modelLabels: string
}

export interface TimerOptions {
    // Whether the timerButton is shown or hidden.
    allowed: boolean
    // Whether automatically capturing of images is enabled.
    enabled: boolean
    // The duration of the interval (in seconds) in which images are automatically captured, should be a float.
    duration: number
}

export interface Dimensions {
    // To add extra horizontal padding to the cropped image.
    width: number
    // To add extra vertical padding to the cropped image.
    height: number
}

export interface SuccessOptions {
    // After capture, show a check mark preview with this success message, instead of a preview of the image.
    message: string
    // The amount of seconds the success message should be visible for, should be a float.
    previewDuration: number
}

export interface ShutterButton {
    // Whether to allow or disallow the shutter button to work (can only be disabled if a model is supplied)
    allowShutterButton: boolean
    // Whether the shutter button should be hidden (only works if allowShutterButton is false)
    hideShutterButton: boolean
}

export interface DocumentMode {
    // Localized document mode name shown to user.
    name?: string
    // Instructions show to user, if null is passed no instructions will be shown.
    message?: string
    // The image that is shown in the instructions (iOS only).
    image?: string
}

export interface CameraConfig {
    // Global options.

    // The license as given by Klippa.
    license: string

    // Whether the crop mode (auto edge detection) should be enabled by default.
    defaultCrop?: boolean

    // The warning message when someone should move closer to a document, should be a string.
    moveCloserMessage?: string

    // The warning message when the camera preview has to much motion to be able to automatically take a photo.
    imageMovingMessage?: string

    // Define the max resolution of the output file. It’s possible to set only one of these values.
    // We will make sure the picture fits in the given resolution. We will also keep the aspect ratio of the image.
    // Default is max resolution of camera.

    // The max width of the result image.
    imageMaxWidth?: number

    // The max height of the result image.
    imageMaxHeight?: number

    // Set the output quality (between 0-100) of the jpg encoder. Default is 100.
    imageMaxQuality?: number

    // The amount of seconds the preview should be visible for, should be a float.
    previewDuration?: number

    // Whether to go to the Review Screen once the image limit has been reached. (default false)
    shouldGoToReviewScreenWhenImageLimitReached?: boolean

    // Whether to hide or show the rotate button in the Review Screen. (default shown/true)
    userCanRotateImage?: boolean

    // Whether to hide or show the cropping button in the Review Screen. (default shown/true)
    userCanCropManually?: boolean

    // Whether to hide or show the color changing button in the Review Screen. (default shown/true)
    userCanChangeColorSetting?: boolean

    // If you would like to use a custom model for object detection. Model + labels file should be packaged in your bundle.
    model?: ModelOptions

    // If you would like to enable automatic capturing of images.
    timer?: TimerOptions

    // To add extra horizontal and / or vertical padding to the cropped image.
    cropPadding?: Dimensions

    // After capture, show a check mark preview with this success message, instead of a preview of the image.
    success?: SuccessOptions

    // Whether to disable/hide the shutter button (only works if a model is supplied).
    shutterButton?: ShutterButton

    // To limit the amount of images that can be taken.
    imageLimit?: number

    // The message to display when the limit has been reached.
    imageLimitReachedMessage?: string

    // Whether the camera automatically saves the images to the camera roll (iOS) / gallery (Android). Default true.
    storeImagesToCameraRoll?: boolean

    // What the default color conversion will be (original, grayscale, enhanced, blackAndWhite).
    defaultColor?: 'original' | 'grayscale' | 'enhanced' | 'blackAndWhite'

    // The output format (jpeg, pdfSingle, pdfMerged, png). Default is jpeg.
    outputFormat?: 'jpeg' | 'pdfSingle' | 'pdfMerged' | 'png'

    // Set the output resolution, uses the DPI to calculate the resolution. Default is off.
    pageFormat?: 'off' | 'a3' | 'a4' | 'a5' | 'a6' | 'b4' | 'b5' | 'letter'

    // The DPI which is used to calculate the PageFormat resolution.
    dpi?: 'auto' | 'dpi200' | 'dpi300'

    // Whether to perform on-device OCR after scanning completes.
    performOnDeviceOCR?: boolean

    // The lower threshold before the warning message informs the environment is too dark (default 0).
    brightnessLowerThreshold?: number

    // The upper threshold before the warning message informs the environment is too bright (default 6).
    brightnessUpperThreshold?: number

    // Whether the user must confirm the taken photo before the SDK continues (default false).
    userShouldAcceptResultToContinue?: boolean

    // Whether to allow users to select media from their device (shows a media button bottom left on the scanner screen).
    userCanPickMediaFromStorage?: boolean

    // Whether the next button in the bottom right of the scanner screen goes to the review screen instead of finishing the session.
    shouldGoToReviewScreenOnFinishPressed?: boolean

    // The camera mode for scanning single documents.
    cameraModeSingle?: DocumentMode;

    // The camera mode for scanning documents that consist of multiple pages.
    cameraModeMulti?: DocumentMode;

    // The camera mode for scanning long documents in separate parts that are later stitched together.
    cameraModeSegmented?: DocumentMode;

    // The index of which camera mode be shown first, (i.e 0 is first camera mode.)
    startingIndex?: number;

    // Android options.

    // Where to put the image results.
    storagePath?: string

    // The filename to be given to the image results.
    outputFilename?: string

    // The threshold sensitive the motion detection is. (lower value is higher sensitivity, default 50).
    imageMovingSensitivityAndroid?: number

    // iOS options.

    // The text inside of the delete button.
    deleteButtonText?: string

    // The text inside of the retake button.
    retakeButtonText?: string

    // The text inside of the cancel button.
    cancelButtonText?: string

    // The text inside of the color selection alert dialog button named original.
    imageColorOriginalText?: string

    // The text inside of the color selection alert dialog button named grayscale.
    imageColorGrayScaleText?: string

    // The text inside of the color selection alert dialog button named enhanced.
    imageColorEnhancedText?: string

    // The text inside of the color selection alert dialog button named black and white.
    imageColorBlackAndWhiteText?: string

    // The text above the shutter button to indicate whether auto capture is enabled or not.
    autoCaptureButtonText?: string

    // The text above the shutter button to indicate whether manual capture is enabled or not.
    manualButtonText?: string

    // The text inside of the delete options alert dialog.
    deleteOptionsButtonText?: string

    // The text to finish the scanner on the edit screen.
    continueButtonText?: string

    // The text below the crop button in the review screen.
    cropEditButtonText?: string

    // The text below the filter button in the review screen.
    filterEditButtonText?: string

    // The text below the rotate button in the review screen.
    rotateEditButtonText?: string

    // The text below the delete button in the review screen.
    deleteEditButtonText?: string

    // The text below the cancel button in the crop screen.
    cancelCropButtonText?: string

    // The text below the expand button in the crop screen.
    expandCropButtonText?: string

    // The text below the save button in the crop screen.
    saveCropButtonText?: string

    // The text inside of the cancel alert button.
    cancelAndDeleteImagesButtonText?: string

    // The text inside of the alert to confirm exiting the scanner.
    cancelConfirmationMessage?: string

    // The text at the top to indicate the picture count on segmented camera mode.
    segmentedModeImageCountMessage?: string

    // The warning message when the camera result is too bright.
    imageTooBrightMessage?: string

    // The warning message when the camera result is too dark.
    imageTooDarkMessage?: string

    // The iOS colors to be configured as RGB Hex. For Android see the readme.

    // The primary color of the interface, should be a hex RGB color string.
    primaryColor?: string

    // The accent color of the interface, should be a hex RGB color string.
    accentColor?: string

    // The secondary color of the interface, should be a hex RGB color string.
    secondaryColor?: string

    // The color of the background of the warning message, should be a hex RGB color string.
    warningBackgroundColor?: string

    // The color of the text of the warning message, should be a hex RGB color string.
    warningTextColor?: string

    // The amount of opacity for the overlay, should be a float.
    overlayColorAlpha?: number

    // The color of the menu icons when they are enabled, should be a hex RGB color string.
    iconEnabledColor?: string

    // The color of the menu icons when they are enabled, should be a hex RGB color string.
    iconDisabledColor?: string

    // The color of the menu icons of the screen where you can review/edit the images, should be a hex RGB color string.
    buttonWithIconForegroundColor?: string

    // The color of the menu icons of the screen where you can review/edit the images, should be a hex RGB color string.
    buttonWithIconBackgroundColor?: string

    // The foreground color of the primary action buttons.
    primaryActionForegroundColor?: string

    // The background color of the primary action buttons.
    primaryActionBackgroundColor?: string

    // Whether the camera has a view finder overlay (a helper grid so the user knows where the document should be), should be a Boolean.
    isViewFinderEnabled?: boolean

    // The threshold sensitive the motion detection is. (lower value is higher sensitivity, default 200).
    imageMovingSensitivityIOS?: number
}

export interface CameraResult {
    // An array of images.
    images: CameraResultImage[]

    // Whether the MultipleDocuments option was turned on, so you can save it as default.
    multipleDocuments?: boolean

    // Whether the AllowTimer option was turned on, so you can save it as default.
    timerEnabled?: boolean

    // Whether the Crop option was turned on, so you can save it as default.
    crop?: boolean

    // What color option was used, so you can save it as default.
    color?: 'original' | 'grayscale' | 'enhanced' | 'blackAndWhite'

    // Whether the single document mode instructions were dismissed.
    singleDocumentModeInstructionsDismissed?: boolean

    // Whether the multi document mode instructions were dismissed.
    multiDocumentModeInstructionsDismissed?: boolean

    // Whether the segmented document mode instructions were dismissed.
    segmentedDocumentModeInstructionsDismissed?: boolean
}

export interface CameraResultImage {
    // The path to the image on the filesystem.
    filePath: string
}

export interface KlippaScannerSDKPlugin {
    getCameraResult(config: CameraConfig): Promise<CameraResult>
    purge(): Promise<void>
}

const KlippaScannerSDK = registerPlugin<KlippaScannerSDKPlugin>('KlippaScannerSDKPlugin')

export { KlippaScannerSDK }

