//
//  APIChallenge.swift
//  iSpyChallenge
//
//

import Foundation

struct APIChallenge: Codable, Hashable {
    var id: String
    var photo: String
    var hint: String
    var user: String
    var location: APILocation
    var matches: [APIMatch]
    var ratings: [APIRating]
}
