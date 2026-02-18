import Foundation
import Capacitor
import KlippaScanner

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(KlippaScannerSDKPlugin)
public class KlippaScannerSDKPlugin: CAPPlugin {

    private let E_ERROR = "E_ERROR"
    private let E_CANCELED = "E_CANCELED"
    private let E_MISSING_LICENSE = "E_MISSING_LICENSE"
    private let E_FAILED_TO_SHOW_SESSION = "E_FAILED_TO_SHOW_SESSION"
    private let E_UNKNOWN_ERROR = "E_UNKNOWN_ERROR"

    private var _call: CAPPluginCall? = nil

    // MARK: Setup Timer
    private func setupTimer(_ config: [AnyHashable : Any], _ builder: KlippaScannerBuilder) {
        guard let timer = config["timer"] as? [String: Any] else {
            return
        }

        if let isTimerAllowed = timer["allowed"] as? Bool {
            builder.klippaMenu.allowTimer = isTimerAllowed
        }

        if let isTimerEnabled = timer["enabled"] as? Bool {
            builder.klippaMenu.isTimerEnabled = isTimerEnabled
        }

        if let timerDuration = timer["duration"] as? Double {
            builder.klippaDurations.timerDuration = timerDuration
        }
    }

    // MARK: Purge
    @objc func purge(_ call: CAPPluginCall) {
        KlippaScannerStorage.purge()
        call.resolve()
    }

    //MARK: Setup Colors
    private func setupColors(_ config: [AnyHashable : Any], _ builder: KlippaScannerBuilder) {
        if let primaryColor = config["primaryColor"] as? String {
            builder.klippaColors.primaryColor = hexColorToUIColor(hex: primaryColor)
        }

        if let accentColor = config["accentColor"] as? String {
            builder.klippaColors.accentColor = hexColorToUIColor(hex: accentColor)
        }

        if let secondaryColor = config["secondaryColor"] as? String {
            builder.klippaColors.secondaryColor = hexColorToUIColor(hex: secondaryColor)
        }

        if let overlayColorAlpha = config["overlayColorAlpha"] as? CGFloat {
            builder.klippaColors.overlayColorAlpha = overlayColorAlpha
        }

        if let warningBackgroundColor = config["warningBackgroundColor"] as? String {
            builder.klippaColors.warningBackgroundColor = hexColorToUIColor(hex: warningBackgroundColor)
        }

        if let warningTextColor = config["warningTextColor"] as? String {
            builder.klippaColors.warningTextColor = hexColorToUIColor(hex: warningTextColor)
        }

        if let iconEnabledColor = config["iconEnabledColor"] as? String {
            builder.klippaColors.iconEnabledColor = hexColorToUIColor(hex: iconEnabledColor)
        }

        if let iconDisabledColor = config["iconDisabledColor"] as? String {
            builder.klippaColors.iconDisabledColor = hexColorToUIColor(hex: iconDisabledColor)
        }

        if let buttonWithIconForegroundColor = config["buttonWithIconForegroundColor"] as? String {
            builder.klippaColors.buttonWithIconForegroundColor = hexColorToUIColor(hex: buttonWithIconForegroundColor)
        }

        if let buttonWithIconBackgroundColor = config["buttonWithIconBackgroundColor"] as? String {
            builder.klippaColors.buttonWithIconBackgroundColor = hexColorToUIColor(hex: buttonWithIconBackgroundColor)
        }

        if let primaryActionForegroundColor = config["primaryActionForegroundColor"] as? String {
            builder.klippaColors.primaryActionForegroundColor = hexColorToUIColor(hex: primaryActionForegroundColor)
        }

        if let primaryActionBackgroundColor = config["primaryActionBackgroundColor"] as? String {
            builder.klippaColors.primaryActionBackgroundColor = hexColorToUIColor(hex: primaryActionBackgroundColor)
        }

        if let defaultColor = config["defaultColor"] as? String {
            let color = switch defaultColor {
            case "grayscale":
                KlippaImageColor.grayscale
            case "enhanced":
                KlippaImageColor.enhanced
            case "blackAndWhite":
                KlippaImageColor.blackAndWhite
            default:
                KlippaImageColor.original
            }
            builder.klippaColors.imageColor = color
        }
    }

