import SwiftUI
import Combine

@MainActor
class LibraryViewModel: ObservableObject {
    @Published var categories: [LibraryCategory] = []
    @Published var isLoading = false
    @Published var searchText: String = ""
    
    // Filtered categories based on search (cached)
    @Published var filteredCategories: [LibraryCategory] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let database = AppDatabaseManager.shared
    
    init() {
        setupBindings()
        loadData()
    }
    
    private func setupBindings() {
        // Automatically update filtered list when search text or categories change
        Publishers.CombineLatest($searchText, $categories)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] searchText, categories in
                self?.performFilter(text: searchText, in: categories)
            }
            .store(in: &cancellables)
    }
    
    private func performFilter(text: String, in categories: [LibraryCategory]) {
        if text.isEmpty {
            self.filteredCategories = categories
            return
        }
        
        self.filteredCategories = categories.compactMap { category in
            let filteredItems = category.items.filter { 
                $0.title.localizedCaseInsensitiveContains(text) || 
                ($0.meaning?.localizedCaseInsensitiveContains(text) ?? false)
            }
            
            if !filteredItems.isEmpty {
                var newCategory = category
                newCategory.items = filteredItems
                return newCategory
            }
            return nil
        }
    }
    
    func loadData() {
        isLoading = true
        
        Task {
            // 1. Fetch from SQL (Dynamic Library Content)
            let rawCategories = await database.fetchDynamicLibraryCategories()
            
            // 2. Fetch specific Prayer Surahs
            let sqlPrayers = await database.fetchLibraryPrayerSurahs()
            
            var finalCategories: [LibraryCategory] = []
            var unifiedDualarItems: [LibraryItem] = []
            
            // 3. Process and group
            for category in rawCategories {
                if category.id == "daily_prayers" || 
                   category.id == "protection_prayers" || 
                   category.id.contains("prayers") {
                    unifiedDualarItems.append(contentsOf: category.items)
                } else {
                    finalCategories.append(category)
                }
            }
            
            // Add SQL prayers to unified items
            unifiedDualarItems.append(contentsOf: sqlPrayers)
            
            // 4. Create Unified Dualar Category
            if !unifiedDualarItems.isEmpty {
                let unifiedCategory = LibraryCategory(
                    id: "unified_dualar",
                    name: "Dualar & Sureler",
                    icon: "building.columns.fill",
                    color: "#007AFF",
                    items: unifiedDualarItems
                )
                finalCategories.insert(unifiedCategory, at: 0)
            }
            
            // 5. Stable Priority-Based Sorting
            let priorityMap: [String: Int] = [
                "unified_dualar": 0,
                "namaz_rehber": 1,
                "dini_bilgiler": 2
            ]
            
            self.categories = finalCategories.sorted { cat1, cat2 in
                let p1 = priorityMap[cat1.id] ?? 999
                let p2 = priorityMap[cat2.id] ?? 999
                
                if p1 != p2 {
                    return p1 < p2
                }
                return cat1.name < cat2.name
            }
            
            self.isLoading = false
        }
    }
}
