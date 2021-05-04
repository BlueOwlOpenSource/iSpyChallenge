//
//  UserResult.swift
//  iSpyChallenge
//
//

import Foundation

struct UsersResults: Codable {
    let results: [UserResult]
}

struct UserResult: Codable {
    let email: String
    let login: LoginResult
    let picture: PictureResult
}

struct LoginResult: Codable {
    let username: String
    let password: String
    let salt: String
    let md5: String
    let sha1: String
    let sha256: String
}

struct PictureResult: Codable {
    let large: String
    let medium: String
    let thumbnail: String
}
