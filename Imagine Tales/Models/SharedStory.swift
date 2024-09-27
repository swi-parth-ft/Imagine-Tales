//
//  SharedStory.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/27/24.
//


struct SharedStory: Codable, Hashable {
    let id: String
    let story: Story
    let fromId: String
}