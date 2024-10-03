//
//  CustomAlert.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/4/24.
//


import SwiftUI

struct CustomAlert: View {
    @Binding var isShowing: Bool
    let title: String
    let message1: String
    let message2: String
    let onConfirm: () -> Void
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ZStack {
            if isShowing {
                // Background overlay
                BackGroundMesh()
                    .frame(width: 612, height: 321)
                    .cornerRadius(23)
                    .shadow(radius: 10)
                
                // Alert box
                VStack(spacing: 16) {
                    Text(title)
                        .font(.custom("ComicNeue-Bold", size: 32))
                        .padding(.top)
                    
                    Text(message1)
                        .font(.system(size: 24))
                    
                    Text(message2)
                        .font(.system(size: 24))
                    Spacer()
                    HStack(spacing: 20) {
                        Button(action: {
                            isShowing = false
                        }) {
                            Text("Stay and Play!")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .font(.custom("ComicNeue-Bold", size: 24))
                                .padding()
                                .frame(width: 266, height: 70)
                                .background(colorScheme == .dark ? Color(hex: "#9F9F74").opacity(0.3) : Color(hex: "#F2F2DB"))
                                .cornerRadius(16)
                        }
                        
                        Button(action: {
                            onConfirm()
                            isShowing = false
                        }) {
                            Text("Yes, Log Me Out")
                                .foregroundColor(.white)
                                .font(.custom("ComicNeue-Bold", size: 24))
                                .padding()
                                .frame(width: 266, height: 70)
                                .background(Color(hex: "#FF6F61"))
                                .cornerRadius(16)
                        }
                    }
                    .padding(.bottom)
                }
                .padding()
                .frame(width: 612, height: 321)
               
            }
        }
    }
}
