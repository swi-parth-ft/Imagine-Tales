//
//  OpenAIService.swift
//  Image Sandbox
//
//  Created by Parth Antala on 8/10/24.
//


import Foundation
import UIKit

class OpenAIService {
    static let shared = OpenAIService()
    
    private init() {
       
    }
    
    private let apiKey = "\(Environment.apikey)"
    private let url = URL(string: "https://api.openai.com/v1/images/generations")!
    
    func generateImage(from prompt: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "prompt": prompt,
            "n": 1,
            "size": "1024x1024"
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let dataArr = json["data"] as? [[String: Any]],
                  let urlString = dataArr.first?["url"] as? String,
                  let url = URL(string: urlString) else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data, let image = UIImage(data: data) else {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])))
                    return
                }
                
                completion(.success(image))
            }.resume()
        }
        
        task.resume()
    }
}
