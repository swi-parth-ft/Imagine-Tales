//
//  SwiftUIView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/2/24.
//

import SwiftUI


struct SwiftUIView: View {
    var body: some View {
        ZStack {
        
            
            Circle()
                .fill(.pink)
                .frame(width: 200, height: 200)
                
                
            Image("fairy")
                .frame(width: 70, height: 70)
        }
    }
}

#Preview {
    SwiftUIView()
}
