import SwiftUI

struct ZakatInfoSheet: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    Text(L10n.Zakat.Info.howTo)
                        .font(.title2).bold()
                        .foregroundColor(.themePrimary)
                    
                    Text(L10n.Zakat.Info.howToDesc)
                        .foregroundColor(.themeTextSecondary)
                    
                    Divider()
                    
                    // Zinet Eşyaları
                    Group {
                        Text(L10n.Zakat.Info.ornament)
                            .font(.headline)
                            .foregroundColor(.themeSecondary)
                        Text(L10n.Zakat.Info.ornamentDesc)
                            .foregroundColor(.themeTextSecondary)
                    }
                    
                    // Zirai Mahsuller
                    Group {
                        Text(L10n.Zakat.Info.agriculture)
                            .font(.headline)
                            .foregroundColor(.themeSecondary)
                        Text(L10n.Zakat.Info.agricultureDesc)
                            .foregroundColor(.themeTextSecondary)
                    }
                    
                    Divider()
                    
                    // 1 Kameri Yıl ve Nisap
                    Group {
                        Text(L10n.Zakat.Info.nisab)
                            .font(.headline)
                            .foregroundColor(.themeSecondary)
                        Text(L10n.Zakat.Info.nisabDesc)
                            .foregroundColor(.themeTextSecondary)
                    }
                    
                    Divider()
                    
                    // Maaş ve Ücret Zekatı
                    Group {
                        Text(L10n.Zakat.Info.salary)
                            .font(.headline)
                            .foregroundColor(.themeSecondary)
                        Text(L10n.Zakat.Info.salaryDesc)
                            .foregroundColor(.themeTextSecondary)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
            .background(Color.themeBackground)
            .navigationTitle(L10n.Zakat.Info.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L10n.Common.close) {
                        dismiss()
                    }
                    .foregroundColor(.themePrimary)
                    .font(.headline)
                }
            }
        }
    }
}
