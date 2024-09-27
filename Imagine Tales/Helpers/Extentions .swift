//
//  Extentions .swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//

import Foundation
import SwiftUI

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

