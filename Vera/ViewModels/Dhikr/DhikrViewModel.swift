import SwiftUI
import Combine
import AudioToolbox

@MainActor
class DhikrViewModel: ObservableObject {
    @Published var count: Int = 0 {
        didSet { saveToDB() }
    }
    
    @Published var target: Int = 33 {
        didSet { saveToDB() }
    }
    
    @Published var title: String = "" {
        didSet { saveToDB() }
    }
    
    @Published var isSoundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSoundEnabled, forKey: "dhikrSound")
        }
    }
    
    private var dhikrId: UUID = UUID()
    private let database: DatabaseProvider
    private let tickHaptic = UISelectionFeedbackGenerator()
    private let heavyHaptic = UINotificationFeedbackGenerator()
    
    init(database: DatabaseProvider? = nil) {
        self.database = database ?? AppDatabaseManager.shared
        if UserDefaults.standard.object(forKey: "dhikrSound") == nil {

            self.isSoundEnabled = true
        } else {
            self.isSoundEnabled = UserDefaults.standard.bool(forKey: "dhikrSound")
        }
        
        tickHaptic.prepare()
        heavyHaptic.prepare()
        loadInitialData()
    }
    
    private func loadInitialData() {
        Task {
            if let savedDhikr = await database.fetchActiveDhikr() {
                self.dhikrId = savedDhikr.id
                self.title = savedDhikr.title
                self.count = savedDhikr.count
                self.target = savedDhikr.target ?? 33
            } else {
                self.dhikrId = UUID()
                self.title = "Serbest Zikir"
                self.count = 0
                self.target = 33
                
                let initialDhikr = Dhikr(id: dhikrId, title: title, count: count, target: target)
                await database.saveActiveDhikr(initialDhikr)
            }
        }
    }
    
    private func saveToDB() {
        let active = Dhikr(id: dhikrId, title: title, count: count, target: target)
        Task {
            await database.saveActiveDhikr(active)
        }
    }

    
    func increment() {

        count += 1
        
        let reachedTarget = target > 0 && count % target == 0
        
        // Hedefe ulaşıldıysa veya katlarıysa büyük titreşim/farklı ses, değilse hafif titreşim/tık sesi
        if reachedTarget {
            heavyHaptic.notificationOccurred(.success)
            if isSoundEnabled {
                AudioServicesPlaySystemSound(1057) // Success ses (Tink)
            }
        } else {
            tickHaptic.selectionChanged()
            tickHaptic.prepare() // Next one ready
            if isSoundEnabled {
                AudioServicesPlaySystemSound(1104) // Normal sayaç sesi (Tock)
            }
        }
    }
    
    func reset() {
        count = 0
        heavyHaptic.notificationOccurred(.warning)
    }
    
    func loadTemplate(newTitle: String, newTarget: Int) {
        self.title = newTitle
        self.target = newTarget
        self.count = 0
        heavyHaptic.notificationOccurred(.success)
    }
}
