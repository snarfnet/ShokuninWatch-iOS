import SwiftUI

struct AngleMeterView: View {
    @ObservedObject var motionManager: MotionManager

    private var displayAngle: Double {
        (motionManager.pitch.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
    }

    var body: some View {
        ZStack {
            WorkshopBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    ToolHeader(title: "角度計", subtitle: "DIGITAL ANGLE GAUGE", icon: "gauge")

                    WorkshopPanel {
                        VStack(spacing: 18) {
                            GaugeDial(angle: displayAngle)

                            HStack(spacing: 10) {
                                PrecisionReadout(
                                    label: "PITCH",
                                    value: String(format: "%.1f°", motionManager.pitch),
                                    tint: ShokuninTheme.amber,
                                    icon: "arrow.up.and.down"
                                )
                                PrecisionReadout(
                                    label: "ROLL",
                                    value: String(format: "%.1f°", motionManager.roll),
                                    tint: ShokuninTheme.paper,
                                    icon: "arrow.left.and.right"
                                )
                            }

                            Button(action: { motionManager.resetReference() }) {
                                Label("ゼロリセット", systemImage: "scope")
                                    .font(.system(size: 18, weight: .black, design: .rounded))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 15)
                                    .background(ShokuninTheme.amberGradient)
                                    .clipShape(RoundedRectangle(cornerRadius: 13))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 13)
                                            .stroke(Color.white.opacity(0.30), lineWidth: 1)
                                    )
                                    .shadow(color: ShokuninTheme.amber.opacity(0.30), radius: 14, y: 8)
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
                .padding(.bottom, 24)
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
                        colors: [
                            ShokuninTheme.gunmetal,
                            ShokuninTheme.iron,
                            Color.black.opacity(0.92)
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 152
                    )
                )
                .frame(width: 304, height: 304)
                .overlay(Circle().stroke(ShokuninTheme.steelBright.opacity(0.24), lineWidth: 1))
                .overlay(Circle().stroke(ShokuninTheme.amber.opacity(0.30), lineWidth: 8).padding(11))
                .overlay(Circle().stroke(Color.black.opacity(0.52), lineWidth: 2).padding(20))

            ForEach(0..<120, id: \.self) { index in
                let isMajor = index % 30 == 0
                let isMedium = index % 10 == 0
                Rectangle()
                    .fill(isMajor ? ShokuninTheme.amber : ShokuninTheme.steel.opacity(isMedium ? 0.66 : 0.30))
                    .frame(width: isMajor ? 3 : 1, height: isMajor ? 22 : (isMedium ? 16 : 8))
                    .offset(y: -139)
                    .rotationEffect(.degrees(Double(index) * 3))
            }

            ForEach([0, 45, 90, 135, 180, 225, 270, 315], id: \.self) { mark in
                dialNumber("\(mark)", angle: Double(mark))
            }

            ForEach(0..<4, id: \.self) { index in
                Rivet()
                    .offset(y: -132)
                    .rotationEffect(.degrees(Double(index) * 90 + 45))
            }

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [ShokuninTheme.amber, ShokuninTheme.amberDeep],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 7, height: 112)
                .overlay(Capsule().stroke(Color.white.opacity(0.26), lineWidth: 1))
                .offset(y: -55)
                .rotationEffect(.degrees(angle))
                .shadow(color: ShokuninTheme.amber.opacity(0.52), radius: 12)
                .animation(.snappy(duration: 0.12), value: angle)

            Circle()
                .fill(ShokuninTheme.amberGradient)
                .frame(width: 30, height: 30)
                .overlay(Circle().stroke(Color.black.opacity(0.52), lineWidth: 4))

            VStack(spacing: 2) {
                Text(String(format: "%.1f°", angle))
                    .font(.system(size: 49, weight: .black, design: .rounded))
                    .foregroundColor(ShokuninTheme.paper)
                    .monospacedDigit()
                    .shadow(color: Color.black, radius: 9)
                    .minimumScaleFactor(0.70)
                    .lineLimit(1)

                Text("REFERENCE ANGLE")
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundColor(ShokuninTheme.amber)
                    .tracking(1.2)
            }
            .offset(y: 82)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 320)
    }

    private func dialNumber(_ text: String, angle: Double) -> some View {
        let radians = angle * .pi / 180
        let radius: CGFloat = 106
        let x = CGFloat(sin(radians)) * radius
        let y = -CGFloat(cos(radians)) * radius

        Text(text)
            .font(.system(size: 11, weight: .black, design: .rounded))
            .foregroundColor(ShokuninTheme.steel)
            .offset(x: x, y: y)
    }
}
