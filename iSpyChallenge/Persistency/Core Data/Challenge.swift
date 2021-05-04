//
//  Challenge.swift
//  iSpyChallenge
//

import UIKit
import CoreData

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
