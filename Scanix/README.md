# Scanix - Modern iOS Scanner App

A beautiful, modern document scanner app for iOS built with SwiftUI, SwiftData, and featuring Apple's Liquid Glass design language.

## Features

### 📸 Document Scanning
- **VisionKit Integration**: Use the native iOS document scanner for high-quality captures
- **Multi-page Scanning**: Capture multiple pages in a single scan session
- **Automatic Edge Detection**: VisionKit automatically detects document edges and applies perspective correction

### 🎨 Modern Design
- **Liquid Glass Effects**: Beautiful glass morphism design throughout the app
- **Interactive Elements**: Buttons and cards react to touch with smooth animations
- **Minimalist UI**: Clean, distraction-free interface focused on your documents

### 📱 Smart Organization
- **Fun Name Generation**: Each scan gets a randomly generated, goofy name
- **Search Functionality**: Quickly find scans by name with built-in search
- **Recent Scans**: Quick access to your most recent documents on the home screen
- **Timestamp Tracking**: Automatic date/time tracking for all scans

### ✏️ Powerful Editing
- **Swipeable Pages**: Navigate through multi-page scans with smooth swipe gestures
- **Reorder Pages**: Move pages up or down to reorganize your document
- **Delete Pages**: Remove unwanted pages from your scans
- **Rename Scans**: Give your documents meaningful names
- **Add More Pages**: Scan additional pages to existing documents

### 💾 Export Options
- **PDF Export**: Combine all pages into a single PDF document
- **Individual Images**: Save single pages to your Photos library
- **Batch Save**: Save all pages as individual images
- **Share Sheet**: Share PDFs via any iOS share extension

### 🔍 Page Management
- **Page Thumbnails**: Visual overview of all pages in a scan
- **Page Counter**: Always know which page you're viewing
- **Context Menu Actions**: Long-press thumbnails for quick actions
- **Visual Feedback**: Selected pages are highlighted for clarity

## Technical Details

### Architecture
- **SwiftUI**: Modern declarative UI framework
- **SwiftData**: Persistent storage with `@Model` classes
- **VisionKit**: Native document scanning capabilities
- **PDFKit**: PDF generation and handling
- **Swift Concurrency**: Async/await for smooth operations

### Data Models

#### Scan
- `id`: Unique identifier
- `name`: User-editable scan name
- `timestamp`: Creation date
- `pages`: Collection of ScanPage objects

#### ScanPage
- `id`: Unique identifier
- `imageData`: Compressed JPEG data
- `orderIndex`: Position in the scan
- `timestamp`: Creation date

### Key Components

1. **ContentView**: Home screen with search and scan list
2. **ScanDetailView**: View and edit individual scans
3. **DocumentScannerView**: UIKit wrapper for VNDocumentCameraViewController
4. **NameGenerator**: Generates fun, random names for scans
5. **PDFExporter**: Creates PDF documents from images

## Requirements

- iOS 18.0+ (for full Liquid Glass support)
- Xcode 16.0+
- Swift 6.0+

## Permissions Required

Add these to your `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Scanix needs camera access to scan documents</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>Scanix needs permission to save scanned documents to your Photos library</string>
```

## Setup Instructions

1. **Clone or create the project**
2. **Add required capabilities**:
   - No special entitlements needed
3. **Build and run on iOS 18+ device or simulator**
4. **Grant camera and photo library permissions when prompted**

## Usage

### Scanning a Document
1. Tap the "New Scan" button on the home screen
2. Camera scanner opens automatically
3. Position your document and tap the capture button
4. Review and adjust the scan
5. Tap "Save" to add it to your library

### Managing Scans
- **Search**: Use the search bar to filter scans by name
- **View Details**: Tap any scan card to open it
- **Rename**: Tap the menu (•••) → "Rename"
- **Delete**: Tap the menu (•••) → "Delete Scan"

### Editing Pages
- **Swipe**: Swipe left/right on the main image to navigate
- **Reorder**: Long-press a thumbnail → "Move Up" or "Move Down"
- **Delete**: Long-press a thumbnail → "Delete Page"
- **Add More**: Tap menu → "Add Pages"

### Exporting
1. Open a scan
2. Tap "Export & Share"
3. Choose your export option:
   - Export All as PDF
   - Save Current Page to Photos
   - Save All Pages to Photos

## Liquid Glass Design

The app uses Apple's modern Liquid Glass design language:

- **Glass Effects**: Semi-transparent backgrounds with blur
- **Interactive Responses**: Elements react to touch
- **Smooth Animations**: Fluid transitions between states
- **Visual Hierarchy**: Important elements stand out with tinted glass

### Implementation Examples

```swift
// Basic glass effect
.glassEffect(.regular)

// Interactive glass with tint
.glassEffect(.regular.tint(.blue).interactive())

// Container for multiple glass elements
GlassEffectContainer(spacing: 12) {
    // Multiple views with glass effects
}
```

## Code Structure

```
Scanix/
├── ScanixApp.swift           # App entry point
├── ContentView.swift          # Home screen
├── ScanDetailView.swift       # Scan detail & editing
├── DocumentScannerView.swift  # VisionKit wrapper
├── Item.swift                 # Data models (Scan, ScanPage)
├── NameGenerator.swift        # Random name generation
└── PDFExporter.swift          # PDF creation utilities
```

## Fun Name Examples

The name generator creates entertaining scan names like:
- "Mighty Documents"
- "The Scanpocalypse"
- "Cosmic Papers"
- "Doc-o-Rama"
- "Epic Scan - Nov 05"
- "Sheet Storm"

## Future Enhancements

Potential features for future versions:
- OCR text recognition
- Cloud sync (iCloud)
- Document templates
- Batch scanning workflows
- Advanced image filters
- Tags and categories
- Password protection
- Widget support

## License

Copyright © 2025 Sergey Gamuylo. All rights reserved.

## Credits

Built with:
- SwiftUI
- SwiftData
- VisionKit
- PDFKit
- Apple's Liquid Glass design language