    // MARK: Setup Model
    private func setupModel(_ config: [AnyHashable : Any], _ builder: KlippaScannerBuilder) {
        if let model = config["model"] as? [String: String] {
            if let modelFile = model["fileName"], let modelLabels = model["modelLabels"] {
                builder.klippaObjectDetectionModel = KlippaObjectDetectionModel(
                    modelFile: modelFile,
                    modelLabels: modelLabels
                )
            }
        }
    }

    // MARK: Setup Camera Modes
    private func setupCameraModes(_ config: [AnyHashable : Any], _ builder: KlippaScannerBuilder) {
        var modes = [KlippaDocumentMode]()

        if let singleCameraMode = config["cameraModeSingle"] as? [String: String] {
            let single = KlippaSingleDocumentMode()

            if let name = singleCameraMode["name"] {
                single.name = name
            }

            if let message = singleCameraMode["message"] ?? single.instructions?.message {
                let image = singleCameraMode["image"]
                single.instructions = Instructions(
                    title: single.name,
                    message: message,
                    image: image ?? KlippaSingleDocumentMode.image
                )
            }
            modes.append(single)
        }

        if let multiCameraMode = config["cameraModeMulti"] as? [String: String] {
            let multi = KlippaMultipleDocumentMode()

            if let name = multiCameraMode["name"] {
                multi.name = name
            }

            if let message = multiCameraMode["message"] ?? multi.instructions?.message {
                let image = multiCameraMode["image"]
                multi.instructions = Instructions(
                    title: multi.name,
                    message: message,
                    image: image ?? KlippaMultipleDocumentMode.image
                )
            }
            modes.append(multi)
        }

        if let segmentedCameraMode = config["cameraModeSegmented"] as? [String: String] {
            let segmented = KlippaSegmentedDocumentMode()

            if let name = segmentedCameraMode["name"] {
                segmented.name = name
            }

            if let message = segmentedCameraMode["message"] ?? segmented.instructions?.message {
                let image = segmentedCameraMode["image"]
                segmented.instructions = Instructions(
                    title: segmented.name,
                    message: message,
                    image: image ?? KlippaSegmentedDocumentMode.image
                )
            }
            modes.append(segmented)
        }

        if modes.isEmpty {
            return
        }

        let index = config["startingIndex"] as? Int ?? 0

        builder.klippaCameraModes = KlippaCameraModes(
            modes: modes,
            startingIndex: index
        )
    }

