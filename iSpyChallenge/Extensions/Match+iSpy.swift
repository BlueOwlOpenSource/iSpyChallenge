//
//  Match+iSpy.swift
//  iSpyChallenge
//
//

import Foundation

extension Match {
    init(apiMatch: APIMatch) {
        self.init(id: apiMatch.id,
                  latitude: apiMatch.location.latitude,
                  longitude: apiMatch.location.longitude,
                  photoImageName: apiMatch.photo,
                  verified: apiMatch.verified,
                  creatorID: apiMatch.user)
    }
}
