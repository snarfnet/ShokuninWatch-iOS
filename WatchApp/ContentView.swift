import SwiftUI

struct ContentView: View {
    @State private var selectedTool = 0

    var body: some View {
        TabView(selection: $selectedTool) {
            WatchAngleView()
                .tag(0)

            WatchLevelView()
                .tag(1)
        }
        .tabViewStyle(.verticalPage)
        .background(WatchWorkshopBackground())
    }
}

private struct WatchWorkshopBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.018, green: 0.020, blue: 0.022),
                Color(red: 0.070, green: 0.076, blue: 0.074),
                Color(red: 0.100, green: 0.066, blue: 0.034)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

private struct WatchAngleView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("角度計")
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(WatchPalette.title)

            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.44))
                    .overlay(Circle().stroke(WatchPalette.amber.opacity(0.45), lineWidth: 5))

                ForEach(0..<36, id: \.self) { index in
                    Rectangle()
                        .fill(index % 9 == 0 ? WatchPalette.amber : WatchPalette.steel.opacity(0.42))
                        .frame(width: index % 9 == 0 ? 2 : 1, height: index % 9 == 0 ? 12 : 6)
                        .offset(y: -58)
                        .rotationEffect(.degrees(Double(index) * 10))
                }

                Capsule()
                    .fill(WatchPalette.amber)
                    .frame(width: 5, height: 48)
                    .offset(y: -24)

                Circle()
                    .fill(WatchPalette.amber)
                    .frame(width: 18, height: 18)

                VStack(spacing: 0) {
                    Text("0.0°")
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .monospacedDigit()
                        .foregroundColor(WatchPalette.paper)
                    Text("ANGLE")
                        .font(.system(size: 8, weight: .black, design: .monospaced))
                        .foregroundColor(WatchPalette.amber)
                }
                .offset(y: 38)
            }
            .frame(width: 142, height: 142)
        }
    }
}

private struct WatchLevelView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("水平器")
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(WatchPalette.title)

            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.black.opacity(0.42))
                    .overlay(RoundedRectangle(cornerRadius: 22).stroke(WatchPalette.steel.opacity(0.28), lineWidth: 1))

                Circle()
                    .stroke(WatchPalette.amber.opacity(0.72), lineWidth: 3)
                    .frame(width: 102, height: 102)
                Circle()
                    .stroke(WatchPalette.steel.opacity(0.24), lineWidth: 1)
                    .frame(width: 56, height: 56)

                Rectangle()
                    .fill(WatchPalette.steel.opacity(0.28))
                    .frame(width: 1, height: 110)
                Rectangle()
                    .fill(WatchPalette.steel.opacity(0.28))
                    .frame(width: 110, height: 1)

                Circle()
                    .fill(WatchPalette.green)
                    .frame(width: 28, height: 28)
                    .overlay(Circle().stroke(Color.white.opacity(0.52), lineWidth: 2))
                    .shadow(color: WatchPalette.green.opacity(0.62), radius: 10)
            }
            .frame(width: 142, height: 142)

            Text("LEVEL OK")
                .font(.system(size: 10, weight: .black, design: .monospaced))
                .foregroundColor(WatchPalette.green)
        }
    }
}

private enum WatchPalette {
    static let amber = Color(red: 1.000, green: 0.610, blue: 0.150)
    static let steel = Color(red: 0.630, green: 0.675, blue: 0.670)
    static let paper = Color(red: 0.950, green: 0.900, blue: 0.780)
    static let green = Color(red: 0.200, green: 0.910, blue: 0.520)
    static let title = LinearGradient(colors: [paper, amber], startPoint: .topLeading, endPoint: .bottomTrailing)
}
