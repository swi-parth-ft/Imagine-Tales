//
//  UserModel.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//
import Foundation

enum gender: String {
    case male
    case female
}

struct UserModel: Codable {
    let userId: String
    let name: String
    let birthDate: Date?
    let email: String?
    let gender: String
    let country: String
    let number: String
    let isParent: Bool
    
    init(userId: String, name: String, birthDate: Date?, email: String?, gender: String, country: String, number: String, isParent: Bool) {
        self.userId = userId
        self.name = name
        self.birthDate = birthDate
        self.email = email
        self.gender = gender
        self.country = country
        self.number = number
        self.isParent = isParent
    }
}
