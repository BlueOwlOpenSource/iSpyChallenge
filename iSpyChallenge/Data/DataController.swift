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
}
