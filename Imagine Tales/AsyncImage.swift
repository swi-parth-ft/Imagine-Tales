//
//  AsyncImage.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/2/24.
//

import SwiftUI

struct AsyncCircularImageView: View {
    let urlString: String
    let size: CGFloat
    
    var body: some View {
        AsyncImage(url: URL(string: urlString)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle()) // Clip to circle shape
                
            case .empty, .failure:
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: size, height: size)
                
            @unknown default:
                EmptyView()
            }
        }
    }
}
