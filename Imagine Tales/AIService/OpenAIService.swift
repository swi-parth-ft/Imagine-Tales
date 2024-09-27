//
//  OpenAIService.swift
//  Image Sandbox
//
//  Created by Parth Antala on 8/10/24.
//

import Foundation
import UIKit

class OpenAIService {
    static let shared = OpenAIService() // Singleton instance of OpenAIService

    private init() {
        // Private initializer to prevent creating multiple instances
    }
    
    private let apiKey = "\(Env.apikey)" // API key for OpenAI, fetched from environment variables
    private let url = URL(string: "https://api.openai.com/v1/images/generations")! // URL for the OpenAI image generation endpoint
    
    /// Generates an image from a given prompt using OpenAI's API.
    /// - Parameters:
    ///   - prompt: The text prompt to generate an image from.
    ///   - completion: A closure that is called with the result of the image generation.
    func generateImage(from prompt: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        var request = URLRequest(url: url) // Create a URL request for the image generation API
        request.httpMethod = "POST" // Set the request method to POST
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // Set content type to JSON
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization") // Set authorization header with Bearer token
        
        // Define the body of the request
        let body: [String: Any] = [
            "model": "dall-e-3", // Specify the model to use
            "prompt": prompt, // The prompt for image generation
            "n": 1, // Number of images to generate
            "size": "1024x1024" // Size of the generated image
        ]
        
        // Serialize the body to JSON
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        // Create a data task to send the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle any error from the request
            if let error = error {
                completion(.failure(error)) // Return the error
                return
            }
            
            // Check if data is received
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let dataArr = json["data"] as? [[String: Any]], // Extract the 'data' array from the JSON response
                  let urlString = dataArr.first?["url"] as? String, // Get the URL of the generated image
                  let url = URL(string: urlString) else {
                // Handle invalid response
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }
            
            // Fetch the image data from the generated URL
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    completion(.failure(error)) // Return the error if any occurs
                    return
                }
                
                // Check if the image data is valid
                guard let data = data, let image = UIImage(data: data) else {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"]))) // Handle invalid image data
                    return
                }
                
                completion(.success(image)) // Return the successfully generated image
            }.resume() // Start the task to fetch the image data
        }
        
        task.resume() // Start the task to send the request
    }
}
