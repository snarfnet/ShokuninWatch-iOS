import SwiftUI

enum ShokuninTheme {
    static let soot = Color(red: 0.018, green: 0.020, blue: 0.022)
    static let iron = Color(red: 0.055, green: 0.061, blue: 0.064)
    static let ironLight = Color(red: 0.124, green: 0.133, blue: 0.132)
    static let gunmetal = Color(red: 0.176, green: 0.190, blue: 0.188)
    static let steel = Color(red: 0.630, green: 0.675, blue: 0.670)
    static let steelBright = Color(red: 0.850, green: 0.885, blue: 0.860)
    static let amber = Color(red: 1.000, green: 0.610, blue: 0.150)
    static let amberDeep = Color(red: 0.830, green: 0.360, blue: 0.060)
    static let paper = Color(red: 0.950, green: 0.900, blue: 0.780)
    static let safetyGreen = Color(red: 0.200, green: 0.910, blue: 0.520)
    static let dangerRed = Color(red: 0.940, green: 0.180, blue: 0.120)

    static let titleGradient = LinearGradient(
        colors: [paper, amber, amberDeep],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let amberGradient = LinearGradient(
        colors: [amber, amberDeep],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let brushedMetal = LinearGradient(
        stops: [
            .init(color: gunmetal, location: 0.00),
            .init(color: ironLight, location: 0.26),
            .init(color: iron, location: 0.52),
            .init(color: Color.black.opacity(0.78), location: 1.00)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let insetMetal = LinearGradient(
        colors: [Color.black.opacity(0.64), iron, gunmetal.opacity(0.84)],
        startPoint: .top,
        endPoint: .bottom
    )
}

struct WorkshopBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [ShokuninTheme.soot, ShokuninTheme.iron, Color(red: 0.080, green: 0.064, blue: 0.044)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [ShokuninTheme.amber.opacity(0.24), .clear],
                center: .topTrailing,
                startRadius: 16,
                endRadius: 380
            )

            RadialGradient(
                colors: [ShokuninTheme.steel.opacity(0.10), .clear],
                center: .bottomLeading,
                startRadius: 12,
                endRadius: 320
            )

            GeometryReader { geometry in
                Path { path in
                    let spacing: CGFloat = 28
                    var x: CGFloat = -geometry.size.height
                    while x < geometry.size.width {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x + geometry.size.height, y: geometry.size.height))
                        x += spacing
                    }
                }
                .stroke(ShokuninTheme.steel.opacity(0.045), lineWidth: 1)
            }

            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.white.opacity(0.035))
                    .frame(height: 1)
                Spacer()
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, Color.black.opacity(0.30), ShokuninTheme.amberDeep.opacity(0.08)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 240)
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
                RoundedRectangle(cornerRadius: 12)
                    .fill(ShokuninTheme.amberGradient)
                    .frame(width: 54, height: 54)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.32), lineWidth: 1)
                    )
                    .shadow(color: ShokuninTheme.amber.opacity(0.28), radius: 18, y: 8)

                Image(systemName: icon)
                    .font(.system(size: 25, weight: .black))
                    .foregroundColor(.black)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(ShokuninTheme.titleGradient)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Text(subtitle)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(ShokuninTheme.steel)
                    .tracking(1.2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
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
                RoundedRectangle(cornerRadius: 18)
                    .fill(ShokuninTheme.brushedMetal)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        ShokuninTheme.steelBright.opacity(0.48),
                                        ShokuninTheme.amber.opacity(0.34),
                                        Color.black.opacity(0.55)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.50), radius: 22, y: 14)
            )
    }
}

struct PrecisionReadout: View {
    let label: String
    let value: String
    let tint: Color
    var icon: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .black))
                }
                Text(label)
                    .font(.system(size: 11, weight: .black, design: .monospaced))
            }
            .foregroundColor(ShokuninTheme.steel)
            .tracking(0.8)

            Text(value)
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundColor(tint)
                .monospacedDigit()
                .minimumScaleFactor(0.58)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 14)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 13)
                .fill(ShokuninTheme.insetMetal)
                .overlay(
                    RoundedRectangle(cornerRadius: 13)
                        .stroke(tint.opacity(0.34), lineWidth: 1)
                )
        )
    }
}

struct Rivet: View {
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [ShokuninTheme.steelBright, ShokuninTheme.gunmetal, Color.black.opacity(0.72)],
                    center: .topLeading,
                    startRadius: 1,
                    endRadius: 9
                )
            )
            .frame(width: 12, height: 12)
            .overlay(Circle().stroke(Color.black.opacity(0.45), lineWidth: 1))
    }
}
