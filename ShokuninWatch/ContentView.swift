import SwiftUI

struct ContentView: View {
    @StateObject private var motionManager = MotionManager()
    @State private var selectedTab = Self.initialTab

    var body: some View {
        TabView(selection: $selectedTab) {
            AngleMeterView(motionManager: motionManager)
                .tag(0)
                .tabItem {
                    Label("角度計", systemImage: "gauge")
                }

            LevelView(motionManager: motionManager)
                .tag(1)
                .tabItem {
                    Label("水平器", systemImage: "level")
                }

            UnitConverterView()
                .tag(2)
                .tabItem {
                    Label("単位変換", systemImage: "ruler")
                }
        }
        .tint(ShokuninTheme.amber)
        .toolbarBackground(ShokuninTheme.iron, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .onAppear { motionManager.startUpdates() }
        .onDisappear { motionManager.stopUpdates() }
    }

    private static var initialTab: Int {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: "-screenshotTab"),
              arguments.indices.contains(index + 1) else {
            return 0
        }

        switch arguments[index + 1] {
        case "level": return 1
        case "converter": return 2
        default: return 0
        }
    }
}
