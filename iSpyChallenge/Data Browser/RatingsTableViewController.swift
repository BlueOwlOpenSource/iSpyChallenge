//
//  RatingsTableViewController.swift
//  iSpyChallenge
//
//

import Foundation
import UIKit
import CoreData

class RatingsTableViewController: UITableViewController, DataControllerInjectable, UserInjectable, ChallengeInjectable {
    var dataController: DataController!
    var user: User?
    var challenge: Challenge?
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Rating> = {
        let fetchRequest: NSFetchRequest<Rating> = Rating.newFetchRequest()
        if let u = self.user {
            fetchRequest.predicate = NSPredicate(format: "player = %@", u)
        }
        else if let c = self.challenge {
            fetchRequest.predicate = NSPredicate(format: "challenge = %@", c)
        }
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "stars", ascending: true)]
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "RatingCell", for: indexPath)
        configure(cell, at: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Configure Table View Cell
    
    private func configure(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let rating = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = String(format: "%i", rating.stars)
        cell.detailTextLabel?.text = rating.player.username
    }
}

extension RatingsTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
            
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            if let newIndexPath = newIndexPath {
                tableView.deleteRows(at: [newIndexPath], with: .automatic)
            }
            
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
                configure(cell, at: indexPath)
            }
            
        @unknown default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
