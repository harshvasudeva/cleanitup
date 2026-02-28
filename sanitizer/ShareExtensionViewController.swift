//
//  ShareViewController.swift
//  sanitizer Share Extension
//
//  Created by Harsh Vasudeva on 19/02/26.
//

import UIKit
import SwiftUI
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Extract the shared content
        extractSharedURL { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let urlString):
                    self.showShareView(with: urlString)
                case .failure(let error):
                    self.showError(error)
                }
            }
        }
    }
    
    private func extractSharedURL(completion: @escaping (Result<String, Error>) -> Void) {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem else {
            completion(.failure(ShareExtensionError.noInputItems))
            return
        }
        
        guard let itemProvider = extensionItem.attachments?.first else {
            completion(.failure(ShareExtensionError.noAttachments))
            return
        }
        
        // Try to load as URL first
        if itemProvider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
            itemProvider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { (item, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let url = item as? URL {
                    completion(.success(url.absoluteString))
                } else if let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                    completion(.success(url.absoluteString))
                } else {
                    completion(.failure(ShareExtensionError.invalidURLFormat))
                }
            }
        }
        // Try to load as text
        else if itemProvider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
            itemProvider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { (item, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let text = item as? String {
                    completion(.success(text))
                } else {
                    completion(.failure(ShareExtensionError.invalidTextFormat))
                }
            }
        } else {
            completion(.failure(ShareExtensionError.unsupportedType))
        }
    }
    
    private func showShareView(with urlString: String) {
        let shareView = ShareView(inputURL: urlString) { [weak self] in
            self?.closeExtension()
        }
        
        let hostingController = UIHostingController(rootView: shareView)
        hostingController.view.backgroundColor = .systemBackground
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostingController.didMove(toParent: self)
    }
    
    private func showError(_ error: Error) {
        let errorView = VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            
            Text(error.localizedDescription)
                .font(.subheadline)
                .multilineTextAlignment(.center)
            
            Button("Close") { [weak self] in
                self?.closeExtension()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
        
        let hostingController = UIHostingController(rootView: errorView)
        hostingController.view.backgroundColor = .systemBackground
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostingController.didMove(toParent: self)
    }
    
    private func closeExtension() {
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
}

enum ShareExtensionError: LocalizedError {
    case noInputItems
    case noAttachments
    case unsupportedType
    case invalidURLFormat
    case invalidTextFormat
    
    var errorDescription: String? {
        switch self {
        case .noInputItems, .noAttachments:
            return "No content was shared"
        case .unsupportedType:
            return "Unsupported content type. Please share a URL or text containing a URL."
        case .invalidURLFormat, .invalidTextFormat:
            return "Could not extract URL from shared content"
        }
    }
}
