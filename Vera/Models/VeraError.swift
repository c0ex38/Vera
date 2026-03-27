import Foundation

enum VeraError: LocalizedError, Sendable {
    case databaseError(String)
    case networkError(String)
    case locationError(String)
    case timeoutError
    case unknownError

    
    var errorDescription: String? {
        switch self {
        case .databaseError(let msg): return "Veritabanı Hatası: \(msg)"
        case .networkError(let msg): return "Ağ Hatası: \(msg)"
        case .locationError(let msg): return "Konum Hatası: \(msg)"
        case .timeoutError: return "İstek zaman aşımına uğradı."
        case .unknownError: return "Bilinmeyen bir hata oluştu."
        }
    }
}
