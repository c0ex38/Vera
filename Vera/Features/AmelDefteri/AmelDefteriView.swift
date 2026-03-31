import SwiftUI

struct AmelDefteriView: View {
    @StateObject private var viewModel = AmelDefteriViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background
            Color.themeBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Progress Section
                        progressCard
                        
                        // Date Switcher
                        dateSwitcher
                        
                        // Tasks List
                        tasksListView
                    }
                    .padding(20)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            Task {
                await viewModel.loadData()
            }
        }
    }
    
    // MARK: - Components
    
    private var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.themeText)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.themeSurface))
                    .shadow(color: .black.opacity(0.05), radius: 5)
            }
            
            Spacer()
            
            Text(L10n.AmelDefteri.title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.themeText)
            
            Spacer()
            
            Button(action: { viewModel.goToToday() }) {
                Text(L10n.AmelDefteri.today)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.themePrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.themePrimary.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.themeSurface.ignoresSafeArea(edges: .top))
    }
    
    private var progressCard: some View {
        VStack(spacing: 16) {
            ZStack {
                // Background Track
                Circle()
                    .stroke(Color.themePrimary.opacity(0.1), lineWidth: 15)
                    .frame(width: 120, height: 120)
                
                // Progress Bar
                Circle()
                    .trim(from: 0, to: viewModel.progressPercentage)
                    .stroke(
                        LinearGradient(
                            colors: [.themePrimary, .themePrimary.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 15, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(), value: viewModel.progressPercentage)
                
                // Percentage Text
                VStack(spacing: 2) {
                    Text("\(Int(viewModel.progressPercentage * 100))%")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.themeText)
                    Text(L10n.AmelDefteri.progress)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.themeTextSecondary)
                }
            }
            .padding(.top, 10)
            
            Text(progressMessage)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.themeTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .veraGlassCard(cornerRadius: 32)
    }
    
    private var dateSwitcher: some View {
        HStack {
            Button(action: { viewModel.previousDay() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.themeTextSecondary)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.themeSurface))
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .foregroundStyle(.themePrimary)
                Text(formattedDate)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.themeText)
            }
            
            Spacer()
            
            Button(action: { viewModel.nextDay() }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.themeTextSecondary)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.themeSurface))
            }
        }
        .padding(.horizontal, 10)
    }
    
    private var tasksListView: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.tasksWithStatus, id: \.task.id) { item in
                TaskRow(task: item.task, isCompleted: item.isCompleted) {
                    viewModel.toggleTask(item.task)
                }
            }
        }
    }
    
    // MARK: - Computed
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: viewModel.selectedDate)
    }
    
    private var progressMessage: String {
        let percent = viewModel.progressPercentage
        if percent == 1.0 { return L10n.AmelDefteri.msgSuccess }
        if percent >= 0.5 { return L10n.AmelDefteri.msgGreat }
        if percent > 0 { return L10n.AmelDefteri.msgStarted }
        return L10n.AmelDefteri.msgEmpty
    }
}

struct TaskRow: View {
    let task: SpiritualTask
    let isCompleted: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon Background
                ZStack {
                    Circle()
                        .fill(isCompleted ? Color.themePrimary.opacity(0.15) : Color.themeBackground)
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: task.icon)
                        .font(.system(size: 20))
                        .foregroundStyle(isCompleted ? .themePrimary : .themeTextSecondary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(isCompleted ? .themeText : .themeText.opacity(0.8))
                    
                    Text(isCompleted ? L10n.AmelDefteri.completed : L10n.AmelDefteri.pending)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(isCompleted ? .themePrimary : .themeTextSecondary.opacity(0.6))
                }
                
                Spacer()
                
                // Custom Toggle
                ZStack {
                    Circle()
                        .stroke(isCompleted ? Color.themePrimary : Color.themeTextSecondary.opacity(0.2), lineWidth: 2)
                        .frame(width: 28, height: 28)
                    
                    if isCompleted {
                        Circle()
                            .fill(Color.themePrimary)
                            .frame(width: 18, height: 18)
                            .transition(.scale.combined(with: .opacity))
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .black))
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .veraGlassCard(cornerRadius: 24)
            .scaleEffect(isCompleted ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isCompleted)
        }
    }
}

#Preview {
    AmelDefteriView()
}
