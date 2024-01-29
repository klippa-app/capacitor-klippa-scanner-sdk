package com.klippa.capacitorscanner

import android.util.Size
import com.getcapacitor.JSObject
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin
import com.klippa.scanner.KlippaScannerBuilder
import com.klippa.scanner.KlippaScannerListener
import com.klippa.scanner.model.Instructions
import com.klippa.scanner.model.KlippaCameraModes
import com.klippa.scanner.model.KlippaDocumentMode
import com.klippa.scanner.model.KlippaImageColor
import com.klippa.scanner.model.KlippaMultipleDocumentMode
import com.klippa.scanner.model.KlippaObjectDetectionModel
import com.klippa.scanner.model.KlippaScannerResult
import com.klippa.scanner.model.KlippaSegmentedDocumentMode
import com.klippa.scanner.model.KlippaSingleDocumentMode
import org.json.JSONArray
import org.json.JSONObject

@CapacitorPlugin(name = "KlippaScannerSDKPlugin")
class KlippaScannerSDKPlugin : Plugin() {

    private var _call: PluginCall? = null

    private var singleDocumentModeInstructionsDismissed = false
    private var multiDocumentModeInstructionsDismissed = false
    private var segmentedDocumentModeInstructionsDismissed = false

    private val listener = object: KlippaScannerListener {

        override fun klippaScannerDidCancel() {
            _call?.reject("Scanner was canceled.", E_CANCELED)
            _call = null
        }

        override fun klippaScannerDidFailWithException(exception: Exception) {
            _call?.reject("Scanner was canceled with error: $exception", E_CANCELED)
            _call = null
        }

        override fun klippaScannerDidFinishScanningWithResult(result: KlippaScannerResult) {

            val images: MutableList<Map<String, String>> = mutableListOf()
            for (image in result.images) {
                val imageDict = mapOf("filePath" to image.filePath)
                images.add(imageDict)
            }
            val imagesAsJSON = JSONArray(images)

            val ret = JSObject()
            ret.put("images", imagesAsJSON)
            ret.put("crop", result.cropEnabled)
            ret.put("timerEnabled", result.timerEnabled)
            ret.put("color", result.defaultImageColor.name)
            ret.put("singleDocumentModeInstructionsDismissed", singleDocumentModeInstructionsDismissed)
            ret.put("multiDocumentModeInstructionsDismissed", multiDocumentModeInstructionsDismissed)
            ret.put("segmentedDocumentModeInstructionsDismissed", segmentedDocumentModeInstructionsDismissed)

            _call?.resolve(ret)
            _call = null
        }
    }

    @PluginMethod
    fun getCameraResult(call: PluginCall) {
        val config: JSONObject = call.data

        val license = config.getStringOrNull("license") ?: run {
            call.reject("Missing license", E_MISSING_LICENSE)
            return
        }

        val builder = KlippaScannerBuilder(
            listener = listener,
            license = license
        )

        setupImage(config, builder)

        setupModel(config, builder)

        setupTimer(config, builder)

        setupSuccess(config, builder)

        setupShutterButton(config, builder)

        setupColors(config, builder)

        setupMessages(config, builder)

        setupMenu(config, builder)

        setupCameraModes(config, builder)

        _call = call
        builder.startScanner(context)
    }

    private fun setupColors(config: JSONObject, builder: KlippaScannerBuilder) {
        config.getStringOrNull("defaultColor")?.let {
            builder.colors.imageColorMode = when (it) {
                "original" -> KlippaImageColor.ORIGINAL
                "enhanced" -> KlippaImageColor.ENHANCED
                "grayscale" -> KlippaImageColor.GRAYSCALE
                else -> KlippaImageColor.ORIGINAL
            }
        }
    }

    private fun setupMessages(config: JSONObject, builder: KlippaScannerBuilder) {
        config.getStringOrNull("imageLimitReachedMessage")?.let {
            builder.messages.imageLimitReached = it
        }

        config.getStringOrNull("cancelConfirmationMessage")?.let {
            builder.messages.cancelConfirmationMessage = it
        }

        config.getStringOrNull("orientationWarningMessage")?.let {
            builder.messages.orientationWarningMessage = it
        }

        config.getStringOrNull("imageMovingMessage")?.let {
            builder.messages.imageMovingMessage = it
        }

        config.getStringOrNull("moveCloserMessage")?.let {
            builder.messages.moveCloserMessage = it
        }

        config.getStringOrNull("cancelAndDeleteImagesButtonText")?.let {
            builder.buttonTexts.cancelAndDeleteImagesButtonText = it
        }

        config.getStringOrNull("cancelButtonText")?.let {
            builder.buttonTexts.cancelButtonText = it
        }

        config.getStringOrNull("retakeButtonText")?.let {
            builder.buttonTexts.retakeButtonText = it
        }

        config.getStringOrNull("deleteButtonText")?.let {
            builder.buttonTexts.deleteButtonText = it
        }
    }

