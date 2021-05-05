//
//  User.swift
//  iSpyChallenge
//

import UIKit
import CoreData

protocol UserInjectable: AnyObject {
    var user: User? { get set }
}

class User: NSManagedObject, ManagedObjectType {
    
    static var entityName = "User"

    @NSManaged var avatarLargeHref: String
    @NSManaged var avatarMediumHref: String
    @NSManaged var avatarThumbnailHref: String
    @NSManaged var email: String
    @NSManaged var username: String
    
    @NSManaged var challenges: Set<Challenge>
    @NSManaged var matches: Set<Match>
    @NSManaged var ratings: Set<Rating>
}
