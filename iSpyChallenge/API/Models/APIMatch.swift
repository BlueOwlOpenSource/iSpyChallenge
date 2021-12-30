//
//  APIMatch.swift
//  iSpyChallenge
//
//

import Foundation

struct APIMatch: Codable, Hashable {
    var id: String
    var location: APILocation
    var photo: String
    var verified: Bool
    var user: String
}
