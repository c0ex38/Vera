import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = SettingsViewModel()
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showPaywall = false
    
    var body: some View {
        VStack(spacing: 0) {
            VeraCustomHeader(title: L10n.Settings.title, subtitle: L10n.Settings.subtitle) {
                presentationMode.wrappedValue.dismiss()
            }
            
            Form {
                /*
                // Pro Section - Hızlı Erişim
                Section {
                    Button(action: { showPaywall = true }) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(subscriptionManager.isPro ? Color.themePrimary.opacity(0.1) : Color.orange.opacity(0.1))
                                    .frame(width: 44, height: 44)
                                Image(systemName: subscriptionManager.isPro ? "crown.fill" : "star.fill")
                                    .foregroundColor(subscriptionManager.isPro ? .themePrimary : .orange)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(subscriptionManager.isPro ? "Vera Pro Avantajları" : "Vera Pro'ya Geç")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.themeText)
                                Text(subscriptionManager.isPro ? "Reklamlar devre dışı bırakıldı." : "Reklamları kaldırın ve destek olun.")
                                    .font(.system(size: 12))
                                    .foregroundColor(.themeTextSecondary)
                            }
                            
                            Spacer()
                            
                            if subscriptionManager.isPro {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.themePrimary)
                            } else {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.themeTextSecondary.opacity(0.5))
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listRowBackground(Color.themeSurface)
                .sheet(isPresented: $showPaywall) {
                    SubscriptionView()
                }
                */

                Section(header: Text(L10n.Settings.general).foregroundColor(.themePrimary)) {
                    Toggle(L10n.Settings.notifications, isOn: $viewModel.notificationsEnabled)
                        .tint(.themePrimary)
                        .onChange(of: viewModel.notificationsEnabled) { _, isEnabled in
                            if isEnabled {
                                Task {
                                    let granted = await NotificationManager.shared.requestAuthorization()
                                    if !granted {
                                        DispatchQueue.main.async {
                                            viewModel.notificationsEnabled = false
                                        }
                                    }
                                }
                            } else {
                                NotificationManager.shared.cancelAllNotifications()
                            }
                        }
                    
                    Toggle(L10n.Settings.autoLocation, isOn: $viewModel.autoLocationEnabled)
                        .tint(.themePrimary)
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
            }
            .scrollContentBackground(.hidden)
            .background(Color.themeBackground)
        }
        .preferredColorScheme(viewModel.appTheme == 1 ? .light : (viewModel.appTheme == 2 ? .dark : nil))
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadAuthors()
        }
    }
}

