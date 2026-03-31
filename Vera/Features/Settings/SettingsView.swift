import SwiftUI
import Combine

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            VeraCustomHeader(title: L10n.Settings.title, subtitle: L10n.Settings.subtitle) {
                presentationMode.wrappedValue.dismiss()
            }
            
            Form {

                Section(header: Text(L10n.Settings.general).foregroundColor(.themePrimary)) {
                    NavigationLink(destination: NotificationSettingsView()) {
                        Label(L10n.Settings.notifications, systemImage: "bell.badge.fill")
                    }
                    
                    NavigationLink(destination: LocationSettingsView()) {
                        Label(L10n.Settings.autoLocation, systemImage: "location.circle.fill")
                    }
                }
                .listRowBackground(Color.themeSurface)
                
                Section(header: Text(L10n.Settings.appearance).foregroundColor(.themePrimary)) {
                    Picker(L10n.Settings.theme, selection: $viewModel.appTheme) {
                        Text(L10n.Settings.themeSystem).tag(0)
                        Text(L10n.Settings.themeLight).tag(1)
                        Text(L10n.Settings.themeDark).tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: viewModel.appTheme) { _, _ in
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                    
                    HStack {
                        Text(L10n.Settings.language)
                        Spacer()
                        Text(L10n.Settings.languageName).foregroundColor(.themeTextSecondary)
                    }
                }
                .listRowBackground(Color.themeSurface)
                
                Section(header: Text(L10n.Settings.quran).foregroundColor(.themePrimary)) {
                    Picker(L10n.Settings.quranAuthor, selection: $viewModel.selectedQuranAuthorId) {
                        ForEach(viewModel.availableAuthors) { author in
                            Text(author.name).tag(author.id)
                        }
                    }
                }
                .listRowBackground(Color.themeSurface)

                
                Section(header: Text(L10n.Settings.support).foregroundColor(.themePrimary)) {
                    NavigationLink(destination: ContactUsView()) {
                        Label(L10n.Settings.contact, systemImage: "envelope.fill")
                    }
                    
                    NavigationLink(destination: FAQView()) {
                        Label(L10n.Settings.faq, systemImage: "questionmark.circle.fill")
                    }
                    
                    NavigationLink(destination: AboutUsView()) {
                        Label(L10n.Settings.about, systemImage: "info.circle.fill")
                    }
                }
                .listRowBackground(Color.themeSurface)
                
                Section(header: Text(L10n.Settings.dataManagement).foregroundColor(.themePrimary)) {
                    Button(role: .destructive) {
                        viewModel.isShowingResetConfirmation = true
                    } label: {
                        Label(L10n.Settings.resetData, systemImage: "trash.fill")
                    }
                }
                .listRowBackground(Color.themeSurface)
            }
            .scrollContentBackground(.hidden)
            .background(Color.themeBackground)
            .alert(L10n.Settings.resetData, isPresented: $viewModel.isShowingResetConfirmation) {
                Button(L10n.Common.cancel, role: .cancel) { }
                Button(L10n.Settings.resetData, role: .destructive) {
                    viewModel.resetAllData()
                }
            } message: {
                Text(L10n.Settings.resetDataDesc)
            }
        }
        .preferredColorScheme(viewModel.appTheme == 1 ? .light : (viewModel.appTheme == 2 ? .dark : nil))
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadAuthors()
        }
    }
}

