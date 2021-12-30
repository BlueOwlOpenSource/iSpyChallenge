//
//  User.swift
//  iSpyChallenge
//
//

import Foundation

struct User: Codable, Hashable {
    var id: String
    var email: String
    var username: String
    var avatarLargeURL: URL?
    var avatarMediumURL: URL?
    var avatarThumbnailURL: URL?
    var challenges: [Challenge]
}
