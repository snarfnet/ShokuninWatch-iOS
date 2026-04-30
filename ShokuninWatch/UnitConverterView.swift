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
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                Text("単位変換")
                    .font(.headline)
                    .foregroundColor(.orange)

                Picker("変換タイプ", selection: $selectedType) {
                    ForEach(ConversionType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                VStack(spacing: 8) {
                    HStack {
                        TextField("値を入力", text: $inputText)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 36, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(12)

                        Text(selectedType.fromUnit)
                            .font(.title2)
                            .foregroundColor(.gray)
                            .frame(width: 50)
                    }

                    Image(systemName: "arrow.down.circle.fill")
                        .font(.title)
                        .foregroundColor(.orange)

                    HStack {
                        Text(formattedConverted)
                            .font(.system(size: 36, weight: .bold, design: .monospaced))
                            .foregroundColor(.orange)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(12)

                        Text(selectedType.toUnit)
                            .font(.title2)
                            .foregroundColor(.gray)
                            .frame(width: 50)
                    }
                }
                .padding(.horizontal)

                Spacer()

                BannerAdView(adUnitID: "ca-app-pub-9404799280370656/5212572496")
                    .frame(height: 50)
            }
            .padding(.top)
        }
        .onTapGesture { UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) }
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
