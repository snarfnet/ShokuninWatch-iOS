import SwiftUI

enum ShokuninTheme {
    static let iron = Color(red: 0.055, green: 0.061, blue: 0.064)
    static let ironLight = Color(red: 0.118, green: 0.128, blue: 0.130)
    static let steel = Color(red: 0.630, green: 0.675, blue: 0.670)
    static let soot = Color(red: 0.020, green: 0.022, blue: 0.024)
    static let amber = Color(red: 1.000, green: 0.610, blue: 0.150)
    static let amberDeep = Color(red: 0.830, green: 0.360, blue: 0.060)
    static let wood = Color(red: 0.430, green: 0.240, blue: 0.115)
    static let safetyGreen = Color(red: 0.200, green: 0.910, blue: 0.520)
    static let dangerRed = Color(red: 0.940, green: 0.180, blue: 0.120)
    static let paper = Color(red: 0.950, green: 0.900, blue: 0.780)

    static let titleGradient = LinearGradient(
        colors: [paper, amber, amberDeep],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let metalGradient = LinearGradient(
        colors: [ironLight, iron, soot],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let buttonGradient = LinearGradient(
        colors: [amber, amberDeep],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct WorkshopBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [ShokuninTheme.soot, ShokuninTheme.iron, Color(red: 0.090, green: 0.070, blue: 0.045)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [ShokuninTheme.amber.opacity(0.22), .clear],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 340
            )

            GeometryReader { geo in
                Path { path in
                    let spacing: CGFloat = 34
                    var x: CGFloat = -geo.size.height
                    while x < geo.size.width {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x + geo.size.height, y: geo.size.height))
                        x += spacing
                    }
                }
                .stroke(ShokuninTheme.steel.opacity(0.045), lineWidth: 1)
            }

            VStack {
                Spacer()
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [ShokuninTheme.wood.opacity(0.0), ShokuninTheme.wood.opacity(0.32)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 180)
            }
        }
        .ignoresSafeArea()
    }
}

struct ToolHeader: View {
    let title: String
    let subtitle: String
    let icon: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(ShokuninTheme.buttonGradient)
                    .frame(width: 52, height: 52)
                    .shadow(color: ShokuninTheme.amber.opacity(0.35), radius: 12, y: 6)
                Image(systemName: icon)
                    .font(.system(size: 25, weight: .black))
                    .foregroundColor(.black)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(ShokuninTheme.titleGradient)
                Text(subtitle)
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(ShokuninTheme.steel)
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
    }
}

struct WorkshopPanel<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(ShokuninTheme.metalGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [ShokuninTheme.steel.opacity(0.60), ShokuninTheme.amber.opacity(0.34), Color.black.opacity(0.35)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.42), radius: 18, y: 12)
            )
    }
}

struct MetricTile: View {
    let label: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(ShokuninTheme.steel)
            Text(value)
                .font(.system(size: 24, weight: .black, design: .monospaced))
                .foregroundColor(tint)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.30))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(tint.opacity(0.38), lineWidth: 1))
        )
    }
}
