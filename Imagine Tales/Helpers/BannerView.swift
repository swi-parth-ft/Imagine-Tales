//
//  BannerView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 10/7/24.
//

import SwiftUI
import GoogleMobileAds

struct BannerView: UIViewRepresentable {
    let adSize: GADAdSize
    
    init(_ adSize: GADAdSize) {
        self.adSize = adSize
    }
    
    func makeUIView(context: Context) -> UIView {
        // Wrap the GADBannerView in a UIView. GADBannerView automatically reloads a new ad when its
        // frame size changes; wrapping in a UIView container insulates the GADBannerView from size
        // changes that impact the view returned from makeUIView.
        let view = UIView()
        view.addSubview(context.coordinator.bannerView)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.bannerView.adSize = adSize
    }
    
    func makeCoordinator() -> BannerCoordinator {
        return BannerCoordinator(self)
    }
}

class BannerCoordinator: NSObject, GADBannerViewDelegate {
    
    private(set) lazy var bannerView: GADBannerView = {
        let banner = GADBannerView(adSize: parent.adSize)
        banner.adUnitID = "ca-app-pub-3940256099942544/2435281174"
        banner.load(GADRequest())
        banner.delegate = self
        return banner
    }()
    
    let parent: BannerView
    
    init(_ parent: BannerView) {
        self.parent = parent
    }
}


class InterstitialViewModel: NSObject, GADFullScreenContentDelegate {
    private var interstitialAd: GADInterstitialAd?
    
    func loadAd() async {
        do {
            interstitialAd = try await GADInterstitialAd.load(
                withAdUnitID: "ca-app-pub-3940256099942544/4411468910", request: GADRequest())
            interstitialAd?.fullScreenContentDelegate = self
        } catch {
            print("Failed to load interstitial ad with error: \(error.localizedDescription)")
        }
    }
    
    func showAd() {
      guard let interstitialAd = interstitialAd else {
        return print("Ad wasn't ready.")
      }

      interstitialAd.present(fromRootViewController: nil)
    }
    
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
      print("\(#function) called")
    }

    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
      print("\(#function) called")
    }

    func ad(
      _ ad: GADFullScreenPresentingAd,
      didFailToPresentFullScreenContentWithError error: Error
    ) {
      print("\(#function) called")
    }

    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
      print("\(#function) called")
    }

    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
      print("\(#function) called")
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
      print("\(#function) called")
      // Clear the interstitial ad.
      interstitialAd = nil
    }
}
