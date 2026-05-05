import Foundation

enum AppRuntime {
    static let isScreenshotRun = ProcessInfo.processInfo.arguments.contains("-screenshots")
}
