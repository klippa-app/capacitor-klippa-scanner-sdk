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

    private var _call: CAPPluginCall? = nil

    private var singleDocumentModeInstructionsDismissed = false
    private var multiDocumentModeInstructionsDismissed = false
    private var segmentedDocumentModeInstructionsDismissed = false

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

    //MARK: Setup Colors
    private func setupColors(_ config: [AnyHashable : Any], _ builder: KlippaScannerBuilder) {
        if let primaryColor = config["primaryColor"] as? String {
            builder.klippaColors.primaryColor = hexStringToUIColor(hex: primaryColor)
        }

        if let accentColor = config["accentColor"] as? String {
            builder.klippaColors.accentColor = hexStringToUIColor(hex: accentColor)
        }

        if let overlayColor = config["overlayColor"] as? String {
            builder.klippaColors.overlayColor = hexStringToUIColor(hex: overlayColor)
        }

        if let overlayColorAlpha = config["overlayColorAlpha"] as? CGFloat {
            builder.klippaColors.overlayColorAlpha = overlayColorAlpha
        }

        if let warningBackgroundColor = config["warningBackgroundColor"] as? String {
            builder.klippaColors.warningBackgroundColor = hexStringToUIColor(hex: warningBackgroundColor)
        }

        if let warningTextColor = config["warningTextColor"] as? String {
            builder.klippaColors.warningTextColor = hexStringToUIColor(hex: warningTextColor)
        }

        if let iconEnabledColor = config["iconEnabledColor"] as? String {
            builder.klippaColors.iconEnabledColor = hexStringToUIColor(hex: iconEnabledColor)
        }

        if let iconDisabledColor = config["iconDisabledColor"] as? String {
            builder.klippaColors.iconDisabledColor = hexStringToUIColor(hex: iconDisabledColor)
        }

        if let reviewIconColor = config["reviewIconColor"] as? String {
            builder.klippaColors.reviewIconColor = hexStringToUIColor(hex: reviewIconColor)
        }

        if let defaultColor = config["defaultColor"] as? String {
            let color = switch defaultColor {
            case "grayscale":
                KlippaImageColor.grayscale
            case "enhanced":
                KlippaImageColor.enhanced
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

            if let instructions = singleCameraMode["message"] {
                single.instructions = Instructions(
                    message: instructions,
                    dismissHandler: { [weak self] in
                        self?.singleDocumentModeInstructionsDismissed = true
                    }
                )
            }
            modes.append(single)
        }

        if let multiCameraMode = config["cameraModeMulti"] as? [String: String] {
            let multi = KlippaMultipleDocumentMode()

            if let name = multiCameraMode["name"] {
                multi.name = name
            }

            if let instructions = multiCameraMode["message"] {
                multi.instructions = Instructions(
                    message: instructions,
                    dismissHandler: { [weak self] in
                        self?.multiDocumentModeInstructionsDismissed = true
                    }
                )
            }
            modes.append(multi)
        }

        if let segmentedCameraMode = config["cameraModeSegmented"] as? [String: String] {
            let segmented = KlippaSegmentedDocumentMode()

            if let name = segmentedCameraMode["name"] {
                segmented.name = name
            }

            if let instructions = segmentedCameraMode["message"] {
                segmented.instructions = Instructions(
                    message: instructions,
                    dismissHandler: { [weak self] in
                        self?.multiDocumentModeInstructionsDismissed = true
                    }
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

        if let cancelConfirmationMessage = config["cancelConfirmationMessage"] as? String {
            builder.klippaMessages.cancelConfirmationMessage = cancelConfirmationMessage
        }

        if let moveCloserMessage = config["moveCloserMessage"] as? String {
            builder.klippaMessages.moveCloserMessage = moveCloserMessage
        }

        if let imageMovingMessage = config["imageMovingMessage"] as? String {
            builder.klippaMessages.imageMovingMessage = imageMovingMessage
        }

        if let orientationWarningMessage = config["orientationWarningMessage"] as? String {
            builder.klippaMessages.orientationWarningMessage = orientationWarningMessage
        }
    }

    // MARK: Setup Shutter Button
    private func setupShutterButton(_ config: [AnyHashable : Any], _ builder: KlippaScannerBuilder) {
        if let shutterButton = config["shutterButton"] as? [String: Bool] {
            if let allowShutterButton = shutterButton["allowShutterButton"] {
                builder.klippaShutterbutton.allowShutterButton = allowShutterButton
            }

            if let hideShutterButton = shutterButton["hideShutterButton"] {
                builder.klippaShutterbutton.hideShutterButton = hideShutterButton
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

        if let cropPadding = config["cropPadding"] as? [String: Int] {
            let width = cropPadding["width"] ?? 0
            let height = cropPadding["height"] ?? 0

            builder.klippaImageAttributes.cropPadding = CGSize(width: width, height: height)
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
    }

    // MARK: Setup Menu
    private func setupMenu(_ config: [AnyHashable : Any], _ builder: KlippaScannerBuilder) {
        if let isCropEnabled = config["defaultCrop"] as? Bool {
            builder.klippaMenu.isCropEnabled = isCropEnabled
        }

        if let shouldGoToReviewScreenWhenImageLimitReached = config["shouldGoToReviewScreenWhenImageLimitReached"] as? Bool {
            builder.klippaMenu.shouldGoToReviewScreenWhenImageLimitReached = shouldGoToReviewScreenWhenImageLimitReached
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
            call.reject("CameraConfig was not supplied correctly.")
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

            switch result {
            case .success(let controller):
                self.startScanner(controller: controller)
            case .failure(let error):
                call.reject(error.localizedDescription, self.E_ERROR, error)
            }
        }
    }

    private func startScanner(controller: UIViewController) {
        let rootViewController = UIApplication.shared.windows.last!.rootViewController!
        controller.modalPresentationStyle = .fullScreen
        rootViewController.show(controller, sender: self)
    }

    // MARK: Hex to UIColor
    private func hexStringToUIColor(hex: String) -> UIColor {
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
        for image in result.images {
            let imageDict = ["filePath" : image.path]
            images.append(imageDict)
        }

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
    }

    public func klippaScannerDidFailWithError(error: Error) {
        _call?.reject(error.localizedDescription, E_ERROR, error)
    }

}

