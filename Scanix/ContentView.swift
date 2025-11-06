//
//  ContentView.swift
//  Scanix
//
//  Created by Sergey Gamuylo on 5.11.2025.
//

import SwiftUI
import SwiftData
import VisionKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Query(sort: \Scan.timestamp, order: .reverse) private var scans: [Scan]
    
    @State private var searchText = ""
    @State private var showScanner = false
    @State private var scannedImages: [UIImage] = []
    @State private var navigationPath = NavigationPath()
    @State private var selectedScan: Scan?
    
    private var filteredScans: [Scan] {
        if searchText.isEmpty {
            return scans
        } else {
            return scans.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    private var recentScans: [Scan] {
        Array(scans.prefix(5))
    }
    
    private var isIPad: Bool {
        horizontalSizeClass == .regular
    }
    
    var body: some View {
        if isIPad {
            iPadLayout
        } else {
            iPhoneLayout
        }
    }
    
    // MARK: - iPad Layout
    
    private var iPadLayout: some View {
        NavigationSplitView {
            sidebarContent
        } detail: {
            if let selectedScan = selectedScan {
                ScanDetailView(scan: selectedScan)
            } else {
                detailPlaceholder
            }
        }
        .sheet(isPresented: $showScanner) {
            DocumentScannerView(isPresented: $showScanner, scannedImages: $scannedImages)
                .ignoresSafeArea()
        }
        .onChange(of: scannedImages) { oldValue, newValue in
            if !newValue.isEmpty {
                let newScan = saveScannedImages(newValue)
                scannedImages = []
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    selectedScan = newScan
                }
            }
        }
    }
    
    private var sidebarContent: some View {
        List(selection: $selectedScan) {
            Section {
                Button {
                    showScanner = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "doc.text.viewfinder")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background {
                                Circle()
                                    .fill(Color.accentColor)
                            }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("New Scan")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            
                            Text("Capture documents")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
            
            if !filteredScans.isEmpty {
                Section {
                    ForEach(filteredScans) { scan in
                        ScanRowView(scan: scan)
                            .tag(scan)
                    }
                } header: {
                    Text(searchText.isEmpty ? "All Scans" : "Search Results")
                }
            }
        }
        .navigationTitle("Scanix")
        .searchable(text: $searchText, prompt: "Search scans")
    }
    
    private var detailPlaceholder: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 80))
                .foregroundStyle(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No Scan Selected")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Select a scan from the sidebar or create a new one")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - iPhone Layout
    
    private var iPhoneLayout: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(spacing: 24) {
                    // New Scan Button - Prominent
                    newScanButton
                        .padding(.top, 20)
                    
                    // Recent Scans Section
                    if !recentScans.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Recent Scans")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            recentScansGrid
                        }
                    }
                    
                    // All Scans Section
                    if !filteredScans.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(searchText.isEmpty ? "All Scans" : "Search Results")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            allScansList
                        }
                    } else if searchText.isEmpty && scans.isEmpty {
                        emptyStateView
                    } else if !searchText.isEmpty {
                        noResultsView
                    }
                }
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Scanix")
            .searchable(text: $searchText, prompt: "Search scans")
            .searchToolbarBehavior(.minimize)
            .navigationDestination(for: Scan.self) { scan in
                ScanDetailView(scan: scan)
            }
            .sheet(isPresented: $showScanner) {
                DocumentScannerView(isPresented: $showScanner, scannedImages: $scannedImages)
                    .ignoresSafeArea()
            }
            .onChange(of: scannedImages) { oldValue, newValue in
                if !newValue.isEmpty {
                    let newScan = saveScannedImages(newValue)
                    scannedImages = []
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        navigationPath.append(newScan)
                    }
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var newScanButton: some View {
        Button {
            showScanner = true
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "doc.text.viewfinder")
                    .font(.system(size: 36))
                    .foregroundStyle(.white)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("New Scan")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    
                    Text("Capture documents instantly")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(24)
            .frame(maxWidth: isIPad ? 600 : .infinity)
            .glassEffect(.regular.tint(.accentColor).interactive())
            .padding(.horizontal)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
    
    private var recentScansGrid: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(recentScans) { scan in
                    Button {
                        navigationPath.append(scan)
                    } label: {
                        ScanCardView(scan: scan, isCompact: true)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var allScansList: some View {
        Group {
            if isIPad {
                // Grid layout for iPad
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 300), spacing: 16)
                ], spacing: 16) {
                    ForEach(filteredScans) { scan in
                        Button {
                            navigationPath.append(scan)
                        } label: {
                            ScanCardView(scan: scan, isCompact: false)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            } else {
                // Vertical list for iPhone
                VStack(spacing: 12) {
                    ForEach(filteredScans) { scan in
                        Button {
                            navigationPath.append(scan)
                        } label: {
                            ScanCardView(scan: scan, isCompact: false)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 80))
                .foregroundStyle(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No Scans Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Tap 'New Scan' to get started")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(60)
    }
    
    private var noResultsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No Results")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("Try a different search term")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }
    
    // MARK: - Actions
    
    private func saveScannedImages(_ images: [UIImage]) -> Scan {
        let newScan = Scan(name: NameGenerator.generateRandomName())
        
        for (index, image) in images.enumerated() {
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                let page = ScanPage(imageData: imageData, orderIndex: index)
                newScan.pages.append(page)
            }
        }
        
        modelContext.insert(newScan)
        try? modelContext.save()
        
        return newScan
    }
}

// MARK: - Scan Row View (iPad Sidebar)

struct ScanRowView: View {
    let scan: Scan
    
    private var pageCount: Int {
        scan.pages.count
    }
    
    private var thumbnailImage: UIImage? {
        scan.pages.sorted { $0.orderIndex < $1.orderIndex }.first?.image
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            if let thumbnail = thumbnailImage {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 60)
                    .clipped()
                    .cornerRadius(6)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 50, height: 60)
                    .cornerRadius(6)
                    .overlay {
                        Image(systemName: "doc.text")
                            .font(.system(size: 20))
                            .foregroundStyle(.gray.opacity(0.5))
                    }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(scan.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text("\(pageCount) page\(pageCount == 1 ? "" : "s")")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Text("•")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Text(scan.timestamp, format: .dateTime.month().day())
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - Scan Card View

struct ScanCardView: View {
    let scan: Scan
    let isCompact: Bool
    
    private var pageCount: Int {
        scan.pages.count
    }
    
    private var thumbnailImage: UIImage? {
        scan.pages.sorted { $0.orderIndex < $1.orderIndex }.first?.image
    }
    
    var body: some View {
        if isCompact {
            compactCard
        } else {
            fullCard
        }
    }
    
    private var compactCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Thumbnail
            if let thumbnail = thumbnailImage {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 140, height: 180)
                    .clipped()
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 140, height: 180)
                    .cornerRadius(8)
                    .overlay {
                        Image(systemName: "doc.text")
                            .font(.system(size: 40))
                            .foregroundStyle(.gray.opacity(0.5))
                    }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(scan.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Text("\(pageCount) page\(pageCount == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 140)
        }
    }
    
    private var fullCard: some View {
        HStack(spacing: 16) {
            // Thumbnail
            if let thumbnail = thumbnailImage {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 100)
                    .clipped()
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 100)
                    .cornerRadius(8)
                    .overlay {
                        Image(systemName: "doc.text")
                            .font(.system(size: 30))
                            .foregroundStyle(.gray.opacity(0.5))
                    }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(scan.name)
                    .font(.headline)
                    .lineLimit(2)
                
                HStack(spacing: 16) {
                    Label("\(pageCount) page\(pageCount == 1 ? "" : "s")", systemImage: "doc")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(scan.timestamp, format: .dateTime.month().day().year())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Scan.self, inMemory: true)
}
