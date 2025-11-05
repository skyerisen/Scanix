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
    @Query(sort: \Scan.timestamp, order: .reverse) private var scans: [Scan]
    
    @State private var searchText = ""
    @State private var showScanner = false
    @State private var scannedImages: [UIImage] = []
    @State private var navigationPath = NavigationPath()
    
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
    
    var body: some View {
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
                    
                    // Небольшая задержка для плавного перехода после закрытия сканера
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
            .frame(maxWidth: .infinity)
            .glassEffect(.regular.tint(.accentColor).interactive())
            .padding(.horizontal)
        }
        .buttonStyle(.plain)
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
