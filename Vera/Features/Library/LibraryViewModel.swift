import SwiftUI
import Combine

@MainActor
class LibraryViewModel: ObservableObject {
    @Published var categories: [LibraryCategory] = []
    @Published var isLoading = false
    @Published var searchText: String = ""
    
    // Dependencies
    private let database = AppDatabaseManager.shared
    
    // Filtered categories based on search
    var filteredCategories: [LibraryCategory] {
        if searchText.isEmpty {
            return categories
        }
        
        return categories.compactMap { category in
            let filteredItems = category.items.filter { 
                $0.title.localizedCaseInsensitiveContains(searchText) || 
                ($0.meaning?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
            
            if !filteredItems.isEmpty {
                var newCategory = category
                newCategory.items = filteredItems
                return newCategory
            }
            return nil
        }
    }
    
    init() {
        loadData()
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
                    icon: "mosque.fill",
                    color: "#007AFF",
                    items: unifiedDualarItems
                )
                finalCategories.insert(unifiedCategory, at: 0)
            }
            
            // 5. Ensure sorting: Dualar first, then Namaz Rehber, then others
            self.categories = finalCategories.sorted { cat1, cat2 in
                if cat1.id == "unified_dualar" { return true }
                if cat2.id == "unified_dualar" { return false }
                
                if cat1.id == "namaz_rehber" { return true }
                if cat2.id == "namaz_rehber" { return false }
                
                if cat1.id == "dini_bilgiler" { return true }
                if cat2.id == "dini_bilgiler" { return false }
                
                return cat1.name < cat2.name
            }
            
            self.isLoading = false
        }
    }
}
