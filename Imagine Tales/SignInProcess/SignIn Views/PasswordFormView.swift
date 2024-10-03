//
//  PasswordFormView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//


import SwiftUI

struct PasswordFormView: View {
    @Binding var password: String
    @Binding var confirmPassword: String
    @Binding var errorMessage: String
    let isCompact: Bool
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var isTextFieldFocused: Bool
    var body: some View {
        VStack {
            SecureField("Password", text: $password)
                .customTextFieldStyle(isCompact: isCompact)
                .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                .cornerRadius(isCompact ? 6 : 12)
                .focused($isTextFieldFocused)
                .onAppear {
                    isTextFieldFocused = true
                }
            
            SecureField("Confirm Password", text: $confirmPassword)
                .customTextFieldStyle(isCompact: isCompact)
                .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                .cornerRadius(isCompact ? 6 : 12)
            
            Text(errorMessage)
                .foregroundColor(.red) // Customize error message color
                .font(.footnote) // Adjust font size if needed
                .padding(.top, 4) // Add some space above the error message
        }
    }
}
