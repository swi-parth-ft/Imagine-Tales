//
//  UserInfoFormView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//


import SwiftUI

struct UserInfoFormView: View {
    @Binding var name: String
    @Binding var email: String
    @Binding var number: String
    @Binding var gender: String
    @Binding var country: String
    let isCompact: Bool

    var body: some View {
        VStack {
            TextField("Name", text: $name)
                .customTextFieldStyle(isCompact: isCompact)
            
            TextField("Email", text: $email)
                .customTextFieldStyle(isCompact: isCompact)
            
            TextField("Phone", text: $number)
                .customTextFieldStyle(isCompact: isCompact)
            
            VStack {
                Picker("Gender", selection: $gender) {
                    Text("Male").tag("Male")
                    Text("Female").tag("Female")
                }
                .pickerStyle(.segmented)
                .frame(height: isCompact ? 35 : 55)
            }
            
            TextField("Country", text: $country)
                .customTextFieldStyle(isCompact: isCompact)
        }
    }
}