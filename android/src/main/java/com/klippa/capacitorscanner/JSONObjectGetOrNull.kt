package com.klippa.capacitorscanner

import org.json.JSONObject

fun JSONObject.getStringOrNull(name: String) : String? {
    return try {
        this.getString(name)
    } catch (e: Exception) {
        return null
    }
}

fun JSONObject.getBooleanOrNull(name: String) : Boolean? {
    return try {
        this.getBoolean(name)
    } catch (e: Exception) {
        return null
    }
}

fun JSONObject.getIntOrNull(name: String) : Int? {
    return try {
        this.getInt(name)
    } catch (e: Exception) {
        return null
    }
}

fun JSONObject.getDoubleOrNull(name: String) : Double? {
    return try {
        this.getDouble(name)
    } catch (e: Exception) {
        return null
    }
}

fun JSONObject.getJsonObjectOrNull(name: String) : JSONObject? {
    return try {
        this.getJSONObject(name)
    } catch (e: Exception) {
        return null
    }
}
