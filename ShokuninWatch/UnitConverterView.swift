import SwiftUI

enum ConversionType: String, CaseIterable, Identifiable {
    case shakuMm = "尺 → mm"
    case tsuboM2 = "坪 → m²"
    case inchMm = "inch → mm"
    case feetM = "feet → m"
    case pyeongM2 = "평 → m²"

    var id: String { rawValue }

    var fromUnit: String {
        switch self {
        case .shakuMm:  return "尺"
        case .tsuboM2:  return "坪"
        case .inchMm:   return "inch"
        case .feetM:    return "feet"
        case .pyeongM2: return "평"
        }
    }

    var toUnit: String {
        switch self {
        case .shakuMm:  return "mm"
        case .tsuboM2:  return "m²"
        case .inchMm:   return "mm"
        case .feetM:    return "m"
        case .pyeongM2: return "m²"
        }
    }

    func convert(_ value: Double) -> Double {
        switch self {
        case .shakuMm:  return value * 303.030
        case .tsuboM2:  return value * 3.30579
        case .inchMm:   return value * 25.4
        case .feetM:    return value * 0.3048
        case .pyeongM2: return value * 3.3058
        }
    }
}

struct UnitConverterView: View {
    @State private var selectedType: ConversionType = .shakuMm
    @State private var inputText: String = "1"

    var inputValue: Double { Double(inputText) ?? 0 }
    var converted: Double { selectedType.convert(inputValue) }

    var body: some View {
        ZStack {
            WorkshopBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    ToolHeader(title: "単位変換", subtitle: "CRAFT UNIT CONVERTER", icon: "ruler.fill")

                    WorkshopPanel {
                        VStack(spacing: 16) {
                            conversionPicker
                            conversionBody
                        }
                    }
                    .padding(.horizontal, 18)

                    WorkshopPanel {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("現場メモ", systemImage: "note.text")
                                .font(.system(size: 17, weight: .black))
                                .foregroundColor(ShokuninTheme.amber)
                            Text("尺・坪・インチ・フィートを現場ですばやく確認できます。数字をタップして入力してください。")
                                .font(.system(size: 15, weight: .semibold))
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
                .padding(.bottom, 26)
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
                    Text(type.rawValue)
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundColor(selectedType == type ? .black : ShokuninTheme.paper)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedType == type ? AnyShapeStyle(ShokuninTheme.buttonGradient) : AnyShapeStyle(Color.black.opacity(0.30)))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(selectedType == type ? ShokuninTheme.amber.opacity(0.0) : ShokuninTheme.steel.opacity(0.25), lineWidth: 1)
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
                inputText: $inputText
            )

            Image(systemName: "arrow.down")
                .font(.system(size: 22, weight: .black))
                .foregroundColor(ShokuninTheme.amber)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color.black.opacity(0.35)))

            UnitValueBox(
                label: "換算結果",
                value: formattedConverted,
                unit: selectedType.toUnit,
                inputText: .constant("")
            )
        }
    }

    var formattedConverted: String {
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

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 13, weight: .black, design: .monospaced))
                .foregroundColor(ShokuninTheme.steel)

            HStack(spacing: 10) {
                if let value {
                    Text(value)
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundColor(ShokuninTheme.amber)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .minimumScaleFactor(0.55)
                        .lineLimit(1)
                } else {
                    TextField("0", text: $inputText)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundColor(ShokuninTheme.paper)
                        .minimumScaleFactor(0.55)
                        .lineLimit(1)
                }

                Text(unit)
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(ShokuninTheme.steel)
                    .frame(minWidth: 50, alignment: .trailing)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.34))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(ShokuninTheme.amber.opacity(value == nil ? 0.45 : 0.25), lineWidth: 1))
            )
        }
    }
}
