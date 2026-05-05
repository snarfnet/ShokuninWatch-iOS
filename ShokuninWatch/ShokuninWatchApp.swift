import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency

@main
struct ShokuninWatchApp: App {
    init() {
        if !AppRuntime.isScreenshotRun {
            GADMobileAds.sharedInstance().start(completionHandler: nil)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    if !AppRuntime.isScreenshotRun {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            ATTrackingManager.requestTrackingAuthorization { _ in }
                        }
                    }
                }
        }
    }
}
