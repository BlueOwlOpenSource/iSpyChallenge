//
//  User+iSpy.swift
//  iSpyChallenge
//
//

import Foundation

extension User {
    init(apiUser: APIUser, apiChallenges: [APIChallenge]) {
        self.init(
            id: apiUser.id,
            email: apiUser.email,
            username: apiUser.username,
            avatarLargeURL: URL(string: apiUser.picture.large),
            avatarMediumURL: URL(string: apiUser.picture.medium),
            avatarThumbnailURL: URL(string: apiUser.picture.thumbnail),
            challenges: apiChallenges
                .filter { $0.user == apiUser.id }
                .map { Challenge(apiChallenge: $0) }
        )
    }
}
