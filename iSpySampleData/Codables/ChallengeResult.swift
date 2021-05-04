//
//  ChallengeResult.swift
//  iSpyChallenge
//
//

import Foundation

struct ChallengesResult: Codable {
    let challenges: [ChallengeResult]
}

struct ChallengeResult: Codable {
    let photo: String
    let hint: String
    let latitude: Double
    let longitude: Double
}
