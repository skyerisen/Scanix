//
//  ScanixApp.swift
//  Scanix
//
//  Created by Sergey Gamuylo on 5.11.2025.
//

import SwiftUI
import SwiftData

@main
struct ScanixApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Scan.self,
            ScanPage.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