    private fun setupImage(config: JSONObject, builder: KlippaScannerBuilder) {

        config.getIntOrNull("imageMaxWidth")?.let {
            builder.imageAttributes.resolutionMaxWidth = it
        }

        config.getIntOrNull("imageMaxHeight")?.let {
            builder.imageAttributes.resolutionMaxHeight = it
        }

        config.getIntOrNull("imageMaxQuality")?.let {
            builder.imageAttributes.outputQuality = it
        }

        config.getStringOrNull("outputFilename")?.let {
            builder.imageAttributes.outputFileName = it
        }

        config.getIntOrNull("imageMovingSensitivityAndroid")?.let {
            builder.imageAttributes.imageMovingSensitivity = it
        }

        config.getIntOrNull("imageLimit")?.let {
            builder.imageAttributes.imageLimit = it
        }

        config.getJsonObjectOrNull("cropPadding")?.let { cropPadding ->
            val width = cropPadding.getIntOrNull("width") ?: 0
            val height = cropPadding.getIntOrNull("height") ?: 0
            builder.imageAttributes.cropPadding = Size(width, height)
        }

        config.getStringOrNull("storagePath")?.let {
            builder.imageAttributes.outputDirectory = it
        }
    }

    private fun setupModel(config: JSONObject, builder: KlippaScannerBuilder) {
        config.getJsonObjectOrNull("model")?.let { model ->
            val modelName = model.getStringOrNull("fileName")
            val modelLabels = model.getStringOrNull("fileName")

            if (modelName.isNullOrBlank() || modelLabels.isNullOrBlank()) {
                return
            }

            builder.objectDetectionModel = KlippaObjectDetectionModel(
                modelName = modelName,
                modelLabels = modelLabels
            )
        }
    }

    private fun setupTimer(config: JSONObject, builder: KlippaScannerBuilder) {
        val timer = config.getJsonObjectOrNull("timer") ?: return

        timer.getBooleanOrNull("allowed")?.let {
            builder.menu.allowTimer = it
        }

        timer.getBooleanOrNull("enabled")?.let {
            builder.menu.allowTimer = it
        }

        timer.getDoubleOrNull("duration")?.let {
            builder.durations.timerDuration
        }
    }

    private fun setupSuccess(config: JSONObject, builder: KlippaScannerBuilder) {
        val success = config.getJsonObjectOrNull("success") ?: return

        success.getDoubleOrNull("previewDuration")?.let {
            builder.durations.successPreviewDuration = it
        }

        success.getStringOrNull("message")?.let {
            builder.messages.successMessage = it
        }

        config.getDoubleOrNull("previewDuration")?.let {
            builder.durations.previewDuration = it
        }
    }

    private fun setupShutterButton(config: JSONObject, builder: KlippaScannerBuilder) {
        val shutterButton = config.getJsonObjectOrNull("shutterButton") ?: return

        shutterButton.getBooleanOrNull("allowShutterButton")?.let {
            builder.shutterButton.allowShutterButton = it
        }

        shutterButton.getBooleanOrNull("hideShutterButton")?.let {
            builder.shutterButton.hideShutterButton = it
        }
    }

    private fun setupMenu(config: JSONObject, builder: KlippaScannerBuilder) {

        config.getBooleanOrNull("shouldGoToReviewScreenWhenImageLimitReached")?.let {
            builder.menu.shouldGoToReviewScreenWhenImageLimitReached = it
        }

        config.getBooleanOrNull("userCanRotateImage")?.let {
            builder.menu.userCanRotateImage = it
        }

        config.getBooleanOrNull("userCanCropManually")?.let {
            builder.menu.userCanCropManually = it
        }

        config.getBooleanOrNull("userCanChangeColorSetting")?.let {
            builder.menu.userCanChangeColorSetting = it
        }

        config.getBooleanOrNull("defaultCrop")?.let {
            builder.menu.isCropEnabled = it
        }

        config.getBooleanOrNull("storeImagesToCameraRoll")?.let {
            builder.imageAttributes.storeImagesToGallery = it
        }
    }

    private fun setupCameraModes(config: JSONObject, builder: KlippaScannerBuilder) {
        val modes = mutableListOf<KlippaDocumentMode>()

        config.getJsonObjectOrNull("cameraModeSingle")?.let { singleCameraMode ->
            val single = KlippaSingleDocumentMode()

            singleCameraMode.getStringOrNull("name")?.let {
                single.name = it
            }

            singleCameraMode.getStringOrNull("message")?.let {
                single.instructions = Instructions(
                    message = it,
                    dismissHandler = {
                        singleDocumentModeInstructionsDismissed = true
                    }
                )
            }

            modes.add(single)
        }

        config.getJsonObjectOrNull("cameraModeMulti")?.let { multiCameraMode ->
            val multi = KlippaMultipleDocumentMode()

            multiCameraMode.getStringOrNull("name")?.let {
                multi.name = it
            }

            multiCameraMode.getStringOrNull("message")?.let {
                multi.instructions = Instructions(
                    message = it,
                    dismissHandler = {
                        multiDocumentModeInstructionsDismissed = true
                    }
                )
            }

            modes.add(multi)
        }

        config.getJsonObjectOrNull("cameraModeSegmented")?.let { segmentedCameraMode ->
            val segmented = KlippaSegmentedDocumentMode()

            segmentedCameraMode.getStringOrNull("name")?.let {
                segmented.name = it
            }

            segmentedCameraMode.getStringOrNull("message")?.let {
                segmented.instructions = Instructions(
                    message = it,
                    dismissHandler = {
                        segmentedDocumentModeInstructionsDismissed = true
                    }
                )
            }

            modes.add(segmented)
        }


        if (modes.isEmpty()) {
            return
        }

        val startingIndex = config.getIntOrNull("startingIndex") ?: 0

        builder.cameraModes = KlippaCameraModes(
            modes = modes,
            startingIndex = startingIndex
        )

    }

    companion object {
        const val E_MISSING_LICENSE = "E_MISSING_LICENSE"
        const val E_CANCELED = "E_CANCELED"
    }


}
