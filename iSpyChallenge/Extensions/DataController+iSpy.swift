//
//  DataController+iSpy.swift
//  iSpyChallenge
//
//

import Foundation

// A set of convenience functions for navigating the data stored in DataController
extension DataController {
    func user(identifiedBy userID: String) -> User? {
        allUsers.first { $0.id == userID }
    }
    
    var allChallenges: [Challenge] {
        allUsers.flatMap { $0.challenges }
    }
    
    func challenge(for match: Match) -> Challenge? {
        allChallenges.first { $0.matches.contains(match) }
    }
        
    func matches(createdBy user: User) -> [Match] {
        allChallenges
            .flatMap { $0.matches }
            .filter { $0.creatorID == user.id }
    }
    
    func ratings(createdBy user: User) -> [Rating] {
        allChallenges
            .flatMap { $0.ratings }
            .filter { $0.creatorID == user.id }
    }
    
    /// Returns the original array of ratings, but with each rating paired with the user that created it.
    func ratingsAndAssociatedUsers(for ratings: [Rating]) -> [RatingAndAssociatedUser] {
        ratings.compactMap { rating in
            guard let user = self.user(identifiedBy: rating.creatorID) else {
                return nil
            }
            
            return RatingAndAssociatedUser(rating: rating, user: user)
        }
    }
}
