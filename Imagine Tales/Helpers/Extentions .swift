//
//  Extentions .swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

//MARK: Tabbar Apperience
extension TabbarView{
    func CustomTabItem(imageName: String, title: String, isActive: Bool) -> some View{
        HStack(spacing: 10){
            Spacer()
            Image(systemName: isActive ? imageName + ".fill" : imageName)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(isActive ? .white : .black)
                .frame(width: 20, height: 20)
            if isActive{
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(isActive ? .white : .black)
            }
            Spacer()
        }
        .frame(width: isActive ? 140 : 120, height: 50)
        .background(isActive ? Color(hex: "#8AC640") : .clear)
        .cornerRadius(12)
        .padding(.horizontal, 5)
    }
}

//MARK: ButtonStyle
struct ButtonViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .buttonStyle(.borderedProminent)
            .tint(.white.opacity(0.4))
            .cornerRadius(20)
            .shadow(radius: 10)
    }
}
extension View {
    func buttonStyle() -> some View {
        modifier(ButtonViewModifier())
    }
    
}

//MARK: Hex color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

//MARK: Custome TextField
struct CustomTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.white)
            .frame(width: UIScreen.main.bounds.width * 0.7)
            .cornerRadius(12)
    }
}
struct CustomTextFieldModifierCompact: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.white)
            .frame(width: UIScreen.main.bounds.width * 0.8, height: 30)
            .cornerRadius(6)
            .font(.system(size: 12))
    }
}
extension View {
    
    func customTextFieldStyle(isCompact: Bool) -> some View {
        
        if isCompact {
            return AnyView(self.modifier(CustomTextFieldModifierCompact()))
        } else {
            return AnyView(self.modifier(CustomTextFieldModifier()))
        }
    }
}

extension Query {
    func getDocumentsWithSnapshot<T>(as type: T.Type) async throws -> (children: [T], lastDocument: DocumentSnapshot?) where T : Decodable {
        let snapshot = try await self.getDocuments()
        
        let children = try snapshot.documents.map({ document in
            try document.data(as: T.self)
        })
        
        return (children, snapshot.documents.last)
    }
    
}
