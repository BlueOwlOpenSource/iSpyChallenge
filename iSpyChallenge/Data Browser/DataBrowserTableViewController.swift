//
//  DataBrowserTableViewController.swift
//  iSpyChallenge
//

import UIKit
import CoreData

class DataBrowserTableViewController: FetchedTableViewController, DataControllerInjectable, PhotoControllerInjectable {
    
    var dataController: DataController!
    var photoController: PhotoController!

    private lazy var fetchedResultsController: NSFetchedResultsController<User> = {
        let fetchRequest: NSFetchRequest<User> = User.newFetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "username", ascending: true)]
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        configure(cell, at: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowUser", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Configure Table View Cell
    
    override func configure(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let user = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = user.username
        cell.detailTextLabel?.text = user.email
        if let thumbnailURL = URL(string: user.avatarThumbnailHref), let data = (try? Data(contentsOf: thumbnailURL)) ?? nil {
            cell.imageView?.image = UIImage(data: data)
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
        
        if let vc = viewController as? UserTableViewController {
            let user = fetchedResultsController.object(at: tableView.indexPathForSelectedRow!)
            vc.user = user
        }
    }
}
