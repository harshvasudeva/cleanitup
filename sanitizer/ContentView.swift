//
//  ContentView.swift
//  sanitizer
//
//  Created by Harsh Vasudeva on 19/02/26.
//

import SwiftUI

struct ContentView: View {
    @State private var settings = SettingsManager.shared
    @State private var recentURLs = RecentURLsManager.shared

    // Manual URL cleaning
    @State private var manualURL = ""
    @State private var manualResult: SanitizedURL? = nil
    @State private var manualError: String? = nil

    var body: some View {
        NavigationStack {
            List {
                // Manual URL input section
                Section {
                    // Input row
                    HStack(spacing: 8) {
                        Image(systemName: "link")
                            .foregroundStyle(.secondary)
                            .frame(width: 20)

                        TextField("Paste a URL to clean…", text: $manualURL)
                            .textContentType(.URL)
                            .keyboardType(.URL)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .onSubmit { cleanManualURL() }

                        if !manualURL.isEmpty {
                            Button {
                                manualURL = ""
                                manualResult = nil
                                manualError = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.tertiary)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Action buttons
                    HStack(spacing: 10) {
                        Button {
                            if let string = UIPasteboard.general.string {
                                manualURL = string
                                cleanManualURL()
                            }
                        } label: {
                            Label("Paste & Clean", systemImage: "doc.on.clipboard")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.regular)

                        Button {
                            cleanManualURL()
                        } label: {
                            Label("Clean", systemImage: "sparkles")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.regular)
                        .disabled(manualURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }

                    // Error message
                    if let error = manualError {
                        Label(error, systemImage: "exclamationmark.triangle")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    // Result display
                    if let result = manualResult {
                        ManualResultView(result: result)
                    }

                } header: {
                    Text("Clean a URL")
                }

                // Settings section
                Section {
                    Toggle(isOn: $settings.aggressiveCleaning) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Aggressive Cleaning")
                            Text("May remove non-essential parameters")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Settings")
                }

                // Recently cleaned section
                if !recentURLs.recentURLs.isEmpty {
                    Section {
                        ForEach(recentURLs.recentURLs) { record in
                            RecentURLRow(record: record)
                        }
                    } header: {
                        HStack {
                            Text("Recently Cleaned")
                            Spacer()
                            Button("Clear") {
                                withAnimation {
                                    recentURLs.clearAll()
                                }
                            }
                            .font(.caption)
                            .textCase(.none)
                        }
                    }
                }

                // How it works section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Share from any app", systemImage: "square.and.arrow.up")
                            .font(.headline)
                        Text("Tap the Share button in Safari or any app, then choose Clean it Up! to instantly clean tracking parameters.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("How It Works")
                }

                // About section
                Section {
                    Link(destination: URL(string: "https://harshvasudeva.com/cleanitup/privacy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }

                    Link(destination: URL(string: "mailto:support@harshvasudeva.com")!) {
                        Label("Contact Support", systemImage: "envelope")
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Clean it Up!")
        }
    }

    private func cleanManualURL() {
        let trimmed = manualURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        manualError = nil
        manualResult = nil

        let result = URLSanitizer.sanitize(url: trimmed, settings: settings.urlSanitizerSettings)
        switch result {
        case .success(let sanitized):
            manualResult = sanitized
            RecentURLsManager.shared.addRecord(from: sanitized)
        case .failure(let error):
            manualError = error.localizedDescription
        }
    }
}

// MARK: - Manual Result View

struct ManualResultView: View {
    let result: SanitizedURL
    @State private var showingCopied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Status badge
            HStack(spacing: 6) {
                Image(systemName: result.wasModified ? "checkmark.shield.fill" : "checkmark.circle")
                    .foregroundStyle(result.wasModified ? .green : .secondary)
                Text(result.summary)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(result.wasModified ? .green : .secondary)
            }

            // Cleaned URL box
            Text(result.sanitized)
                .font(.system(.caption, design: .monospaced))
                .lineLimit(4)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            // Copy / Share buttons
            HStack(spacing: 10) {
                Button {
                    UIPasteboard.general.string = result.sanitized
                    let gen = UINotificationFeedbackGenerator()
                    gen.notificationOccurred(.success)
                    showingCopied = true
                } label: {
                    Label(showingCopied ? "Copied!" : "Copy", systemImage: showingCopied ? "checkmark" : "doc.on.doc")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(showingCopied ? .green : .accentColor)

                ShareLink(item: result.sanitized) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }

            // Removed parameters chips
            if !result.removedParameters.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(result.removedParameters, id: \.self) { param in
                        Text(param)
                            .font(.caption2)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Color.red.opacity(0.1))
                            .foregroundStyle(.red)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
            }
        }
        .padding(.top, 4)
        .onChange(of: showingCopied) { _, newValue in
            if newValue {
                Task {
                    try? await Task.sleep(for: .seconds(2))
                    showingCopied = false
                }
            }
        }
    }
}

// MARK: - Recent URL Row

struct RecentURLRow: View {
    let record: CleanedURLRecord
    @State private var showingCopiedAlert = false
    
    var body: some View {
        Button {
            UIPasteboard.general.string = record.cleanedURL
            
            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            showingCopiedAlert = true
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Text(record.cleanedURL)
                    .font(.system(.body, design: .monospaced))
                    .lineLimit(2)
                    .foregroundStyle(.primary)
                
                HStack {
                    Text(record.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if record.removedCount > 0 {
                        Text("•")
                            .foregroundStyle(.secondary)
                        Text("\(record.removedCount) removed")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.vertical, 2)
        }
        .alert("Copied", isPresented: $showingCopiedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("URL copied to clipboard")
        }
    }
}

#Preview {
    ContentView()
}
