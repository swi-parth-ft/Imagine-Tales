//
//  SpeechManager.swift
//  Imagine Tales
//
//  Created by Parth Antala on 9/29/24.
//


import UIKit
import AVFoundation
import NaturalLanguage

class SpeechManager {
    let synthesizer = AVSpeechSynthesizer()
    
    // Analyze sentiment using NLTagger
    func analyzeSentiment(of text: String) -> Double {
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text

        let (sentiment, _) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
        
        if let sentimentScore = sentiment?.rawValue, let score = Double(sentimentScore) {
            return score  // Sentiment ranges from -1.0 (negative) to 1.0 (positive)
        }
        return 0.0  // Neutral if no score found
    }

    // Detect emotion based on sentiment score
    func detectEmotion(from sentimentScore: Double) -> String {
        if sentimentScore > 0.7 {
            return "excited"
        } else if sentimentScore > 0.4 {
            return "happy"
        } else if sentimentScore > 0 {
            return "calm"
        } else if sentimentScore < -0.7 {
            return "angry"
        } else if sentimentScore < -0.4 {
            return "sad"
        } else if sentimentScore < 0 {
            return "fearful"
        } else {
            return "neutral"
        }
    }

    // Set speech properties based on detected emotion
    func setNaturalSpeechProperties(for emotion: String, text: String) -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: text)
        
        switch emotion {
        case "happy":
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate + 0.1
            utterance.pitchMultiplier = 1.2
            utterance.volume = 1.0
            
        case "sad":
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate - 0.1
            utterance.pitchMultiplier = 0.8
            utterance.volume = 0.7
            
        case "excited":
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate + 0.2
            utterance.pitchMultiplier = 1.5
            utterance.volume = 1.0
            
        case "angry":
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate
            utterance.pitchMultiplier = 1.0
            utterance.volume = 1.2
            
        case "fearful":
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate
            utterance.pitchMultiplier = 0.9
            utterance.volume = 0.8
            
        case "calm":
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate
            utterance.pitchMultiplier = 1.0
            utterance.volume = 0.9
            
        default:
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate
            utterance.pitchMultiplier = 1.0
            utterance.volume = 1.0
        }
        
        return utterance
    }

    // Set a specific voice for the utterance
    func setSpeechVoice(for utterance: AVSpeechUtterance, language: String) {
        if let voice = AVSpeechSynthesisVoice(language: language) {
            utterance.voice = voice
        }
    }

    // Narrate text with dynamic emotion adjustments
    func narrateWithDynamicEmotion(paragraph: String) {
        let sentences = paragraph.split(separator: ".")
        
        for sentence in sentences {
            let sentimentScore = analyzeSentiment(of: String(sentence))
            let detectedEmotion = detectEmotion(from: sentimentScore)
            
            let utterance = setNaturalSpeechProperties(for: detectedEmotion, text: String(sentence))
            setSpeechVoice(for: utterance, language: "en-US") // Set preferred language and voice
            
            synthesizer.speak(utterance)
            
            // Optional: Add a slight delay between sentences for a more natural flow
            Thread.sleep(forTimeInterval: 0.5)
        }
    }
}

// Example usage

