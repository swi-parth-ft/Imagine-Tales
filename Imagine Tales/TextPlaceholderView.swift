//
//  TextPlaceholderView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/29/24.
//

import SwiftUI

struct TextPlaceholderView: View {
    @State private var gradientStart = UnitPoint(x: -1, y: 0)
    @State private var gradientEnd = UnitPoint(x: 0, y: 0)
    
    let gradientColors = [Color.blue.opacity(0.3), Color.cyan, Color.blue.opacity(0.3)]
    @State private var count = 10
    var body: some View {
        VStack(alignment: .leading) {
            
            ForEach(0..<count, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: gradientColors),
                        startPoint: gradientStart,
                        endPoint: gradientEnd
                    ))
                    .frame(width: UIScreen.main.bounds.width * 0.8, height: 5)
            }
              
            
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(
                    gradient: Gradient(colors: gradientColors),
                    startPoint: gradientStart,
                    endPoint: gradientEnd
                ))
                .frame(width: UIScreen.main.bounds.width * 0.5, height: 5)
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                gradientStart = UnitPoint(x: 1, y: 0)
                gradientEnd = UnitPoint(x: 2, y: 0)
            }
        }
        .padding()
    }
}

#Preview {
    TextPlaceholderView()
}
