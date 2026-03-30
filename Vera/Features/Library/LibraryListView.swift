import SwiftUI

struct LibraryListView: View {
    @StateObject private var viewModel = LibraryViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    // Grid Setup
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color.themeBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header
                
                // Search Bar
                searchBar
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, minHeight: 200)
                        } else if viewModel.categories.isEmpty {
                            Text(L10n.Common.error)
                                .foregroundColor(.themeTextSecondary)
                                .frame(maxWidth: .infinity, minHeight: 200)
                        } else {
                            // Categories Grid
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(viewModel.filteredCategories) { category in
                                    NavigationLink(destination: categoryDetailList(category)) {
                                        categoryCard(category)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        }
                    }
                    .padding(.bottom, 120)
                }
                .mask(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .black, location: 0),
                            .init(color: .black, location: 0.85),
                            .init(color: .clear, location: 1)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Components
    
    private var header: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.themeText)
                    .frame(width: 40, height: 40)
                    .background(Color.themeSurface)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
            }
            
            Spacer()
            
            Text("Kütüphane")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.themeText)
            
            Spacer()
            
            // Empty placeholder for symmetry
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(Color.themeSurface.ignoresSafeArea(edges: .top))
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.themeTextSecondary)
            
            TextField("Dua, sure veya bilgi ara...", text: $viewModel.searchText)
                .font(.system(size: 15))
            
            if !viewModel.searchText.isEmpty {
                Button(action: { viewModel.searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.themeTextSecondary.opacity(0.6))
                }
            }
        }
        .padding(12)
        .background(Color.themeSurface)
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .shadow(color: .black.opacity(0.03), radius: 8, y: 4)
    }
    
    private func categoryCard(_ category: LibraryCategory) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: category.color ?? "#007AFF").opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: category.icon ?? "book.fill")
                    .font(.system(size: 22))
                    .foregroundColor(Color(hex: category.color ?? "#007AFF"))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.themeText)
                    .lineLimit(2)
                
                Text("\(category.items.count) İçerik")
                    .font(.system(size: 12))
                    .foregroundColor(.themeTextSecondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.themeSurface)
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
    }
    
    private func categoryDetailList(_ category: LibraryCategory) -> some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Mini Header
                HStack {
                    Button(action: { /* Automatic back button works */ }) {
                        // We use the default back button or define a custom one in this child view
                    }
                    Text(category.name)
                        .font(.headline)
                        .foregroundColor(.themeText)
                    Spacer()
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(category.items) { item in
                            NavigationLink(destination: LibraryDetailView(item: item)) {
                                itemRow(item)
                            }
                        }
                    }
                    .padding(20)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func itemRow(_ item: LibraryItem) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.themeText)
                
                if let meaning = item.meaning {
                    Text(meaning)
                        .font(.system(size: 13))
                        .foregroundColor(.themeTextSecondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.themeTextSecondary.opacity(0.4))
        }
        .padding(16)
        .background(Color.themeSurface)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.03), radius: 8, y: 4)
    }
}

#Preview {
    LibraryListView()
}
