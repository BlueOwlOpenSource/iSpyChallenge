//
//  APIRating.swift
//  iSpyChallenge
//
//

import Foundation

struct APIRating: Codable, Hashable {
    var id: String
    var value: Int
    var user: String
}
