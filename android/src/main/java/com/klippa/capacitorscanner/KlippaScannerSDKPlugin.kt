package com.klippa.capacitorscanner

import android.app.Activity
import android.content.Intent
import android.util.Size
import androidx.activity.result.ActivityResult
import com.getcapacitor.JSObject
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.ActivityCallback
import com.getcapacitor.annotation.CapacitorPlugin
import com.klippa.scanner.KlippaScanner
import com.klippa.scanner.`object`.Image
import org.json.JSONArray
import org.json.JSONObject

@CapacitorPlugin(name = "KlippaScannerSDKPlugin")
class KlippaScannerSDKPlugin : Plugin() {

    @PluginMethod
    fun getCameraResult(call: PluginCall) {
        val config: JSONObject = call.data

        if (config.has("license")) {
            KlippaScanner.license = config.getString("license")
        } else {
            call.reject("Missing license", E_MISSING_LICENSE)
            return
        }

        setupImage(config)

        setupModel(config)

        setupTimer(config)

        setupSuccess(config)

        setupShutterButton(config)

        setupColors(config)

        setupMessages(config)

        setupMenu(config)

        val intent = Intent(activity, KlippaScanner::class.java)
        startActivityForResult(call, intent, "startKlippaScannerForResult")
    }

    private fun setupColors(config: JSONObject) {

        if (config.has("defaultColor")) {
            val color = when (config.getString("defaultColor")) {
                "original" -> KlippaScanner.DefaultColor.ORIGINAL
                "enhanced" -> KlippaScanner.DefaultColor.ENHANCED
                "grayscale" -> KlippaScanner.DefaultColor.GRAYSCALE
                else -> KlippaScanner.DefaultColor.ORIGINAL
            }

            KlippaScanner.colors.defaultColor = color
        }
    }

    private fun setupMessages(config: JSONObject) {
        if (config.has("imageLimitReachedMessage")) {
            KlippaScanner.messages.cancelConfirmationMessage = config.getString("imageLimitReachedMessage")
        }

        if (config.has("cancelConfirmationMessage")) {
            KlippaScanner.messages.cancelConfirmationMessage = config.getString("cancelConfirmationMessage")
        }

        if (config.has("orientationWarningMessage")) {
            KlippaScanner.messages.orientationWarningMessage = config.getString("orientationWarningMessage")
        }

        if (config.has("imageMovingMessage")) {
            KlippaScanner.messages.imageMovingMessage = config.getString("imageMovingMessage")
        }

        if (config.has("cancelAndDeleteImagesButtonText")) {
            KlippaScanner.buttonTexts.cancelAndDeleteImagesButtonText = config.getString("cancelAndDeleteImagesButtonText")
        }

        if (config.has("cancelButtonText")) {
            KlippaScanner.buttonTexts.cancelButtonText = config.getString("cancelButtonText")
        }

        if (config.has("retakeButtonText")) {
            KlippaScanner.buttonTexts.retakeButtonText = config.getString("retakeButtonText")
        }

        if (config.has("deleteButtonText")) {
            KlippaScanner.buttonTexts.deleteButtonText = config.getString("deleteButtonText")
        }

        if (config.has("moveCloserMessage")) {
            KlippaScanner.messages.moveCloserMessage = config.getString("moveCloserMessage")
        }
    }

    private fun setupImage(config: JSONObject) {

        if (config.has("imageMaxWidth")) {
            KlippaScanner.images.resolutionMaxWidth = config.getInt("imageMaxWidth")
        }

        if (config.has("imageMaxHeight")) {
            KlippaScanner.images.resolutionMaxWidth = config.getInt("imageMaxHeight")
        }

        if (config.has("imageMaxQuality")) {
            KlippaScanner.images.outputQuality = config.getInt("imageMaxQuality")
        }

        if (config.has("outputFilename")) {
            KlippaScanner.images.outputFileName = config.getString("outputFilename")!!
        }

        if (config.has("imageMovingSensitivityAndroid")) {
            KlippaScanner.images.imageMovingSensitivity = config.getInt("imageMovingSensitivityAndroid")
        }

        if (config.has("imageLimit")) {
            KlippaScanner.images.imageLimit = config.getInt("imageLimit")
        }

        if (config.has("cropPadding")) {
            val cropPadding = config.getJSONObject("cropPadding")
            val width = cropPadding.getInt("width")
            val height = cropPadding.getInt("height")
            KlippaScanner.images.cropPadding = Size(width, height)
        }

        if (config.has("storagePath")) {
            KlippaScanner.images.outputDirectory = config.getString("storagePath")!!
        }
    }

    private fun setupModel(config: JSONObject) {
        if (config.has("model")) {
            val model = config.getJSONObject("model")
            if (model.has("fileName")) {
                KlippaScanner.model.modelName = model.getString("fileName")
            }

            if (model.has("modelLabels")) {
                KlippaScanner.model.modelLabels = model.getString("modelLabels")
            }
        }
    }

