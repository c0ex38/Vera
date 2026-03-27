import SwiftUI

struct ZakatHomeView: View {
    @StateObject private var viewModel = ZakatCalculatorViewModel()
    @State private var showInfoSheet = false
    
    // UI animasyonları için
    @FocusState private var focusedField: Field?
    enum Field {
        case cash, bank, foreign, gold24, gold22, silver, commercial, receivables, debts, agriYield, goldPrice, silverPrice
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // 1. Durum Kartı (Result Card)
                ZakatResultCard(result: viewModel.result)
                    .padding(.horizontal)
                
                // 2. Fiyat Ayarları (Altın/Gümüş TL Değeri)
                VStack(spacing: 12) {
                    HStack {
                        Text(L10n.Zakat.pricesTitle)
                            .font(.caption).bold()
                            .foregroundColor(.themeTextSecondary.opacity(0.7))
                        Spacer()
                    }
                    
                    HStack(spacing: 16) {
                        ZakatTextField(title: L10n.Zakat.goldPrice, value: $viewModel.input.currentGoldPrice)
                            .focused($focusedField, equals: .goldPrice)
                        ZakatTextField(title: L10n.Zakat.silverPrice, value: $viewModel.input.currentSilverPrice)
                            .focused($focusedField, equals: .silverPrice)
                    }
                }
                .padding()
                .background(Color.themeSurface)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.03), radius: 8, y: 4)
                .padding(.horizontal)
                
                // 3. Varlık Giriş Formu
                VStack(spacing: 20) {
                    Group {
                        ZakatInputSection(
                            title: L10n.Zakat.cashBank,
                            icon: "banknote",
                            color: .green
                        ) {
                            ZakatTextField(title: L10n.Zakat.cash, value: $viewModel.input.cashInHand)
                                .focused($focusedField, equals: .cash)
                            ZakatTextField(title: L10n.Zakat.bank, value: $viewModel.input.bankAccounts)
                                .focused($focusedField, equals: .bank)
                            ZakatTextField(title: L10n.Zakat.foreign, value: $viewModel.input.foreignCurrency)
                                .focused($focusedField, equals: .foreign)
                        }
                        
                        ZakatInputSection(
                            title: L10n.Zakat.preciousMetals,
                            icon: "sparkles",
                            color: .yellow
                        ) {
                            ZakatTextField(title: L10n.Zakat.gold24k, value: $viewModel.input.gold24k)
                                .focused($focusedField, equals: .gold24)
                            ZakatTextField(title: L10n.Zakat.gold22k, value: $viewModel.input.gold22k)
                                .focused($focusedField, equals: .gold22)
                            ZakatTextField(title: L10n.Zakat.silverGr, value: $viewModel.input.silver)
                                .focused($focusedField, equals: .silver)
                        }
                        
                        ZakatInputSection(
                            title: L10n.Zakat.trade,
                            icon: "briefcase",
                            color: .blue
                        ) {
                            ZakatTextField(title: L10n.Zakat.commercial, value: $viewModel.input.commercialGoods)
                                .focused($focusedField, equals: .commercial)
                            ZakatTextField(title: L10n.Zakat.receivables, value: $viewModel.input.receivables)
                                .focused($focusedField, equals: .receivables)
                        }
                        
                        ZakatInputSection(
                            title: L10n.Zakat.debtsTitle,
                            icon: "minus.square",
                            color: .red
                        ) {
                            ZakatTextField(title: L10n.Zakat.debts, value: $viewModel.input.debts)
                                .focused($focusedField, equals: .debts)
                        }
                        
                        ZakatInputSection(
                            title: L10n.Zakat.agriculture,
                            icon: "leaf",
                            color: .mint
                        ) {
                            ZakatTextField(title: L10n.Zakat.yield, value: $viewModel.input.agriculturalYieldValue)
                                .focused($focusedField, equals: .agriYield)
                            
                            Toggle(isOn: $viewModel.input.isIrrigationCostly) {
                                VStack(alignment: .leading) {
                                    Text(L10n.Zakat.irrigationCostly)
                                        .font(.subheadline).bold()
                                    Text(viewModel.input.isIrrigationCostly ? L10n.Zakat.rate5 : L10n.Zakat.rate10)
                                        .font(.caption)
                                        .foregroundColor(.themeTextSecondary)
                                }
                            }
                            .tint(.mint)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .padding(.top, 20)
        }
        .background(Color.themeBackground.ignoresSafeArea())
        .navigationTitle(L10n.Zakat.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showInfoSheet = true }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.themePrimary)
                }
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(L10n.Common.done) {
                    focusedField = nil
                }
            }
        }
        .sheet(isPresented: $showInfoSheet) {
            ZakatInfoSheet()
        }
    }
}

// MARK: - Result Card (Glassmorphic)
struct ZakatResultCard: View {
    let result: ZakatResultModel
    
    var body: some View {
        VStack(spacing: 20) {
            
            HStack(spacing: 15) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.Zakat.netAssets)
                        .font(.caption2).bold()
                        .foregroundColor(.white.opacity(0.7))
                    Text("₺\(result.netAssets, specifier: "%.2f")")
                        .font(.title3).bold()
                        .foregroundColor(.white)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(L10n.Zakat.nisabThreshold)
                        .font(.caption2).bold()
                        .foregroundColor(.white.opacity(0.7))
                    Text("₺\(result.nisabThreshold, specifier: "%.2f")")
                        .font(.subheadline).bold()
                        .foregroundColor(.white)
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.3))
            
            if result.totalZakatAmount > 0 {
                VStack(alignment: .center, spacing: 8) {
                    Text(L10n.Zakat.totalZakat)
                        .font(.caption).bold()
                        .foregroundColor(.white.opacity(0.9))
                    Text("₺\(result.totalZakatAmount, specifier: "%.2f")")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 5, y: 2)
                    
                    if result.isEligibleForAgricultureZakat && result.isEligibleForGeneralZakat {
                        Text(L10n.Zakat.detail(general: result.generalZakatAmount, agriculture: result.agricultureZakatAmount))
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            } else {
                VStack(alignment: .center, spacing: 8) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                    Text(L10n.Zakat.notRequired)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.vertical, 10)
            }
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: result.totalZakatAmount > 0 ? [.themePrimary, .themePrimary.opacity(0.8)] : [.gray, .gray.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(24)
        .shadow(color: result.totalZakatAmount > 0 ? Color.themePrimary.opacity(0.4) : .black.opacity(0.1), radius: 15, y: 8)
        .animation(.easeInOut, value: result.totalZakatAmount)
    }
}

// MARK: - Input Section
struct ZakatInputSection<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: Content
    
    init(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(color)
                }
                Text(title)
                    .font(.headline).bold()
                    .foregroundColor(.themeSecondary)
            }
            
            VStack(spacing: 12) {
                content
            }
        }
        .padding()
        .background(Color.themeSurface)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 10, y: 5)
    }
}

// MARK: - Custom TextField
struct ZakatTextField: View {
    let title: String
    @Binding var value: Double
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.themeText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Spacer(minLength: 10)
            
            TextField("0.0", value: $value, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .font(.system(.body, design: .monospaced).bold())
                .foregroundColor(.themePrimary)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.themeBackground)
                .cornerRadius(8)
                .frame(width: 120)
        }
    }
}
