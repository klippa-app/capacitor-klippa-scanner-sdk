package com.klippa.capacitorscanner

import androidx.activity.result.ActivityResult
import com.getcapacitor.JSObject
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.ActivityCallback
import com.getcapacitor.annotation.CapacitorPlugin
import com.klippa.scanner.ScannerFinishedReason
import com.klippa.scanner.ScannerSession
import com.klippa.scanner.ScannerSession.Companion.KLIPPA_ERROR
import com.klippa.scanner.ScannerSession.Companion.KLIPPA_RESULT
import com.klippa.scanner.model.Instructions
import com.klippa.scanner.model.KlippaCameraModes
import com.klippa.scanner.model.KlippaDPI
import com.klippa.scanner.model.KlippaDocumentMode
import com.klippa.scanner.model.KlippaError
import com.klippa.scanner.model.KlippaImageColor
import com.klippa.scanner.model.KlippaMultipleDocumentMode
import com.klippa.scanner.model.KlippaObjectDetectionModel
import com.klippa.scanner.model.KlippaOutputFormat
import com.klippa.scanner.model.KlippaPageFormat
import com.klippa.scanner.model.KlippaScannerResult
import com.klippa.scanner.model.KlippaSegmentedDocumentMode
import com.klippa.scanner.model.KlippaSingleDocumentMode
import com.klippa.scanner.model.KlippaSize
import com.klippa.scanner.storage.KlippaStorage
import org.json.JSONArray
import org.json.JSONObject

@CapacitorPlugin(name = "KlippaScannerSDKPlugin")
class KlippaScannerSDKPlugin : Plugin() {

    companion object {
        private const val E_ACTIVITY_DOES_NOT_EXIST = "E_ACTIVITY_DOES_NOT_EXIST"
        private const val E_MISSING_LICENSE = "E_MISSING_LICENSE"
        private const val E_FAILED_TO_SHOW_SESSION = "E_FAILED_TO_SHOW_SESSION"
        private const val E_CANCELED = "E_CANCELED"
    }

    private var _call: PluginCall? = null

    data object UnknownError: KlippaError {
        private fun readResolve(): Any = UnknownError
        override fun message(): String = "Unknown Error"
    }

    @PluginMethod
    fun purge(call: PluginCall) {
        activity?.let { 
            KlippaStorage.purge(it)
            call.resolve()
        } ?: run {
            call.reject("Activity doesn't exist", E_ACTIVITY_DOES_NOT_EXIST)
        }
    }

