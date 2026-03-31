import SwiftUI
import Combine

@MainActor
class AmelDefteriViewModel: ObservableObject {
    @Published var selectedDate = Date()
    @Published var tasksWithStatus: [(task: SpiritualTask, isCompleted: Bool)] = []
    @Published var isLoading = false
    
    private let database = AppDatabaseManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    var progressPercentage: Double {
        guard !tasksWithStatus.isEmpty else { return 0 }
        let completedCount = tasksWithStatus.filter { $0.isCompleted }.count
        return Double(completedCount) / Double(tasksWithStatus.count)
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: selectedDate)
    }
    
    init() {
        // Refresh when date changes
        $selectedDate
            .sink { [weak self] _ in
                Task { [weak self] in
                    await self?.loadData()
                }
            }
            .store(in: &cancellables)
    }
    
    func loadData() async {
        isLoading = true
        let progress = await database.fetchDailyProgress(for: dateString)
        
        // Map all predefined tasks to their status
        self.tasksWithStatus = SpiritualTask.allCases.map { task in
            let status = progress.first(where: { $0.taskId == task.id })?.isCompleted ?? false
            return (task, status)
        }
        
        isLoading = false
    }
    
    func toggleTask(_ task: SpiritualTask) {
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.prepare()
        impact.impactOccurred()
        
        // Optimistic UI update
        if let index = tasksWithStatus.firstIndex(where: { $0.task.id == task.id }) {
            tasksWithStatus[index].isCompleted.toggle()
        }
        
        // Persist to DB
        Task {
            await database.toggleDailyTask(taskId: task.id, date: dateString)
        }
    }
    
    func nextDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
    }
    
    func previousDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
    }
    
    func goToToday() {
        selectedDate = Date()
    }
}
