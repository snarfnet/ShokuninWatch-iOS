import SwiftUI

struct AngleMeterView: View {
    @ObservedObject var motionManager: MotionManager

    var displayAngle: Double {
        let angle = motionManager.pitch
        return (angle.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
    }

    var body: some View {
        ZStack {
            WorkshopBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    ToolHeader(title: "角度計", subtitle: "DIGITAL ANGLE GAUGE", icon: "hammer.fill")

                    WorkshopPanel {
                        VStack(spacing: 18) {
                            GaugeDial(angle: displayAngle)

                            HStack(spacing: 10) {
                                MetricTile(label: "ピッチ", value: String(format: "%.1f°", motionManager.pitch), tint: ShokuninTheme.amber)
                                MetricTile(label: "ロール", value: String(format: "%.1f°", motionManager.roll), tint: ShokuninTheme.paper)
                            }

                            Button(action: { motionManager.resetReference() }) {
                                Label("ゼロリセット", systemImage: "scope")
                                    .font(.system(size: 18, weight: .black))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 15)
                                    .background(ShokuninTheme.buttonGradient)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .shadow(color: ShokuninTheme.amber.opacity(0.35), radius: 12, y: 8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 18)

                    if !AppRuntime.isScreenshotRun {
                        BannerAdView(adUnitID: "ca-app-pub-9404799280370656/5212572496")
                            .frame(height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal, 18)
                    }
                }
                .padding(.bottom, 26)
            }
        }
    }
}

private struct GaugeDial: View {
    let angle: Double

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [ShokuninTheme.ironLight, ShokuninTheme.soot],
                        center: .center,
                        startRadius: 20,
                        endRadius: 140
                    )
                )
                .frame(width: 282, height: 282)
                .overlay(Circle().stroke(ShokuninTheme.steel.opacity(0.40), lineWidth: 2))
                .overlay(Circle().stroke(ShokuninTheme.amber.opacity(0.26), lineWidth: 8).padding(9))

            ForEach(0..<72, id: \.self) { index in
                Rectangle()
                    .fill(index % 18 == 0 ? ShokuninTheme.amber : ShokuninTheme.steel.opacity(index % 6 == 0 ? 0.62 : 0.28))
                    .frame(width: index % 18 == 0 ? 3 : 1, height: index % 6 == 0 ? 18 : 9)
                    .offset(y: -128)
                    .rotationEffect(.degrees(Double(index) * 5))
            }

            dialNumber("0", x: 0, y: -101)
            dialNumber("90", x: 101, y: 0)
            dialNumber("180", x: 0, y: 101)
            dialNumber("270", x: -101, y: 0)

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [ShokuninTheme.amber, ShokuninTheme.amberDeep],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 5, height: 98)
                .offset(y: -49)
                .rotationEffect(.degrees(angle))
                .shadow(color: ShokuninTheme.amber.opacity(0.55), radius: 10)
                .animation(.easeOut(duration: 0.10), value: angle)

            Circle()
                .fill(ShokuninTheme.buttonGradient)
                .frame(width: 24, height: 24)
                .overlay(Circle().stroke(Color.black.opacity(0.45), lineWidth: 3))

            VStack(spacing: 2) {
                Text(String(format: "%.1f°", angle))
                    .font(.system(size: 47, weight: .black, design: .rounded))
                    .foregroundColor(ShokuninTheme.paper)
                    .shadow(color: Color.black, radius: 8)
                    .minimumScaleFactor(0.7)
                Text("MASTER CUT")
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundColor(ShokuninTheme.amber)
            }
            .offset(y: 76)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
    }

    private func dialNumber(_ text: String, x: CGFloat, y: CGFloat) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .black, design: .rounded))
            .foregroundColor(ShokuninTheme.steel)
            .offset(x: x, y: y)
    }
}
