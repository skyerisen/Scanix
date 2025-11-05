//
//  PDFExporter.swift
//  Scanix
//
//  Created by Sergey Gamuylo on 5.11.2025.
//

import Foundation
import UIKit
import PDFKit

/// Handles exporting scans to PDF format
struct PDFExporter {
    
    /// Creates a PDF from an array of images
    static func createPDF(from images: [UIImage], fileName: String) -> URL? {
        let pdfDocument = PDFDocument()
        
        for (index, image) in images.enumerated() {
            if let pdfPage = PDFPage(image: image) {
                pdfDocument.insert(pdfPage, at: index)
            }
        }
        
        // Save to temporary directory
        let tempDirectory = FileManager.default.temporaryDirectory
        let pdfURL = tempDirectory.appendingPathComponent("\(fileName).pdf")
        
        // Remove existing file if it exists
        try? FileManager.default.removeItem(at: pdfURL)
        
        // Write PDF to disk
        if pdfDocument.write(to: pdfURL) {
            return pdfURL
        }
        
        return nil
    }
    
    /// Creates a PDF from a Scan object
    static func createPDF(from scan: Scan) -> URL? {
        let images = scan.pages
            .sorted { $0.orderIndex < $1.orderIndex }
            .compactMap { $0.image }
        
        guard !images.isEmpty else { return nil }
        
        let fileName = scan.name.isEmpty ? "Scan_\(Date().timeIntervalSince1970)" : scan.name
        return createPDF(from: images, fileName: fileName)
    }
    
    /// Converts a single image to PDF
    static func createPDF(from image: UIImage, fileName: String) -> URL? {
        return createPDF(from: [image], fileName: fileName)
    }
}