    private fun setupTimer(config: JSONObject) {
        if (config.has("timer")) {
            val timer = config.getJSONObject("timer")

            if (timer.has("allowed")) {
                KlippaScanner.menu.allowTimer = timer.getBoolean("allowed")
            }

            if (timer.has("enabled")) {
                KlippaScanner.menu.isTimerEnabled = timer.getBoolean("enabled")
            }

            if (timer.has("duration")) {
                KlippaScanner.durations.timerDuration = timer.getDouble("duration")
            }
        }
    }

    private fun setupSuccess(config: JSONObject) {
        if (config.has("success")) {
            val success = config.getJSONObject("success")

            if (success.has("previewDuration")) {
                KlippaScanner.durations.successPreviewDuration = success.getDouble("previewDuration")
            }

            if (success.has("message")) {
                KlippaScanner.messages.successMessage = success.getString("message")
            }
        }

        if (config.has("previewDuration")) {
            KlippaScanner.durations.previewDuration = config.getDouble("previewDuration")
        }
    }

    private fun setupShutterButton(config: JSONObject) {
        if (config.has("shutterButton")) {
            val shutterButton = config.getJSONObject("shutterButton")

            if (shutterButton.has("allowShutterButton")) {
                KlippaScanner.shutterButton.allowShutterButton = shutterButton.getBoolean("allowShutterButton")
            }

            if (shutterButton.has("hideShutterButton")) {
                KlippaScanner.shutterButton.hideShutterButton = shutterButton.getBoolean("hideShutterButton")
            }
        }
    }

    private fun setupMenu(config: JSONObject) {

        if (config.has("shouldGoToReviewScreenWhenImageLimitReached")) {
            KlippaScanner.menu.shouldGoToReviewScreenWhenImageLimitReached = config.getBoolean("shouldGoToReviewScreenWhenImageLimitReached")
        }

        if (config.has("userCanRotateImage")) {
            KlippaScanner.menu.userCanRotateImage = config.getBoolean("userCanRotateImage")
        }

        if (config.has("userCanCropManually")) {
            KlippaScanner.menu.userCanCropManually = config.getBoolean("userCanCropManually")
        }

        if (config.has("userCanChangeColorSetting")) {
            KlippaScanner.menu.userCanChangeColorSetting = config.getBoolean("userCanChangeColorSetting")
        }

        if (config.has("allowMultipleDocuments")) {
            KlippaScanner.menu.allowMultiDocumentsMode = config.getBoolean("allowMultipleDocuments")
        }

        if (config.has("defaultMultipleDocuments")) {
            KlippaScanner.menu.isMultiDocumentsModeEnabled = config.getBoolean("defaultMultipleDocuments")
        }

        if (config.has("defaultCrop")) {
            KlippaScanner.menu.isCropEnabled = config.getBoolean("defaultCrop")
        }

        if (config.has("storeImagesToCameraRoll")) {
            KlippaScanner.storeImagesToGallery = config.getBoolean("storeImagesToCameraRoll")
        }
    }


    @ActivityCallback
    private fun startKlippaScannerForResult(call: PluginCall, result: ActivityResult) {
        val data = result.data
        if (result.resultCode == Activity.RESULT_OK) {

            val extras = data?.extras ?: return

            val receivedImages: ArrayList<Image> = extras.getParcelableArrayList<Image>(KlippaScanner.IMAGES) as ArrayList<Image>

            val images: MutableList<Map<String, String>> = mutableListOf()

            for (image in receivedImages) {
                val imageDict = mapOf("Filepath" to image.filePath)
                images.add(imageDict)
            }

            val imagesAsJSON = JSONArray(images)

            val multipleDocuments: Boolean = extras.getBoolean(KlippaScanner.CREATE_MULTIPLE_RECEIPTS)
            val cropEnabled: Boolean = extras.getBoolean(KlippaScanner.CROP)
            val timerEnabled: Boolean = extras.getBoolean(KlippaScanner.TIMER_ENABLED)
            val color = extras.getString(KlippaScanner.DEFAULT_COLOR)

            val ret = JSObject()
            ret.put("images", imagesAsJSON)
            ret.put("multipleDocuments", multipleDocuments)
            ret.put("crop", cropEnabled)
            ret.put("timerEnabled", timerEnabled)
            ret.put("color", color)

            call.resolve(ret)
        } else if (result.resultCode == Activity.RESULT_CANCELED) {
            var error: String? = null
            if (data != null) {
                error = data.getStringExtra(KlippaScanner.ERROR)
            }
            if (error != null) {
                call.reject("Scanner was canceled with error: $error", E_CANCELED)
            } else {
                call.reject("Scanner was canceled.", E_CANCELED)
            }
        }
    }

    companion object {
        const val E_MISSING_LICENSE = "E_MISSING_LICENSE"
        const val E_CANCELED = "E_CANCELED"
    }


}