    //MARK: Setup Messages
    private func setupMessages(_ config: [AnyHashable : Any], _ builder: KlippaScannerBuilder) {
        if let imageTooBrightMessage = config["imageTooBrightMessage"] as? String {
            builder.klippaMessages.imageTooBrightMessage = imageTooBrightMessage
        }

        if let imageTooDarkMessage = config["imageTooDarkMessage"] as? String {
            builder.klippaMessages.imageTooDarkMessage = imageTooDarkMessage
        }

        if let imageColorOriginalText = config["imageColorOriginalText"] as? String {
            builder.klippaButtonTexts.imageColorOriginalText = imageColorOriginalText
        }

        if let imageColorGrayscaleText = config["imageColorGrayScaleText"] as? String {
            builder.klippaButtonTexts.imageColorGrayscaleText = imageColorGrayscaleText
        }

        if let imageColorEnhancedText = config["imageColorEnhancedText"] as? String {
            builder.klippaButtonTexts.imageColorEnhancedText = imageColorEnhancedText
        }

        if let imageColorBlackAndWhiteText = config["imageColorBlackAndWhiteText"] as? String {
            builder.klippaButtonTexts.imageColorBlackAndWhiteText = imageColorBlackAndWhiteText
        }

        if let continueButtonText = config["continueButtonText"] as? String {
            builder.klippaButtonTexts.continueButtonText = continueButtonText
        }

        if let imageLimitReachedMessage = config["imageLimitReachedMessage"] as? String {
            builder.klippaMessages.imageLimitReachedMessage = imageLimitReachedMessage
        }

        if let deleteButtonText = config["deleteButtonText"] as? String {
            builder.klippaButtonTexts.deleteButtonText = deleteButtonText
        }

        if let retakeButtonText = config["retakeButtonText"] as? String {
            builder.klippaButtonTexts.retakeButtonText = retakeButtonText
        }

        if let cancelButtonText = config["cancelButtonText"] as? String {
            builder.klippaButtonTexts.cancelButtonText = cancelButtonText
        }

        if let cancelAndDeleteImagesButtonText = config["cancelAndDeleteImagesButtonText"] as? String {
            builder.klippaButtonTexts.cancelAndDeleteImagesButtonText = cancelAndDeleteImagesButtonText
        }

        if let cropEditButtonText = config["cropEditButtonText"] as? String {
            builder.klippaButtonTexts.cropEditButtonText = cropEditButtonText
        }

        if let filterEditButtonText = config["filterEditButtonText"] as? String {
            builder.klippaButtonTexts.filterEditButtonText = filterEditButtonText
        }

        if let rotateEditButtonText = config["rotateEditButtonText"] as? String {
            builder.klippaButtonTexts.rotateEditButtonText = rotateEditButtonText
        }

        if let deleteEditButtonText = config["deleteEditButtonText"] as? String {
            builder.klippaButtonTexts.deleteEditButtonText = deleteEditButtonText
        }

        if let cancelCropButtonText = config["cancelCropButtonText"] as? String {
            builder.klippaButtonTexts.cancelCropButtonText = cancelCropButtonText
        }

        if let expandCropButtonText = config["expandCropButtonText"] as? String {
            builder.klippaButtonTexts.expandCropButtonText = expandCropButtonText
        }

        if let saveCropButtonText = config["saveCropButtonText"] as? String {
            builder.klippaButtonTexts.saveCropButtonText = saveCropButtonText
        }

        if let autoCaptureButtonText = config["autoCaptureButtonText"] as? String {
            builder.klippaButtonTexts.autoCaptureButtonText = autoCaptureButtonText
        }

        if let manualButtonText = config["manualButtonText"] as? String {
            builder.klippaButtonTexts.manualButtonText = manualButtonText
        }

        if let deleteOptionsButtonText = config["deleteOptionsButtonText"] as? String {
            builder.klippaButtonTexts.deleteOptionsButtonText = deleteOptionsButtonText
        }

        if let cancelConfirmationMessage = config["cancelConfirmationMessage"] as? String {
            builder.klippaMessages.cancelConfirmationMessage = cancelConfirmationMessage
        }

        if let segmentedModeImageCountMessage = config["segmentedModeImageCountMessage"] as? String {
            builder.klippaMessages.segmentedModeImageCountMessage = segmentedModeImageCountMessage
        }

        if let moveCloserMessage = config["moveCloserMessage"] as? String {
            builder.klippaMessages.moveCloserMessage = moveCloserMessage
        }

        if let imageMovingMessage = config["imageMovingMessage"] as? String {
            builder.klippaMessages.imageMovingMessage = imageMovingMessage
        }
    }

    // MARK: Setup Shutter Button
    private func setupShutterButton(_ config: [AnyHashable : Any], _ builder: KlippaScannerBuilder) {
        if let shutterButton = config["shutterButton"] as? [String: Bool] {
            if let allowShutterButton = shutterButton["allowShutterButton"] {
                builder.klippaShutterButton.allowShutterButton = allowShutterButton
            }

            if let hideShutterButton = shutterButton["hideShutterButton"] {
                builder.klippaShutterButton.hideShutterButton = hideShutterButton
            }
        }
    }

