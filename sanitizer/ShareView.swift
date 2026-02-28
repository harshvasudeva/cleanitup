//
//  ShareViewController.swift
//  sanitizer Share Extension
//
//  Created by Harsh Vasudeva on 19/02/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct ShareView: View {
    let inputURL: String
    let onComplete: () -> Void
    
    @State private var sanitizationState: SanitizationState = .loading
    @State private var settings = SettingsManager.shared
    @State private var isExpanded = false
    
    enum SanitizationState {
        case loading
        case success(SanitizedURL)
        case error(Error)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HStack(spacing: 12) {
                    Image(systemName: "link.badge.minus")
                        .font(.title3)
                        .foregroundStyle(.blue)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sanitize Link")
                            .font(.headline)
                        
                        if case .success(let result) = sanitizationState {
                            Text(result.summary)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                
                Divider()
                
                // Main content
                Group {
                    switch sanitizationState {
                    case .loading:
                        loadingView
                    case .success(let result):
                        successView(result)
                    case .error(let error):
                        errorView(error)
                    }
                }
                .frame(maxHeight: .infinity)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        onComplete()
                    }
                }
            }
        }
        .task {
            await performSanitization()
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Cleaning link…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Success View
    
    private func successView(_ result: SanitizedURL) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Clean URL display
                VStack(alignment: .leading, spacing: 8) {
                    Text("Clean URL")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    
                    Text(result.displayURL)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .lineLimit(isExpanded ? nil : 4)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                    
                    if result.displayURL.count > 100 {
                        Button(isExpanded ? "Show Less" : "Show More") {
                            withAnimation {
                                isExpanded.toggle()
                            }
                        }
                        .font(.caption)
                    }
                }
                
                // Action buttons
                HStack(spacing: 12) {
                    Button {
                        copyToClipboard(result.displayURL)
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                    ShareLink(item: result.displayURL) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
                
                // Settings
                VStack(alignment: .leading, spacing: 12) {
                    Toggle(isOn: $settings.aggressiveCleaning) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Aggressive Cleaning")
                                .font(.subheadline)
                            Text("May remove non-essential parameters")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onChange(of: settings.aggressiveCleaning) { _, _ in
                        Task {
                            await performSanitization()
                        }
                    }
                }
                .padding(.top, 8)
                
                // Info about removed parameters
                if !result.removedParameters.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Removed Parameters")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                        
                        FlowLayout(spacing: 6) {
                            ForEach(result.removedParameters, id: \.self) { param in
                                Text(param)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.red.opacity(0.1))
                                    .foregroundStyle(.red)
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
                
                Spacer(minLength: 20)
            }
            .padding()
        }
    }
    
    // MARK: - Error View
    
    private func errorView(_ error: Error) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            
            Text(error.localizedDescription)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            
            Button("Close") {
                onComplete()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Actions
    
    private func performSanitization() async {
        sanitizationState = .loading
        
        // Small delay for visual feedback
        try? await Task.sleep(for: .milliseconds(150))
        
        let result = URLSanitizer.sanitize(
            url: inputURL,
            settings: settings.urlSanitizerSettings
        )
        
        switch result {
        case .success(let sanitized):
            sanitizationState = .success(sanitized)
            
            // Save to recents
            RecentURLsManager.shared.addRecord(from: sanitized)
            
        case .failure(let error):
            sanitizationState = .error(error)
        }
    }
    
    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Auto-close after short delay
        Task {
            try? await Task.sleep(for: .milliseconds(500))
            onComplete()
        }
    }
}

// MARK: - Flow Layout for Tags

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX,
                                     y: bounds.minY + result.frames[index].minY),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize
        var frames: [CGRect]
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var frames: [CGRect] = []
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.frames = frames
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

#Preview {
    ShareView(
        inputURL: "https://example.com/page?utm_source=test&utm_campaign=demo&fbclid=12345",
        onComplete: {}
    )
}
