//
//  ScanDetailView.swift
//  Scanix
//
//  Created by Sergey Gamuylo on 5.11.2025.
//

import SwiftUI
import SwiftData
import PhotosUI

struct ScanDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var scan: Scan
    
    @State private var selectedPageIndex = 0
    @State private var showingRenameAlert = false
    @State private var editedName = ""
    @State private var showingDeleteConfirmation = false
    @State private var showingExportOptions = false
    @State private var showingShareSheet = false
    @State private var pdfURL: URL?
    @State private var showingImagePicker = false
    @State private var showingScanner = false
    @State private var scannedImages: [UIImage] = []
    
    private var sortedPages: [ScanPage] {
        scan.pages.sorted { $0.orderIndex < $1.orderIndex }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Page viewer
                if !sortedPages.isEmpty {
                    pageViewer
                        .padding(.top, 20)
                    
                    // Page thumbnails
                    pageThumbnails
                }
                
                // Actions
                actionsSection
                    .padding(.horizontal)
                
                // Info section
                infoSection
                    .padding(.horizontal)
            }
            .padding(.bottom, 20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(scan.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        editedName = scan.name
                        showingRenameAlert = true
                    } label: {
                        Label("Rename", systemImage: "pencil")
                    }
                    
                    Button {
                        showingScanner = true
                    } label: {
                        Label("Add Pages", systemImage: "plus")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete Scan", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.body)
                }
            }
        }
        .alert("Rename Scan", isPresented: $showingRenameAlert) {
            TextField("Name", text: $editedName)
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                scan.name = editedName
                try? modelContext.save()
            }
        }
        .confirmationDialog("Delete this scan?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                deleteScan()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This action cannot be undone.")
        }
        .confirmationDialog("Export Options", isPresented: $showingExportOptions, titleVisibility: .visible) {
            Button("Export All as PDF") {
                exportAsPDF()
            }
            Button("Save Current Page to Photos") {
                saveCurrentImageToPhotos()
            }
            Button("Save All Pages to Photos") {
                saveAllImagesToPhotos()
            }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = pdfURL {
                ShareSheet(items: [url])
            }
        }
        .sheet(isPresented: $showingScanner) {
            DocumentScannerView(isPresented: $showingScanner, scannedImages: $scannedImages)
                .ignoresSafeArea()
        }
        .onChange(of: scannedImages) { oldValue, newValue in
            if !newValue.isEmpty {
                addScannedImages(newValue)
                scannedImages = []
            }
        }
    }
    
    // MARK: - Subviews
    
    private var pageViewer: some View {
        TabView(selection: $selectedPageIndex) {
            ForEach(Array(sortedPages.enumerated()), id: \.element.id) { index, page in
                if let image = page.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .tag(index)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .overlay {
                            VStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 40))
                                Text("Failed to load image")
                                    .font(.caption)
                            }
                            .foregroundStyle(.gray)
                        }
                        .tag(index)
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .frame(height: 500)
    }
    
    private var pageThumbnails: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Pages")
                    .font(.headline)
                
                Spacer()
                
                Text("\(selectedPageIndex + 1) of \(sortedPages.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(sortedPages.enumerated()), id: \.element.id) { index, page in
                        ThumbnailView(
                            page: page,
                            index: index,
                            isSelected: index == selectedPageIndex,
                            onTap: { selectedPageIndex = index },
                            onDelete: { deletePage(page) },
                            onMoveUp: { movePage(page, direction: -1) },
                            onMoveDown: { movePage(page, direction: 1) },
                            canMoveUp: index > 0,
                            canMoveDown: index < sortedPages.count - 1
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var actionsSection: some View {
        GlassEffectContainer(spacing: 12) {
            VStack(spacing: 12) {
                Button {
                    showingExportOptions = true
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title3)
                        Text("Export & Share")
                            .font(.headline)
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Information")
                .font(.headline)
            
            VStack(spacing: 12) {
                InfoRow(icon: "doc.text", label: "Pages", value: "\(sortedPages.count)")
                InfoRow(icon: "calendar", label: "Created", value: scan.timestamp.formatted(date: .long, time: .shortened))
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
            }
        }
    }
    
    // MARK: - Actions
    
    private func deletePage(_ page: ScanPage) {
        withAnimation {
            if let index = scan.pages.firstIndex(where: { $0.id == page.id }) {
                scan.pages.remove(at: index)
                
                // Reindex remaining pages
                for (newIndex, page) in scan.pages.enumerated() {
                    page.orderIndex = newIndex
                }
                
                // Adjust selected index if needed
                if selectedPageIndex >= sortedPages.count && selectedPageIndex > 0 {
                    selectedPageIndex -= 1
                }
                
                try? modelContext.save()
                
                // Delete scan if no pages left
                if scan.pages.isEmpty {
                    deleteScan()
                }
            }
        }
    }
    
    private func movePage(_ page: ScanPage, direction: Int) {
        guard let currentIndex = sortedPages.firstIndex(where: { $0.id == page.id }) else { return }
        let newIndex = currentIndex + direction
        
        guard newIndex >= 0 && newIndex < sortedPages.count else { return }
        
        withAnimation {
            let otherPage = sortedPages[newIndex]
            let tempOrder = page.orderIndex
            page.orderIndex = otherPage.orderIndex
            otherPage.orderIndex = tempOrder
            
            // Update selected index
            if selectedPageIndex == currentIndex {
                selectedPageIndex = newIndex
            } else if selectedPageIndex == newIndex {
                selectedPageIndex = currentIndex
            }
            
            try? modelContext.save()
        }
    }
    
    private func deleteScan() {
        modelContext.delete(scan)
        try? modelContext.save()
        dismiss()
    }
    
    private func exportAsPDF() {
        guard let url = PDFExporter.createPDF(from: scan) else { return }
        pdfURL = url
        showingShareSheet = true
    }
    
    private func saveCurrentImageToPhotos() {
        guard selectedPageIndex < sortedPages.count,
              let image = sortedPages[selectedPageIndex].image else { return }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    private func saveAllImagesToPhotos() {
        for page in sortedPages {
            if let image = page.image {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
        }
    }
    
    private func addScannedImages(_ images: [UIImage]) {
        withAnimation {
            let startIndex = scan.pages.count
            
            for (offset, image) in images.enumerated() {
                if let imageData = image.jpegData(compressionQuality: 0.8) {
                    let page = ScanPage(imageData: imageData, orderIndex: startIndex + offset)
                    scan.pages.append(page)
                }
            }
            
            try? modelContext.save()
        }
    }
}

// MARK: - Supporting Views

struct ThumbnailView: View {
    let page: ScanPage
    let index: Int
    let isSelected: Bool
    let onTap: () -> Void
    let onDelete: () -> Void
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void
    let canMoveUp: Bool
    let canMoveDown: Bool
    
    @State private var showingOptions = false
    
    var body: some View {
        VStack(spacing: 8) {
            Button(action: onTap) {
                Group {
                    if let image = page.image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundStyle(.gray)
                            }
                    }
                }
                .frame(width: 80, height: 100)
                .clipped()
                .cornerRadius(8)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                }
            }
            .contextMenu {
                Button {
                    onDelete()
                } label: {
                    Label("Delete Page", systemImage: "trash")
                }
                
                if canMoveUp {
                    Button {
                        onMoveUp()
                    } label: {
                        Label("Move Up", systemImage: "arrow.up")
                    }
                }
                
                if canMoveDown {
                    Button {
                        onMoveDown()
                    } label: {
                        Label("Move Down", systemImage: "arrow.down")
                    }
                }
            }
            
            Text("\(index + 1)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)
            
            Text(label)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .foregroundStyle(.primary)
        }
        .font(.subheadline)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}

#Preview {
    NavigationStack {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Scan.self, configurations: config)
        let context = container.mainContext
        
        let scan = Scan(name: "Test Scan")
        context.insert(scan)
        
        return ScanDetailView(scan: scan)
            .modelContainer(container)
    }
}