    // MARK: Setup Image Settings
    private func setupImageSettings(_ config: [AnyHashable : Any], _ builder: KlippaScannerBuilder) {
        if let imageMaxWidth = config["imageMaxWidth"] as? CGFloat {
            builder.klippaImageAttributes.imageMaxWidth = imageMaxWidth
        }

        if let imageMaxHeight = config["imageMaxHeight"] as? CGFloat {
            builder.klippaImageAttributes.imageMaxHeight = imageMaxHeight
        }

        if let imageMaxQuality = config["imageMaxQuality"] as? CGFloat {
            builder.klippaImageAttributes.imageMaxQuality = imageMaxQuality
        }

        if let cropPadding = config["cropPadding"] as? [String: Double] {
            if let width = cropPadding["width"] {
                builder.klippaImageAttributes.cropPadding.width = width
            }
            if let height = cropPadding["height"] {
                builder.klippaImageAttributes.cropPadding.height = height
            }
        }

        if let imageLimit = config["imageLimit"] as? Int {
            builder.klippaImageAttributes.imageLimit = imageLimit
        }

        if let storeImagesToCameraRoll = config["storeImagesToCameraRoll"] as? Bool {
            builder.klippaImageAttributes.storeImagesToCameraRoll = storeImagesToCameraRoll
        }

        if let imageMovingSensitivity = config["imageMovingSensitivityIOS"] as? CGFloat {
            builder.klippaImageAttributes.imageMovingSensitivity = imageMovingSensitivity
        }

        if let outputFormat = config["outputFormat"] as? String {
            switch outputFormat {
            case "jpeg":
                builder.klippaImageAttributes.outputFormat = .jpeg
            case "pdfSingle":
                builder.klippaImageAttributes.outputFormat = .pdfSingle
            case "pdfMerged":
                builder.klippaImageAttributes.outputFormat = .pdfMerged
            case "png":
                builder.klippaImageAttributes.outputFormat = .png
            default:
                builder.klippaImageAttributes.outputFormat = .jpeg
            }
        }

        if let performOnDeviceOCR = config["performOnDeviceOCR"] as? Bool {
            builder.klippaImageAttributes.performOnDeviceOCR = performOnDeviceOCR
        }

        if let brightnessLowerThreshold = config["brightnessLowerThreshold"] as? Double {
            builder.klippaImageAttributes.brightnessLowerThreshold = brightnessLowerThreshold
        }

        if let brightnessUpperThreshold = config["brightnessUpperThreshold"] as? Double {
            builder.klippaImageAttributes.brightnessUpperThreshold = brightnessUpperThreshold
        }

        if let pageFormat = config["pageFormat"] as? String {
            switch pageFormat {
            case "off":
                builder.klippaImageAttributes.pageFormat = .off
            case "a3":
                builder.klippaImageAttributes.pageFormat = .a3
            case "a4":
                builder.klippaImageAttributes.pageFormat = .a4
            case "a5":
                builder.klippaImageAttributes.pageFormat = .a5
            case "a6":
                builder.klippaImageAttributes.pageFormat = .a6
            case "b4":
                builder.klippaImageAttributes.pageFormat = .b4
            case "b5":
                builder.klippaImageAttributes.pageFormat = .b5
            case "letter":
                builder.klippaImageAttributes.pageFormat = .letter
            default:
                builder.klippaImageAttributes.pageFormat = .off
            }
        }

        if let dpi = config["dpi"] as? String {
            switch dpi {
            case "auto":
                builder.klippaImageAttributes.dpi = .auto
            case "dpi200":
                builder.klippaImageAttributes.dpi = .dpi200
            case "dpi300":
                builder.klippaImageAttributes.dpi = .dpi300
            default:
                builder.klippaImageAttributes.dpi = .auto
            }
        }
    }

    // MARK: Setup Menu
    private func setupMenu(_ config: [AnyHashable : Any], _ builder: KlippaScannerBuilder) {
        if let isCropEnabled = config["defaultCrop"] as? Bool {
            builder.klippaMenu.isCropEnabled = isCropEnabled
        }

        if let shouldGoToReviewScreenWhenImageLimitReached = config["shouldGoToReviewScreenWhenImageLimitReached"] as? Bool {
            builder.klippaMenu.shouldGoToReviewScreenWhenImageLimitReached = shouldGoToReviewScreenWhenImageLimitReached
        }

        if let userShouldAcceptResultToContinue = config["userShouldAcceptResultToContinue"] as? Bool {
            builder.klippaMenu.userShouldAcceptResultToContinue = userShouldAcceptResultToContinue
        }

        if let userCanRotateImage = config["userCanRotateImage"] as? Bool {
            builder.klippaMenu.userCanRotateImage = userCanRotateImage
        }

        if let userCanCropManually = config["userCanCropManually"] as? Bool {
            builder.klippaMenu.userCanCropManually = userCanCropManually
        }

        if let userCanChangeColorSetting = config["userCanChangeColorSetting"] as? Bool {
            builder.klippaMenu.userCanChangeColorSetting = userCanChangeColorSetting
        }

        if let isViewFinderEnabled = config["isViewFinderEnabled"] as? Bool {
            builder.klippaMenu.isViewFinderEnabled = isViewFinderEnabled
        }

        if let userCanPickMediaFromStorage = config["userCanPickMediaFromStorage"] as? Bool {
            builder.klippaMenu.userCanPickMediaFromStorage = userCanPickMediaFromStorage
        }

        if let shouldGoToReviewScreenOnFinishPressed = config["shouldGoToReviewScreenOnFinishPressed"] as? Bool {
            builder.klippaMenu.shouldGoToReviewScreenOnFinishPressed = shouldGoToReviewScreenOnFinishPressed
        }
    }

