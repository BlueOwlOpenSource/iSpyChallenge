//
//  APIService.swift
//  iSpyChallenge
//
//

import Foundation

/// This is a mock API service that just returns data from the JSONs bundled with this Xcode project.
/// A real API service would make requests to a backend service to provide that data exposed in this interface.
class APIService {
    func getUsers(completion: @escaping ([APIUser]) -> Void) {
        let users: [APIUser]? = object(fromJSONNamed: "users")
        
        executeOnBackground(afterTimeInterval: 2) {
            completion(users ?? [])
        }
    }
    
    func getChallenges(completion: @escaping ([APIChallenge]) -> Void) {
        let challenges: [APIChallenge]? = object(fromJSONNamed: "challenges")
        
        executeOnBackground(afterTimeInterval: 2) {
            completion(challenges ?? [])
        }
    }
    
    func postChallenge(forUser userId: String,
                       hint: String,
                       location: APILocation,
                       photoImageName: String,
                       completion: @escaping (Result<APIChallenge, Error>) -> Void) {
        // Mock a successful response from the API
        let apiChallenge = APIChallenge(id: UUID().uuidString,
                                        photo: photoImageName,
                                        hint: hint,
                                        user: userId,
                                        location: location,
                                        matches: [],
                                        ratings: [])
        
        executeOnBackground(afterTimeInterval: 2) {
            completion(.success(apiChallenge))
        }
    }
    
    func postMatch(fromUser userId: String,
                   forChallenge challengeId: String,
                   location: APILocation,
                   photo: String,
                   completion: @escaping (Result<APIMatch, Error>) -> Void) {
        // Mock a successful response from the API
        let apiMatch = APIMatch(id: UUID().uuidString,
                                location: location,
                                photo: photo,
                                verified: false,
                                user: userId)
        
        executeOnBackground(afterTimeInterval: 2) {
            completion(.success(apiMatch))
        }
    }
}

private func executeOnBackground(afterTimeInterval timeInterval: TimeInterval, execute: @escaping () -> Void) {
    DispatchQueue
        .global(qos: .background)
        .asyncAfter(deadline: .now() + timeInterval, execute: execute)
}

private func object<T: Decodable>(fromJSONNamed jsonName: String) -> T? {
    guard let url = Bundle.main.url(forResource: jsonName, withExtension: "json") else {
        print("APIService error: Could not find resource for JSON named '\(jsonName)'")
        return nil
    }
    
    do {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    } catch {
        print("APIService error: \(error)")
        return nil
    }
}