    @PluginMethod
    fun getCameraResult(call: PluginCall) {
        val config: JSONObject = call.data

        val license = config.getStringOrNull("license") ?: run {
            call.reject("Missing license", E_MISSING_LICENSE)
            return
        }

        activity?.let { activity ->
            try {
                val scannerSession = ScannerSession(license)

                // Global options
                config.getBooleanOrNull("defaultCrop")?.let {
                    scannerSession.menu.isCropEnabled = it
                }

                config.getIntOrNull("imageMaxWidth")?.let {
                    scannerSession.imageAttributes.resolutionMaxWidth = it
                }

                config.getIntOrNull("imageMaxHeight")?.let {
                    scannerSession.imageAttributes.resolutionMaxHeight = it
                }

                config.getIntOrNull("imageMaxQuality")?.let {
                    scannerSession.imageAttributes.outputQuality = it
                }

                config.getDoubleOrNull("previewDuration")?.let {
                    scannerSession.durations.previewDuration = it
                }

                // Model setup
                config.getJsonObjectOrNull("model")?.let { model ->
                    val fileName = model.getStringOrNull("fileName")
                    val modelLabels = model.getStringOrNull("modelLabels")

                    if (!fileName.isNullOrBlank() && !modelLabels.isNullOrBlank()) {
                        val objectDetectionModel = KlippaObjectDetectionModel().apply {
                            modelName = fileName
                            this.modelLabels = modelLabels
                        }
                        scannerSession.objectDetectionModel = objectDetectionModel
                    }
                }

                // Timer setup
                config.getJsonObjectOrNull("timer")?.let { timer ->
                    timer.getBooleanOrNull("allowed")?.let {
                        scannerSession.menu.allowTimer = it
                    }
                    
                    timer.getBooleanOrNull("enabled")?.let {
                        scannerSession.menu.isTimerEnabled = it
                    }
                    
                    timer.getDoubleOrNull("duration")?.let {
                        scannerSession.durations.timerDuration = it
                    }
                }

                // Crop padding setup
                config.getJsonObjectOrNull("cropPadding")?.let { cropPadding ->
                    val width = cropPadding.getIntOrNull("width") ?: 0
                    val height = cropPadding.getIntOrNull("height") ?: 0
                    scannerSession.imageAttributes.cropPadding = KlippaSize(width, height)
                }

                // Success setup
                config.getJsonObjectOrNull("success")?.let { success ->
                    success.getDoubleOrNull("previewDuration")?.let {
                        scannerSession.durations.successPreviewDuration = it
                    }
                }

                // Shutter button setup
                config.getJsonObjectOrNull("shutterButton")?.let { shutterButton ->
                    shutterButton.getBooleanOrNull("allowShutterButton")?.let {
                        scannerSession.shutterButton.allowShutterButton = it
                    }
                    
                    shutterButton.getBooleanOrNull("hideShutterButton")?.let {
                        scannerSession.shutterButton.hideShutterButton = it
                    }
                }

                // Storage and output
                config.getStringOrNull("storagePath")?.let {
                    scannerSession.imageAttributes.outputDirectory = it
                }

                config.getStringOrNull("outputFilename")?.let {
                    scannerSession.imageAttributes.outputFileName = it
                }

                // Default color
                config.getStringOrNull("defaultColor")?.let {
                    when (it) {
                        "original" -> scannerSession.imageAttributes.imageColorMode = KlippaImageColor.ORIGINAL
                        "enhanced" -> scannerSession.imageAttributes.imageColorMode = KlippaImageColor.ENHANCED
                        "grayscale" -> scannerSession.imageAttributes.imageColorMode = KlippaImageColor.GRAYSCALE
                        "blackAndWhite" -> scannerSession.imageAttributes.imageColorMode = KlippaImageColor.BLACK_AND_WHITE
                    }
                }

                // Output format
                config.getStringOrNull("outputFormat")?.let {
                    when (it) {
                        "jpeg" -> scannerSession.imageAttributes.outputFormat = KlippaOutputFormat.JPEG
                        "pdfSingle" -> scannerSession.imageAttributes.outputFormat = KlippaOutputFormat.PDF_SINGLE
                        "pdfMerged" -> scannerSession.imageAttributes.outputFormat = KlippaOutputFormat.PDF_MERGED
                        "png" -> scannerSession.imageAttributes.outputFormat = KlippaOutputFormat.PNG
                    }
                }

                config.getIntOrNull("imageLimit")?.let {
                    scannerSession.imageAttributes.imageLimit = it
                }

                config.getIntOrNull("imageMovingSensitivityAndroid")?.let {
                    scannerSession.imageAttributes.imageMovingSensitivity = it
                }

                config.getBooleanOrNull("performOnDeviceOCR")?.let {
                    scannerSession.imageAttributes.performOnDeviceOCR = it
                }

                config.getBooleanOrNull("storeImagesToCameraRoll")?.let {
                    scannerSession.imageAttributes.storeImagesToGallery = it
                }

                // Page format
                config.getStringOrNull("pageFormat")?.let {
                    when (it) {
                        "off" -> scannerSession.imageAttributes.pageFormat = KlippaPageFormat.OFF
                        "a3" -> scannerSession.imageAttributes.pageFormat = KlippaPageFormat.A3
                        "a4" -> scannerSession.imageAttributes.pageFormat = KlippaPageFormat.A4
                        "a5" -> scannerSession.imageAttributes.pageFormat = KlippaPageFormat.A5
                        "a6" -> scannerSession.imageAttributes.pageFormat = KlippaPageFormat.A6
                        "b4" -> scannerSession.imageAttributes.pageFormat = KlippaPageFormat.B4
                        "b5" -> scannerSession.imageAttributes.pageFormat = KlippaPageFormat.B5
                        "letter" -> scannerSession.imageAttributes.pageFormat = KlippaPageFormat.LETTER
                    }
                }

                // DPI setting
                config.getStringOrNull("dpi")?.let {
                    when (it) {
                        "auto" -> scannerSession.imageAttributes.dpi = KlippaDPI.AUTO
                        "dpi200" -> scannerSession.imageAttributes.dpi = KlippaDPI.DPI_200
                        "dpi300" -> scannerSession.imageAttributes.dpi = KlippaDPI.DPI_300
                    }
                }

                // Brightness thresholds
                config.getDoubleOrNull("brightnessLowerThreshold")?.let {
                    scannerSession.imageAttributes.brightnessLowerThreshold = it
                }

                config.getDoubleOrNull("brightnessUpperThreshold")?.let {
                    scannerSession.imageAttributes.brightnessUpperThreshold = it
                }

                // Menu options
                config.getBooleanOrNull("shouldGoToReviewScreenWhenImageLimitReached")?.let {
                    scannerSession.menu.shouldGoToReviewScreenWhenImageLimitReached = it
                }

                config.getBooleanOrNull("userShouldAcceptResultToContinue")?.let {
                    scannerSession.menu.userShouldAcceptResultToContinue = it
                }

                config.getBooleanOrNull("userCanRotateImage")?.let {
                    scannerSession.menu.userCanRotateImage = it
                }

                config.getBooleanOrNull("userCanCropManually")?.let {
                    scannerSession.menu.userCanCropManually = it
                }

                config.getBooleanOrNull("userCanChangeColorSetting")?.let {
                    scannerSession.menu.userCanChangeColorSetting = it
                }

                config.getBooleanOrNull("userCanPickMediaFromStorage")?.let {
                    scannerSession.menu.userCanPickMediaFromStorage = it
                }

                config.getBooleanOrNull("shouldGoToReviewScreenOnFinishPressed")?.let {
                    scannerSession.menu.shouldGoToReviewScreenOnFinishPressed = it
                }

                // Camera modes setup
                setupCameraModes(config, scannerSession)

                val intent = scannerSession.getIntent(activity)
                _call = call
                startActivityForResult(call, intent, "klippaScannerResult")

            } catch (e: Exception) {
                call.reject(
                    "Could not launch scanner session: ${e.message}",
                    E_FAILED_TO_SHOW_SESSION
                )
            }
        } ?: run {
            call.reject("Activity doesn't exist", E_ACTIVITY_DOES_NOT_EXIST)
        }
    }

