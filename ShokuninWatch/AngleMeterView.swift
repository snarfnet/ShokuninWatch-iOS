import SwiftUI

struct AngleMeterView: View {
    @ObservedObject var motionManager: MotionManager

    var displayAngle: Double {
        let a = motionManager.pitch
        return (a.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                Text("デジタル角度計")
                    .font(.headline)
                    .foregroundColor(.orange)

                ZStack {
                    Circle()
                        .stroke(Color.orange.opacity(0.3), lineWidth: 3)
                        .frame(width: 220, height: 220)

                    // Tick marks
                    ForEach(0..<36, id: \.self) { i in
                        Rectangle()
                            .fill(i % 9 == 0 ? Color.orange : Color.gray.opacity(0.5))
                            .frame(width: i % 9 == 0 ? 2 : 1, height: i % 9 == 0 ? 16 : 8)
                            .offset(y: -102)
                            .rotationEffect(.degrees(Double(i) * 10))
                    }

                    // Needle
                    Rectangle()
                        .fill(Color.orange)
                        .frame(width: 3, height: 80)
                        .offset(y: -40)
                        .rotationEffect(.degrees(displayAngle))
                        .animation(.easeOut(duration: 0.1), value: displayAngle)

                    Circle()
                        .fill(Color.orange)
                        .frame(width: 12, height: 12)

                    Text(String(format: "%.1f°", displayAngle))
                        .font(.system(size: 42, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .offset(y: 60)
                }

                HStack(spacing: 40) {
                    VStack(spacing: 4) {
                        Text("ピッチ")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(String(format: "%.1f°", motionManager.pitch))
                            .font(.system(size: 18, design: .monospaced))
                            .foregroundColor(.orange)
                    }
                    VStack(spacing: 4) {
                        Text("ロール")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(String(format: "%.1f°", motionManager.roll))
                            .font(.system(size: 18, design: .monospaced))
                            .foregroundColor(.orange)
                    }
                }

                Button(action: { motionManager.resetReference() }) {
                    Text("ゼロリセット")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(Color.orange)
                        .clipShape(Capsule())
                }

                BannerAdView(adUnitID: "ca-app-pub-9404799280370656/5212572496")
                    .frame(height: 50)
            }
            .padding()
        }
    }
}
