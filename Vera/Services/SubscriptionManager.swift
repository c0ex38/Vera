import Foundation
import StoreKit
import Combine

@MainActor
class SubscriptionManager: ObservableObject, SubscriptionProvider {
    static let shared = SubscriptionManager()
    
    @Published private(set) var products: [Product] = []
    @Published private(set) var isPro: Bool = true // TEMPORARY: SET TO TRUE FOR SCREENSHOTS
    
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var fetchError: String? = nil
        
    private let productIDs = ["com.cozay.Vera.monthly", "com.cozay.Vera.yearly"]
    private var updates: Task<Void, Never>? = nil

    private init() {
        print("SubscriptionManager initialized. (Subscription fetching disabled by user request)")
        // Uygulama açılışında durumu kontrol et
        updates = observeTransactionUpdates()
        /* Task {
            await fetchProducts()
            await updateSubscriptionStatus()
        } */
    }

    deinit {
        updates?.cancel()
    }

    /// App Store'dan ürünleri çeker
    func fetchProducts() async {
        guard !isLoading else { return }
        
        isLoading = true
        fetchError = nil
        
        let ids = Set(productIDs)
        print("🔍 StoreKit Diagnostic: Fetching products for IDs: \(ids)")
        
        do {
            let fetchedProducts = try await Product.products(for: ids)
            
            if fetchedProducts.isEmpty {
                print("⚠️ StoreKit Diagnostic: No products returned from App Store/StoreKit Config.")
                
                #if DEBUG
                // Eğer hiçbir ürün gelmiyorsa ve DEBUG modundaysak, UI'ı test edebilmek için 
                // hata yerine bir uyarı verelim ama isterseniz manuel mock ekleyebiliriz.
                // Not: StoreKit 2 Product struct'ı dışarıdan init edilemez. 
                // Bu yüzden fetchError verip UI'da 'Demo Modu' butonu çıkaracağız.
                #endif
                
                fetchError = "Ürünler şu an yüklenemiyor. (StoreKit Kaynağı Bulunamadı)"
            } else {
                self.products = fetchedProducts
                print("✅ StoreKit Diagnostic: Successfully fetched \(fetchedProducts.count) products:")
                for product in fetchedProducts {
                    print("   - [\(product.id)] \(product.displayName) - \(product.displayPrice)")
                }
            }
        } catch {
            print("❌ StoreKit Diagnostic Error: \(error.localizedDescription)")
            fetchError = "Mağaza bağlantı hatası: \(error.localizedDescription)"
        }
        
        isLoading = false
    }

    /// Satın alma işlemini başlatır
    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updateSubscriptionStatus()
            await transaction.finish()
            return true
        case .userCancelled, .pending:
            return false
        @unknown default:
            return false
        }
    }

    /// Abonelik durumunu günceller
    func updateSubscriptionStatus() async {
        var purchasedIdentifiers: Set<String> = []
        
        // Mevcut tüm aktif işlemleri kontrol et
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                // Sadece pro ürünlerini kontrol et
                if productIDs.contains(transaction.productID) {
                    if transaction.revocationDate == nil {
                        purchasedIdentifiers.insert(transaction.productID)
                    }
                }
            }
        }
        
        self.isPro = !purchasedIdentifiers.isEmpty
        print("Subscription Status Updated: \(isPro ? "PRO" : "FREE")")
        
        // Pro durumunu UserDefaults'a da yedekleyelim (Hızlı kontrol için)
        UserDefaults.standard.set(isPro, forKey: "isProAccount")
    }
    
    /// Geçmiş satın almaları geri yükler (Restore)
    func restorePurchases() async {
        try? await AppStore.sync()
        await updateSubscriptionStatus()
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) {
            for await _ in Transaction.updates {
                await updateSubscriptionStatus()
            }
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