    private fun setupCameraModes(config: JSONObject, scannerSession: ScannerSession) {
        val modes: MutableList<KlippaDocumentMode> = mutableListOf()

        config.getJsonObjectOrNull("cameraModeSingle")?.let { cameraModeSingle ->
            val singleDocumentMode = KlippaSingleDocumentMode()
            cameraModeSingle.getStringOrNull("name")?.let { name ->
                singleDocumentMode.name = name
            }
            cameraModeSingle.getStringOrNull("message")?.let { message ->
                singleDocumentMode.instructions = Instructions(singleDocumentMode.name, message)
            }
            modes.add(singleDocumentMode)
        }

        config.getJsonObjectOrNull("cameraModeMulti")?.let { cameraModeMulti ->
            val multiDocumentMode = KlippaMultipleDocumentMode()
            cameraModeMulti.getStringOrNull("name")?.let { name ->
                multiDocumentMode.name = name
            }
            cameraModeMulti.getStringOrNull("message")?.let { message ->
                multiDocumentMode.instructions = Instructions(multiDocumentMode.name, message)
            }
            modes.add(multiDocumentMode)
        }

        config.getJsonObjectOrNull("cameraModeSegmented")?.let { cameraModeSegmented ->
            val segmentedDocumentMode = KlippaSegmentedDocumentMode()
            cameraModeSegmented.getStringOrNull("name")?.let { name ->
                segmentedDocumentMode.name = name
            }
            cameraModeSegmented.getStringOrNull("message")?.let { message ->
                segmentedDocumentMode.instructions = Instructions(segmentedDocumentMode.name, message)
            }
            modes.add(segmentedDocumentMode)
        }

        if (modes.isNotEmpty()) {
            var index = 0
            config.getIntOrNull("startingIndex")?.let {
                index = it
            }
            val cameraModes = KlippaCameraModes(
                modes = modes,
                startingIndex = index
            )
            scannerSession.cameraModes = cameraModes
        }
    }

    @Suppress("UNUSED")
    @ActivityCallback
    private fun klippaScannerResult(call: PluginCall, result: ActivityResult) {
        val reason = ScannerFinishedReason.mapResultCode(result.resultCode)

        val data = result.data

        when (reason) {
            ScannerFinishedReason.FINISHED -> {
                val result = data?.serializable<KlippaScannerResult>(KLIPPA_RESULT) ?: run {
                    klippaScannerDidFailWithError(UnknownError)
                    return
                }
                klippaScannerDidFinishScanningWithResult(result)
            }
            ScannerFinishedReason.ERROR -> {
                val error = data?.serializable<KlippaError>(KLIPPA_ERROR) ?: run {
                    klippaScannerDidFailWithError(UnknownError)
                    return
                }
                klippaScannerDidFailWithError(error)
            }
            ScannerFinishedReason.CANCELED -> {
                klippaScannerDidCancel()
            }
            else -> klippaScannerDidFailWithError(UnknownError)
        }

    }

    private fun klippaScannerDidFinishScanningWithResult(result: KlippaScannerResult) {
        val images: MutableList<Map<String, String>> = mutableListOf()

        for (image in result.results) {
            val imageDict = mapOf("filePath" to image.location)
            images.add(imageDict)
        }

        val cropEnabled: Boolean = result.cropEnabled
        val timerEnabled: Boolean = result.timerEnabled

        val singleDocumentModeInstructionsDismissed = result.dismissedInstructions["SINGLE_DOCUMENT"] ?: false
        val multiDocumentModeInstructionsDismissed = result.dismissedInstructions["MULTIPLE_DOCUMENT"] ?: false
        val segmentedDocumentModeInstructionsDismissed = result.dismissedInstructions["SEGMENTED_DOCUMENT"] ?: false

        val imagesAsJSON = JSONArray(images)

        val ret = JSObject()
        ret.put("images", imagesAsJSON)
        ret.put("crop", cropEnabled)
        ret.put("timerEnabled", timerEnabled)
        ret.put("singleDocumentModeInstructionsDismissed", singleDocumentModeInstructionsDismissed)
        ret.put("multiDocumentModeInstructionsDismissed", multiDocumentModeInstructionsDismissed)
        ret.put("segmentedDocumentModeInstructionsDismissed", segmentedDocumentModeInstructionsDismissed)

        _call?.resolve(ret)
        _call = null
    }

    private fun klippaScannerDidFailWithError(error: KlippaError) {
        _call?.reject("Scanner canceled with error: ${error.message()}", E_CANCELED)
        _call = null
    }

    private fun klippaScannerDidCancel() {
        _call?.reject("Scanner was canceled", E_CANCELED)
        _call = null
    }

}
