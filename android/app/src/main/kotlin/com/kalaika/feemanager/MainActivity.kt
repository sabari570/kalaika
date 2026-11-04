package com.kalaika.feemanager

import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isWhatsAppInstalled" -> {
                    result.success(isWhatsAppInstalled())
                }
                "sharePdfToChat" -> {
                    val pdfPath = call.argument<String>("pdfPath")
                    val phoneDigits = call.argument<String>("phoneDigits")
                    val text = call.argument<String>("text")
                    if (pdfPath.isNullOrBlank() || phoneDigits.isNullOrBlank()) {
                        result.success(false)
                        return@setMethodCallHandler
                    }
                    result.success(
                        sharePdfToWhatsApp(
                            pdfPath = pdfPath,
                            phoneDigits = phoneDigits,
                            text = text,
                        ),
                    )
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun isWhatsAppInstalled(): Boolean {
        return WHATSAPP_PACKAGES.any { packageName ->
            try {
                packageManager.getPackageInfo(packageName, 0)
                true
            } catch (_: PackageManager.NameNotFoundException) {
                false
            }
        }
    }

    private fun sharePdfToWhatsApp(
        pdfPath: String,
        phoneDigits: String,
        text: String?,
    ): Boolean {
        val file = File(pdfPath)
        if (!file.exists()) {
            return false
        }
        val authority = "${packageName}.fileprovider"
        val uri: Uri = FileProvider.getUriForFile(this, authority, file)
        val jid = "${phoneDigits}@s.whatsapp.net"

        for (packageName in WHATSAPP_PACKAGES) {
            if (!isPackageInstalled(packageName)) {
                continue
            }
            val intent = Intent(Intent.ACTION_SEND).apply {
                type = "application/pdf"
                putExtra(Intent.EXTRA_STREAM, uri)
                if (!text.isNullOrBlank()) {
                    putExtra(Intent.EXTRA_TEXT, text)
                }
                putExtra(JID_EXTRA, jid)
                setPackage(packageName)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            try {
                startActivity(intent)
                return true
            } catch (_: ActivityNotFoundException) {
                continue
            }
        }
        return false
    }

    private fun isPackageInstalled(packageName: String): Boolean {
        return try {
            packageManager.getPackageInfo(packageName, 0)
            true
        } catch (_: PackageManager.NameNotFoundException) {
            false
        }
    }

    companion object {
        private const val CHANNEL = "com.kalaika.feemanager/whatsapp"
        private const val JID_EXTRA = "jid"
        private val WHATSAPP_PACKAGES = listOf(
            "com.whatsapp",
            "com.whatsapp.w4b",
        )
    }
}
