package com.klippa.capacitorscanner

import android.app.Activity
import android.content.Intent
import androidx.activity.result.ActivityResult
import com.getcapacitor.JSObject
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.ActivityCallback
import com.getcapacitor.annotation.CapacitorPlugin
import com.klippa.scanner.KlippaScanner
import com.klippa.scanner.`object`.Image

@CapacitorPlugin(name = "KlippaScannerSDKPlugin")
class KlippaScannerSDKPlugin : Plugin() {

    @PluginMethod
    fun getCameraResult(call: PluginCall) {
        val config = call.data

        val license = config["license"] as? String ?: kotlin.run {
            call.reject("Missing license", E_MISSING_LICENSE)
            return
        }

        KlippaScanner.license = license

        val intent = Intent(activity, KlippaScanner::class.java)
        startActivityForResult(call, intent, "startKlippaScannerForResult")
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

            val multipleDocuments: Boolean = extras.getBoolean(KlippaScanner.CREATE_MULTIPLE_RECEIPTS)
            val cropEnabled: Boolean = extras.getBoolean(KlippaScanner.CROP)
            val timerEnabled: Boolean = extras.getBoolean(KlippaScanner.TIMER_ENABLED)

            val resultDict: Map<String, Any> = mapOf(
                "Images" to images,
                "MultipleDocuments" to multipleDocuments,
                "Crop" to cropEnabled,
                "TimerEnabled" to timerEnabled)

            val resultDictAsJSObject = JSObject(resultDict.toString())

            call.resolve(resultDictAsJSObject)
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
