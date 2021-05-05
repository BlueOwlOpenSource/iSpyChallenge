//
//  MatchesTableViewController.swift
//  iSpyChallenge
//
//

import Foundation
import UIKit
import CoreData

class MatchesTableViewController: FetchedTableViewController, DataControllerInjectable, PhotoControllerInjectable, UserInjectable {
    var dataController: DataController!
    var photoController: PhotoController!
    var user: User?

    private lazy var fetchedResultsController: NSFetchedResultsController<Match> = {
        let fetchRequest: NSFetchRequest<Match> = Match.newFetchRequest()
        fetchRequest.predicate = NSPredicate(format: "player = %@", self.user!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "verified", ascending: true)]
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.mainQueueManagedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        return controller
    }()

    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        do {
            try fetchedResultsController.performFetch()
        } catch let error {
            print(error)
        }
    }

    // MARK: - UITableViewDataSource & UITableViewDelegate

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MatchCell", for: indexPath)
        configure(cell, at: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowMatch", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Configure Table View Cell
    
    override func configure(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let match = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = "Match"
        cell.detailTextLabel?.text = String(format: "(%.5f, %.5f)", match.latitude, match.longitude)
        if let thumbnail = photoController.photo(withName: match.photoHref) {
            cell.imageView?.image = thumbnail
        } else {
            cell.imageView?.image = nil
        }
    }

    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        injectProperties(viewController: segue.destination)
    }
    
    // MARK: - Injection
    
    func injectProperties(viewController: UIViewController) {
        if let vc = viewController as? DataControllerInjectable {
            vc.dataController = self.dataController
        }
        
        if let vc = viewController as? PhotoControllerInjectable {
            vc.photoController = self.photoController
        }
        
        if let vc = viewController as? MatchInjectable {
            let match = fetchedResultsController.object(at: tableView.indexPathForSelectedRow!)
            vc.match = match
        }
    }
}
