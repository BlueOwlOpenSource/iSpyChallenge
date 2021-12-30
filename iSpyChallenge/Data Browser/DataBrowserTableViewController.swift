//
//  DataBrowserTableViewController.swift
//  iSpyChallenge
//

import UIKit
import CoreData

class DataBrowserTableViewController: UITableViewController {
    var dataController: DataController!
    var users: [User] = []
    
    // MARK: - UITableViewDataSource & UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        
        if let user = users[safe: indexPath.row] {
            cell.textLabel?.text = user.username
            cell.detailTextLabel?.text = user.email
            cell.imageView?.image = user.avatarLargeURL?.loadedIntoImage
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowUser", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
        
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        injectProperties(viewController: segue.destination)
    }
    
    // MARK: - Injection
    
    func injectProperties(viewController: UIViewController) {
        if let vc = viewController as? UserTableViewController {
            vc.dataController = dataController
            vc.user = users[safe: tableView.indexPathForSelectedRow?.row]
        }
    }
}
