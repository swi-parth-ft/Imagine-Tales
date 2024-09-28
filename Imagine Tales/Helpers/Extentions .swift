//
//  Extentions.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// MARK: - Tabbar Appearance
extension TabbarView {
    
    // Custom tab item view with an icon and title
    func CustomTabItem(imageName: String, title: String, isActive: Bool) -> some View {
        HStack(spacing: 10) {
            Spacer()
            Image(systemName: isActive ? imageName + ".fill" : imageName) // Use filled icon if active
                .resizable()
                .renderingMode(.template)
                .foregroundColor(isActive ? .white : colorScheme == .dark ? .white : .black) // Change color based on active state
                .frame(width: 20, height: 20)
            if isActive {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(isActive ? .white : .black) // Change text color based on active state
            }
            Spacer()
        }
        .frame(width: isActive ? 140 : 120, height: 50) // Dynamic width based on active state
        .background(isActive ? (colorScheme == .dark ? Color(hex: "#5A6D2A") : Color(hex: "#8AC640")) : .clear) // Background color for active state
        .cornerRadius(12) // Rounded corners
        .padding(.horizontal, 5)
    }
}

// MARK: - Button Style
struct ButtonViewModifier: ViewModifier {
    // Modify button appearance
    func body(content: Content) -> some View {
        content
            .buttonStyle(.borderedProminent) // Use bordered prominent style
            .tint(.white.opacity(0.4)) // Tint color for button
            .cornerRadius(20) // Rounded corners
            .shadow(radius: 10) // Add shadow for depth
    }
}

extension View {
    // Apply button style modifier
    func buttonStyle() -> some View {
        modifier(ButtonViewModifier())
    }
}

// MARK: - Hex Color
extension Color {
    // Initialize Color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted) // Remove invalid characters
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int) // Convert hex to integer
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0) // Default to black if invalid hex
        }

        // Initialize color with RGBA values
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Custom TextField
struct CustomTextFieldModifier: ViewModifier {
    // Modify TextField appearance for standard use
    func body(content: Content) -> some View {
        content
            .padding() // Padding around the text field
            .background(Color.white) // Background color
            .frame(width: UIScreen.main.bounds.width * 0.7) // Set width relative to screen size
            .cornerRadius(12) // Rounded corners
    }
}

struct CustomTextFieldModifierCompact: ViewModifier {
    // Modify TextField appearance for compact use
    func body(content: Content) -> some View {
        content
            .padding() // Padding around the text field
            .background(Color.white) // Background color
            .frame(width: UIScreen.main.bounds.width * 0.8, height: 30) // Set width and height
            .cornerRadius(6) // Rounded corners
            .font(.system(size: 12)) // Font size for compact text fields
    }
}

extension View {
    // Apply custom text field style based on compact flag
    func customTextFieldStyle(isCompact: Bool) -> some View {
        if isCompact {
            return AnyView(self.modifier(CustomTextFieldModifierCompact())) // Use compact modifier
        } else {
            return AnyView(self.modifier(CustomTextFieldModifier())) // Use standard modifier
        }
    }
}

// MARK: - Firestore Query Extension
extension Query {
    // Asynchronously get documents and map them to a specified type
    func getDocumentsWithSnapshot<T>(as type: T.Type) async throws -> (children: [T], lastDocument: DocumentSnapshot?) where T: Decodable {
        let snapshot = try await self.getDocuments() // Fetch documents
        
        let children = try snapshot.documents.map({ document in
            try document.data(as: T.self) // Map each document to the specified type
        })
        
        return (children, snapshot.documents.last) // Return mapped children and last document
    }
}

// MARK: - Remove JPG Extension
extension String {
    // Remove .jpg extension from the string
    func removeJPGExtension() -> String {
        return self.replacingOccurrences(of: ".jpg", with: "")
    }
}

// MARK: - Custom Background
struct CustomBackgroundModifier: ViewModifier {
    // Modify the background appearance of a view
    func body(content: Content) -> some View {
        content
            .padding() // Padding around the content
            .background(Color.white) // Background color
            .cornerRadius(12) // Rounded corners
    }
}

extension View {
    // Apply custom background modifier
    func customBackground() -> some View {
        self.modifier(CustomBackgroundModifier())
    }
}