    // MARK: Setup Success
    private func setupSuccess(_ config: [AnyHashable : Any], _ builder: KlippaScannerBuilder) {
        if let previewDuration = config["previewDuration"] as? Double {
            builder.klippaDurations.previewDuration = previewDuration
        }

        guard let success = config["success"] as? [String: Any] else {
            return
        }

        if let successPreviewDuration = success["previewDuration"] as? Double {
            builder.klippaDurations.successPreviewDuration = successPreviewDuration
        }

        if let successMessage = success["message"] as? String {
            builder.klippaMessages.successMessage = successMessage
        }

    }

    // MARK: Get Camera Result
    @objc func getCameraResult(_ call: CAPPluginCall) {
        guard let config = call.options else {
            call.reject("CameraConfig was not supplied correctly.", E_UNKNOWN_ERROR)
            return
        }

        guard let license = config["license"] as? String else {
            call.reject("Missing license", E_MISSING_LICENSE)
            return
        }

        let builder = KlippaScannerBuilder(
            builderDelegate: self,
            license: license
        )

        setupMenu(config, builder)

        setupImageSettings(config, builder)

        setupTimer(config, builder)

        setupSuccess(config, builder)

        setupShutterButton(config, builder)

        setupMessages(config, builder)

        setupColors(config, builder)

        setupModel(config, builder)

        setupCameraModes(config, builder)

        _call = call

        DispatchQueue.main.async {
            let result = builder.build()
            let rootViewController = UIApplication.shared.windows.last!.rootViewController!

            switch result {
            case .success(let controller):
                controller.modalPresentationStyle = .fullScreen
                rootViewController.present(controller, animated: true, completion: nil)
            case .failure(let error):
                call.reject("error: \(error)", self.E_FAILED_TO_SHOW_SESSION, error)
            }
        }
    }

    // MARK: Hex to UIColor
    private func hexColorToUIColor(hex: String) -> UIColor {
        let r, g, b, a: CGFloat

        let start = hex.index(hex.startIndex, offsetBy: 1)
        let hexColor = String(hex[start...])

        if hexColor.count == 8 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0

            if scanner.scanHexInt64(&hexNumber) {
                a = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                r = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                g = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                b = CGFloat(hexNumber & 0x000000ff) / 255

                return UIColor(red: r, green: g, blue: b, alpha: a)
            }
        }

        // Fallback to 6-character hex format
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

// MARK: Scanner Delegate
extension KlippaScannerSDKPlugin: KlippaScannerDelegate {

    public func klippaScannerDidFinishScanningWithResult(result: KlippaScanner.KlippaScannerResult) {
        var images: [[String: String]] = []
        for image in result.results {
            let imageDict = ["filePath" : image.path]
            images.append(imageDict)
        }

        let singleDocumentModeInstructionsDismissed = result.dismissedInstructions[DocModeType.singleDocument.name] ?? false
        let multiDocumentModeInstructionsDismissed = result.dismissedInstructions[DocModeType.multipleDocument.name] ?? false
        let segmentedDocumentModeInstructionsDismissed = result.dismissedInstructions[DocModeType.segmentedDocument.name] ?? false

        let resultDict = [
            "images" : images,
            "crop": result.cropEnabled,
            "timerEnabled" : result.timerEnabled,
            "singleDocumentModeInstructionsDismissed": singleDocumentModeInstructionsDismissed,
            "multiDocumentModeInstructionsDismissed": multiDocumentModeInstructionsDismissed,
            "segmentedDocumentModeInstructionsDismissed": segmentedDocumentModeInstructionsDismissed
        ] as [String : Any]

        _call?.resolve(resultDict)
        _call = nil
    }

    public func klippaScannerDidCancel() {
        _call?.reject(E_CANCELED)
        _call = nil
    }

    public func klippaScannerDidFailWithError(error: Error) {
        _call?.reject(error.localizedDescription, E_ERROR, error)
        _call = nil
    }

}

