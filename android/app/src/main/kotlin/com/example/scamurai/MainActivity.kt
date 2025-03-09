package com.example.scamurai

import android.content.Intent
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val SHARED_CHANNEL = "app.channel.shared.data"
    private val DEFAULT_BROWSER_CHANNEL = "app.channel.default_browser"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent) {
        val data: String? = intent.data?.toString()
        if (data != null) {
            MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, SHARED_CHANNEL)
                .invokeMethod("receivedLink", data)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DEFAULT_BROWSER_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "isDefaultBrowser") {
                    result.success(isDefaultBrowser())
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun isDefaultBrowser(): Boolean {
        val defaultBrowser = Settings.Secure.getString(contentResolver, "http_default_browser_package")
        return defaultBrowser == packageName
    }
}
