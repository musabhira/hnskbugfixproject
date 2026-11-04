package com.poketmates.app

import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import io.flutter.plugins.googlemobileads.NativeAdFactory

/**
 * Custom NativeAdFactory for POKET Mates App.
 * Inflates pocket_native_ad_card.xml and binds the native ad components.
 */
class PocketNativeAdFactory(private val layoutInflater: LayoutInflater) : NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val adView = layoutInflater.inflate(R.layout.pocket_native_ad_card, null) as NativeAdView

        // 1. Headline
        val headlineView = adView.findViewById<TextView>(R.id.ad_headline)
        headlineView.text = nativeAd.headline
        adView.headlineView = headlineView

        // 2. Media View (Video / Image)
        val mediaView = adView.findViewById<MediaView>(R.id.ad_media)
        adView.mediaView = mediaView

        // 3. Call to Action Button
        val ctaView = adView.findViewById<Button>(R.id.ad_call_to_action)
        if (nativeAd.callToAction != null) {
            ctaView.visibility = View.VISIBLE
            ctaView.text = nativeAd.callToAction
            adView.callToActionView = ctaView
        } else {
            ctaView.visibility = View.GONE
        }

        // 4. App Icon
        val iconView = adView.findViewById<ImageView>(R.id.ad_app_icon)
        val icon = nativeAd.icon
        if (icon != null) {
            iconView.visibility = View.VISIBLE
            iconView.setImageDrawable(icon.drawable)
            adView.iconView = iconView
        } else {
            iconView.visibility = View.GONE
        }

        // 5. Body Text
        val bodyView = adView.findViewById<TextView>(R.id.ad_body)
        if (nativeAd.body != null) {
            bodyView.visibility = View.VISIBLE
            bodyView.text = nativeAd.body
            adView.bodyView = bodyView
        } else {
            bodyView.visibility = View.GONE
        }

        // 6. Advertiser
        val advertiserView = adView.findViewById<TextView>(R.id.ad_advertiser)
        if (nativeAd.advertiser != null) {
            advertiserView.visibility = View.VISIBLE
            advertiserView.text = nativeAd.advertiser
            adView.advertiserView = advertiserView
        } else {
            advertiserView.visibility = View.GONE
        }

        // 7. Store / Price
        val storeView = adView.findViewById<TextView>(R.id.ad_store)
        if (nativeAd.store != null) {
            storeView.visibility = View.VISIBLE
            storeView.text = nativeAd.store
            adView.storeView = storeView
        } else {
            storeView.visibility = View.GONE
        }

        val priceView = adView.findViewById<TextView>(R.id.ad_price)
        if (nativeAd.price != null) {
            priceView.visibility = View.VISIBLE
            priceView.text = nativeAd.price
            adView.priceView = priceView
        } else {
            priceView.visibility = View.GONE
        }

        // Register the NativeAd object with the NativeAdView
        adView.setNativeAd(nativeAd)

        return adView
    }
}

