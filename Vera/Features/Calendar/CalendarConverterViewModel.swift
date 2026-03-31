import SwiftUI
import Combine

@MainActor
class CalendarConverterViewModel: ObservableObject {
    
    @Published var gregorianDate: Date = Date() {
        didSet {
            if !isUpdatingFromHijri {
                updateHijriFromGregorian()
            }
        }
    }
    
    @Published var hijriDate: Date = Date() { // This 'Date' object will be interpreted using Islamic calendar
        didSet {
            if !isUpdatingFromGregorian {
                updateGregorianFromHijri()
            }
        }
    }
    
    // Formatted strings for display
    @Published var formattedGregorian: String = ""
    @Published var formattedHijri: String = ""
    
    private var isUpdatingFromGregorian = false
    private var isUpdatingFromHijri = false
    
    private let gregorianCalendar = Calendar(identifier: .gregorian)
    private let hijriCalendar = Calendar(identifier: .islamicUmmAlQura)
    
    init() {
        updateHijriFromGregorian()
    }
    
    private func updateHijriFromGregorian() {
        isUpdatingFromGregorian = true
        
        // Convert Gregorian date to Hijri components
        let components = hijriCalendar.dateComponents([.year, .month, .day], from: gregorianDate)
        if let newHijriDate = hijriCalendar.date(from: components) {
            self.hijriDate = newHijriDate
        }
        
        updateFormats()
        isUpdatingFromGregorian = false
    }
    
    private func updateGregorianFromHijri() {
        isUpdatingFromHijri = true
        
        // Convert Hijri date components to Gregorian date
        // Note: hijriDate internally is just a Date, we need to extract its components using hijriCalendar
        let components = hijriCalendar.dateComponents([.year, .month, .day], from: hijriDate)
        if let newGregorianDate = hijriCalendar.date(bySettingHour: 12, minute: 0, second: 0, of: hijriCalendar.date(from: components) ?? Date()) {
            // We use standard calendar to get the Gregorian representation
            self.gregorianDate = newGregorianDate
        }
        
        updateFormats()
        isUpdatingFromHijri = false
    }
    
    private func updateFormats() {
        let gFormatter = DateFormatter()
        gFormatter.dateStyle = .long
        gFormatter.calendar = gregorianCalendar
        formattedGregorian = gFormatter.string(from: gregorianDate)
        
        let hFormatter = DateFormatter()
        hFormatter.calendar = hijriCalendar
        hFormatter.dateFormat = "d MMMM yyyy"
        // Ensure month names are correctly localized for Islamic calendar
        formattedHijri = hFormatter.string(from: hijriDate)
    }
    
    func copyGregorian() {
        UIPasteboard.general.string = formattedGregorian
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    func copyHijri() {
        UIPasteboard.general.string = formattedHijri
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
