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

    var body: some View {
        VStack {
            SecureField("Password", text: $password)
                .customTextFieldStyle(isCompact: isCompact)
            
            SecureField("Confirm Password", text: $confirmPassword)
                .customTextFieldStyle(isCompact: isCompact)
            
            Text(errorMessage)
                .foregroundColor(.red) // Customize error message color
                .font(.footnote) // Adjust font size if needed
                .padding(.top, 4) // Add some space above the error message
        }
    }
}