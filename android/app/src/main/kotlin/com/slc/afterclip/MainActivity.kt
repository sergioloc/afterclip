package com.slc.afterclip

import android.content.ContentValues
import android.content.Intent
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream

class MainActivity : FlutterActivity() {
    private val channelName = "afterclip/gallery"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "saveVideo" -> {
                        val path = call.argument<String>("path")
                        if (path == null) {
                            result.error("INVALID_ARGUMENT", "path is required", null)
                            return@setMethodCallHandler
                        }
                        try {
                            val savedUri = saveVideoToGallery(path)
                            result.success(savedUri?.toString())
                        } catch (e: Exception) {
                            result.error("SAVE_FAILED", e.message, e.toString())
                        }
                    }
                    "openGallery" -> {
                        openGallery()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun saveVideoToGallery(path: String): android.net.Uri? {
        val dirPath = Environment.DIRECTORY_MOVIES + "/Afterclip"
        val file = File(path)
        val resolver = contentResolver
        val values = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, file.name)
            put(MediaStore.MediaColumns.MIME_TYPE, "video/mp4")
            put(MediaStore.Video.Media.RELATIVE_PATH, dirPath)
        }
        val uri = resolver.insert(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, values)
            ?: return null
        resolver.openOutputStream(uri).use { out ->
            if (out == null) return null
            FileInputStream(file).use { input ->
                val buffer = ByteArray(8192)
                var read: Int
                while (input.read(buffer).also { read = it } != -1) {
                    out.write(buffer, 0, read)
                }
            }
        }
        return uri
    }

    private fun openGallery() {
        val intent = Intent(Intent.ACTION_VIEW)
        if (Build.VERSION.SDK_INT <= 23) {
            intent.type = "video/*"
        } else {
            intent.data = MediaStore.Video.Media.EXTERNAL_CONTENT_URI
        }
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        startActivity(intent)
    }
}
