//
//  Environment.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/7/24.
//

import Foundation

public enum Env {
    enum keys {
        static let apikey = "API_KEY"
    }
    
    private static let infoDirectory: [String : Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("plist not fount")
        }
        return dict
    }()
    
    static let apikey: String = {
        guard let apiKeyString = Env.infoDirectory[keys.apikey] as? String else {
            fatalError("API key is not set in plist")
        }
        return apiKeyString
    }()
}
