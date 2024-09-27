//
//  StoryTextItem.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//


// Struct for each story text item
struct StoryTextItem: Codable, Hashable {
    var image: String
    var text: String
}

// Struct for the story document
struct Story: Codable, Hashable, Identifiable {
    let id: String
    var parentId: String
    var childId: String
    var storyText: [StoryTextItem]
    var title: String
    var status: String
    var genre: String
    var childUsername: String
    var likes: Int
    var theme: String?
    var summary: String?
}