import SwiftUI

private enum ToolTab: Int, CaseIterable {
    case angle
    case level
    case converter

    var title: String {
        switch self {
        case .angle: return "角度計"
        case .level: return "水平器"
        case .converter: return "単位変換"
        }
    }

    var icon: String {
        switch self {
        case .angle: return "gauge"
        case .level: return "level.fill"
        case .converter: return "ruler.fill"
        }
    }
}

struct ContentView: View {
    @StateObject private var motionManager = MotionManager()
    @State private var selectedTab = Self.initialTab

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .angle:
                    AngleMeterView(motionManager: motionManager)
                case .level:
                    LevelView(motionManager: motionManager)
                case .converter:
                    UnitConverterView()
                }
            }
            .safeAreaPadding(.bottom, 88)

            CustomToolTabBar(selectedTab: $selectedTab)
        }
        .onAppear { motionManager.startUpdates() }
        .onDisappear { motionManager.stopUpdates() }
    }

    private static var initialTab: ToolTab {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: "-screenshotTab"),
              arguments.indices.contains(index + 1) else {
            return .angle
        }

        switch arguments[index + 1] {
        case "level": return .level
        case "converter": return .converter
        default: return .angle
        }
    }
}

private struct CustomToolTabBar: View {
    @Binding var selectedTab: ToolTab

    var body: some View {
        HStack(spacing: 8) {
            ForEach(ToolTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.30, dampingFraction: 0.82)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 18, weight: .black))
                            .symbolRenderingMode(.hierarchical)
                        Text(tab.title)
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    .foregroundColor(selectedTab == tab ? .black : ShokuninTheme.paper.opacity(0.82))
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(selectedTab == tab ? AnyShapeStyle(ShokuninTheme.amberGradient) : AnyShapeStyle(Color.black.opacity(0.18)))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(selectedTab == tab ? Color.white.opacity(0.28) : ShokuninTheme.steel.opacity(0.18), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color.black.opacity(0.40))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(ShokuninTheme.steel.opacity(0.24), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.45), radius: 18, y: 10)
        )
        .padding(.horizontal, 14)
        .padding(.bottom, 10)
    }
}
