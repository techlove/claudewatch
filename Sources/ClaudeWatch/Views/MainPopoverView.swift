import SwiftUI

struct MainPopoverView: View {
    @ObservedObject var store: UsageStore

    var body: some View {
        if !store.auth.isLoggedIn {
            LoginView(auth: store.auth)
        } else if store.showingSettings {
            SettingsView(store: store)
                .transition(.move(edge: .trailing).combined(with: .opacity))
        } else {
            mainContent
                .transition(.move(edge: .leading).combined(with: .opacity))
        }
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 8)

            tabPicker
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

            Divider()

            tabContent
                .frame(height: 340)

            Divider()

            footer
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
        }
        .frame(width: 370)
        .background(Color(white: 0.08))
        .animation(.easeInOut(duration: 0.2), value: store.showingSettings)
    }

    private var header: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "bolt.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.linearGradient(
                        colors: [.blue, .cyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                Text("ClaudeWatch")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
            }

            Spacer()

            HStack(spacing: 4) {
                if !store.activeSessions.isEmpty {
                    HStack(spacing: 3) {
                        Circle().fill(.green).frame(width: 6, height: 6)
                        Text("\(store.activeSessions.count)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(.trailing, 4)
                }

                Button(action: { Task { await store.refresh() } }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.6))
                        .rotationEffect(.degrees(store.isLoading ? 360 : 0))
                        .animation(
                            store.isLoading ? .linear(duration: 1).repeatForever(autoreverses: false) : .default,
                            value: store.isLoading
                        )
                }
                .buttonStyle(.plain)

                Button(action: { withAnimation { store.showingSettings = true } }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.6))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var tabPicker: some View {
        Picker("", selection: $store.selectedTab) {
            ForEach(PopoverTab.allCases, id: \.self) { Text($0.rawValue).tag($0) }
        }
        .pickerStyle(.segmented)
        .controlSize(.small)
        .colorScheme(.dark)
    }

    @ViewBuilder
    private var tabContent: some View {
        switch store.selectedTab {
        case .overview: OverviewTab(store: store)
        case .sessions: SessionsTab(store: store)
        case .stats: StatsTab(store: store)
        }
    }

    private var techloveLabel: some View {
        HStack(spacing: 3) {
            if let url = Bundle.module.url(forResource: "techlove", withExtension: "png", subdirectory: "Resources"),
               let nsImage = NSImage(contentsOf: url) {
                Image(nsImage: nsImage)
                    .resizable()
                    .interpolation(.high)
                    .frame(width: 10, height: 10)
            }
            Text("Made by Techlove")
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.35))
        }
    }

    private var footer: some View {
        HStack {
            if let updated = store.lastUpdated {
                Text("Updated \(updated.formatted(.relative(presentation: .named)))")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.35))
            }
            Spacer()
            techloveLabel
            Spacer()
            Button("Quit") { NSApplication.shared.terminate(nil) }
                .buttonStyle(.plain)
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.35))
        }
    }
}
