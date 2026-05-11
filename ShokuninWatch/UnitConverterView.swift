import SwiftUI
import UIKit

enum ConversionType: String, CaseIterable, Identifiable {
    case shakuMm = "尺 → mm"
    case tsuboM2 = "坪 → m²"
    case inchMm = "inch → mm"
    case feetM = "feet → m"
    case pyeongM2 = "평 → m²"

    var id: String { rawValue }

    var fromUnit: String {
        switch self {
        case .shakuMm: return "尺"
        case .tsuboM2: return "坪"
        case .inchMm: return "inch"
        case .feetM: return "feet"
        case .pyeongM2: return "평"
        }
    }

    var toUnit: String {
        switch self {
        case .shakuMm: return "mm"
        case .tsuboM2: return "m²"
        case .inchMm: return "mm"
        case .feetM: return "m"
        case .pyeongM2: return "m²"
        }
    }

    var title: String {
        switch self {
        case .shakuMm: return "尺寸法"
        case .tsuboM2: return "面積"
        case .inchMm: return "インチ"
        case .feetM: return "フィート"
        case .pyeongM2: return "坪換算"
        }
    }

    func convert(_ value: Double) -> Double {
        switch self {
        case .shakuMm: return value * 303.030
        case .tsuboM2: return value * 3.30579
        case .inchMm: return value * 25.4
        case .feetM: return value * 0.3048
        case .pyeongM2: return value * 3.3058
        }
    }
}

struct UnitConverterView: View {
    @State private var selectedType: ConversionType = .shakuMm
    @State private var inputText: String = "1"

    private var inputValue: Double { Double(inputText.replacingOccurrences(of: ",", with: ".")) ?? 0 }
    private var converted: Double { selectedType.convert(inputValue) }

    var body: some View {
        ZStack {
            WorkshopBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    ToolHeader(title: "単位変換", subtitle: "CRAFT UNIT CONVERTER", icon: "ruler.fill")

                    WorkshopPanel {
                        VStack(spacing: 17) {
                            conversionPicker
                            conversionBody
                        }
                    }
                    .padding(.horizontal, 18)

                    WorkshopPanel {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 9) {
                                Image(systemName: "note.text")
                                Text("現場メモ")
                            }
                            .font(.system(size: 17, weight: .black, design: .rounded))
                            .foregroundColor(ShokuninTheme.amber)

                            Text("尺・坪・インチ・フィートを現場で素早く確認できます。数値を入力すると換算結果が即時に更新されます。")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(ShokuninTheme.paper.opacity(0.86))
                                .lineSpacing(4)
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
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

    private var conversionPicker: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 9) {
            ForEach(ConversionType.allCases) { type in
                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.82)) {
                        selectedType = type
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(type.title)
                            .font(.system(size: 13, weight: .black, design: .rounded))
                        Text(type.rawValue)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .opacity(0.78)
                    }
                    .foregroundColor(selectedType == type ? .black : ShokuninTheme.paper)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedType == type ? AnyShapeStyle(ShokuninTheme.amberGradient) : AnyShapeStyle(ShokuninTheme.insetMetal))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedType == type ? Color.white.opacity(0.30) : ShokuninTheme.steel.opacity(0.22), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var conversionBody: some View {
        VStack(spacing: 13) {
            UnitValueBox(
                label: "入力",
                value: nil,
                unit: selectedType.fromUnit,
                inputText: $inputText,
                tint: ShokuninTheme.paper
            )

            ZStack {
                Rectangle()
                    .fill(ShokuninTheme.steel.opacity(0.16))
                    .frame(height: 1)
                Image(systemName: "arrow.down")
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(.black)
                    .frame(width: 42, height: 42)
                    .background(Circle().fill(ShokuninTheme.amberGradient))
                    .overlay(Circle().stroke(Color.white.opacity(0.28), lineWidth: 1))
            }

            UnitValueBox(
                label: "換算結果",
                value: formattedConverted,
                unit: selectedType.toUnit,
                inputText: .constant(""),
                tint: ShokuninTheme.amber
            )
        }
    }

    private var formattedConverted: String {
        if converted >= 1000 {
            return String(format: "%.1f", converted)
        } else if converted >= 10 {
            return String(format: "%.2f", converted)
        } else {
            return String(format: "%.3f", converted)
        }
    }
}

private struct UnitValueBox: View {
    let label: String
    let value: String?
    let unit: String
    @Binding var inputText: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(label)
                .font(.system(size: 12, weight: .black, design: .monospaced))
                .foregroundColor(ShokuninTheme.steel)
                .tracking(0.9)

            HStack(spacing: 10) {
                if let value {
                    Text(value)
                        .font(.system(size: 41, weight: .black, design: .rounded))
                        .foregroundColor(tint)
                        .monospacedDigit()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .minimumScaleFactor(0.52)
                        .lineLimit(1)
                } else {
                    TextField("0", text: $inputText)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 41, weight: .black, design: .rounded))
                        .foregroundColor(tint)
                        .monospacedDigit()
                        .minimumScaleFactor(0.52)
                        .lineLimit(1)
                }

                Text(unit)
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(ShokuninTheme.steelBright)
                    .frame(minWidth: 54, alignment: .trailing)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .padding(15)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(ShokuninTheme.insetMetal)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(tint.opacity(value == nil ? 0.44 : 0.30), lineWidth: 1)
                    )
            )
        }
    }
}
