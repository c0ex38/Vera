import Foundation
import Combine
import SwiftUI

class ZakatCalculatorViewModel: ObservableObject {
    @Published var input = ZakatInputModel()
    @Published var result = ZakatResultModel(
        totalAssets: 0, 
        totalDebts: 0, 
        netAssets: 0, 
        nisabThreshold: 0, 
        isEligibleForGeneralZakat: false, 
        generalZakatAmount: 0, 
        isEligibleForAgricultureZakat: false, 
        agricultureZakatAmount: 0
    )
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Girdiler her değiştiğinde hesabı anında güncelle
        $input
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] newInput in
                self?.calculateZakat(from: newInput)
            }
            .store(in: &cancellables)
    }
    
    func calculateZakat(from model: ZakatInputModel) {
        // Altın ve gümüş TL değerleri
        let gold24Value = model.gold24k * model.currentGoldPrice
        // 22 Ayar altın genellikle 24 ayarın %91.6'sı saf altındır. 
        // Ancak Diyanet'e göre doğrudan gramı nisaba eklenir, ticari değerinden (bozdurma fiyatı) zekat verilir. 
        // Biz kolaylık olsun diye güncel hurda altın/22 ayar fiyatını girdiğini varsayabiliriz ya da 
        // 24 ayarın %91.6'sı (0.916) fiyatı üzerinden değerlendirebiliriz.
        let gold22Price = model.currentGoldPrice * 0.916
        let gold22Value = model.gold22k * gold22Price
        
        let silverValue = model.silver * model.currentSilverPrice
        
        // 1. Toplam Varlık (Tarım haricindeki DÖNER sermaye / nakdi varlıklar)
        let totalGeneralAssets = model.cashInHand 
                                + model.bankAccounts 
                                + model.foreignCurrency 
                                + gold24Value 
                                + gold22Value 
                                + silverValue 
                                + model.commercialGoods 
                                + model.receivables
                                
        // 2. Toplam Borç
        let totalDebts = model.debts
        
        // 3. Net Varlık (Safi Zenginlik)
        let netAssets = max(0, totalGeneralAssets - totalDebts)
        
        // 4. Nisap Sınırı (80.18 Gram Altın)
        let nisabThreshold = 80.18 * model.currentGoldPrice
        
        // 5. Zekat Uygunluk (Genel Zekat)
        let isEligible = netAssets >= nisabThreshold
        let generalZakatAmount = isEligible ? (netAssets * 0.025) : 0.0
        
        // 6. Tarım Zekatı (Öşür)
        // Tarım zekatında nisap miktarı klasik mezheplere göre 5 vesk (~653 kg) üründür.
        // Modern uygulamada ürünün mahiyetine göre veya gelirine göre hesaplanır. Biz doğrudan kullanıcı
        // parasal değerini (veya 5 veski geçtiğini teyit ederek) girdiğini varsayıyoruz. 
        // Girdiği değer > 0 ise hesaplıyoruz. %5 masraflı, %10 masrafsız
        var agricultureZakat = 0.0
        let isAgriEligible = model.agriculturalYieldValue > 0
        if isAgriEligible {
            let rate = model.isIrrigationCostly ? 0.05 : 0.10
            agricultureZakat = model.agriculturalYieldValue * rate
        }
        
        self.result = ZakatResultModel(
            totalAssets: totalGeneralAssets,
            totalDebts: totalDebts,
            netAssets: netAssets,
            nisabThreshold: nisabThreshold,
            isEligibleForGeneralZakat: isEligible,
            generalZakatAmount: generalZakatAmount,
            isEligibleForAgricultureZakat: isAgriEligible,
            agricultureZakatAmount: agricultureZakat
        )
    }
}
