//
//  Item.swift
//  Scanix
//
//  Created by Sergey Gamuylo on 5.11.2025.
//

import Foundation
import SwiftData
import UIKit

/// Represents a single scanned document/group
@Model
final class Scan {
    var id: UUID
    var name: String
    var timestamp: Date
    var pages: [ScanPage]
    
    init(name: String = "", timestamp: Date = Date()) {
        self.id = UUID()
        self.name = name
        self.timestamp = timestamp
        self.pages = []
    }
}

/// Represents a single page within a scan
@Model
final class ScanPage {
    var id: UUID
    var imageData: Data?
    var orderIndex: Int
    var timestamp: Date
    
    init(imageData: Data? = nil, orderIndex: Int = 0) {
        self.id = UUID()
        self.imageData = imageData
        self.orderIndex = orderIndex
        self.timestamp = Date()
    }
    
    /// Get UIImage from stored data
    var image: UIImage? {
        guard let data = imageData else { return nil }
        return UIImage(data: data)
    }
}
