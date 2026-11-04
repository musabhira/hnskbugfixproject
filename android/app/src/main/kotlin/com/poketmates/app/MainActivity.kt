package com.poketmates.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import io.flutter.plugins.googlemobileads.NativeAdFactory

class MainActivity: FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register custom NativeAdFactory for POKET Native Advanced Ads
        val factory: NativeAdFactory = PocketNativeAdFactory(layoutInflater)
        GoogleMobileAdsPlugin.registerNativeAdFactory(flutterEngine, "pocketNativeCardFactory", factory)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        // Unregister factory on cleanup to prevent memory leaks
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "pocketNativeCardFactory")
        super.cleanUpFlutterEngine(flutterEngine)
    }
}

