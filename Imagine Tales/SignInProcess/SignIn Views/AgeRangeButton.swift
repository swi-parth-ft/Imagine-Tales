//
//  AgeRangeButton.swift
//  Imagine Tales
//
//  Created by Parth Antala on 10/6/24.
//

import SwiftUI

struct AgeRangeButton: View {
    let ageRange: SignInWithEmailView.AgeRange
    @Binding var selectedAgeRange: SignInWithEmailView.AgeRange?
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        Button(action: {
            selectedAgeRange = ageRange
        }) {
            Text(ageRange.rawValue)
                .frame(maxWidth: .infinity)
                .padding()
                .background(selectedAgeRange != ageRange ? Color.clear : colorScheme == .dark ? Color(hex: "#9F9F74").opacity(0.3) : Color(hex: "#DFFFDF"))
                
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(colorScheme == .dark ? Color(hex: "#9F9F74").opacity(0.3) : Color(hex: "#DFFFDF"), lineWidth: 2)
                )
        }
        
    }
}
