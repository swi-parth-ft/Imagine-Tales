//
//  Charater.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//


struct Charater: Codable, Identifiable {
    let id: String
    let name: String
    let gender: String
    let emotion: String
    let age: Int
}

struct Pet: Codable, Identifiable {
    let id: String
    let name: String
    let kind: String
}