//
//  DataController.swift
//  iSpyChallenge
//

import CoreData
import UIKit

protocol DataControllerInjectable: AnyObject {
    var dataController: DataController! { get set }
}

enum CoreDataStackError: Error {
    case invalidManagedObjectModuleName
    case unsupportedPersistentStoreType
}

class DataController: NSObject {
    
    private let moduleName: String
    private let storeType: String
    private let bundle: Bundle
    
    // MARK: - Initializer
    
    init(managedObjectModuleName: String, persistentStoreType: String, managedObjectModuleBundle: Bundle) throws {
        
        if managedObjectModuleBundle.url(forResource: managedObjectModuleName, withExtension: "momd") == nil {
            throw CoreDataStackError.invalidManagedObjectModuleName
        } else if persistentStoreType != NSInMemoryStoreType && persistentStoreType != NSSQLiteStoreType {
            throw CoreDataStackError.unsupportedPersistentStoreType
        }
        
        moduleName = managedObjectModuleName
        storeType = persistentStoreType
        bundle = managedObjectModuleBundle
                
        super.init()
        
        if shouldPopulateSampleData() {
            populateWithSampleData()
        }
    }
    
    // MARK: - Private State
    
    private lazy var applicationsDocumentsDirectory: URL = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let url = bundle.url(forResource: moduleName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: url)!
    }()
    
    private var persistentStoreURL: URL {
        return applicationsDocumentsDirectory.appendingPathComponent("\(moduleName).sqlite")
    }
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        if storeType == NSInMemoryStoreType {
            do {
                try coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
            } catch {
                fatalError("NSInMemoryStoreType persistent store error: \(error)")
            }
        
        } else if storeType == NSSQLiteStoreType {
            do {
                let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
                try coordinator.addPersistentStore(ofType: storeType, configurationName: nil, at: persistentStoreURL, options: options)
            } catch {
                fatalError("NSSQLiteStoreType persistent store error: \(error)")
            }
        }
        
        return coordinator
    }()
    
    private lazy var persistenceManagedObjectContext: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.persistentStoreCoordinator = persistentStoreCoordinator
        return moc
    }()
    
    // MARK: - Managed Object Contexts
    
    lazy var mainQueueManagedObjectContext: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        moc.parent = persistenceManagedObjectContext
        moc.name = "Main Queue Context"
        NotificationCenter.default.addObserver(self, selector: #selector(DataController.didSaveContext(_:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: moc)
        return moc
    }()
    
    // MARK: - Managed Object Context Did Save Event Handling
    
    @objc func didSaveContext(_ notification: NSNotification) {
        
        guard let moc = notification.object as? NSManagedObjectContext else {
            assertionFailure("Notification posted from an object other than an NSManagedObjectContext")
            return
        }
        
        guard  let parentContext = moc.parent else {
            return
        }
        
        parentContext.performAndWait {
            do {
                try parentContext.save()
            } catch {
                print("Data Controller = Error saving parent context")
            }
        }
    }
        
    // MARK: - Deallocation
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Sample Data

extension DataController {
    func shouldPopulateSampleData() -> Bool {
        return !FileManager.default.fileExists(atPath: persistentStoreURL.path)
    }
    
    func populateWithSampleData() {
        let photoController = try? PhotoController()
        photoController?.removeAllPhotos()
        
        let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.parent = mainQueueManagedObjectContext
        
        moc.performAndWait {
            for result in getUserResult() {
                if let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: moc) as? User {
                    
                    user.email = result.email
                    user.username = result.login.username
                    user.avatarLargeHref = result.picture.large
                    user.avatarMediumHref = result.picture.medium
                    user.avatarThumbnailHref = result.picture.thumbnail
                }
                else {
                    print("Failed to load sample users.")
                }
            }
        }
        
        moc.performAndWait {
            let request = User.newFetchRequest()
            let users = try! moc.fetch(request)

            for result in getChallengeResult() {
                let photo = UIImage(named: result.photo)!
                photoController?.addPhoto(withName: result.photo, image: photo)
                
                if let challenge = NSEntityDescription.insertNewObject(forEntityName: "Challenge", into: moc) as? Challenge {
                    challenge.hint = result.hint
                    challenge.photoHref = result.photo
                    challenge.latitude = result.latitude
                    challenge.longitude = result.longitude
                    
                    let randomUser = users.randomElement()! as! User
                    challenge.creator = randomUser
                    
                    if let rating = NSEntityDescription.insertNewObject(forEntityName: "Rating", into: moc) as? Rating {
                        rating.stars = Int.random(in: 1..<5)
                        rating.challenge = challenge
                        rating.player = randomUser
                    }
                    else {
                        print("Failed to generate random rating for challenge.")
                    }
                }
                else {
                    print("Failed to load sample challenges.")
                }
            }
        }
        
        moc.performAndWait {
            let userRequest = User.newFetchRequest()
            let users = try! moc.fetch(userRequest)

            let challengeRequest = Challenge.newFetchRequest()
            let challenges = try! moc.fetch(challengeRequest)
            
            for user in users {
                let numMatches = Int.random(in: 1...challenges.count)
                for _ in 0...numMatches {
                    let challenge = challenges.randomElement() as! Challenge
                    
                    if let match = NSEntityDescription.insertNewObject(forEntityName: "Match", into: moc) as? Match {
                        match.photoHref = challenge.photoHref
                        match.longitude = challenge.longitude
                        match.latitude = challenge.latitude
                        match.player = user as! User
                        match.challenge = challenge
                        match.verified = false
                    }
                    else {
                        print("Failed to generate random matches for user.")
                    }
                }
            }
        }
        
        do {
            try moc.save()
        }
        catch {
            print(error.localizedDescription)
        }

    }
    
    func getUserResult() -> [UserResult] {
        guard let url = Bundle.main.url(forResource: "users", withExtension: "json") else { return [] }
        guard let users = try? Data(contentsOf: url) else { return [] }
        
        let userResult = try? JSONDecoder().decode(UsersResults.self, from: users)
        return userResult?.results ?? []
    }
    
    func getChallengeResult() -> [ChallengeResult] {
        guard let url = Bundle.main.url(forResource: "challenges", withExtension: "json") else { return [] }
        guard let challenges = try? Data(contentsOf: url) else { return [] }
        
        let challengeResult = try? JSONDecoder().decode(ChallengesResult.self, from: challenges)
        return challengeResult?.challenges  ?? []
    }

}
