import Foundation

struct ZakatInputModel: Codable, Equatable {
    // 1. Nakit ve Banka Hesapları
    var cashInHand: Double = 0.0
    var bankAccounts: Double = 0.0
    var foreignCurrency: Double = 0.0 // İstendiğinde güncel kura çevrilerek girildiği varsayılır
    
    // 2. Ziynet (Altın ve Gümüş)
    var gold24k: Double = 0.0 // Gram cinsinden
    var gold22k: Double = 0.0 // Gram cinsinden
    var silver: Double = 0.0 // Gram cinsinden
    
    // 3. Ticaret Malları ve Alacaklar
    var commercialGoods: Double = 0.0
    var receivables: Double = 0.0
    
    // 4. Borçlar (Bir yıl içinde ödenecekler)
    var debts: Double = 0.0
    
    // 5. Tarım (Öşür) -> Gram/Miktar veya doğrudan Nakit Değeri üzerinden hesaplanabilir. (Nakit değeri tutuyoruz)
    var agriculturalYieldValue: Double = 0.0 
    var isIrrigationCostly: Bool = false // Masraflı (Sulama) %5, Masrafsız (Doğa) %10
    
    // Altın/Gümüş güncel TL fiyatı (Kullanıcı kendi girebilir)
    var currentGoldPrice: Double = 2300.0 // Örnek default değer
    var currentSilverPrice: Double = 27.0 // Örnek default değer
}

struct ZakatResultModel: Equatable {
    var totalAssets: Double
    var totalDebts: Double
    var netAssets: Double
    var nisabThreshold: Double // 80.18 gram altının mevcut TL karşılığı
    
    var isEligibleForGeneralZakat: Bool
    var generalZakatAmount: Double
    
    var isEligibleForAgricultureZakat: Bool
    var agricultureZakatAmount: Double
    
    var totalZakatAmount: Double {
        return generalZakatAmount + agricultureZakatAmount
    }
}
