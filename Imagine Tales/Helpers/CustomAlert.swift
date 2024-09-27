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
    
    var body: some View {
        ZStack {
            if isShowing {
                // Background overlay
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color(hex: "#8AC640"))
                    .frame(width: 612, height: 321)
                
                // Alert box
                VStack(spacing: 16) {
                    Text(title)
                        .font(.custom("ComicNeue-Bold", size: 32))
                        .padding(.top)
                    
                    Text(message1)
                        .font(.system(size: 24))
                        .padding(.top)
                    
                    Text(message2)
                        .font(.system(size: 24))
                    Spacer()
                    HStack(spacing: 20) {
                        Button(action: {
                            isShowing = false
                        }) {
                            Text("Stay and Play!")
                                .foregroundColor(.black)
                                .font(.system(size: 24))
                                .padding()
                                .frame(width: 266, height: 70)
                                .background(Color(hex: "#D0FFD0"))
                                .cornerRadius(16)
                        }
                        
                        Button(action: {
                            onConfirm()
                            isShowing = false
                        }) {
                            Text("Yes, Log Me Out")
                                .foregroundColor(.white)
                                .font(.system(size: 24))
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
