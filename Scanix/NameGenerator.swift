//
//  NameGenerator.swift
//  Scanix
//
//  Created by Sergey Gamuylo on 5.11.2025.
//

import Foundation

/// Generates fun and goofy names for scanned documents
struct NameGenerator {
    
    private static let templates = [
        "Scan-tastic",
        "Paper Trail",
        "Doc & Roll",
        "Scan Master",
        "Sheet Storm",
        "Page Turner",
        "Pixel Perfect",
        "Quick Capture",
        "Paper Chase"
    ]
    
    private static let adjectives = [
        "Mighty", "Cosmic", "Turbo", "Supreme", "Ultra",
        "Epic", "Legendary", "Mystical", "Golden", "Royal",
        "Radical", "Awesome", "Stellar", "Fantastic", "Brilliant",
        "Magnificent", "Spectacular", "Phenomenal", "Incredible", "Marvelous"
    ]
    
    private static let nouns = [
        "Document", "Papers", "Files", "Pages", "Sheets",
        "Records", "Forms", "Notes", "Receipts", "Contracts",
        "Reports", "Letters", "Bills", "Tickets", "Certificates"
    ]
    
    private static let funPhrases = [
        "The Scanpocalypse",
        "Digitize This!",
        "Scan-o-Rama",
        "Paper Patrol",
        "Scan Squad",
        "Doc Block",
        "Sheet Happens",
        "Scan Solo",
        "The Document-ary",
        "Scan-demonium"
    ]
    
    /// Generates a random fun name for a new scan
    static func generateRandomName() -> String {
        let randomChoice = Int.random(in: 0...3)
        
        switch randomChoice {
        case 0:
            // Template style
            return templates.randomElement() ?? "Scan"
        case 1:
            // Adjective + Noun
            let adj = adjectives.randomElement() ?? "Great"
            let noun = nouns.randomElement() ?? "Document"
            return "\(adj) \(noun)"
        case 2:
            // Fun phrase
            return funPhrases.randomElement() ?? "My Scan"
        default:
            // Date-based with fun prefix
            let prefix = ["Epic", "Super", "Mega", "Ultra"].randomElement() ?? "My"
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd"
            return "\(prefix) Scan - \(formatter.string(from: Date()))"
        }
    }
    
    /// Generates a name with a date suffix
    static func generateNameWithDate() -> String {
        let baseName = generateRandomName()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return "\(baseName) (\(formatter.string(from: Date())))"
    }
}
