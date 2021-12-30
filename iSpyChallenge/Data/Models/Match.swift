//
//  Match.swift
//  iSpyChallenge
//
//

import Foundation

struct Match: Codable, Hashable {
    var id: String
    var latitude: Double
    var longitude: Double
    var photoImageName: String
    var verified: Bool
    var creatorID: String
}
