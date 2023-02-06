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

    // MARK: Setup Timer
    fileprivate func setupTimer(_ config: [AnyHashable : Any]) {
        guard let timer = config["timer"] as? [String: Any] else {
            return
        }

        if let isTimerAllowed = timer["allowed"] as? Bool {
            KlippaScanner.setup.allowTimer = isTimerAllowed
        }

        if let isTimerEnabled = timer["enabled"] as? Bool {
            KlippaScanner.setup.isTimerEnabled = isTimerEnabled
        }

        if let timerDuration = timer["duration"] as? Double {
            KlippaScanner.setup.timerDuration = timerDuration
        }
    }

    //MARK: Setup Colors
    fileprivate func setupColors(_ config: [AnyHashable : Any]) {
        if let primaryColor = config["primaryColor"] as? String {
            KlippaScanner.setup.primaryColor = hexStringToUIColor(hex: primaryColor)
        }

        if let accentColor = config["accentColor"] as? String {
            KlippaScanner.setup.accentColor = hexStringToUIColor(hex: accentColor)
        }

        if let overlayColor = config["overlayColor"] as? String {
            KlippaScanner.setup.overlayColor = hexStringToUIColor(hex: overlayColor)
        }

        if let overlayColorAlpha = config["overlayColorAlpha"] as? CGFloat {
            KlippaScanner.setup.overlayColorAlpha = overlayColorAlpha
        }

        if let warningBackgroundColor = config["warningBackgroundColor"] as? String {
            KlippaScanner.setup.warningBackgroundColor = hexStringToUIColor(hex: warningBackgroundColor)
        }

        if let warningTextColor = config["warningTextColor"] as? String {
            KlippaScanner.setup.warningTextColor = hexStringToUIColor(hex: warningTextColor)
        }

        if let iconEnabledColor = config["iconEnabledColor"] as? String {
            KlippaScanner.setup.iconEnabledColor = hexStringToUIColor(hex: iconEnabledColor)
        }

        if let iconDisabledColor = config["iconDisabledColor"] as? String {
            KlippaScanner.setup.iconDisabledColor = hexStringToUIColor(hex: iconDisabledColor)
        }

        if let reviewIconColor = config["reviewIconColor"] as? String {
            KlippaScanner.setup.reviewIconColor = hexStringToUIColor(hex: reviewIconColor)
        }

        if let defaultColor = config["defaultColor"] as? String {
            KlippaScanner.setup.defaultImageColor = defaultColor
        }
    }

    // MARK: Setup Model
    fileprivate func setupModel(_ config: [AnyHashable : Any]) {
        if let model = config["model"] as? [String: String] {
            if let modelFile = model["fileName"], let modelLabels = model["modelLabels"] {
                KlippaScanner.setup.set(modelName: modelFile, modelLabelsName: modelLabels)
            }
        }
    }

    //MARK: Setup Messages
    fileprivate func setupMessages(_ config: [AnyHashable : Any]) {
        if let imageTooBrightMessage = config["imageTooBrightMessage"] as? String {
            KlippaScanner.setup.imageTooBrightMessage = imageTooBrightMessage
        }

        if let imageTooDarkMessage = config["imageTooDarkMessage"] as? String {
            KlippaScanner.setup.imageTooDarkMessage = imageTooDarkMessage
        }

        if let imageColorOriginalText = config["imageColorOriginalText"] as? String {
            KlippaScanner.setup.imageColorOriginalText = imageColorOriginalText
        }

        if let imageColorGrayscaleText = config["imageColorGrayscaleText"] as? String {
            KlippaScanner.setup.imageColorGrayscaleText = imageColorGrayscaleText
        }

        if let imageColorEnhancedText = config["imageColorEnhancedText"] as? String {
            KlippaScanner.setup.imageColorEnhancedText = imageColorEnhancedText
        }

        if let imageLimitReachedMessage = config["imageLimitReachedMessage"] as? String {
            KlippaScanner.setup.imageLimitReachedMessage = imageLimitReachedMessage
        }

        if let deleteButtonText = config["deleteButtonText"] as? String {
            KlippaScanner.setup.deleteButtonText = deleteButtonText
        }

        if let retakeButtonText = config["retakeButtonText"] as? String {
            KlippaScanner.setup.retakeButtonText = retakeButtonText
        }

        if let cancelButtonText = config["cancelButtonText"] as? String {
            KlippaScanner.setup.cancelButtonText = cancelButtonText
        }

        if let cancelAndDeleteImagesButtonText = config["cancelAndDeleteImagesButtonText"] as? String {
            KlippaScanner.setup.cancelAndDeleteImagesButtonText = cancelAndDeleteImagesButtonText
        }

        if let cancelConfirmationMessage = config["cancelConfirmationMessage"] as? String {
            KlippaScanner.setup.cancelConfirmationMessage = cancelConfirmationMessage
        }

        if let moveCloserMessage = config["moveCloserMessage"] as? String {
            KlippaScanner.setup.moveCloserMessage = moveCloserMessage
        }

        if let imageMovingMessage = config["imageMovingMessage"] as? String {
            KlippaScanner.setup.imageMovingMessage = imageMovingMessage
        }

        if let orientationWarningMessage = config["orientationWarningMessage"] as? String {
            KlippaScanner.setup.orientationWarningMessage = orientationWarningMessage
        }
    }

    // MARK: Setup Shutter Button
    fileprivate func setupShutterButton(_ config: [AnyHashable : Any]) {
        if let shutterButton = config["shutterButton"] as? [String: Bool] {
            if let allowShutterButton = shutterButton["allowShutterButton"] {
                KlippaScanner.setup.allowShutterButton = allowShutterButton
            }

            if let hideShutterButton = shutterButton["hideShutterButton"] {
                KlippaScanner.setup.hideShutterButton = hideShutterButton
            }
        }
    }

    // MARK: Setup Image Settings
    fileprivate func setupImageSettings(_ config: [AnyHashable : Any]) {
        if let imageMaxWidth = config["imageMaxWidth"] as? CGFloat {
            KlippaScanner.setup.imageMaxWidth = imageMaxWidth
        }

        if let imageMaxHeight = config["imageMaxHeight"] as? CGFloat {
            KlippaScanner.setup.imageMaxHeight = imageMaxHeight
        }

        if let imageMaxQuality = config["imageMaxQuality"] as? CGFloat {
            KlippaScanner.setup.imageMaxQuality = imageMaxQuality
        }

        if let cropPadding = config["cropPadding"] as? [String: Int] {
            let width = cropPadding["width"] ?? 0
            let height = cropPadding["height"] ?? 0

            KlippaScanner.setup.set(cropPadding: CGSize(width:  width, height: height))
        }

        if let imageLimit = config["imageLimit"] as? Int {
            KlippaScanner.setup.imageLimit = imageLimit
        }

        if let storeImagesToCameraRoll = config["storeImagesToCameraRoll"] as? Bool {
            KlippaScanner.setup.storeImagesToCameraRoll = storeImagesToCameraRoll
        }
    }

    // MARK: Setup Menu
    fileprivate func setupMenu(_ config: [AnyHashable : Any]) {
        if let allowMultipleDocumentsMode = config["allowMultipleDocuments"] as? Bool {
            KlippaScanner.setup.allowMultipleDocumentsMode = allowMultipleDocumentsMode
        }

        if let isMultipleDocumentsModeEnabled = config["defaultMultipleDocuments"] as? Bool {
            KlippaScanner.setup.isMultipleDocumentsModeEnabled = isMultipleDocumentsModeEnabled
        }

        if let isCropEnabled = config["defaultCrop"] as? Bool {
            KlippaScanner.setup.isCropEnabled = isCropEnabled
        }

        if let shouldGoToReviewScreenWhenImageLimitReached = config["shouldGoToReviewScreenWhenImageLimitReached"] as? Bool {
            KlippaScanner.setup.shouldGoToReviewScreenWhenImageLimitReached = shouldGoToReviewScreenWhenImageLimitReached
        }

        if let userCanRotateImage = config["userCanRotateImage"] as? Bool {
            KlippaScanner.setup.userCanRotateImage = userCanRotateImage
        }

        if let userCanCropManually = config["userCanCropManually"] as? Bool {
            KlippaScanner.setup.userCanCropManually = userCanCropManually
        }

        if let userCanChangeColorSetting = config["userCanChangeColorSetting"] as? Bool {
            KlippaScanner.setup.userCanChangeColorSetting = userCanChangeColorSetting
        }


        if let isViewFinderEnabled = config["isViewFinderEnabled"] as? Bool {
            KlippaScanner.setup.isViewFinderEnabled = isViewFinderEnabled
        }

        if let imageMovingSensitivity = config["imageMovingSensitivityIOS"] as? CGFloat {
            KlippaScanner.setup.imageMovingSensitivity = imageMovingSensitivity
        }
    }

    // MARK: Setup Success
    fileprivate func setupSuccess(_ config: [AnyHashable : Any]) {
        if let previewDuration = config["previewDuration"] as? Double {
            KlippaScanner.setup.previewDuration = previewDuration
        }

        guard let success = config["success"] as? [String: Any] else {
            return
        }

        if let successPreviewDuration = success["previewDuration"] as? Double {
            KlippaScanner.setup.successPreviewDuration = successPreviewDuration
        }

        if let successMessage = success["message"] as? String {
            KlippaScanner.setup.successMessage = successMessage
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

        KlippaScanner.setup.set(license: license)

        setupMenu(config)

        setupImageSettings(config)

        setupTimer(config)

        setupSuccess(config)

        setupShutterButton(config)

        setupMessages(config)

        setupColors(config)

        setupModel(config)

        _call = call

        DispatchQueue.main.async {
            let rootViewController = UIApplication.shared.windows.last!.rootViewController!

            let scannerViewController = ImageScannerController()
            scannerViewController.imageScannerDelegate = self
            scannerViewController.modalPresentationStyle = .fullScreen
            rootViewController.present(scannerViewController, animated: false)
        }
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
extension KlippaScannerSDKPlugin: ImageScannerControllerDelegate {

    public func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResult result: ImageScannerResult) {

        var images: [[String: String]] = []
        for image in result.images {
            let imageDict = ["filePath" : image.path]
            images.append(imageDict)
        }

        let resultDict = [
            "images" : images,
            "multipleDocuments" : result.multipleDocumentsModeEnabled,
            "crop": result.cropEnabled,
            "timerEnabled" : result.timerEnabled
        ] as [String : Any]

        _call?.resolve(resultDict)
        _call = nil

    }

    public func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        _call?.reject(E_CANCELED)
    }

    public func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        _call?.reject(error.localizedDescription, E_ERROR, error)
    }
}

