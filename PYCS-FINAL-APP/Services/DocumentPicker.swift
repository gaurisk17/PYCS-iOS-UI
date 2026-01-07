//
//  DocumentPicker.swift
//  PYCS-FINAL-APP
//
//  Created by Gauri Kulkarni on 4/13/25.
//

import SwiftUI
import UniformTypeIdentifiers

// Custom DocumentPicker Coordinator
class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate {
    var parent: DocumentPicker
    
    init(parent: DocumentPicker) {
        self.parent = parent
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        print("Document picked: \(url)")
        parent.completion(.success([url]))
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled")
        parent.completion(.failure(NSError(domain: "DocumentPickerDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "Document picker was cancelled"])))
    }
}

// SwiftUI wrapper for UIDocumentPickerViewController
struct DocumentPicker: UIViewControllerRepresentable {
    let types: [UTType]
    let completion: (Result<[URL], Error>) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> DocumentPickerCoordinator {
        DocumentPickerCoordinator(parent: self)
    }
}
