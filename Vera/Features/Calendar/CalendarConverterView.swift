import SwiftUI

struct CalendarConverterView: View {
    @StateObject private var viewModel = CalendarConverterViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VeraCustomHeader(title: L10n.CalendarConverter.title, subtitle: L10n.CalendarConverter.selectDate)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Gregorian Card
                    dateCard(
                        title: L10n.CalendarConverter.gregorian,
                        formattedDate: viewModel.formattedGregorian,
                        date: $viewModel.gregorianDate,
                        icon: "calendar",
                        color: .blue,
                        onCopy: viewModel.copyGregorian
                    )
                    
                    // Connection Icon
                    Image(systemName: "arrow.up.arrow.down.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.linearGradient(colors: [.blue, .emerald], startPoint: .top, endPoint: .bottom))
                        .shadow(color: .emerald.opacity(0.3), radius: 5)
                    
                    // Hijri Card
                    dateCard(
                        title: L10n.CalendarConverter.hijri,
                        formattedDate: viewModel.formattedHijri,
                        date: $viewModel.hijriDate,
                        icon: "moon.stars.fill",
                        color: .emerald,
                        calendar: Calendar(identifier: .islamicUmmAlQura),
                        onCopy: viewModel.copyHijri
                    )
                    
                    // Info Section
                    VStack(alignment: .leading, spacing: 12) {
                        Label {
                            Text(NSLocalizedString("İslami takvim (Hicri), Ay döngüsüne dayanır ve Ümmü'l-Kura standardı ile hesaplanır.", comment: ""))
                                .font(.subheadline)
                                .foregroundColor(.themeTextSecondary)
                        } icon: {
                            Image(systemName: "info.circle")
                                .foregroundColor(.emerald)
                        }
                    }
                    .padding()
                    .background(Color.emerald.opacity(0.05))
                    .cornerRadius(16)
                    .padding(.top, 10)
                }
                .padding(20)
            }
        }
        .background(
            VeraBackgroundView(prayerTheme: .dhuhr) // Bu görünümde default dhuhr kullanabiliriz veya Home'dan inject edilebilir
        )
        .navigationBarHidden(true)
    }
    
    @ViewBuilder
    private func dateCard(
        title: String,
        formattedDate: String,
        date: Binding<Date>,
        icon: String,
        color: Color,
        calendar: Calendar = Calendar(identifier: .gregorian),
        onCopy: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.headline)
                    .foregroundColor(color)
                
                Spacer()
                
                Button(action: onCopy) {
                    Image(systemName: "doc.on.doc.fill")
                        .font(.subheadline)
                        .foregroundColor(.themeTextSecondary)
                        .padding(8)
                        .background(Color.themeSurface.opacity(0.8))
                        .clipShape(Circle())
                }
            }
            
            Text(formattedDate)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.themeText)
            
            Divider()
                .background(color.opacity(0.2))
            
            // Inline Date Picker
            DatePicker("", selection: date, displayedComponents: [.date])
                .datePickerStyle(.wheel)
                .environment(\.calendar, calendar)
                .environment(\.locale, Locale(identifier: L10n.Settings.languageName == "Türkçe" ? "tr_TR" : "en_US"))
                .labelsHidden()
                .frame(maxHeight: 180)
        }
        .padding(20)
        .veraGlassCard(cornerRadius: 24)
    }
}

#Preview {
    CalendarConverterView()
}
