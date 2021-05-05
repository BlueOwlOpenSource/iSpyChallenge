//
//  Challenge.swift
//  iSpyChallenge
//

import UIKit
import CoreData

protocol ChallengeInjectable: AnyObject {
    var challenge: Challenge? { get set }
}

class Challenge: NSManagedObject, ManagedObjectType {

    static var entityName = "Challenge"
    
    @NSManaged var hint: String
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var photoHref: String
    
    @NSManaged var creator: User
    @NSManaged var matches: Set<Match>
    @NSManaged var ratings: Set<Rating>
}
