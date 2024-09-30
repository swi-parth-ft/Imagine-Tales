//
//  Notification.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/30/24.
//

import Foundation

struct Notification: Codable, Hashable, Identifiable {
   
    var id: String
    var fromId: String
    var toId: String
    var storyId: String
    var timeStamp: Date
    var read: Bool
    var type: String
    var fromChildUsername: String
    var fromChildProfileImage: String
    var storyTitle: String
    
    init(id: String = UUID().uuidString, fromId: String, toId: String, storyId: String, timeStamp: Date = Date(), read: Bool, type: String, fromChildUsername: String, fromChildProfileImage: String, storyTitle: String) {
        self.id = id
        self.fromId = fromId
        self.toId = toId
        self.storyId = storyId
        self.timeStamp = timeStamp
        self.read = read
        self.type = type
        self.fromChildUsername = fromChildUsername
        self.fromChildProfileImage = fromChildProfileImage
        self.storyTitle = storyTitle
    }
    
}
