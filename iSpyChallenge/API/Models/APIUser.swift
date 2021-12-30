//
//  APIUser.swift
//  iSpyChallenge
//
//

import Foundation

struct APIUser: Codable, Hashable {
    var id: String
    var email: String
    var username: String
    var picture: Picture
    
    struct Picture: Codable, Hashable {
        var large: String
        var medium: String
        var thumbnail: String
    }
}
