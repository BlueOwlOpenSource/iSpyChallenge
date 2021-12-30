//
//  DataController.swift
//  iSpyChallenge
//
//

import Foundation

protocol DataControllerDelegate: AnyObject {
    func dataControllerDidUpdate(_ dataController: DataController)
}

class DataController {
    private let apiService: APIService
    private weak var delegate: DataControllerDelegate?
    
    private(set) var currentUser: User? { didSet { delegate?.dataControllerDidUpdate(self) } }
    private(set) var allUsers: [User] = [] { didSet { delegate?.dataControllerDidUpdate(self) } }
    
    init(apiService: APIService, delegate: DataControllerDelegate?) {
        self.apiService = apiService
        self.delegate = delegate
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
            self.allUsers = apiUsers.map { User(apiUser: $0, apiChallenges: apiChallenges) }
            self.currentUser = self.allUsers.first
        }
    }
        
    func postNewChallenge(hint: String, latitude: Double, longitude: Double, photoImageName: String) {
        guard let user = currentUser else {
            return
        }
        
        let location = APILocation(latitude: latitude, longitude: longitude)
        apiService.postChallenge(forUserID: user.id,
                                 hint: hint,
                                 location: location,
                                 photoImageName: photoImageName) { result in
            if case .success(let apiChallenge) = result {
                self.addChallengeToCurrentUser(apiChallenge)
            }
        }
    }
}

private extension DataController {
    func addChallengeToCurrentUser(_ apiChallenge: APIChallenge) {
        currentUser?.challenges.append(Challenge(apiChallenge: apiChallenge))
        
        if let currentUser = currentUser,
           let indexOfCurrentUser = allUsers.firstIndex(where: { $0.id == currentUser.id }) {
            allUsers[indexOfCurrentUser] = currentUser
        }
    }
}
