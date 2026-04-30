import SwiftUI

struct ContentView: View {
    @StateObject private var motionManager = MotionManager()

    var body: some View {
        TabView {
            AngleMeterView(motionManager: motionManager)
                .tabItem {
                    Label("角度計", systemImage: "rotate.3d")
                }

            LevelView(motionManager: motionManager)
                .tabItem {
                    Label("水平器", systemImage: "level")
                }

            UnitConverterView()
                .tabItem {
                    Label("単位変換", systemImage: "ruler")
                }
        }
        .tint(.orange)
        .onAppear { motionManager.startUpdates() }
        .onDisappear { motionManager.stopUpdates() }
    }
}
