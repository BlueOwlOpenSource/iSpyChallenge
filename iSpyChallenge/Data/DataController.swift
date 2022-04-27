//
//  DataController.swift
//  iSpyChallenge
//
//

import Foundation

extension NSNotification.Name {
    /// Indicates that a `DataController` instance updated its data.
    /// This notification is only fired on the main thread.
    static let dataControllerDidUpdate = NSNotification.Name(rawValue: "dataControllerDidUpdate")
}

class DataController {
    private let apiService: APIService
    
    private(set) var allUsers: [User] = [] {
        didSet {
            NotificationCenter.default.post(name: .dataControllerDidUpdate, object: self)
        }
    }
    
    // A hack for this project -- assume that the first user is the current user
    private let currentUserIndex = 0
    
    init(apiService: APIService) {
        self.apiService = apiService
    }
    
    var currentUser: User? {
        allUsers[safe: currentUserIndex]
    }
    
    func loadAllData() {
        var apiUsers: [APIUser] = []
        var apiChallenges: [APIChallenge] = []
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        apiService.getUsers {
            apiUsers = $0
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        apiService.getChallenges {
            apiChallenges = $0
            dispatchGroup.leave()
        }
        
        DispatchQueue.global(qos: .background).async {
            dispatchGroup.wait()
            DispatchQueue.main.async {
                self.allUsers = apiUsers.map { User(apiUser: $0, apiChallenges: apiChallenges) }
            }
        }
    }
    
    func addChallengeForCurrentUser(hint: String,
                                    latitude: Double,
                                    longitude: Double,
                                    photoImageName: String) {
        guard let currentUser = currentUser else {
            return
        }
        
        apiService.postChallenge(forUserID: currentUser.id,
                                 hint: hint,
                                 location: APILocation(latitude: latitude, longitude: longitude),
                                 photoImageName: photoImageName) { result in
            if case .success(let apiChallenge) = result {
                DispatchQueue.main.async {
                    self.allUsers[self.currentUserIndex]
                        .challenges
                        .append(Challenge(apiChallenge: apiChallenge))
                }
            }
        }
    }
}
