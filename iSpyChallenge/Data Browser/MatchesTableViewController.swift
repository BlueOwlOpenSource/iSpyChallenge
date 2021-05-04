//
//  MatchesTableViewController.swift
//  iSpyChallenge
//
//

import Foundation
import UIKit
import CoreData

class MatchesTableViewController: UITableViewController, DataControllerInjectable, PhotoControllerInjectable {
    var dataController: DataController!
    var photoController: PhotoController!
    var user: User!

    private lazy var fetchedResultsController: NSFetchedResultsController<Match> = {
        let fetchRequest: NSFetchRequest<Match> = Match.newFetchRequest()
        fetchRequest.predicate = NSPredicate(format: "player = %@", self.user)
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
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Configure Table View Cell
    
    private func configure(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let match = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = "Match"
        cell.detailTextLabel?.text = String(format: "(%.3f, %.3f)", match.latitude, match.longitude)
        if let thumbnail = photoController.photo(withName: match.photoHref) {
            cell.imageView?.image = thumbnail
        } else {
            cell.imageView?.image = nil
        }
    }

}

extension MatchesTableViewController: NSFetchedResultsControllerDelegate {
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
