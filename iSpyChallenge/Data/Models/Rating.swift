//
//  Rating.swift
//  iSpyChallenge
//
//

import Foundation

struct Rating: Codable, Hashable {
    var id: String
    var stars: Int
    var creatorID: String
}
