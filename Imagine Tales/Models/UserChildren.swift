//
//  UserChildren.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//

import Foundation
struct UserChildren: Codable, Identifiable {
    
    let id: String
    let parentId: String
    let name: String
    let age: String
    let dateCreated: Date
    let username: String
    let profileImage: String
}
