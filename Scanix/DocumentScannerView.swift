//
//  DocumentScannerView.swift
//  Scanix
//
//  Created by Sergey Gamuylo on 5.11.2025.
//

import SwiftUI
import VisionKit

/// Coordinator for handling VNDocumentCameraViewController
class DocumentScannerCoordinator: NSObject, VNDocumentCameraViewControllerDelegate {
    var parent: DocumentScannerView
    
    init(_ parent: DocumentScannerView) {
        self.parent = parent
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        var images: [UIImage] = []
        
        for pageIndex in 0..<scan.pageCount {
            let image = scan.imageOfPage(at: pageIndex)
            images.append(image)
        }
        
        parent.scannedImages = images
        parent.isPresented = false
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        parent.isPresented = false
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        print("Document scanning failed: \(error.localizedDescription)")
        parent.isPresented = false
    }
}

/// SwiftUI wrapper for VNDocumentCameraViewController
struct DocumentScannerView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var scannedImages: [UIImage]
    
    func makeCoordinator() -> DocumentScannerCoordinator {
        DocumentScannerCoordinator(self)
    }
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let viewController = VNDocumentCameraViewController()
        viewController.delegate = context.coordinator
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
        // No updates needed
    }
}
