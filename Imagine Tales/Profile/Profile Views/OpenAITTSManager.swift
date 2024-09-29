import Foundation
import AVFoundation

class OpenAITTS {
    
    private enum constants {
        enum openAI {
            static let url = URL(string: "https://api.openai.com/v1/audio/speech")
            static let apiKey = "\(Env.apikey)"
        }
    }
    
    private var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        return session
    }()
    
    private var audioPlayer: AVAudioPlayer?
    
    func speak(_ text: String) {
        guard let request = self.request(text) else {
            print("No request")
            return
        }
        self.send(request: request)
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            print("Audio session configured successfully.")
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    private func send(request: URLRequest) {
        
        let task = self.urlSession.downloadTask(with: request) { urlOrNil, responseOrNil, errorOrNil in
            if let errorOrNil {
                print(errorOrNil)
                return
            }

            if let response = responseOrNil as? HTTPURLResponse {
                print(response.statusCode)
            }
            
            guard let fileURL = urlOrNil else { return }

            do {
                let documentsURL = try
                    FileManager.default.url(for: .documentDirectory,
                                            in: .userDomainMask,
                                            appropriateFor: nil,
                                            create: false)
                let savedURL = documentsURL.appendingPathComponent("output.mp3")
                            print("Saving to: \(savedURL)")
                // If a file with the same name already exists, remove it
                            if FileManager.default.fileExists(atPath: savedURL.path) {
                                try FileManager.default.removeItem(at: savedURL)
                            }

                            // Move the downloaded file to the new location with the new name
                            try FileManager.default.moveItem(at: fileURL, to: savedURL)
                
                // Play the saved audio file
                self.playAudio(from: savedURL)
                
            } catch {
                print ("file error: \(error)")
            }
        }

        task.resume()
    }
    
    private func playAudio(from url: URL) {
        configureAudioSession()
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            guard let player = audioPlayer else { return }
                       
                       player.prepareToPlay()
                       player.play()
            print("Playing audio...")
        } catch {
            print("Error playing audio: \(error)")
        }
    }
    
    private func request(_ text: String) -> URLRequest? {
        guard let baseURL = Self.constants.openAI.url else {
            return nil
        }
        
        let request = NSMutableURLRequest(url: baseURL)
        let parameters: [String: Any] = [
            "model": "tts-1",
            "voice": "nova",
            "response_format": "mp3",
            "speed": "0.98",  // hidden feature in OpenAI TTS! Range: 0.25 - 4.0, Default 1.0
            "input": text
        ]
        
        request.addValue("Bearer \(Self.constants.openAI.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) {
            request.httpBody = jsonData
        }
        
        return request as URLRequest
    }
}
