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
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var isTextFieldFocused: Bool
    let countries = ["United States", "Canada", "India", "United Kingdom", "Germany", "France", "Australia", "Japan", "China", "Brazil"]
    @State private var selectedCountry: String = "United States" // Default selection
    @State private var isDropdownExpanded: Bool = false
    var body: some View {
        VStack {
            TextField("Name", text: $name)
                .customTextFieldStyle(isCompact: isCompact)
                .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                .cornerRadius(isCompact ? 6 : 12)
                .focused($isTextFieldFocused)
                .onAppear {
                    isTextFieldFocused = true
                }
                
            
            TextField("Email", text: $email)
                .customTextFieldStyle(isCompact: isCompact)
                .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                .cornerRadius(isCompact ? 6 : 12)
                
            
            TextField("Phone", text: $number)
                .customTextFieldStyle(isCompact: isCompact)
                .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                .cornerRadius(isCompact ? 6 : 12)
            
            HStack {
                Button {
                    gender = "Male"
                } label: {
                    Text("Male")
                        .padding()
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                        .frame(width: UIScreen.main.bounds.width * 0.34, height: isCompact ? 35 : 55)
                        .background(colorScheme == .dark ? (gender == "Male" ? Color(hex: "#FF6F61") : .black.opacity(0.2)) : (gender == "Female" ? Color(hex: "#FF6F61") : .white))
                        .cornerRadius(isCompact ? 6 : 12)
                }
                
                Spacer()
                
                Button {
                    gender = "Female"
                } label: {
                    Text("Female")
                        .padding()
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                        .frame(width: UIScreen.main.bounds.width * 0.34, height: isCompact ? 35 : 55)
                        .background(colorScheme == .dark ? (gender == "Female" ? Color(hex: "#FF6F61") : .black.opacity(0.2)) : (gender == "Female" ? Color(hex: "#FF6F61") : .white))
                        .cornerRadius(isCompact ? 6 : 12)
                }
                
            }
            .frame(width: UIScreen.main.bounds.width * 0.7, height: isCompact ? 35 : 55)
    
            VStack(alignment: .leading) {
                        // Label and dropdown button combined
                        HStack {
                            Text("Country:")
                                .padding()
                            
                            Spacer()

                            // Dropdown button
                            Button(action: {
                                withAnimation {
                                    isDropdownExpanded.toggle() // Toggle dropdown visibility
                                }
                            }) {
                                HStack {
                                    Text(country) // Display the selected country
                                        .foregroundColor(colorScheme == .dark ? .white : .black) // Default style for unselected state
                                    Spacer()
                                    Image(systemName: isDropdownExpanded ? "chevron.up" : "chevron.down") // Arrow icon for dropdown
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .frame(height: isCompact ? 35 : 55)
                                .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                                .cornerRadius(isCompact ? 6 : 12)
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.7, height: isCompact ? 35 : 55)

                        // Dropdown menu
                        if isDropdownExpanded {
                            ScrollView{
                                VStack(alignment: .leading, spacing: 5) {
                                    ForEach(countries, id: \.self) { co in
                                        Button(action: {
                                            country = co // Set the selected country
                                            isDropdownExpanded = false // Close the dropdown after selection
                                        }) {
                                            Text(co)
                                                .padding(.vertical, 8)
                                                .frame(maxWidth: .infinity, alignment: .center) // Left-align items
                                                .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                                                .cornerRadius(isCompact ? 6 : 12)
                                        }
                                        
                                    }
                                }
                                
                                .padding(.horizontal)
                                .transition(.opacity) // Smooth transition for dropdown appearance
                            }
                            .frame(height: UIScreen.main.bounds.height * 0.3)
                        }

                        Spacer()
                    }
            
                  
        }
    }
}
